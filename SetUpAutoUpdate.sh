#!/bin/bash

# SetUpAutoUpdate.sh
#
# Sets up a git repo to include all scripts (and only scripts) in
# a given directory, pushes it to a GitHub repo, and sets up
# a cron job to automatically update and push the repo to GitHub
# every night. Edit the dirToUpdate variable below to specify the
# directory you want to turn into a repo.
#
# Before running this script, create a new repo on GitHub, then copy
# the address from the webpage of your new repo (which should also
# include instructions on how to do what we're doing here) and paste
# it as the gitRepoAddress below.
#
# If you haven't uploaded to GitHub from Felix before, you will
# probably need to follow the instructions on this page to generate # an SSH key for communication with GitHub:
# https://help.github.com/articles/connecting-to-github-with-ssh/
#
# As this script finishes running, a text editor will open your
# 'crontab' file. Follow the instructions that this script outputs
# to set up your nightly Auto-Update cron job.
#
# If you run MATLAB after the git repo is created, MATLAB may try to index
# all your files and take forever to do it. To stop this from happening,
# you can disable Source Control in the Preferences menu
# (MATLAB>General>SourceControl pane).
#
# Created 8/29/17 by DJ.
# Updated 8/30/17 by DJ - completed cron part and added comments.
# Updated 10/2/17 by DJ - added note about MATLAB hanging.

# Declare constants
dirToUpdate="/data/$USER"
gitRepoAddress="git@github.com:djangraw/FelixScripts.git" # ssh version of remote address, copied from the webpage of your newly created github repo.

# Create Git Repo in the directory you want to update
cd $dirToUpdate # Navigate to directory you want to update
git init

# Make a .gitignore file with the filetypes you want to include.
# (I recommend including text files only so your repo doesn't get huge.)
rm -f .gitignore
echo '*' > .gitignore # ignore everything except...
echo '!*/' >> .gitignore # ...in all subdirectories...
echo '!*.sh' >> .gitignore # ...files ending in .sh.
echo '!*.tcsh' >> .gitignore
echo '!*.m' >> .gitignore
echo '!*.py' >> .gitignore
echo '!*.md' >> .gitignore
echo '!.gitignore' >> .gitignore
echo 'abin*' >> .gitignore # ignore this directory
echo '._*' >> .gitignore # ignore these mac metadata files

# Create README
rm -f README.md
echo "Auto-Update of all scripts in directory `pwd`." > README.md

# add .gitignore and README to repo as simple first commit
git add README.md
git add .gitignore
git commit -m "Add README.md and .gitignore"

# Create Auto-Update script that we will run nightly
rm -f AutoUpdate.sh
echo '#!/bin/bash' > AutoUpdate.sh
echo 'echo ===GIT AUTO-UPDATE, `date`===' >> AutoUpdate.sh
echo "cd $dirToUpdate" >> AutoUpdate.sh
echo 'git add -A' >> AutoUpdate.sh
echo 'git commit -m "Auto-Update `date`"' >> AutoUpdate.sh
echo 'git push origin master' >> AutoUpdate.sh
chmod u+x AutoUpdate.sh # so cron can run it

# Add everything to the Git repo! (This could take a while.)
git add -A
git commit -m "Add All Scripts"

# Send repo to GitHub
git remote add origin $gitRepoAddress # sets remote target
git remote -v # verifies URL
git push -u origin master # sends local repo to GitHub
# if you get an error at this last step, follow the instructions on this page to generate an SSH key: https://help.github.com/articles/connecting-to-github-with-ssh/

# initialize a blank log file that cron will add to every night.
touch AutoUpdate.log

# Set up cron job to run our Auto-Update script every night
echo "===Enter the following line into the crontab file: 0 3 * * * $dirToUpdate/AutoUpdate.sh >> $dirToUpdate/AutoUpdate.log 2>&1"
echo "===(Include an empty line after that line to avoid an error.)"
echo "===This command will make the file AutoUpdate.sh run every night at 3AM."
crontab -e # opens the crontab file
