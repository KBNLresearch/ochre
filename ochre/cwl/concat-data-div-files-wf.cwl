#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
inputs:
  datadivision: File
  gs: Directory
  ocr: Directory
  gs_dir_name:
    default: gs_concat
    type: string
  ocr_dir_name:
    default: ocr_concat
    type: string
outputs:
  gs_dir:
    type: Directory
    outputSource: save-files-to-dir/out
  ocr_dir:
    type: Directory
    outputSource: save-files-to-dir-1/out
steps:
  concat-files:
    run: concat-files.cwl
    in:
      in_dir: gs
      datadivision: datadivision
    out:
    - data_files
  concat-files-1:
    run: concat-files.cwl
    in:
      in_dir: ocr
      datadivision: datadivision
    out:
    - data_files
  save-files-to-dir:
    run: save-files-to-dir.cwl
    in:
      dir_name: gs_dir_name
      in_files: concat-files/data_files
    out:
    - out
  save-files-to-dir-1:
    run: save-files-to-dir.cwl
    in:
      dir_name: ocr_dir_name
      in_files: concat-files-1/data_files
    out:
    - out
