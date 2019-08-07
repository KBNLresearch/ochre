import numpy as np

from ochre.datagen import DataGenerator


def dgen():
    ocr_seqs = ['abc', 'ab', 'ca8']
    gs_seqs = ['abc', 'bb', 'ca']
    p_char = 'P'
    oov_char = '@'
    n = 3
    ci = {'a': 0, 'b': 1, 'c': 2, p_char: 3, oov_char: 4}
    dg = DataGenerator(xData=ocr_seqs, yData=gs_seqs, char_to_int=ci,
                       seq_length=n, padding_char=p_char, oov_char=oov_char,
                       batch_size=1, shuffle=False)

    return dg


def test_dg():
    dg = dgen()

    assert dg.n_vocab == len(dg.char_to_int)
    assert len(dg) == 3

    x, y = dg[0]

    print(x)
    print(y)

    assert np.array_equal(x[0], np.array([0, 1, 2]))
    assert np.array_equal(y[0], np.array([[1, 0, 0, 0, 0],
                                          [0, 1, 0, 0, 0],
                                          [0, 0, 1, 0, 0]]))


def test_convert_sample():
    dg = dgen()

    cases = {
        'aaa': np.array([0, 0, 0]),
        'a': np.array([0, 3, 3]),
        'b8': np.array([1, 4, 3])
    }

    for inp, outp in cases.items():
        assert np.array_equal(dg._convert_sample(inp), outp)
