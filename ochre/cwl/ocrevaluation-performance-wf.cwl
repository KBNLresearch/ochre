#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
inputs:
  gt: File
  ocr: File
outputs:
  character_data:
    type: File
    outputSource: ocrevaluation-extract-1/character_data
  global_data:
    type: File
    outputSource: ocrevaluation-extract-1/global_data
steps:
  ocrevaluation-1:
    run: https://raw.githubusercontent.com/nlppln/ocrevaluation-docker/master/ocrevaluation.cwl
    in:
      ocr: ocr
      gt: gt
    out:
    - out_file
  ocrevaluation-extract-1:
    run: ocrevaluation-extract.cwl
    in:
      in_file: ocrevaluation-1/out_file
    out:
    - character_data
    - global_data
