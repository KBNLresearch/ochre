#!/usr/bin/env python
import click
import codecs
import json
import os
from nlppln.utils import create_dirs, get_files, cwl_file


@click.command()
@click.argument('in_dir', type=click.Path(exists=True))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def sac2gs_and_ocr(in_dir, out_dir):
    result = {}
    result['gs_de'] = []
    result['ocr_de'] = []
    result['gs_fr'] = []
    result['ocr_fr'] = []

    files = {}

    for i in range(1864, 1900):
        try:
            in_files = get_files(os.path.join(in_dir, str(i)))
            for fi in in_files:
                language = 'de'
                typ = 'gs'
                bn = os.path.basename(fi)

                if bn.endswith('ocr'):
                    typ = 'ocr'
                if 'fr' in bn:
                    language = 'fr'
                with codecs.open(fi, encoding='utf-8') as f:
                    text = f.read()
                fname = '{}-{}-{}.txt'.format(i, language, typ)
                out_file = os.path.join(out_dir, fname)
                create_dirs(out_file)
                with codecs.open(out_file, 'a', encoding='utf-8') as fo:
                    fo.write(text)
                if out_file not in files:
                    label = '{}_{}'.format(typ, language)
                    result[label].append(cwl_file(out_file))
                    files[out_file] = None
        except OSError:
            pass

    stdout_text = click.get_text_stream('stdout')
    stdout_text.write(json.dumps(result))


if __name__ == '__main__':
    sac2gs_and_ocr()
