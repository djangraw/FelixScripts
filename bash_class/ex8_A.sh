# There is always more than one way to do it

tag=$USER.$RANDOM
mkdir $tag
cd $tag
echo -n "NEW DIR: "
echo $tag

# The long way
touch myfile.txt
touch myfile.bam
touch myfile.bam.bai
touch myfile.bam.bas
touch myfile.pdb
touch myfile.psf
touch myfile.dcd
touch myfile.coor
touch myfile.conf
mv myfile.txt     newfile.txt
mv myfile.bam     newfile.bam
mv myfile.bam.bai newfile.bam.bai
mv myfile.bam.bas newfile.bam.bas
mv myfile.pdb     newfile.pdb
mv myfile.psf     newfile.psf
mv myfile.dcd     newfile.dcd
mv myfile.coor    newfile.coor
mv myfile.conf    newfile.conf
