#!/bin/bash
time test/test_mips_cpu_harvard.sh rtl | tee failed_tests.txt
TESTCASES=$(wc -l failed_tests.txt | awk '{ print $1 }')
grep -v "Pass" failed_tests.txt > mtests.txt; mv mtests.txt failed_tests.txt
FAILS=$(wc -l failed_tests.txt | awk '{ print $1 }')
echo ""
echo "Failed: ${FAILS} / ${TESTCASES} testcases"
echo ""
echo "Please Check: "
cat failed_tests.txt