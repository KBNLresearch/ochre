{
    "cwlVersion": "v1.0", 
    "$graph": [
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "python", 
                "-m", 
                "nlppln.commands.ls"
            ], 
            "doc": "List files in a directory.\n\nThis command can be used to convert a ``Directory`` into a list of files. This list can be filtered on file name by specifying ``--endswith``.\n", 
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
                "nlppln.commands.merge_csv"
            ], 
            "requirements": [
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
            "requirements": [
                {
                    "class": "ScatterFeatureRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "Directory", 
                    "id": "#ocrevaluation-performance-wf.cwl/gt"
                }, 
                {
                    "type": "Directory", 
                    "id": "#ocrevaluation-performance-wf.cwl/ocr"
                }, 
                {
                    "default": "performance.csv", 
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "id": "#ocrevaluation-performance-wf.cwl/out_name"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#ocrevaluation-performance-wf.cwl/merge-csv-1/merged", 
                    "id": "#ocrevaluation-performance-wf.cwl/performance"
                }
            ], 
            "steps": [
                {
                    "run": "#ls.cwl", 
                    "in": [
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/ocr", 
                            "id": "#ocrevaluation-performance-wf.cwl/ls-6/in_dir"
                        }
                    ], 
                    "out": [
                        "#ocrevaluation-performance-wf.cwl/ls-6/out_files"
                    ], 
                    "id": "#ocrevaluation-performance-wf.cwl/ls-6"
                }, 
                {
                    "run": "#ls.cwl", 
                    "in": [
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/gt", 
                            "id": "#ocrevaluation-performance-wf.cwl/ls-7/in_dir"
                        }
                    ], 
                    "out": [
                        "#ocrevaluation-performance-wf.cwl/ls-7/out_files"
                    ], 
                    "id": "#ocrevaluation-performance-wf.cwl/ls-7"
                }, 
                {
                    "run": "#merge-csv.cwl", 
                    "in": [
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract-1/global_data", 
                            "id": "#ocrevaluation-performance-wf.cwl/merge-csv-1/in_files"
                        }, 
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/out_name", 
                            "id": "#ocrevaluation-performance-wf.cwl/merge-csv-1/name"
                        }
                    ], 
                    "out": [
                        "#ocrevaluation-performance-wf.cwl/merge-csv-1/merged"
                    ], 
                    "id": "#ocrevaluation-performance-wf.cwl/merge-csv-1"
                }, 
                {
                    "run": "#ocrevaluation.cwl", 
                    "in": [
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/ls-7/out_files", 
                            "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-1/gt"
                        }, 
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/ls-6/out_files", 
                            "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-1/ocr"
                        }
                    ], 
                    "out": [
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation-1/out_file"
                    ], 
                    "scatter": [
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation-1/gt", 
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation-1/ocr"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-1"
                }, 
                {
                    "run": "#ocrevaluation-extract.cwl", 
                    "in": [
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/ocrevaluation-1/out_file", 
                            "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract-1/in_file"
                        }
                    ], 
                    "out": [
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract-1/character_data", 
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract-1/global_data"
                    ], 
                    "scatter": [
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract-1/in_file"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract-1"
                }
            ], 
            "id": "#ocrevaluation-performance-wf.cwl"
        }, 
        {
            "class": "ExpressionTool", 
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ], 
            "doc": "Save a list of files to a directory.\n", 
            "inputs": [
                {
                    "type": "string", 
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
            "expression": "${\n  return {\"out\": {\n    \"class\": \"Directory\",\n    \"basename\": inputs.dir_name,\n    \"listing\": inputs.in_files\n  } };\n}\n", 
            "id": "#save-files-to-dir.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "python", 
                "-m", 
                "ochre.select_test_files"
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
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "id": "#main/datadivision"
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
                    "type": "File", 
                    "outputSource": "#main/ocrevaluation-performance-wf/performance", 
                    "id": "#main/performance"
                }
            ], 
            "steps": [
                {
                    "run": "#ocrevaluation-performance-wf.cwl", 
                    "in": [
                        {
                            "source": "#main/save-files-to-dir/out", 
                            "id": "#main/ocrevaluation-performance-wf/gt"
                        }, 
                        {
                            "source": "#main/save-files-to-dir-5/out", 
                            "id": "#main/ocrevaluation-performance-wf/ocr"
                        }
                    ], 
                    "out": [
                        "#main/ocrevaluation-performance-wf/performance"
                    ], 
                    "id": "#main/ocrevaluation-performance-wf"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/gt_dir_name", 
                            "id": "#main/save-files-to-dir/dir_name"
                        }, 
                        {
                            "source": "#main/select-test-files-1/out_files", 
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
                            "source": "#main/ocr_dir_name", 
                            "id": "#main/save-files-to-dir-5/dir_name"
                        }, 
                        {
                            "source": "#main/select-test-files/out_files", 
                            "id": "#main/save-files-to-dir-5/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-5/out"
                    ], 
                    "id": "#main/save-files-to-dir-5"
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
                "/ocrevalUAtion/target/ocrevaluation.jar", 
                "eu.digitisation.Main"
            ], 
            "requirements": [
                {
                    "class": "DockerRequirement", 
                    "dockerPull": "nlppln/ocrevaluation-docker"
                }
            ], 
            "arguments": [
                {
                    "prefix": "-o", 
                    "valueFrom": "$(runtime.outdir)/$(inputs.gt.nameroot)_out.html"
                }
            ], 
            "inputs": [
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "inputBinding": {
                        "prefix": "-e"
                    }, 
                    "id": "#ocrevaluation.cwl/encoding"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "-gt"
                    }, 
                    "id": "#ocrevaluation.cwl/gt"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "-ic"
                    }, 
                    "id": "#ocrevaluation.cwl/ignore_case"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "-id"
                    }, 
                    "id": "#ocrevaluation.cwl/ignore_diacritics"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "-ip"
                    }, 
                    "id": "#ocrevaluation.cwl/ignore_punctuation"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "-ocr"
                    }, 
                    "id": "#ocrevaluation.cwl/ocr"
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
    ]
}