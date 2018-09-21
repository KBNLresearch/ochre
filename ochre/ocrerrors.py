#!/usr/bin/env python
# -*- coding: utf-8 -*-
import unicodedata
import six

import warnings

from collections import OrderedDict
from string import punctuation

from .rmgarbage import get_rmgarbage_errors


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
    error_types['garbage_string'] = garbage_string_error

    return error_types


def categorize_errors(df, terms=[], gs_name='gs', ocr_name='ocr'):
    df = df.copy()
    terms = set(terms)

    df['error_type'] = df.apply(find_errors, terms=terms, gs_name=gs_name,
                                ocr_name=ocr_name, axis=1)

    return df


def find_errors(row, terms, gs_name='gs', ocr_name='ocr', empty_word='@@@'):
    err_types = get_error_types()

    errors = []
    for err_name, err_function in err_types.items():
        if err_name == 'real_word':
            if err_function(row, terms, gs_name=gs_name, ocr_name=ocr_name,
                            empty_word=empty_word):
                errors.append(err_name)
        else:
            if err_function(row, gs_name=gs_name, ocr_name=ocr_name,
                            empty_word=empty_word):
                errors.append(err_name)

    if len(errors) == 1:
        return errors[0]
    elif len(errors) > 1:
        errs = u', '.join(errors)
        msg = u'Found multiple errors for "{}"-"{}" ({})'.format(row[gs_name],
                                                                 row[ocr_name],
                                                                 errs)
        warnings.warn(msg)
        return 'multiple'
    return 'other'


def num_errors(df, error_function, args=None):
    s = df[df.apply(error_function, args=args, axis=1)].shape
    return s[0]


def remove_errors(df, error_function, args=None):
    return df[df.apply(error_function, args=args, axis=1) == False]


def hyphenation_error(row, gs_name='gs', ocr_name='ocr', empty_word='@@@'):
    """Check wether row contains a word with a hyphenation error.

    """
    #ocr = 'gesta- tionneerd'
    #gs = 'gestationneerd'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if ocr != gs and ocr.replace(u'- ', u'') == gs:
        return True
    return False


def hyphenation_error2(row, gs_name='gs', ocr_name='ocr', empty_word='@@@'):
    #ocr = 'gesta-tionneerd'
    #gs = 'gestationneerd'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if ocr.replace(u'-', u'') == gs:
        return True
    return False


def case_error(row, gs_name='gs', ocr_name='ocr', empty_word='@@@'):
    #ocr = 'Woord'
    #gs = 'WOORD'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if ocr.lower() == gs.lower():
        return True
    return False


def punctuation_mark_error(row, gs_name='gs', ocr_name='ocr',
                           empty_word='@@@'):
    #ocr = '.'
    #gs = ','
    gs = row[gs_name]
    ocr = row[ocr_name]

    if ocr in punctuation and gs in punctuation:
        return True
    return False


def missing_punctuation_mark_error(row, gs_name='gs', ocr_name='ocr',
                                   empty_word='@@@'):
    #ocr = ''
    #gs = ','
    gs = row[gs_name]
    ocr = row[ocr_name]

    #print type(ocr)
    #print type(gs)

    if gs in punctuation and ocr == empty_word:
        return True
    return False


def number_error(row, gs_name='gs', ocr_name='ocr', empty_word='@@@'):
    #ocr = '64-jarige'
    #gs = '-jarig'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if filter(lambda x: not x.isdigit(), ocr) == filter(lambda x: not x.isdigit(), gs):
        return True
    return False


def whitespace_error(row, gs_name='gs', ocr_name='ocr', empty_word='@@@'):
    #ocr = 'Wo or'
    #gs = 'WOORD'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if u''.join(ocr.split()) == u''.join(gs.split()):
        return True
    return False


def accent_error(row, gs_name='gs', ocr_name='ocr', empty_word='@@@'):
    #gs = u'décors'
    #ocr = u'decors'

    gs = row[gs_name]
    ocr = row[ocr_name]

    no_accents = u''.join((c for c in unicodedata.normalize('NFD', six.text_type(gs)) if unicodedata.category(c) != 'Mn'))
    if no_accents == ocr:
        return True

    no_accents = u''.join((c for c in unicodedata.normalize('NFD', six.text_type(ocr)) if unicodedata.category(c) != 'Mn'))
    if no_accents == gs:
        return True
    return False


def missing_word_error(row, gs_name='gs', ocr_name='ocr', empty_word='@@@'):
    gs = row[gs_name]
    ocr = row[ocr_name]

    #print type(ocr)
    #print type(gs)

    if gs not in punctuation and ocr == u'@@@':
        #print gs
        return True
    return False


def real_word_error(row, terms, gs_name='gs', ocr_name='ocr',
                    empty_word='@@@'):
    if terms == []:
        warnings.warn('Word list is empty. So, not finding real word errors.')

    #gs = u'hallo'
    #ocr = u'boom'

    gs = row[gs_name]
    ocr = row[ocr_name]

    # Make sure accent_error and real_word_error are mutually exclusive
    if not accent_error(row, gs_name=gs_name, ocr_name=ocr_name):
        return ocr in terms
    return False


def garbage_string_error(row, gs_name='gs', ocr_name='ocr', empty_word='@@@'):
    #ocr = 'CslwWkrm bla'
    #gs = 'bla'
    gs = row[gs_name]
    ocr = row[ocr_name]

    if ocr != empty_word:
        words = ocr.split()
        for w in words:
            errors = get_rmgarbage_errors(w)
            if len(errors) > 0:
                return True
    return False
