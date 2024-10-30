# --------------------------------------------
#  EMT solver main function
#  2020-2024 Bin Wang, Min Xiong, Deepthi Vaidhynathan, Jonathan Maack
#  Last modified: 8/15/24
# --------------------------------------------

import sys
import time
import os, sys
import json
import numpy as np
from Lib_BW import *
from psutils import *
from preprocessscript import get_json_pkl
from psutils import initialize_bus_fault

workingfolder = '.'
os.chdir(workingfolder)

def main():
    SimMod = 0  # 0 - Save a snapshot, 1 - run from a snapshot
    DSrate = 10 # down sampling rate, i.e. results saved every DSrate sim steps.

    systemN = 6 # 1: 2-gen, 2: 9-bus, 3: 39-bus, 4: 179-bus, 5: 240-bus, 6: 2-area
    N_row = 1  # haven't tested the mxn layout, so plz don't set N_row/N_col to other nums.
    N_col = 1

    ts = 50e-6  # time step, second
    Tlen = 2  # total simulation time length, second
    t_release_f = 0.0
    loadmodel_option = 1  # 1-const rlc, 2-const z
    netMod = 'lu'  #'inv': direct inverse, 'lu': LU decomposition
    nparts = 2 # number of blocks in BBD form

    output_snp_ful = 'sim_snp_S' + str(systemN) + '_' + str(int(ts * 1e6)) + 'u.pkl'
    output_snp_1pt = 'sim_snp_S' + str(systemN) + '_' + str(int(ts * 1e6)) + 'u_1pt.pkl'
    output_res = 'sim_res_S' + str(systemN) + '_' + str(int(ts * 1e6)) + 'u.pkl'
    input_snp = 'sim_snp_S' + str(systemN) + '_' + str(int(ts * 1e6)) + 'u_1pt.pkl'

    t0 = time.time()
    if SimMod == 0:
        (pfd, ini, dyd, emt) = initialize_emt(workingfolder, systemN, N_row, N_col, ts, Tlen, mode = netMod, nparts=nparts)
    else:
        (pfd, ini, dyd, emt) = initialize_from_snp(input_snp, netMod, nparts)

    ## ---------------------- other simulation setting ----------------------------------------------------------
    # ctrl step change
    emt.t_sc = 10
    emt.i_gen_sc = 0
    emt.flag_exc_gov = 1  # 0 - exc, 1 - gov
    emt.dsp = - 0.02
    emt.flag_sc = 1

    # gen trip
    emt.t_gentrip = 50
    emt.i_gentrip = 0   # 0: 1032 C for WECC 240-bus
    emt.flag_gentrip = 1 
    emt.flag_reinit = 1

    # Bus grounding fault, with line trip
    emt.busfault_t = 10
    emt.fault_bus_idx = 0 
    emt.busfault_tlen = 4/60 # 5 cycles
    emt.busfault_type = 7 # Check psutils for fault types
    emt.busfault_r = [x / 100000 for x in [1, 1, 1, 1, 1, 1]]
    emt.fault_tripline = 0 # 1: Enable tripping line
    emt.fault_line_idx = 0 #2
    emt.bus_del_ind=[]  #bus delete index, do not change
    emt.add_line_num=0  # Do not change

    # Before t = t_release_f, PLL freq are fixed at synchronous freq
    emt.t_release_f = t_release_f
    emt.loadmodel_option = loadmodel_option  # 1-const rlc, 2-const z

    t1 = time.time()

    t_solve = 0.0
    t_busmea = 0.0
    t_pred = 0.0
    t_upig = 0.0
    t_upir = 0.0
    t_upil = 0.0
    t_upx = 0.0
    t_upxr = 0.0
    t_upxl = 0.0
    t_save = 0.0
    t_upih = 0.0
    Nsteps = 0

    # time loop
    tn = 0
    tsave = 0

    # Initialize Bus fault
    if emt.busfault_t > 0.0 and emt.busfault_t < emt.Tlen:
        initialize_bus_fault(pfd,ini,dyd,emt, netMod)
    
    cap_line=1
    while tn*ts < Tlen:
        tn = tn + 1
        emt.StepChange(dyd, ini, tn)                # configure step change in exc or gov references
        emt.GenTrip(pfd, dyd, ini, tn, netMod)      # configure generation trip

        if tn*ts < emt.busfault_t:
            emt.net_coe = ini.Init_net_coe0
            # emt.Ginv = ini.Init_net_G0 #TODO: Check whether this is correct? No inverse at all
            if netMod == 'inv':
                emt.Ginv=ini.Init_net_G0_inv
            elif netMod == 'lu':
                emt.Glu = ini.Init_net_G0_lu
            emt.brch_range = np.array([0,len(emt.net_coe)]).reshape(2,1) # 
        elif (tn*ts >= emt.busfault_t) and (tn*ts < emt.busfault_t+emt.busfault_tlen):
            # emt.Ginv = ini.Init_net_G1
            emt.net_coe = ini.Init_net_coe1
            if netMod == 'inv':
                emt.Ginv=ini.Init_net_G1_inv
            elif netMod == 'lu':
                emt.Glu = ini.Init_net_G1_lu
            emt.brch_range = np.array([0,len(emt.net_coe)]).reshape(2,1) # Min, consider new lines under fault
            if cap_line==1: # do it only once
                emt.brch_Ipre= np.append(emt.brch_Ipre,np.zeros(emt.add_line_num)) # added line, Ipre=0
                emt.brch_Ihis= np.append(emt.brch_Ihis,np.zeros(emt.add_line_num))
                cap_line=0
        else:
            emt.net_coe = ini.Init_net_coe2
            if netMod == 'inv':
                emt.Ginv = ini.Init_net_G2
            elif netMod == 'lu':
                emt.Glu = ini.Init_net_G2_lu
            emt.brch_range = np.array([0,len(emt.net_coe)]).reshape(2,1) # Min
            if cap_line==0: # do it only once
                if emt.fault_tripline == 0:
                    emt.brch_Ipre=emt.brch_Ipre[:-emt.add_line_num]
                    emt.brch_Ihis=emt.brch_Ihis[:-emt.add_line_num] # delete those added lines
                if emt.fault_tripline == 1:  
                    emt.brch_Ipre=emt.brch_Ipre[:-emt.add_line_num]
                    emt.brch_Ihis=emt.brch_Ihis[:-emt.add_line_num] # delete those added lines
                    emt.brch_Ipre=np.delete(emt.brch_Ipre, emt.bus_del_ind, 0) # 0 delete row
                    emt.brch_Ihis=np.delete(emt.brch_Ihis, emt.bus_del_ind, 0) # Delete those related to tripped lines, to match the index in update Ihis                 
                cap_line=1

        tl_0 = time.time()
        emt.predictX(pfd, dyd, emt.ts)

        tl_1 = time.time()
        emt.Igs = emt.Igs * 0
        emt.updateIg(pfd, dyd, ini)

        tl_2 = time.time()
        emt.Igi = emt.Igi * 0
        emt.Iibr = emt.Iibr * 0
        emt.updateIibr(pfd, dyd, ini)

        tl_3 = time.time()
        if emt.loadmodel_option == 1:
            pass
        else:
            emt.Il = emt.Il * 0
            emt.updateIl(pfd, dyd, tn)   # update current injection from load

        tl_4 = time.time()
        emt.solveV(ini)

        tl_5 = time.time()
        emt.BusMea(pfd, dyd, tn)     # bus measurement

        tl_6 = time.time()
        emt.updateX(pfd, dyd, ini, tn)

        tl_7 = time.time()
        emt.updateXibr(pfd, dyd, ini, ts)

        tl_8 = time.time()
        if emt.loadmodel_option == 1:
            pass
        else:
            emt.updateXl(pfd, dyd, tn)

        tl_9 = time.time()
        emt.x_pred = {0:emt.x_pred[1],1:emt.x_pred[2],2:emt.x_pv_1}

        if np.mod(tn, DSrate) == 0:
            tsave = tsave + 1
            # save states
            emt.t.append(tn * ts)
            print("%.4f" % emt.t[-1])

            emt.x[tsave] = emt.x_pv_1.copy()

            if len(pfd.ibr_bus) > 0:
                emt.x_ibr[tsave] = emt.x_ibr_pv_1.copy()

            if len(pfd.bus_num) > 0:
                emt.x_bus[tsave] = emt.x_bus_pv_1.copy()

            if len(pfd.load_bus) > 0:
                emt.x_load[tsave] = emt.x_load_pv_1.copy()

            emt.v[tsave] = emt.Vsol.copy()
            term=emt.brch_Ipre.copy()
            term2=9*len(pfd.line_from)
            term3=9*len(pfd.line_from)+3*len(pfd.xfmr_from) # save only line RL current and transformer current
            emt.i_branch[tsave]=np.concatenate((term[9*len(pfd.line_from):term3:3], term[0:term2:9],  \
                                                            term[9*len(pfd.line_from)+1:term3:3],term[1:term2:9],  \
                                                            term[9*len(pfd.line_from)+2:term3:3], term[2:term2:9]))  
   
        tl_10 = time.time()

        # re-init
        if ((emt.flag_gentrip == 0) & (emt.flag_reinit == 1) or
            (tn*ts >= emt.busfault_t and (tn - 1)*ts < emt.busfault_t) or
            (tn*ts >= emt.busfault_t + emt.busfault_tlen and (tn - 1)*ts < emt.busfault_t + emt.busfault_tlen)
            ):
            emt.Re_Init(pfd, dyd, ini)
        else:
            emt.updateIhis(ini)

        tl_11 = time.time()

        t_pred += tl_1 - tl_0
        t_upig += tl_2 - tl_1
        t_upir += tl_3 - tl_2
        t_upil += tl_4 - tl_3
        t_solve += tl_5 - tl_4
        t_busmea += tl_6 - tl_5
        t_upx += tl_7 - tl_6
        t_upxr += tl_8 - tl_7
        t_upxl += tl_9 - tl_8
        t_save += tl_10 - tl_9
        t_upih += tl_11 - tl_10

        Nsteps += 1

    t_stop = time.time()

    emt.dump_res(pfd, dyd, ini, SimMod, output_snp_ful, output_snp_1pt, output_res)

    elapsed = t_stop - t0
    init = t1 - t0
    loop = t_stop - t1
    timing_string = """**** Timing Info ****
    Dimension:   {:8d}
    Init:        {:10.2e} {:8.2%}
    Loop:        {:10.2e} {:8.2%} {:8d} {:8.2e}
    PredX:       {:10.2e} {:8.2%} {:8d} {:8.2e}
    UpdIG:       {:10.2e} {:8.2%} {:8d} {:8.2e}
    UpdIR:       {:10.2e} {:8.2%} {:8d} {:8.2e}
    UpdIL:       {:10.2e} {:8.2%} {:8d} {:8.2e}
    Solve:       {:10.2e} {:8.2%} {:8d} {:8.2e}
    BusMea:      {:10.2e} {:8.2%} {:8d} {:8.2e}
    UpdX:        {:10.2e} {:8.2%} {:8d} {:8.2e}
    UpdXr:       {:10.2e} {:8.2%} {:8d} {:8.2e}
    UpdXL:       {:10.2e} {:8.2%} {:8d} {:8.2e}
    Save:        {:10.2e} {:8.2%} {:8d} {:8.2e}
    UpdIH:       {:10.2e} {:8.2%} {:8d} {:8.2e}
    Total:       {:10.2e}

    """.format(ini.Init_net_G0_inv.shape[0],
               init, init / elapsed,
               loop, loop / elapsed, Nsteps, loop / Nsteps,
               t_pred, t_pred / elapsed, Nsteps, t_pred / Nsteps,
               t_upig, t_upig / elapsed, Nsteps, t_upig / Nsteps,
               t_upir, t_upir / elapsed, Nsteps, t_upir / Nsteps,
               t_upil, t_upil / elapsed, Nsteps, t_upil / Nsteps,
               t_solve, t_solve / elapsed, Nsteps, t_solve / Nsteps,
               t_busmea, t_busmea / elapsed, Nsteps, t_busmea / Nsteps,
               t_upx, t_upx / elapsed, Nsteps, t_upx / Nsteps,
               t_upxr, t_upxr / elapsed, Nsteps, t_upxr / Nsteps,
               t_upxl, t_upxl / elapsed, Nsteps, t_upxl / Nsteps,
               t_save, t_save / elapsed, Nsteps, t_save / Nsteps,
               t_upih, t_upih / elapsed, Nsteps, t_upih / Nsteps,
               elapsed
               )
    print(timing_string)

main()
