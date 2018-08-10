#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: onmt-build-vocab

inputs:
  in_files:
    type: File[]
    inputBinding:
      position: 1
  save_vocab:
    type: string
    inputBinding:
      prefix: --save_vocab
  min_frequency:
    type: int?
    default: 1
    inputBinding:
      prefix: --min_frequency
  size:
    type: int?
    default: 0
    inputBinding:
      prefix: --size
  without_sequence_tokens:
    type: bool?
    inputBinding:
      prefix: --without_sequence_tokens
  tokenizer:
    type:
      type: enum
      symbols:
      - CharacterTokenizer
      - SpaceTokenizer
    default: SpaceTokenizer
  tokenizer_config:
    type: File?
    inputBinding:
      prefix: --tokenizer_config

outputs:
  out_files:
    type: File
    outputBinding:
      glob: $(inputs.save_vocab.basename)
