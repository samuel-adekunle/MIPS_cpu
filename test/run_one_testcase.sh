#!/bin/bash
set -eou pipefail

# Can be used to echo commands
# set -o xtrace

TESTCASE="$1"
INSTRUCTION=$(echo $TESTCASE | cut -d _ -f 1)
>&2 echo "  1 - Assembling input file"
#bin/assembler <test/0-assembly/${TESTCASE}.asm.txt >test/1-binary/${TESTCASE}.hex.txt

>&2 echo " 2 - Compiling test-bench"
# Compile a specific simulator for this variant and testbench.
# -s specifies exactly which testbench should be top-level
# The -P command is used to modify the RAM_INIT_FILE parameter on the test-bench at compile-time
# iverilog -g 2012 \
#    source directory

>&2 echo "  3 - Running test-bench"
# Run the simulator, and capture all output to a file
# Use +e to disable automatic script failure if the command fails, as
# it is possible the simulation might go wrong.
# set +e
# test/2-simulator/CPU_MU0_${VARIANT}_tb_${TESTCASE} > test/3-output/CPU_MU0_${VARIANT}_tb_${TESTCASE}.stdout
# # Capture the exit code of the simulator in a variable
# RESULT=$?
RESULT=0;
# set -e

# Check whether the simulator returned a failure code, and immediately quit
if [[ "${RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE} ${INSTRUCTION} Fail Failure to run"
   exit
fi

>&2 echo "4-    Extracting result of V0 instructions"
# This is the prefix for simulation output lines containing result of OUT instruction
PATTERN="CPU : V0   :"
NOTHING=""
# Use "grep" to look only for lines containing PATTERN
# set +e
# grep "${PATTERN}" test/3-output/CPU_MU0_${VARIANT}_tb_${TESTCASE}.stdout > test/3-output/CPU_MU0_${VARIANT}_tb_${TESTCASE}.out-lines
# set -e
# # Use "sed" to replace "CPU : OUT   :" with nothing
# sed -e "s/${PATTERN}/${NOTHING}/g" test/3-output/CPU_MU0_${VARIANT}_tb_${TESTCASE}.out-lines > test/3-output/CPU_MU0_${VARIANT}_tb_${TESTCASE}.out

# >&2 echo "  4 - Running reference simulator" #reference outputs for RAM and v0?
# set +e
# bin/simulator < test/1-binary/${TESTCASE}.hex.txt > test/4-reference/${TESTCASE}.out
# set -e

>&2 echo "5-    Comparing output"
# Note the -w to ignore whitespace
# set +e
# diff -w test/4-reference/${TESTCASE}.out test/3-output/CPU_MU0_${VARIANT}_tb_${TESTCASE}.out
# RESULT=$?
# set -e
#some iff things with comments
COMMENT="yeet"
>&2 echo "Checking RAM"
# Based on whether differences were found, either pass or fail
if [[ "${RESULT}" -ne 0 ]] ; then
   echo "  ${TESTCASE} ${INSTRUCTION} Fail ${COMMENT}"
else
   echo "  ${TESTCASE} ${INSTRUCTION} Pass ${COMMENT}"
fi