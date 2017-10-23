#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  datadivision: File
  div_name:
    type: string
    default: test
  charset: File
  model: File
outputs:
  corrected:
    type:
      items: File
      type: array
    outputSource: lstm-synced-correct-ocr/corrected
steps:
  select-test-files:
    run: /home/jvdzwaan/code/ocr/cwl/select-test-files.cwl
    in:
      in_dir: in_dir
      datadivision: datadivision
    out:
    - out_files
  lstm-synced-correct-ocr:
    run: /home/jvdzwaan/code/ocr/cwl/lstm-synced-correct-ocr.cwl
    in:
      txt: select-test-files/out_files
      model: model
      charset: charset
    out:
    - corrected
    scatter:
    - txt
    scatterMethod: dotproduct
