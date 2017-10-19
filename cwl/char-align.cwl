#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.char_align"]

inputs:
  ocr_text:
    type: File
    inputBinding:
      position: 1
  gs_text:
    type: File
    inputBinding:
      position: 2
  metadata:
    type: File
    inputBinding:
      position: 3
  out_dir:
    type: Directory?
    inputBinding:
      prefix: --out_dir=
      separate: false

outputs:
  out_file:
    type: File
    outputBinding:
      glob: "*.json"
