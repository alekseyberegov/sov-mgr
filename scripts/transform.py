#!/usr/bin/python3

import argparse
import csv

parser = argparse.ArgumentParser()
parser.add_argument('file', type=argparse.FileType('r'))
parser.add_argument("-v", "--verbose", action="store_true", help="increase output verbosity")
parser.add_argument("-c", "--columns", type=str, help="filter columns by index")
parser.add_argument("-n", "--nan", type=str, help="replace #N/A #DIV/0!")
parser.add_argument("-p", "--prepand", type=str, help="prepend values")

args = parser.parse_args()

all_columns = args.columns is None or args.columns == "*"
if not all_columns:
    columns = list(map(int, args.columns.split(',')))

prepand = args.prepand.split(',') if args.prepand is not None else None

with args.file as fd:
    reader = csv.reader(fd, delimiter=',')
    for row in reader:
        output = []
        if prepand is not None:
            output.extend(prepand)
        for i, c in enumerate(row):
            if all_columns or i in columns:
                if c.find(',') != -1:
                    c = '"' + c + '"'
                if c == '#N/A' or c == '#DIV/0!':
                    if args.nan is not None:
                        c = args.nan
                output.append(c)
        print(",".join(output))
