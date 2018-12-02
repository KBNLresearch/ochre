#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

baseCommand: ["python", "-m", "ochre.count_chars"]

inputs:
  in_file:
    type: File
    inputBinding:
      position: 1

outputs:
  char_counts:
    type: File
    outputBinding:
      glob: "*.json"
