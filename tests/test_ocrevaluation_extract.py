# -*- coding: utf-8 -*-
import os
import codecs
import sh
import pytest

from click.testing import CliRunner
from bs4 import BeautifulSoup

from ochre import ocrevaluation_extract


#def test_prettify_xml():
#    runner = CliRunner()
#    with runner.isolated_filesystem():
#        os.makedirs('in')
#        os.makedirs('out')
#        with open('in/test.xml', 'w') as f:
#            xml = '<?xml version="1.0" encoding="utf-8"?>\n<document>\n' \
#                  '<word w_id="242" value="test" total_analysis="11">\n' \
#                  '<analysis a_id="1" additional_info=""/>\n' \
#                  '</word>\n</document>'
#            f.write(xml)

#        result = runner.invoke(prettify_xml, ['in/test.xml',
#                                              '--out_dir', 'out'])

#        assert result.exit_code == 0

#        assert os.path.exists('out/test.xml')

#        with codecs.open('out/test.xml', 'r', encoding='utf-8') as f:
#            pretty = f.read()

#        assert pretty == BeautifulSoup(xml, 'xml').prettify()


def test_ocr_evaluation_extract_cwl(tmpdir):
    tool = os.path.join('ochre', 'cwl', 'ocrevaluation-extract.cwl')
    in_file = os.path.join('tests', 'data', 'ocrevaluation-extract', 'in',
                           'in.html')

    try:
        sh.cwltool(['--outdir', tmpdir, tool, '--in_file', in_file])
    except sh.ErrorReturnCode as e:
        print(e)
        pytest.fail(e)

    for out in ['in-character.csv', 'in-global.csv']:

        out_file = tmpdir.join(out).strpath
        with open(out_file) as f:
            actual = f.read()

        fname = os.path.join('tests', 'data', 'ocrevaluation-extract', 'out',
                             out)
        with open(fname) as f:
            expected = f.read()

        print(out)
        print('  actual:', actual)
        print('expected:', expected)
        assert actual == expected


def test_ocr_evaluation_extract_cwl_empty(tmpdir):
    tool = os.path.join('ochre', 'cwl', 'ocrevaluation-extract.cwl')
    in_file = os.path.join('tests', 'data', 'ocrevaluation-extract', 'in',
                           'empty.html')

    try:
        sh.cwltool(['--outdir', tmpdir, tool, '--in_file', in_file])
    except sh.ErrorReturnCode as e:
        print(e)
        pytest.fail(e)

    for out in ['empty-character.csv', 'empty-global.csv']:

        out_file = tmpdir.join(out).strpath
        with open(out_file) as f:
            actual = f.read()

        fname = os.path.join('tests', 'data', 'ocrevaluation-extract', 'out',
                             out)
        with open(fname) as f:
            expected = f.read()

        print(out)
        print('  actual:', actual)
        print('expected:', expected)
        assert actual == expected
