#!/bin/bash

gen_group_command.py -command 3dttest++             \
                     -write_script cmd.tt++.readingrecall       \
                     -prefix tt++.readingrecall_covary_clustsim          \
                     -dsets ./coef_ReadingGlt.*.blur_fwhm4p0.scale+tlrc.HEAD         \
                     -subs_betas 'ReadingVsFixation#0_Coef'      \
                     -options                       \
                        -covariates ReadingScores.txt  \
                        -center SAME \
                        -toz -Clustsim
