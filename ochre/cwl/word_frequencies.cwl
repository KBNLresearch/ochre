#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
inputs:
  txt_dir: Directory
  data_div: File
  data_set:
    default: train
    type: string
outputs:
  vocab:
    type: File
    outputSource: freqs/freqs
steps:
  select-test-files-3:
    run: select-test-files.cwl
    in:
      in_dir: txt_dir
      datadivision: data_div
    out:
    - out_files
  freqs:
    run: freqs.cwl
    in:
      in_files: select-test-files-3/out_files
    out:
    - freqs
