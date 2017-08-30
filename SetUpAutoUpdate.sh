#!/bin/bash

# SetUpAutoUpdate.sh
#
# Created 8/29/17 by DJ.

# Make Git Repo
# cd /data/$USER # Navigate to directory you want to update
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

# Create README
rm -f README.md
echo "Auto-Update of all scripts in directory `pwd`." > README.md

# add .gitignore and README to repo
git add README.md
git add !.gitignore
git commit -m "Add README.md and .gitignore"

# Add everything!
git add -A

# Create git script to run nightly
rm -f AutoUpdate.sh
echo '#!/bin/bash' > AutoUpdate.sh
echo 'git add -A' > AutoUpdate.sh
echo 'git commit -m "Auto-Update `date`"' > AutoUpdate.sh

# Add it to your startup script to run every time you log in to Felix?

# Set up cron job to run it every night?
