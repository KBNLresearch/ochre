#!/usr/bin/env python
import click
import os
import json

from nlppln.utils import create_dirs, cwl_file
from ochre.utils import get_files


@click.command()
@click.argument('in_dir', type=click.Path(exists=True))
@click.argument('datadivision', type=click.File(encoding='utf-8'))
@click.option('--name', '-n', default='test')
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def command(in_dir, datadivision, name, out_dir):
    create_dirs(out_dir)

    div = json.load(datadivision)
    files_out = [cwl_file(f) for f in get_files(in_dir, div, name)]

    stdout_text = click.get_text_stream('stdout')
    stdout_text.write(json.dumps({'out_files': files_out}))

if __name__ == '__main__':
    command()
