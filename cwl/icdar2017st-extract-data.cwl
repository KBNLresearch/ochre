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
    outputSource: save-files-to-dir/out
  ocr_dir:
    type: Directory
    outputSource: save-files-to-dir-1/out
  aligned_dir:
    type: Directory
    outputSource: save-files-to-dir-2/out
steps:
  ls:
    run: /home/jvdzwaan/code/nlppln/cwl/ls.cwl
    in:
      in_dir: in_dir
    out:
    - out_files
  icdar2017st-extract-text:
    run: /home/jvdzwaan/code/ocr/cwl/icdar2017st-extract-text.cwl
    in:
      in_file: ls/out_files
    out:
    - aligned
    - gs
    - ocr
    scatter:
    - in_file
    scatterMethod: dotproduct
  save-files-to-dir:
    run: /home/jvdzwaan/code/nlppln/cwl/save-files-to-dir.cwl
    in:
      dir_name: gs_dir_name
      in_files: icdar2017st-extract-text/gs
    out:
    - out
  save-files-to-dir-1:
    run: /home/jvdzwaan/code/nlppln/cwl/save-files-to-dir.cwl
    in:
      dir_name: ocr_dir_name
      in_files: icdar2017st-extract-text/ocr
    out:
    - out
  save-files-to-dir-2:
    run: /home/jvdzwaan/code/nlppln/cwl/save-files-to-dir.cwl
    in:
      dir_name: aligned_dir_name
      in_files: icdar2017st-extract-text/aligned
    out:
    - out
