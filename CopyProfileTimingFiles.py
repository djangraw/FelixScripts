#!/usr/bin/env python2

# CopyProfileTimingFiles.py
# Selects the random timing file iterations suggested by AFNI and copies them
# to a different folder.
#
# Inputs should be 4-digit numbers specifying the timing iterations you want.
#
# SAMPLE USAGE:
#  python CopyProfileTimingFiles.py 0005 0252 3562
#
# Created 2/21/19 by DJ.

# Import packages
import sys
from shutil import copyfile

inputs = sys.argv[1:]
print(inputs)

folderStart = "/data/EDB/fIBT/stim_analyse/profile/stim_results"
folderEnd = "/data/EDB/fIBT/stim_analyse/profile/good_timing_files"
for fileNum in inputs:
    copyfile('%s/events.%s.txt'%(folderStart,fileNum),'%s/events.%s.txt'%(folderEnd,fileNum))
