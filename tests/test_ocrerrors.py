import pytest

from ochre.ocrerrors import hyphenation_error


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
