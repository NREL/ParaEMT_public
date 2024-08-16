# --------------------------------------------
#  EMT solver main function - create large cases and save in .json format
#  2020-2021 Bin Wang, Deepthi Vaidhynathan, Min Xiong
#  Last modified: 08/15/24
# --------------------------------------------

# PSSE/python compatibility summary:
# psspy27 - to be used with python 2.7
# psspy34 - to be used with python 3.4
# psspy37 - to be used with python 3.7

# note: Our PSSE v34.4 does not have psspy37, but has psspy27 and psspy34, so Python 2.7 and psspy27 are used here.
# note: Regarding EMT simulation, Python 3.7 will be used for better performance. So the function for generating large
# systems was separated from Lib_BW, and named as Lib_BW_CreateLargeCases.

# In our next version, this PSSE license required power flow solver will be replaced by ANDES
# For simulating the systems in put under 'models', the users can skip this setp. Because the generated files are already included in 'cases'.
import os, sys
import numpy
import json

# sys_path_PSSE = r"C:\Program Files (x86)\PTI\PSSE34\PSSBIN"
# os_path_PSSE = r"C:\Program Files (x86)\PTI\PSSE34\PSSBIN"

sys_path_PSSE = r"C:\Program Files (x86)\PTI\PSSE34\PSSPY37"
sys.path.append(sys_path_PSSE) 
os_path_PSSE  = r"C:\Program Files (x86)\PTI\PSSE34\PSSPY37"
os.environ['PATH'] += ';' + os_path_PSSE 

import psse34
import psspy

workingfolder = os.getcwd()
os.chdir(workingfolder)

import json
import pickle
from Lib_BW_CreateLargeCases import *

def main_2():
    systemN = 1

    psspy.psseinit()
    # load PSS/E model
    if systemN == 1:
        psspy.read(0, workingfolder + """\\models\\2gen_psse\\2gen.raw""")
    elif systemN == 2:
        psspy.read(0, workingfolder + """\\models\\9bus_psse\\ieee9.raw""")
    elif systemN == 3:
        psspy.read(0, workingfolder + """\\models\\39bus_psse\\39bus.raw""")
    elif systemN == 4:
        psspy.read(0, workingfolder + """\\models\\179bus_psse\\wecc179.raw""")
    elif systemN == 5:
        psspy.read(0,workingfolder + """\\models\\240bus_psse\\WECC240.raw""")
    elif systemN == 6:
        psspy.read(0, workingfolder + """\\models\\2area_psse\\twoarea.raw""")
    else:
        pass

    psspy.nsol([0, 0, 0, 1, 1, 0, 0])  # fast decouple with "Do not flat start"
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])
    psspy.fnsl([0, 0, 0, 1, 1, 0, 0, 0])

    pfd0 = PFData()
    pfd0.getdata(psspy)  # IBR, switch shunts

    # Create large cases y connecting multiple replications:
    N_row = 1
    N_col = 1

    # select interfacing buses (need to be PV buses)
    if systemN == 1:
        ItfcBus = [1, 4, 1, 4]
        pfd_name = r"""4_""" + str(N_row) + """_""" + str(N_col)
    elif systemN == 2:
        ItfcBus = [1, 2, 3, 1]
        pfd_name = r"""9_""" + str(N_row) + """_""" + str(N_col)
    elif systemN == 3:
        ItfcBus = [37, 36, 32, 39]
        pfd_name = r"""39_""" + str(N_row) + """_""" + str(N_col)
    elif systemN == 4:
        ItfcBus = [35, 4, 149, 70]
        pfd_name = r"""179_""" + str(N_row) + """_""" + str(N_col)
    elif systemN == 5:
        ItfcBus = []
        pfd_name = r"""240_""" + str(N_row) + """_""" + str(N_col)
        pfd = pfd0
    elif systemN == 6:
        ItfcBus = []
        pfd_name = r"""2area_""" + str(N_row) + """_""" + str(N_col)
        pfd = pfd0

    if len(ItfcBus) != 0:
        pfd = pfd0.LargeSysGenerator(ItfcBus, N_row, N_col)

    pfd_dict = pfd.__dict__
    pddd = {}
    for x in pfd_dict.keys():
        if type(pfd_dict[x]) != numpy.ndarray:
            pddd[x] = pfd_dict[x]
        else:
            if pfd_dict[x].dtype == 'complex128':
                pddd[x] = pfd_dict[x].tolist()
                pddd[x] = [str(y) for y in pddd[x]]
            else:
                pddd[x] = pfd_dict[x].tolist()
    with open(workingfolder + '\\cases\\pfd_' + pfd_name + '.json', 'w') as fp:
            json.dump(pddd, fp)

    # disconnect PSSE license after the use
    psspy.pssehalt_2()

main_2()