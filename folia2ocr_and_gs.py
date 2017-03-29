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

    ocr_text_complete = []
    ocr_text = []
    gold_standard = []
    punctuation = []

    # TODO: how to handle headings? They are sentences without a closing
    # punctuation mark.
    # I think the existing LSTM code does not take into account documents (all
    # text is simply concatenated together).
    context = etree.iterparse(in_file, tag='{http://ilk.uvt.nl/folia}w',
                              encoding='utf-8')
    for action, elem in context:
        ocr_word = ''
        punc = False
        pos_elem = elem.find('{http://ilk.uvt.nl/folia}pos')
        if pos_elem is not None:
            if pos_elem.get('class').startswith('LET'):
                punc = True
        for t in elem.iterchildren(tag='{http://ilk.uvt.nl/folia}t'):
            if t.get('class') == 'ocroutput':
                ocr_word = t.text
            else:
                gs_word = t.text

        if ocr_word != '':
            ocr_text.append(ocr_word)
        ocr_text_complete.append(ocr_word)
        gold_standard.append(gs_word)
        punctuation.append(punc)

    result = []
    for i in range(len(ocr_text_complete)):
        #print ocr_text_complete[i]
        #print gold_standard[i]
        result.append(gold_standard[i])
        space = True
        if punctuation[i]:
            #print ocr_text_complete[i-1]
            if i+1 < len(ocr_text_complete):
                if ocr_text_complete[i+1].strip().startswith(gold_standard[i]):
                    #print 'No space after this punctuation: {}'.format(gold_standard[i])
                    space = False
                if punctuation[i+1]:
                    #print 'No space after this punctuation: '.format(gold_standard[i])
                    space = False
        elif i+1 < len(ocr_text_complete) and punctuation[i+1]:
            #print '!'
            if i+2 < len(ocr_text_complete):
                if ocr_text_complete[i+2].strip().startswith(gold_standard[i+1]):
                    #print 'Space after this word: {}'.format(gold_standard[i])
                    space = True
                else:
                    #print 'No space after this word: {}'.format(gold_standard[i])
                    space = False
            else:
                space = False
        if space:
            result.append(' ')

    fname = os.path.basename(in_file)
    fname = fname.replace('.folia.xml', '.{}.txt')
    fname = os.path.join(out_dir, fname)
    with codecs.open(fname.format('gs'), 'wb', encoding='utf-8') as f:
        gs = u''.join(result).strip()
        f.write(gs)

    with codecs.open(fname.format('ocr'), 'wb', encoding='utf-8') as f:
        ocr = u' '.join(ocr_text)
        f.write(ocr)


if __name__ == '__main__':
    folia2ocr_and_gs()
