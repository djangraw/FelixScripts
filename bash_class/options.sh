arg=($@)
for (( i=0 ; i < ${#arg[@]} ; i++ ))
do
  let j=i+1
  case ${arg[$i]} in
    -h) halp=1 ;;
    --help) halp=1 ;;
    -d) debug=1 ;;
    --debug) debug=1 ;;
    --nonsense) nonsense=1 ;;
    --extra-juicy) extra=1 ;;
  esac
done

[[ $halp ]] && echo "Help? What help?" && exit
[[ $debug ]] && echo "Wasn't doing nuffin anyway..." && exit
echo "Now for something completely different"

