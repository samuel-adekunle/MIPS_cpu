#!/bin/bash
set -eou pipefail

# Can be used to echo commands
# set -o xtrace
DIRECTORY="$1"
TESTCASE="$2"
INSTRUCTION=$(echo $TESTCASE | cut -d _ -f 1)
FLAGS="-g 2012 -Wall"
VARIANT="harvard"

##assemble test case
#bin/assembler <test/0-assembly/${TESTCASE}.asm.txt >test/1-binary/${TESTCASE}.hex.txt
./test/test_cases "test/0-cases/${TESTCASE}.txt" "test/1-binary/instr_${TESTCASE}.hex.txt" "test/1-binary/data_${TESTCASE}.hex.txt" "test/4-reference/${TESTCASE}.txt"
##compile test bench
# iverilog -g 2012 \
#    ${DIRECTORY}/*.v test/*.v  -s mips_cpu_${VARIANT}_tb \
#    -Pmips_cpu_${VARIANT}_tb.RAM_INIT_FILE=\"test/1-binary/${TESTCASE}.hex.txt\" \
#    -o test/2-simulator/mips_cpu_${VARIANT}_tb_${TESTCASE}
iverilog -g 2012 \
   ${DIRECTORY}/*.v test/*.v test/5-memory/*.v -s mips_cpu_${VARIANT}_tb \
   -Pmips_cpu_${VARIANT}_tb.DATA_MEM_INIT_FILE=\"test/1-binary/data_${TESTCASE}.hex.txt\" \
   -Pmips_cpu_${VARIANT}_tb.INSTR_MEM_INIT_FILE=\"test/1-binary/instr_${TESTCASE}.hex.txt\"\
   -o test/2-simulator/mips_cpu_${VARIANT}_tb_${TESTCASE}
#    source directory

# Run the simulator, and capture all output to a file
set +e
test/2-simulator/mips_cpu_${VARIANT}_tb_${TESTCASE} > test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.stdout
# Capture the exit code of the simulator in a variable
REG_RESULT=$?
set -e

# Check whether the simulator returned a failure code, and immediately quit
if [[ "${REG_RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE} ${INSTRUCTION} Fail Failure to run"
   exit
fi

#get v0 outputs
# V0 contents 
PATTERN="CPU : V0 :"
NOTHING=""
# Use "grep" to look only for lines containing PATTERN
set +e
grep "${PATTERN}" test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.stdout > test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.out-lines
set -e
# Use "sed" to replace "CPU : V0   :" with nothing
sed -e "s/${PATTERN}/${NOTHING}/g" test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.out-lines > test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.out

# >&2 echo "  4 - Running reference simulator" #reference outputs for RAM and v0?
# set +e
# bin/simulator < test/1-binary/${TESTCASE}.hex.txt > test/4-reference/${TESTCASE}.out
# set -e

##compare v0 results
set +e
diff -w test/4-reference/${TESTCASE}.out test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.out &>/dev/null
REG_RESULT=$?
set -e
#some iff things with comments
if [[ "${REG_RESULT}" -ne 0 ]] ; then
   COMMENT=" Error in output"
fi

##check some stuff in RAM
# set +e
# diff -w test/4-reference/${TESTCASE}.out test/3-output/mips_cpu_${VARIANT}_tb_${TESTCASE}.out &>/dev/null
# MEM_RESULT=$?
# set -e
# if [[ "${MEM_RESULT}" -ne 0 ]] ; then
#    COMMENT+=" Error in RAM"
# fi



# Based on whether differences were found, either pass or fail
if [[ "${REG_RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE} ${INSTRUCTION} Fail ${COMMENT}"
else
   echo "${TESTCASE} ${INSTRUCTION} Pass ${COMMENT}"
fi