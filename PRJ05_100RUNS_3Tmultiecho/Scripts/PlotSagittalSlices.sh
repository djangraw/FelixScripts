filetype="MEICA"
nfiles=16
centerC="-22 14 15"

afni -com "OPEN_WINDOW A.sagittalimage mont=4x4:8 geom=752x616+0+0 opacity=5 ifrac=1" \
-com "CLOSE_WINDOW A.axialimage" \
-com "SWITCH_UNDERLAY ${subject}_Anatomy+orig" \
-com "SWITCH_OVERLAY ${subject}_${filetype}_ISC_${nfiles}files+orig" \
-com "SET_FUNC_AUTORANGE A.-" \
-com "SET_FUNC_RANGE A.0.3" \
-com "SET_PBAR_SIGN A.+" \
-com "SET_THRESHNEW A .05 *p" \
-com "SET_VIEW A.tlrc" \
-com "SET_DICOM_XYZ A ${centerC}" \
-com "SET_XHAIRS A.OFF"