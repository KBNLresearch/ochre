import click
import codecs

#import lingpy
import edlib


@click.command()
@click.argument('file1', type=click.Path(exists=True))
@click.argument('file2', type=click.Path(exists=True))
def align(file1, file2):
    with codecs.open(file1, encoding='utf-8') as f:
        seq1 = f.read()
    with codecs.open(file2, encoding='utf-8') as f:
        seq2 = f.read()
    click.echo(type(seq1))
    # mode : {"global","local","overlap","dialign"}
    #click.echo(lingpy.align.pairwise.pw_align(seq1, seq2, mode='dialign'))
    result = edlib.align(seq1, seq2, task='path')
    print(result["editDistance"])  # 3
    print(result["alphabetLength"])  # 8
    print(result["locations"])  # [(None, 8)]
    print(result["cigar"])  # None

if __name__ == '__main__':
    align()
