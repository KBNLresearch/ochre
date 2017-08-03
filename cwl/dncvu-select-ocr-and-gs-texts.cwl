#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

baseCommand: ['python', '-m', 'ocrtools.dncvu_select_ocr_and_gs_texts']

inputs:
  in_dir:
    type: Directory
    inputBinding:
      position: 1

stdout: cwl.output.json

outputs:
  gs_files:
    type: File[]
  ocr_files:
    type: File[]
