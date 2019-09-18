#!/usr/bin/env python
import click
import os
import json

from nlppln.utils import create_dirs

from ochre.create_word_mappings import find_word_boundaries


@click.command()
@click.argument('saf', type=click.File(encoding='utf-8'))
@click.argument('alignments', type=click.File(encoding='utf-8'))
@click.option('--lowercase/--no-lowercase', default=False)
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def create_sentence_mappings(saf, alignments, lowercase, out_dir):
    create_dirs(out_dir)

    alignment_data = json.load(alignments)
    aligned1 = alignment_data['gs']
    aligned2 = alignment_data['ocr']

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

    stdout_text = click.get_text_stream('stdout')

    for s, e in wb:
        s1 = u''.join(aligned1[s:e])
        s2 = u''.join(aligned2[s:e])

        stdout_text.write(u'{}||@@||{}\n'.format(s1.strip(), s2.strip()))


if __name__ == '__main__':
    create_sentence_mappings()
