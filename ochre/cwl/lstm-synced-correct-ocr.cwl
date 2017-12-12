#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.lstm_synced_correct_ocr"]

inputs:
  model:
    type: File
    inputBinding:
      position: 1
  charset:
    type: File
    inputBinding:
      position: 2
  txt:
    type: File
    inputBinding:
      position: 3

outputs:
  corrected:
    type: File
    outputBinding:
      glob: "$(inputs.txt.basename)"
