#!/usr/bin/env cwlrunner
cwlVersion: cwl:v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ocrtools.ocrevaluation_extract"]

inputs:
  in_file:
    type: File
    inputBinding:
      position: 1
  out_dir:
    type: Directory?
    inputBinding:
      prefix: --out_dir=
      separate: false

outputs:
  character_data:
    type: File
    outputBinding:
      glob: "*-character.csv"
  global_data:
    type: File
    outputBinding:
      glob: "*-global.csv"
