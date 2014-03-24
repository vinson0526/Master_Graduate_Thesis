#-*- coding:utf-8 -*-
"""


"""
DATASET = './data'

import gzip
import sys
import numpy as np
reload(sys)
sys.setdefaultencoding('utf-8')

def extract_data_use_only_one_frame_fft(txt, npy):
    data_file = open(txt)
    x = []
    dim = 0
    count_line = 0
    for line in data_file:
        line = line.rstrip('\n')
        if len(line) < 1:
            continue
        if count_line == 0: 
            dim = (int)(line)
            print 'Dimenation:',line
            x = np.ndarray((0, dim), dtype='float64')
        else:
            items = line.split()
            for i in range(0,len(items)):
                items[i] = float(items[i])
            if len(items) != dim:
                print 'line:',count_line,'has',len(items),'items instead of',dim
                continue
            one_sample = np.array([items])
            one_sample = one_sample.astype('f', copy = False)
            x = np.append(x, one_sample, axis = 0)
        count_line += 1
    np.save(npy, x)
    
    print "data:", x
    print "the number of samples:", len(x)
    print "data shape:", x.shape
    print ''
    
def extract_data_from_fft_peaks(pfile_txt, lfile_txt, pfile_npy, lfile_npy):
    extract_data_use_only_one_frame_fft(pfile_txt, pfile_npy)
    extract_data_use_only_one_frame_fft(lfile_txt, lfile_npy)
             
def extract_data_from_txt(txt, npy, txt2 = 'C:/nofile', npy2 = 'C:/nofile', flag = 0):
    if flag == 0:
        extract_data_use_only_one_frame_fft(txt, npy)
    elif flag == 1:
        extract_data_from_fft_peaks(txt, txt2, npy, npy2)
    else:
        pass

def extract_label_from_txt(txt, npy):
    label_file = open(txt)
    y = []
    count_line = 0
    dim = 1
    #y = np.ndarray((0, dim), dtype='int32')
    
    for line in label_file:
        line = line.rstrip('\n')
        if len(line) < 1:
            continue
        items = line.split()
        print "items:", items
        if len(items) != dim:
            print 'line:',count_line,'has',len(items),'items instead of',dim
            continue
        one_label = items[0]
        print "label", count_line, ":", one_label
        y.append(one_label)
        count_line += 1
    #yy = np.array(y)
    print y
    np.save(npy, y)
    
    #print "labels:", y
    print "the number of lebels:", len(y)
    #print "lebel shape:", y.shape
    print ''
	
def extract_filename(fname):
    left = fname.rfind('\\')+1
    right = fname.rfind('.')
    if left <= 0:
        left = 0
    if right < 0:
        right = len(fname)
		
    return fname[left:right]

if __name__ == '__main__':
    extract_data_from_txt(DATASET + '/unlabel_train_x.txt', DATASET + '/unlabel_train_x.npy')
    extract_data_from_txt(DATASET + '/label_train_x.txt', DATASET + '/label_train_x.npy')
    extract_data_from_txt(DATASET + '/label_test_x.txt', DATASET + '/label_test_x.npy')
    extract_label_from_txt(DATASET + '/label_train_y.txt', DATASET + '/label_train_y.npy')
    extract_label_from_txt(DATASET + '/label_test_y.txt', DATASET + '/label_test_y.npy')