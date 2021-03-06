#!/bin/bash
covarFile="/data/jangrawdc/PRJ16_TaskFcManipulation/Results/srttCovarFile_readingPc1_shortlabel.txt"
for i in `seq 0 $lastBrick`;
do
  3dttest++ -overwrite -prefix ${outPrefix}_brick${i} -covariates $covarFile                                \
          -setA setA                                             \
             0093 "coef.censorbase15-nofilt.tb0093+tlrc.HEAD[$i]" \
             0094 "coef.censorbase15-nofilt.tb0094+tlrc.HEAD[$i]" \
             0065 "coef.censorbase15-nofilt.tb0065+tlrc.HEAD[$i]" \
             0137 "coef.censorbase15-nofilt.tb0137+tlrc.HEAD[$i]" \
             0169 "coef.censorbase15-nofilt.tb0169+tlrc.HEAD[$i]" \
             0170 "coef.censorbase15-nofilt.tb0170+tlrc.HEAD[$i]" \
             0275 "coef.censorbase15-nofilt.tb0275+tlrc.HEAD[$i]" \
             0312 "coef.censorbase15-nofilt.tb0312+tlrc.HEAD[$i]" \
             0313 "coef.censorbase15-nofilt.tb0313+tlrc.HEAD[$i]" \
             0349 "coef.censorbase15-nofilt.tb0349+tlrc.HEAD[$i]" \
             0456 "coef.censorbase15-nofilt.tb0456+tlrc.HEAD[$i]" \
             0498 "coef.censorbase15-nofilt.tb0498+tlrc.HEAD[$i]" \
             0543 "coef.censorbase15-nofilt.tb0543+tlrc.HEAD[$i]" \
             0716 "coef.censorbase15-nofilt.tb0716+tlrc.HEAD[$i]" \
             0782 "coef.censorbase15-nofilt.tb0782+tlrc.HEAD[$i]" \
             1063 "coef.censorbase15-nofilt.tb1063+tlrc.HEAD[$i]" \
             1147 "coef.censorbase15-nofilt.tb1147+tlrc.HEAD[$i]" \
             1208 "coef.censorbase15-nofilt.tb1208+tlrc.HEAD[$i]" \
             1313 "coef.censorbase15-nofilt.tb1313+tlrc.HEAD[$i]" \
             1524 "coef.censorbase15-nofilt.tb1524+tlrc.HEAD[$i]" \
             5762 "coef.censorbase15-nofilt.tb5762+tlrc.HEAD[$i]" \
             5833 "coef.censorbase15-nofilt.tb5833+tlrc.HEAD[$i]" \
             5868 "coef.censorbase15-nofilt.tb5868+tlrc.HEAD[$i]" \
             5914 "coef.censorbase15-nofilt.tb5914+tlrc.HEAD[$i]" \
             5976 "coef.censorbase15-nofilt.tb5976+tlrc.HEAD[$i]" \
             5985 "coef.censorbase15-nofilt.tb5985+tlrc.HEAD[$i]" \
             6048 "coef.censorbase15-nofilt.tb6048+tlrc.HEAD[$i]" \
             6082 "coef.censorbase15-nofilt.tb6082+tlrc.HEAD[$i]" \
             6150 "coef.censorbase15-nofilt.tb6150+tlrc.HEAD[$i]" \
             6162 "coef.censorbase15-nofilt.tb6162+tlrc.HEAD[$i]" \
             6199 "coef.censorbase15-nofilt.tb6199+tlrc.HEAD[$i]" \
             6301 "coef.censorbase15-nofilt.tb6301+tlrc.HEAD[$i]" \
             6366 "coef.censorbase15-nofilt.tb6366+tlrc.HEAD[$i]" \
             6487 "coef.censorbase15-nofilt.tb6487+tlrc.HEAD[$i]" \
             6562 "coef.censorbase15-nofilt.tb6562+tlrc.HEAD[$i]" \
             6563 "coef.censorbase15-nofilt.tb6563+tlrc.HEAD[$i]" \
             6601 "coef.censorbase15-nofilt.tb6601+tlrc.HEAD[$i]" \
             6631 "coef.censorbase15-nofilt.tb6631+tlrc.HEAD[$i]" \
             6704 "coef.censorbase15-nofilt.tb6704+tlrc.HEAD[$i]" \
             6813 "coef.censorbase15-nofilt.tb6813+tlrc.HEAD[$i]" \
             6842 "coef.censorbase15-nofilt.tb6842+tlrc.HEAD[$i]" \
             6843 "coef.censorbase15-nofilt.tb6843+tlrc.HEAD[$i]" \
             6874 "coef.censorbase15-nofilt.tb6874+tlrc.HEAD[$i]" \
             6899 "coef.censorbase15-nofilt.tb6899+tlrc.HEAD[$i]" \
             6930 "coef.censorbase15-nofilt.tb6930+tlrc.HEAD[$i]" \
             7065 "coef.censorbase15-nofilt.tb7065+tlrc.HEAD[$i]" \
             7153 "coef.censorbase15-nofilt.tb7153+tlrc.HEAD[$i]" \
             7428 "coef.censorbase15-nofilt.tb7428+tlrc.HEAD[$i]" \
             7763 "coef.censorbase15-nofilt.tb7763+tlrc.HEAD[$i]" \
             7764 "coef.censorbase15-nofilt.tb7764+tlrc.HEAD[$i]" \
             8068 "coef.censorbase15-nofilt.tb8068+tlrc.HEAD[$i]" \
             8135 "coef.censorbase15-nofilt.tb8135+tlrc.HEAD[$i]" \
             8159 "coef.censorbase15-nofilt.tb8159+tlrc.HEAD[$i]" \
             8403 "coef.censorbase15-nofilt.tb8403+tlrc.HEAD[$i]" \
             8461 "coef.censorbase15-nofilt.tb8461+tlrc.HEAD[$i]" \
             8462 "coef.censorbase15-nofilt.tb8462+tlrc.HEAD[$i]" \
             8503 "coef.censorbase15-nofilt.tb8503+tlrc.HEAD[$i]" \
             8561 "coef.censorbase15-nofilt.tb8561+tlrc.HEAD[$i]" \
             8562 "coef.censorbase15-nofilt.tb8562+tlrc.HEAD[$i]" \
             8630 "coef.censorbase15-nofilt.tb8630+tlrc.HEAD[$i]" \
             8632 "coef.censorbase15-nofilt.tb8632+tlrc.HEAD[$i]" \
             8748 "coef.censorbase15-nofilt.tb8748+tlrc.HEAD[$i]" \
             8818 "coef.censorbase15-nofilt.tb8818+tlrc.HEAD[$i]" \
             8883 "coef.censorbase15-nofilt.tb8883+tlrc.HEAD[$i]" \
             8965 "coef.censorbase15-nofilt.tb8965+tlrc.HEAD[$i]" \
             9026 "coef.censorbase15-nofilt.tb9026+tlrc.HEAD[$i]" \
             9027 "coef.censorbase15-nofilt.tb9027+tlrc.HEAD[$i]" \
             9065 "coef.censorbase15-nofilt.tb9065+tlrc.HEAD[$i]" \
             9148 "coef.censorbase15-nofilt.tb9148+tlrc.HEAD[$i]" \
             9149 "coef.censorbase15-nofilt.tb9149+tlrc.HEAD[$i]" \
             9158 "coef.censorbase15-nofilt.tb9158+tlrc.HEAD[$i]" \
             9331 "coef.censorbase15-nofilt.tb9331+tlrc.HEAD[$i]" \
             9354 "coef.censorbase15-nofilt.tb9354+tlrc.HEAD[$i]" \
             9369 "coef.censorbase15-nofilt.tb9369+tlrc.HEAD[$i]" \
             9392 "coef.censorbase15-nofilt.tb9392+tlrc.HEAD[$i]" \
             9405 "coef.censorbase15-nofilt.tb9405+tlrc.HEAD[$i]" \
             9425 "coef.censorbase15-nofilt.tb9425+tlrc.HEAD[$i]" \
             9512 "coef.censorbase15-nofilt.tb9512+tlrc.HEAD[$i]" \
             9614 "coef.censorbase15-nofilt.tb9614+tlrc.HEAD[$i]" \
             9639 "coef.censorbase15-nofilt.tb9639+tlrc.HEAD[$i]" \
             9660 "coef.censorbase15-nofilt.tb9660+tlrc.HEAD[$i]" \
             9661 "coef.censorbase15-nofilt.tb9661+tlrc.HEAD[$i]" \
             9692 "coef.censorbase15-nofilt.tb9692+tlrc.HEAD[$i]" \
             9727 "coef.censorbase15-nofilt.tb9727+tlrc.HEAD[$i]" \
             9728 "coef.censorbase15-nofilt.tb9728+tlrc.HEAD[$i]" \
             9769 "coef.censorbase15-nofilt.tb9769+tlrc.HEAD[$i]" \
             9804 "coef.censorbase15-nofilt.tb9804+tlrc.HEAD[$i]" \
             9841 "coef.censorbase15-nofilt.tb9841+tlrc.HEAD[$i]" \
             9881 "coef.censorbase15-nofilt.tb9881+tlrc.HEAD[$i]" \
             9941 "coef.censorbase15-nofilt.tb9941+tlrc.HEAD[$i]"
done
