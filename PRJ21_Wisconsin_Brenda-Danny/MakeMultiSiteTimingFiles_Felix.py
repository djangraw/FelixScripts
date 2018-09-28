# MakeMultiSiteTimingFiles_Felix.py
# -Reads in E-Prime data files from a Multi-Site ("Wisconsin") task and produces timing files for use in AFNI.
#
# Created 9/27/18 by DJ based on MakeMultiSiteTimingFiles_script

# Import packages
import os
import glob
from LoadMultiSiteEprimeFile import LoadMultiSiteEprimeFile
from MakeMultiSiteTimingFiles import MakeTimingFiles

# Declare paths to data
dataDir = "/data/EDB/WISC_Studies/afni_method/subjects/timing" # Where behavioral data sits
overwrite = True # overwrite old files?

# Find file and subject names
files = glob.glob("%s/Run1fMRI_MultiSite_NIH-*-1.txt"%dataDir)
subjects = [file.split("-")[1] for file in files]

# Write timing files
print('===Making timing files for %d subjects...'%len(subjects))
for subject in subjects:
    print('  -> subject %s:'%subject)
    inFile = "%s/Run1fMRI_MultiSite_NIH-%s-allruns.xlsx"%(dataDir,subject) # TODO: find out real naming convention
    outFolder = "/data/EDB/WISC_Studies/afni_method/subjects/%s/timing/Python_minus8"%subject # where timing files will be written
    MakeTimingFiles(inFile,outFolder,subtractVal = 8)
