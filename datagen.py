"""Data generation functionality for ochre

Source:
https://stanford.edu/~shervine/blog/keras-how-to-generate-data-on-the-fly
"""
import keras
import tensorflow

import numpy as np


class DataGenerator(tensorflow.keras.utils.Sequence):
    'Generates data for Keras'
    def __init__(self, xData, yData, char_to_int, seq_length,
                 padding_char='\n', oov_char='@', batch_size=32, shuffle=True):
        """
        xData is list of input strings
        yData is list of output strings
        """
        self.xData = xData
        self.yData = yData

        self.char_to_int = char_to_int
        self.padding_char = padding_char
        self.oov_char = oov_char

        self.n_vocab = len(char_to_int)
        self.seq_length = seq_length

        self.batch_size = batch_size
        self.shuffle = shuffle
        self.on_epoch_end()

    def __len__(self):
        'Denotes the number of batches per epoch'
        return int(np.floor(len(self.xData) / self.batch_size))

    def __getitem__(self, index):
        'Generate one batch of data'
        # Generate indexes of the batch
        indexes = self.indexes[index*self.batch_size:(index+1)*self.batch_size]

        # Generate data
        X, y = self.__data_generation(indexes)

        return X, y

    def on_epoch_end(self):
        'Updates indexes after each epoch'
        self.indexes = np.arange(len(self.xData))
        if self.shuffle is True:
            np.random.shuffle(self.indexes)

    def __data_generation(self, list_IDs_temp):
        'Generates data containing batch_size samples'
        # Initialization
        X = np.empty((self.batch_size, self.seq_length), dtype=np.int)
        ylist = list()

        # Generate data
        for i, ID in enumerate(list_IDs_temp):
            # input
            X[i, ] = self._convert_sample(self.xData[ID])

            # output
            y_seq = self._convert_sample(self.yData[ID])
            enc = keras.utils.to_categorical(y_seq, num_classes=self.n_vocab)
            ylist.append(enc)

        y = np.array(ylist)
        y = y.reshape(self.batch_size, self.seq_length, self.n_vocab)

        return X, y

    def _convert_sample(self, string):
        res = np.empty(self.seq_length, dtype=np.int)
        oov = self.char_to_int[self.oov_char]
        for i in range(self.seq_length):
            try:
                res[i] = self.char_to_int.get(string[i], oov)
            except IndexError:
                res[i] = self.char_to_int[self.padding_char]
        return res

    def __iter__(self):
        n = len(self)
        for i in range(n):
            yield self[i]
