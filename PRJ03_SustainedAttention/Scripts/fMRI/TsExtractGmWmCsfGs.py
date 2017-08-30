#!/usr/bin/env python
###################################################
# TsExtractGmWmCsfGs.py
#
# takes an atlas and an EPI scan and extracts time series for each ROI
#
# USAGE: python TsExtractGmWmCsfGs.py -Atlas $atlasFile -EPI $epiFile -prefix $prefix
#
# FLAGS:
# -Atlas $atlasFile = filepath/name for White matter, CSF, 
# -EPI $epiFile = filepath/name for 3D+time AFNI dataset
# -prefix $prefix = filepath/prefix for desired output (result will be <prefix>ROI_TS.1D)
# [-Mask $maskFile] = filepath/name for mask dataset
# [-Warp] = warp atlas from MNI to TTA space
#
# HISTORY:
# -Created 5/19/16 by BG.
# 
###################################################
import numpy as np
import subprocess
import argparse
import glob
import sys
import os


# Make sure all necessary arguments are present & valid
def Argument_Check(Mask, Atlas, EPI, prefix):
    fails=0
    if not os.path.isfile(Mask) and Mask != '':
        print('++ Error: Path to Mask is not correct')
        fails += 1
    if not os.path.isfile(Atlas):
        print('++ Error: Path to Atlas is not correct')
        fails += 1
    if not os.path.isfile(EPI):
        print('++ Error: Path to EPI is not correct')
        fails += 1
    if not os.path.isdir(prefix):
        print('++ Error: Prefix is not a direcotry')
        fails += 1
    if fails != 0:
        print('++ Error: One or more errors have occured. Exiting program...')
        sys.exit()


# Main function  
if __name__ == '__main__':
    # Define & parse command-line arguments
    parser = argparse.ArgumentParser('Arguments')
    parser.add_argument('-Mask',   dest = 'MaskPath',  help = 'Mask of EPI data',          default = '', type = str)
    parser.add_argument('-Atlas',  dest = 'AtlasPath', help = 'Atlas of ROIs',             default = '', type = str)
    parser.add_argument('-EPI',    dest = 'EPIPath',   help = 'EPI dataset',               default = '', type = str)
    parser.add_argument('-prefix', dest = 'prefix',    help = 'Directory of output files', default = '', type = str)
    args = parser.parse_args()

    # Make sure all necessary arguments are present & valid
    Argument_Check(args.MaskPath, args.AtlasPath, args.EPIPath, args.prefix)
    
    # Separate paths into directories & base filenames
    AtlasPath = args.AtlasPath
    AtlasBase = os.path.basename(AtlasPath)
    AtlasDir  = os.path.dirname(AtlasPath)

    EPIPath   = args.EPIPath
    EPIBase   = os.path.basename(EPIPath)
    EPIDir    = os.path.dirname(EPIPath)

    MaskPath  = args.MaskPath
    MaskBase  = os.path.basename(MaskPath)
    MaskDir   = os.path.dirname(MaskPath)

    # Seperate the parcellation
    subprocess.call('3dcalc -a %s -expr "equals(a, 3)"    -prefix %s/WM_%s -overwrite' % (AtlasPath,AtlasDir,AtlasBase),shell=True)
    subprocess.call('3dcalc -a %s -expr "equals(a, 1)"    -prefix %s/CSF_%s -overwrite'% (AtlasPath,AtlasDir,AtlasBase),shell=True)
    subprocess.call('3dcalc -a %s -expr "within(a, 1, 3)" -prefix %s/GS_%s -overwrite' % (AtlasPath,AtlasDir,AtlasBase),shell=True)
    subprocess.call('3dcalc -a %s -expr "equals(a, 2)"    -prefix %s/GM_%s -overwrite' % (AtlasPath,AtlasDir,AtlasBase),shell=True)
    
    # Resample atlas to EPI resplution
    subprocess.call('3dresample -master %s -prefix %s/EPIres.WM_%s  -inset %s/WM_%s -overwrite' % (EPIPath,AtlasDir,AtlasBase,AtlasDir,AtlasBase),shell=True)
    subprocess.call('3dresample -master %s -prefix %s/EPIres.CSF_%s -inset %s/CSF_%s -overwrite'% (EPIPath,AtlasDir,AtlasBase,AtlasDir,AtlasBase),shell=True)
    subprocess.call('3dresample -master %s -prefix %s/EPIres.GS_%s  -inset %s/GS_%s -overwrite' % (EPIPath,AtlasDir,AtlasBase,AtlasDir,AtlasBase),shell=True)
    subprocess.call('3dresample -master %s -prefix %s/EPIres.GM_%s  -inset %s/GM_%s -overwrite' % (EPIPath,AtlasDir,AtlasBase,AtlasDir,AtlasBase),shell=True)

    # Mask 
    subprocess.call('3dcalc -a %s/EPIres.WM_%s  -b %s -expr "a*b" -prefix %s/EPIres.WM_Mask.%s -overwrite' % (AtlasDir,AtlasBase,MaskPath,AtlasDir,AtlasBase),shell=True)
    subprocess.call('3dcalc -a %s/EPIres.CSF_%s -b %s -expr "a*b" -prefix %s/EPIres.CSF_Mask.%s -overwrite'% (AtlasDir,AtlasBase,MaskPath,AtlasDir,AtlasBase),shell=True)
    subprocess.call('3dcalc -a %s/EPIres.GS_%s  -b %s -expr "a*b" -prefix %s/EPIres.GS_Mask.%s -overwrite' % (AtlasDir,AtlasBase,MaskPath,AtlasDir,AtlasBase),shell=True)
    subprocess.call('3dcalc -a %s/EPIres.GM_%s  -b %s -expr "a*b" -prefix %s/EPIres.GM_Mask.%s -overwrite' % (AtlasDir,AtlasBase,MaskPath,AtlasDir,AtlasBase),shell=True)
    
    # Extract ROI timecourses
    subprocess.call('3dmaskave -quiet -mask %s/EPIres.WM_%s  %s > %s/WM_Timecourse.1D' % (AtlasDir,AtlasBase,EPIPath,args.prefix),shell=True)
    subprocess.call('3dmaskave -quiet -mask %s/EPIres.CSF_%s %s > %s/CSF_Timecourse.1D'% (AtlasDir,AtlasBase,EPIPath,args.prefix),shell=True)
    subprocess.call('3dmaskave -quiet -mask %s/EPIres.GS_%s  %s > %s/GS_Timecourse.1D' % (AtlasDir,AtlasBase,EPIPath,args.prefix),shell=True)
    subprocess.call('3dmaskave -quiet -mask %s/EPIres.GM_%s  %s > %s/GM_Timecourse.1D' % (AtlasDir,AtlasBase,EPIPath,args.prefix),shell=True)
    
    # Change permissions on resulting timecourse files
    subprocess.call('chmod 2770 %s/WM_Timecourse.1D'  % (args.prefix),shell=True)
    subprocess.call('chgrp SFIM %s/WM_Timecourse.1D'  % (args.prefix),shell=True)
    subprocess.call('chmod 2770 %s/CSF_Timecourse.1D' % (args.prefix),shell=True)
    subprocess.call('chgrp SFIM %s/CSF_Timecourse.1D' % (args.prefix),shell=True)
    subprocess.call('chmod 2770 %s/GS_Timecourse.1D'  % (args.prefix),shell=True)
    subprocess.call('chgrp SFIM %s/GS_Timecourse.1D'  % (args.prefix),shell=True)
    subprocess.call('chmod 2770 %s/GM_Timecourse.1D'  % (args.prefix),shell=True)
    subprocess.call('chgrp SFIM %s/GM_Timecourse.1D'  % (args.prefix),shell=True)