import click
import codecs
import re
import edlib


def make_mapping(sequences):
    # make char -> int mapping
    temp = {}
    multiple_chars = []

    for sequence in sequences:
        for c in sequence:
            length = len(c.encode('utf-8'))
            if length > 1:
                multiple_chars.append(c)
            else:
                temp[ord(c)] = c

    if len(temp.keys()) + len(set(multiple_chars)) > 255:
        raise ValueError('Too many strange characters!')

    # find unused integers for characters encoded with multiple characters
    for c in set(multiple_chars):
        for i in range(1, 256):
            if i not in temp.keys():
                temp[i] = c
                break

    # reverse the int -> char mapping
    mapping = {}
    for k, v in temp.items():
        mapping[v] = k

    return mapping


def translate(mapping, sequence):
    seq = []
    for i, c in enumerate(sequence):
        seq.append(chr(mapping[c]))
    return ''.join(seq)


@click.command()
@click.argument('file1', type=click.Path(exists=True))
@click.argument('file2', type=click.Path(exists=True))
def align(file1, file2):
    with codecs.open(file1, encoding='utf-8') as f:
        seq1 = f.read()
    with codecs.open(file2, encoding='utf-8') as f:
        seq2 = f.read()
    click.echo(type(seq1))

    # map characters encoded with multiple characters to single characters
    mapping = make_mapping([seq1, seq2])
    sequence1 = translate(mapping, seq1)
    sequence2 = translate(mapping, seq2)

    result = edlib.align(sequence1, sequence2, task='path')
    print(result["editDistance"])  # 3
    print(result["alphabetLength"])  # 8
    print(result["locations"])  # [(None, 8)]
    print(result["cigar"])  # None

    cigar = result['cigar']

    matches = re.findall(r'(\d+)(.)', cigar)
    offset1 = 0
    offset2 = 0

    for m in matches:
        n = int(m[0])
        typ = m[1]

        if typ == '=':
            # sanity check - strings should be equal
            assert(seq1[offset1:offset1+n] == seq2[offset2:offset2+n])
            offset1 += n
            offset2 += n
            #print('len in seq1', len(seq1[offset1:offset1+n]))
            #print('len in seq2', len(seq2[offset2:offset2+n]))
        elif typ == 'D':
            print('inserted: "{}"'.format(seq1[offset1:offset1+n]))
            print('context: "{}"'.format(seq1[max(0, offset1-5):offset1+n+5]))
            print('inserted: "{}"'.format(seq2[offset2:offset2+n]))
            print('context: "{}"'.format(seq2[max(0, offset2-5):offset2+n+5]))
            #print(len(seq1[offset1:offset1+n]))
            #offset1 += n
            offset2 += n
        elif typ == 'X':
            print('subsituted: "{}"'.format(seq1[offset1:offset1+n]))
            print('context: "{}"'.format(seq1[max(0, offset1-5):offset1+n+5]))
            print('subsituted: "{}"'.format(seq2[offset2:offset2+n]))
            print('context: "{}"'.format(seq2[max(0, offset2-5):offset2+n+5]))
            offset1 += n
            offset2 += n
            print('len in seq1', len(seq1[offset1:offset1+n]))
            print('len in seq2', len(seq2[offset2:offset2+n]))
        elif typ == 'I':
            print('deleted: "{}"'.format(seq1[offset1:offset1+n]))
            print('context: "{}"'.format(seq1[max(0, offset1-5):offset1+n+5]))
            print('deleted: "{}"'.format(seq1[offset1:offset1+n]))
            print('context: "{}"'.format(seq1[max(0, offset1-5):offset1+n+5]))
            #print('deleted: "{}"'.format(seq2[offset2:offset2+n]))
            #print('deleted: "{}"'.format(seq2[max(0, offset2-5):offset2+n+5]))
            offset1 += n
            #offset2 += n

        print('----')


if __name__ == '__main__':
    align()
