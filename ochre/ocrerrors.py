#!/usr/bin/env python
# -*- coding: utf-8 -*-
import unicodedata

import warnings

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


def categorize_errors(df, terms, gs_name='gs', ocr_name='ocr'):
    df = df.copy()
    err_types = get_error_types()

    total_errors = 0
    for err_name, err_function in err_types.items():
        if err_name == 'real_word':
            df[err_name] = df.apply(err_function, args=(terms,),
                                    gs_name=gs_name, ocr_name=ocr_name, axis=1)
        else:
            df[err_name] = df.apply(err_function, gs_name=gs_name,
                                    ocr_name=ocr_name, axis=1)
        total_errors += df[err_name].sum()

    if total_errors != df.shape[0]:
        msg = 'The number of errors classified ({}) is not equal to the ' \
              'number of errors in the input ({}).'.format(total_errors,
                                                           df.shape[0])
        warnings.warn(msg)

    return df


def num_errors(df, error_function, args=None):
    s = df[df.apply(error_function, args=args, axis=1)].shape
    return s[0]


def remove_errors(df, error_function, args=None):
    return df[df.apply(error_function, args=args, axis=1) == False]


def hyphenation_error(row, gs_name='gs', ocr_name='ocr'):
    """Check wether row contains a word with a hyphenation error.

    """
    #ocr = 'gesta- tionneerd'
    #gs = 'gestationneerd'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if ocr != gs and ocr.replace(u'- ', u'') == gs:
        return True
    return False


def hyphenation_error2(row, gs_name='gs', ocr_name='ocr'):
    #ocr = 'gesta-tionneerd'
    #gs = 'gestationneerd'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if ocr.replace(u'-', u'') == gs:
        return True
    return False


def case_error(row, gs_name='gs', ocr_name='ocr'):
    #ocr = 'Woord'
    #gs = 'WOORD'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if ocr.lower() == gs.lower():
        return True
    return False


def punctuation_mark_error(row, gs_name='gs', ocr_name='ocr'):
    #ocr = '.'
    #gs = ','
    gs = row[gs_name]
    ocr = row[ocr_name]

    if ocr in punctuation and gs in punctuation:
        return True
    return False


def missing_punctuation_mark_error(row, gs_name='gs', ocr_name='ocr'):
    #ocr = ''
    #gs = ','
    gs = row[gs_name]
    ocr = row[ocr_name]

    #print type(ocr)
    #print type(gs)

    if gs in punctuation and ocr == u'@@@':
        return True
    return False


def number_error(row, gs_name='gs', ocr_name='ocr'):
    #ocr = '64-jarige'
    #gs = '-jarig'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if filter(lambda x: not x.isdigit(), ocr) == filter(lambda x: not x.isdigit(), gs):
        return True
    return False


def whitespace_error(row, gs_name='gs', ocr_name='ocr'):
    #ocr = 'Wo or'
    #gs = 'WOORD'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if u''.join(ocr.split()) == u''.join(gs.split()):
        return True
    return False


def accent_error(row, gs_name='gs', ocr_name='ocr'):
    #gs = u'décors'
    #ocr = u'decors'

    gs = row[gs_name]
    ocr = row[ocr_name]

    no_accents = u''.join((c for c in unicodedata.normalize('NFD', unicode(gs)) if unicodedata.category(c) != 'Mn'))
    if no_accents == ocr:
        return True
    return False


def missing_word_error(row, gs_name='gs', ocr_name='ocr'):
    gs = row[gs_name]
    ocr = row[ocr_name]

    #print type(ocr)
    #print type(gs)

    if gs not in punctuation and ocr == u'@@@':
        #print gs
        return True
    return False


def real_word_error(row, terms, gs_name='gs', ocr_name='ocr'):
    #gs = u'hallo'
    #ocr = u'boom'

    gs = row[gs_name]
    ocr = row[ocr_name]

    # Make sure accent_error and real_word_error are mutually exclusive
    if not accent_error(row, gs_name=gs_name, ocr_name=ocr_name):
        return ocr in terms
    return False


def other_error(row, gs_name='gs', ocr_name='ocr'):
    num_false = 0
    err_types = get_error_types()
    del(err_types['other'])
    for err_type in err_types:
        if row[err_type] == False:
            num_false += 1
    if num_false == len(err_types.keys()):
        return True
    return False
