#!/usr/bin/env python
import click
import os
import json

from nlppln.utils import create_dirs, remove_ext, cwl_file


def match(name, beginnings):
    for b in beginnings:
        if name.startswith(b) and name[len(b)] in ('.', '_', '-'):
            return True
    return False


def get_files(in_dir, div, name):
    files_out = []

    files = [remove_ext(f) for f in div.get(name, [])]

    for f in os.listdir(in_dir):
        fi = os.path.join(in_dir, f)
        if os.path.isfile(fi) and match(f, files):
            files_out.append(fi)
    files_out.sort()
    return files_out


@click.command()
@click.argument('in_dir', type=click.Path(exists=True))
@click.argument('datadivision', type=click.File(encoding='utf-8'))
@click.option('--name', '-n', type=click.Choice(['train', 'test', 'val']),
              default='test')
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def command(in_dir, datadivision, name, out_dir):
    create_dirs(out_dir)

    div = json.load(datadivision)
    files_out = [cwl_file(f) for f in get_files(in_dir, div, name)]

    stdout_text = click.get_text_stream('stdout')
    stdout_text.write(json.dumps({'out_files': files_out}))

if __name__ == '__main__':
    command()
