#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  dir_name:
    default: gs_lowercase
    type: string
outputs:
  out_dir:
    type: Directory
    outputSource: save-files-to-dir/out
steps:
  ls:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, nlppln.commands.ls]

      inputs:
      - type: Directory
        inputBinding:
          position: 2
        id: _:ls#in_dir
      - type:
        - 'null'
        - boolean
        inputBinding:
          prefix: --recursive

        id: _:ls#recursive
      stdout: cwl.output.json

      outputs:
      - type:
          type: array
          items: File
        id: _:ls#out_files
      id: _:ls
    in:
      in_dir: in_dir
    out:
    - out_files
  lowercase:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, nlppln.commands.lowercase]

      inputs:
      - type: File
        inputBinding:
          position: 1
        id: _:lowercase#in_file
      - type:
        - 'null'
        - Directory
        inputBinding:
          prefix: --out_dir=
          separate: false

        id: _:lowercase#out_dir
      stdout: $(inputs.in_file.nameroot).txt

      outputs:
      - type: File
        outputBinding:
          glob: $(inputs.in_file.nameroot).txt
        id: _:lowercase#out_files
      id: _:lowercase
    in:
      in_file: ls/out_files
    out:
    - out_files
    scatter:
    - in_file
    scatterMethod: dotproduct
  save-files-to-dir:
    run:
      cwlVersion: v1.0
      class: ExpressionTool

      requirements:
      - class: InlineJavascriptRequirement

      inputs:
      - type: string
        id: _:save-files-to-dir#dir_name
      - type:
          type: array
          items: File
        id: _:save-files-to-dir#in_files
      outputs:
      - type: Directory
        id: _:save-files-to-dir#out
      expression: |
        ${
          return {"out": {
            "class": "Directory",
            "basename": inputs.dir_name,
            "listing": inputs.in_files
          } };
        }
      id: _:save-files-to-dir
    in:
      dir_name: dir_name
      in_files: lowercase/out_files
    out:
    - out
