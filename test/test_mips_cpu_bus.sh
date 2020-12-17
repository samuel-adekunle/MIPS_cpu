#!/bin/bash
set -eou pipefail
VARIANT="bus"
DIRECTORY="$1"
chmod u+x test/run_all_testcases.sh
chmod u+x test/run_instruction_testcase.sh
chmod u+x test/run_one_testcase.sh
#compile utils?
g++ ./test/assembler.cpp -o test/assembler
g++ ./test/test_case_functions.cpp -o test/test_case_fns

if [ $# -ge 2 ]; then
    TESTCASE="$2"
    #test for one
    ./test/run_instruction_testcase.sh ${DIRECTORY} ${TESTCASE} ${VARIANT}
else
    #test all
    ./test/run_all_testcases.sh ${DIRECTORY} ${VARIANT}

fi
