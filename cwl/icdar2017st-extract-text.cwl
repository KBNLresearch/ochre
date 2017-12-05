#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.icdar2017st_extract_text"]

inputs:
  in_file:
    type: File
    inputBinding:
      position: 1

outputs:
  gs:
    type: File
    outputBinding:
      glob: "gs/*.txt"
  ocr:
    type: File
    outputBinding:
      glob: "ocr/*.txt"
  aligned:
    type: File
    outputBinding:
      glob: "*.json"
