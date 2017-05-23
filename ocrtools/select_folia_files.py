#!/usr/bin/env python
import click
import os
import json

from nlppln.utils import cwl_file


@click.command()
@click.argument('dir_in', type=click.Path(exists=True))
def command(dir_in):
    files_out = []

    newspapers = ['ad1951', 'nrc1950', 't1950', 'tr1950', 'vk1951']

    for np in newspapers:
        path = os.path.join(dir_in, np)
        for f in os.listdir(path):
            fi = os.path.join(path, f)
            if fi.endswith('.folia.xml'):
                files_out.append(cwl_file(fi))

    stdout_text = click.get_text_stream('stdout')
    stdout_text.write(json.dumps({'out_files': files_out}))


if __name__ == '__main__':
    command()
