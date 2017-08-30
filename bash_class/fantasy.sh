#!/bin/bash

#===============================================================================
# Fantasy script for a fantasy workflow
#
# David Hoover, 2011-12-15
#===============================================================================

# This fantasy workflow takes a "raw data" file, runs it through three
# commands, and compiles the final results into a database file.  This is a
# generic template that could be applied to other applications, like 
# sequencing or statistical analysis.  Your call.

# There are a number of hiccups in the workflow, as there always are.  The
# purpose of this script is to check for the problems and report what is 
# going on so that they don't screw you up later on.

# The commands are actually bash scripts in themselves.  You are welcome to
# look at them to see how they work as well.

#===============================================================================
# Example 1.
# A very basic error function for this script.  Note that all functions within
# a script must appear at the top of the script.
#===============================================================================

function throwError
{
  echo ERROR: $1
  exit 1
}

# This could also be written in one-liner fashion

# throwError () { echo ERROR: $1; exit 1; }

#===============================================================================
# Example 2.
# There are two arguments required for this script, rawdata and a unique name.
# We will use the most standard conditional statement to check if exactly two
# arguments were given to the script.
#===============================================================================

if [ $# -ne 2 ]
then echo "usage: $0 rawdata name"
  exit 1   # Give exit status of 1 to signal general error
fi

#===============================================================================
# Example 3.
# Assign the rawdata and name variables from the positional parameters, as well
# as some other variables.
#===============================================================================

rawdata=$1
name=$2

# Don't allow the unique name to have blanks in it.  This will save us from a
# lot of headaches.

echo $name | grep -q [[:blank:]] && throwError "Unique name can't have blanks"

# Other variables can be set here as well.  Because these use the $PWD
# environment variable, they are full absolute pathnames, and can called from
# anywhere.

bindir=$PWD                          # path to binary files
database=$PWD/fantasy_database.txt   # path to database
workdir=$PWD/workdir_${name}         # path to workdir

#===============================================================================
# Example 4.
# Create workdir so that files created won't interfere with previously created
# ones.
#===============================================================================

# Because we will be creating a working directory to create files, it is best
# to expand the initial $rawdata file to the full and absolute pathname.  That
# way, it will be very easy to find it.

D=`dirname "$rawdata"`
B=`basename "$rawdata"`
fullrawdata="`cd \"$D\" 2>/dev/null && pwd -P || echo \"$D\"`/$B"

# Don't overwrite a previous run.

if [ -d $workdir ] ; then throwError "$workdir already exists" ; fi

mkdir $workdir
cd $workdir

#===============================================================================
# Example 5.
# Check to see if rawdata actually exists.
#===============================================================================

# The $fullrawdata variable must be double-quoted in case it has blanks.  This
# causes it to be expanded to a single word prior to test evaluation.  If it
# had blanks, only the first word would be tested.

# This is the most formal way of testing if a file exists.

if test ! -f "$fullrawdata"
then echo "$rawdata doesn't exist"
  exit 1
elif test ! -s "$fullrawdata"
then echo "$rawdata is empty"
  exit 1
else
  echo "$rawdata is present"
fi

# Here are some one-liner equivalents:

# Compound commands in braces "{}" must end with a semi-colon ";". They are 
# excuted in the current shell.

#  { [ ! -f "$fullrawdata" ] && throwError "$rawdata doesn't exist"; } || \
#    { [ ! -s "$fullrawdata" ] && throwError "$rawdata is empty"; } || \
#    { echo "$rawdata is present"; }

# Parentheses don't require a semi-colon at the end. However, because the
# compound command is executed in a subshell, each of the test evaluations
# are run independently, and the exit is ignored.  This doesn't work.
 
#  ( [ ! -f "$fullrawdata" ] && throwError "$rawdata doesn't exist" ) || \
#    ( [ ! -s "$fullrawdata" ] && throwError "$rawdata is empty" ) || \
#    ( echo "$rawdata is present" )

# To avoid quoting the $fullrawdata variable, you can use double brackets "[[]]":

#  { [[ ! -f $fullrawdata ]] && throwError "$rawdata doesn't exist"; } || \
#    { [[ ! -s $fullrawdata ]] && throwError "$rawdata is empty"; } || \
#    { echo "$rawdata is present"; }
 
#===============================================================================
# Example 6.
# Check to see if the unique name has already been used.  Shown here is a
# more complicated one-liner.
#===============================================================================

# The final results of the fantasy workflow will be appended to a database file.
# If the database file doesn't already exist, create it here.

# The first line of the file will contain headers separated by tabs.  The
# headers will be loaded as an array.  Because words in an array are split on
# the basis of blanks, having headers with multiple words presents a problem.
# The $IFS variable shows what character, or group of characters, is used as a
# word separator.  Normally it is a single space.  For this brief instance, we
# need it to be a tab.
 
if [ ! -e $database ]
then
  SAVEIFS=$IFS
  IFS=$(echo -en "\t")
  array=("Unique Name" "Raw Data File" "Date Processed" "Results File" "Score" "Annotations" "Tarball")
  echo "${array[*]}" > $database
  IFS=$SAVEIFS
fi

# Now check to see if the unique name has been used already and is in the 
# database file.

# The formal way...  Note that no braces are needed for the pipeline.  The
# exit status of the pipeline determines action.

if cut -f 1 $database | tail -n +2 | grep -m 1 -q ^$name$
  then throwError "'$name' has already been used"
fi

# The one-liner way...

#  { cut -f 1 $database | tail -n +2 | grep -m 1 -q ^$name$; } \
#  && { throwError "'$name' has already been used"; }

#===============================================================================
# Example 7.
# Modifying the $PATH variable
#===============================================================================

# Now that we are here, cmdA will call another program that requires
# an addition to the PATH environment variable.  Note that this only
# changes the $PATH variable within the scope of this script.

export PATH=/usr/local/extra/nonsense/bin:$PATH

#===============================================================================
# Example 8.
# Setting an alias within a script
#===============================================================================

# As written this will fail, because cmdA is not in our path.  This could be
# solved by creating an alias.  However, we need to enable the expand_aliases
# option to allow alias expansion within the script.

shopt -s expand_aliases
alias cmdA="$bindir/cmdA"

#===============================================================================
# Example 9.
# Calling a command within a script
#===============================================================================

# It's always good to have some kind of output telling what is happening.

echo "Running cmdA..."

# Why is $name in braces?  In this case we are adding an extra letter (A) to 
# $name to keep the out file from being overwritten by downstream processes.
# Putting $name in braces causes the value to be expanded first prior to 
# appending.

# Again, $fullrawdata must be enclosed in double quotes in case it has blanks.

# In case cmdA fails and returns an exit status > 0, we'll create a compound
# conditional statment.

cmdA -f "$fullrawdata" -n 5 --bogus --nonsense --extra-juicy -o ${name}A.zzz \
 -t ${name}A.txt >  ${name}A.out || throwError "cmdA failed!"

# Test to see what happens when it does fail.  cmdA requires -o, -t, and -f.

#cmdA -f $fullrawdata -n 5 --bogus --nonsense --extra-juicy >  "${name}A.out" \
#  || throwError "cmdA failed!"

#===============================================================================
# Example 10.
# Checking memory on the host
#===============================================================================

# cmdB requires at least 20GB of memory.  An easy way to find this is the free
# command, combined with grep and awk.

# There is no equivalent to free on a Mac, so we'll make this step 
# conditional on whether the free command exists.

if `which free > /dev/null`
then 
  freemem=`free -g | grep 'buffers/cache' | awk '{print $4}'`
  echo "Free memory = $freemem"
else
  echo "free command not found"
  freemem=20
fi

# This conditional command will use arithmetic expansion.  This involves the
# double parentheses "(())", and can be done with a one-liner.

(( $freemem < 10 )) && throwError "Not enough memory!" 

#===============================================================================
# Example 11.
# Setting an environment variable
#===============================================================================

# The next step, cmdB, requires an addiional environment variable to find the
# wgs database.

export CMDB_DATABASE=/fdb/blastdb/wgs

#===============================================================================
# Example 12.
# Running cmdB.
#===============================================================================

echo "Running cmdB..."

# cmdB is a somewhat flaky program.  It can hang or go haywire. It doesn't
# return a proper exit status, so we can't simply create a conditional compound
# command.  Bad programming on the part of cmdB developers, but what are you
# going to do?

# One way of dealing with nasty programs is run them in the background and keep
# an eye on them while they're running.

# First, we'll run cmdB in the background.

$bindir/cmdB -i "${name}A.zzz" > "${name}B.out" 2> "${name}B.err" &

# Capture the process id of the last background job.

ps=$!

# Next, we'll create a while loop to monitor what's happening.  If the process
# id is no longer valid because the load has dipped below 50%, then quit.

# The process needs to be killed in two steps.  First we run pkill, which kills
# all the children of the process.  This is important, because killing the
# parent only will leave all the spawned children to wreak havok down the line.
# After pkill, we run the standard kill.

# After killing, we wait for the background processes to end using wait.  This
# is important because just issuing the kill signal may not stop the process 
# immediately.  Programs can be written to catch a signal and do some tidying up
# before they end.

# The pkill utility doesn't exist on all operating systems, so we'll make it
# conditional.

while `ps -p $ps > /dev/null` 
do 
  echo "Waiting..."
  sleep 2
  load=`ps -p $ps -o pcpu | tail -1 | cut -d "." -f 1`
  if [[ $load -lt 50 ]]
  then
    echo "no load!" 1>&2
    `which pkill > /dev/null` && pkill -P $ps
    kill $ps
    wait
    break
  fi
done

# Make sure results exist

{ [ ! -f "${name}B.out" ] && throwError "${name}B.out doesn't exist"; } || \
  { [ ! -s "${name}B.out" ] && throwError "${name}B.out is empty"; } || \
  { echo "${name}B.out is present"; }

#===============================================================================
# Example 13.
# Sort, filter, and reformat
#===============================================================================

# cmdC requires a list of tab-delimited data in a single input file, and in
# a particular field order.  We also want to limit the amount of data and
# filter out the entries whose annotations begin with D.  Don't ask why.

# This is an example of doing everything in one step using pipes.  First we 
# sort the results by numerical (-n) reverse (-r) order using the second field
# (-k2).  Next we keep only the top 10 answers (head -10).  Next, we get rid of
# those lines that begin with a D (fantasies don't always answer why).  Last,
# we use awk to rearrange the order of the fields and convert the fields from
# space-delimited to tab-delimited.

sort -nrk2 "${name}B.out" | head -10 | grep -v ^D | awk '{print $2 "\t" $1 "\t" $3}' > "${name}C.in"

# Make sure the reformatted results file is not empty

if [ ! -s "${name}C.in" ] ; then throwError "${name}C.in is empty" ; fi

echo "${name}C.in is not empty, running cmdC"

#===============================================================================
# Example 14.
# Run cmdC and rename an indeterminate number of output files.
#===============================================================================

# cmdC creates a series of files of the name format cmdC_xx.out, where xx is 
# any two character string.  Thus, there will be an indeterminate number of
# files created.

$bindir/cmdC < "${name}C.in"

# Because the names are generic, we need to move the files to the standard
# naming convention for this script.

echo "Renaming cmdC_*.out files"
for oldfile in `ls cmdC_*.out`
do
  newfile=`echo $oldfile | sed -e "s/cmdC_/${name}C_/"`
  mv $oldfile $newfile
done

#===============================================================================
# Example 15.
# Save results into a single tarball.
#===============================================================================

# To compartmentalize the results into a single file that can be backed up and
# transferred easily, we will create a gzipped tar file, know colloquially as
# a tarball.  The name of the tarball will reflect the current time and the 
# unique name.

datestring=`date +%s`
tarball=${datestring}_${name}.tgz
echo "Creating tarball $tarball"
tar czf $tarball ${name}*

# Move the tarball to whatever directory the database is in

mv $tarball `dirname $database`

#===============================================================================
# Example 16.
# Append results to fantasy_database.txt
#===============================================================================

# Here we need to parse through the indeterminate results of cmdC, pull out the
# annotation string, generate the average score for similar annotations, and 
# compile other data into the database file.

for results in `ls ${name}C_*.out`
do
  ann=""
  for j in `awk '{print $1}' $results`
  do
    if [ ! -z $ann ] ; then ann=${ann}: ; fi
    ann=${ann}`echo -n ${j}`
  done
  avg=`awk '{sum+=$2; num++;}END{avg=sum/num; print avg}' $results` 
  datestring=`date +%F`
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" $name "$rawdata" $datestring $results $avg $ann $tarball >> $database
done

#===============================================================================
# Example 17.
# Clean up and move on.
#===============================================================================

# Always a vital part of any project, you need to clean up the toys after you've
# taken them out.  In this case, the the files have already been bundled up in 
# the tarball, so there is no need to keep them or the working directory where
# they were generated.

rm ${name}*
cd ..
rmdir $workdir

# All done!

echo "Success!"
exit
