import click
import codecs
import os
import json

from nlppln.utils import out_file_name
from ochre.utils import get_files


@click.command()
@click.argument('datadivision', type=click.File(encoding='utf-8'))
@click.argument('in_dir', type=click.Path(exists=True))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def concat_files(datadivision, in_dir, out_dir):
    div = json.load(datadivision)
    new_div = {}

    for name in div.keys():
        print(name)
        in_files = get_files(in_dir, div, name)

        out_file = out_file_name(out_dir, name, ext='txt')
        new_div[name] = [os.path.basename(out_file_name(out_dir, name, ext='json'))]

        with codecs.open(out_file, 'a', encoding='utf-8') as fo:
            for in_file in in_files:
                with codecs.open(in_file, 'r', encoding='utf-8') as fi:
                    text = fi.read()
                    text = text.replace(u'\n', u'')
                    text = text.strip()

                fo.write(text)
                fo.write(u'\n')

    print(json.dumps(new_div))


if __name__ == '__main__':
    concat_files()
