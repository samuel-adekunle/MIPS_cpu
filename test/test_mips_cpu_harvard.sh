#!/bin/bash
set -eou pipefail
VARIANT="harvard"
DIRECTORY="$1"

#compile utils?
g++ ./test/test_cases.cpp -o test/test_cases
g++ ./test/test_case_functions.cpp -o test/test_case_fns

if [ $# -ge 2 ]
then
    TESTCASE="$2"
    #test for one
    ./test/run_instruction_testcase.sh ${DIRECTORY} ${TESTCASE}
else
    #test all
    ./test/run_all_testcases.sh ${DIRECTORY}

fi