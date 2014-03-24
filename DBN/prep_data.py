#-*- coding:utf-8 -*-

import theano, copy, sys, json, cPickle
import theano.tensor as T
import numpy as np

BORROW = True #true makes it faster with GPU
USE_CACHING = False
DTYPE = 'int32' #label tyoe

def prep_data(dataset, dataFile, labelFile, scaling='normalize'):
    try:
        train_x = np.load(dataset + "/" + dataFile)
        train_y = np.load(dataset + "/" + labelFile)
    except:
        print >> sys.stderr, "you need the .npy python arrays"
        print >> sys.stderr, "you can produce them with txt_to_numpy.py"
        print >> sys.stderr, dataset + "/" + dataFile
        print >> sys.stderr, dataset + "/" + labelFile
        sys.exit(-1)
    
    print "train_x shape:", train_x.shape
    
    if scaling == 'unit':
        ### Putting values on [0-1]
        train_x = (train_x - np.min(train_x, 0)) / np.max(train_x, 0)
    elif scaling == 'normalize':
        ### Normalizing (0 mean, 1 variance)
        # TODO or do that globally on all data (but that would mean to know
        # the test set and this is cheating!)
        train_x = (train_x - np.mean(train_x, 0)) / np.std(train_x, 0)
    elif scaling == 'student':
        ### T-statistic
        train_x = (train_x - np.mean(train_x, 0)) / np.std(train_x, ddof=1)
    train_x_f = train_x
    
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
    
    return [train_x_f, train_y_f]
    
def load_data(dataset, dataFile, labelFile, scaling='normalize', valid_cv_frac=0.1, test_cv_frac=0.5, numpy_array_only=False):
     """ 
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
    """    
    
    def prep_and_serialize():
        [train_x, train_y] = prep_data(dataset, dataFile, labelFile, scaling=scaling)
        with open(dataset+'/train_x_' + scaling + '.npy', 'w') as f:
            np.save(f, train_x)
        with open(dataset+'/train_y_' + scaling + '.npy', 'w') as f:
            np.save(f, train_y)
        print ">>> Serialized all train/test tables"
        return [train_x, train_y]
    
    if USE_CACHING:
        try: # try to load from serialized filed, beware
            with open(dataset+'/train_x_' + scaling + '.npy') as f:
                train_x = np.load(f)
            with open(dataset+'/train_y_' + scaling + '.npy') as f:
                train_y = np.load(f)
        except: # do the whole preparation (normalization / padding)
            [train_x, train_y] = prep_and_serialize()
    else:
        [train_x, train_y] = prep_and_serialize()
    
    print 'train_x shape before cross validation:',train_x.shape
    print 'train_y shape before cross validation:',train_y.shape
    from collections import Counter
    c = Counter(train_y)
    print 'original train_y size:',len(c)
    
    from sklearn import cross_validation 
    X_train, X_validate, y_train, y_validate = cross_validation.train_test_split(train_x, train_y, test_size=valid_cv_frac, random_state=0)
    X_train1, X_test, y_train1, y_test = cross_validation.train_test_split(train_x, train_y, test_size=test_cv_frac, random_state=0)
    
    c_train = Counter(y_train)
    c_valid = Counter(y_validate)
    c_test = Counter(y_test)
    
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
    print 'X_test shape',X_test.shape
    print 'y_test shape',y_test.shape
    
    if numpy_array_only:
        train_set_x = X_train
        train_set_y = np.asarray(y_train, dtype=DTYPE)
        val_set_x = X_validate
        val_set_y = np.asarray(y_validate, dtype=DTYPE)
        test_set_x = X_test
        test_set_y = np.asarray(y_test, dtype=DTYPE)
    else:
        train_set_x = theano.shared(X_train, borrow=BORROW)
        train_set_y = theano.shared(np.asarray(y_train, dtype=theano.config.floatX), borrow=BORROW)
        train_set_y = T.cast(train_set_y, DTYPE)
        val_set_x = theano.shared(X_validate, borrow=BORROW)
        val_set_y = theano.shared(np.asarray(y_validate, dtype=theano.config.floatX), borrow=BORROW)
        val_set_y = T.cast(val_set_y, DTYPE)
        test_set_x = theano.shared(X_test, borrow=BORROW)
        test_set_y = theano.shared(np.asarray(y_test, dtype=theano.config.floatX), borrow=BORROW)
        test_set_y = T.cast(test_set_y, DTYPE)

    return [(train_set_x, train_set_y), 
            (val_set_x, val_set_y),
            (test_set_x, test_set_y)] 

if __name__ == '__main__':
    load_data('./data')