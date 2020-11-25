#!/bin/bash
set -eou pipefail
VARIANT="bus"
DIRECTORY="$1"
FLAGS="-g 2012 -Wall"

if [ $# -ge 2 ]
then
    TESTCASE="$2"
    #test for one
    ./run_instruction_testcase.sh ${TESTCASE}
else
    #test all
    ./run_all_testcases.sh

fi