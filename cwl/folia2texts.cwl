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
    outputSource: merge-json/merged
  ocr:
    type:
      type: array
      items: File
    outputSource: remove-empty-files/ocr
  changes:
    type: File
    outputSource: merge-json/merged
  metadata:
    type: File
    outputSource: merge-json/merged
steps:
  select-folia-files:
    run: /home/jvdzwaan/code/ocr/cwl/select-folia-files.cwl
    in:
      in_dir: in_dir
    out:
    - out_files
  folia2ocr-and-gs:
    run: /home/jvdzwaan/code/ocr/cwl/folia2ocr-and-gs.cwl
    in:
      in_file: select-folia-files/out_files
    out:
    - gs
    scatter:
    - in_file
    scatterMethod: flat_crossproduct
  remove-empty-files:
    run: /home/jvdzwaan/code/ocr/cwl/remove-empty-files.cwl
    in:
      ocr_files: folia2ocr-and-gs/ocr
      gs_files: folia2ocr-and-gs/gs
    out:
    - gs
  count-chars:
    run: /home/jvdzwaan/code/ocr/cwl/count-chars.cwl
    in:
      in_file: remove-empty-files/gs
    out:
    - char_counts
    scatter:
    - in_file
    scatterMethod: dotproduct
  merge-json:
    run: /home/jvdzwaan/code/ocr/cwl/merge-json.cwl
    in:
      in_files: align/changes
      name: align_c
    out:
    - merged
  align:
    run: /home/jvdzwaan/code/ocr/cwl/align.cwl
    in:
      file2: remove-empty-files/gs
      file1: remove-empty-files/ocr
    out:
    - changes
    scatter:
    - file1
    - file2
    scatterMethod: dotproduct
