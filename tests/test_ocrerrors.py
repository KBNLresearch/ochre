# -*- coding: utf-8 -*-
import pytest

from ochre.ocrerrors import hyphenation_error, accent_error, real_word_error


def test_hyphenation_error_true():
    row = {'ocr': u'gesta- tionneerd',
           'gs': u'gestationneerd'
           }
    assert hyphenation_error(row) is True


def test_hyphenation_error_false():
    row = {'ocr': u'gestationneerd',
           'gs': u'gestationneerd'
           }
    assert hyphenation_error(row) is False


def test_accent_error_true():
    row = {'ocr': u'patienten',
           'gs': u'patiënten'
           }
    assert accent_error(row) is True


def test_accent_error_true_ocr():
    row = {'ocr': u'patiënten',
           'gs': u'patienten'
           }
    assert accent_error(row) is True


def test_real_word_error_vs_accent_error():
    row = {'ocr': u'zeker',
           'gs': u'zéker'
           }
    terms = ['zeker']
    assert real_word_error(row, terms) is False
    assert accent_error(row) is True
