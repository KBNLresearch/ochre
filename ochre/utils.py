import numpy as np
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers import LSTM
from keras.layers import TimeDistributed
from keras.layers import Bidirectional
from keras.layers import RepeatVector
from keras.layers import Embedding
from keras.callbacks import ModelCheckpoint

import os
import codecs
import glob2
import json
import re
import edlib


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


def initialize_model_seq2seq(n, dropout, seq_length, predict_chars,
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
    model.add(RepeatVector(seq_length+predict_chars))
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


def to_string(char_list, lowercase):
    if lowercase:
        return u''.join(char_list).lower()
    return u''.join(char_list)


def create_training_data(text_in, text_out, char_to_int, n_vocab,
                         seq_length=25, batch_size=100, padding_char=u'\n',
                         lowercase=False, predict_chars=0, step=1,
                         char_embedding=False):
    """Create padded one-hot encoded data sets from aligned text.

    A sample consists of seq_length characters from text_in (e.g., the ocr
    text) (may include empty characters), and seq_length characters from
    text_out (e.g., the gold standard text) (may include empty characters).
    text_in and text_out contain aligned arrays of characters.
    Because of the empty characters ('' in the character arrays), the input
    and output sequences may not have equal length. Therefore input and
    output are padded with a padding character (default: newline).

    Returns:
      int: the number of samples in the dataset
      generator: generator for one-hot encoded data (so the data doesn't have
        to fit in memory)
    """
    dataX = []
    dataY = []
    text_length = len(text_in)
    for i in range(0, text_length-seq_length-predict_chars+1, step):
        seq_in = text_in[i:i+seq_length]
        seq_out = text_out[i:i+seq_length+predict_chars]
        dataX.append(to_string(seq_in, lowercase))
        dataY.append(to_string(seq_out, lowercase))
    if char_embedding:
        data_gen = data_generator_embedding(dataX, dataY, seq_length,
                                            predict_chars, n_vocab,
                                            char_to_int, batch_size,
                                            padding_char)
    else:
        data_gen = data_generator(dataX, dataY, seq_length, predict_chars,
                                  n_vocab, char_to_int, batch_size,
                                  padding_char)

    return len(dataX), data_gen


def data_generator(dataX, dataY, seq_length, predict_chars, n_vocab,
                   char_to_int, batch_size, padding_char):
    while 1:
        for batch_idx in range(0, len(dataX), batch_size):
            X = np.zeros((batch_size, seq_length, n_vocab), dtype=np.bool)
            Y = np.zeros((batch_size, seq_length+predict_chars, n_vocab),
                         dtype=np.bool)
            sliceX = dataX[batch_idx:batch_idx+batch_size]
            sliceY = dataY[batch_idx:batch_idx+batch_size]
            for i, (sentenceX, sentenceY) in enumerate(zip(sliceX, sliceY)):
                for j, c in enumerate(sentenceX):
                    X[i, j, char_to_int[c]] = 1
                for j in range(seq_length-len(sentenceX)):
                    X[i, len(sentenceX) + j, char_to_int[padding_char]] = 1
                for j, c in enumerate(sentenceY):
                    Y[i, j, char_to_int[c]] = 1
                for j in range(seq_length+predict_chars-len(sentenceY)):
                    Y[i, len(sentenceY) + j, char_to_int[padding_char]] = 1
            yield X, Y


def data_generator_embedding(dataX, dataY, seq_length, predict_chars, n_vocab,
                             char_to_int, batch_size, padding_char):
    while 1:
        for batch_idx in range(0, len(dataX), batch_size):
            X = np.zeros((batch_size, seq_length), dtype=np.int)
            Y = np.zeros((batch_size, seq_length+predict_chars, n_vocab),
                         dtype=np.bool)
            sliceX = dataX[batch_idx:batch_idx+batch_size]
            sliceY = dataY[batch_idx:batch_idx+batch_size]
            for i, (sentenceX, sentenceY) in enumerate(zip(sliceX, sliceY)):
                for j, c in enumerate(sentenceX):
                    X[i, j] = char_to_int[c]
                for j in range(seq_length-len(sentenceX)):
                    X[i, len(sentenceX) + j] = char_to_int[padding_char]
                for j, c in enumerate(sentenceY):
                    Y[i, j, char_to_int[c]] = 1
                for j in range(seq_length+predict_chars-len(sentenceY)):
                    Y[i, len(sentenceY) + j, char_to_int[padding_char]] = 1
            yield X, Y


def read_texts(data_files, data_dir):
    raw_text = []
    gs = []
    ocr = []

    for df in data_files:
        if data_dir is None:
            fi = df
        else:
            fi = os.path.join(data_dir, df)
        with codecs.open(fi, encoding='utf-8') as f:
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


def read_text_to_predict(text, seq_length, lowercase, n_vocab,
                         char_to_int, padding_char, predict_chars=0, step=1,
                         char_embedding=False):
    dataX = []
    text_length = len(text)
    for i in range(0, text_length-seq_length-predict_chars+1, step):
        seq_in = text[i:i+seq_length]
        dataX.append(to_string(seq_in, lowercase))

    if char_embedding:
        X = np.zeros((len(dataX), seq_length), dtype=np.int)
    else:
        X = np.zeros((len(dataX), seq_length, n_vocab), dtype=np.bool)

    for i, sentenceX in enumerate(dataX):
        for j, c in enumerate(sentenceX):
            if char_embedding:
                X[i, j] = char_to_int[c]
            else:
                X[i, j, char_to_int[c]] = 1
        for j in range(seq_length-len(sentenceX)):
            if char_embedding:
                X[i, len(sentenceX) + j] = char_to_int[padding_char]
            else:
                X[i, len(sentenceX) + j, char_to_int[padding_char]] = 1

    return X


def get_char_to_int(chars):
    return dict((c, i) for i, c in enumerate(chars))


def get_int_to_char(chars):
    return dict((i, c) for i, c in enumerate(chars))


def align_characters(ocr, gs, cigar, empty_char='', sanity_check=True):
    matches = re.findall(r'(\d+)(.)', cigar)
    offset1 = 0
    offset2 = 0

    gs_a = []
    ocr_a = []

    for m in matches:
        n = int(m[0])
        typ = m[1]

        if typ == '=':
            # sanity check - strings should be equal
            if sanity_check:
                assert(ocr[offset1:offset1+n] == gs[offset2:offset2+n])

            for c in ocr[offset1:offset1+n]:
                ocr_a.append(c)
            for c in gs[offset2:offset2+n]:
                gs_a.append(c)

            offset1 += n
            offset2 += n
        elif typ == 'D':  # Inserted
            for _ in range(n):
                ocr_a.append(empty_char)
            for c in gs[offset2:offset2+n]:
                gs_a.append(c)

            offset2 += n
        elif typ == 'X':
            for c in ocr[offset1:offset1+n]:
                ocr_a.append(c)
            for c in gs[offset2:offset2+n]:
                gs_a.append(c)

            offset1 += n
            offset2 += n
        elif typ == 'I':  # Deleted
            for c in ocr[offset1:offset1+n]:
                ocr_a.append(c)
            for _ in range(n):
                gs_a.append(empty_char)

            offset1 += n
    return ocr_a, gs_a


def align_output_to_input(input_str, output_str, empty_char=u'@'):
    t_output_str = output_str.encode('ASCII', 'replace')
    t_input_str = input_str.encode('ASCII', 'replace')
    try:
        r = edlib.align(t_input_str, t_output_str, task='path')
    except:
        print(input_str)
        print(output_str)
    r1, r2 = align_characters(input_str, output_str, r.get('cigar'),
                              empty_char=empty_char, sanity_check=False)
    while len(r2) < len(input_str):
        r2.append(empty_char)
    return u''.join(r2)


def save_charset(weights_dir, chars, lowercase):
    if lowercase:
        fname = 'chars-lower.txt'
    else:
        fname = 'chars.txt'
    chars_file = os.path.join(weights_dir, fname)
    with codecs.open(chars_file, 'wb', encoding='utf-8') as f:
        f.write(u''.join(chars))


def get_chars(raw_val, raw_test, raw_train, lowercase, padding_char=u'\n'):
    raw_text = ''.join([raw_val, raw_test, raw_train])
    if lowercase:
        raw_text = raw_text.lower()

    chars = sorted(list(set(raw_text)))
    chars.append(padding_char)
    char_to_int = get_char_to_int(chars)

    return chars, len(chars), char_to_int
