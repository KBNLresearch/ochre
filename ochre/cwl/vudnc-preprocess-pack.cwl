{
    "$graph": [
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "nlppln.commands.archive2dir"
            ],
            "doc": "Extract archive.\n\nTo recursively put all files in the output directory, use the\n`--remove-dir-structure` option.\n\nUses `Patool <http://wummel.github.io/patool/>`_ for extracting archives.\n",
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
            "arguments": [
                {
                    "prefix": "-o",
                    "valueFrom": "$(runtime.outdir)"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#archive2dir.cwl/archive"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "inputBinding": {
                        "prefix": "--remove-dir-structure"
                    },
                    "id": "#archive2dir.cwl/remove-dir-structure"
                }
            ],
            "outputs": [
                {
                    "type": "Directory",
                    "outputBinding": {
                        "glob": "*"
                    },
                    "id": "#archive2dir.cwl/out_dir"
                }
            ],
            "id": "#archive2dir.cwl"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "ochre.remove_empty_files"
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
                        "position": 1
                    },
                    "id": "#remove-empty-files.cwl/gs_dir"
                },
                {
                    "type": "Directory",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#remove-empty-files.cwl/ocr_dir"
                }
            ],
            "stdout": "cwl.output.json",
            "outputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#remove-empty-files.cwl/gs"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#remove-empty-files.cwl/ocr"
                }
            ],
            "id": "#remove-empty-files.cwl"
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
            "baseCommand": [
                "python",
                "-m",
                "ochre.select_vudnc_files"
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
                        "position": 1
                    },
                    "id": "#vudnc-select-files.cwl/in_dir"
                }
            ],
            "stdout": "cwl.output.json",
            "outputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#vudnc-select-files.cwl/out_files"
                }
            ],
            "id": "#vudnc-select-files.cwl"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "ochre.vudnc2ocr_and_gs"
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
                    "type": "File",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#vudnc2ocr-and-gs.cwl/in_file"
                },
                {
                    "type": [
                        "null",
                        "Directory"
                    ],
                    "inputBinding": {
                        "prefix": "--out_dir=",
                        "separate": false
                    },
                    "id": "#vudnc2ocr-and-gs.cwl/out_dir"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "*.gs.txt"
                    },
                    "id": "#vudnc2ocr-and-gs.cwl/gs"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "*.ocr.txt"
                    },
                    "id": "#vudnc2ocr-and-gs.cwl/ocr"
                }
            ],
            "id": "#vudnc2ocr-and-gs.cwl"
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
                    "type": "File",
                    "id": "#main/archive"
                },
                {
                    "default": "gs",
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#main/gs_dir_name"
                },
                {
                    "default": "ocr",
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#main/ocr_dir_name"
                }
            ],
            "outputs": [
                {
                    "outputSource": "#main/save-files-to-dir-14/out",
                    "type": "Directory",
                    "id": "#main/gs_dir"
                },
                {
                    "outputSource": "#main/save-files-to-dir-15/out",
                    "type": "Directory",
                    "id": "#main/ocr_dir"
                }
            ],
            "steps": [
                {
                    "run": "#archive2dir.cwl",
                    "in": [
                        {
                            "source": "#main/archive",
                            "id": "#main/archive2dir/archive"
                        }
                    ],
                    "out": [
                        "#main/archive2dir/out_dir"
                    ],
                    "id": "#main/archive2dir"
                },
                {
                    "run": "#remove-empty-files.cwl",
                    "in": [
                        {
                            "source": "#main/save-files-to-dir-5/out",
                            "id": "#main/remove-empty-files-1/gs_dir"
                        },
                        {
                            "source": "#main/save-files-to-dir-13/out",
                            "id": "#main/remove-empty-files-1/ocr_dir"
                        }
                    ],
                    "out": [
                        "#main/remove-empty-files-1/gs",
                        "#main/remove-empty-files-1/ocr"
                    ],
                    "id": "#main/remove-empty-files-1"
                },
                {
                    "run": "#save-files-to-dir.cwl",
                    "in": [
                        {
                            "source": "#main/ocr_dir_name",
                            "id": "#main/save-files-to-dir-13/dir_name"
                        },
                        {
                            "source": "#main/vudnc2ocr-and-gs-1/ocr",
                            "id": "#main/save-files-to-dir-13/in_files"
                        }
                    ],
                    "out": [
                        "#main/save-files-to-dir-13/out"
                    ],
                    "id": "#main/save-files-to-dir-13"
                },
                {
                    "run": "#save-files-to-dir.cwl",
                    "in": [
                        {
                            "source": "#main/gs_dir_name",
                            "id": "#main/save-files-to-dir-14/dir_name"
                        },
                        {
                            "source": "#main/remove-empty-files-1/gs",
                            "id": "#main/save-files-to-dir-14/in_files"
                        }
                    ],
                    "out": [
                        "#main/save-files-to-dir-14/out"
                    ],
                    "id": "#main/save-files-to-dir-14"
                },
                {
                    "run": "#save-files-to-dir.cwl",
                    "in": [
                        {
                            "source": "#main/ocr_dir_name",
                            "id": "#main/save-files-to-dir-15/dir_name"
                        },
                        {
                            "source": "#main/remove-empty-files-1/ocr",
                            "id": "#main/save-files-to-dir-15/in_files"
                        }
                    ],
                    "out": [
                        "#main/save-files-to-dir-15/out"
                    ],
                    "id": "#main/save-files-to-dir-15"
                },
                {
                    "run": "#save-files-to-dir.cwl",
                    "in": [
                        {
                            "source": "#main/gs_dir_name",
                            "id": "#main/save-files-to-dir-5/dir_name"
                        },
                        {
                            "source": "#main/vudnc2ocr-and-gs-1/gs",
                            "id": "#main/save-files-to-dir-5/in_files"
                        }
                    ],
                    "out": [
                        "#main/save-files-to-dir-5/out"
                    ],
                    "id": "#main/save-files-to-dir-5"
                },
                {
                    "run": "#vudnc-select-files.cwl",
                    "in": [
                        {
                            "source": "#main/archive2dir/out_dir",
                            "id": "#main/vudnc-select-files-1/in_dir"
                        }
                    ],
                    "out": [
                        "#main/vudnc-select-files-1/out_files"
                    ],
                    "id": "#main/vudnc-select-files-1"
                },
                {
                    "run": "#vudnc2ocr-and-gs.cwl",
                    "in": [
                        {
                            "source": "#main/vudnc-select-files-1/out_files",
                            "id": "#main/vudnc2ocr-and-gs-1/in_file"
                        }
                    ],
                    "out": [
                        "#main/vudnc2ocr-and-gs-1/gs",
                        "#main/vudnc2ocr-and-gs-1/ocr"
                    ],
                    "scatter": [
                        "#main/vudnc2ocr-and-gs-1/in_file"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#main/vudnc2ocr-and-gs-1"
                }
            ],
            "id": "#main"
        }
    ],
    "cwlVersion": "v1.0"
}