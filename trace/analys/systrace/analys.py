#!/usr/bin/python3
# -*- coding: utf-8 -*-

'''
pip3 install perfetto
py -3 analys.py -f redmi.perfetto-trace
'''

import logging
import os
import re
import sys
import time
from getopt import getopt
from pathlib import Path
from pprint import pprint

pattern = r"^ +(.+)\-(\d+) +\( *(\S+)\) +\[(\d+)\] +(\S+) +(\d+\.\d+): +([a-zA-Z0-9_]+): *(.*)$"

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
    trace = {}
    with open(filename, 'r') as file:
        i = 0
        for line in file:
            match = re.search(pattern, line)
            if match:
                task = match.group(1)
                pid = match.group(2)
                tgid = match.group(3)
                cpu = match.group(4)
                delay = match.group(5)
                timestamp = match.group(6)
                function = match.group(7)
                message = match.group(8)
                pid = int(pid)
                if '-----' == tgid:
                    tgid = -1
                trace[i] = {'task':task,
                            'pid':pid,
                            'tgid':tgid,
                            'cpu':cpu,
                            'delay':delay,
                            'timestamp':timestamp,
                            'function':function,
                            'message':message}
                i = i + 1
            else:
                pprint(line)
    return trace

def print_trace(trace):
    elapse = Elapse(sys._getframe().f_code.co_name)
    for key, value in trace.items():
        line = "[{}][{}][{}][{}][{}][{}][{}][{}][{}]".format(
            key,
            value['task'],
            value['pid'],
            value['tgid'],
            value['cpu'],
            value['delay'],
            value['timestamp'],
            value['function'],
            value['message'])
        print(line)

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
            cmd = "py -3 traceconv systrace {} {}".format(perfetto, systrace)
            print(cmd)
            os.system(cmd)
        trace = preprocess(systrace)
        print_trace(trace)

if __name__ == '__main__':
    main()