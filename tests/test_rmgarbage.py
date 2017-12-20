# -*- coding: utf-8 -*-
from ochre.rmgarbage import rmgarbage_long, rmgarbage_alphanumeric, \
                            rmgarbage_row, rmgarbage_vowels, \
                            rmgarbage_punctuation, rmgarbage_case


def test_rmgarbage_long():
    assert rmgarbage_long('short') is False
    long_string = 'Ii'*21
    assert rmgarbage_long(long_string) is True


def test_rmgarbage_alphanumeric():
    assert rmgarbage_alphanumeric('.M~y~l~i~c~.I~') is True
    assert rmgarbage_alphanumeric('______________J.~:ys~,.<F9>j}ss.') is True
    assert rmgarbage_alphanumeric('14.9tv="~;<F9>ia.~:..') is True
    assert rmgarbage_alphanumeric('.') is False


def test_rmgarbage_row():
    assert rmgarbage_row('111111111111111111111111') is True
    assert rmgarbage_row('Pnlhrrrr') is True
    assert rmgarbage_row('11111k1U1M.il.uu4ailuidt]i') is True


def test_rmgarbage_row_non_ascii():
    assert rmgarbage_row(u'ÐÐÐÐææææ') is True


def test_rmgarbage_vowels():
    assert rmgarbage_vowels('CslwWkrm') is True
    assert rmgarbage_vowels('Tptpmn') is True
    assert rmgarbage_vowels('Thlrlnd') is True


def test_rmgarbage_punctuation():
    assert rmgarbage_punctuation('ab,cde,fg') is False
    assert rmgarbage_punctuation('btkvdy@us1s<F9>8') is True
    assert rmgarbage_punctuation('w.a.e.~tcet~oe~') is True
    assert rmgarbage_punctuation('<F9><F9>iA,1llfllwl~flII~N') is True


def test_rmgarbage_case():
    assert rmgarbage_case('bAa') is True
    assert rmgarbage_case('aepauWetectronic') is True
    assert rmgarbage_case('sUatigraphic') is True
