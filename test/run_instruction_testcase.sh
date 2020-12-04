#!/bin/bash
set -eou pipefail
   
DIRECTORY="$1" 
TESTCASES="test/0-cases/${2}_*.txt"
if [[ ! -f test/0-cases/${2}_1.txt ]] ; then
    echo 'No testcase found'
    exit
fi
for i in ${TESTCASES} ; do
    # Extract just the testcase name from the filename.
    TESTNAME=$(basename ${i} .txt)
    # Dispatch to the main test-case script
    ./test/run_one_testcase.sh ${DIRECTORY} ${TESTNAME}
done