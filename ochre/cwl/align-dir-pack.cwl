{
    "$graph": [
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "ScatterFeatureRequirement"
                }
            ],
            "inputs": [
                {
                    "default": "merged_changes.csv",
                    "type": "string",
                    "id": "#align-texts-wf.cwl/align_c"
                },
                {
                    "default": "merged_metadata.csv",
                    "type": "string",
                    "id": "#align-texts-wf.cwl/align_m"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#align-texts-wf.cwl/gs"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#align-texts-wf.cwl/ocr"
                }
            ],
            "outputs": [
                {
                    "outputSource": "#align-texts-wf.cwl/char-align-1/out_file",
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#align-texts-wf.cwl/alignments"
                },
                {
                    "outputSource": "#align-texts-wf.cwl/merge-json-3/merged",
                    "type": "File",
                    "id": "#align-texts-wf.cwl/changes"
                },
                {
                    "outputSource": "#align-texts-wf.cwl/merge-json-2/merged",
                    "type": "File",
                    "id": "#align-texts-wf.cwl/metadata"
                }
            ],
            "steps": [
                {
                    "run": "#align.cwl",
                    "in": [
                        {
                            "source": "#align-texts-wf.cwl/ocr",
                            "id": "#align-texts-wf.cwl/align-1/file1"
                        },
                        {
                            "source": "#align-texts-wf.cwl/gs",
                            "id": "#align-texts-wf.cwl/align-1/file2"
                        }
                    ],
                    "out": [
                        "#align-texts-wf.cwl/align-1/changes",
                        "#align-texts-wf.cwl/align-1/metadata"
                    ],
                    "scatter": [
                        "#align-texts-wf.cwl/align-1/file1",
                        "#align-texts-wf.cwl/align-1/file2"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#align-texts-wf.cwl/align-1"
                },
                {
                    "run": "#char-align.cwl",
                    "in": [
                        {
                            "source": "#align-texts-wf.cwl/gs",
                            "id": "#align-texts-wf.cwl/char-align-1/gs_text"
                        },
                        {
                            "source": "#align-texts-wf.cwl/align-1/metadata",
                            "id": "#align-texts-wf.cwl/char-align-1/metadata"
                        },
                        {
                            "source": "#align-texts-wf.cwl/ocr",
                            "id": "#align-texts-wf.cwl/char-align-1/ocr_text"
                        }
                    ],
                    "out": [
                        "#align-texts-wf.cwl/char-align-1/out_file"
                    ],
                    "scatter": [
                        "#align-texts-wf.cwl/char-align-1/gs_text",
                        "#align-texts-wf.cwl/char-align-1/ocr_text",
                        "#align-texts-wf.cwl/char-align-1/metadata"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#align-texts-wf.cwl/char-align-1"
                },
                {
                    "run": "#merge-json.cwl",
                    "in": [
                        {
                            "source": "#align-texts-wf.cwl/align-1/metadata",
                            "id": "#align-texts-wf.cwl/merge-json-2/in_files"
                        },
                        {
                            "source": "#align-texts-wf.cwl/align_m",
                            "id": "#align-texts-wf.cwl/merge-json-2/name"
                        }
                    ],
                    "out": [
                        "#align-texts-wf.cwl/merge-json-2/merged"
                    ],
                    "id": "#align-texts-wf.cwl/merge-json-2"
                },
                {
                    "run": "#merge-json.cwl",
                    "in": [
                        {
                            "source": "#align-texts-wf.cwl/align-1/changes",
                            "id": "#align-texts-wf.cwl/merge-json-3/in_files"
                        },
                        {
                            "source": "#align-texts-wf.cwl/align_c",
                            "id": "#align-texts-wf.cwl/merge-json-3/name"
                        }
                    ],
                    "out": [
                        "#align-texts-wf.cwl/merge-json-3/merged"
                    ],
                    "id": "#align-texts-wf.cwl/merge-json-3"
                }
            ],
            "id": "#align-texts-wf.cwl"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "ochre.char_align"
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
                        "position": 2
                    },
                    "id": "#char-align.cwl/gs_text"
                },
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 3
                    },
                    "id": "#char-align.cwl/metadata"
                },
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#char-align.cwl/ocr_text"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "*.json"
                    },
                    "id": "#char-align.cwl/out_file"
                }
            ],
            "id": "#char-align.cwl"
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
            "baseCommand": [
                "python",
                "-m",
                "ochre.merge_json"
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
                },
                {
                    "listing": "$(inputs.in_files)",
                    "class": "InitialWorkDirRequirement"
                }
            ],
            "arguments": [
                {
                    "valueFrom": "$(runtime.outdir)",
                    "position": 1
                }
            ],
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#merge-json.cwl/in_files"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "--name=",
                        "separate": false
                    },
                    "id": "#merge-json.cwl/name"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "*.csv"
                    },
                    "id": "#merge-json.cwl/merged"
                }
            ],
            "id": "#merge-json.cwl"
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
            "class": "Workflow",
            "requirements": [
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ],
            "inputs": [
                {
                    "default": "align",
                    "type": "string",
                    "id": "#main/align_dir_name"
                },
                {
                    "type": "Directory",
                    "id": "#main/gs"
                },
                {
                    "type": "Directory",
                    "id": "#main/ocr"
                }
            ],
            "outputs": [
                {
                    "outputSource": "#main/save-files-to-dir-2/out",
                    "type": "Directory",
                    "id": "#main/align"
                }
            ],
            "steps": [
                {
                    "run": "#align-texts-wf.cwl",
                    "in": [
                        {
                            "source": "#main/ls-2/out_files",
                            "id": "#main/align-texts-wf/gs"
                        },
                        {
                            "source": "#main/ls-5/out_files",
                            "id": "#main/align-texts-wf/ocr"
                        }
                    ],
                    "out": [
                        "#main/align-texts-wf/alignments",
                        "#main/align-texts-wf/changes",
                        "#main/align-texts-wf/metadata"
                    ],
                    "id": "#main/align-texts-wf"
                },
                {
                    "run": "#ls.cwl",
                    "in": [
                        {
                            "source": "#main/gs",
                            "id": "#main/ls-2/in_dir"
                        }
                    ],
                    "out": [
                        "#main/ls-2/out_files"
                    ],
                    "id": "#main/ls-2"
                },
                {
                    "run": "#ls.cwl",
                    "in": [
                        {
                            "source": "#main/ocr",
                            "id": "#main/ls-5/in_dir"
                        }
                    ],
                    "out": [
                        "#main/ls-5/out_files"
                    ],
                    "id": "#main/ls-5"
                },
                {
                    "run": "#save-files-to-dir.cwl",
                    "in": [
                        {
                            "source": "#main/align_dir_name",
                            "id": "#main/save-files-to-dir-2/dir_name"
                        },
                        {
                            "source": "#main/align-texts-wf/alignments",
                            "id": "#main/save-files-to-dir-2/in_files"
                        }
                    ],
                    "out": [
                        "#main/save-files-to-dir-2/out"
                    ],
                    "id": "#main/save-files-to-dir-2"
                }
            ],
            "id": "#main"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "/align.py"
            ],
            "hints": [
                {
                    "class": "DockerRequirement",
                    "dockerPull": "nlppln/edlib-align:0.1.2"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#align.cwl/file1"
                },
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#align.cwl/file2"
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
                    "id": "#align.cwl/out_dir"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "*-changes.json"
                    },
                    "id": "#align.cwl/changes"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "*-metadata.json"
                    },
                    "id": "#align.cwl/metadata"
                }
            ],
            "id": "#align.cwl"
        }
    ],
    "cwlVersion": "v1.0"
}