import click
import json
import codecs

from nlppln.utils import get_files, cwl_file


@click.command()
@click.argument('in_dir1', type=click.Path(exists=True))
@click.argument('in_dir2', type=click.Path(exists=True))
@click.argument('in_dir3', type=click.Path(exists=True))
def remove_empty_files(in_dir1, in_dir2, in_dir3):
    in_dirs = [in_dir1, in_dir2, in_dir3]

    files_list = []
    files_out = {'files1': [], 'files2': [], 'files3': []}

    for d in in_dirs:
        files_list.append(get_files(d))

    for files in zip(*files_list):
        lengths = []
        for fi in files:
            with codecs.open(fi, 'r', encoding='utf-8') as f:
                lengths.append(len(f.read().strip()))
        if min(lengths) > 0:
            for i, d in enumerate(in_dirs):
                files_out['files{}'.format(i+1)].append(cwl_file(files[i]))
    stdout_text = click.get_text_stream('stdout')
    stdout_text.write(json.dumps(files_out))


if __name__ == '__main__':
    remove_empty_files()
