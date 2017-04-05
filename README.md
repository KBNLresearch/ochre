
## Plan

* create ocr + gs for all files
* remove files with empty ocr text(?)
* extract character counts for all files (to get an idea of the characters used)
* align all ocr + gs files
* quantify and qualify the differences between ocr and gs (what kind of ocr mistakes occur?)
  * How can we show they are (more or less) random?
* dive into the neural networks

## Ideas

* Perhaps NN can be used to asses the quality of text? (character-based language model, the probability of generating a certain text)

## align

* Docker to run align command in Python > 3.4
* FIXED characters consisting of multiple characters are mapped to unused ascii extended
codes on the fly
* How to store changes (so they can be merged easily)?

## folia2ocr_and_gs

* FIXED Not all files have ocr text (example: BNObi2-ds)
  * FIXED This is a problem, because the separation of words by spaces depends on the presence of the ocroutput class
* FIXED Not all words have ocr text (example: BNObi3-ds)
  * FIXED This is a problem, because the separation of words by spaces depends on the presence of the ocroutput class
  * Punctuation marks also do not have an ocrtext class
* FIXED Additional space after ( (example: BNObi3-ds) (just like with " - is there a generic way to fix this?)
* Additional space after " (starting quote) - fix requires use of folia class quote
