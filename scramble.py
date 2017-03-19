#!/usr/bin/env python
import click
import codecs
import random

from nlppln.utils import create_dirs, out_file_name


@click.command()
#@click.argument('in_files', nargs=-1, type=click.Path(exists=True))
#@click.argument('out_dir', nargs=1, type=click.Path())
#def command(in_files, out_dir):
def command():
    #create_dirs(out_dir)

    #for fi in in_files:
    #    with codecs.open(fi, encoding='utf-8') as f:
    #        text = f.read()
    #        text = text.replace('\n', '')

    text = 'Dit is een tekst.'
    original = text

    scrambled = []

    for char in text:
        scramble = random.randint(1, 20)
        if scramble == 1 and not char.isspace():
            insert_char = random.randint(0, 1)
            new_char = chr(random.randint(32, 126))
            if bool(insert_char):
                scrambled.append(char)
            scrambled.append(new_char)
        else:
            scrambled.append(char)

    print ''.join(scrambled)


        #out_file = out_file_name(out_dir, fi, 'txt')
        #with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        #    pass


if __name__ == '__main__':
    command()
