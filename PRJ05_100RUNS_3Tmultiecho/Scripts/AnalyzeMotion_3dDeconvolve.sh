3dDeconvolve -input /data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/${subject}/ReverseCorrelation/${subject}_Video_Mean_Meica+orig.BRIK \
	-polort 3 			\
	-xout -num_stimts 2 \
	-stim_file 1 AvgSpeedRegressor.1D -stim_label 1 AvgSpeed	\
	-stim_file 2 NewClipRegressor.1D -stim_label 2 NewClip		\
	-mask $maskfile 	\
	-fitts ${subject}_fit_ts_meica -errts ${subject}_error_ts_meica -xjpeg ${subject}_glm_matrix.jpg -tout -fout -bucket ${subject}_glm_out_meica

3dDeconvolve -input /data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/${subject}/ReverseCorrelation/${subject}_Video_Mean_Echo2+orig.BRIK \
	-polort 3 			\
	-xout -num_stimts 2 \
	-stim_file 1 AvgSpeedRegressor.1D -stim_label 1 AvgSpeed	\
	-stim_file 2 NewClipRegressor.1D -stim_label 2 NewClip		\
	-mask $maskfile 	\
	-fitts ${subject}_fit_ts_echo2 -errts ${subject}_error_ts_echo2 -xjpeg ${subject}_glm_matrix.jpg -tout -fout -bucket ${subject}_glm_out_echo2

3dDeconvolve -input /data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/${subject}/ReverseCorrelation/${subject}_Video_Mean_OptCom+orig.BRIK \
	-polort 3 			\
	-xout -num_stimts 2 \
	-stim_file 1 AvgSpeedRegressor.1D -stim_label 1 AvgSpeed	\
	-stim_file 2 NewClipRegressor.1D -stim_label 2 NewClip		\
	-mask $maskfile 	\
	-fitts ${subject}_fit_ts_optcom -errts ${subject}_error_ts_optcom -xjpeg ${subject}_glm_matrix.jpg -tout -fout -bucket ${subject}_glm_out_optcom