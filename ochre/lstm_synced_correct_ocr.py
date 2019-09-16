#!/usr/bin/env python
import click
import codecs
import os
import numpy as np

from collections import Counter

from keras.models import load_model

from nlppln.utils import create_dirs, out_file_name

from .utils import get_char_to_int, get_int_to_char, read_text_to_predict
from .edlibutils import align_output_to_input


@click.command()
@click.argument('model', type=click.Path(exists=True))
@click.argument('charset', type=click.File(encoding='utf-8'))
@click.argument('text', type=click.File(encoding='utf-8'))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def lstm_synced_correct_ocr(model, charset, text, out_dir):
    create_dirs(out_dir)

    # load model
    model = load_model(model)
    conf = model.get_config()
    conf_result = conf[0].get('config').get('batch_input_shape')
    seq_length = conf_result[1]
    char_embedding = False
    if conf[0].get('class_name') == u'Embedding':
        char_embedding = True

    charset = charset.read()
    n_vocab = len(charset)
    char_to_int = get_char_to_int(charset)
    int_to_char = get_int_to_char(charset)
    lowercase = True
    for c in u'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
        if c in charset:
            lowercase = False
            break

    pad = u'\n'

    to_predict = read_text_to_predict(text.read(), seq_length, lowercase,
                                      n_vocab, char_to_int, padding_char=pad,
                                      char_embedding=char_embedding)

    outputs = []
    inputs = []

    predicted = model.predict(to_predict, verbose=0)
    for i, sequence in enumerate(predicted):
        predicted_indices = [np.random.choice(n_vocab, p=p) for p in sequence]
        pred_str = u''.join([int_to_char[j] for j in predicted_indices])
        outputs.append(pred_str)

        if char_embedding:
            indices = to_predict[i]
        else:
            indices = np.where(to_predict[i:i+1, :, :] == True)[2]
        inp = u''.join([int_to_char[j] for j in indices])
        inputs.append(inp)

    idx = 0
    counters = {}

    for input_str, output_str in zip(inputs, outputs):
        if pad in output_str:
            output_str2 = align_output_to_input(input_str, output_str,
                                                empty_char=pad)
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

    corrected_text = u''.join(agg_out)
    corrected_text = corrected_text.replace(pad, u'')

    out_file = out_file_name(out_dir, text.name)
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        f.write(corrected_text)


if __name__ == '__main__':
    lstm_synced_correct_ocr()
