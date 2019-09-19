OCR Quality Measures and Tools
##############################

* ocrevalation tool
* ICDAR shared task script

Performance
-----------

To calculate performance of the OCR (post-correction), the external tool
`ocrevalUAtion <https://github.com/impactcentre/ocrevalUAtion>`_ is used. More
information about this tool can be found on the
`website <https://sites.google.com/site/textdigitisation/>`_ and
`wiki <https://github.com/impactcentre/ocrevalUAtion/wiki>`_.

Two workflows are available for calculating performance. The first calculates
performance for all files in a directory. To use it type:

.. code-block::

   cwltool /path/to/ochre/cwl/ocrevaluation-performance-wf-pack.cwl#main --gt /path/to/dir/containing/the/gold/standard/ --ocr /path/to/dir/containing/ocr/texts/ [--out_name name-of-output-file.csv]

The second calculates performance for all files in the test set:

.. code-block::

   cwltool /path/to/ochre/cwl/ocrevaluation-performance-test-files-wf-pack.cwl --datadivision /path/to/datadivision.json --gt /path/to/dir/containing/the/gold/standard/ --ocr /path/to/dir/containing/ocr/texts/ [--out_name name-of-output-file.csv]

Both of these workflows are stand-alone (packed). The corresponding Jupyter notebook is `ocr-evaluation-workflow.ipynb <https://github.com/KBNLresearch/ochre/blob/master/notebooks/ocr-evaluation-workflow.ipynb>`_.

To use the ocrevalUAtion tool in your workflows, you have to add it to the ``WorkflowGenerator's`` steps
library:

.. code-block::

   wf.load(step_file='https://raw.githubusercontent.com/nlppln/ocrevaluation-docker/master/ocrevaluation.cwl')


* TODO: explain how to calculate performance with ignore case (or use lowercase-directory.cwl)

OCR quality measure
-------------------

Jupyter notebook


* better (more balanced) training data is needed.
