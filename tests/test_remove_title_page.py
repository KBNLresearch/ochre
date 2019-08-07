# -*- coding: utf-8 -*-
import os

from click.testing import CliRunner

# FIXME: import correct methods for testing
from ochre.remove_title_page import remove_title_page


# Documentation about testing click commands: http://click.pocoo.org/5/testing/
def test_remove_title_page_single_line():
    runner = CliRunner()
    with runner.isolated_filesystem():
        os.makedirs('in')
        os.makedirs('out')

        with open('in/test-without.txt', 'w') as f:
            content_without = 'Text starts here.\n' \
                              'Second line.\n'
            f.write(content_without)

        with open('in/test-with.txt', 'w') as f:
            content = 'This is the title page\n' \
                      'Text starts here.\n' \
                      'Second line.\n'
            f.write(content)

        result = runner.invoke(remove_title_page,
                               ['in/test-without.txt', 'in/test-with.txt',
                                '--out_dir', 'out'])

        assert result.exit_code == 0

        assert os.path.exists('out/test-with.txt')

        with open('out/test-with.txt') as f:
            c = f.read()

        assert c == content_without


def test_remove_title_page_multiple_lines():
    runner = CliRunner()
    with runner.isolated_filesystem():
        os.makedirs('in')
        os.makedirs('out')

        with open('in/test-without.txt', 'w') as f:
            content_without = 'Text starts here.\n' \
                              'Second line.\n'
            f.write(content_without)

        with open('in/test-with.txt', 'w') as f:
            content = 'This is the title page 1.\n' \
                      'This is the title page 2.\n' \
                      'Text starts here.\n' \
                      'Second line.\n'
            f.write(content)

        result = runner.invoke(remove_title_page,
                               ['in/test-without.txt', 'in/test-with.txt',
                                '--out_dir', 'out'])

        assert result.exit_code == 0

        assert os.path.exists('out/test-with.txt')

        with open('out/test-with.txt') as f:
            c = f.read()

        assert c == content_without


def test_remove_title_page_no_lines():
    runner = CliRunner()
    with runner.isolated_filesystem():
        os.makedirs('in')
        os.makedirs('out')

        with open('in/test-without.txt', 'w') as f:
            content_without = 'Text starts here.\n' \
                              'Second line.\n'
            f.write(content_without)

        with open('in/test-with.txt', 'w') as f:
            content = 'Text starts here.\n' \
                      'Second line.\n'
            f.write(content)

        result = runner.invoke(remove_title_page,
                               ['in/test-without.txt', 'in/test-with.txt',
                                '--out_dir', 'out'])

        assert result.exit_code == 0

        assert os.path.exists('out/test-with.txt')

        with open('out/test-with.txt') as f:
            c = f.read()

        assert c == content_without
