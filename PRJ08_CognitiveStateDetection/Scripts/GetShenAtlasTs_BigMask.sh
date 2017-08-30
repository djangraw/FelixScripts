#!/bin/bash
# GetShenAtlasTs.sh
#
# Created 10/24/16 by DJ.


# COMMON STUFF
source ./00_CommonVariables.sh
atlasDir=${PRJDIR}Atlases/
scriptDir=${PRJDIR}Scripts/
atlasName="shen_1mm_268_parcellation+tlrc"
winLength=180 # 045 # 
# make parcellations from atlas
cd $atlasDir
# get filenames
subjNums=(`count -digits 2 6 27`)
#subjNums=("06")

# transform into individual space and remove any ROIs with <10 voxels
for subjNum in ${subjNums[@]}
do
    # set up
    subject=SBJ$subjNum
    subjAtlasPrefix="${subject}_CTask001.Shen"
    echo "Making parcellations for $subject..."    
    dataDir=${PRJDIR}PrcsData/${subject}/D02_CTask001/
    cd $dataDir
    # transform random parcellations into orig space and mask to 'low-sigma' voxels
    subjMask=pb03.${subject}_CTask001.volreg.REF.mask.FBrain+orig

    3dAllineate -overwrite \
	      -input ${atlasDir}${atlasName} \
	      -1Dmatrix_apply ${subject}_CTask001.MNI2REF.Xaff12.1D \
	      -master $subjMask \
	      -final NN \
	      -prefix $subjAtlasPrefix 
    
    # remove ROIS with <10 voxels    
    #roiFile=${subjAtlasPrefix}+orig
    #3dROIstats -quiet -nzvoxels -mask $roiFile $roiFile > rm_nVoxInRoi        
    #1d_tool.py -infile 'rm_nVoxInRoi[0..$(2)]' -overwrite -write rm_roiNums
    #1d_tool.py -infile 'rm_nVoxInRoi[1..$(2)]' -moderate_mask 0 9 -overwrite -write rm_isBelow10
    #1deval -a rm_roiNums\' -b rm_isBelow10\' -expr 'a*b' > rm_tinyRoisCol
    #1d_tool.py -infile rm_tinyRoisCol -transpose -overwrite -write rm_tinyRois
    # convert to comma-separated list
    #str_tinyRois="`cat rm_tinyRois`" # dump into variable
    #str_tinyRois=${str_tinyRois//"0 "/} # remove zeros and the spaces after them
    #str_tinyRois=${str_tinyRois// /,} # replace spaces with commas
    # use 3dCalc to remove the selected ROIs
    #3dcalc -a ${roiFile} -expr "a*not(amongst(a,${str_tinyRois}))" -overwrite -prefix ${subjAtlasPrefix}_10VoxelMin
    
    # clean up
    # rm rm_*
            
    # declare input/output filenames
    epiFile=pb08.${subject}_CTask001.blur.WL${winLength}+orig # VERSION WITH MOTION AND POLORT TIMECOURSES REGRESSED OUT, SCALED
    prefix=${subjAtlasPrefix}_WL${winLength}_BigMask_ # TS.1D will be appended to end

    # Run timeseries extraction script
    # echo "python TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $prefix -Warp"
    # python TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $prefix -Warp
    cd $scriptDir
cat <<EOF > TsExtractBatchCommand.$subject
#!/bin/bash
python TsExtractByROIs.py -Mask ${dataDir}${subjMask}.HEAD -Atlas ${dataDir}${subjAtlasPrefix}+orig.HEAD -EPI ${dataDir}${epiFile}.HEAD -prefix ${dataDir}$prefix
EOF
    # print it
    cat ${scriptDir}TsExtractBatchCommand.$subject
    # submit it
    jobid=$(sbatch --partition=nimh,norm ${scriptDir}TsExtractBatchCommand.$subject)
    echo "--> Job $jobid"
    
done
    
    
