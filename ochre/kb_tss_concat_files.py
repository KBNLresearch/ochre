import click
import codecs
import os
from collections import Counter

from nlppln.utils import get_files, out_file_name


@click.command()
@click.argument('in_dir', type=click.Path(exists=True))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def concat_files(in_dir, out_dir):
    in_files = get_files(in_dir)

    counts = Counter()

    for in_file in in_files:
        parts = os.path.basename(in_file).split(u'_')
        prefix = u'_'.join(parts[:2])
        counts[prefix] += 1

        out_file = out_file_name(out_dir, prefix, ext='txt')

        with codecs.open(in_file, 'r', encoding='utf-8') as fi:
            text = fi.read()
            text = text.replace(u'\n', u'')
            text = text.strip()

        with codecs.open(out_file, 'a', encoding='utf-8') as fo:
            fo.write(text)
            fo.write(u'\n')


if __name__ == '__main__':
    concat_files()
