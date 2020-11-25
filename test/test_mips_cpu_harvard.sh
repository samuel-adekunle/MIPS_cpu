#!/bin/bash
set -eou pipefail
VARIANT="harvard"
DIRECTORY="$1"
FLAGS="-g 2012 -Wall"

if [ $# -ge 2 ]
then
    TESTCASE="$2"
    #test for one
else
    #test all


fi