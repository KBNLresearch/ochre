#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: SubworkflowFeatureRequirement
- class: ScatterFeatureRequirement
inputs:
  gs_dir: Directory
  ocr_dir: Directory
  lowercase: boolean?
  align_m: string?
  align_c: string?
  wm_name: string?
outputs:
  wm_mapping:
    type: File
    outputSource: merge-csv/merged
steps:
  ls:
    run: /home/jvdzwaan/code/nlppln/cwl/ls.cwl
    in:
      in_dir: gs_dir
    out:
    - out_files
  ls-1:
    run: /home/jvdzwaan/code/nlppln/cwl/ls.cwl
    in:
      in_dir: ocr_dir
    out:
    - out_files
  normalize-whitespace-punctuation:
    run: /home/jvdzwaan/code/nlppln/cwl/normalize-whitespace-punctuation.cwl
    in:
      meta_in: ls/out_files
    out:
    - metadata_out
    scatter:
    - meta_in
    scatterMethod: dotproduct
  normalize-whitespace-punctuation-1:
    run: /home/jvdzwaan/code/nlppln/cwl/normalize-whitespace-punctuation.cwl
    in:
      meta_in: ls-1/out_files
    out:
    - metadata_out
    scatter:
    - meta_in
    scatterMethod: dotproduct
  align-texts-wf:
    run: /home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl
    in:
      align_m: align_m
      align_c: align_c
      ocr: normalize-whitespace-punctuation-1/metadata_out
      gs: normalize-whitespace-punctuation/metadata_out
    out:
    - alignments
    - changes
    - metadata
  create-word-mappings:
    run: /home/jvdzwaan/code/ocr/cwl/create-word-mappings.cwl
    in:
      lowercase: lowercase
      txt: normalize-whitespace-punctuation/metadata_out
      alignments: align-texts-wf/alignments
    out:
    - word_mapping
    scatter:
    - alignments
    - txt
    scatterMethod: dotproduct
  merge-csv:
    run: /home/jvdzwaan/code/nlppln/cwl/merge-csv.cwl
    in:
      in_files: create-word-mappings/word_mapping
      name: wm_name
    out:
    - merged
