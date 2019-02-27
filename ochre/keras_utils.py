import re
import os
import glob2

from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers import LSTM
from keras.layers import TimeDistributed
from keras.layers import Bidirectional
from keras.layers import RepeatVector
from keras.layers import Embedding
from keras.callbacks import ModelCheckpoint


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


def initialize_model_seq2seq(n, dropout, seq_length,
                             output_size, layers, char_embedding_size=0,
                             loss='categorical_crossentropy', optimizer='adam',
                             metrics=['accuracy']):
    model = Sequential()
    # encoder
    if char_embedding_size:
        n_embed = char_embedding_size
        model.add(Embedding(output_size, n_embed, input_length=seq_length))
        model.add(LSTM(n))
    else:
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
            epoch += 1

    return epoch, model


def add_checkpoint(weights_dir):
    filepath = os.path.join(weights_dir, '{loss:.4f}-{epoch:02d}.hdf5')
    checkpoint = ModelCheckpoint(filepath, monitor='loss', verbose=1,
                                 save_best_only=True, mode='min')
    return checkpoint
