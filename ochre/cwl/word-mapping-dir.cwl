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
                "ochre.create_word_mappings"
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 2
                    }, 
                    "id": "#create-word-mappings.cwl/alignments"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "--lowercase"
                    }, 
                    "id": "#create-word-mappings.cwl/lowercase"
                }, 
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "inputBinding": {
                        "prefix": "--name"
                    }, 
                    "id": "#create-word-mappings.cwl/name"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#create-word-mappings.cwl/saf"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "*.csv"
                    }, 
                    "id": "#create-word-mappings.cwl/word_mapping"
                }
            ], 
            "id": "#create-word-mappings.cwl"
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
                "python", 
                "-m", 
                "nlppln.commands.normalize_whitespace_punctuation"
            ], 
            "doc": "Normalize whitespace and punctuation.\n\nReplace multiple subsequent occurrences of whitespace characters and\npunctuation with a single occurrence.\n", 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#normalize-whitespace-punctuation.cwl/meta_in"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "*.txt"
                    }, 
                    "id": "#normalize-whitespace-punctuation.cwl/metadata_out"
                }
            ], 
            "id": "#normalize-whitespace-punctuation.cwl"
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
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "id": "#word-mapping-wf.cwl/align_c"
                }, 
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "id": "#word-mapping-wf.cwl/align_m"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#word-mapping-wf.cwl/gs_files"
                }, 
                {
                    "type": "string", 
                    "id": "#word-mapping-wf.cwl/language"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "id": "#word-mapping-wf.cwl/lowercase"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#word-mapping-wf.cwl/ocr_files"
                }, 
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "id": "#word-mapping-wf.cwl/wm_name"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#word-mapping-wf.cwl/merge-csv-2/merged", 
                    "id": "#word-mapping-wf.cwl/wm_mapping"
                }
            ], 
            "steps": [
                {
                    "run": "#align-texts-wf.cwl", 
                    "in": [
                        {
                            "source": "#word-mapping-wf.cwl/align_c", 
                            "id": "#word-mapping-wf.cwl/align-texts-wf-2/align_c"
                        }, 
                        {
                            "source": "#word-mapping-wf.cwl/align_m", 
                            "id": "#word-mapping-wf.cwl/align-texts-wf-2/align_m"
                        }, 
                        {
                            "source": "#word-mapping-wf.cwl/normalize-whitespace-punctuation-2/metadata_out", 
                            "id": "#word-mapping-wf.cwl/align-texts-wf-2/gs"
                        }, 
                        {
                            "source": "#word-mapping-wf.cwl/normalize-whitespace-punctuation-3/metadata_out", 
                            "id": "#word-mapping-wf.cwl/align-texts-wf-2/ocr"
                        }
                    ], 
                    "out": [
                        "#word-mapping-wf.cwl/align-texts-wf-2/alignments", 
                        "#word-mapping-wf.cwl/align-texts-wf-2/changes", 
                        "#word-mapping-wf.cwl/align-texts-wf-2/metadata"
                    ], 
                    "id": "#word-mapping-wf.cwl/align-texts-wf-2"
                }, 
                {
                    "run": "#create-word-mappings.cwl", 
                    "in": [
                        {
                            "source": "#word-mapping-wf.cwl/align-texts-wf-2/alignments", 
                            "id": "#word-mapping-wf.cwl/create-word-mappings-1/alignments"
                        }, 
                        {
                            "source": "#word-mapping-wf.cwl/lowercase", 
                            "id": "#word-mapping-wf.cwl/create-word-mappings-1/lowercase"
                        }, 
                        {
                            "source": "#word-mapping-wf.cwl/pattern-1/out_files", 
                            "id": "#word-mapping-wf.cwl/create-word-mappings-1/saf"
                        }
                    ], 
                    "out": [
                        "#word-mapping-wf.cwl/create-word-mappings-1/word_mapping"
                    ], 
                    "scatter": [
                        "#word-mapping-wf.cwl/create-word-mappings-1/alignments", 
                        "#word-mapping-wf.cwl/create-word-mappings-1/saf"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#word-mapping-wf.cwl/create-word-mappings-1"
                }, 
                {
                    "run": "#merge-csv.cwl", 
                    "in": [
                        {
                            "source": "#word-mapping-wf.cwl/create-word-mappings-1/word_mapping", 
                            "id": "#word-mapping-wf.cwl/merge-csv-2/in_files"
                        }, 
                        {
                            "source": "#word-mapping-wf.cwl/wm_name", 
                            "id": "#word-mapping-wf.cwl/merge-csv-2/name"
                        }
                    ], 
                    "out": [
                        "#word-mapping-wf.cwl/merge-csv-2/merged"
                    ], 
                    "id": "#word-mapping-wf.cwl/merge-csv-2"
                }, 
                {
                    "run": "#normalize-whitespace-punctuation.cwl", 
                    "in": [
                        {
                            "source": "#word-mapping-wf.cwl/gs_files", 
                            "id": "#word-mapping-wf.cwl/normalize-whitespace-punctuation-2/meta_in"
                        }
                    ], 
                    "out": [
                        "#word-mapping-wf.cwl/normalize-whitespace-punctuation-2/metadata_out"
                    ], 
                    "scatter": [
                        "#word-mapping-wf.cwl/normalize-whitespace-punctuation-2/meta_in"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#word-mapping-wf.cwl/normalize-whitespace-punctuation-2"
                }, 
                {
                    "run": "#normalize-whitespace-punctuation.cwl", 
                    "in": [
                        {
                            "source": "#word-mapping-wf.cwl/ocr_files", 
                            "id": "#word-mapping-wf.cwl/normalize-whitespace-punctuation-3/meta_in"
                        }
                    ], 
                    "out": [
                        "#word-mapping-wf.cwl/normalize-whitespace-punctuation-3/metadata_out"
                    ], 
                    "scatter": [
                        "#word-mapping-wf.cwl/normalize-whitespace-punctuation-3/meta_in"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#word-mapping-wf.cwl/normalize-whitespace-punctuation-3"
                }, 
                {
                    "run": "#pattern.cwl", 
                    "in": [
                        {
                            "source": "#word-mapping-wf.cwl/normalize-whitespace-punctuation-2/metadata_out", 
                            "id": "#word-mapping-wf.cwl/pattern-1/in_file"
                        }, 
                        {
                            "source": "#word-mapping-wf.cwl/language", 
                            "id": "#word-mapping-wf.cwl/pattern-1/language"
                        }
                    ], 
                    "out": [
                        "#word-mapping-wf.cwl/pattern-1/out_files"
                    ], 
                    "scatter": [
                        "#word-mapping-wf.cwl/pattern-1/in_file"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#word-mapping-wf.cwl/pattern-1"
                }
            ], 
            "id": "#word-mapping-wf.cwl"
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
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "id": "#main/align_c"
                }, 
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "id": "#main/align_m"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/gs_dir"
                }, 
                {
                    "type": "string", 
                    "id": "#main/language"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "id": "#main/lowercase"
                }, 
                {
                    "type": "Directory", 
                    "id": "#main/ocr_dir"
                }, 
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "id": "#main/wm_name"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#main/word-mapping-wf-1/wm_mapping", 
                    "id": "#main/wm_mapping"
                }
            ], 
            "steps": [
                {
                    "run": "#ls.cwl", 
                    "in": [
                        {
                            "source": "#main/gs_dir", 
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
                            "source": "#main/ocr_dir", 
                            "id": "#main/ls-5/in_dir"
                        }
                    ], 
                    "out": [
                        "#main/ls-5/out_files"
                    ], 
                    "id": "#main/ls-5"
                }, 
                {
                    "run": "#word-mapping-wf.cwl", 
                    "in": [
                        {
                            "source": "#main/align_c", 
                            "id": "#main/word-mapping-wf-1/align_c"
                        }, 
                        {
                            "source": "#main/align_m", 
                            "id": "#main/word-mapping-wf-1/align_m"
                        }, 
                        {
                            "source": "#main/ls-2/out_files", 
                            "id": "#main/word-mapping-wf-1/gs_files"
                        }, 
                        {
                            "source": "#main/language", 
                            "id": "#main/word-mapping-wf-1/language"
                        }, 
                        {
                            "source": "#main/lowercase", 
                            "id": "#main/word-mapping-wf-1/lowercase"
                        }, 
                        {
                            "source": "#main/ls-5/out_files", 
                            "id": "#main/word-mapping-wf-1/ocr_files"
                        }, 
                        {
                            "source": "#main/wm_name", 
                            "id": "#main/word-mapping-wf-1/wm_name"
                        }
                    ], 
                    "out": [
                        "#main/word-mapping-wf-1/wm_mapping"
                    ], 
                    "id": "#main/word-mapping-wf-1"
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
        }, 
        {
            "class": "CommandLineTool", 
            "baseCommand": [
                "python", 
                "/pattern_parse.py"
            ], 
            "doc": "Parse text using `pattern <https://www.clips.uantwerpen.be/pattern>`_.\n\nDoes tokenization, lemmatization and part of speech tagging. The default language is English, but other languages can be specified (``--language [en|es|de|fr|it|nl]``).\n\nOutput is `saf <https://github.com/vanatteveldt/saf>`_.\n", 
            "requirements": [
                {
                    "class": "DockerRequirement", 
                    "dockerPull": "nlppln/pattern-docker"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#pattern.cwl/in_file"
                }, 
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "default": "en", 
                    "inputBinding": {
                        "prefix": "-l"
                    }, 
                    "id": "#pattern.cwl/language"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "*.json"
                    }, 
                    "id": "#pattern.cwl/out_files"
                }
            ], 
            "id": "#pattern.cwl"
        }
    ]
}