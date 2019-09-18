#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

baseCommand: ["python", "-m", "ochre.concat_files"]

inputs:
  datadivision:
    type: File
    inputBinding:
      position: 1
  in_dir:
    type: Directory
    inputBinding:
      position: 2

outputs:
  data_files:
    type: File[]
    outputBinding:
      glob: "*"
