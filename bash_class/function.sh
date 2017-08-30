function throwError
{
  echo ERROR: $1
  exit 1
}

tag=$USER.$RANDOM
throwError "No can do!"
mkdir $tag
cd $tag
