#!/bin/bash
set -eou pipefail
   
TESTCASES="test/cases/${1}_*.txt"

for i in ${TESTCASES} ; do
    # Extract just the testcase name from the filename.
    TESTNAME=$(basename ${i} .txt)
    # Dispatch to the main test-case script
    ./test/run_one_testcase.sh ${TESTNAME}
done
