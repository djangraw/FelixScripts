# COMMON STUFF
# ============
source ./00_CommonVariables.sh
module load Anaconda
source activate meica
# READ INPUT PARAMETERS
# =====================
if [ $# -ne 2 ]; then
 echo "Usage: $basename $0 SBJID FILEPREFIX"
 exit
fi
SBJ=$1
FILEPREFIX=$2

EFile01=`echo ${FILEPREFIX}_E01`
EFile02=`echo ${FILEPREFIX}_E02`
EFile03=`echo ${FILEPREFIX}_E03`
cd ${PRJDIR}/PrcsData/${SBJ}
# CHECK FOR OUTPUT DIRECTORY AND IF EXISTS DELETE IT
if [ -d DXX_${FILEPREFIX} ]; then rm -rf DXX_${FILEPREFIX}; fi

# CREATE OUTPUT DIRECTORY
mkdir DXX_${FILEPREFIX}
cd DXX_${FILEPREFIX}

# Link EPI DATA
ln -s ../D00_OriginalData/${EFile01}+orig.* .
ln -s ../D00_OriginalData/${EFile02}+orig.* .
ln -s ../D00_OriginalData/${EFile03}+orig.* .

# Discard initial 5 volumes
nt=`3dinfo -nt ${EFile03}+orig`
nt=`echo ${nt} -1 | bc`
3dcalc -a ${EFile01}+orig"[5..${nt}]" -expr 'a' -prefix pb01.${EFile01}.discard.nii.gz
3dcalc -a ${EFile02}+orig"[5..${nt}]" -expr 'a' -prefix pb01.${EFile02}.discard.nii.gz
3dcalc -a ${EFile03}+orig"[5..${nt}]" -expr 'a' -prefix pb01.${EFile03}.discard.nii.gz

# Link Anatomical Dataset (bias corrected and no skull)
ln -s ../D01_Anatomical/SBJ01_Anat_bc_ns.nii.gz .

# Create ME-ICA script
/data/SFIM/Apps/me-ica/meica.py -e 17.5,35.3,53.1 \
                                -d pb01.${EFile01}.discard.nii.gz,pb01.${EFile02}.discard.nii.gz,pb01.${EFile03}.discard.nii.gz \
                                -a SBJ01_Anat_bc_ns.nii.gz \
                                --MNI --no_skullstrip --keep_int \
                                --prefix _MEICA_V001 \
                                --label  _MEICA_V001 \
                                --script_only
# Corrects the MEICA Script --> Use 3dAutomask instead of 3dSkullStrip becuase
# the former does not like datasets with less than 16 slices (ours are below that)
sed -i 's/3dSkullStrip -prefix .\/ocv_ss.nii.gz -overwrite -input ocv_uni+orig/3dAutomask -prefix .\/ocv_ss.nii.gz -overwrite ocv_uni+orig/g' _meica_pb01.${EFile01}.discard_MEICA_V001.sh
sed -i 's/3dSkullStrip/3dAutomask/g' _meica_pb01.${EFile01}.discard_MEICA_V001.sh

# Run ME-ICA
if [ -d pb01.meica_pb01.${EFile01}.discard_MEICA_V001 ]; then rm -rf meica_pb01.${EFile01}_MEICA_V001; fi
sh ./_meica_pb01.${EFile01}.discard_MEICA_V001.sh

# Run ME-ICA Report
meica_report.py -anat SBJ01_Anat_bc_ns_at.nii.gz -setname meica.pb01.${EFile01}.discard_MEICA_V001 -ax -sag -title ${FILEPREFIX}
