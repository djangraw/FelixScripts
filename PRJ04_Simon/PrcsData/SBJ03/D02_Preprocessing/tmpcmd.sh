3dTcat -overwrite -prefix SBJ03_e2FirstVol.align p04.SBJ03_Run01_e2.align+orig'[0]' p04.SBJ03_Run02_e2.align+orig'[0]' p04.SBJ03_Run03_e2.align+orig'[0]' p04.SBJ03_Run04_e2.align+orig'[0]' p04.SBJ03_Run05_e2.align+orig'[0]' p04.SBJ03_Run06_e2.align+orig'[0]'
echo 'p04.SBJ03_Run01_e2.align p04.SBJ03_Run02_e2.align p04.SBJ03_Run03_e2.align p04.SBJ03_Run04_e2.align p04.SBJ03_Run05_e2.align p04.SBJ03_Run06_e2.align' >> tmp.txt
3drefit -relabel_all tmp.txt SBJ03_e2FirstVol.align+orig
rm tmp.txt
