{
    "cwlVersion": "v1.0", 
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
                    "type": {
                        "items": "File", 
                        "type": "array"
                    }, 
                    "outputSource": "#align-texts-wf.cwl/char-align/out_file", 
                    "id": "#align-texts-wf.cwl/alignments"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#align-texts-wf.cwl/merge-json-1/merged", 
                    "id": "#align-texts-wf.cwl/changes"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#align-texts-wf.cwl/merge-json/merged", 
                    "id": "#align-texts-wf.cwl/metadata"
                }
            ], 
            "steps": [
                {
                    "run": "#align.cwl", 
                    "in": [
                        {
                            "source": "#align-texts-wf.cwl/ocr", 
                            "id": "#align-texts-wf.cwl/align/file1"
                        }, 
                        {
                            "source": "#align-texts-wf.cwl/gs", 
                            "id": "#align-texts-wf.cwl/align/file2"
                        }
                    ], 
                    "out": [
                        "#align-texts-wf.cwl/align/changes", 
                        "#align-texts-wf.cwl/align/metadata"
                    ], 
                    "scatter": [
                        "#align-texts-wf.cwl/align/file1", 
                        "#align-texts-wf.cwl/align/file2"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#align-texts-wf.cwl/align"
                }, 
                {
                    "run": "#char-align.cwl", 
                    "in": [
                        {
                            "source": "#align-texts-wf.cwl/gs", 
                            "id": "#align-texts-wf.cwl/char-align/gs_text"
                        }, 
                        {
                            "source": "#align-texts-wf.cwl/align/metadata", 
                            "id": "#align-texts-wf.cwl/char-align/metadata"
                        }, 
                        {
                            "source": "#align-texts-wf.cwl/ocr", 
                            "id": "#align-texts-wf.cwl/char-align/ocr_text"
                        }
                    ], 
                    "out": [
                        "#align-texts-wf.cwl/char-align/out_file"
                    ], 
                    "scatter": [
                        "#align-texts-wf.cwl/char-align/gs_text", 
                        "#align-texts-wf.cwl/char-align/ocr_text", 
                        "#align-texts-wf.cwl/char-align/metadata"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#align-texts-wf.cwl/char-align"
                }, 
                {
                    "run": "#merge-json.cwl", 
                    "in": [
                        {
                            "source": "#align-texts-wf.cwl/align/metadata", 
                            "id": "#align-texts-wf.cwl/merge-json/in_files"
                        }, 
                        {
                            "source": "#align-texts-wf.cwl/align_m", 
                            "id": "#align-texts-wf.cwl/merge-json/name"
                        }
                    ], 
                    "out": [
                        "#align-texts-wf.cwl/merge-json/merged"
                    ], 
                    "id": "#align-texts-wf.cwl/merge-json"
                }, 
                {
                    "run": "#merge-json.cwl", 
                    "in": [
                        {
                            "source": "#align-texts-wf.cwl/align/changes", 
                            "id": "#align-texts-wf.cwl/merge-json-1/in_files"
                        }, 
                        {
                            "source": "#align-texts-wf.cwl/align_c", 
                            "id": "#align-texts-wf.cwl/merge-json-1/name"
                        }
                    ], 
                    "out": [
                        "#align-texts-wf.cwl/merge-json-1/merged"
                    ], 
                    "id": "#align-texts-wf.cwl/merge-json-1"
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
                "ochre.merge_json"
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
                    "default": "align", 
                    "type": "string", 
                    "id": "#main/align_dir_name"
                }, 
                {
                    "type": "File", 
                    "id": "#main/data_div"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/gs_dir"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/ocr_dir"
                }
            ], 
            "outputs": [
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-files-to-dir-9/out", 
                    "id": "#main/align"
                }
            ], 
            "steps": [
                {
                    "run": "#align-texts-wf.cwl", 
                    "in": [
                        {
                            "source": "#main/select-test-files-3/out_files", 
                            "id": "#main/align-texts-wf-1/gs"
                        }, 
                        {
                            "source": "#main/select-test-files-4/out_files", 
                            "id": "#main/align-texts-wf-1/ocr"
                        }
                    ], 
                    "out": [
                        "#main/align-texts-wf-1/alignments", 
                        "#main/align-texts-wf-1/changes", 
                        "#main/align-texts-wf-1/metadata"
                    ], 
                    "id": "#main/align-texts-wf-1"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/align_dir_name", 
                            "id": "#main/save-files-to-dir-9/dir_name"
                        }, 
                        {
                            "source": "#main/align-texts-wf-1/alignments", 
                            "id": "#main/save-files-to-dir-9/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-9/out"
                    ], 
                    "id": "#main/save-files-to-dir-9"
                }, 
                {
                    "run": "#select-test-files.cwl", 
                    "in": [
                        {
                            "source": "#main/data_div", 
                            "id": "#main/select-test-files-3/datadivision"
                        }, 
                        {
                            "source": "#main/gs_dir", 
                            "id": "#main/select-test-files-3/in_dir"
                        }
                    ], 
                    "out": [
                        "#main/select-test-files-3/out_files"
                    ], 
                    "id": "#main/select-test-files-3"
                }, 
                {
                    "run": "#select-test-files.cwl", 
                    "in": [
                        {
                            "source": "#main/data_div", 
                            "id": "#main/select-test-files-4/datadivision"
                        }, 
                        {
                            "source": "#main/ocr_dir", 
                            "id": "#main/select-test-files-4/in_dir"
                        }
                    ], 
                    "out": [
                        "#main/select-test-files-4/out_files"
                    ], 
                    "id": "#main/select-test-files-4"
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
    ]
}