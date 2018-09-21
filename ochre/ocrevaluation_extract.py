#!/usr/bin/env python
import click
import codecs
import os
import tempfile

from bs4 import BeautifulSoup

from nlppln.utils import create_dirs, remove_ext


@click.command()
@click.argument('in_file', type=click.File(encoding='utf-8'))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def ocrevaluation_extract(in_file, out_dir):
    create_dirs(out_dir)

    tables = []

    write = False

    (fd, tmpfile) = tempfile.mkstemp()
    with codecs.open(tmpfile, 'w', encoding='utf-8') as tmp:
        for line in in_file:
            if line.startswith('<h2>General'):
                write = True
            if line.startswith('<h2>Difference'):
                write = False
            if line.startswith('<h2>Error'):
                write = True

            if write:
                tmp.write(line)

    with codecs.open(tmpfile, encoding='utf-8') as f:
        soup = BeautifulSoup(f.read(), 'lxml')
    os.remove(tmpfile)

    tables = soup.find_all('table')
    assert len(tables) == 2

    doc = remove_ext(in_file.name)

    t = tables[0]
    table_data = [[cell.text for cell in row('td')] for row in t('tr')]

    # 'transpose' table_data
    lines = {}
    for data in table_data:
        for i, entry in enumerate(data):
            if i not in lines.keys():
                # add doc id to data line (but not to header)
                if i != 0:
                    lines[i] = [doc]
                else:
                    lines[i] = ['']
            lines[i].append(entry)

    out_file = os.path.join(out_dir, '{}-global.csv'.format(doc))
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        for i in range(len(lines.keys())):
            f.write(u','.join(lines[i]))
            f.write(u'\n')

    t = tables[1]
    table_data = [[cell.text for cell in row('td')] for row in t('tr')]
    out_file = os.path.join(out_dir, '{}-character.csv'.format(doc))
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        for data in table_data:
            f.write(u'"{}",'.format(data[0]))
            f.write(u','.join(data[1:]))
            f.write(u'\n')


if __name__ == '__main__':
    ocrevaluation_extract()
