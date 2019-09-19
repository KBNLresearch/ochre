Error Analysis
##############

Different types of OCR errors exist, e.g., structural vs. random mistakes. OCR
post-correction methods may be suitable for fixing different types of errors.
Therefore, it is useful to gain insight into what types of OCR errors occur.
We chose to approach this problem on the word level. In order to be able to
compare OCR errors on the word level, words in the OCR text and gold standard
text need to be mapped. CWL workflows are available to do this. To create word
mappings for the test files of a dataset, use:

.. code-block:: bash

   cwltool  /path/to/ochre/cwl/word-mapping-test-files.cwl --data_div /path/to/datadivision --gs_dir /path/to/directory/containing/the/gold/standard/texts --ocr_dir /path/to/directory/containing/the/ocr/texts/ --wm_name name-of-the-output-file.csv

To create word mappings for two directories of files, do:

.. code-block:: bash

   cwltool  /path/to/ochre/cwl/word-mapping-wf.cwl --gs_dir /path/to/directory/containing/the/gold/standard/texts/ --ocr_dir /path/to/directory/containing/the/ocr/texts/ --wm_name name-of-the-output-file.csv

(These workflows can be regenerated using the notebook `word-mapping-workflow.ipynb <https://github.com/KBNLresearch/ochre/blob/master/notebooks/word-mapping-workflow.ipynb>`_.)

The result is a csv-file containing mapped words. The first column contains
a word id, the second column the gold standard text and the third column contains
the OCR text of the word:

.. code-block:: bash

   ,gs,ocr
   0,Hello,Hcllo
   1,World,World
   2,!,.

This csv file can be used to analyze the errors. See ``notebooks/categorize errors based on word mappings.ipynb`` for an example.

We use heuristics to categorize the following types of errors (\ ``ochre/ocrerrors.py``\ ):

.. todo::
    Add error types
