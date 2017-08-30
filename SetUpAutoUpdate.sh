#!/bin/bash

# SetUpAutoUpdate.sh
#
# Created 8/29/17 by DJ.

# Declare constants
dirToUpdate="/data/$USER"
gitRepoAddress="https://github.com/djangraw/FelixScripts.git"

# Make Git Repo
cd $dirToUpdate # Navigate to directory you want to update
git init

# Make a .gitignore with the filetypes you want to include.
# (I recommend including text files only so your repo doesn't get huge.)
rm -f .gitignore
echo '*' > .gitignore
echo '!*/' >> .gitignore
echo '!*.sh' >> .gitignore
echo '!*.tcsh' >> .gitignore
echo '!*.m' >> .gitignore
echo '!*.py' >> .gitignore
echo '!*.md' >> .gitignore
echo '!.gitignore' >> .gitignore
echo 'abin*' >> .gitignore

# Create README
rm -f README.md
echo "Auto-Update of all scripts in directory `pwd`." > README.md

# add .gitignore and README to repo
git add README.md
git add !.gitignore
git commit -m "Add README.md and .gitignore"

# Create git script to run nightly
rm -f AutoUpdate.sh
echo '#!/bin/bash' > AutoUpdate.sh
echo 'echo ===GIT AUTO-UPDATE, `date`===' >> AutoUpdate.sh
echo 'git add -A' >> AutoUpdate.sh
echo 'git commit -m "Auto-Update `date`"' >> AutoUpdate.sh
echo 'git push origin master' >> AutoUpdate.sh

# Add everything to the Git repo!
git add -A

# Send repo to GitHub
git remote add origin $gitRepoAddress # sets remote target
git remote -v # verifies URL
git push origin master # sends local repo to

# initialize a blank log file that cron will write to
touch AutoUpdate.log

# Set up cron job to run it every night
echo "===Enter the following line into the crontab file: 0 3 * * * $dirToUpdate/AutoUpdate.sh >> $dirToUpdate/AutoUpdate.log 2>&1"
echo "===(Include an empty line after that line to avoid an error.)"
echo "===This command will make the file AutoUpdate.sh run every night at 3AM."
crontab -e # opens the crontab file
