#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.create_word_mappings"]

inputs:
  txt:
    type: File
    inputBinding:
      position: 1
  alignments:
    type: File
    inputBinding:
      position: 2
  lowercase:
    type: boolean?
    inputBinding:
      prefix: --lowercase
  name:
    type: string?
    inputBinding:
      prefix: --name

outputs:
  word_mapping:
    type: File
    outputBinding:
      glob: "*.csv"
