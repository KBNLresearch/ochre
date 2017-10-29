#!/usr/bin/env python
import click
import codecs
import json
import os

from nlppln.utils import create_dirs, remove_ext


@click.command()
@click.argument('json_file', type=click.File(encoding='utf-8'))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def clin2018st_extract_text(json_file, out_dir):
    create_dirs(out_dir)

    corrections = {}
    gs_text = []
    text_with_errors = []

    text = json.load(json_file)
    for w in text['corrections']:
        span = w['span']
        # TODO: fix 'after'
        if 'after' in w.keys():
            print 'Found "after" in {}.'.format(os.path.basename(json_file.name))
        for i, w_id in enumerate(span):
            corrections[w_id] = {}
            if i == 0:
                corrections[w_id]['text'] = w['text']
            else:
                corrections[w_id]['text'] = u''
            corrections[w_id]['last'] = False
            if i == (len(span) - 1):
                corrections[w_id]['last'] = True

    for w in text['words']:
        w_id = w['id']
        gs_text.append(w['text'])
        if w_id in corrections.keys():
            text_with_errors.append(corrections[w_id]['text'])
        else:
            text_with_errors.append(w['text'])
        if w['space']:
            gs_text.append(u' ')
            text_with_errors.append(u' ')

    gs_file = remove_ext(json_file.name)
    gs_file = os.path.join(out_dir, '{}-gs.txt'.format(gs_file))
    with codecs.open(gs_file, 'wb', encoding='utf-8') as f:
        f.write(u''.join(gs_text))

    err_file = remove_ext(json_file.name)
    err_file = os.path.join(out_dir, '{}-errors.txt'.format(err_file))
    with codecs.open(err_file, 'wb', encoding='utf-8') as f:
        f.write(u''.join(text_with_errors))


if __name__ == '__main__':
    clin2018st_extract_text()
