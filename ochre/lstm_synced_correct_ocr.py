#!/usr/bin/env python
import click
import codecs
import os
import numpy as np

from collections import Counter

from keras.models import load_model

from nlppln.utils import create_dirs, out_file_name, get_files

from utils import get_char_to_int, get_int_to_char, read_texts, create_synced_data, align_output_to_input


@click.command()
@click.argument('model', type=click.Path(exists=True))
@click.argument('charset', type=click.File(encoding='utf-8'))
@click.argument('text', type=click.Path(exists=True))
#@click.option('--name', '-n', default='metadata_out.csv')
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def lstm_synced_correct_ocr(model, charset, text, out_dir):
    create_dirs(out_dir)

    # load model
    model = load_model(model)
    conf = model.get_config()
    _, seq_length, batch_size = conf[0].get('config').get('batch_input_shape')

    charset = charset.read()
    n_vocab = len(charset)
    char_to_int = get_char_to_int(charset)
    int_to_char = get_int_to_char(charset)
    lowercase = True
    for c in u'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
        if c in charset:
            lowercase = False
            break

    raw_test, gs_test, ocr_test = read_texts([text], None)

    numTestSamples, testDataGen = create_synced_data(ocr_test, gs_test,
                                                     char_to_int, n_vocab,
                                                     seq_length=seq_length,
                                                     batch_size=batch_size,
                                                     lowercase=lowercase)
    xTest = np.zeros((numTestSamples, seq_length, n_vocab))
    yTest = np.zeros((numTestSamples, seq_length, n_vocab))

    steps = 0
    idx = 0
    for xBatch, yBatch in testDataGen:
        for x, y in zip(xBatch, yBatch):
            if idx < numTestSamples:
                xTest[idx, :, :] = x
                yTest[idx, :, :] = y
            idx += 1

        if steps == int(numTestSamples/batch_size):
            break
        steps += 1

    outputs = []
    inputs = []

    predicted = model.predict(xTest, verbose=0)
    for i, sequence in enumerate(predicted):
        predicted_indices = [np.random.choice(n_vocab, p=p) for p in sequence]
        pred_str = u''.join([int_to_char[j] for j in predicted_indices])
        pred_str = pred_str.replace(u'\n', u'@')
        outputs.append(pred_str)

        indices = np.where(xTest[i:i+1, :, :] == True)[2]
        inp = u''.join([int_to_char[j] for j in indices])
        inp = inp.replace(u'\n', u'@')
        inputs.append(inp)

    idx = 0
    counters = {}

    for input_str, output_str in zip(inputs, outputs):
        if u'@' in output_str:
            output_str2 = align_output_to_input(input_str, output_str.replace(u'@', u''), empty_char=u'@')
        else:
            output_str2 = output_str
        for i, (inp, outp) in enumerate(zip(input_str, output_str2)):
            if not idx + i in counters.keys():
                counters[idx+i] = Counter()
            counters[idx+i][outp] += 1

        idx += 1

    agg_out = []
    for idx, c in counters.items():
        agg_out.append(c.most_common(1)[0][0])

    new_text = u''.join(agg_out)
    new_text = new_text.replace(u'@', u'')

    out_file = out_file_name(out_dir, text, ext='txt')
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        f.write(new_text)


if __name__ == '__main__':
    lstm_synced_correct_ocr()
