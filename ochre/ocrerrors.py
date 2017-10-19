#!/usr/bin/env python
# -*- coding: utf-8 -*-
import unicodedata

from string import punctuation


def num_errors(df, error_function):
    s = df[df.apply(error_function, axis=1)].shape
    return s[0]


def remove_errors(df, error_function):
    return df[df.apply(error_function, axis=1) == False]


def hyphenation_error(row):
    """Check wether row contains a word with a hyphenation error.

    """
    #ocr = 'gesta- tionneerd'
    #gs = 'gestationneerd'
    gs = row['gs']
    ocr = row['ocr']

    if ocr != gs and ocr.replace(u'- ', u'') == gs:
        return True
    return False


def hyphenation_error2(row):
    #ocr = 'gesta-tionneerd'
    #gs = 'gestationneerd'
    gs = row['gs']
    ocr = row['ocr']

    if ocr.replace(u'-', u'') == gs:
        return True
    return False


def case_error(row):
    #ocr = 'Woord'
    #gs = 'WOORD'
    gs = row['gs']
    ocr = row['ocr']

    if ocr.lower() == gs.lower():
        return True
    return False


def punctuation_mark_error(row):
    #ocr = '.'
    #gs = ','
    gs = row['gs']
    ocr = row['ocr']

    if ocr in punctuation and gs in punctuation:
        return True
    return False


def number_error(row):
    #ocr = '64-jarige'
    #gs = '-jarig'
    gs = row['gs']
    ocr = row['ocr']

    if filter(lambda x: not x.isdigit(), ocr) == filter(lambda x: not x.isdigit(), gs):
        return True
    return False


def whitespace_error(row):
    #ocr = 'Wo or'
    #gs = 'WOORD'
    gs = row['gs']
    ocr = row['ocr']

    if u''.join(ocr.split()) == u''.join(gs.split()):
        return True
    return False


def accent_error(row):
    #gs = u'décors'
    #ocr = u'decors'

    gs = row['gs']
    ocr = row['ocr']

    no_accents = ''.join((c for c in unicodedata.normalize('NFD', gs) if unicodedata.category(c) != 'Mn'))
    if no_accents == ocr:
        return True
    return False
