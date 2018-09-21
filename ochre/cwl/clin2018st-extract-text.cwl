#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

baseCommand: ["python", "-m", "ochre.clin2018st_extract_text"]

inputs:
  json_file:
    type: File
    inputBinding:
      position: 1

outputs:
  gs_text:
    type: File
    outputBinding:
      glob: "*-gs.txt"
  err_text:
    type: File
    outputBinding:
      glob: "*-errors.txt"
