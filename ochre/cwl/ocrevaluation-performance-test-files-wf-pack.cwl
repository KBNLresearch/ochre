{
    "$graph": [
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "nlppln.commands.merge_csv"
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
            "doc": "Merge csv files (with the same header) into a single csv file.",
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#merge-csv.cwl/in_files"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "merged.csv",
                    "inputBinding": {
                        "prefix": "--name=",
                        "separate": false
                    },
                    "id": "#merge-csv.cwl/name"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.name)"
                    },
                    "id": "#merge-csv.cwl/merged"
                }
            ],
            "id": "#merge-csv.cwl"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "ochre.ocrevaluation_extract"
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
                    "id": "#ocrevaluation-extract.cwl/in_file"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "*-character.csv"
                    },
                    "id": "#ocrevaluation-extract.cwl/character_data"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "*-global.csv"
                    },
                    "id": "#ocrevaluation-extract.cwl/global_data"
                }
            ],
            "id": "#ocrevaluation-extract.cwl"
        },
        {
            "class": "Workflow",
            "inputs": [
                {
                    "type": "File",
                    "id": "#ocrevaluation-performance-wf.cwl/gt"
                },
                {
                    "type": "File",
                    "id": "#ocrevaluation-performance-wf.cwl/ocr"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#ocrevaluation-performance-wf.cwl/xmx"
                }
            ],
            "outputs": [
                {
                    "outputSource": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract/character_data",
                    "type": "File",
                    "id": "#ocrevaluation-performance-wf.cwl/character_data"
                },
                {
                    "outputSource": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract/global_data",
                    "type": "File",
                    "id": "#ocrevaluation-performance-wf.cwl/global_data"
                }
            ],
            "steps": [
                {
                    "run": "#ocrevaluation.cwl",
                    "in": [
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/gt",
                            "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation/gt"
                        },
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/ocr",
                            "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation/ocr"
                        },
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/xmx",
                            "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation/xmx"
                        }
                    ],
                    "out": [
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation/out_file"
                    ],
                    "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation"
                },
                {
                    "run": "#ocrevaluation-extract.cwl",
                    "in": [
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/ocrevaluation/out_file",
                            "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract/in_file"
                        }
                    ],
                    "out": [
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract/character_data",
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract/global_data"
                    ],
                    "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract"
                }
            ],
            "id": "#ocrevaluation-performance-wf.cwl"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "python",
                "-m",
                "ochre.select_test_files"
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
            "stdout": "cwl.output.json",
            "inputs": [
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#select-test-files.cwl/datadivision"
                },
                {
                    "type": "Directory",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#select-test-files.cwl/in_dir"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "--name"
                    },
                    "id": "#select-test-files.cwl/name"
                }
            ],
            "outputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#select-test-files.cwl/out_files"
                }
            ],
            "id": "#select-test-files.cwl"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "SubworkflowFeatureRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "id": "#main/datadivision"
                },
                {
                    "default": "test",
                    "type": "string",
                    "id": "#main/div_name"
                },
                {
                    "type": "Directory",
                    "id": "#main/gt"
                },
                {
                    "default": "gs",
                    "type": "string",
                    "id": "#main/gt_dir_name"
                },
                {
                    "type": "Directory",
                    "id": "#main/ocr"
                },
                {
                    "default": "ocr",
                    "type": "string",
                    "id": "#main/ocr_dir_name"
                },
                {
                    "default": "performance.csv",
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#main/out_name"
                }
            ],
            "outputs": [
                {
                    "outputSource": "#main/merge-csv/merged",
                    "type": "File",
                    "id": "#main/performance"
                }
            ],
            "steps": [
                {
                    "run": "#merge-csv.cwl",
                    "in": [
                        {
                            "source": "#main/ocrevaluation-performance-wf/global_data",
                            "id": "#main/merge-csv/in_files"
                        },
                        {
                            "source": "#main/out_name",
                            "id": "#main/merge-csv/name"
                        }
                    ],
                    "out": [
                        "#main/merge-csv/merged"
                    ],
                    "id": "#main/merge-csv"
                },
                {
                    "run": "#ocrevaluation-performance-wf.cwl",
                    "in": [
                        {
                            "source": "#main/select-test-files-1/out_files",
                            "id": "#main/ocrevaluation-performance-wf/gt"
                        },
                        {
                            "source": "#main/select-test-files/out_files",
                            "id": "#main/ocrevaluation-performance-wf/ocr"
                        }
                    ],
                    "out": [
                        "#main/ocrevaluation-performance-wf/character_data",
                        "#main/ocrevaluation-performance-wf/global_data"
                    ],
                    "scatter": [
                        "#main/ocrevaluation-performance-wf/gt",
                        "#main/ocrevaluation-performance-wf/ocr"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#main/ocrevaluation-performance-wf"
                },
                {
                    "run": "#select-test-files.cwl",
                    "in": [
                        {
                            "source": "#main/datadivision",
                            "id": "#main/select-test-files/datadivision"
                        },
                        {
                            "source": "#main/ocr",
                            "id": "#main/select-test-files/in_dir"
                        },
                        {
                            "source": "#main/div_name",
                            "id": "#main/select-test-files/name"
                        }
                    ],
                    "out": [
                        "#main/select-test-files/out_files"
                    ],
                    "id": "#main/select-test-files"
                },
                {
                    "run": "#select-test-files.cwl",
                    "in": [
                        {
                            "source": "#main/datadivision",
                            "id": "#main/select-test-files-1/datadivision"
                        },
                        {
                            "source": "#main/gt",
                            "id": "#main/select-test-files-1/in_dir"
                        },
                        {
                            "source": "#main/div_name",
                            "id": "#main/select-test-files-1/name"
                        }
                    ],
                    "out": [
                        "#main/select-test-files-1/out_files"
                    ],
                    "id": "#main/select-test-files-1"
                }
            ],
            "id": "#main"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "java",
                "-cp",
                "/ocrevalUAtion/target/ocrevaluation.jar"
            ],
            "requirements": [
                {
                    "class": "DockerRequirement",
                    "dockerPull": "nlppln/ocrevaluation-docker"
                },
                {
                    "class": "InitialWorkDirRequirement",
                    "listing": [
                        {
                            "entryname": "$(inputs.gt.nameroot)_out.html",
                            "entry": "<h2>General results</h2>\n<table border=\"1\">\n<tr>\n<td>CER</td><td>n/a</td>\n</tr>\n<tr>\n<td>WER</td><td>n/a</td>\n</tr>\n<tr>\n<td>WER (order independent)</td><td>n/a</td>\n</tr>\n</table>\n<h2>Difference spotting</h2>\n<table border=\"1\">\n</table>\n<h2>Error rate per character and type</h2>\n<table border=\"1\">\n<tr>\n<td>Character</td><td>Hex code</td><td>Total</td><td>Spurious</td><td>Confused</td><td>Lost</td><td>Error rate</td>\n</tr>\n<tr>\n<td>n/a</td><td>n/a</td><td>n/a</td><td>n/a</td><td>n/a</td><td>n/a</td><td>n/a</td>\n</tr>\n</table>\n"
                        }
                    ]
                }
            ],
            "arguments": [
                {
                    "prefix": "-o",
                    "valueFrom": "$(runtime.outdir)/$(inputs.gt.nameroot)_out.html",
                    "position": 4
                },
                {
                    "valueFrom": "eu.digitisation.Main",
                    "position": 1
                }
            ],
            "successCodes": [
                1
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "-e",
                        "position": 5
                    },
                    "id": "#ocrevaluation.cwl/encoding"
                },
                {
                    "type": "File",
                    "inputBinding": {
                        "prefix": "-gt",
                        "position": 2
                    },
                    "id": "#ocrevaluation.cwl/gt"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "inputBinding": {
                        "prefix": "-ic",
                        "position": 6
                    },
                    "id": "#ocrevaluation.cwl/ignore_case"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "inputBinding": {
                        "prefix": "-id",
                        "position": 7
                    },
                    "id": "#ocrevaluation.cwl/ignore_diacritics"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "inputBinding": {
                        "prefix": "-ip",
                        "position": 8
                    },
                    "id": "#ocrevaluation.cwl/ignore_punctuation"
                },
                {
                    "type": "File",
                    "inputBinding": {
                        "prefix": "-ocr",
                        "position": 3
                    },
                    "id": "#ocrevaluation.cwl/ocr"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "5G",
                    "inputBinding": {
                        "prefix": "-Xmx",
                        "separate": false,
                        "position": 0
                    },
                    "id": "#ocrevaluation.cwl/xmx"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.gt.nameroot)_out.html"
                    },
                    "id": "#ocrevaluation.cwl/out_file"
                }
            ],
            "id": "#ocrevaluation.cwl"
        }
    ],
    "cwlVersion": "v1.0"
}