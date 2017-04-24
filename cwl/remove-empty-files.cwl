#!/usr/bin/env cwlrunner
cwlVersion: cwl:v1.0
class: CommandLineTool

baseCommand: ["python", "/Users/janneke/Documents/code/ocr/remove_empty_files.py"]

requirements:
  InitialWorkDirRequirement:
    listing: |
      ${
        return inputs.ocr_files.concat(inputs.gs_files);
      }
  InlineJavascriptRequirement: {}

arguments:
  - valueFrom: $(runtime.outdir)
    position: 1

inputs:
  ocr_files:
    type: File[]
  gs_files:
    type: File[]
  out_dir:
    type: Directory?
    inputBinding:
      prefix: --out_dir=
      separate: false

stdout: cwl.output.json

outputs:
  ocr:
    type: File[]
  gs:
    type: File[]
