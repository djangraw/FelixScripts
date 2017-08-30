# There is always more than one way to do it

tag=$USER.$RANDOM
mkdir $tag
cd $tag
echo -n "NEW DIR: "
echo $tag

# A way easier way
basename=myfile
newname=newfile
touch $basename.{txt,bam,bam.bai,bam.bas,pdb,psf,dcd,coor,conf}
rename $basename $newname $basename.*
