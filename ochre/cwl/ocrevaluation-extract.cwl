#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.ocrevaluation_extract"]

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

inputs:
  in_file:
    type: File
    inputBinding:
      position: 1

outputs:
  character_data:
    type: File
    outputBinding:
      glob: "*-character.csv"
  global_data:
    type: File
    outputBinding:
      glob: "*-global.csv"
