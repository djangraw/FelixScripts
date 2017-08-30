# There is always more than one way to do it

tag=$USER.$RANDOM
mkdir $tag
cd $tag
echo -n "NEW DIR: "
echo $tag

# An easier way
basename=myfile
newname=newfile
touch $basename.{txt,bam,bam.bai,bam.bas,pdb,psf,dcd,coor,conf}
mv {$basename.txt,$newname.txt}
mv {$basename.bam,$newname.bam}
mv {$basename.bam.bai,$newname.bam.bai}
mv {$basename.bam.bas,$newname.bam.bas}
mv {$basename.pdb,$newname.pdb}
mv {$basename.psf,$newname.psf}
mv {$basename.dcd,$newname.dcd}
mv {$basename.coor,$newname.coor}
mv {$basename.conf,$newname.conf}
