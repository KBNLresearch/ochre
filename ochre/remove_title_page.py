#!/usr/bin/env python
import click
import os
import edlib
import warnings
import codecs
import shutil

from nlppln.utils import out_file_name


@click.command()
@click.argument('txt_file_without_tp', type=click.File(encoding='utf-8'))
@click.argument('txt_file_with_tp', type=click.File(encoding='utf-8'))
@click.option('--num_lines', '-n', default=100)
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def remove_title_page(txt_file_without_tp, txt_file_with_tp, num_lines,
                      out_dir):
    result = None
    lines_without = txt_file_without_tp.readlines()
    lines_with = txt_file_with_tp.readlines()

    without_txt = ''.join(lines_without[:num_lines]).lower()
    with_txt = ''.join(lines_with[:num_lines]).lower()
    res = edlib.align(without_txt, with_txt)
    prev_ld = res['editDistance']

    for i in range(num_lines):
        without_txt = ''.join(lines_without[:num_lines]).lower()
        with_txt = ''.join(lines_with[i:num_lines]).lower()

        res = edlib.align(without_txt, with_txt)
        ld = res['editDistance']

        if ld > prev_ld:
            result = ''.join(lines_with[i-1:])
            break
        elif ld < prev_ld:
            prev_ld = ld

    if result is None:
        warnings.warn('No title page found')
        out_file = out_file_name(out_dir, txt_file_with_tp.name)
        shutil.copy2(txt_file_with_tp.name, out_file)
    else:
        out_file = out_file_name(out_dir, txt_file_with_tp.name)
        with codecs.open(out_file, 'w', encoding='utf8') as f:
            f.write(result)


if __name__ == '__main__':
    remove_title_page()
