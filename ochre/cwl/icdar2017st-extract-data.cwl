#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  ocr_dir_name: string
  gs_dir_name: string
  aligned_dir_name: string
outputs:
  gs_dir:
    type: Directory
    outputSource: save-files-to-dir-6/out
  ocr_dir:
    type: Directory
    outputSource: save-files-to-dir-7/out
  aligned_dir:
    type: Directory
    outputSource: save-files-to-dir-8/out
steps:
  ls-3:
    run: ls.cwl
    in:
      in_dir: in_dir
    out:
    - out_files
  icdar2017st-extract-text:
    run: icdar2017st-extract-text.cwl
    in:
      in_file: ls-3/out_files
    out:
    - aligned
    - gs
    - ocr
    scatter:
    - in_file
    scatterMethod: dotproduct
  save-files-to-dir-6:
    run: save-files-to-dir.cwl
    in:
      dir_name: gs_dir_name
      in_files: icdar2017st-extract-text/gs
    out:
    - out
  save-files-to-dir-7:
    run: save-files-to-dir.cwl
    in:
      dir_name: ocr_dir_name
      in_files: icdar2017st-extract-text/ocr
    out:
    - out
  save-files-to-dir-8:
    run: save-files-to-dir.cwl
    in:
      dir_name: aligned_dir_name
      in_files: icdar2017st-extract-text/aligned
    out:
    - out
