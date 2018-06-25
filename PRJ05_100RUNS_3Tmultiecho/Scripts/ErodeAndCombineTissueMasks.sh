3dcalc -a ${subject}_Gray_EPIRes+orig -expr 'ispositive(a-7500)' -prefix __tmp_GMbin+orig -overwrite
# 3dmask_tool -input __tmp_GMbin+orig -dilate_input -1 -prefix __tmp_GM+orig -overwrite

3dcalc -a ${subject}_White_EPIRes+orig -expr 'ispositive(a-9000)' -prefix __tmp_WMbin+orig -overwrite
# 3dmask_tool -input __tmp_WMbin+orig -dilate_input -1 -prefix __tmp_WM+orig -overwrite

3dcalc -a ${subject}_CSF_EPIRes+orig -expr 'ispositive(a-9000)' -prefix __tmp_CSFbin+orig -overwrite
# 3dmask_tool -input __tmp_CSFbin+orig -dilate_input -1 -prefix __tmp_CSF+orig -overwrite

3dcalc -a __tmp_GMbin+orig -b __tmp_WMbin+orig -c __tmp_CSFbin+orig -expr 'a + 2*b + 3*c' -prefix ${subject}_TissueMasks+orig -overwrite
# 3dcalc -a __tmp_GM+orig -b __tmp_WM+orig -c __tmp_CSF+orig -expr 'a + 2*b + 3*c' -prefix ${subject}_TissueMasks+orig -overwrite
rm __tmp*