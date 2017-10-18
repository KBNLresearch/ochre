#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  gs: File[]
  ocr: File[]
  align_m: string?
  align_c: string?
outputs:
  alignments:
    type:
      items: File
      type: array
    outputSource: char-align/out_file
  changes:
    type: File
    outputSource: merge-json-1/merged
  metadata:
    type: File
    outputSource: merge-json/merged
steps:
  align:
    run: /home/jvdzwaan/code/edlib-align/align.cwl
    in:
      file2: gs
      file1: ocr
    out:
    - changes
    - metadata
    scatter:
    - file1
    - file2
    scatterMethod: dotproduct
  merge-json:
    run: /home/jvdzwaan/code/ocr/cwl/merge-json.cwl
    in:
      in_files: align/metadata
      name: align_m
    out:
    - merged
  merge-json-1:
    run: /home/jvdzwaan/code/ocr/cwl/merge-json.cwl
    in:
      in_files: align/changes
      name: align_c
    out:
    - merged
  char-align:
    run: /home/jvdzwaan/code/ocr/cwl/char-align.cwl
    in:
      ocr_text: ocr
      metadata: align/metadata
      gs_text: gs
    out:
    - out_file
    scatter:
    - ocr_text
    - gs_text
    - metadata
    scatterMethod: dotproduct
