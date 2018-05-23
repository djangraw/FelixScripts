#!/bin/bash

PRJDIR='/data/jangrawdc/PRJ18_HaskinsStory';

dataDir='/data/NIMH_Haskins/a182' # data directory
scriptDir='/data/jangrawdc/PRJ18_HaskinsStory/Scripts'; # DJ script directory

subjects="tb0027 tb0028 tb0065 tb0093 tb0094 tb0111 tb0137 "\
"tb0138 tb0169 tb0170 tb0201 tb0202 tb0239 tb0240 tb0275 "\
"tb0276 tb0312 tb0313 tb0348 tb0349 tb0381 tb0382 tb0420 "\
"tb0421 tb0455 tb0456 tb0497 tb0498 tb0542 tb0543 tb0592 "\
"tb0593 tb0716 tb0717 tb0741 tb0782 tb0783 tb0829 tb0954 "\
"tb1063 tb1147 tb1165 tb1208 tb1249 tb1290 tb1313 tb1314 "\
"tb1357 tb1400 tb1401 tb1524 tb2521 tb2522 tb5688 tb5689 "\
"tb5722 tb5723 tb5762 tb5796 tb5832 tb5833 tb5867 tb5868 "\
"tb5895 tb5896 tb5914 tb5949 tb5976 tb5985 tb5986 tb6026 "\
"tb6048 tb6081 tb6082 tb6120 tb6121 tb6150 tb6162 tb6163 "\
"tb6198 tb6199 tb6235 tb6236 tb6300 tb6301 tb6332 tb6333 "\
"tb6366 tb6367 tb6387 tb6388 tb6419 tb6450 tb6487 tb6520 "\
"tb6521 tb6562 tb6563 tb6600 tb6601 tb6631 tb6632 tb6663 "\
"tb6664 tb6702 tb6703 tb6704 tb6742 tb6743 tb6777 tb6812 "\
"tb6813 tb6842 tb6843 tb6874 tb6875 tb6898 tb6899 tb6930 "\
"tb6964 tb6965 tb7000 tb7001 tb7034 tb7035 tb7065 tb7066 "\
"tb7090 tb7091 tb7125 tb7126 tb7152 tb7153 tb7187"
subjects=($subjects) # convert to array

# All subjects with complete fMRI Data
okSubj="tb0027 tb0028 tb0065 tb0093 tb0094 tb0169 "\
"tb0170 tb0202 tb0275 tb0276 tb0312 tb0313 tb0348 "\
"tb0349 tb0420 tb0456 tb0498 tb0543 tb0593 tb0716 "\
"tb0717 tb0782 tb1063 tb1208 tb1249 tb1314 tb2521 "\
"tb2522 tb5688 tb5723 tb5796 tb5833 tb5868 tb5976 "\
"tb5985 tb5986 tb6048 tb6082 tb6121 tb6150 tb6163 "\
"tb6199 tb6236 tb6300 tb6301 tb6333 tb6366 tb6367 "\
"tb6419 tb6487 tb6521 tb6562 tb6600 tb6631 tb6632 "\
"tb6663 tb6777 tb6812 tb6842 tb6874 tb6899 tb6930 "\
"tb6964 tb7001 tb7035 tb7065 tb7090 tb7091 tb7125 "\
"tb7153"
okSubj=($okSubj) #convert to array

# All subjects with complete fMRI and reading phenotyping data
okReadSubj="tb0027 tb0065 tb0093 tb0094 tb0169 tb0170 tb0275 tb0276 tb0312 "\
"tb0313 tb0349 tb0456 tb0498 tb0543 tb0593 tb0716 tb0782 tb1063 tb1208 tb1314 "\
"tb5833 tb5868 tb5976 tb5985 tb6048 tb6082 tb6150 tb6199 tb6301 tb6366 tb6367 "\
"tb6487 tb6562 tb6631 tb6812 tb6842 tb6874 tb6899 tb6930 tb7065 tb7125 tb7153"
okReadSubj=($okReadSubj) #convert to array

# top half readers
okReadSubj_top="tb6048 tb6367 tb0498 tb0169 tb7153 tb0065 tb6874 tb6899 tb6150 "\
"tb0716 tb5985 tb6199 tb0349 tb6082 tb0275 tb6842 tb6487 tb0093 tb6301 tb6562 tb7065"
okReadSubj_top=($okReadSubj_top)
# bottom half readers
okReadSubj_bot="tb7125 tb5833 tb0593 tb0027 tb0312 tb0094 tb1063 tb0313 tb1314 "\
"tb5868 tb1208 tb0170 tb0782 tb0276 tb0543 tb6366 tb6812 tb5976 tb6631 tb6930 tb0456"
okReadSubj_bot=($okReadSubj_bot)
