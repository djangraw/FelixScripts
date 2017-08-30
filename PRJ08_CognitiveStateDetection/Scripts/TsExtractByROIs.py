#!/usr/bin/env python
###################################################
# TsExtractByROIs.py
#
# takes an atlas and an EPI scan and extracts time series for each ROI
#
# USAGE: python TsExtractByROIs.py -Atlas $atlasFile -EPI $epiFile -prefix $prefix
#
# FLAGS:
# -Atlas $atlasFile = filepath/name for atlas AFNI dataset
# -EPI $epiFile = filepath/name for 3D+time AFNI dataset
# -prefix $prefix = filepath/prefix for desired output (result will be <prefix>ROI_TS.1D)
# [-Mask $maskFile] = filepath/name for mask dataset
# [-Warp] = warp atlas from MNI to TTA space
#
# HISTORY:
# -Created 5/2/16 by BG.
# -Updated 5/2/16 by DJ - comments and header.
# -Updated 5/16/16 by BG - find empty or too-small ROIs and fill their timecourses with zeros
#
# DATE LAST MODIFICATION:
# * 05/24/2016
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
    if ' ' in prefix:
        print('++ Error: Prefix contains spaces.  This is not a good idea.')
        fails += 1
    if fails != 0:
        print('++ Error: One or more errors have occured. Exiting program...')
        sys.exit()


# Main function  
if __name__ == '__main__':
    # Define & parse command-line arguments
    parser = argparse.ArgumentParser('Arguments')
    parser.add_argument('-Mask',   dest = 'MaskPath',   help = 'Mask of EPI data',       default = '', type = str)
    parser.add_argument('-Atlas',  dest = 'AtlasPath',  help = 'Atlas of ROIs',          default = '', type = str)
    parser.add_argument('-EPI',    dest = 'EPIPath',    help = 'EPI dataset',            default = '', type = str)
    parser.add_argument('-prefix', dest = 'prefix', help = 'prefix of output files', default = './', type = str)
    parser.add_argument('-Warp',   dest = 'Warp',   help = 'perform NN neighbor warp of Atlas to EPI space', action = 'store_true')
    args = parser.parse_args()

    # Make sure all necessary arguments are present & valid
    Argument_Check(args.MaskPath, args.AtlasPath, args.EPIPath, args.prefix)
    
    # Separate paths into directories & base filenames
    AtlasPath=args.AtlasPath
    AtlasBase=os.path.basename(AtlasPath)
    AtlasDir =os.path.dirname(AtlasPath)

    EPIPath  =args.EPIPath
    EPIBase  =os.path.basename(EPIPath)
    EPIDir   =os.path.dirname(EPIPath)

    MaskPath =args.MaskPath
    MaskBase =os.path.basename(MaskPath)
    MaskDir  =os.path.dirname(MaskPath)

    p = subprocess.Popen(["3dinfo", "-nv", "%s" % (EPIPath)], stdout=subprocess.PIPE)
    nv=int(p.communicate()[0])
    p = subprocess.Popen(["3dBrickStat", "-max", "%s" % (AtlasPath)], stdout=subprocess.PIPE)
    nROIs=int(p.communicate()[0])

    # If a mask is provided
    if os.path.isfile(MaskPath):
        if args.Warp:
            # Warp atlas into TLRC space and resample to EPI resolution
            subprocess.call('3dWarp -mni2tta -NN -gridset "%s[0]" -overwrite -prefix %s/EPIres_%s %s' % 
                (EPIPath[:-EPIPath[::-1].index('.')-1],AtlasDir,AtlasBase,AtlasPath),shell=True)
            # Apply mask to atlas
            subprocess.call('3dcalc -a %s/EPIres_%s -b %s -expr "a*step(b)" -overwrite -prefix %s/Mask_EPIres_%s' %
                (AtlasDir,AtlasBase,MaskPath,MaskDir,AtlasBase),shell=True)
        else:
            # resample atlas to EPI resplution
            subprocess.call('3dresample -master %s -prefix %s/EPIres_%s -inset %s -overwrite' %
                (EPIPath,AtlasDir,AtlasBase,AtlasPath),shell=True)
            # Apply mask to atlas
            subprocess.call('3dcalc -a %s/EPIres_%s -b %s -expr "a*step(b)" -overwrite -prefix %s/Mask_EPIres_%s' %
                (AtlasDir,AtlasBase,MaskPath,MaskDir,AtlasBase),shell=True)

        # Get number of ROIs and find empty ROIs
        subprocess.call('3dROIstats -mask %s/Mask_EPIres_%s -numROI %s -nomeanout -nzvoxels -quiet %s/Mask_EPIres_%s > %sROIstats.1D' %
                (MaskDir,AtlasBase,nROIs,MaskDir,AtlasBase,args.prefix),shell=True)
        ROIsize=np.loadtxt('%sROIstats.1D' % args.prefix)
        # Extract ROI timecourses
        for t in range(1,nROIs+1):
            # Use 3dmaskave to get mean of all voxels in ROI
            # subprocess.call('3dmaskave -mask Mask_EPIres_%s -quiet -mrange %s %s %s > tmp.ROI%s_TS.1D' % (AtlasBase,t-0.5,t+0.5,EPIPath,t),shell=True)
            print('\n++ INFO: Computing SVD for ROI %s' % (str(t).zfill(len(str(nROIs)))))
            # Use 3dmaskSVD to get 1st principal component rather than mean
            if int(ROIsize[t-1]) <= 1:
                np.savetxt('%s/tmp.ROI%s_TS.1D' % (os.path.dirname(args.prefix),str(t).zfill(len(str(nROIs)))),np.zeros((nv,1)))
            else:
                subprocess.call('3dmaskSVD -vnorm -mask %s/Mask_EPIres_%s\"<%s..%s>\" %s > %s/tmp.ROI%s_TS.1D' %
                    (MaskDir,AtlasBase[:-AtlasBase[::-1].index('.')-1],t,t,EPIPath,os.path.dirname(args.prefix),str(t).zfill(len(str(nROIs)))),shell=True)
    # If NO mask is provided
    else:
        if args.Warp:
            # Warp atlas into TLRC space and resample to EPI resolution
            subprocess.call('3dWarp -mni2tta -NN -gridset "%s[0]" -overwrite -prefix %s/EPIres_%s %s' %
                (EPIPath[:-EPIPath[::-1].index('.')-1],AtlasDir,AtlasBase,AtlasPath),shell=True) 
        else:
            # resample atlas to EPI resplution
            subprocess.call('3dresample -master %s -prefix %s/EPIres_%s -inset %s -overwrite' % (EPIPath,AtlasDir,AtlasBase,AtlasPath),shell=True)

        # Get number of ROIs and find empty ROIs
        subprocess.call('3dROIstats -mask %s/EPIres_%s -numROI %s -nomeanout -nzvoxels -quiet %s/EPIres_%s > %sROIstats.1D' %
                (MaskDir,AtlasBase,nROIs,MaskDir,AtlasBase,args.prefix),shell=True)
        ROIsize=np.loadtxt('%sROIstats.1D' % args.prefix)

        # Extract ROI timecourses
        for t in range(1,nROIs+1):
            # Use 3dmaskave to get mean of all voxels in ROI
            # subprocess.call('3dmaskave -mask EPIres_%s -quiet -mrange %s %s %s > tmp.ROI%s_TS.1D' % (AtlasBase,t-0.5,t+0.5,EPIPath,t),shell=True)
            print('\n++ INFO: Computing SVD for ROI %s' % (str(t).zfill(len(str(nROIs)))))
            # Use 3dmaskSVD to get 1st principal component rather than mean
            if int(ROIsize[t-1]) <= 1:
                np.savetxt('%s/tmp.ROI%s_TS.1D' % (os.path.dirname(args.prefix),str(t).zfill(len(str(nROIs))),np.zeros((nv,1))))
            else:
                subprocess.call('3dmaskSVD -vnorm -mask %s/EPIres_%s\"<%s..%s>\" %s > %s/tmp.ROI%s_TS.1D' %
                    (AtlasDir,AtlasBase[:-AtlasBase[::-1].index('.')-1],t,t,EPIPath,os.path.dirname(args.prefix),str(t).zfill(len(str(nROIs)))),shell=True)

    for i in range(1,nROIs+1):
        if os.stat('%s/tmp.ROI%s_TS.1D' % (os.path.dirname(args.prefix),str(i).zfill(len(str(nROIs))))) == 0:
            np.savetxt('%s/tmp.ROI%s_TS.1D' % (os.path.dirname(args.prefix),str(i).zfill(len(str(nROIs)))), np.zeros((nv,1)))

    # Concatenate individual ROI timecourses into matrix and delete individual files
    subprocess.call('1dcat %s/tmp.ROI*_TS.1D > %sROI_TS.1D' % (os.path.dirname(args.prefix),args.prefix),shell=True)
    subprocess.call('rm -f %s/tmp.ROI*_TS.1D' % os.path.dirname(args.prefix),shell=True)
    subprocess.call('chmod 2770 %sROI_TS.1D' % (args.prefix),shell=True)
    subprocess.call('chgrp SFIM %sROI_TS.1D' % (args.prefix),shell=True)
    subprocess.call('chmod 2770 %sROIstats.1D' % (args.prefix),shell=True)
    subprocess.call('chgrp SFIM %sROIstats.1D' % (args.prefix),shell=True)