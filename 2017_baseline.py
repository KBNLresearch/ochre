import os
import pickle

from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from keras.layers import TimeDistributed
from keras.layers import RepeatVector
from keras.layers import Embedding
from keras.callbacks import ModelCheckpoint

from datagen import DataGenerator


def infinite_loop(generator):
    while True:
        for i in range(len(generator)):
            yield(generator[i])
        generator.on_epoch_end()


# load the data
data_dir = '/home/jvdzwaan/data/sprint-icdar/in' # FIXME
weights_dir = '/home/jvdzwaan/data/sprint-icdar/weights'

if not os.path.exists(weights_dir):
    os.makedirs(weights_dir)

seq_length = 53
batch_size = 100
shuffle = True
pc = '\n'
oc = '@'

n_nodes = 1000
dropout = 0.2
n_embed = 256

epochs = 30
loss = 'categorical_crossentropy'
optimizer = 'adam'
metrics = ['accuracy']

with open(os.path.join(data_dir, 'train.pkl'), 'rb') as f:
    gs_selected_train, ocr_selected_train = pickle.load(f)

with open(os.path.join(data_dir, 'val.pkl'), 'rb') as f:
    gs_selected_val, ocr_selected_val = pickle.load(f)

with open(os.path.join(data_dir, 'ci.pkl'), 'rb') as f:
    ci = pickle.load(f)

n_vocab = len(ci)

dg_val = DataGenerator(xData=ocr_selected_val, yData=gs_selected_val,
                       char_to_int=ci,
                       seq_length=seq_length, padding_char=pc, oov_char=oc,
                       batch_size=batch_size, shuffle=shuffle)
dg_train = DataGenerator(xData=ocr_selected_train,
                         yData=gs_selected_train, char_to_int=ci,
                         seq_length=seq_length, padding_char=pc,
                         oov_char=oc,
                         batch_size=batch_size, shuffle=shuffle)

# create the network
model = Sequential()

# encoder
model.add(Embedding(n_vocab, n_embed, input_length=seq_length))
model.add(LSTM(n_nodes, input_shape=(seq_length, n_vocab)))
# For the decoder's input, we repeat the encoded input for each time step
model.add(RepeatVector(seq_length))
model.add(LSTM(n_nodes, return_sequences=True))

# For each of step of the output sequence, decide which character should be
# chosen
model.add(TimeDistributed(Dense(n_vocab, activation='softmax')))
model.compile(loss=loss, optimizer=optimizer, metrics=metrics)

# initialize saving of weights
filepath = os.path.join(weights_dir, '{loss:.4f}-{epoch:02d}.hdf5')
checkpoint = ModelCheckpoint(filepath, monitor='loss', verbose=1,
                             save_best_only=True, mode='min')
callbacks_list = [checkpoint]

# do training (and save weights)
model.fit_generator(infinite_loop(dg_train), steps_per_epoch=len(dg_train), epochs=epochs,
                    validation_data=infinite_loop(dg_val),
                    validation_steps=len(dg_val), callbacks=callbacks_list)
