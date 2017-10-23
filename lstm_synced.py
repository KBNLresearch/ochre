from keras.callbacks import ModelCheckpoint

from ochre.utils import initialize_model, initialize_model_bidirectional, \
                           initialize_model_seq2seq, load_weights, \
                           create_synced_data, read_texts, get_char_to_int

import click
import os
import json
import codecs


@click.command()
@click.argument('datasets', type=click.File())
@click.argument('data_dir', type=click.Path(exists=True))
@click.option('--weights_dir', '-w', default=os.getcwd(), type=click.Path())
def train_lstm(datasets, data_dir, weights_dir):
    # lees data in en maak character mappings
    # genereer trainings data
    seq_length = 25
    num_nodes = 256
    layers = 2
    batch_size = 100
    step = 3  # step size used to create data (3 = use every third sequence)
    lowercase = True
    bidirectional = False
    seq2seq = True

    print('Sequence lenght: {}'.format(seq_length))
    print('Number of nodes in hidden layers: {}'.format(num_nodes))
    print('Number of hidden layers: {}'.format(layers))
    print('Batch size: {}'.format(batch_size))
    print('Lowercase data: {}'.format(lowercase))
    print('Bidirectional layers: {}'.format(bidirectional))
    print('Seq2seq: {}'.format(seq2seq))

    division = json.load(datasets)

    raw_val, gs_val, ocr_val = read_texts(division.get('val'), data_dir)
    raw_test, gs_test, ocr_test = read_texts(division.get('test'), data_dir)
    raw_train, gs_train, ocr_train = read_texts(division.get('train'), data_dir)

    raw_text = ''.join([raw_val, raw_test, raw_train])
    if lowercase:
        raw_text = raw_text.lower()

    #print('Number of texts: {}'.format(len(data_files)))

    chars = sorted(list(set(raw_text)))
    chars.append(u'\n')                      # padding character
    char_to_int = get_char_to_int(chars)

    # save charset to file
    if lowercase:
        fname = 'chars-lower.txt'
    else:
        fname = 'chars.txt'
    chars_file = os.path.join(weights_dir, fname)
    with codecs.open(chars_file, 'wb', encoding='utf-8') as f:
        f.write(u''.join(chars))

    n_chars = len(raw_text)
    n_vocab = len(chars)

    print('Total Characters: {}'.format(n_chars))
    print('Total Vocab: {}'.format(n_vocab))

    numTrainSamples, trainDataGen = create_synced_data(ocr_train, gs_train, char_to_int, n_vocab, seq_length=seq_length, batch_size=batch_size, lowercase=lowercase, step=step)
    numTestSamples, testDataGen = create_synced_data(ocr_test, gs_test, char_to_int, n_vocab, seq_length=seq_length, batch_size=batch_size, lowercase=lowercase)
    numValSamples, valDataGen = create_synced_data(ocr_val, gs_val, char_to_int, n_vocab, seq_length=seq_length, batch_size=batch_size, lowercase=lowercase)

    n_patterns = numTrainSamples
    print("Train Patterns: {}".format(n_patterns))
    print("Validation Patterns: {}".format(numValSamples))
    print("Test Patterns: {}".format(numTestSamples))
    print('Total: {}'.format(numTrainSamples+numTestSamples+numValSamples))

    if bidirectional:
        model = initialize_model_bidirectional(num_nodes, 0.5, seq_length,
                                               chars, n_vocab, layers)
    elif seq2seq:
        model = initialize_model_seq2seq(num_nodes, 0.5, seq_length,
                                         n_vocab, layers)
    else:
        model = initialize_model(num_nodes, 0.5, seq_length, chars, n_vocab,
                                 layers)
    epoch, model = load_weights(model, weights_dir)

    # initialize saving of weights
    filepath = os.path.join(weights_dir, '{loss:.4f}-{epoch:02d}.hdf5')
    checkpoint = ModelCheckpoint(filepath, monitor='loss', verbose=1,
                                 save_best_only=True, mode='min')
    callbacks_list = [checkpoint]

    # do training (and save weights)
    model.fit_generator(trainDataGen, steps_per_epoch=int(numTrainSamples/batch_size), epochs=40, validation_data=valDataGen, validation_steps=int(numValSamples/batch_size), callbacks=callbacks_list, initial_epoch=epoch)


if __name__ == '__main__':
    train_lstm()
