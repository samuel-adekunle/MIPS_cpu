#!/bin/bash
VARIANT="$1"
time test/test_mips_cpu_${VARIANT}.sh avalon_bus | tee failed_tests.txt
TESTCASES=$(wc -l failed_tests.txt | awk '{ print $1 }')
grep -v "Pass" failed_tests.txt >mtests.txt
mv mtests.txt failed_tests.txt
FAILS=$(wc -l failed_tests.txt | awk '{ print $1 }')
echo ""
echo "Failed: ${FAILS} / ${TESTCASES} testcases"
echo ""
echo "Please Check: "
cat failed_tests.txt

rm -rf test/1-binary/*.hex.txt
rm -rf test/4-reference/*.txt
rm -rf test/2-simulator/mips*
rm -rf test/3-output/*stdout
rm -rf test/0-cases/*r3.txt
rm -rf test/0-cases/*r2.txt
rm -rf test/0-cases/*r1.txt
rm -rf test/0-cases/*r3a.txt
rm -rf test/0-cases/*r2a.txt
rm -rf test/0-cases/*r1a.txt
rm -rf test/0-cases/*r3b.txt
rm -rf test/0-cases/*r2b.txt
rm -rf test/0-cases/*r1b.txt