from ochre.utils import initialize_model_seq2seq, load_weights, save_charset, \
                           create_training_data, read_texts, get_chars, \
                           add_checkpoint

import click
import os
import json


@click.command()
@click.argument('datasets', type=click.File())
@click.argument('data_dir', type=click.Path(exists=True))
@click.option('--weights_dir', '-w', default=os.getcwd(), type=click.Path())
def train_lstm(datasets, data_dir, weights_dir):
    seq_length = 25
    predict_chars = 1
    num_nodes = 256
    layers = 2
    batch_size = 100
    step = 3  # step size used to create data (3 = use every third sequence)
    lowercase = True
    pad = u'\n'

    print('Sequence length: {}'.format(seq_length))
    print('Predict characters: {}'.format(predict_chars))
    print('Number of nodes in hidden layers: {}'.format(num_nodes))
    print('Number of hidden layers: {}'.format(layers))
    print('Batch size: {}'.format(batch_size))
    print('Lowercase data: {}'.format(lowercase))

    division = json.load(datasets)

    raw_val, gs_val, ocr_val = read_texts(division.get('val'), data_dir)
    raw_test, gs_test, ocr_test = read_texts(division.get('test'), data_dir)
    raw_train, gs_train, ocr_train = read_texts(division.get('train'), data_dir)

    chars, n_vocab, char_to_int = get_chars(raw_val, raw_test, raw_train,
                                            lowercase, padding_char=pad)
    # save charset to file
    save_charset(weights_dir, chars, lowercase)

    print('Total Vocab: {}'.format(n_vocab))

    numTrainSamples, trainDataGen = create_training_data(ocr_train, gs_train, char_to_int, n_vocab, seq_length=seq_length, batch_size=batch_size, lowercase=lowercase, step=step, predict_chars=predict_chars)
    numTestSamples, testDataGen = create_training_data(ocr_test, gs_test, char_to_int, n_vocab, seq_length=seq_length, batch_size=batch_size, lowercase=lowercase, predict_chars=predict_chars)
    numValSamples, valDataGen = create_training_data(ocr_val, gs_val, char_to_int, n_vocab, seq_length=seq_length, batch_size=batch_size, lowercase=lowercase, predict_chars=predict_chars)

    n_patterns = numTrainSamples
    print("Train Patterns: {}".format(n_patterns))
    print("Validation Patterns: {}".format(numValSamples))
    print("Test Patterns: {}".format(numTestSamples))
    print('Total: {}'.format(numTrainSamples+numTestSamples+numValSamples))

    model = initialize_model_seq2seq(num_nodes, 0.5, seq_length, predict_chars,
                                     n_vocab, layers)
    epoch, model = load_weights(model, weights_dir)
    callbacks_list = [add_checkpoint(weights_dir)]

    # do training (and save weights)
    model.fit_generator(trainDataGen, steps_per_epoch=int(numTrainSamples/batch_size), epochs=40, validation_data=valDataGen, validation_steps=int(numValSamples/batch_size), callbacks=callbacks_list, initial_epoch=epoch+1)


if __name__ == '__main__':
    train_lstm()
