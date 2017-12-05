#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

baseCommand: ["python", "-m", "ochre.remove_empty_files"]

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

stdout: cwl.output.json

outputs:
  ocr:
    type: File[]
  gs:
    type: File[]
