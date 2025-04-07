#!/usr/bin/python3
# -*- coding: utf-8 -*-

'''
pip3 install perfetto
py -3 analys.py -f redmi.perfetto-trace
'''

import logging
import os
import sys
import time
from getopt import getopt
from pathlib import Path
from pprint import pprint

str = r"^ +(.+)\-(\d+) +\( *(\S+)\) +\[(\d+)\] +(\S+) +(\d+\.\d+): +([a-zA-Z0-9_]+): *(.*)$"

class Elapse:
    def __init__(self, name):
        self.name = name
        self.start = time.perf_counter()
        print(self.name, "start...")

    def __del__(self):
        self.end = time.perf_counter()
        print(self.name, "process cost time", self.end - self.start)

def preprocess(filename):
    elapse = Elapse(sys._getframe().f_code.co_name)
    with open(filename, 'r') as f:
        ...

def main():
    elapse = Elapse(sys._getframe().f_code.co_name)
    opt, filenames = getopt(sys.argv[1:], 'f', ['file'])
    if not filenames:
        logging.error("please input a filename!")
        return
    for perfetto in filenames:
        logging.debug("input file: " + perfetto)
        perfetto_path = Path(perfetto)
        if not perfetto_path.exists():
            logging.error(perfetto + ": not exist!")
            return
        if not perfetto_path.is_file():
            logging.error(perfetto + ": not regular file!")
            return
        stem = perfetto_path.stem
        systrace = stem + ".html"
        systrace_path = Path(systrace)
        if not systrace_path.exists():
            logging.info(systrace + ": not exist!")
            cmd = "./traceconv systrace {} {}".format(perfetto, systrace)
            os.system(cmd)
        preprocess(systrace)

if __name__ == '__main__':
    main()