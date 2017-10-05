## Todo

* Come up with name for software package
*

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
* VU DNC corpus: `folia2texts.cwl`
* ICDAR 2017 shared task on OCR post correction: `icdar2017st-extract-data-all.cwl`

## Training networks for OCR post-correction

* Create datadivision
* Script: `lstm_synched.py`

## OCR post-correction

Currently, only available in a Jupyter notebook, needs to be converted to a command/workflow.

## Performance

* The ocrevaluation docker needs to be published on github and dockerhub.
* ocrevaluation-performance-wf.cwl

## OCR error analysis

* quantify and qualify the differences between ocr and gs (what kind of ocr mistakes occur? structural vs. random mistakes)
* create wordmapping
* compare words
* automatically classify types of errors (based on heuristics)

## OCR quality measure

Jupyter notebook
* better (more balanced) training data is needed.

## Generating training data

## Ideas

* Visualization of probabilities for each character (do the ocr mistakes have lower
  probability?) (probability=color)
