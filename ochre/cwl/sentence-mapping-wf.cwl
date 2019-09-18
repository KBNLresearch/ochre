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
outputs:
  sentences:
    type:
      items: File
      type: array
    outputSource: create-sentence-mappings/sentences
steps:
  normalize-whitespace-punctuation:
    run: normalize-whitespace-punctuation.cwl
    in:
      meta_in: gs_files
    out:
    - metadata_out
    scatter:
    - meta_in
    scatterMethod: dotproduct
  normalize-whitespace-punctuation-1:
    run: normalize-whitespace-punctuation.cwl
    in:
      meta_in: ocr_files
    out:
    - metadata_out
    scatter:
    - meta_in
    scatterMethod: dotproduct
  align-texts-wf-1:
    run: align-texts-wf.cwl
    in:
      align_m: align_m
      align_c: align_c
      ocr: normalize-whitespace-punctuation-1/metadata_out
      gs: normalize-whitespace-punctuation/metadata_out
    out:
    - alignments
    - changes
    - metadata
  pattern:
    run: https://raw.githubusercontent.com/nlppln/pattern-docker/master/pattern.cwl
    in:
      in_file: normalize-whitespace-punctuation/metadata_out
      language: language
    out:
    - out_files
    scatter:
    - in_file
    scatterMethod: dotproduct
  create-sentence-mappings:
    run: create-sentence-mappings.cwl
    in:
      lowercase: lowercase
      alignments: align-texts-wf-1/alignments
      saf: pattern/out_files
    out:
    - sentences
    scatter:
    - alignments
    - saf
    scatterMethod: dotproduct
