#!/bin/bash

gcc optimized.s -o optimized
../test.py --n 100 ./optimized > ../logs/log_optimized
grep -c ../logs/log_optimized -e "\bCorrect"