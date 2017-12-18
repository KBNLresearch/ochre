#!/usr/bin/env python
# -*- coding: utf-8 -*-
import unicodedata

from collections import OrderedDict
from string import punctuation


def get_error_types():
    error_types = OrderedDict()
    error_types['hyphenation'] = hyphenation_error
    error_types['hyphenation2'] = hyphenation_error2
    error_types['case'] = case_error
    error_types['punctuation'] = punctuation_mark_error
    error_types['missing_punctuation'] = missing_punctuation_mark_error
    error_types['missing_word'] = missing_word_error
    error_types['number'] = number_error
    error_types['whitespace'] = whitespace_error
    error_types['accent'] = accent_error
    error_types['real_word'] = real_word_error
    error_types['other'] = other_error

    return error_types


def num_errors(df, error_function, args=None):
    s = df[df.apply(error_function, args=args, axis=1)].shape
    return s[0]


def remove_errors(df, error_function, args=None):
    return df[df.apply(error_function, args=args, axis=1) == False]


def hyphenation_error(row, gs='gs', ocr='ocr'):
    """Check wether row contains a word with a hyphenation error.

    """
    #ocr = 'gesta- tionneerd'
    #gs = 'gestationneerd'
    gs = row[gs]
    ocr = row[ocr]

    if ocr != gs and ocr.replace(u'- ', u'') == gs:
        return True
    return False


def hyphenation_error2(row, gs='gs', ocr='ocr'):
    #ocr = 'gesta-tionneerd'
    #gs = 'gestationneerd'
    gs = row[gs]
    ocr = row[ocr]

    if ocr.replace(u'-', u'') == gs:
        return True
    return False


def case_error(row, gs='gs', ocr='ocr'):
    #ocr = 'Woord'
    #gs = 'WOORD'
    gs = row[gs]
    ocr = row[ocr]

    if ocr.lower() == gs.lower():
        return True
    return False


def punctuation_mark_error(row, gs='gs', ocr='ocr'):
    #ocr = '.'
    #gs = ','
    gs = row[gs]
    ocr = row[ocr]

    if ocr in punctuation and gs in punctuation:
        return True
    return False


def missing_punctuation_mark_error(row, gs='gs', ocr='ocr'):
    #ocr = ''
    #gs = ','
    gs = row[gs]
    ocr = row[ocr]

    #print type(ocr)
    #print type(gs)

    if gs in punctuation and ocr == u'@@@':
        return True
    return False


def number_error(row, gs='gs', ocr='ocr'):
    #ocr = '64-jarige'
    #gs = '-jarig'
    gs = row[gs]
    ocr = row[ocr]

    if filter(lambda x: not x.isdigit(), ocr) == filter(lambda x: not x.isdigit(), gs):
        return True
    return False


def whitespace_error(row, gs='gs', ocr='ocr'):
    #ocr = 'Wo or'
    #gs = 'WOORD'
    gs = row[gs]
    ocr = row[ocr]

    if u''.join(ocr.split()) == u''.join(gs.split()):
        return True
    return False


def accent_error(row, gs='gs', ocr='ocr'):
    #gs = u'décors'
    #ocr = u'decors'

    gs = row[gs]
    ocr = row[ocr]

    no_accents = u''.join((c for c in unicodedata.normalize('NFD', unicode(gs)) if unicodedata.category(c) != 'Mn'))
    if no_accents == ocr:
        return True
    return False


def missing_word_error(row, gs='gs', ocr='ocr'):
    gs = row[gs]
    ocr = row[ocr]

    #print type(ocr)
    #print type(gs)

    if gs not in punctuation and ocr == u'@@@':
        #print gs
        return True
    return False


def real_word_error(row, terms, gs='gs', ocr='ocr'):
    #gs = u'hallo'
    #ocr = u'boom'

    gs = row[gs]
    ocr = row[ocr]

    return ocr in terms


def other_error(row, gs='gs', ocr='ocr'):
    num_false = 0
    err_types = get_error_types()
    del(err_types['other'])
    for err_type in err_types:
        if row[err_type] == False:
            num_false += 1
    if num_false == len(err_types.keys()):
        return True
    return False
