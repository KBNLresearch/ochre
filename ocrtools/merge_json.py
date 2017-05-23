import click
import json
import os
import glob
import codecs
import uuid
import pandas as pd


@click.command()
@click.argument('in_dir', type=click.Path(exists=True))
@click.option('--name', '-n', default='{}.csv'.format(uuid.uuid4()))
@click.option('--out_dir', '-o', default=os.getcwd(), type=click.Path())
def merge_json(in_dir, name, out_dir):
    in_files = glob.glob('{}{}*.json'.format(in_dir, os.sep))
    idx = [os.path.basename(f) for f in in_files]

    dfs = []
    for in_file in in_files:
        with codecs.open(in_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # Make sure it works if the json file contains a list of dictionaries
        # instead of just a single dictionary.
        if not isinstance(data, list):
            data = [data]
        for item in data:
            dfs.append(item)

    if len(idx) != len(dfs):
        result = pd.DataFrame(dfs)
    else:
        result = pd.DataFrame(dfs, index=idx)
    result = result.fillna(0)

    out_file = os.path.join(out_dir, name)
    result.to_csv(out_file, encoding='utf-8')


if __name__ == '__main__':
    merge_json()
