import click
import re
import edlib
import os
import json

from collections import Counter


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
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def align(file1, file2, out_dir):
    with open(file1, encoding='utf-8') as f:
        seq1 = f.read()
    with open(file2, encoding='utf-8') as f:
        seq2 = f.read()

    # map characters encoded with multiple characters to single characters
    mapping = make_mapping([seq1, seq2])
    sequence1 = translate(mapping, seq1)
    sequence2 = translate(mapping, seq2)

    aligment = edlib.align(sequence1, sequence2, task='path')
    edit_distance = aligment['editDistance']
    cigar = aligment['cigar']

    matches = re.findall(r'(\d+)(.)', cigar)
    offset1 = 0
    offset2 = 0

    changes_from = []
    changes_to = []
    changes = Counter()

    for m in matches:
        n = int(m[0])
        typ = m[1]

        if typ == '=':
            # sanity check - strings should be equal
            assert(seq1[offset1:offset1+n] == seq2[offset2:offset2+n])

            if changes_from != [] and changes_to != []:
                changes[(''.join(changes_from), ''.join(changes_to))] += 1

            changes_from = []
            changes_to = []

            offset1 += n
            offset2 += n
        elif typ == 'D':  # Inserted
            changes_from.append('')
            changes_to.append(seq2[offset2:offset2+n])

            offset2 += n
        elif typ == 'X':
            changes_from.append(seq1[offset1:offset1+n])
            changes_to.append(seq2[offset2:offset2+n])

            offset1 += n
            offset2 += n
        elif typ == 'I':  # Deleted
            changes_from.append(seq1[offset1:offset1+n])
            changes_to.append('')

            offset1 += n

    doc_id = os.path.basename(file1).split('-')[0]
    result = {'doc_id': doc_id,
              'edit_distance': edit_distance,
              'seq1_length': len(sequence1),
              'seq2_length': len(sequence2),
              'cigar': cigar}

    out_file = os.path.join(out_dir, '{}-metadata.json'.format(doc_id))
    with open(out_file, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2)

    changes_list = []
    for (c_from, c_to), freq in changes.items():
        changes_list.append({'doc_id': doc_id,
                             'from': c_from,
                             'to': c_to,
                             'num': freq,
                             'df': 1})
    out_file = os.path.join(out_dir, '{}-changes.json'.format(doc_id))
    with open(out_file, 'w', encoding='utf-8') as f:
        json.dump(changes_list, f, indent=2)


if __name__ == '__main__':
    align()
