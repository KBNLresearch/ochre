#!/usr/bin/env python
import click
import os
import json

import pandas as pd

from string import punctuation

from nlppln.utils import create_dirs, remove_ext, out_file_name
from nlppln.commands.pattern_nl import parse


def find_word_boundaries(txt, aligned):
    words = [w['word'] for w in parse(txt)]

    unaligned = []
    for w in words:
        for c in w:
            unaligned.append(c)
        unaligned.append('@')

    i = 0
    j = 0
    prev = 0
    wb = []
    while i < len(aligned) and j < len(unaligned):
        if unaligned[j] == '@':
            w = u''.join(aligned[prev:i])
            # Punctuation that occurs in the ocr but not in the gold standard
            # is ignored.
            if len(w) > 1 and (w[0] == u' ' or w[0] in punctuation):
                s = prev + 1
            else:
                s = prev
            wb.append((s, i))
            prev = i
            j += 1
        elif aligned[i] == '' or aligned[i] == ' ':
            i += 1
        elif aligned[i] == unaligned[j]:
            i += 1
            j += 1
        else:
            i += 1
    # add last word
    wb.append((prev, len(aligned)))
    return wb


@click.command()
@click.argument('txt', type=click.File(encoding='utf-8'))
@click.argument('alignments', type=click.File(encoding='utf-8'))
@click.option('--lowercase/--no-lowercase', default=False)
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def create_word_mappings(txt, alignments, lowercase, out_dir):
    create_dirs(out_dir)

    alignment_data = json.load(alignments)
    aligned1 = alignment_data['gs']
    aligned2 = alignment_data['ocr']

    t = txt.read()
    if lowercase:
        t = t.lower()
        aligned1 = [c.lower() for c in aligned1]
        aligned2 = [c.lower() for c in aligned2]

    wb = find_word_boundaries(t, aligned1)

    doc_id = remove_ext(alignments.name)

    res = {'gs': [], 'ocr': []}
    for s, e in wb:
        w1 = u''.join(aligned1[s:e])
        w2 = u''.join(aligned2[s:e])

        res['gs'].append(w1.strip())
        res['ocr'].append(w2.strip())

    # Use pandas DataFrame to create the csv, so commas and quotes are properly
    # escaped.
    df = pd.DataFrame(res)

    out_file = out_file_name(out_dir, doc_id, ext='csv')
    df.to_csv(out_file, encoding='utf-8')

if __name__ == '__main__':
    create_word_mappings()
