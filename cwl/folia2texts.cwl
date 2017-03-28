#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
outputs:
  texts:
    type:
      items:
        type: array
        items: File
      type: array
    outputSource: folia2ocr-and-gs/out_files
steps:
  ls:
    run: /Users/janneke/Documents/code/nlppln/cwl/ls.cwl
    in:
      in_dir: in_dir
    out:
    - out_files
  folia2ocr-and-gs:
    run: /Users/janneke/Documents/code/ocr/cwl/folia2ocr-and-gs.cwl
    in:
      in_file: ls/out_files
    out:
    - out_files
    scatter:
    - in_file
    scatterMethod: nested_crossproduct
