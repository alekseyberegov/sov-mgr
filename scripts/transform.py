#!/usr/bin/python3

import argparse
import csv

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--columns", type=str, help="filter columns by index")
parser.add_argument("-r", "--reorder", type=str, help="re-order columns by index")
parser.add_argument("-n", "--nan", type=str, help="replace #N/A #DIV/0!")
parser.add_argument("-p", "--prepand", type=str, help="prepend values")
parser.add_argument('file', type=argparse.FileType('r'))

args = parser.parse_args()

prepand = args.prepand.split(',') if args.prepand is not None else None
columns = list(map(int, args.columns.split(','))) if args.columns is not None else None
reorder = list(map(int, args.reorder.split(','))) if args.reorder is not None else None

with args.file as fd:
    reader = csv.reader(fd, delimiter=',')
    for row in reader:
        output = []
        # prepand columns
        if prepand is not None:
            output.extend(prepand)
        # filter columnns
        for i, c in enumerate(row):
            if columns is None or i in columns:
                if c.find(',') != -1:
                    c = '"' + c + '"'
                if c == '#N/A' or c == '#DIV/0!':
                    if args.nan is not None:
                        c = args.nan
                output.append(c)
        # re-order columns
        if reorder is not None:
            output = [output[i] for i in reorder]
        print(",".join(output))
