import click
import codecs
import re

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
    #seq1 = 'telephone'
    #seq2 = 'elephant'
    #seq1 = 'aabaa abaaabba'
    #seq2 = 'aaaa aaaaa'
    #seq1 = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    #seq2 = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    seq1 = 'Inkoper der V.N. komt naar ons land Naar aanleiding van het reeds eer- der gemelde bericht, dat F. A. Mapes, directeur van het bureau voor inkoop en vervoer der V.N., een bezoek aan West-Europa zal brengen voor de aankoop van materialen voor het nieuwe hoofdbureau der V.N. te New York, verneemt A.N.P.- Aneta, dat Mapes met de architect der V.N., A. R. Sorensen in de eerste week van Mei Nederland en België zal bezoeken. In Nederland zou men vooral meu- bilair, stoelbekleding, manufacturen, vloertegels voor de wandelgang van het auditorium der algemene verga- dering en vloerkleden willen kopen, in België o.m. spiegelglas, spiegels en meubilair. Men wijst er op, dat niet alleen de kwaliteit der goederen, maar ook de prijs, de vervoerskosten en de leve- ringstijd van belang zullen zijn. De ministers van buitenlandse zaken in Den Haag en Brussel hebben hun hulp aangeboden voor het leggen van con- tact tussen de beide inkopers der V.N. en de handelaren, die hen willen ont- moeten. Mapes en Sorensen zouden ook met de regeringen der Beneluxlanden spreken over mogelijke geschenken dezer landen op decoratief gebied, waarover onlangs door het secretariaat der V.N. en delegaties van de Bene- lux is gesproken.'
    seq2 = 'Inkoper der V.N. komt naar ons land Naar aanleiding van het reeds eerder gemelde bericht, dat F. A. Mapes, directeur van het bureau voor inkoop en vervoer der V.N., een bezoek aan West-Europa zal brengen voor de aankoop van materialen voor het nieuwe hoofdbureau der V.N. te New York, verneemt A.N.P.- Aneta, dat Mapes met de architect der V.N., A. R. Sorensen in de eerste week van Mei Nederland en België zal bezoeken. In Nederland zou men vooral meubilair, stoelbekleding, manufacturen, vloertegels voor de wandelgang van het auditorium der algemene vergadering en vloerkleden willen kopen, in België o.m. spiegelglas, spiegels en meubilair. Men wijst er op, dat niet alleen de kwaliteit der goederen, maar ook de prijs, de vervoerskosten en de leveringstijd van belang zullen zijn. De ministers van buitenlandse zaken in Den Haag en Brussel hebben hun hulp aangeboden voor het leggen van contact tussen de beide inkopers der V.N. en de handelaren, die hen willen ontmoeten. Mapes en Sorensen zouden ook met de regeringen der Beneluxlanden spreken over mogelijke geschenken dezer landen op decoratief gebied, waarover onlangs door het secretariaat der V.N. en delegaties van de Benelux is gesproken.'
    seq1 = 'aabëaba'
    seq2 = 'aaëaa'
    print(repr(seq1))
    result = edlib.align(seq1, seq2, task='path')
    print(result["editDistance"])  # 3
    print(result["alphabetLength"])  # 8
    print(result["locations"])  # [(None, 8)]
    print(result["cigar"])  # None

    cigar = result['cigar']

    matches = re.findall(r'(\d+)(.)', cigar)
    offset1 = 0
    offset2 = 0
    s1 = 0
    s2 = 0
    for m in matches:
        print(int(m[0]))
        print(m[1])
        n = int(m[0])
        typ = m[1]
        print('offset1', offset1)
        print('offset2', offset2)

        if typ == '=':
            print(seq1[offset1:offset1+n])
            print(seq2[offset2:offset2+n])
            offset1 += n
            offset2 += n
            print('len in seq1', len(seq1[offset1:offset1+n]))
            print('len in seq2', len(seq2[offset2:offset2+n]))
            s1 += n
            s2 += n
        elif typ == 'I':
            print('inserted: "{}"'.format(seq1[offset1:offset1+n]))
            print('inserted: "{}"'.format(seq1[max(0, offset1-5):offset1+n+5]))
            print(len(seq1[offset1:offset1+n]))
            offset1 += n
            s1 += n
        elif typ == 'X':
            print('subsituted: "{}"'.format(seq1[offset1:offset1+n]))
            print('subsituted: "{}"'.format(seq2[offset2:offset2+n]))
            offset1 += n
            offset2 += n
            s1 += n
            s2 += n
        elif typ == 'D':
            print('deleted: "{}"'.format(seq2[offset2:offset2+n]))
            offset2 += n
            s2 += n

        print('----')

        #else:
        #    offset2 += n

        #if typ == 'I':
        #    print('inserted: "{}"'.format(seq1[offset-n-5:offset+5]))
        #    print('inserted: "{}"'.format(seq1[offset-n:offset]))
        #    offset -= n
    print(len(seq1), s1)
    print(len(seq2), s2)

if __name__ == '__main__':
    align()
