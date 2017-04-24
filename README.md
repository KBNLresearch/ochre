## Plan

* create ocr + gs for all files
* DONE remove files with either empty ocr text or empty gs (`remove_empty_files.py`)
* extract character counts for all files (to get an idea of the characters used)
* align all ocr + gs files
* quantify and qualify the differences between ocr and gs (what kind of ocr mistakes occur?)
  * How can we show they are (more or less) random?
  * They might be newspaper (or font) dependant
  * Maybe it is better to show that rnns can deal with both random errors and
  non random errors, because probably the errors aren't random
  * Idea: experiment with various types and (combined) degrees of errors (e.g., is it
    better to train using generated data, does pretraining with correct Dutch text
    help or harm)
  * Idea: generate new data to test on
* dive into the neural networks
  * keras (+tensorflow)
  * try the rnn software from the blogpost

## Ideas

* Perhaps NN can be used to asses the quality of text? (character-based language model, the probability of generating a certain text)
* Visualization of probabilities for each character (do the ocr mistakes have lower
  probability?) (probability=color)

## align

* Docker to run align command in Python > 3.4
* FIXED characters consisting of multiple characters are mapped to unused ascii extended
codes on the fly
* How to store changes (so they can be merged easily)?

## remove_empty_files

* FIXED remove files with either empty ocr text or empty gs
* there might still be problems with aligning texts that differ a lot (but we'll see)

## folia2ocr_and_gs

* FIXED Not all files have ocr text (example: BNObi2-ds)
  * FIXED This is a problem, because the separation of words by spaces depends on the presence of the ocroutput class
* FIXED Not all words have ocr text (example: BNObi3-ds)
  * FIXED This is a problem, because the separation of words by spaces depends on the presence of the ocroutput class
  * Punctuation marks also do not have an ocrtext class
* FIXED Additional space after ( (example: BNObi3-ds) (just like with " - is there a generic way to fix this?)
* Additional space after " (starting quote) - fix requires use of folia class quote

## Software for sequence alignment

From talk with Arnold:

* Blast
* Suffix tree
	* https://code.google.com/archive/p/pysuffix/
* Dan Gusfield (person)
