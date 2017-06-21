import random
import numpy as np
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers import TimeDistributed
from keras.layers import RepeatVector
from keras.layers import LSTM

from keras.callbacks import ModelCheckpoint

import click
import os
import codecs
import glob
import glob2


def initialize_model(n, dropout, input_shape, output_size, layers,
                     loss='categorical_crossentropy', optimizer='adam',
                     metrics=['accuracy']):
    model = Sequential()
    # encoder
    model.add(LSTM(n, input_shape=input_shape))
    # For the decoder's input, we repeat the encoded input for each time step
    model.add(RepeatVector(input_shape[0]))
    # The decoder RNN could be multiple layers stacked or a single layer
    for _ in range(layers):
        model.add(LSTM(n, return_sequences=True))

    # For each of step of the output sequence, decide which character should be
    # chosen
    model.add(TimeDistributed(Dense(output_size, activation='softmax')))
    model.compile(loss=loss, optimizer=optimizer, metrics=metrics)

    return model


def load_weights(model, weights_dir, loss='categorical_crossentropy',
                 optimizer='adam', metrics=['accuracy']):
    weight_files = glob2.glob('{}{}*-*.hdf5'.format(weights_dir, os.sep))
    if weight_files != []:
        fname = sorted(weight_files)[-1]
        print('Loading weights from {}'.format(fname))

        model.load_weights(fname)
        model.compile(loss=loss, optimizer=optimizer, metrics=metrics)

    return model


def create_data(ocr_texts, gs_texts, n_vocab, char_to_int, seq_length=25):
    dataX = []
    dataY = []
    for ocr, gs in zip(ocr_texts, gs_texts):
        text_length = max(len(ocr), len(gs))

        # pad texts with \n
        if len(ocr) < text_length:
            ocr = ocr + '\n' * (text_length-len(ocr))
        if len(gs) < text_length:
            gs = gs + '\n' * (text_length-len(gs))

        for i in range(0, text_length-seq_length + 1, 1):
            seq_in = ocr[i:i+seq_length]
            seq_out = gs[i:i+seq_length]
            dataX.append(seq_in)
            dataY.append(seq_out)

    X = np.zeros((len(dataX), seq_length, n_vocab), dtype=np.bool)
    Y = np.zeros((len(dataY), seq_length, n_vocab), dtype=np.bool)

    for i, sentence in enumerate(dataX):
        for j, c in enumerate(sentence):
            X[i, j, char_to_int[c]] = 1

    for i, sentence in enumerate(dataY):
        for j, c in enumerate(sentence):
            Y[i, j, char_to_int[c]] = 1

    return X, Y


@click.command()
@click.argument('texts_dir', type=click.Path(exists=True))
@click.option('--weights_dir', '-w', default=os.getcwd(), type=click.Path())
def train_lstm(texts_dir, weights_dir):
    PERCENTAGE_VALIDATION = 10
    SEQ_LENGTH = 20
    BATCH_SIZE = 100
    EPOCHS = 20
    LAYERS = 2
    num_nodes = 256

    # Read data
    ocr_texts = []
    gs_texts = []

    ocr_files = glob.glob(os.path.join(texts_dir, 'BAO*.ocr.txt'))
    ocr_files.sort()
    gs_files = glob.glob(os.path.join(texts_dir, 'BAO*.gs.txt'))
    gs_files.sort()

    for ocr_file, gs_file in zip(ocr_files, gs_files):
        with codecs.open(ocr_file, encoding='utf-8') as f:
            ocr_text = f.read()
        ocr_texts.append(ocr_text.lower())

        with codecs.open(gs_file, encoding='utf-8') as f:
            gs_text = f.read()
        gs_texts.append(gs_text.lower())

    print('Number of newspaper articles: {}'.format(len(ocr_texts)))

    # Create character mapping
    raw_text = []
    for ocr, gs in zip(ocr_texts, gs_texts):
        raw_text.append(ocr)
        raw_text.append(gs)
    raw_text.append('\n')

    raw_text = ' '.join(raw_text)

    chars = sorted(list(set(raw_text)))
    char_to_int = dict((c, i) for i, c in enumerate(chars))

    n_chars = len(raw_text)
    n_vocab = len(chars)
    print('Total Characters: {}'.format(n_chars))
    print('Total Vocab: {}'.format(n_vocab))

    # divide texts in train and validation set
    c = list(zip(ocr_texts, gs_texts))
    random.shuffle(c)
    ocr_texts, gs_texts = zip(*c)

    n = len(ocr_texts) / PERCENTAGE_VALIDATION
    print n

    ocr_validation_texts = ocr_texts[0:n]
    ocr_train_texts = ocr_texts[n:]

    gs_validation_texts = gs_texts[0:n]
    gs_train_texts = gs_texts[n:]

    xTrain, yTrain = create_data(ocr_train_texts, gs_train_texts, n_vocab,
                                 char_to_int, seq_length=SEQ_LENGTH)
    xTest, yTest = create_data(ocr_validation_texts, gs_validation_texts,
                               n_vocab, char_to_int, seq_length=SEQ_LENGTH)

    n_patterns = len(xTrain)
    print('Total Patterns: {}'.format(n_patterns))

    model = initialize_model(num_nodes, 0.5, (SEQ_LENGTH, n_vocab), n_vocab,
                             LAYERS)
    model = load_weights(model, weights_dir)

    # initialize saving of weights
    filepath = os.path.join(weights_dir, '{loss:.4f}.hdf5')
    checkpoint = ModelCheckpoint(filepath, monitor='loss', verbose=1,
                                 save_best_only=True, mode='min')
    callbacks_list = [checkpoint]

    # do training (and save weights)
    model.fit(xTrain, yTrain, batch_size=BATCH_SIZE, epochs=EPOCHS,
              validation_data=(xTest, yTest), callbacks=callbacks_list)


if __name__ == '__main__':
    train_lstm()
