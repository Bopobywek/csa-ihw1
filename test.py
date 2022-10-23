#!/usr/bin/python3
import argparse
import subprocess
import random
import os
import sys
from math import log10, ceil

def get_answer(array):
    nonzero_elements = list(filter(lambda x: x != 0, array))
    min_el = min(nonzero_elements) if nonzero_elements else 0
    new_array = list(map(lambda x: min_el if x == 0 else x, array))
    return new_array

def dir_path(string):
    if not os.path.exists(string):
        raise argparse.ArgumentTypeError(f"{string} is not a valid path")
    if os.path.isdir(string):
        return string
    raise argparse.ArgumentTypeError(f"{string} is not a directory")

def run_test(path_to_executable, input_data, answer, file_in=None, file_out=None):
    process = subprocess.Popen([path_to_executable], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    process.stdin.write(input_data.encode())
    process.stdin.close()
    process.wait()
    out_data = process.stdout.readlines()[-1].decode("utf-8").strip()
    answer = answer.strip()
    print("Test:\n{}".format(input_data.strip()))
    print("Program output:\n{}".format(out_data))
    if (out_data == answer):
        print("Correct")
    else:
        print("Correct answer:\n{}".format(answer))
        print("Incorrect")
    print()

def make_test(max_size, min_size=1):
    zero_amount = random.randrange(min_size, max_size // 3)
    array_size = random.randrange(min_size, max_size - zero_amount + 1)
    zeroes = [0 for _ in range(array_size)]
    array = [int(random.gauss(0, 100)) for _ in range(array_size)] 
    array = array + zeroes
    if (min(array) == 0 and max(array) == 0):
        array.append(random.randrange(1, 100))
    random.shuffle(array)
    
    return array

def get_test_name(test_idx, size):
    name = str(test_idx).zfill(ceil(log10(size)))
    return name

def save_test(directory, name, test_data, test_answer):
    with open(os.path.join(directory, name), mode="w") as fout:
        fout.write(test_data)

    with open(os.path.join(directory, "{}.a".format(name)), mode="w") as fout:
        fout.write(test_answer)

parser = argparse.ArgumentParser()

parser.add_argument("executable", help="path to executable file")
parser.add_argument("--n", dest="size", default=5, type=int, help="Number of test cases")
parser.add_argument("--mx", dest="max_array_size", default=10, type=int)
parser.add_argument("-s", dest="save", type=dir_path,
                    help="Save tests in the passed directory")
parser.add_argument("-t", dest="tests_dir", type=dir_path,
                    help="Directory with tests. Tests from there will be used")
parser.add_argument("-f", action="store_true", help="Use the file for input/output")
parser.add_argument("--seed", type=int, default=42)
args = parser.parse_args()

random.seed(args.seed)

if (args.tests_dir):
    for filename in os.listdir(args.tests_dir):
        if (filename.endswith(".a")):
            continue
        with open(os.path.join(args.tests_dir, filename), mode="r") as fin:
            test_data = fin.read()
        with open(os.path.join(args.tests_dir, "{}.a".format(filename)), mode="r") as fin:
            test_answer = fin.read()
        run_test(args.executable, test_data, test_answer)
    sys.exit(0)

for idx in range(args.size):
    test_data = make_test(args.max_array_size)
    test_answer = get_answer(test_data)
    input_data = "{}\n{}\n".format(len(test_data), " ".join(str(x) for x in test_data))
    output_data = "{}\n".format(" ".join(str(x) for x in test_answer))
    run_test(args.executable, input_data, output_data)
    if (args.save):
        save_test(args.save, get_test_name(idx, args.size), input_data, output_data)

