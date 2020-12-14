#!/bin/bash
set -eou pipefail
VARIANT="bus"
DIRECTORY="$1"

if [ $# -ge 2 ]
then
    TESTCASE="$2"
    #test for one
    ./test/run_instruction_testcase.sh ${DIRECTORY} ${TESTCASE} ${VARIANT}
else
    #test all
    ./test/run_all_testcases.sh ${DIRECTORY} ${VARIANT}

fi