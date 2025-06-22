import numpy as np
import subprocess
import os

filename = [
    "cane_modified_0p05",
    "cane_modified_0p1",
    "cane_modified_0p15",
    "cane_modified_0p2",
    "cane_modified_0p25",
    "cane_modified_0p3",
    "cane_modified_0p35",
    "cane_modified_0p4",
    "cane_modified_0p45",
    "cane_modified_0p5",
    "cane_original_0p05",
    "cane_original_0p1",
    "cane_original_0p15",
    "cane_original_0p2",
    "cane_original_0p25",
    "cane_original_0p3",
    "cane_original_0p35",
    "cane_original_0p4",
]

corenum = 12  # number of cores used for simulation
puma_run_file = "./../../../puma-opt"

for i in range(len(filename)):
    print("running file " + filename[i])
    proc1 = subprocess.Popen(
        [
            "mpiexec",
            "-n",
            str(corenum),
            puma_run_file,
            "-i",
            "input.i",
            "filename={}".format(filename[i]),
            # "--parse-neml2-only",
        ],
        stdin=subprocess.DEVNULL,
        stdout=open("input_" + filename[i] + ".log", "w"),
        stderr=subprocess.STDOUT,
        text=True,
    )
    proc1.wait()
