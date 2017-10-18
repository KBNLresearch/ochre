#!/usr/bin/env python
import click
import codecs
import os
import json
import re

from nlppln.utils import create_dirs, out_file_name


def align_characters(ocr, gs, cigar, empty_char='', sanity_check=True):
    matches = re.findall(r'(\d+)(.)', cigar)
    offset1 = 0
    offset2 = 0

    gs_a = []
    ocr_a = []

    for m in matches:
        n = int(m[0])
        typ = m[1]

        if typ == '=':
            # sanity check - strings should be equal
            if sanity_check:
                assert(ocr[offset1:offset1+n] == gs[offset2:offset2+n])

            for c in ocr[offset1:offset1+n]:
                ocr_a.append(c)
            for c in gs[offset2:offset2+n]:
                gs_a.append(c)

            offset1 += n
            offset2 += n
        elif typ == 'D':  # Inserted
            for _ in range(n):
                ocr_a.append(empty_char)
            for c in gs[offset2:offset2+n]:
                gs_a.append(c)

            offset2 += n
        elif typ == 'X':
            for c in ocr[offset1:offset1+n]:
                ocr_a.append(c)
            for c in gs[offset2:offset2+n]:
                gs_a.append(c)

            offset1 += n
            offset2 += n
        elif typ == 'I':  # Deleted
            for c in ocr[offset1:offset1+n]:
                ocr_a.append(c)
            for _ in range(n):
                gs_a.append(empty_char)

            offset1 += n
    return ocr_a, gs_a


@click.command()
@click.argument('ocr_text', type=click.File(mode='r', encoding='utf-8'))
@click.argument('gs_text', type=click.File(mode='r', encoding='utf-8'))
@click.argument('metadata', type=click.File(mode='r', encoding='utf-8'))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def command(ocr_text, gs_text, metadata, out_dir):
    create_dirs(out_dir)

    ocr = ocr_text.read()
    gs = gs_text.read()
    md = json.load(metadata)

    ocr_a, gs_a = align_characters(ocr, gs, md['cigar'])

    out_file = out_file_name(out_dir, md['doc_id'], 'json')
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        json.dump({'ocr': ocr_a, 'gs': gs_a}, f, encoding='utf-8', indent=4)


if __name__ == '__main__':
    command()
