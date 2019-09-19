Installation
############

.. code-block:: bash

   git clone git@github.com:KBNLresearch/ochre.git
   cd ochre
   pip install -r requirements.txt
   python setup.py develop


* Using the CWL workflows requires (the development version of) `nlppln
  <https://github.com/nlppln/nlppln>`_ and its requirements (`see installation
  guidelines <http://nlppln.readthedocs.io/en/latest/installation.html>`_).
* To run a CWL workflow type: ``cwltool path/to/workflow.cwl <inputs>`` (if you
  run the command without inputs, the tool will tell you about what inputs are
  required and how to specify them). For more information on running CWL
  workflows, have a look at the `nlppln documentation
  <http://nlppln.readthedocs.io/en/latest/>`_. This is especially relevant for
  Windows users.
* Please note that some of the CWL workflows contain absolute paths, if you want
  to use them on your own machine, regenerate them using the associated Jupyter
  Notebooks.

