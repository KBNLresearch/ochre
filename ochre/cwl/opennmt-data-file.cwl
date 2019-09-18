#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
inputs:
  gs: File
  alignments: File
  language: string
  lowercase: boolean?
  space: string?
outputs:
  src:
    outputSource: opennmt-create-data-1/src
    type: File
  tgt:
    outputSource: opennmt-create-data-1/tgt
    type: File
steps:
  pattern-3:
    run: https://raw.githubusercontent.com/nlppln/pattern-docker/master/pattern.cwl
    in:
      in_file: gs
      language: language
    out:
    - saf
  opennmt-create-data-1:
    run: opennmt-create-data.cwl
    in:
      alignments: alignments
      saf: pattern-3/saf
      lowercase: lowercase
      space: space
    out:
    - src
    - tgt
