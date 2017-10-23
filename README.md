# Ochre

Ochre is a toolbox for OCR post-correction.

* Overview of OCR post-correction data sets
* Preprocess data sets
* Train character-based language models/LSTMs for OCR post-correction
* Do the post-correction
* Assess the performance of OCR post-correction
* Analyze OCR errors

## Data sets

* [VU DNC corpus](http://tst-centrale.org/nl/tst-materialen/corpora/vu-dnc-corpus-detail)
  - Language: nl
  - Format: FoLiA
  - ~3340 newspaper articles, different genres, 5 newspapers, 1950/1951
* [ICDAR 2017 shared task on OCR post correction](https://sites.google.com/view/icdar2017-postcorrectionocr/dataset)
  - Language: en and fr
  - Format: txt (more info on the website)
  - Periodicals and monographs
* [Digitzed yearbooks of the Swiss Alpine Club (19th century)](https://files.ifi.uzh.ch/cl/OCR19thSAC/)
  - Paper: http://www.zora.uzh.ch/124786/
  - Languages: de and fr
* [Sydney Morning Herald 1842-1954 (Overproof)](http://overproof.projectcomputing.com/datasets/)
  - Paper: http://dl.acm.org/citation.cfm?id=2595200
  - Languages: en
* byu synthetic ocr data
  - Paper: http://scholarsarchive.byu.edu/cgi/viewcontent.cgi?article=2664&context=facpub
  - Not (yet) available

## Installation

```
git clone git@github.com:KBNLresearch/ochre.git
cd ochre
pip install -r requirements.txt
python setup.py develop
```
* Using the CWL workflows requires (the development version of) [nlppln](https://github.com/WhatWorksWhenForWhom/nlppln) and cwltool (`pip install cwltool`)
* Please note that the CWL workflows contain absolute paths, if you want to use them on your own machine, regenerate them using the associated Jupyter Notebooks.

## Preprocessing

The software needs the data in the following formats:
* ocr: text files containing the ocr-ed text, one file per unit (article, page, book, etc.)
* gs: text files containing the gold standard (correct) text, one file per unit (article, page, book, etc.)
* alinged: json files containing aligned character sequences:
```
{
    "ocr": ["E", "x", "a", "m", "p", "", "c"],
    "gs": ["E", "x", "a", "m", "p", "l", "e"]
}
```

To create data in these formats, CWL workflows are available:
* VU DNC corpus: `vudnc-preprocess.cwl` (regenerate with notebook [vudnc-preprocess-workflow.ipynb](https://github.com/KBNLresearch/ochre/blob/master/notebooks/vudnc-preprocess-workflow.ipynb))
* ICDAR 2017 shared task on OCR post correction: `icdar2017st-extract-data-all.cwl` (regenerate with notebook [extract ICDAR2017 shared task data.ipynb](https://github.com/KBNLresearch/ochre/blob/master/notebooks/extract ICDAR2017 shared task data.ipynb))

## Training networks for OCR post-correction

First, you need to divide the data into a train, validation and test set:

```
python -m ochre.create_data_division /path/to/aligned
```

The result of this command is a json file containing lists of file names, for example:

```
{
    "train": ["1.json", "2.json", "3.json", "4.json", "5.json", ...],
    "test": ["6.json", ...],
    "val": ["7.json", ...]
}
```

* Script: `lstm_synched.py`

## OCR post-correction

If you trained a model, you can use it to correct OCR text using the `lstm_synced_correct_ocr` command:

```
python -m ochre.lstm_synced_correct_ocr /path/to/keras/model/file /path/to/text/file/containing/the/characters/in/the/training/data /path/to/ocr/text/file
```
or
```
cwltool /path/to/ochre/cwl/lstm_synced_correct_ocr.cwl --charset /path/to/text/file/containing/the/characters/in/the/training/data --model /path/to/keras/model/file --txt /path/to/ocr/text/file
```

The command creates a text file containing the corrected text.

To generate corrected text for the test files of a dataset, do:

```
cwltool /path/to/ochre/cwl/post_correct_test_files.cwl --charset /path/to/text/file/containing/the/characters/in/the/training/data --model /path/to/keras/model/file --datadivision /path/to/data/division --in_dir /path/to/directory/with/ocr/text/files
```

To run it for a directory of text files, use:

```
cwltool /path/to/ochre/cwl/post_correct_dir.cwl --charset /path/to/text/file/containing/the/characters/in/the/training/data --model /path/to/keras/model/file --in_dir /path/to/directory/with/ocr/text/files
```

(Regenerate with notebook [post_correction_workflows.ipynb](https://github.com/KBNLresearch/ochre/blob/master/notebooks/post_correction_workflows.ipynb))

## Performance

* The ocrevaluation docker needs to be published on github and dockerhub.
* ocrevaluation-performance-wf.cwl

## OCR error analysis

Different types of OCR errors exist, e.g., structural vs. random mistakes. OCR
post-correction methods may be suitable for fixing different types of errors.
Therefore, it is useful to gain insight into what types of OCR errors occur.
We chose to approach this problem on the word level. In order to be able to
compare OCR errors on the word level, words in the OCR text and gold standard
text need to be mapped. CWL workflows are available to do this. To create word
mappings for the test files of a dataset, use:

```
cwltool  /path/to/ochre/cwl/word-mapping-test-files.cwl --data_div /path/to/datadivision --gs_dir /path/to/directory/containing/the/gold/standard/texts --ocr_dir /path/to/directory/containing/the/ocr/texts/ --wm_name name-of-the-output-file.csv
```

To create word mappings for two directories of files, do:

```
cwltool  /path/to/ochre/cwl/word-mapping-wf.cwl --gs_dir /path/to/directory/containing/the/gold/standard/texts/ --ocr_dir /path/to/directory/containing/the/ocr/texts/ --wm_name name-of-the-output-file.csv
```

(These workflows can be regenerated using the notebook [word-mapping-workflow.ipynb](https://github.com/KBNLresearch/ochre/blob/master/notebooks/word-mapping-workflow.ipynb).)

The result is a csv-file containing mapped words. The first column contains
a word id, the second column the gold standard text and the third column contains
the OCR text of the word:
```
,gs,ocr
0,Hello,Hcllo
1,World,World
2,!,.
```
This csv file can be used to analyze the errors. See `notebooks/categorize errors based on word mappings.ipynb` for an example.

We use heuristics to categorize the following types of errors (`ochre/ocrerrors.py`):

* TODO: add error types

## OCR quality measure

Jupyter notebook
* better (more balanced) training data is needed.

## Generating training data

* Scramble gold standard text

## Ideas

* Visualization of probabilities for each character (do the ocr mistakes have lower
  probability?) (probability=color)
