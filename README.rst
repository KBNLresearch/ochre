
Ochre
=====

Ochre is a toolbox for OCR post-correction.

.. important::
    Please note that this software is experimental and very much a work in
    progress!

* Overview of OCR post-correction data sets
* Preprocess data sets
* Train character-based language models/LSTMs for OCR post-correction
* Do the post-correction
* Assess the performance of OCR post-correction
* Analyze OCR errors

Ochre contains ready-to-use data processing workflows (based on `CWL
<http://www.commonwl.org/>`_). The software also allows you to create your own
(OCR post-correction related) workflows. Examples of how to create these can be
found in the `notebooks directory
<https://github.com/KBNLresearch/ochre/tree/master/notebooks>`_ (to be able to
use those, make sure you have `Jupyter Notebooks
<http://jupyter.readthedocs.io/en/latest/install.html>`_ installed). This
directory also contains notebooks that show how results can be analyzed and
visualized.

Preprocessing
-------------

The software needs the data in the following formats:


* ocr: text files containing the ocr-ed text, one file per unit (article, page, book, etc.)
* gs: text files containing the gold standard (correct) text, one file per unit (article, page, book, etc.)
* aligned: json files containing aligned character sequences:
  .. code-block::

     {
       "ocr": ["E", "x", "a", "m", "p", "", "c"],
       "gs": ["E", "x", "a", "m", "p", "l", "e"]
     }

Corresponding files in these directories should have the same name (or at least the same prefix), for example:

.. code-block::

   ├── gs
   │   ├── 1.txt
   │   ├── 2.txt
   │   └── 3.txt
   ├── ocr
   │   ├── 1.txt
   │   ├── 2.txt
   │   └── 3.txt
   └── aligned
       ├── 1.json
       ├── 2.json
       └── 3.json

To create data in these formats, CWL workflows are available.
First run a preprocess workflow to create the ``gs`` and ``ocr`` directories containing the expected files.
Next run an align workflow to create the ``align`` directory.


* VU DNC corpus: ``vudnc-preprocess-pack.cwl`` (can be run as stand-alone; associated notebook `vudnc-preprocess-workflow.ipynb <https://github.com/KBNLresearch/ochre/blob/master/notebooks/vudnc-preprocess-workflow.ipynb>`_\ )
* ICDAR 2017 shared task on OCR post correction: ``icdar2017st-extract-data-all.cwl`` (cannot be run as stand-alone;
  regenerate with notebook `ICDAR2017_shared_task_workflows.ipynb <https://github.com/KBNLresearch/ochre/blob/master/notebooks/ICDAR2017_shared_task_workflows.ipynb>`_\ )

To create the alignments, run one of:


* ``align-dir-pack.cwl`` to align all files in the ``gs`` and ``ocr`` directories
* ``align-test-files-pack.cwl`` to align the test files in a data division

These workflows can be run as stand-alone; associated notebook `align-workflow.ipynb <notebooks/align-workflow.ipynb>`_.

Training networks for OCR post-correction
-----------------------------------------

First, you need to divide the data into a train, validation and test set:

.. code-block::

   python -m ochre.create_data_division /path/to/aligned

The result of this command is a json file containing lists of file names, for example:

.. code-block::

   {
       "train": ["1.json", "2.json", "3.json", "4.json", "5.json", ...],
       "test": ["6.json", ...],
       "val": ["7.json", ...]
   }


* Script: ``lstm_synched.py``

OCR post-correction
-------------------

If you trained a model, you can use it to correct OCR text using the ``lstm_synced_correct_ocr`` command:

.. code-block::

   python -m ochre.lstm_synced_correct_ocr /path/to/keras/model/file /path/to/text/file/containing/the/characters/in/the/training/data /path/to/ocr/text/file

or

.. code-block::

   cwltool /path/to/ochre/cwl/lstm_synced_correct_ocr.cwl --charset /path/to/text/file/containing/the/characters/in/the/training/data --model /path/to/keras/model/file --txt /path/to/ocr/text/file

The command creates a text file containing the corrected text.

To generate corrected text for the test files of a dataset, do:

.. code-block::

   cwltool /path/to/ochre/cwl/post_correct_test_files.cwl --charset /path/to/text/file/containing/the/characters/in/the/training/data --model /path/to/keras/model/file --datadivision /path/to/data/division --in_dir /path/to/directory/with/ocr/text/files

To run it for a directory of text files, use:

.. code-block::

   cwltool /path/to/ochre/cwl/post_correct_dir.cwl --charset /path/to/text/file/containing/the/characters/in/the/training/data --model /path/to/keras/model/file --in_dir /path/to/directory/with/ocr/text/files

(these CWL workflows can be run as stand-alone; associated notebook `post_correction_workflows.ipynb <https://github.com/KBNLresearch/ochre/blob/master/notebooks/post_correction_workflows.ipynb>`_\ )

* Explain merging of predictions

Generating training data
------------------------

* Scramble gold standard text

Ideas
-----

* Visualization of probabilities for each character (do the ocr mistakes have lower
  probability?) (probability=color)

License
-------

Copyright (c) 2017-2018, Koninklijke Bibliotheek, Netherlands eScience Center

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
