#!/bin/bash
set -eou pipefail

DIRECTORY="$1"   
VARIANT="$2"
TESTCASES="test/0-cases/*.txt"
#create random where possible 
INSTRUCTIONS="test/0-cases/*_1.txt"
for i in ${INSTRUCTIONS} ; do
    INSTR=$(basename ${i} _1.txt)
    RANDOMTEST1=${INSTR}
    RANDOMTEST1+="_r1"
    RANDOMTEST2=${INSTR}
    RANDOMTEST2+="_r2"
    RANDOMTEST3=${INSTR}
    RANDOMTEST3+="_r3"
    ./test/test_case_fns test/0-cases/${RANDOMTEST1}.txt
    ./test/test_case_fns test/0-cases/${RANDOMTEST2}.txt
    ./test/test_case_fns test/0-cases/${RANDOMTEST3}.txt
done
for i in ${TESTCASES} ; do
    # Extract just the testcase name from the filename
    TESTNAME=$(basename ${i} .txt)
    # Dispatch to the main test-case script
    ./test/run_one_testcase.sh ${DIRECTORY} ${TESTNAME} ${VARIANT} 
done

#delete the random files(not necessary)
# rm -rf test/0-cases/*r1.txt 
# rm -rf test/0-cases/*r2.txt
# rm -rf test/0-cases/*r3.txt