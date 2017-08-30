# Date: 07/15/2014
# Authors: Javier Gonzalez-Castillo, Colin W. Hoy
# Updated 2/1/16 by DJ - updated PRJDIR to jangrawdc directory

# Declare main directories
PRJDIR=/data/jangrawdc/PRJ08_CognitiveStateDetection/
AtlasDir=`echo ${PRJDIR}Atlases`

ROIMinSize=10
RUN=CTask001
DPREFIX=D02
winLen_inSec=(180 090 060 045 030 022 015)
NumWindows=`echo ${#winLen_inSec[@]}`
LocDir=D03_Localizers
OrigDataDir=D00_OriginalData


# These hi pass ends of the bandpass filter are based on 1/winLen
# They're really: 0.0055555 0.0111111 0.0166667 0.0222222 0.0333333 0.0666667
winLen_hiPass=(0.006 0.012 0.017 0.023 0.034 0.045 0.067)

# Additional Info for Analysis of Localizers
blurMM=4
noVideo=(SBJ08 SBJ19)
excDist=(SBJ14 SBJ15)
