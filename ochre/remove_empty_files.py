import click
import json
import os
import glob
import codecs

from nlppln.utils import cwl_file


@click.command()
@click.argument('in_dir', type=click.Path(exists=True))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def remove_empty_files(in_dir, out_dir):
    ocr_out = []
    gs_out = []

    ocr_files = glob.glob('{}{}*.ocr.txt'.format(in_dir, os.sep))
    gs_files = glob.glob('{}{}*.gs.txt'.format(in_dir, os.sep))

    for ocr, gs in zip(sorted(ocr_files), sorted(gs_files)):
        with codecs.open(ocr, 'r', encoding='utf-8') as f:
            ocr_text = f.read()

        with codecs.open(gs, 'r', encoding='utf-8') as f:
            gs_text = f.read()

        if len(ocr_text) > 0 and len(gs_text) > 0:
            ocr_out.append(cwl_file(ocr))
            gs_out.append(cwl_file(gs))

    stdout_text = click.get_text_stream('stdout')
    stdout_text.write(json.dumps({'ocr': ocr_out, 'gs': gs_out}))


if __name__ == '__main__':
    remove_empty_files()
