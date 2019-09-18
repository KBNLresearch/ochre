{
    "$graph": [
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "envDef": [
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LANG"
                        },
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LC_ALL"
                        }
                    ],
                    "class": "EnvVarRequirement"
                },
                {
                    "listing": "$(inputs.in_files)",
                    "class": "InitialWorkDirRequirement"
                }
            ],
            "arguments": [
                {
                    "valueFrom": "$(runtime.outdir)",
                    "position": 0
                }
            ],
            "baseCommand": [
                "python",
                "-m",
                "nlppln.commands.check_utf8"
            ],
            "doc": "Convert text files to utf-8 encoding.\n\nUses `BeautifulSoup <https://www.crummy.com/software/BeautifulSoup/bs4/doc/>`_'s\nUnicode, Dammit module to guess the file encoding if it isn't utf-8.\n",
            "inputs": [
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "inputBinding": {
                        "prefix": "--convert"
                    },
                    "id": "#check-utf8.cwl/convert"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#check-utf8.cwl/in_files"
                }
            ],
            "outputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#check-utf8.cwl/utf8_files"
                }
            ],
            "id": "#check-utf8.cwl"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "nlppln.commands.delete_empty_files"
            ],
            "requirements": [
                {
                    "envDef": [
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LANG"
                        },
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LC_ALL"
                        }
                    ],
                    "class": "EnvVarRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "Directory",
                    "inputBinding": {
                        "position": 0
                    },
                    "id": "#delete-empty-files.cwl/in_dir"
                }
            ],
            "outputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputBinding": {
                        "glob": "*"
                    },
                    "id": "#delete-empty-files.cwl/out_files"
                }
            ],
            "id": "#delete-empty-files.cwl"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "nlppln.commands.ls"
            ],
            "doc": "List files in a directory.\n\nThis command can be used to convert a ``Directory`` into a list of files. This list can be filtered on file name by specifying ``--endswith``.\n",
            "requirements": [
                {
                    "envDef": [
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LANG"
                        },
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LC_ALL"
                        }
                    ],
                    "class": "EnvVarRequirement"
                }
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "--endswith"
                    },
                    "id": "#ls.cwl/endswith"
                },
                {
                    "type": "Directory",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#ls.cwl/in_dir"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "inputBinding": {
                        "prefix": "--recursive"
                    },
                    "id": "#ls.cwl/recursive"
                }
            ],
            "stdout": "cwl.output.json",
            "outputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#ls.cwl/out_files"
                }
            ],
            "id": "#ls.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "envDef": [
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LANG"
                        },
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LC_ALL"
                        }
                    ],
                    "class": "EnvVarRequirement"
                }
            ],
            "baseCommand": [
                "python",
                "-m",
                "ochre.match_ocr_and_gs"
            ],
            "inputs": [
                {
                    "type": "Directory",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#match-ocr-and-gs.cwl/gs_dir"
                },
                {
                    "type": "Directory",
                    "inputBinding": {
                        "position": 0
                    },
                    "id": "#match-ocr-and-gs.cwl/ocr_dir"
                }
            ],
            "outputs": [
                {
                    "type": "Directory",
                    "outputBinding": {
                        "glob": "gs"
                    },
                    "id": "#match-ocr-and-gs.cwl/gs"
                },
                {
                    "type": "Directory",
                    "outputBinding": {
                        "glob": "$(runtime.outdir)/ocr"
                    },
                    "id": "#match-ocr-and-gs.cwl/ocr"
                }
            ],
            "id": "#match-ocr-and-gs.cwl"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "nlppln.commands.remove_newlines"
            ],
            "doc": "Remove newlines from a text.\n",
            "requirements": [
                {
                    "envDef": [
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LANG"
                        },
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LC_ALL"
                        }
                    ],
                    "class": "EnvVarRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#remove-newlines.cwl/in_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "--replacement"
                    },
                    "id": "#remove-newlines.cwl/replacement"
                }
            ],
            "stdout": "$(inputs.in_file.nameroot).txt",
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.in_file.nameroot).txt"
                    },
                    "id": "#remove-newlines.cwl/out_files"
                }
            ],
            "id": "#remove-newlines.cwl"
        },
        {
            "class": "ExpressionTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "doc": "Save a list of files to a directory.\n\nIf the ``dir_name`` is not specified, it is set to the string before the rightmost - of the ``nameroot`` of the first input file\n(e.g., ``input-file-1-0000.txt`` becomes ``input-file-1``). If the file name does not contain a -, the ``nameroot`` is used (e.g.\n``input.txt`` becomes ``input``).\n",
            "inputs": [
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#save-files-to-dir.cwl/dir_name"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#save-files-to-dir.cwl/in_files"
                }
            ],
            "outputs": [
                {
                    "type": "Directory",
                    "id": "#save-files-to-dir.cwl/out"
                }
            ],
            "expression": "${\n  var dir_name;\n  if (inputs.dir_name == null ){\n     var parts = inputs.in_files[0].nameroot.split('-');\n     if (parts.length > 1){\n       dir_name = parts.slice(0, -1).join('-')\n     } else {\n       dir_name = parts[0]\n     }\n\n  } else {\n    dir_name = inputs.dir_name;\n  }\n  return {\"out\": {\n    \"class\": \"Directory\",\n    \"basename\": dir_name,\n    \"listing\": inputs.in_files\n  } };\n}\n",
            "id": "#save-files-to-dir.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "envDef": [
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LANG"
                        },
                        {
                            "envValue": "C.UTF-8",
                            "envName": "LC_ALL"
                        }
                    ],
                    "class": "EnvVarRequirement"
                }
            ],
            "doc": "Convert tei documents to plain text using `xmllint`.\nThis is a very simple solution taken from `digitalhumanities.org <http://digitalhumanities.org/answers/topic/how-do-i-best-convert-hundreds-of-tei-p5-documents-to-plaintext>`_.\n\nTODO: put in Docker containing xmllint\n",
            "baseCommand": [
                "xmllint",
                "--xpath",
                "string(//*[local-name()='body'])"
            ],
            "stdout": "$(inputs.tei_file.nameroot).txt",
            "inputs": [
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 0
                    },
                    "id": "#tei2txt.cwl/tei_file"
                }
            ],
            "outputs": [
                {
                    "type": "stdout",
                    "id": "#tei2txt.cwl/txt_file"
                }
            ],
            "id": "#tei2txt.cwl"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "ScatterFeatureRequirement"
                }
            ],
            "inputs": [
                {
                    "default": true,
                    "type": "boolean",
                    "id": "#main/convert"
                },
                {
                    "default": "space",
                    "type": "string",
                    "id": "#main/replacement"
                },
                {
                    "type": "Directory",
                    "id": "#main/tei_dir"
                },
                {
                    "default": "tmp_gs",
                    "type": "string",
                    "id": "#main/tmp_gs_dir_name"
                },
                {
                    "default": "tmp_ocr",
                    "type": "string",
                    "id": "#main/tmp_ocr_dir_name"
                },
                {
                    "type": "Directory",
                    "id": "#main/txt_dir"
                }
            ],
            "outputs": [
                {
                    "outputSource": "#main/match-ocr-and-gs/gs",
                    "type": "Directory",
                    "id": "#main/gs"
                },
                {
                    "outputSource": "#main/match-ocr-and-gs/ocr",
                    "type": "Directory",
                    "id": "#main/ocr"
                }
            ],
            "steps": [
                {
                    "run": "#check-utf8.cwl",
                    "in": [
                        {
                            "source": "#main/convert",
                            "id": "#main/check-utf8/convert"
                        },
                        {
                            "source": "#main/ls-1/out_files",
                            "id": "#main/check-utf8/in_files"
                        }
                    ],
                    "out": [
                        "#main/check-utf8/utf8_files"
                    ],
                    "id": "#main/check-utf8"
                },
                {
                    "run": "#delete-empty-files.cwl",
                    "in": [
                        {
                            "source": "#main/save-files-to-dir/out",
                            "id": "#main/delete-empty-files/in_dir"
                        }
                    ],
                    "out": [
                        "#main/delete-empty-files/out_files"
                    ],
                    "id": "#main/delete-empty-files"
                },
                {
                    "run": "#delete-empty-files.cwl",
                    "in": [
                        {
                            "source": "#main/save-files-to-dir-1/out",
                            "id": "#main/delete-empty-files-1/in_dir"
                        }
                    ],
                    "out": [
                        "#main/delete-empty-files-1/out_files"
                    ],
                    "id": "#main/delete-empty-files-1"
                },
                {
                    "run": "#ls.cwl",
                    "in": [
                        {
                            "source": "#main/tei_dir",
                            "id": "#main/ls/in_dir"
                        }
                    ],
                    "out": [
                        "#main/ls/out_files"
                    ],
                    "id": "#main/ls"
                },
                {
                    "run": "#ls.cwl",
                    "in": [
                        {
                            "source": "#main/txt_dir",
                            "id": "#main/ls-1/in_dir"
                        }
                    ],
                    "out": [
                        "#main/ls-1/out_files"
                    ],
                    "id": "#main/ls-1"
                },
                {
                    "run": "#match-ocr-and-gs.cwl",
                    "in": [
                        {
                            "source": "#main/save-files-to-dir-2/out",
                            "id": "#main/match-ocr-and-gs/gs_dir"
                        },
                        {
                            "source": "#main/save-files-to-dir-3/out",
                            "id": "#main/match-ocr-and-gs/ocr_dir"
                        }
                    ],
                    "out": [
                        "#main/match-ocr-and-gs/gs",
                        "#main/match-ocr-and-gs/ocr"
                    ],
                    "id": "#main/match-ocr-and-gs"
                },
                {
                    "run": "#remove-newlines.cwl",
                    "in": [
                        {
                            "source": "#main/tei2txt/txt_file",
                            "id": "#main/remove-newlines/in_file"
                        },
                        {
                            "source": "#main/replacement",
                            "id": "#main/remove-newlines/replacement"
                        }
                    ],
                    "out": [
                        "#main/remove-newlines/out_files"
                    ],
                    "scatter": [
                        "#main/remove-newlines/in_file"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#main/remove-newlines"
                },
                {
                    "run": "#remove-newlines.cwl",
                    "in": [
                        {
                            "source": "#main/check-utf8/utf8_files",
                            "id": "#main/remove-newlines-1/in_file"
                        },
                        {
                            "source": "#main/replacement",
                            "id": "#main/remove-newlines-1/replacement"
                        }
                    ],
                    "out": [
                        "#main/remove-newlines-1/out_files"
                    ],
                    "scatter": [
                        "#main/remove-newlines-1/in_file"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#main/remove-newlines-1"
                },
                {
                    "run": "#save-files-to-dir.cwl",
                    "in": [
                        {
                            "source": "#main/tmp_gs_dir_name",
                            "id": "#main/save-files-to-dir/dir_name"
                        },
                        {
                            "source": "#main/remove-newlines/out_files",
                            "id": "#main/save-files-to-dir/in_files"
                        }
                    ],
                    "out": [
                        "#main/save-files-to-dir/out"
                    ],
                    "id": "#main/save-files-to-dir"
                },
                {
                    "run": "#save-files-to-dir.cwl",
                    "in": [
                        {
                            "source": "#main/tmp_ocr_dir_name",
                            "id": "#main/save-files-to-dir-1/dir_name"
                        },
                        {
                            "source": "#main/remove-newlines-1/out_files",
                            "id": "#main/save-files-to-dir-1/in_files"
                        }
                    ],
                    "out": [
                        "#main/save-files-to-dir-1/out"
                    ],
                    "id": "#main/save-files-to-dir-1"
                },
                {
                    "run": "#save-files-to-dir.cwl",
                    "in": [
                        {
                            "source": "#main/tmp_gs_dir_name",
                            "id": "#main/save-files-to-dir-2/dir_name"
                        },
                        {
                            "source": "#main/delete-empty-files/out_files",
                            "id": "#main/save-files-to-dir-2/in_files"
                        }
                    ],
                    "out": [
                        "#main/save-files-to-dir-2/out"
                    ],
                    "id": "#main/save-files-to-dir-2"
                },
                {
                    "run": "#save-files-to-dir.cwl",
                    "in": [
                        {
                            "source": "#main/tmp_ocr_dir_name",
                            "id": "#main/save-files-to-dir-3/dir_name"
                        },
                        {
                            "source": "#main/delete-empty-files-1/out_files",
                            "id": "#main/save-files-to-dir-3/in_files"
                        }
                    ],
                    "out": [
                        "#main/save-files-to-dir-3/out"
                    ],
                    "id": "#main/save-files-to-dir-3"
                },
                {
                    "run": "#tei2txt.cwl",
                    "in": [
                        {
                            "source": "#main/ls/out_files",
                            "id": "#main/tei2txt/tei_file"
                        }
                    ],
                    "out": [
                        "#main/tei2txt/txt_file"
                    ],
                    "scatter": [
                        "#main/tei2txt/tei_file"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#main/tei2txt"
                }
            ],
            "id": "#main"
        }
    ],
    "cwlVersion": "v1.0"
}