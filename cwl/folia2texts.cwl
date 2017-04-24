#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
outputs:
  ocr:
    type:
      items: File
      type: array
    outputSource: folia2ocr-and-gs/ocr
  gs:
    type:
      items: File
      type: array
    outputSource: folia2ocr-and-gs/gs
  merged:
    type: File
    outputSource: merge-json/merged
steps:
  select-folia-files:
    run: /Users/janneke/Documents/code/ocr/cwl/select-folia-files.cwl
    in:
      in_dir: in_dir
    out:
    - out_files
  folia2ocr-and-gs:
    run: /Users/janneke/Documents/code/ocr/cwl/folia2ocr-and-gs.cwl
    in:
      in_file: select-folia-files/out_files
    out:
    - gs
    - ocr
    scatter:
    - in_file
    scatterMethod: flat_crossproduct
  count-chars:
    run: /Users/janneke/Documents/code/ocr/cwl/count-chars.cwl
    in:
      in_file: folia2ocr-and-gs/ocr
    out:
    - char_counts
    scatter:
    - in_file
    scatterMethod: flat_crossproduct
  merge-json:
    run: /Users/janneke/Documents/code/ocr/cwl/merge-json.cwl
    in:
      in_files: count-chars/char_counts
    out:
    - merged
