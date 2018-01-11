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
                    "type": "string", 
                    "id": "#icdar2017st-extract-data.cwl/aligned_dir_name"
                }, 
                {
                    "type": "string", 
                    "id": "#icdar2017st-extract-data.cwl/gs_dir_name"
                }, 
                {
                    "type": "Directory", 
                    "id": "#icdar2017st-extract-data.cwl/in_dir"
                }, 
                {
                    "type": "string", 
                    "id": "#icdar2017st-extract-data.cwl/ocr_dir_name"
                }
            ], 
            "outputs": [
                {
                    "type": "Directory", 
                    "outputSource": "#icdar2017st-extract-data.cwl/save-files-to-dir-8/out", 
                    "id": "#icdar2017st-extract-data.cwl/aligned_dir"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#icdar2017st-extract-data.cwl/save-files-to-dir-6/out", 
                    "id": "#icdar2017st-extract-data.cwl/gs_dir"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#icdar2017st-extract-data.cwl/save-files-to-dir-7/out", 
                    "id": "#icdar2017st-extract-data.cwl/ocr_dir"
                }
            ], 
            "steps": [
                {
                    "run": "#icdar2017st-extract-text.cwl", 
                    "in": [
                        {
                            "source": "#icdar2017st-extract-data.cwl/ls-3/out_files", 
                            "id": "#icdar2017st-extract-data.cwl/icdar2017st-extract-text/in_file"
                        }
                    ], 
                    "out": [
                        "#icdar2017st-extract-data.cwl/icdar2017st-extract-text/aligned", 
                        "#icdar2017st-extract-data.cwl/icdar2017st-extract-text/gs", 
                        "#icdar2017st-extract-data.cwl/icdar2017st-extract-text/ocr"
                    ], 
                    "scatter": [
                        "#icdar2017st-extract-data.cwl/icdar2017st-extract-text/in_file"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#icdar2017st-extract-data.cwl/icdar2017st-extract-text"
                }, 
                {
                    "run": "#ls.cwl", 
                    "in": [
                        {
                            "source": "#icdar2017st-extract-data.cwl/in_dir", 
                            "id": "#icdar2017st-extract-data.cwl/ls-3/in_dir"
                        }
                    ], 
                    "out": [
                        "#icdar2017st-extract-data.cwl/ls-3/out_files"
                    ], 
                    "id": "#icdar2017st-extract-data.cwl/ls-3"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#icdar2017st-extract-data.cwl/gs_dir_name", 
                            "id": "#icdar2017st-extract-data.cwl/save-files-to-dir-6/dir_name"
                        }, 
                        {
                            "source": "#icdar2017st-extract-data.cwl/icdar2017st-extract-text/gs", 
                            "id": "#icdar2017st-extract-data.cwl/save-files-to-dir-6/in_files"
                        }
                    ], 
                    "out": [
                        "#icdar2017st-extract-data.cwl/save-files-to-dir-6/out"
                    ], 
                    "id": "#icdar2017st-extract-data.cwl/save-files-to-dir-6"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#icdar2017st-extract-data.cwl/ocr_dir_name", 
                            "id": "#icdar2017st-extract-data.cwl/save-files-to-dir-7/dir_name"
                        }, 
                        {
                            "source": "#icdar2017st-extract-data.cwl/icdar2017st-extract-text/ocr", 
                            "id": "#icdar2017st-extract-data.cwl/save-files-to-dir-7/in_files"
                        }
                    ], 
                    "out": [
                        "#icdar2017st-extract-data.cwl/save-files-to-dir-7/out"
                    ], 
                    "id": "#icdar2017st-extract-data.cwl/save-files-to-dir-7"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#icdar2017st-extract-data.cwl/aligned_dir_name", 
                            "id": "#icdar2017st-extract-data.cwl/save-files-to-dir-8/dir_name"
                        }, 
                        {
                            "source": "#icdar2017st-extract-data.cwl/icdar2017st-extract-text/aligned", 
                            "id": "#icdar2017st-extract-data.cwl/save-files-to-dir-8/in_files"
                        }
                    ], 
                    "out": [
                        "#icdar2017st-extract-data.cwl/save-files-to-dir-8/out"
                    ], 
                    "id": "#icdar2017st-extract-data.cwl/save-files-to-dir-8"
                }
            ], 
            "id": "#icdar2017st-extract-data.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "python", 
                "-m", 
                "ochre.icdar2017st_extract_text"
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#icdar2017st-extract-text.cwl/in_file"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "*.json"
                    }, 
                    "id": "#icdar2017st-extract-text.cwl/aligned"
                }, 
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "gs/*.txt"
                    }, 
                    "id": "#icdar2017st-extract-text.cwl/gs"
                }, 
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "ocr/*.txt"
                    }, 
                    "id": "#icdar2017st-extract-text.cwl/ocr"
                }
            ], 
            "id": "#icdar2017st-extract-text.cwl"
        }, 
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
            "class": "Workflow", 
            "requirements": [
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ], 
            "inputs": [
                {
                    "default": "aligned", 
                    "type": "string", 
                    "id": "#main/aligned_dir_name"
                }, 
                {
                    "default": "gs", 
                    "type": "string", 
                    "id": "#main/gs_dir_name"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/in_dir1"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/in_dir2"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/in_dir3"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/in_dir4"
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
                    "outputSource": "#main/save-dir-to-subdir-11/out", 
                    "id": "#main/aligned1"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-8/out", 
                    "id": "#main/aligned2"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-5/out", 
                    "id": "#main/aligned3"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-2/out", 
                    "id": "#main/aligned4"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir/out", 
                    "id": "#main/gs1"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-3/out", 
                    "id": "#main/gs2"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-6/out", 
                    "id": "#main/gs3"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-9/out", 
                    "id": "#main/gs4"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-1/out", 
                    "id": "#main/ocr1"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-4/out", 
                    "id": "#main/ocr2"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-7/out", 
                    "id": "#main/ocr3"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-dir-to-subdir-10/out", 
                    "id": "#main/ocr4"
                }
            ], 
            "steps": [
                {
                    "run": "#icdar2017st-extract-data.cwl", 
                    "in": [
                        {
                            "source": "#main/aligned_dir_name", 
                            "id": "#main/icdar2017st-extract-data/aligned_dir_name"
                        }, 
                        {
                            "source": "#main/gs_dir_name", 
                            "id": "#main/icdar2017st-extract-data/gs_dir_name"
                        }, 
                        {
                            "source": "#main/in_dir1", 
                            "id": "#main/icdar2017st-extract-data/in_dir"
                        }, 
                        {
                            "source": "#main/ocr_dir_name", 
                            "id": "#main/icdar2017st-extract-data/ocr_dir_name"
                        }
                    ], 
                    "out": [
                        "#main/icdar2017st-extract-data/aligned_dir", 
                        "#main/icdar2017st-extract-data/gs_dir", 
                        "#main/icdar2017st-extract-data/ocr_dir"
                    ], 
                    "id": "#main/icdar2017st-extract-data"
                }, 
                {
                    "run": "#icdar2017st-extract-data.cwl", 
                    "in": [
                        {
                            "source": "#main/aligned_dir_name", 
                            "id": "#main/icdar2017st-extract-data-1/aligned_dir_name"
                        }, 
                        {
                            "source": "#main/gs_dir_name", 
                            "id": "#main/icdar2017st-extract-data-1/gs_dir_name"
                        }, 
                        {
                            "source": "#main/in_dir2", 
                            "id": "#main/icdar2017st-extract-data-1/in_dir"
                        }, 
                        {
                            "source": "#main/ocr_dir_name", 
                            "id": "#main/icdar2017st-extract-data-1/ocr_dir_name"
                        }
                    ], 
                    "out": [
                        "#main/icdar2017st-extract-data-1/aligned_dir", 
                        "#main/icdar2017st-extract-data-1/gs_dir", 
                        "#main/icdar2017st-extract-data-1/ocr_dir"
                    ], 
                    "id": "#main/icdar2017st-extract-data-1"
                }, 
                {
                    "run": "#icdar2017st-extract-data.cwl", 
                    "in": [
                        {
                            "source": "#main/aligned_dir_name", 
                            "id": "#main/icdar2017st-extract-data-2/aligned_dir_name"
                        }, 
                        {
                            "source": "#main/gs_dir_name", 
                            "id": "#main/icdar2017st-extract-data-2/gs_dir_name"
                        }, 
                        {
                            "source": "#main/in_dir3", 
                            "id": "#main/icdar2017st-extract-data-2/in_dir"
                        }, 
                        {
                            "source": "#main/ocr_dir_name", 
                            "id": "#main/icdar2017st-extract-data-2/ocr_dir_name"
                        }
                    ], 
                    "out": [
                        "#main/icdar2017st-extract-data-2/aligned_dir", 
                        "#main/icdar2017st-extract-data-2/gs_dir", 
                        "#main/icdar2017st-extract-data-2/ocr_dir"
                    ], 
                    "id": "#main/icdar2017st-extract-data-2"
                }, 
                {
                    "run": "#icdar2017st-extract-data.cwl", 
                    "in": [
                        {
                            "source": "#main/aligned_dir_name", 
                            "id": "#main/icdar2017st-extract-data-3/aligned_dir_name"
                        }, 
                        {
                            "source": "#main/gs_dir_name", 
                            "id": "#main/icdar2017st-extract-data-3/gs_dir_name"
                        }, 
                        {
                            "source": "#main/in_dir4", 
                            "id": "#main/icdar2017st-extract-data-3/in_dir"
                        }, 
                        {
                            "source": "#main/ocr_dir_name", 
                            "id": "#main/icdar2017st-extract-data-3/ocr_dir_name"
                        }
                    ], 
                    "out": [
                        "#main/icdar2017st-extract-data-3/aligned_dir", 
                        "#main/icdar2017st-extract-data-3/gs_dir", 
                        "#main/icdar2017st-extract-data-3/ocr_dir"
                    ], 
                    "id": "#main/icdar2017st-extract-data-3"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/icdar2017st-extract-data/gs_dir", 
                            "id": "#main/save-dir-to-subdir/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir1", 
                            "id": "#main/save-dir-to-subdir/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir/out"
                    ], 
                    "id": "#main/save-dir-to-subdir"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/icdar2017st-extract-data/ocr_dir", 
                            "id": "#main/save-dir-to-subdir-1/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir1", 
                            "id": "#main/save-dir-to-subdir-1/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-1/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-1"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/icdar2017st-extract-data-3/ocr_dir", 
                            "id": "#main/save-dir-to-subdir-10/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir4", 
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
                            "source": "#main/icdar2017st-extract-data-3/aligned_dir", 
                            "id": "#main/save-dir-to-subdir-11/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir4", 
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
                            "source": "#main/icdar2017st-extract-data/aligned_dir", 
                            "id": "#main/save-dir-to-subdir-2/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir1", 
                            "id": "#main/save-dir-to-subdir-2/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-2/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-2"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/icdar2017st-extract-data-1/gs_dir", 
                            "id": "#main/save-dir-to-subdir-3/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir2", 
                            "id": "#main/save-dir-to-subdir-3/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-3/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-3"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/icdar2017st-extract-data-1/ocr_dir", 
                            "id": "#main/save-dir-to-subdir-4/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir2", 
                            "id": "#main/save-dir-to-subdir-4/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-4/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-4"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/icdar2017st-extract-data-1/aligned_dir", 
                            "id": "#main/save-dir-to-subdir-5/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir2", 
                            "id": "#main/save-dir-to-subdir-5/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-5/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-5"
                }, 
                {
                    "run": "#save-dir-to-subdir.cwl", 
                    "in": [
                        {
                            "source": "#main/icdar2017st-extract-data-2/gs_dir", 
                            "id": "#main/save-dir-to-subdir-6/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir3", 
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
                            "source": "#main/icdar2017st-extract-data-2/ocr_dir", 
                            "id": "#main/save-dir-to-subdir-7/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir3", 
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
                            "source": "#main/icdar2017st-extract-data-2/aligned_dir", 
                            "id": "#main/save-dir-to-subdir-8/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir3", 
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
                            "source": "#main/icdar2017st-extract-data-3/gs_dir", 
                            "id": "#main/save-dir-to-subdir-9/inner_dir"
                        }, 
                        {
                            "source": "#main/in_dir4", 
                            "id": "#main/save-dir-to-subdir-9/outer_dir"
                        }
                    ], 
                    "out": [
                        "#main/save-dir-to-subdir-9/out"
                    ], 
                    "id": "#main/save-dir-to-subdir-9"
                }
            ], 
            "id": "#main"
        }
    ]
}