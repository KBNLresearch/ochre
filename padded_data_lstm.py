import numpy as np
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers import LSTM
from keras.layers import TimeDistributed

from keras.callbacks import ModelCheckpoint
from keras.utils import np_utils

import click
import os
import codecs
import glob2
import glob
import json


def initialize_model(n, dropout, seq_length, chars, output_size, layers,
                     loss='categorical_crossentropy', optimizer='adam'):
    model = Sequential()
    model.add(LSTM(n, input_shape=(seq_length, len(chars)), return_sequences=True))
    model.add(Dropout(dropout))

    for _ in range(layers-1):
        model.add(LSTM(n, return_sequences=True))
        model.add(Dropout(dropout))

        model.add(TimeDistributed(Dense(len(chars), activation='softmax')))

        model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

    return model


def load_weights(model, weights_dir, loss='categorical_crossentropy',
                 optimizer='adam'):
    weight_files = glob2.glob('{}{}*.hdf5'.format(weights_dir, os.sep))
    if weight_files != []:
        fname = sorted(weight_files)[-1]
        print('Loading weights from {}'.format(fname))

        model.load_weights(fname)
        model.compile(loss=loss, optimizer=optimizer)

    return model


def create_data(ocr_texts, gs_texts, char_to_int, n_vocab, seq_length=25):
    """Create padded one-hot encoded data sets from text.

    A sample consists of seq_length characters from texts from ocr_texts
    (includes empty characters) (input), and seq_length characters from
    gs_texts (includes empty characters) (output).
    ocr_texts and gs_tetxts contain aligned arrays of characters.
    Because of the empty characters ('' in the character arrays), the input
    and output sequences may not have equal length. Therefore input and
    output are padded with a padding character (newline).
    """
    dataX = []
    dataY = []
    for ocr, gs in zip(ocr_texts, gs_texts):
        text_length = len(ocr)
        for i in range(0, text_length-seq_length +1, 1):
            seq_in = ocr[i:i+seq_length]
            seq_out = gs[i:i+seq_length]
            dataX.append(''.join(seq_in))
            dataY.append(''.join(seq_out))
    X = np.zeros((len(dataX), seq_length, n_vocab), dtype=np.bool)
    Y = np.zeros((len(dataY), seq_length, n_vocab), dtype=np.bool)

    for i, sentence in enumerate(dataX):
        for j, c in enumerate(sentence):
            X[i, j, char_to_int[c]] = 1
        for j in range(seq_length-len(sentence)):
            X[i, len(sentence) + j, char_to_int[u'\n']] = 1
            #print len(sentence)+j
        #print X[i]
        #print X[i].shape

    for i, sentence in enumerate(dataY):
        #print sentence
        for j, c in enumerate(sentence):
            Y[i, j, char_to_int[c]] = 1
        for j in range(seq_length-len(sentence)):
            Y[i, len(sentence)+j, char_to_int[u'\n']] = 1
        #print Y[i]
        #print Y[i].shape
    return X, Y


@click.command()
@click.argument('text_dir', type=click.Path(exists=True))
@click.option('--weights_dir', '-w', default=os.getcwd(), type=click.Path())
def train_lstm(text_dir, weights_dir):
    # lees data in en maak character mappings
    # genereer trainings data
    seq_length = 25
    num_nodes = 256
    layers = 2

    data_files = glob.glob('{}/BAO*.json'.format(text_dir))
    print data_files

    print('Number of texts: {}'.format(len(data_files)))

    ocr_texts = []
    gs_texts = []

    raw_text = []

    for df in data_files:
        with codecs.open(df, encoding='utf-8') as f:
            aligned = json.load(f)

            ocr_texts.append(aligned['ocr'])
            gs_texts.append(aligned['gs'])

            raw_text.append(''.join(aligned['ocr']))
            raw_text.append(''.join(aligned['gs']))

    raw_text = ' '.join(raw_text)

    chars = sorted(list(set(raw_text)))
    chars.append(u'\n')                      # padding character
    char_to_int = dict((c, i) for i, c in enumerate(chars))

    n_chars = len(raw_text)
    n_vocab = len(chars)

    print('Total Characters: {}'.format(n_chars))
    print('Total Vocab: {}'.format(n_vocab))

    # divide texts in train and validation set
    c = zip(ocr_texts, gs_texts)
    np.random.seed(4)
    np.random.shuffle(c)
    ocr_texts_shuffled, gs_texts_shuffled = zip(*c)

    n = len(ocr_texts) / 10 / 2

    ocr_validation_texts = ocr_texts_shuffled[0:n]
    ocr_test_texts = ocr_texts_shuffled[n:n+n]
    ocr_train_texts = ocr_texts_shuffled[n+n:]

    gs_validation_texts = gs_texts_shuffled[0:n]
    gs_test_texts = gs_texts_shuffled[n:n+n]
    gs_train_texts = gs_texts_shuffled[n+n:]

    xTrain, yTrain = create_data(ocr_train_texts, gs_train_texts, char_to_int, n_vocab, seq_length=seq_length)
    xTest, yTest = create_data(ocr_test_texts, gs_test_texts, char_to_int, n_vocab, seq_length=seq_length)
    xVal, yVal = create_data(ocr_validation_texts, gs_validation_texts, char_to_int, n_vocab, seq_length=seq_length)

    n_patterns = len(xTrain)
    print("Train Patterns: {}".format(n_patterns))
    print("Validation Patterns: {}".format(len(xVal)))
    print("Test Patterns: {}".format(len(xTest)))
    print('Total: {}'.format(len(xTrain) + len(xVal) + len(xTest)))

    model = initialize_model(num_nodes, 0.5, seq_length, chars, n_vocab, layers)
    model = load_weights(model, weights_dir)

    # initialize saving of weights
    filepath = os.path.join(weights_dir, '{loss:.4f}.hdf5')
    checkpoint = ModelCheckpoint(filepath, monitor='loss', verbose=1,
                                 save_best_only=True, mode='min')
    callbacks_list = [checkpoint]

    # do training (and save weights)
    model.fit(xTrain, yTrain, batch_size=100, epochs=15, validation_data=(xVal, yVal), callbacks=callbacks_list)


if __name__ == '__main__':
    train_lstm()
