#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.opennmt_create_data"]

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

inputs:
  saf:
    type: File
    inputBinding:
      position: 1
  alignments:
    type: File
    inputBinding:
      position: 2
  lowercase:
    type: boolean?
    default: false
    inputBinding:
      prefix: --lowercase

outputs:
  src:
    type: File
    outputBinding:
      glob: "*.raw.src.txt"
  tgt:
    type: File
    outputBinding:
      glob: "*.raw.tgt.txt"
