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
    outputSource: char-align-1/out_file
    type:
      type: array
      items: File
  metadata:
    outputSource: merge-json-2/merged
    type: File
  changes:
    outputSource: merge-json-3/merged
    type: File
steps:
  align-1:
    run: https://raw.githubusercontent.com/nlppln/edlib-align/master/align.cwl
    in:
      file1: ocr
      file2: gs
    out:
    - changes
    - metadata
    scatter:
    - file1
    - file2
    scatterMethod: dotproduct
  merge-json-2:
    run: merge-json.cwl
    in:
      in_files: align-1/metadata
      name: align_m
    out:
    - merged
  merge-json-3:
    run: merge-json.cwl
    in:
      in_files: align-1/changes
      name: align_c
    out:
    - merged
  char-align-1:
    run: char-align.cwl
    in:
      gs_text: gs
      metadata: align-1/metadata
      ocr_text: ocr
    out:
    - out_file
    scatter:
    - gs_text
    - ocr_text
    - metadata
    scatterMethod: dotproduct
