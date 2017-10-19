import click
import json
import os
import glob

from nlppln.utils import cwl_file


@click.command()
@click.argument('in_dir', type=click.Path(exists=True))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def select(in_dir, out_dir):
    gs_files = sorted(glob.glob('{}{}*.gs.txt'.format(in_dir, os.sep)))
    gs_files = [cwl_file(os.path.abspath(f)) for f in gs_files]

    ocr_files = sorted(glob.glob('{}{}*.ocr.txt'.format(in_dir, os.sep)))
    ocr_files = [cwl_file(os.path.abspath(f)) for f in ocr_files]

    stdout_text = click.get_text_stream('stdout')
    stdout_text.write(json.dumps({'ocr_files': ocr_files,
                                  'gs_files': gs_files}))


if __name__ == '__main__':
    select()
