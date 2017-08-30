pwd
for i in {1..10} ; do 
(
  BASE=/tmp/$i.$RANDOM
  mkdir $BASE ; echo -n "OLD DIR: " ; pwd
  cd $BASE ; echo -n "NEW DIR: " ; pwd
  sleep 2
  rmdir $BASE
)
done
pwd
