#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: onmt-main

inputs:
  run_type:
    type:
      type: enum
      symbols:
        - train_and_eval
        - train
        - eval
        - infer
        - export
        - score
    inputBinding:
      position: 0
  model_type:
    type:
      - "null"
      - type: enum
        symbols:
          - ListenAttendSpell
          - NMTBig
          - NMTMedium
          - NMTSmall
          - SeqTagger
          - Transformer
          - TransformerAAN
          - TransformerBig
    inputBinding:
      prefix: --model_type
  model:
    type: File?
    inputBinding:
      prefix: --model
  config:
    type: File[]
    inputBinding:
      prefix: --config

outputs:
  out_dir:
    type: Directory
