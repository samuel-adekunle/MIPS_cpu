#!/bin/bash
set -eou pipefail

DIRECTORY="$1"
TESTCASE="$2"
INSTRUCTION=$(echo $TESTCASE | cut -d _ -f 1)
FLAGS="-g 2012 -Wall"
VARIANT="$3"

##assemble test case
COMMENT=$(./test/assembler "test/0-cases/${TESTCASE}.txt" "test/1-binary/instr_${TESTCASE}.hex.txt" "test/1-binary/data_${TESTCASE}.hex.txt" "test/4-reference/${TESTCASE}.txt")

if ls ${DIRECTORY}/mips_cpu/*.v &> /dev/null; then
  # if $DIRECTORY/mips_cpu exists, compile the stuff in it ->theres nothing here rn
     iverilog -g 2012 \
   ${DIRECTORY}/mips_cpu_*.v ${DIRECTORY}/mips_cpu/*.v test/mips_cpu_${VARIANT}_tb.v test/5-memory/*.v -s mips_cpu_${VARIANT}_tb \
   -Pmips_cpu_${VARIANT}_tb.DATA_MEM_INIT_FILE=\"test/1-binary/data_${TESTCASE}.hex.txt\" \
   -Pmips_cpu_${VARIANT}_tb.INSTR_MEM_INIT_FILE=\"test/1-binary/instr_${TESTCASE}.hex.txt\"\
   -Pmips_cpu_${VARIANT}_tb.ANSWER_FILE=\"test/4-reference/${TESTCASE}.txt\"\
   -Pmips_cpu_${VARIANT}_tb.BRANCH_JUMP_INIT_FILE=\"test/5-memory/test_loadj.txt\"\
   -o test/2-simulator/mips_cpu_${VARIANT}_tb_${TESTCASE}
else
   #this should compile stuff with mips_cpu_{variant}, currently compiles everything in the folder
   iverilog -g 2012 \
   ${DIRECTORY}/*.v test/mips_cpu_${VARIANT}_tb.v test/5-memory/*.v -s mips_cpu_${VARIANT}_tb \
   -Pmips_cpu_${VARIANT}_tb.DATA_MEM_INIT_FILE=\"test/1-binary/data_${TESTCASE}.hex.txt\" \
   -Pmips_cpu_${VARIANT}_tb.INSTR_MEM_INIT_FILE=\"test/1-binary/instr_${TESTCASE}.hex.txt\"\
   -Pmips_cpu_${VARIANT}_tb.ANSWER_FILE=\"test/4-reference/${TESTCASE}.txt\"\
   -Pmips_cpu_${VARIANT}_tb.BRANCH_JUMP_INIT_FILE=\"test/5-memory/test_loadj.txt\"\
   -o test/2-simulator/mips_cpu_${VARIANT}_tb_${TESTCASE}
#    source directory
fi

# Run the simulator, and capture all output to a file
set +e
test/2-simulator/mips_cpu_${VARIANT}_tb_${TESTCASE} > test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.stdout
# Capture the exit code of the simulator in a variable
REG_RESULT=$?
set -e

# Check whether the simulator returned a failure code, and immediately quit
if [[ "${REG_RESULT}" -ne 0 ]] ; then
   if grep -q "correct final value" test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.stdout; then
    COMMENT+=", correct V0"
   fi
   echo "${TESTCASE} ${INSTRUCTION} Fail Failure to run ${COMMENT}"
   exit
fi

#get v0 outputs
# V0 contents 
PATTERN="TB : V0 :"
NOTHING=""
SUCCESS="success"
set +e
if grep -q "${SUCCESS}" test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.stdout; then
    REG_RESULT=0
else
    REG_RESULT=1
fi
set -e

# Based on whether differences were found, either pass or fail
if [[ "${REG_RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE} ${INSTRUCTION} Fail ${COMMENT}"
else
   echo "${TESTCASE} ${INSTRUCTION} Pass ${COMMENT}"
fi