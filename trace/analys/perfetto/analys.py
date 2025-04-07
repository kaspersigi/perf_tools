#!/usr/bin/python3
# -*- coding: utf-8 -*-

'''
pip3 install perfetto
py -3 analys.py -f redmi.perfetto-trace
'''

import logging
import sys
from getopt import getopt
from pathlib import Path
from pprint import pprint
from protos import perfetto_trace_pb2

def read_perfetto(filename):
    with open(filename, 'rb') as f:
        serialized_data = f.read()

    trace = perfetto_trace_pb2.Trace()
    trace.ParseFromString(serialized_data)

    return trace

def traverse_ftrace_event(trace):
    i = 0
    for packet in trace.packet:
        print("------------------------------")
        print("packet:", i)
        i = i + 1
        which_oneof = packet.WhichOneof('data')
        if which_oneof == 'ftrace_events':
            for event in packet.ftrace_events.event:
                which_oneof = event.WhichOneof('event')
                if which_oneof == 'print':
                    pprint(event.print.buf)

def main():
    opt, filenames = getopt(sys.argv[1:], 'f', ['file'])
    if not filenames:
        logging.error("please input a filename!")
        return
    for filename in filenames:
        logging.debug("input file: " + filename)
        file_path = Path(filename)
        if not file_path.exists():
            logging.error(filename + ": not exist!")
            return
        if not file_path.is_file():
            logging.error(filename + ": not regular file!")
            return
        trace = read_perfetto(filename)
        traverse_ftrace_event(trace)

if __name__ == '__main__':
    main()