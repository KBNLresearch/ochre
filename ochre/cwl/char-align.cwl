#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.char_align"]

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

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

outputs:
  out_file:
    type: File
    outputBinding:
      glob: "*.json"
