#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: onmt-tokenize-text

doc: |
  Use OpenNMT tokenizer offline.
  See http://opennmt.net/OpenNMT-tf/tokenization.html for more information.

inputs:
  text:
    type: File
  delimiter:
    type: string?
    inputBinding:
      prefix: --delimiter
  tokenizer:
    type:
      type: enum
      symbols:
      - CharacterTokenizer
      - SpaceTokenizer
    default: SpaceTokenizer
    inputBinding:
      prefix: --tokenizer
  tokenizer_config:
    type: File?
    inputBinding:
      prefix: --tokenizer_config
  out_name:
    type: string

stdin: $(inputs.text.path)

stdout: $(inputs.out_name)

outputs:
  tokenized: stdout
