#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.select_test_files"]

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

stdout: cwl.output.json

inputs:
  in_dir:
    type: Directory
    inputBinding:
      position: 1
  datadivision:
    type: File
    inputBinding:
      position: 2
  name:
    type: string?
    inputBinding:
      prefix: --name

outputs:
  out_files:
    type: File[]
