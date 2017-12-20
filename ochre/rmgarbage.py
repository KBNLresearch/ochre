#!/usr/bin/env python
"""Implementation of rmgarbage.

As described in the paper:

    Taghva, K., Nartker, T., Condit, A. and Borsack, J., 2001. Automatic
    removal of "garbage strings" in OCR text: An implementation. In The 5th
    World Multi-Conference on Systemics, Cybernetics and Informatics.
"""
import click
import codecs
import os
import re
import pandas as pd

from string import punctuation

from nlppln.utils import create_dirs, out_file_name


def get_rmgarbage_errors(word):
    errors = []
    if rmgarbage_long(word):
        errors.append('L')
    if rmgarbage_alphanumeric(word):
        errors.append('A')
    if rmgarbage_row(word):
        errors.append('R')
    if rmgarbage_vowels(word):
        errors.append('V')
    if rmgarbage_punctuation(word):
        errors.append('P')
    if rmgarbage_case(word):
        errors.append('C')
    return errors


def rmgarbage_long(string, threshold=40):
    if len(string) > threshold:
        return True
    return False


def rmgarbage_alphanumeric(string):
    alphanumeric_chars = sum(c.isalnum() for c in string)
    if len(string) > 2 and (alphanumeric_chars+0.0)/len(string) < 0.5:
        return True
    return False


def rmgarbage_row(string, rep=4):
    # TODO: deal with accented characters
    for c in string:
        if c.isalnum():
            pattern = r'{}{{{}}}'.format(c, rep)
            if re.search(pattern, string):
                return True
    return False


def rmgarbage_vowels(string):
    # TODO: deal with accented characters
    string = string.lower()
    if len(string) > 2 and string.isalpha():
        vowels = sum(c in 'aeuio' for c in string)
        consonants = len(string) - vowels

        low = min(vowels, consonants)
        high = max(vowels, consonants)

        if low/(high+0.0) <= 0.1:
            return True
    return False


def rmgarbage_punctuation(string):
    string = string[1:len(string)-1]

    punctuation_marks = set()
    for c in string:
        if c in punctuation:
            punctuation_marks.add(c)

            if len(punctuation_marks) > 1:
                return True
    return False


def rmgarbage_case(string):
    if string[0].islower() and string[len(string)-1].islower():
        for c in string:
            if c.isupper():
                return True
    return False


@click.command()
@click.argument('in_file', type=click.File(encoding='utf-8'))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def rmgarbage(in_file, out_dir):
    create_dirs(out_dir)

    text = in_file.read()
    words = text.split()

    doc_id = os.path.basename(in_file.name).split('.')[0]

    result = []
    removed = []

    for word in words:
        errors = get_rmgarbage_errors(word)

        if len(errors) == 0:
            result.append(word)
        else:
            removed.append({'word': word,
                            'errors': u''.join(errors),
                            'doc_id': doc_id})

    out_file = out_file_name(out_dir, in_file.name)
    with codecs.open(out_file, 'wb', encoding='utf-8') as f:
        f.write(u' '.join(result))

    metadata_out = pd.DataFrame(removed)
    fname = '{}-rmgarbage-metadata.csv'.format(doc_id)
    out_file = out_file_name(out_dir, fname)
    metadata_out.to_csv(out_file, encoding='utf-8')


if __name__ == '__main__':
    rmgarbage()
