#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: SubworkflowFeatureRequirement
inputs:
  gs_dir: Directory
  ocr_dir: Directory
  gs_dir_name:
    type: string
    default: gs
  ocr_dir_name:
    type: string
    default: ocr
  data_div: File
  lowercase: boolean?
  align_m: string?
  align_c: string?
  wm_name: string?
outputs:
  wm_mapping:
    type: File
    outputSource: word-mapping-wf/wm_mapping
steps:
  select-test-files:
    run: /home/jvdzwaan/code/ocr/cwl/select-test-files.cwl
    in:
      in_dir: gs_dir
      datadivision: data_div
    out:
    - out_files
  select-test-files-1:
    run: /home/jvdzwaan/code/ocr/cwl/select-test-files.cwl
    in:
      in_dir: ocr_dir
      datadivision: data_div
    out:
    - out_files
  save-files-to-dir:
    run: /home/jvdzwaan/code/nlppln/cwl/save-files-to-dir.cwl
    in:
      dir_name: gs_dir_name
      in_files: select-test-files/out_files
    out:
    - out
  save-files-to-dir-1:
    run: /home/jvdzwaan/code/nlppln/cwl/save-files-to-dir.cwl
    in:
      dir_name: ocr_dir_name
      in_files: select-test-files-1/out_files
    out:
    - out
  word-mapping-wf:
    run: /home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl
    in:
      lowercase: lowercase
      ocr_dir: save-files-to-dir-1/out
      align_c: align_c
      gs_dir: save-files-to-dir/out
      wm_name: wm_name
      align_m: align_m
    out:
    - wm_mapping
