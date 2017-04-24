#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  ocr_n: string?
  gs_n: string?
  align_m: string?
  align_c: string?
outputs:
  gs:
    type:
      type: array
      items: File
    outputSource: remove-empty-files/gs
  ocr_char_counts:
    type: File
    outputSource: merge-json/merged
  gs_char_counts:
    type: File
    outputSource: merge-json-1/merged
  ocr:
    type:
      type: array
      items: File
    outputSource: remove-empty-files/ocr
  changes:
    type: File
    outputSource: merge-json-3/merged
  metadata:
    type: File
    outputSource: merge-json-2/merged
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
  remove-empty-files:
    run: /Users/janneke/Documents/code/ocr/cwl/remove-empty-files.cwl
    in:
      ocr_files: folia2ocr-and-gs/ocr
      gs_files: folia2ocr-and-gs/gs
    out:
    - gs
    - ocr
  count-chars:
    run: /Users/janneke/Documents/code/ocr/cwl/count-chars.cwl
    in:
      in_file: remove-empty-files/ocr
    out:
    - char_counts
    scatter:
    - in_file
    scatterMethod: dotproduct
  merge-json:
    run: /Users/janneke/Documents/code/ocr/cwl/merge-json.cwl
    in:
      in_files: count-chars/char_counts
      name: ocr_n
    out:
    - merged
  count-chars-1:
    run: /Users/janneke/Documents/code/ocr/cwl/count-chars.cwl
    in:
      in_file: remove-empty-files/gs
    out:
    - char_counts
    scatter:
    - in_file
    scatterMethod: dotproduct
  merge-json-1:
    run: /Users/janneke/Documents/code/ocr/cwl/merge-json.cwl
    in:
      in_files: count-chars-1/char_counts
      name: gs_n
    out:
    - merged
  align:
    run: /Users/janneke/Documents/code/ocr/cwl/align.cwl
    in:
      file2: remove-empty-files/gs
      file1: remove-empty-files/ocr
    out:
    - changes
    - metadata
    scatter:
    - file1
    - file2
    scatterMethod: dotproduct
  merge-json-2:
    run: /Users/janneke/Documents/code/ocr/cwl/merge-json.cwl
    in:
      in_files: align/metadata
      name: align_m
    out:
    - merged
  merge-json-3:
    run: /Users/janneke/Documents/code/ocr/cwl/merge-json.cwl
    in:
      in_files: align/changes
      name: align_c
    out:
    - merged
