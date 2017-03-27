import click
import json
import os

from collections import Counter


@click.command()
@click.argument('in_file', type=click.Path(exists=True))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def count_chars(in_file, out_dir):
    chars = Counter()
    with open(in_file) as f:
        text = f.read().strip()

    for char in text:
        chars[char] += 1

    fname = os.path.basename(in_file.replace('.txt', '.json'))
    fname = os.path.join(out_dir, fname)
    with open(fname, 'w', encoding='utf-8') as f:
        json.dump(chars, f, indent=2)

    #for c, freq in chars.most_common():
    #    print('{}\t{}'.format(repr(c), freq))
    #    print(repr(c.encode('utf-8')))
    #    print(len(c.encode('utf-8')))


if __name__ == '__main__':
    count_chars()
