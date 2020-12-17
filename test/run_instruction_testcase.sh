#!/bin/bash
set -eou pipefail

DIRECTORY="$1"
TESTCASES="test/0-cases/${2}_*.txt"
if [[ ! -f test/0-cases/${2}_1.txt ]]; then
    echo 'No testcase found'
    exit
fi
VARIANT="$3"
#create random test case where possible
RANDOMTEST1=${2}
RANDOMTEST1+="_r1"
RANDOMTEST2=${2}
RANDOMTEST2+="_r2"
RANDOMTEST3=${2}
RANDOMTEST3+="_r3"
./test/test_case_fns test/0-cases/${RANDOMTEST1}.txt
./test/test_case_fns test/0-cases/${RANDOMTEST2}.txt
./test/test_case_fns test/0-cases/${RANDOMTEST3}.txt
TESTCASES="test/0-cases/${2}_*.txt"
for i in ${TESTCASES}; do
    # Extract just the testcase name from the filename.
    TESTNAME=$(basename ${i} .txt)
    # Dispatch to the main test-case script
    ./test/run_one_testcase.sh ${DIRECTORY} ${TESTNAME} ${VARIANT}
done

# NUMBER=$(echo ${TESTNAME//[^0-9]})
# NUMBER=$((${NUMBER} + 1))
# #create a random test case if possible
# RANDOMTEST1+=$(echo ${TESTNAME} | cut -d _ -f 1)
# RANDOMTEST1+="_r1"
# ./test/test_case_fns test/0-cases/${RANDOMTEST1}.txt
# ./test/run_one_testcase.sh ${DIRECTORY} ${RANDOMTEST1}
# RANDOMTEST2+=$(echo $TESTNAME | cut -d _ -f 1)
# RANDOMTEST2+="_r2"
# ./test/test_case_fns test/0-cases/${RANDOMTEST2}.txt
# ./test/run_one_testcase.sh ${DIRECTORY} ${RANDOMTEST2}
