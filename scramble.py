#!/usr/bin/env python
import click
#import codecs
import numpy as np


@click.command()
#@click.argument('in_files', nargs=-1, type=click.Path(exists=True))
#@click.argument('out_dir', nargs=1, type=click.Path())
#def command(in_files, out_dir):
def command():
    # Hoe gaat het scramblen in z'n werk?
    # Random. We hebben insertions, deletions en substitutions.
    # Die kunnen allemaal meer dan 1 teken lang zijn (zeg: tot maximaal 5 lang)
    # Eerst kies je of je een insertion, deletion of substitution gaat doen.
    # Dan kies je hoe lang ie gaat zijn (bij substitution moet je twee lengtes
    # kiezen: wat wordt vervangen en waarvoor het wordt vervangen)
    # Hmm, je hebt alleen insertion en deletion nodig (met bijbehorende
    # lengtes), soms doe je allebei, dat is substitution).
    # Nee, als het iets is, is het een substitution, dan sample je voor de
    # lengte van de insert en delete (die soms ook 0 kan zijn)
    # Hmm, which characters are subsituted depends on the char (but now we do
    # totally random, this is for later)
    text = 'Dit is een tekst.'
    text_list = [c for c in text]
    text_length = len(text)
    probs2 = [0.5, 0.35, 0.14, 0.005, 0.005]

    change = np.random.choice(2, text_length, p=[0.8, 0.2])
    insert = []
    delete = []
    for i in change:
        if i == 1:
            insert.append(np.random.choice(len(probs2), 1, p=probs2)[0])
            delete.append(np.random.choice(len(probs2), 1, p=probs2)[0])
        else:
            insert.append(0)
            delete.append(0)

    #insert = np.random.choice(max_length, text_length, p=probs)
    #delete = np.random.choice(max_length, text_length, p=probs)
    #insert = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    #delete = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
    print(insert)
    print(delete)
    idx = 0
    for tidx, (i, d) in enumerate(zip(insert, delete)):
        #print(idx)
        #print(i)
        #print(d)
        #print('---')
        #print(idx)
        if i != 0 or d != 0:
            if d != 0:
                for _ in range(d):
                    # make sure text_list[idx] exists, before deleting it
                    if idx < len(text_list):
                        del(text_list[idx])
                # only adjust idx if no characters should be inserted
                if i == 0:
                    idx += 1
            if i != 0:
                for _ in range(i):
                    # TODO: replace by random character(s) instead of a fixed
                    # one (possibly dependent on what was deleted)
                    text_list.insert(idx, '*')
                idx += i
        else:
            idx += 1

    print(''.join(text_list))


if __name__ == '__main__':
    command()
