#!/usr/bin/env python
import click
import codecs
import os
import json

from nlppln.utils import create_dirs, out_file_name


def to_character_list(string):
    l = []
    for c in string:
        if c in ('@', '#'):
            l.append('')
        else:
            l.append(c)
    return l


@click.command()
@click.argument('in_file', type=click.File(encoding='utf-8'))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def command(in_file, out_dir):
    create_dirs(out_dir)

    lines = in_file.readlines()
    # OCR_toInput: lines[0][:14]
    # OCR_aligned: lines[1][:14]
    # GS_aligned: lines[2][:14]
    ocr = to_character_list(lines[1][14:].strip())
    gs = to_character_list(lines[2][14:].strip())

    # Write texts
    out_file = out_file_name(os.path.join(out_dir, 'ocr'), os.path.basename(in_file.name))
    print(out_file)
    create_dirs(out_file)
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        f.write(u''.join(ocr))

    out_file = out_file_name(os.path.join(out_dir, 'gs'), os.path.basename(in_file.name))
    print(out_file)
    create_dirs(out_file)
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        f.write(u''.join(gs))

    out_file = out_file_name(out_dir, os.path.basename(in_file.name), 'json')
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        json.dump({'ocr': ocr, 'gs': gs}, f, encoding='utf-8', indent=4)

#        out_file = out_file_name(out_dir, fi, 'json')
#        with codecs.open(out_file, 'wb', encoding='utf-8') as f:
#            pass


if __name__ == '__main__':
    command()
