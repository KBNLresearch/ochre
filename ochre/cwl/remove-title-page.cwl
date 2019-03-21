#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.remove_title_page"]

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

inputs:
  without_tp:
    type: File
    inputBinding:
      position: 1
  with_tp:
    type: File
    inputBinding:
      position: 2
  num_lines:
    type: int?
    inputBinding:
      prefix: -n

outputs:
  out_file:
    type: File
    outputBinding:
      glob: "*"
