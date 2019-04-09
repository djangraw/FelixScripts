#!/bin/bash

module load afni python/2.7
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh

for subj in ${okReadSubj[@]}; do 
    results_dir=$dataDir/$subj/$subj.story
    cd $results_dir

    # generate html ss review pages
    # (akin to static images from running @ss_review_driver)
    apqc_make_tcsh.py -review_style pythonic -subj_dir . \
        -uvar_json out.ss_review_uvars.json
    tcsh @ss_review_html
    apqc_make_html.py -qc_dir QC_$subj

done
