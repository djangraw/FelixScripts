echo "This script will repeat what you type, or repeat the lines
in a file until the word 'exit' is read
"


while read var
do
  if [[ $var == "exit" ]]
  then
    break
  fi
  echo $var
  # do something else with $var
done

