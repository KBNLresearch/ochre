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
                "ochre.kb_tss_concat_files"
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
                    "id": "#kb-tss-concat-files.cwl/in_files"
                }
            ], 
            "outputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "outputBinding": {
                        "glob": "*.txt"
                    }, 
                    "id": "#kb-tss-concat-files.cwl/out_files"
                }
            ], 
            "id": "#kb-tss-concat-files.cwl"
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
                    "default": [
                        "SP"
                    ], 
                    "type": {
                        "type": "array", 
                        "items": "string"
                    }, 
                    "id": "#kb-tss-preprocess-single-dir.cwl/element"
                }, 
                {
                    "default": "alto.xml", 
                    "type": "string", 
                    "id": "#kb-tss-preprocess-single-dir.cwl/endswith"
                }, 
                {
                    "type": "Directory", 
                    "id": "#kb-tss-preprocess-single-dir.cwl/in_dir"
                }, 
                {
                    "default": "alto", 
                    "type": "string", 
                    "id": "#kb-tss-preprocess-single-dir.cwl/in_fmt"
                }, 
                {
                    "default": "text", 
                    "type": "string", 
                    "id": "#kb-tss-preprocess-single-dir.cwl/out_fmt"
                }, 
                {
                    "default": true, 
                    "type": "boolean", 
                    "id": "#kb-tss-preprocess-single-dir.cwl/recursive"
                }
            ], 
            "outputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "outputSource": "#kb-tss-preprocess-single-dir.cwl/kb-tss-concat-files/out_files", 
                    "id": "#kb-tss-preprocess-single-dir.cwl/text_files"
                }
            ], 
            "steps": [
                {
                    "run": "#kb-tss-concat-files.cwl", 
                    "in": [
                        {
                            "source": "#kb-tss-preprocess-single-dir.cwl/ocr-transform-1/out_file", 
                            "id": "#kb-tss-preprocess-single-dir.cwl/kb-tss-concat-files/in_files"
                        }
                    ], 
                    "out": [
                        "#kb-tss-preprocess-single-dir.cwl/kb-tss-concat-files/out_files"
                    ], 
                    "id": "#kb-tss-preprocess-single-dir.cwl/kb-tss-concat-files"
                }, 
                {
                    "run": "#ls.cwl", 
                    "in": [
                        {
                            "source": "#kb-tss-preprocess-single-dir.cwl/endswith", 
                            "id": "#kb-tss-preprocess-single-dir.cwl/ls/endswith"
                        }, 
                        {
                            "source": "#kb-tss-preprocess-single-dir.cwl/in_dir", 
                            "id": "#kb-tss-preprocess-single-dir.cwl/ls/in_dir"
                        }, 
                        {
                            "source": "#kb-tss-preprocess-single-dir.cwl/recursive", 
                            "id": "#kb-tss-preprocess-single-dir.cwl/ls/recursive"
                        }
                    ], 
                    "out": [
                        "#kb-tss-preprocess-single-dir.cwl/ls/out_files"
                    ], 
                    "id": "#kb-tss-preprocess-single-dir.cwl/ls"
                }, 
                {
                    "run": "#ocr-transform.cwl", 
                    "in": [
                        {
                            "source": "#kb-tss-preprocess-single-dir.cwl/remove-xml-elements-1/out_file", 
                            "id": "#kb-tss-preprocess-single-dir.cwl/ocr-transform-1/in_file"
                        }, 
                        {
                            "source": "#kb-tss-preprocess-single-dir.cwl/in_fmt", 
                            "id": "#kb-tss-preprocess-single-dir.cwl/ocr-transform-1/in_fmt"
                        }, 
                        {
                            "source": "#kb-tss-preprocess-single-dir.cwl/out_fmt", 
                            "id": "#kb-tss-preprocess-single-dir.cwl/ocr-transform-1/out_fmt"
                        }
                    ], 
                    "out": [
                        "#kb-tss-preprocess-single-dir.cwl/ocr-transform-1/out_file"
                    ], 
                    "scatter": [
                        "#kb-tss-preprocess-single-dir.cwl/ocr-transform-1/in_file"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#kb-tss-preprocess-single-dir.cwl/ocr-transform-1"
                }, 
                {
                    "run": "#remove-xml-elements.cwl", 
                    "in": [
                        {
                            "source": "#kb-tss-preprocess-single-dir.cwl/element", 
                            "id": "#kb-tss-preprocess-single-dir.cwl/remove-xml-elements-1/element"
                        }, 
                        {
                            "source": "#kb-tss-preprocess-single-dir.cwl/ls/out_files", 
                            "id": "#kb-tss-preprocess-single-dir.cwl/remove-xml-elements-1/xml_file"
                        }
                    ], 
                    "out": [
                        "#kb-tss-preprocess-single-dir.cwl/remove-xml-elements-1/out_file"
                    ], 
                    "scatter": [
                        "#kb-tss-preprocess-single-dir.cwl/remove-xml-elements-1/xml_file"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#kb-tss-preprocess-single-dir.cwl/remove-xml-elements-1"
                }
            ], 
            "id": "#kb-tss-preprocess-single-dir.cwl"
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
            "baseCommand": "ocr-transform", 
            "requirements": [
                {
                    "class": "DockerRequirement", 
                    "dockerPull": "ubma/ocr-fileformat"
                }, 
                {
                    "class": "InlineJavascriptRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 3
                    }, 
                    "id": "#ocr-transform.cwl/in_file"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#ocr-transform.cwl/in_fmt"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "position": 2
                    }, 
                    "id": "#ocr-transform.cwl/out_fmt"
                }
            ], 
            "stdout": "${\n  var nameroot = inputs.in_file.nameroot;\n  var ext = 'xml';\n  if(inputs.out_fmt == 'text'){\n    ext = 'txt';\n  }\n  return nameroot + '.' + ext;\n}\n", 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "$(inputs.in_file.nameroot).*"
                    }, 
                    "id": "#ocr-transform.cwl/out_file"
                }
            ], 
            "id": "#ocr-transform.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "python", 
                "-m", 
                "nlppln.commands.remove_xml_elements"
            ], 
            "doc": "Remove specified XML elements from XML file.\n", 
            "inputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "string", 
                        "inputBinding": {
                            "prefix": "-e"
                        }
                    }, 
                    "id": "#remove-xml-elements.cwl/element"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#remove-xml-elements.cwl/xml_file"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "*.xml"
                    }, 
                    "id": "#remove-xml-elements.cwl/out_file"
                }
            ], 
            "id": "#remove-xml-elements.cwl"
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
                    "default": "align-Karmac-Origineel", 
                    "type": "string", 
                    "id": "#main/karmac_aligned_name"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/karmac_dir"
                }, 
                {
                    "default": "Karmac", 
                    "type": "string", 
                    "id": "#main/karmac_name"
                }, 
                {
                    "default": "Origineel", 
                    "type": "string", 
                    "id": "#main/original_name"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/orignal_dir"
                }, 
                {
                    "default": "align-X-Cago-Origineel", 
                    "type": "string", 
                    "id": "#main/xcago_aligned_name"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/xcago_dir"
                }, 
                {
                    "default": "X-Cago", 
                    "type": "string", 
                    "id": "#main/xcago_name"
                }
            ], 
            "outputs": [
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-files-to-dir-9/out", 
                    "id": "#main/karmac"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-files-to-dir-12/out", 
                    "id": "#main/karmac_align"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-files-to-dir-10/out", 
                    "id": "#main/original"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-files-to-dir-11/out", 
                    "id": "#main/xcago"
                }, 
                {
                    "type": "Directory", 
                    "outputSource": "#main/save-files-to-dir-13/out", 
                    "id": "#main/xcago_align"
                }
            ], 
            "steps": [
                {
                    "run": "#align-texts-wf.cwl", 
                    "in": [
                        {
                            "source": "#main/kb-tss-preprocess-single-dir/text_files", 
                            "id": "#main/align-texts-wf-1/gs"
                        }, 
                        {
                            "source": "#main/kb-tss-preprocess-single-dir-1/text_files", 
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
                    "run": "#align-texts-wf.cwl", 
                    "in": [
                        {
                            "source": "#main/kb-tss-preprocess-single-dir-2/text_files", 
                            "id": "#main/align-texts-wf-3/gs"
                        }, 
                        {
                            "source": "#main/kb-tss-preprocess-single-dir-1/text_files", 
                            "id": "#main/align-texts-wf-3/ocr"
                        }
                    ], 
                    "out": [
                        "#main/align-texts-wf-3/alignments", 
                        "#main/align-texts-wf-3/changes", 
                        "#main/align-texts-wf-3/metadata"
                    ], 
                    "id": "#main/align-texts-wf-3"
                }, 
                {
                    "run": "#kb-tss-preprocess-single-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/karmac_dir", 
                            "id": "#main/kb-tss-preprocess-single-dir/in_dir"
                        }
                    ], 
                    "out": [
                        "#main/kb-tss-preprocess-single-dir/text_files"
                    ], 
                    "id": "#main/kb-tss-preprocess-single-dir"
                }, 
                {
                    "run": "#kb-tss-preprocess-single-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/orignal_dir", 
                            "id": "#main/kb-tss-preprocess-single-dir-1/in_dir"
                        }
                    ], 
                    "out": [
                        "#main/kb-tss-preprocess-single-dir-1/text_files"
                    ], 
                    "id": "#main/kb-tss-preprocess-single-dir-1"
                }, 
                {
                    "run": "#kb-tss-preprocess-single-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/xcago_dir", 
                            "id": "#main/kb-tss-preprocess-single-dir-2/in_dir"
                        }
                    ], 
                    "out": [
                        "#main/kb-tss-preprocess-single-dir-2/text_files"
                    ], 
                    "id": "#main/kb-tss-preprocess-single-dir-2"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/original_name", 
                            "id": "#main/save-files-to-dir-10/dir_name"
                        }, 
                        {
                            "source": "#main/kb-tss-preprocess-single-dir-1/text_files", 
                            "id": "#main/save-files-to-dir-10/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-10/out"
                    ], 
                    "id": "#main/save-files-to-dir-10"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/xcago_name", 
                            "id": "#main/save-files-to-dir-11/dir_name"
                        }, 
                        {
                            "source": "#main/kb-tss-preprocess-single-dir-2/text_files", 
                            "id": "#main/save-files-to-dir-11/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-11/out"
                    ], 
                    "id": "#main/save-files-to-dir-11"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/karmac_aligned_name", 
                            "id": "#main/save-files-to-dir-12/dir_name"
                        }, 
                        {
                            "source": "#main/align-texts-wf-1/alignments", 
                            "id": "#main/save-files-to-dir-12/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-12/out"
                    ], 
                    "id": "#main/save-files-to-dir-12"
                }, 
                {
                    "run": "#save-files-to-dir.cwl", 
                    "in": [
                        {
                            "source": "#main/xcago_aligned_name", 
                            "id": "#main/save-files-to-dir-13/dir_name"
                        }, 
                        {
                            "source": "#main/align-texts-wf-3/alignments", 
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
                            "source": "#main/karmac_name", 
                            "id": "#main/save-files-to-dir-9/dir_name"
                        }, 
                        {
                            "source": "#main/kb-tss-preprocess-single-dir/text_files", 
                            "id": "#main/save-files-to-dir-9/in_files"
                        }
                    ], 
                    "out": [
                        "#main/save-files-to-dir-9/out"
                    ], 
                    "id": "#main/save-files-to-dir-9"
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