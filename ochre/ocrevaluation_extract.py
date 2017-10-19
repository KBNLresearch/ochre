#!/usr/bin/env python
import click
import codecs
import os

from bs4 import BeautifulSoup

from nlppln.utils import create_dirs, remove_ext


@click.command()
@click.argument('in_file', type=click.File())
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def ocrevaluation_extract(in_file, out_dir):
    create_dirs(out_dir)

    soup = BeautifulSoup(in_file, 'lxml')
    tables = soup.find_all('table')
    assert len(tables) == 3

    doc = remove_ext(in_file.name)

    # global measures: table[0]
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

    # character measures: table[2]
    t = tables[2]
    table_data = [[cell.text for cell in row('td')] for row in t('tr')]
    out_file = os.path.join(out_dir, '{}-character.csv'.format(doc))
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        for data in table_data:
            f.write(u'"{}",'.format(data[0]))
            f.write(u','.join(data[1:]))
            f.write(u'\n')


if __name__ == '__main__':
    ocrevaluation_extract()
