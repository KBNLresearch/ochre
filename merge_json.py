import click
import json
import os
import glob
import codecs
import pandas as pd


@click.command()
@click.argument('in_dir', type=click.Path(exists=True))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def merge_json(in_dir, out_dir):
    in_files = glob.glob('{}{}*.json'.format(in_dir, os.sep))
    idx = [os.path.basename(f) for f in in_files]

    dfs = []
    for in_file in in_files:
        with codecs.open(in_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        dfs.append(data)

    result = pd.DataFrame(dfs, index=idx)
    result = result.fillna(0)
    cols = result.columns
    result[cols] = result[cols].astype(int)

    out_file = os.path.join(out_dir, 'character_counts.csv')
    result.to_csv(out_file, encoding='utf-8')


if __name__ == '__main__':
    merge_json()
