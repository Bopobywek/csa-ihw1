#!/bin/bash

gcc optimized.s -o optimized
../test.py --n 100 ./optimized > log
grep -c log -e "\bCorrect"
