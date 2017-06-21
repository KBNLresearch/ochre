import numpy as np
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers import LSTM

from keras.callbacks import ModelCheckpoint
from keras.utils import np_utils

import click
import os
import codecs
import glob2


def initialize_model(n, dropout, input_shape, output_size,
                     loss='categorical_crossentropy', optimizer='adam'):
    model = Sequential()
    model.add(LSTM(n, input_shape=input_shape))
    model.add(Dropout(dropout))
    model.add(Dense(output_size, activation='softmax'))
    model.compile(loss=loss, optimizer=optimizer)

    return model


def load_weights(model, weights_dir, loss='categorical_crossentropy',
                 optimizer='adam'):
    weight_files = glob2.glob('{}{}*-*.hdf5'.format(weights_dir, os.sep))
    if weight_files != []:
        fname = sorted(weight_files)[-1]
        print('Loading weights from {}'.format(fname))

        model.load_weights(fname)
        model.compile(loss=loss, optimizer=optimizer)

    return model


@click.command()
@click.argument('txt_file', type=click.Path(exists=True))
@click.option('--weights_dir', '-w', default=os.getcwd(), type=click.Path())
def train_lstm(txt_file, weights_dir):
    # lees data in en maak character mappings
    # genereer trainings data
    seq_length = 100
    num_nodes = 256

    with codecs.open(txt_file, 'r', encoding='utf-8') as f:
        raw_text = f.read().strip().lower()
    chars = sorted(list(set(raw_text)))

    n_chars = len(raw_text)
    n_vocab = len(chars)
    print('Total Characters: {}'.format(n_chars))
    print('Total Vocab: {}'.format(n_vocab))

    char_to_int = dict((c, i) for i, c in enumerate(chars))

    dataX = []
    dataY = []
    for i in range(0, n_chars - seq_length, 1):
        seq_in = raw_text[i:i + seq_length]
        seq_out = raw_text[i + seq_length]
        dataX.append([char_to_int[char] for char in seq_in])
        dataY.append(char_to_int[seq_out])
    n_patterns = len(dataX)
    print('Total Patterns: {}'.format(n_patterns))

    X = np.reshape(dataX, (n_patterns, seq_length, 1))
    # normalize
    X = X / float(n_vocab)
    # one hot encode the output variable
    y = np_utils.to_categorical(dataY)

    model = initialize_model(num_nodes, 0.2, (seq_length, 1), n_vocab)
    model = load_weights(model, weights_dir)

    # initialize saving of weights
    filepath = os.path.join(weights_dir, '{epoch:02d}-{loss:.4f}.hdf5')
    checkpoint = ModelCheckpoint(filepath, monitor='loss', verbose=1,
                                 save_best_only=True, mode='min')
    callbacks_list = [checkpoint]

    # do training (and save weights)
    model.fit(X, y, epochs=20, batch_size=100, callbacks=callbacks_list)


if __name__ == '__main__':
    train_lstm()
