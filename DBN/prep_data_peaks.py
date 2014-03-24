#-*- coding:utf-8 -*-

import theano, copy, sys, cPickle
import theano.tensor as T
import numpy as np

BORROW = True #true makes it faster with GPU
DTYPE = 'int32' #label tyoe

'''
def prep_unlabel_data(dataset, pDataFile, lDataFile, adjacent, nPeaks):
    try:
        train_x_p = np.load(dataset + "/" + pDataFile)
        train_x_l = np.load(dataset + "/" + lDataFile)
    except:
        print >> sys.stderr, "you need the .npy python arrays"
        print >> sys.stderr, "you can produce them with txt_to_numpy.py"
        print >> sys.stderr, dataset + "/" + pDataFile
        print >> sys.stderr, dataset + "/" + lDataFile
        sys.exit(-1)
    
    #print "train_x shape:", train_x.shape
        
    sample_count = len(train_x_p)
    k_count = (2 * adjacent + 1)
    dim = k_count * nPeaks
    train_x = np.zeros((sample_count, 2 * dim), dtype='float64')

    for i in xrange(k_count):
        train_x[max(0,adjacent - i):min(sample_count, sample_count - (i - adjacent)),nPeaks * i:nPeaks * (i + 1)] = train_x_p[max(0,adjacent - i):min(sample_count, sample_count - (i - adjacent)),:nPeaks]
        train_x[max(0,adjacent - i):min(sample_count, sample_count - (i - adjacent)),dim +nPeaks * i:dim + nPeaks * (i + 1)] = train_x_l[max(0,adjacent - i):min(sample_count, sample_count - (i - adjacent)),:nPeaks]
    for i in xrange(sample_count):
        train_x[i, :dim] = (train_x[i, :dim] - np.min(train_x[i, :dim])) / np.max(train_x[i, :dim]
    train_x_f = train_x
    return [train_x_f]

    
def prep_label_file(dataset, label_file):
    try:
        train_y = np.load(dataset + "/" + label_file)
    except:
        print >> sys.stderr, "you need the .npy python arrays"
        print >> sys.stderr, "you can produce them with txt_to_numpy.py"
        print >> sys.stderr, dataset + "/" + label_file
        sys.exit(-1)
        
    ### Labels (Ys)
    from collections import Counter
    c = Counter(train_y)
    to_int = dict([(k, c.keys().index(k)) for k in c.iterkeys()])
    print to_int
    to_state = dict([(c.keys().index(k), k) for k in c.iterkeys()])
    print to_state
    
    with open(dataset+'/to_int_and_to_state_dicts_tuple.pickle', 'w') as f:
        cPickle.dump((to_int, to_state), f)
    
    print "preparing / int mapping Ys"
    train_y_f = np.zeros(train_y.shape[0], dtype=DTYPE)
    for i, e in enumerate(train_y):
        train_y_f[i] = to_int[e]
    
    return [train_y_f]
'''
    
def load_label_data(dataset, valid_cv_frac=0.1, numpy_array_only=False):
    try:
        train_x = np.load(dataset + "/label_train_x.npy")
        train_y = np.load(dataset + "/label_train_y.npy")
        test_x = np.load(dataset + "/label_test_x.npy")
        test_y = np.load(dataset + "/label_test_y.npy")
    except:
        print >> sys.stderr, "you need the .npy python arrays"
        print >> sys.stderr, "you can produce them with txt_to_npy.py"
        print >> sys.stderr, dataset + "/label_train_x.npy"
        print >> sys.stderr, dataset + "/label_train_y.npy"
        print >> sys.stderr, dataset + "/label_test_x.npy"
        print >> sys.stderr, dataset + "/label_test_y.npy"
        sys.exit(-1)
        
    
    ''' 
    params:
     - dataset: folder
     - nframes: number of frames to replicate/pad
     - features: 'MFCC' (13 + D + A = 39) || 'fbank' (40 coeffs filterbanks) 
                 || 'gamma' (50 coeffs gammatones)
     - scaling: 'none' || 'unit' (put all the data into [0-1])
                || 'normalize' ((X-mean(X))/std(X))
                || student ((X-mean(X))/std(X, deg_of_liberty=1))
     - pca_whiten: not if 0, MLE if < 0, number of components if > 0
     - cv_frac: cross validation fraction on the train set
     - dataset_name: prepended to the name of the serialized stuff
     - speakers: if true, Ys (labels) are speakers instead of phone's states
    """
    """
    params = {'scaling': scaling,
              'valid_cv_frac': valid_cv_frac,
              'test_cv_frac': test_cv_frac,
              'theano_borrow?': BORROW,
              'use_caching?': USE_CACHING}
    '''    
    
    print 'train_x shape before cross validation:',train_x.shape
    #print 'train_y shape before cross validation:',train_y.shape
    
    from collections import Counter
    c = Counter(train_y)
    print 'original train_y size:',len(c)
    
    to_int = dict([(k, c.keys().index(k)) for k in c.iterkeys()])
    to_state = dict([(c.keys().index(k), k) for k in c.iterkeys()])
    
    with open(dataset + '_to_int_and_to_state_dicts_tuple.pickle', 'w') as f:
        cPickle.dump((to_int, to_state), f)
        
    print "preparing / int mapping Ys"
    train_y_f = np.zeros(train_y.shape[0], dtype=DTYPE)
    for i, e in enumerate(train_y):
        train_y_f[i] = to_int[e]
        
    test_y_f = np.zeros(test_y.shape[0], dtype=DTYPE)
    for i, e in enumerate(test_y):
        test_y_f[i] = to_int[e]
    
    from sklearn import cross_validation 
    X_train, X_validate, y_train, y_validate = cross_validation.train_test_split(train_x, train_y_f, test_size=valid_cv_frac, random_state=0)
    
    
    c_train = Counter(y_train)
    c_valid = Counter(y_validate)
    c_test = Counter(test_y_f)

    print 'Counter y_train size:',len(c_train)
    #print c_train
    print 'Counter y_validate size:',len(c_valid)
    #print c_valid
    print 'Counter y_test size:',len(c_test)
    #print c_test
    
    print 'X_train shape',X_train.shape
    print 'y_train shape',y_train.shape
    print 'X_validate shape',X_validate.shape
    print 'y_validate shape',y_validate.shape
    
    if numpy_array_only:
        train_set_x = X_train
        train_set_y = np.asarray(y_train, dtype='int32')
        val_set_x = X_validate
        val_set_y = np.asarray(y_validate, dtype='int32')
        test_set_x = test_x
        test_set_y = np.asarray(test_y_f, dtype='int32')
    else:
        train_set_x = theano.shared(X_train, borrow=BORROW)
        train_set_y = theano.shared(np.asarray(y_train, dtype=theano.config.floatX), borrow=BORROW)
        train_set_y = T.cast(train_set_y, 'int32')
        val_set_x = theano.shared(X_validate, borrow=BORROW)
        val_set_y = theano.shared(np.asarray(y_validate, dtype=theano.config.floatX), borrow=BORROW)
        val_set_y = T.cast(val_set_y, 'int32')
        test_set_x = theano.shared(test_x, borrow=BORROW)
        test_set_y = theano.shared(np.asarray(test_y_f, dtype=theano.config.floatX), borrow=BORROW)
        test_set_y = T.cast(test_set_y, 'int32')

    return [(train_set_x, train_set_y), 
            (val_set_x, val_set_y),
            (test_set_x, test_set_y)] 

def load_unlabel_data(dataset, numpy_array_only=False):
    try:
        train_x = np.load(dataset + "/unlabel_train_x.npy")
    except:
        print >> sys.stderr, "you need the .npy python arrays"
        print >> sys.stderr, "you can produce them with txt_to_npy.py"
        print >> sys.stderr, dataset + "/unlabel_train_x.npy"
        sys.exit(-1)
    
    print 'train_x shape before cross validation:',train_x.shape
    
    if numpy_array_only:
        train_set_x = train_x
    else:
        train_set_x = theano.shared(train_x, borrow=BORROW)

    return [train_set_x] 
if __name__ == '__main__':
    load_label_data('./data')
    load_unlabel_data('./data')
    