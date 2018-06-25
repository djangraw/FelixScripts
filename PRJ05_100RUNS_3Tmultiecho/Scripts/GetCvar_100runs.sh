# get variables
cd /data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Scripts/
. GetIscVariables.sh SBJ01


# calculate stddev across files
cd /data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/${subject}/ReverseCorrelation/
3dMean -stdev -prefix ${subject}_Video_Std_Meica+orig ${meicafiles[*]}
3dMean -stdev -prefix ${subject}_Video_Std_OptCom+orig ${optcomfiles[*]}
3dMean -stdev -prefix ${subject}_Video_Std_Echo2+orig ${echofiles[*]}

# calculate cvar
3dcalc -a ${subject}_Video_Mean_Meica+orig -b ${subject}_Video_Std_Meica+orig -expr 'b/a' -prefix ${subject}_Video_Cvar_Meica+orig
3dcalc -a ${subject}_Video_Mean_OptCom+orig -b ${subject}_Video_Std_OptCom+orig -expr 'b/a' -prefix ${subject}_Video_Cvar_OptCom+orig
3dcalc -a ${subject}_Video_Mean_Echo2+orig -b ${subject}_Video_Std_Echo2+orig -expr 'b/a' -prefix ${subject}_Video_Cvar_Echo2+orig