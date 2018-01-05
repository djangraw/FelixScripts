#!/bin/bash

# GetSrttReviewTable.sh
#
# Created 1/4/18 by DJ.

source 00_CommonVariables.sh

# Make and enter QA folder`
mkdir -p ${PRJDIR}/RawData/QA
cd ${PRJDIR}/RawData/QA

# Run gen_ss_review_table command
gen_ss_review_table.py -tablefile review_table.xls        \
                -infiles ${PRJDIR}/RawData/tb*/tb*.srtt_v3/out.ss_review.tb*.txt
