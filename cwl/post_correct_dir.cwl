#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  charset: File
  model: File
outputs:
  corrected:
    type:
      items: File
      type: array
    outputSource: lstm-synced-correct-ocr/corrected
steps:
  ls:
    run: /home/jvdzwaan/code/nlppln/cwl/ls.cwl
    in:
      in_dir: in_dir
    out:
    - out_files
  lstm-synced-correct-ocr:
    run: /home/jvdzwaan/code/ocr/cwl/lstm-synced-correct-ocr.cwl
    in:
      txt: ls/out_files
      model: model
      charset: charset
    out:
    - corrected
    scatter:
    - txt
    scatterMethod: dotproduct
