#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
outputs:
  out_files:
    outputSource: delete-empty-files/out_files
    type:
      type: array
      items: File
steps:
  ls:
    run: ls.cwl
    in:
      in_dir: in_dir
    out:
    - out_files
  tei2txt:
    run: tei2txt.cwl
    in:
      tei_file: ls/out_files
    out:
    - txt_file
    scatter:
    - tei_file
  delete-empty-files:
    run: delete-empty-files.cwl
    in:
      in_files: tei2txt/txt_file
    out:
    - out_files
