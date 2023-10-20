# --------------------------------------------
#  EMT solver plotting function
#  2020-2021 Bin Wang
#  Last modified: 5/7/21, 5:50 PM
# --------------------------------------------

import pickle
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

def main():
    # read sim data
    # with open('sim_snp_S5_T20_50u.pkl', 'rb') as f:
    with open('sim_res.pkl','rb') as f:
    # with open('sim_snp.pkl', 'rb') as f:
    # with open('sim_res_S5_T10_50u_1431N.pkl', 'rb') as f:
        pfd, dyd, ini, emt = pickle.load(f)


    Gbus = []
    droop = np.zeros(len(pfd.gen_bus))
    for i in range(len(pfd.gen_bus)):
        Gbus.append(str(pfd.gen_bus[i]) + '_' + pfd.gen_id[i] + '_' + 'Vm')

        # gov pm
        if dyd.gov_type[i] == 'TGOV1':
            idx_gov = np.where(dyd.gov_tgov1_idx == i)[0][0]
            droop[i] = dyd.gov_tgov1_R[idx_gov]

        if dyd.gov_type[i] == 'HYGOV':
            idx_gov = np.where(dyd.gov_hygov_idx == i)[0][0]
            droop[i] = dyd.gov_hygov_R[idx_gov]

        if dyd.gov_type[i] == 'GAST':
            idx_gov = np.where(dyd.gov_gast_idx == i)[0][0]
            droop[i] = dyd.gov_gast_R[idx_gov]



    dfbus = pd.DataFrame(droop)
    dfbus.to_csv("droop.csv")#, header=Gbus, index=False)






# main function
main()
