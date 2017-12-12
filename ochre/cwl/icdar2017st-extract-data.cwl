#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  ocr_dir_name: string
  gs_dir_name: string
  aligned_dir_name: string
outputs:
  gs_dir:
    type: Directory
    outputSource: save-files-to-dir-6/out
  ocr_dir:
    type: Directory
    outputSource: save-files-to-dir-7/out
  aligned_dir:
    type: Directory
    outputSource: save-files-to-dir-8/out
steps:
  ls-3:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, nlppln.commands.ls]

      inputs:
      - type: Directory
        inputBinding:
          position: 2
        id: _:ls-3#in_dir
      - type:
        - 'null'
        - boolean
        inputBinding:
          prefix: --recursive

        id: _:ls-3#recursive
      stdout: cwl.output.json

      outputs:
      - type:
          type: array
          items: File
        id: _:ls-3#out_files
      id: _:ls-3
    in:
      in_dir: in_dir
    out:
    - out_files
  icdar2017st-extract-text:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.icdar2017st_extract_text]

      inputs:
      - type: File
        inputBinding:
          position: 1

        id: _:icdar2017st-extract-text#in_file
      outputs:
      - type: File
        outputBinding:
          glob: '*.json'
        id: _:icdar2017st-extract-text#aligned
      - type: File
        outputBinding:
          glob: gs/*.txt
        id: _:icdar2017st-extract-text#gs
      - type: File
        outputBinding:
          glob: ocr/*.txt
        id: _:icdar2017st-extract-text#ocr
      id: _:icdar2017st-extract-text
    in:
      in_file: ls-3/out_files
    out:
    - aligned
    - gs
    - ocr
    scatter:
    - in_file
    scatterMethod: dotproduct
  save-files-to-dir-6:
    run:
      cwlVersion: v1.0
      class: ExpressionTool

      requirements:
      - class: InlineJavascriptRequirement

      inputs:
      - type: string
        id: _:save-files-to-dir-6#dir_name
      - type:
          type: array
          items: File
        id: _:save-files-to-dir-6#in_files
      outputs:
      - type: Directory
        id: _:save-files-to-dir-6#out
      expression: |
        ${
          return {"out": {
            "class": "Directory",
            "basename": inputs.dir_name,
            "listing": inputs.in_files
          } };
        }
      id: _:save-files-to-dir-6
    in:
      dir_name: gs_dir_name
      in_files: icdar2017st-extract-text/gs
    out:
    - out
  save-files-to-dir-7:
    run:
      cwlVersion: v1.0
      class: ExpressionTool

      requirements:
      - class: InlineJavascriptRequirement

      inputs:
      - type: string
        id: _:save-files-to-dir-7#dir_name
      - type:
          type: array
          items: File
        id: _:save-files-to-dir-7#in_files
      outputs:
      - type: Directory
        id: _:save-files-to-dir-7#out
      expression: |
        ${
          return {"out": {
            "class": "Directory",
            "basename": inputs.dir_name,
            "listing": inputs.in_files
          } };
        }
      id: _:save-files-to-dir-7
    in:
      dir_name: ocr_dir_name
      in_files: icdar2017st-extract-text/ocr
    out:
    - out
  save-files-to-dir-8:
    run:
      cwlVersion: v1.0
      class: ExpressionTool

      requirements:
      - class: InlineJavascriptRequirement

      inputs:
      - type: string
        id: _:save-files-to-dir-8#dir_name
      - type:
          type: array
          items: File
        id: _:save-files-to-dir-8#in_files
      outputs:
      - type: Directory
        id: _:save-files-to-dir-8#out
      expression: |
        ${
          return {"out": {
            "class": "Directory",
            "basename": inputs.dir_name,
            "listing": inputs.in_files
          } };
        }
      id: _:save-files-to-dir-8
    in:
      dir_name: aligned_dir_name
      in_files: icdar2017st-extract-text/aligned
    out:
    - out
