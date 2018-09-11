#!/usr/bin/env python
import click
import codecs
import os
import json

from nlppln.utils import create_dirs, out_file_name

from .utils import align_characters


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

    check = True
    # Too many strange characters, so disable sanity check
    if len(set(ocr+gs)) > 127:
        check = False

    ocr_a, gs_a = align_characters(ocr, gs, md['cigar'], sanity_check=check)

    out_file = out_file_name(out_dir, md['doc_id'], 'json')
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        try:
            json.dump({'ocr': ocr_a, 'gs': gs_a}, f, encoding='utf-8')
        except TypeError:
            json.dump({'ocr': ocr_a, 'gs': gs_a}, f)


if __name__ == '__main__':
    command()
