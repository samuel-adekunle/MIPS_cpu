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

# NUMBER=$(echo ${TESTNAME//[^0-9]})
# NUMBER=$((${NUMBER} + 1))
# #create a random test case if possible
# RANDOMTEST+=$(echo $TESTNAME | cut -d _ -f 1) 
# RANDOMTEST+="_"
# RANDOMTEST+=${NUMBER}
# ./test/test_case_fns test/0-cases/${RANDOMTEST}.txt
# ./test/run_one_testcase.sh ${DIRECTORY} ${RANDOMTEST}
