#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
doc: This workflow is meant to be used as a subworkflow.
requirements:
- class: SubworkflowFeatureRequirement
- class: ScatterFeatureRequirement
inputs:
  gs_files: File[]
  ocr_files: File[]
  language: string
  lowercase: boolean?
  align_m: string?
  align_c: string?
  wm_name: string?
outputs:
  wm_mapping:
    type: File
    outputSource: merge-csv-2/merged
steps:
  normalize-whitespace-punctuation-2:
    run: normalize-whitespace-punctuation.cwl
    in:
      meta_in: gs_files
    out:
    - metadata_out
    scatter:
    - meta_in
    scatterMethod: dotproduct
  normalize-whitespace-punctuation-3:
    run: normalize-whitespace-punctuation.cwl
    in:
      meta_in: ocr_files
    out:
    - metadata_out
    scatter:
    - meta_in
    scatterMethod: dotproduct
  align-texts-wf-2:
    run: align-texts-wf.cwl
    in:
      align_m: align_m
      align_c: align_c
      ocr: normalize-whitespace-punctuation-3/metadata_out
      gs: normalize-whitespace-punctuation-2/metadata_out
    out:
    - alignments
    - changes
    - metadata
  pattern-1:
    run: https://raw.githubusercontent.com/nlppln/pattern-docker/master/pattern.cwl
    in:
      in_file: normalize-whitespace-punctuation-2/metadata_out
      language: language
    out:
    - out_files
    scatter:
    - in_file
    scatterMethod: dotproduct
  create-word-mappings-1:
    run: create-word-mappings.cwl
    in:
      lowercase: lowercase
      alignments: align-texts-wf-2/alignments
      saf: pattern-1/out_files
    out:
    - word_mapping
    scatter:
    - alignments
    - saf
    scatterMethod: dotproduct
  merge-csv-2:
    run: merge-csv.cwl
    in:
      in_files: create-word-mappings-1/word_mapping
      name: wm_name
    out:
    - merged
