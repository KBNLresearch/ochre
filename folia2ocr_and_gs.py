import click
import codecs
import os

from lxml import etree
from nlppln.utils import create_dirs


@click.command()
@click.argument('in_file', type=click.Path(exists=True))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def folia2ocr_and_gs(in_file, out_dir):
    create_dirs(out_dir)

    quote = '{http://ilk.uvt.nl/folia}quote'

    ocr_text = []
    gold_standard = []
    ocr_word = None
    prev_parent = None

    # TODO: how to handle headings? They are sentences without a closing
    # punctuation mark.
    # I think the existing LSTM code does not take into account documents (all
    # text is simply concatenated together).
    context = etree.iterparse(in_file, tag='{http://ilk.uvt.nl/folia}w',
                              encoding='utf-8')
    for action, elem in context:
        parent = elem.getparent().tag
        for t in elem.iterchildren(tag='{http://ilk.uvt.nl/folia}t'):
            if t.get('class') == 'ocroutput':
                ocr_word = t.text
            else:
                gs_word = t.text

        if ocr_word:
            space = True
            ocr_text.append(ocr_word)
        # Add a space if the word is a " and it is the start of a quote.
        # Otherwise, the " will be stuck to the previous word (which it should
        # be if it is the end of the quote or any othe punctuation mark).
        elif gs_word == '"' and parent == quote and prev_parent != quote:
            space = True
        else:
            space = False

        if space:
            gold_standard.append(' ')
        gold_standard.append(gs_word)
        ocr_word = None
        space = False
        prev_parent = parent

    # We need to normalize ' " ' in the gold standard to ' "', because we have
    # introduced an additional space.
    fname = os.path.basename(in_file)
    fname = fname.replace('.folia.xml', '.{}.txt')
    fname = os.path.join(out_dir, fname)
    with codecs.open(fname.format('gs'), 'wb', encoding='utf-8') as f:
        gs = u''.join(gold_standard).replace(u' " ', u' "').strip()
        f.write(gs)

    with codecs.open(fname.format('ocr'), 'wb', encoding='utf-8') as f:
        ocr = u' '.join(ocr_text)
        f.write(ocr)


if __name__ == '__main__':
    folia2ocr_and_gs()
