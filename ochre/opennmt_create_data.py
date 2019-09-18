#!/usr/bin/env python
import click
import os
import json
import codecs

from nlppln.utils import create_dirs, out_file_name

from ochre.create_word_mappings import find_word_boundaries


@click.command()
@click.argument('saf', type=click.File(encoding='utf-8'))
@click.argument('alignments', type=click.File(encoding='utf-8'))
@click.option('--lowercase/--no-lowercase', default=False)
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def opennmt_create_data(saf, alignments, lowercase, space, out_dir):
    create_dirs(out_dir)

    alignment_data = json.load(alignments)
    aligned1 = alignment_data['gs']    # src
    aligned2 = alignment_data['ocr']   # tgt

    saf = json.load(saf)
    s_id = saf['tokens'][0]['sentence']

    sentences = []
    sentence = []
    for w in saf['tokens']:
        if w['sentence'] != s_id:
            sentences.append(u''.join(sentence))
            sentence = []
            s_id = w['sentence']
        sentence.append(w['word'])

    if lowercase:
        sentences = [s.lower() for s in sentences]

        aligned1 = [c.lower() for c in aligned1]
        aligned2 = [c.lower() for c in aligned2]

    wb = find_word_boundaries(sentences, aligned1)

    bn = os.path.splitext(os.path.basename(alignments.name))[0]
    fname_src = out_file_name(out_dir, '{}.raw.src.txt'.format(bn))
    fname_tgt = out_file_name(out_dir, '{}.raw.tgt.txt'.format(bn))

    with codecs.open(fname_src, 'wb', encoding='utf-8') as src:
        with codecs.open(fname_tgt, 'wb', encoding='utf-8') as tgt:

            for s, e in wb:
                s1 = u''.join(aligned1[s:e]).strip()
                s2 = u''.join(aligned2[s:e]).strip()

                tgt.write(u'{}\n'.format(s1))
                src.write(u'{}\n'.format(s2))


if __name__ == '__main__':
    opennmt_create_data()
