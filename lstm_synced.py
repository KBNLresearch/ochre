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


def load_weights(model, weights_dir, loss='categorical_crossentropy',
                 optimizer='adam'):
    epoch = 0
    weight_files = glob2.glob('{}{}*.hdf5'.format(weights_dir, os.sep))
    if weight_files != []:
        fname = sorted(weight_files)[-1]
        print('Loading weights from {}'.format(fname))

        model.load_weights(fname)
        model.compile(loss=loss, optimizer=optimizer)

        m = re.match(r'.+-(\d\d).hdf5', fname)
        if m:
            epoch = int(m.group(1))

    return epoch, model


def create_synced_data(ocr_text, gs_text, char_to_int, n_vocab, seq_length=25,
                       batch_size=100, padding_char=u'\n'):
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
    for i in range(0, text_length-seq_length + 1, 1):
        seq_in = ocr_text[i:i+seq_length]
        seq_out = gs_text[i:i+seq_length]
        dataX.append(''.join(seq_in))
        dataY.append(''.join(seq_out))
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
        gs.append(aligned['gs'])

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


@click.command()
@click.argument('datasets', type=click.File())
@click.argument('data_dir', type=click.Path(exists=True))
@click.option('--weights_dir', '-w', default=os.getcwd(), type=click.Path())
def train_lstm(datasets, data_dir, weights_dir):
    # lees data in en maak character mappings
    # genereer trainings data
    seq_length = 25
    num_nodes = 256
    layers = 3
    batch_size = 100

    print('Sequence lenght: {}'.format(seq_length))
    print('Number of nodes in hidden layers: {}'.format(num_nodes))
    print('Number of hidden layers: {}'.format(layers))
    print('Batch size: {}'.format(batch_size))

    division = json.load(datasets)

    raw_val, gs_val, ocr_val = read_texts(division.get('val'), data_dir)
    raw_test, gs_test, ocr_test = read_texts(division.get('test'), data_dir)
    raw_train, gs_train, ocr_train = read_texts(division.get('train'), data_dir)

    raw_text = ''.join([raw_val, raw_test, raw_train])

    #print('Number of texts: {}'.format(len(data_files)))

    chars = sorted(list(set(raw_text)))
    chars.append(u'\n')                      # padding character
    char_to_int = get_char_to_int(chars)

    n_chars = len(raw_text)
    n_vocab = len(chars)

    print('Total Characters: {}'.format(n_chars))
    print('Total Vocab: {}'.format(n_vocab))

    numTrainSamples, trainDataGen = create_synced_data(ocr_train, gs_train, char_to_int, n_vocab, seq_length=seq_length, batch_size=batch_size)
    numTestSamples, testDataGen = create_synced_data(ocr_test, gs_test, char_to_int, n_vocab, seq_length=seq_length, batch_size=batch_size)
    numValSamples, valDataGen = create_synced_data(ocr_val, gs_val, char_to_int, n_vocab, seq_length=seq_length, batch_size=batch_size)

    n_patterns = numTrainSamples
    print("Train Patterns: {}".format(n_patterns))
    print("Validation Patterns: {}".format(numValSamples))
    print("Test Patterns: {}".format(numTestSamples))
    print('Total: {}'.format(numTrainSamples+numTestSamples+numValSamples))

    model = initialize_model(num_nodes, 0.5, seq_length, chars, n_vocab, layers)
    epoch, model = load_weights(model, weights_dir)

    epoch += 1

    # initialize saving of weights
    filepath = os.path.join(weights_dir, '{loss:.4f}-{epoch:02d}.hdf5')
    checkpoint = ModelCheckpoint(filepath, monitor='loss', verbose=1,
                                 save_best_only=True, mode='min')
    callbacks_list = [checkpoint]

    # do training (and save weights)
    model.fit_generator(trainDataGen, steps_per_epoch=int(numTrainSamples/batch_size), epochs=40, validation_data=valDataGen, validation_steps=int(numValSamples/batch_size), callbacks=callbacks_list, initial_epoch=epoch)


if __name__ == '__main__':
    train_lstm()
