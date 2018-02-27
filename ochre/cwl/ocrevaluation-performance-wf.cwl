#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  gt: Directory
  ocr: Directory
  out_name:
    default: performance.csv
    type: string?
outputs:
  performance:
    type: File
    outputSource: merge-csv-1/merged
steps:
  ls-6:
    run: ls.cwl
    in:
      in_dir: ocr
    out:
    - out_files
  ls-7:
    run: ls.cwl
    in:
      in_dir: gt
    out:
    - out_files
  ocrevaluation-1:
    run: https://raw.githubusercontent.com/nlppln/ocrevaluation-docker/master/ocrevaluation.cwl
    in:
      ocr: ls-6/out_files
      gt: ls-7/out_files
    out:
    - out_file
    scatter:
    - gt
    - ocr
    scatterMethod: dotproduct
  ocrevaluation-extract-1:
    run: ocrevaluation-extract.cwl
    in:
      in_file: ocrevaluation-1/out_file
    out:
    - character_data
    - global_data
    scatter:
    - in_file
    scatterMethod: dotproduct
  merge-csv-1:
    run: merge-csv.cwl
    in:
      in_files: ocrevaluation-extract-1/global_data
      name: out_name
    out:
    - merged
