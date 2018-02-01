import click
import os
import json
import codecs

from keras.models import Model
from keras.layers import Input, LSTM, Dense
import numpy as np

from ochre.select_test_files import get_files
from ochre.utils import add_checkpoint, load_weights


def read_texts(data_dir, div, name):
    in_files = get_files(data_dir, div, name)

    print in_files

    # Vectorize the data.
    input_texts = []
    target_texts = []

    for in_file in in_files:
        print(in_file)
        lines = codecs.open(in_file, 'r', encoding='utf-8').readlines()
        for line in lines:
            #print line.split('||@@||')
            input_text, target_text = line.split('||@@||')
            # We use "tab" as the "start sequence" character
            # for the targets, and "\n" as "end sequence" character.
            target_text = '\t' + target_text
            input_texts.append(input_text)
            target_texts.append(target_text)

        return input_texts, target_texts


def convert(input_texts, target_texts, input_characters, target_characters, max_encoder_seq_length, num_encoder_tokens, max_decoder_seq_length, num_decoder_tokens):
    input_token_index = dict(
        [(char, i) for i, char in enumerate(input_characters)])
    target_token_index = dict(
        [(char, i) for i, char in enumerate(target_characters)])

    encoder_input_data = np.zeros(
        (len(input_texts), max_encoder_seq_length, num_encoder_tokens),
        dtype='float32')
    decoder_input_data = np.zeros(
        (len(input_texts), max_decoder_seq_length, num_decoder_tokens),
        dtype='float32')
    decoder_target_data = np.zeros(
        (len(input_texts), max_decoder_seq_length, num_decoder_tokens),
        dtype='float32')

    for i, (input_text, target_text) in enumerate(zip(input_texts, target_texts)):
        for t, char in enumerate(input_text):
            encoder_input_data[i, t, input_token_index[char]] = 1.
        for t, char in enumerate(target_text):
            # decoder_target_data is ahead of decoder_input_data by one timestep
            decoder_input_data[i, t, target_token_index[char]] = 1.
            if t > 0:
                # decoder_target_data will be ahead by one timestep
                # and will not include the start character.
                decoder_target_data[i, t - 1, target_token_index[char]] = 1.

    return encoder_input_data, decoder_input_data, decoder_target_data


@click.command()
@click.argument('datasets', type=click.File())
@click.argument('data_dir', type=click.Path(exists=True))
@click.option('--weights_dir', '-w', default=os.getcwd(), type=click.Path())
def train_lstm(datasets, data_dir, weights_dir):
    batch_size = 64  # Batch size for training.
    epochs = 100  # Number of epochs to train for.
    latent_dim = 256  # Latent dimensionality of the encoding space.

    div = json.load(datasets)

    train_input, train_target = read_texts(data_dir, div, 'train')
    val_input, val_target = read_texts(data_dir, div, 'train')
    #test_input, test_target = read_texts(data_dir, div, 'test')

    input_characters = sorted(list(set(u''.join(train_input) + u''.join(val_input))))
    target_characters = sorted(list(set(u''.join(train_target) + u''.join(val_target))))
    num_encoder_tokens = len(input_characters)
    num_decoder_tokens = len(target_characters)
    max_encoder_seq_length = max([len(txt) for txt in train_input])
    max_decoder_seq_length = max([len(txt) for txt in train_target])

    print('Number of samples:', len(train_input))
    print('Number of unique input tokens:', num_encoder_tokens)
    print('Number of unique output tokens:', num_decoder_tokens)
    print('Max sequence length for inputs:', max_encoder_seq_length)
    print('Max sequence length for outputs:', max_decoder_seq_length)
    print('Input characters:', u''.join(input_characters))
    print('Output characters:', u''.join(target_characters))

    train_enc_input, train_dec_input, train_dec_target = convert(train_input,
            train_target, input_characters, target_characters,
            max_encoder_seq_length, num_encoder_tokens, max_decoder_seq_length,
            num_decoder_tokens)

    val_enc_input, val_dec_input, val_dec_target = convert(val_input,
            val_target, input_characters, target_characters,
            max_encoder_seq_length, num_encoder_tokens, max_decoder_seq_length,
            num_decoder_tokens)

    # Define an input sequence and process it.
    encoder_inputs = Input(shape=(None, num_encoder_tokens))
    encoder = LSTM(latent_dim, return_state=True)
    encoder_outputs, state_h, state_c = encoder(encoder_inputs)
    # We discard `encoder_outputs` and only keep the states.
    encoder_states = [state_h, state_c]

    # Set up the decoder, using `encoder_states` as initial state.
    decoder_inputs = Input(shape=(None, num_decoder_tokens))
    # We set up our decoder to return full output sequences,
    # and to return internal states as well. We don't use the
    # return states in the training model, but we will use them in inference.
    decoder_lstm = LSTM(latent_dim, return_sequences=True, return_state=True)
    decoder_outputs, _, _ = decoder_lstm(decoder_inputs,
                                         initial_state=encoder_states)
    decoder_dense = Dense(num_decoder_tokens, activation='softmax')
    decoder_outputs = decoder_dense(decoder_outputs)

    # Define the model that will turn
    # `encoder_input_data` & `decoder_input_data` into `decoder_target_data`
    model = Model([encoder_inputs, decoder_inputs], decoder_outputs)

    # Run training
    model.compile(optimizer='rmsprop', loss='categorical_crossentropy')
    epoch, model = load_weights(model, weights_dir, optimizer='rmsprop', loss='categorical_crossentropy')
    callbacks_list = [add_checkpoint(weights_dir)]
    model.fit([train_enc_input, train_dec_input], train_dec_target,
              batch_size=batch_size,
              epochs=epochs,
              validation_data=([val_enc_input, val_dec_input], val_dec_target),
              callbacks=callbacks_list,
              initial_epoch=epoch)


if __name__ == '__main__':
    train_lstm()
