#!/usr/bin/env cwlrunner
cwlVersion: cwl:v1.0
class: CommandLineTool
baseCommand: ["python", "/Users/janneke/Documents/code/ocr/folia2ocr_and_gs.py"]

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
  out_files:
    type: File[]
    outputBinding:
      glob: "*.txt"
