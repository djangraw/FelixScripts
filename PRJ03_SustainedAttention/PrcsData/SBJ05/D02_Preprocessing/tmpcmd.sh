3dTcat -overwrite -prefix SBJ05_e2FirstVol.align p04.SBJ05_Run01_e2.align+orig'[0]' p04.SBJ05_Run02_e2.align+orig'[0]' p04.SBJ05_Run03_e2.align+orig'[0]' p04.SBJ05_Run04_e2.align+orig'[0]'
echo 'p04.SBJ05_Run01_e2.align p04.SBJ05_Run02_e2.align p04.SBJ05_Run03_e2.align p04.SBJ05_Run04_e2.align' >> tmp.txt
3drefit -relabel_all tmp.txt SBJ05_e2FirstVol.align+orig
rm tmp.txt
