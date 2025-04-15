#!/usr/bin/python3
# -*- coding: utf-8 -*-

'''
pip3 install perfetto
py -3 analys.py -f redmi.perfetto-trace
'''

import logging
import sys
from pathlib import Path
from pprint import pprint
from getopt import getopt
from perfetto.trace_processor import TraceProcessor

def init_trace_processor(filename):
    # Initialise TraceProcessor with a trace file
    tp = TraceProcessor(trace=filename)
    logging.debug("init TraceProcessor with file: " + filename)
    return tp

def get_process_map(tp):
    pm = {}
    qr_it = tp.query('''
        SELECT
            process.upid,
            process.pid,
            process.name AS process_name,
            thread.utid,
            thread.tid,
            thread.name AS thread_name
        FROM
            process
        RIGHT JOIN
            thread
        ON
            process.upid = thread.upid;
    ''')
    for row in qr_it:
        if pm.get(row.pid) is None:
            pm[row.pid] = [row.process_name, (row.tid, row.thread_name)]
        else:
            l = pm[row.pid]
            l.append((row.tid, row.thread_name))
            pm[row.pid] = l
    return pm

def get_thread_map(tp):
    tm = {}
    qr_it = tp.query('''
        SELECT
            process.upid,
            process.pid,
            process.name AS process_name,
            thread.utid,
            thread.tid,
            thread.name AS thread_name
        FROM
            process
        RIGHT JOIN
            thread
        ON
            process.upid = thread.upid;
    ''')
    for row in qr_it:
        tm[row.tid] = (row.thread_name, (row.pid, row.process_name))
    return tm

def get_slice_map(tp):
    sm = {}
    qr_it = tp.query('''
        SELECT
            slice.id,
            slice.ts,
            slice.dur,
            slice.name,
            arg.key,
            arg.int_value
        FROM
            slice
        LEFT JOIN
            (SELECT id, key, int_value, arg_set_id FROM args WHERE key is 'cookie') AS arg
        ON
            slice.arg_set_id = arg.arg_set_id;
    ''')
    for row in qr_it:
        sm[row.id] = (row.name, row.ts, row.dur, row.key, row.int_value)
    return sm

def find_slice_by_name(sm, name):
    for key, value in sm.items():
        if name in value[0]:
            return value

def find_slice_by_name_and_cookie(sm, name, cookie):
    for key, value in sm.items():
        if name in value[0] and value[4] is cookie:
            return value

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
        tp = init_trace_processor(filename)
        # process_map = get_process_map(tp)
        # thread_map = get_thread_map(tp)
        slice_map = get_slice_map(tp)
        down_tuple = find_slice_by_name(slice_map, "dispatchInputEvent MotionEvent ACTION_DOWN")
        up_tuple = find_slice_by_name(slice_map, "dispatchInputEvent MotionEvent ACTION_UP")
        connect_tuple = find_slice_by_name(slice_map, "connectDevice")
        config_tuple = find_slice_by_name(slice_map, "endConfigure")
        poweron_begin_tuple = find_slice_by_name(slice_map, "RealTimeMCX: Buffer Nego Forward walk")
        first_request_tuple = find_slice_by_name(slice_map, "HAL3ProcessCaptureRequest : 0")
        prepare_streamon_tuple = find_slice_by_name(slice_map, "SensorNodePrepareStreamOn")
        cslstreamon_tuple = find_slice_by_name(slice_map, "SensorNodePrepareStreamOn")
        first_frame_tuple = find_slice_by_name_and_cookie(slice_map, "frame capture", 0)
        print("{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}".format(
            "ACTION_DOWN",
            "ACTION_UP",
            "connectDevice_E",
            "connectDevice_X",
            "endConfigure_E",
            "poweron_E",
            "endConfigure_X",
            "1st_frame_E",
            "1st_request_E",
            "prepare_streamon_E",
            "prepare_streamon_X",
            "CSLStreamOn_E",
            "CSLStreamOn_X",
            "1st_frame_X"))
        array = [
            down_tuple[1],
            up_tuple[1],
            connect_tuple[1],
            connect_tuple[1]+connect_tuple[2],
            config_tuple[1],
            poweron_begin_tuple[1],
            config_tuple[1]+config_tuple[2],
            first_frame_tuple[1],
            first_request_tuple[1],
            prepare_streamon_tuple[1],
            prepare_streamon_tuple[1]+prepare_streamon_tuple[2],
            cslstreamon_tuple[1],
            cslstreamon_tuple[1]+cslstreamon_tuple[2],
            first_frame_tuple[1]+first_frame_tuple[2]]
        print("{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}".format(
            array[0],
            array[1],
            array[2],
            array[3],
            array[4],
            array[5],
            array[6],
            array[7],
            array[8],
            array[9],
            array[10],
            array[11],
            array[12],
            array[13])
        )
        print("\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t\t{}\t{}".format(
            (array[1]-array[0])/1000000,
            (array[2]-array[1])/1000000,
            (array[3]-array[2])/1000000,
            (array[4]-array[3])/1000000,
            (array[5]-array[4])/1000000,
            (array[6]-array[5])/1000000,
            (array[7]-array[6])/1000000,
            (array[8]-array[7])/1000000,
            (array[9]-array[8])/1000000,
            (array[10]-array[9])/1000000,
            (array[11]-array[10])/1000000,
            (array[12]-array[11])/1000000,
            (array[13]-array[12])/1000000,
            (array[13]-array[0])/1000000,
            (array[13]-array[1])/1000000)
        )

if __name__ == '__main__':
    main()