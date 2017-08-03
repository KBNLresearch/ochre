#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ocrtools.folia2ocr_and_gs"]

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
  gs:
    type: File
    outputBinding:
      glob: "*.gs.txt"
  ocr:
    type: File
    outputBinding:
      glob: "*.ocr.txt"
