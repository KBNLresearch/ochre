{
    "cwlVersion": "v1.0", 
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
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract-1/character_data", 
                    "id": "#ocrevaluation-performance-wf.cwl/character_data"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract-1/global_data", 
                    "id": "#ocrevaluation-performance-wf.cwl/global_data"
                }
            ], 
            "steps": [
                {
                    "run": "#ocrevaluation.cwl", 
                    "in": [
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/gt", 
                            "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-1/gt"
                        }, 
                        {
                            "source": "#ocrevaluation-performance-wf.cwl/ocr", 
                            "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-1/ocr"
                        }
                    ], 
                    "out": [
                        "#ocrevaluation-performance-wf.cwl/ocrevaluation-1/out_file"
                    ], 
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
                    "id": "#ocrevaluation-performance-wf.cwl/ocrevaluation-extract-1"
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
                    "type": "File", 
                    "outputSource": "#main/merge-csv/merged", 
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