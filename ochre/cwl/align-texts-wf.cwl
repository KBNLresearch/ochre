#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  gs: File[]
  ocr: File[]
  align_m:
    default: merged_metadata.csv
    type: string
  align_c:
    default: merged_changes.csv
    type: string
outputs:
  alignments:
    type:
      items: File
      type: array
    outputSource: char-align/out_file
  metadata:
    type: File
    outputSource: merge-json/merged
  changes:
    type: File
    outputSource: merge-json-1/merged
steps:
  align:
    run: https://raw.githubusercontent.com/nlppln/edlib-align/master/align.cwl
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
    run: merge-json.cwl
    in:
      in_files: align/metadata
      name: align_m
    out:
    - merged
  merge-json-1:
    run: merge-json.cwl
    in:
      in_files: align/changes
      name: align_c
    out:
    - merged
  char-align:
    run: char-align.cwl
    in:
      ocr_text: ocr
      metadata: align/metadata
      gs_text: gs
    out:
    - out_file
    scatter:
    - gs_text
    - ocr_text
    - metadata
    scatterMethod: dotproduct
