# MakeMultiSiteTimingFiles_Felix.py
# -Reads in E-Prime data files from a Multi-Site ("Wisconsin") task and produces timing files for use in AFNI.
#
# INPUT CAN BE:
# - list of files, e.g., path/file1.txt path/file2.txt path/file3.txt
# - glob-style filename expansion, e.g., path/file*.txt
# - nothing, which assumes the default directories and file paths hard-coded into this script.
#
# Created 9/27/18 by DJ based on MakeMultiSiteTimingFiles_script
# Updated 10/2/18 by DJ - allow commmand-line inputs

# Import packages
import sys
import os
import glob
from LoadMultiSiteEprimeFile import LoadMultiSiteEprimeFile
from MakeMultiSiteTimingFiles import MakeTimingFiles

# Parse command-line inputs
if len(sys.argv)>1: # input is list of files
    files = sys.argv[1:];
elif len(sys.argv)==1: # input is single file or glob-style fileame expansion (e.g., file*.txt) 
    files = glob.glob(sys.argv[1]);
else:    
    # Declare paths to data
    dataDir = "/data/EDB/WISC_Studies/afni_method/subjects/timing" # Where behavioral data sits

    # Find all file names
    files = glob.glob("%s/Run1fMRI_MultiSite_NIH-*-1.txt"%dataDir) # TODO: find out real naming convention

# Find subject number in each file
subjects = [file.split("-")[1] for file in files]
overwrite = True # overwrite old files?

# Write timing files
print('===Making timing files for %d subjects...'%len(subjects))
for i in range(len(subjects)):
    subject = subjects[i]
    print('  -> subject %s:'%subject)
    inFile = files[i] 
    outFolder = "/data/EDB/WISC_Studies/afni_method/subjects/%s/timing/Python_minus8"%subject # where timing files will be written
    if not os.path.exists(outFolder):
        os.mkdir(outFolder)
        print("     Directory " + outFolder + " created.")
    else:    
        if overwrite:
            print("     Directory " + outFolder + " already exists - files will be overwritten.")
        else:
            print("     Directory " + outFolder + " already exists - skipping this subject.")
            continue
    MakeTimingFiles(inFile,outFolder,subtractVal = 8)
