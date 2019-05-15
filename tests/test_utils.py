from ochre.utils import read_text_to_predict, get_char_to_int, \
    to_space_tokenized


def test_read_text_to_predict_no_embedding():
    text = u'aaaaaa'
    seq_length = 3
    lowercase = True
    char_to_int = get_char_to_int(u'a\n')
    n_vocab = len(char_to_int)
    padding_char = u'\n'
    predict_chars = 0
    step = 1
    char_embedding = False

    result = read_text_to_predict(text, seq_length, lowercase, n_vocab,
                                  char_to_int, padding_char,
                                  predict_chars=predict_chars, step=step,
                                  char_embedding=char_embedding)

    # The result contains one hot encoded sequences
    assert result.dtype == bool
    assert result.shape == (4, seq_length, n_vocab)


def test_read_text_to_predict_embedding():
    text = u'aaaaaa'
    seq_length = 3
    lowercase = True
    char_to_int = get_char_to_int(u'a\n')
    n_vocab = len(char_to_int)
    padding_char = u'\n'
    predict_chars = 0
    step = 1
    char_embedding = True

    result = read_text_to_predict(text, seq_length, lowercase, n_vocab,
                                  char_to_int, padding_char,
                                  predict_chars=predict_chars, step=step,
                                  char_embedding=char_embedding)

    # The result contains lists of ints
    assert result.dtype == int
    assert result.shape == (4, seq_length)


def test_to_space_tokenized():
    result = to_space_tokenized('Dit is een test.')
    assert 'D i t <SPACE> i s <SPACE> e e n <SPACE> t e s t .' == result
