#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ocr-transform

requirements:
  - class: DockerRequirement
    dockerPull: ubma/ocr-fileformat

inputs:
  in_fmt:
    type: string
    inputBinding:
      position: 1
  out_fmt:
    type: string
    inputBinding:
      position: 2
  in_file:
    type: File
    inputBinding:
      position: 3

stdout: $(inputs.in_file.nameroot)

outputs:
  out_file:
    type: File
    outputBinding:
      glob: $(inputs.in_file.nameroot)
