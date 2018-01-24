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
                    "outputSource": "#align-texts-wf.cwl/char-align-1/out_file", 
                    "id": "#align-texts-wf.cwl/alignments"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#align-texts-wf.cwl/merge-json-5/merged", 
                    "id": "#align-texts-wf.cwl/changes"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#align-texts-wf.cwl/merge-json-4/merged", 
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
                            "id": "#align-texts-wf.cwl/merge-json-4/in_files"
                        }, 
                        {
                            "source": "#align-texts-wf.cwl/align_m", 
                            "id": "#align-texts-wf.cwl/merge-json-4/name"
                        }
                    ], 
                    "out": [
                        "#align-texts-wf.cwl/merge-json-4/merged"
                    ], 
                    "id": "#align-texts-wf.cwl/merge-json-4"
                }, 
                {
                    "run": "#merge-json.cwl", 
                    "in": [
                        {
                            "source": "#align-texts-wf.cwl/align-1/changes", 
                            "id": "#align-texts-wf.cwl/merge-json-5/in_files"
                        }, 
                        {
                            "source": "#align-texts-wf.cwl/align_c", 
                            "id": "#align-texts-wf.cwl/merge-json-5/name"
                        }
                    ], 
                    "out": [
                        "#align-texts-wf.cwl/merge-json-5/merged"
                    ], 
                    "id": "#align-texts-wf.cwl/merge-json-5"
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
            "class": "CommandLineTool", 
            "baseCommand": [
                "mkdir"
            ], 
            "doc": "Create directory", 
            "inputs": [
                {
                    "type": "string", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#mkdir.cwl/dir_name"
                }
            ], 
            "outputs": [
                {
                    "type": "Directory", 
                    "outputBinding": {
                        "glob": "*"
                    }, 
                    "id": "#mkdir.cwl/out"
                }
            ], 
            "id": "#mkdir.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "python", 
                "-m", 
                "ochre.sac2gs_and_ocr"
            ], 
            "inputs": [
                {
                    "type": "Directory", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#sac2gs-and-ocr.cwl/in_dir"
                }
            ], 
            "stdout": "cwl.output.json", 
            "outputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#sac2gs-and-ocr.cwl/gs_de"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#sac2gs-and-ocr.cwl/gs_fr"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#sac2gs-and-ocr.cwl/ocr_de"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#sac2gs-and-ocr.cwl/ocr_fr"
                }
            ], 
            "id": "#sac2gs-and-ocr.cwl"
        }, 
        {
            "class": "ExpressionTool", 
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ], 
            "doc": "Save a directory to a subdirectory.\n\nPuts ``inner_dir`` into the ``outer_dir``.\n", 
            "inputs": [
                {
                    "type": "Directory", 
                    "id": "#save-dir-to-subdir.cwl/inner_dir"
                }, 
                {
                    "type": "Directory", 
                    "id": "#save-dir-to-subdir.cwl/outer_dir"
                }
            ], 
            "outputs": [
                {
                    "type": "Directory", 
                    "id": "#save-dir-to-subdir.cwl/out"
                }
            ], 
            "expression": "${\n  return {\"out\": {\n    \"class\": \"Directory\",\n    \"basename\": inputs.outer_dir.basename + \"/\" + inputs.inner_dir.basename,\n    \"listing\": inputs.inner_dir.listing\n  } };\n}\n", 
            "id": "#save-dir-to-subdir.cwl"
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
                "tar", 
                "-xzf"
            ], 
            "doc": "Extract zipped tar archives.", 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#tar.cwl/in_file"
                }
            ], 
            "outputs": [
                {
                    "type": "Directory", 
                    "outputBinding": {
                        "glob": "*"
                    }, 
                    "id": "#tar.cwl/out"
                }
            ], 
            "id": "#tar.cwl"
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
                    "id": "#main/data_file"
                }, 
                {
                    "default": "de", 
                    "type": "string", 
                    "id": "#main/de_dir_name"
                }, 
                {
                    "default": "fr", 
                    "type": "string", 
                    "id": "#main/fr_dir_name"
                }, 
                {
                    "default": "gs", 
                    "type": "string", 
                    "id": "#main/gs_dir_name"
                }, 
                {
                    "default": "ocr", 
                    "type": "string", 
                    "id": "#main/ocr_dir_name"
                }
            ], 
            "outputs": [
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-10/out", 
                    "id": "#main/align_de"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-11/out", 
                    "id": "#main/align_fr"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-7/out", 
                    "id": "#main/gs_de"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-9/out", 
                    "id": "#main/gs_fr"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-6/out", 
                    "id": "#main/ocr_de"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-8/out", 
                    "id": "#main/ocr_fr"
                }
            ], 
            "steps": [
                {
                    "run": "#align-texts-wf.cwl", 
                    "in": [
                        {
                            "source": "#main/sac2gs-and-ocr-1/gs_de", 
                            "id": "#main/align-texts-wf-4/gs"
                        }, 
                        {
                            "source": "#main/sac2gs-and-ocr-1/ocr_de", 
                            "id": "#main/align-texts-wf-4/ocr"
                        }
                    ], 
                    "out": [
                        "#main/align-texts-wf-4/alignments", 
                        "#main/align-texts-wf-4/changes", 
                        "#main/align-texts-wf-4/metadata"
                    ], 
                    "id": "#main/align-texts-wf-4"
                }, 
                {
                    "run": "#align-texts-wf.cwl", 
                    "in": [
                        {
                            "source": "#main/sac2gs-and-ocr-1/gs_fr", 
                            "id": "#main/align-texts-wf-5/gs"
                        }, 
                        {
                            "source": "#main/sac2gs-and-ocr-1/ocr_fr", 
                            "id": "#main/align-texts-wf-5/ocr"
                        }
                    ], 
                    "out": [
                        "#main/align-texts-wf-5/alignments", 
                        "#main/align-texts-wf-5/changes", 
                        "#main/align-texts-wf-5/metadata"
                    ], 
                    "id": "#main/align-texts-wf-5"
                }, 
                {
                    "run": "#mkdir.cwl", 
                    "in": [
                        {
                            "source": "#main/de_dir_name", 
                            "id": "#main/mkdir-2/dir_name"
                        }
                    ], 
                    "out": [
                        "#main/mkdir-2/out"
                    ], 
                    "id": "#main/mkdir-2"
                }, 
                {
                    "run": "#mkdir.cwl", 
                    "in": [
                        {
                            "source": "#main/fr_dir_name", 
                            "id": "#main/mkdir-3/dir_name"
                        }
                    ], 
                    "out": [
                        "#main/mkdir-3/out"
                    ], 
                    "id": "#main/mkdir-3"
                }, 
                {
                    "run": "#sac2gs-and-ocr.cwl", 
                    "in": [
                        {
                            "source": "#main/tar-1/out", 
                            "id": "#main/sac2gs-and-ocr-1/in_dir"
                        }
                    ], 
                    "out": [
                        "#main/sac2gs-and-ocr-1/gs_de", 
                        "#main/sac2gs-and-ocr-1/gs_fr", 
                        "#main/sac2gs-and-ocr-1/ocr_de", 
                        "#main/sac2gs-and-ocr-1/ocr_fr"
                    ], 
                    "id": "#main/sac2gs-and-ocr-1"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/save-files-to-dir-19/out", 
                            "id": "#main/save-dir-to-subdir-10/inner_dir"
                        }, 
                        {
                            "source": "#main/mkdir-2/out", 
                            "id": "#main/save-dir-to-subdir-10/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-10/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-10"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/save-files-to-dir-20/out", 
                            "id": "#main/save-dir-to-subdir-11/inner_dir"
                        }, 
                        {
                            "source": "#main/mkdir-3/out", 
                            "id": "#main/save-dir-to-subdir-11/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-11/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-11"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/save-files-to-dir-15/out", 
                            "id": "#main/save-dir-to-subdir-6/inner_dir"
                        }, 
                        {
                            "source": "#main/mkdir-2/out", 
                            "id": "#main/save-dir-to-subdir-6/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-6/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-6"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/save-files-to-dir-16/out", 
                            "id": "#main/save-dir-to-subdir-7/inner_dir"
                        }, 
                        {
                            "source": "#main/mkdir-2/out", 
                            "id": "#main/save-dir-to-subdir-7/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-7/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-7"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/save-files-to-dir-17/out", 
                            "id": "#main/save-dir-to-subdir-8/inner_dir"
                        }, 
                        {
                            "source": "#main/mkdir-3/out", 
                            "id": "#main/save-dir-to-subdir-8/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-8/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-8"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/save-files-to-dir-18/out", 
                            "id": "#main/save-dir-to-subdir-9/inner_dir"
                        }, 
                        {
                            "source": "#main/mkdir-3/out", 
                            "id": "#main/save-dir-to-subdir-9/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-9/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-9"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/ocr_dir_name", 
                            "id": "#main/save-files-to-dir-15/dir_name"
                        }, 
                        {
                            "source": "#main/sac2gs-and-ocr-1/ocr_de", 
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
                            "id": "#main/save-files-to-dir-16/dir_name"
                        }, 
                        {
                            "source": "#main/sac2gs-and-ocr-1/gs_de", 
                            "id": "#main/save-files-to-dir-16/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-16/out"
                    ], 
                    "id": "#main/save-files-to-dir-16"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/ocr_dir_name", 
                            "id": "#main/save-files-to-dir-17/dir_name"
                        }, 
                        {
                            "source": "#main/sac2gs-and-ocr-1/ocr_fr", 
                            "id": "#main/save-files-to-dir-17/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-17/out"
                    ], 
                    "id": "#main/save-files-to-dir-17"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/gs_dir_name", 
                            "id": "#main/save-files-to-dir-18/dir_name"
                        }, 
                        {
                            "source": "#main/sac2gs-and-ocr-1/gs_fr", 
                            "id": "#main/save-files-to-dir-18/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-18/out"
                    ], 
                    "id": "#main/save-files-to-dir-18"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/align_dir_name", 
                            "id": "#main/save-files-to-dir-19/dir_name"
                        }, 
                        {
                            "source": "#main/align-texts-wf-4/alignments", 
                            "id": "#main/save-files-to-dir-19/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-19/out"
                    ], 
                    "id": "#main/save-files-to-dir-19"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/align_dir_name", 
                            "id": "#main/save-files-to-dir-20/dir_name"
                        }, 
                        {
                            "source": "#main/align-texts-wf-5/alignments", 
                            "id": "#main/save-files-to-dir-20/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-20/out"
                    ], 
                    "id": "#main/save-files-to-dir-20"
                }, 
                {
                    "run": "#tar.cwl", 
                    "in": [
                        {
                            "source": "#main/data_file", 
                            "id": "#main/tar-1/in_file"
                        }
                    ], 
                    "out": [
                        "#main/tar-1/out"
                    ], 
                    "id": "#main/tar-1"
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