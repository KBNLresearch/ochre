#!/usr/bin/env python
"""Select files that occur in both input directories and save them.

Given two input directories, create ocr and gs output directories containing
the files that occur in both.

Files are actually copied, to prevent problems with CWL outputs.
"""
import os
import click
import shutil

from nlppln.utils import get_files, create_dirs, out_file_name


def copy_file(fi, name, out_dir, dest):
    fo = out_file_name(os.path.join(out_dir, dest), name)
    print fo
    create_dirs(fo)
    shutil.copy2(fi, fo)


@click.command()
@click.argument('ocr_dir', type=click.Path(exists=True))
@click.argument('gs_dir', type=click.Path(exists=True))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def match_ocr_and_gs(ocr_dir, gs_dir, out_dir):
    create_dirs(out_dir)

    ocr_files = {os.path.basename(f): f for f in get_files(ocr_dir)}
    gs_files = {os.path.basename(f): f for f in get_files(gs_dir)}

    ocr = set(ocr_files.keys())
    gs = set(gs_files.keys())

    if len(ocr) == 0:
        raise ValueError('No ocr files in directory "{}".'.format(ocr_dir))
    if len(gs) == 0:
        raise ValueError('No gs files in directory "{}".'.format(gs_dir))

    keep = ocr.intersection(gs)

    if len(keep) == 0:
        raise ValueError('No matching ocr and gs files.')

    for name in keep:
        copy_file(ocr_files[name], name, out_dir, 'ocr')
        copy_file(gs_files[name], name, out_dir, 'gs')


if __name__ == '__main__':
    match_ocr_and_gs()
