import numpy as np
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers import LSTM
from keras.layers import TimeDistributed
from keras.layers import Bidirectional
from keras.layers import RepeatVector

import os
import codecs
import glob2
import json
import re


def initialize_model(n, dropout, seq_length, chars, output_size, layers,
                     loss='categorical_crossentropy', optimizer='adam'):
    model = Sequential()
    model.add(LSTM(n, input_shape=(seq_length, len(chars)),
              return_sequences=True))
    model.add(Dropout(dropout))

    for _ in range(layers-1):
        model.add(LSTM(n, return_sequences=True))
        model.add(Dropout(dropout))

    model.add(TimeDistributed(Dense(len(chars), activation='softmax')))

    model.compile(loss=loss, optimizer=optimizer, metrics=['accuracy'])

    return model


def initialize_model_bidirectional(n, dropout, seq_length, chars, output_size,
                                   layers, loss='categorical_crossentropy',
                                   optimizer='adam'):
    model = Sequential()
    model.add(Bidirectional(LSTM(n, return_sequences=True),
                            input_shape=(seq_length, len(chars))))
    model.add(Dropout(dropout))

    for _ in range(layers-1):
        model.add(Bidirectional(LSTM(n, return_sequences=True)))
        model.add(Dropout(dropout))

    model.add(TimeDistributed(Dense(len(chars), activation='softmax')))

    model.compile(loss=loss, optimizer=optimizer, metrics=['accuracy'])

    return model


def initialize_model_seq2seq(n, dropout, seq_length, output_size, layers,
                             loss='categorical_crossentropy', optimizer='adam',
                             metrics=['accuracy']):
    model = Sequential()
    # encoder
    model.add(LSTM(n, input_shape=(seq_length, output_size)))
    # For the decoder's input, we repeat the encoded input for each time step
    model.add(RepeatVector(seq_length))
    # The decoder RNN could be multiple layers stacked or a single layer
    for _ in range(layers-1):
        model.add(LSTM(n, return_sequences=True))

    # For each of step of the output sequence, decide which character should be
    # chosen
    model.add(TimeDistributed(Dense(output_size, activation='softmax')))
    model.compile(loss=loss, optimizer=optimizer, metrics=metrics)

    return model


def load_weights(model, weights_dir, loss='categorical_crossentropy',
                 optimizer='adam'):
    epoch = 0
    weight_files = glob2.glob('{}{}*.hdf5'.format(weights_dir, os.sep))
    if weight_files != []:
        fname = sorted(weight_files)[0]
        print('Loading weights from {}'.format(fname))

        model.load_weights(fname)
        model.compile(loss=loss, optimizer=optimizer, metrics=['accuracy'])

        m = re.match(r'.+-(\d\d).hdf5', fname)
        if m:
            epoch = int(m.group(1))

    return epoch, model


def to_string(char_list, lowercase):
    if lowercase:
        return u''.join(char_list).lower()
    return u''.join(char_list)


def create_synced_data(ocr_text, gs_text, char_to_int, n_vocab, seq_length=25,
                       batch_size=100, padding_char=u'\n', lowercase=False,
                       step=1):
    """Create padded one-hot encoded data sets from text.

    A sample consists of seq_length characters from ocr_text
    (includes empty characters) (input), and seq_length characters from
    gs_text (includes empty characters) (output).
    ocr_text and gs_tetxt contain aligned arrays of characters.
    Because of the empty characters ('' in the character arrays), the input
    and output sequences may not have equal length. Therefore input and
    output are padded with a padding character (newline).

    Returns:
      int: the number of samples in the dataset
      generator: generator for one-hot encoded data (so the data doesn't have
        to fit in memory)
    """
    dataX = []
    dataY = []
    text_length = len(ocr_text)
    for i in range(0, text_length-seq_length + 1, step):
        seq_in = ocr_text[i:i+seq_length]
        seq_out = gs_text[i:i+seq_length]
        dataX.append(to_string(seq_in, lowercase))
        dataY.append(to_string(seq_out, lowercase))
    return len(dataX), synced_data_gen(dataX, dataY, seq_length, n_vocab,
                                       char_to_int, batch_size, padding_char)


def synced_data_gen(dataX, dataY, seq_length, n_vocab, char_to_int, batch_size,
                    padding_char):
    while 1:
        for batch_idx in range(0, len(dataX), batch_size):
            X = np.zeros((batch_size, seq_length, n_vocab), dtype=np.bool)
            Y = np.zeros((batch_size, seq_length, n_vocab), dtype=np.bool)
            sliceX = dataX[batch_idx:batch_idx+batch_size]
            sliceY = dataY[batch_idx:batch_idx+batch_size]
            for i, (sentenceX, sentenceY) in enumerate(zip(sliceX, sliceY)):
                for j, c in enumerate(sentenceX):
                    X[i, j, char_to_int[c]] = 1
                for j in range(seq_length-len(sentenceX)):
                    X[i, len(sentenceX) + j, char_to_int[padding_char]] = 1
                for j, c in enumerate(sentenceY):
                    Y[i, j, char_to_int[c]] = 1
                for j in range(seq_length-len(sentenceY)):
                    Y[i, len(sentenceY) + j, char_to_int[padding_char]] = 1
            yield X, Y


def read_texts(data_files, data_dir):
    raw_text = []
    gs = []
    ocr = []

    for df in data_files:
        with codecs.open(os.path.join(data_dir, df), encoding='utf-8') as f:
            aligned = json.load(f)

        ocr.append(aligned['ocr'])
        ocr.append([' '])             # add space between two texts
        gs.append(aligned['gs'])
        gs.append([' '])              # add space between two texts

        raw_text.append(''.join(aligned['ocr']))
        raw_text.append(''.join(aligned['gs']))

    # Make a single array, containing the character-aligned text of all data
    # files
    gs_text = [y for x in gs for y in x]
    ocr_text = [y for x in ocr for y in x]

    return ' '.join(raw_text), gs_text, ocr_text


def get_char_to_int(chars):
    return dict((c, i) for i, c in enumerate(chars))


def get_int_to_char(chars):
    return dict((i, c) for i, c in enumerate(chars))
