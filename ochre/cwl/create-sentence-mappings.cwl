#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

baseCommand: ["python", "-m", "ochre.create_sentence_mappings"]

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
    inputBinding:
      prefix: --lowercase
  name:
    type: string?
    inputBinding:
      prefix: --name

stdout: $(inputs.saf.nameroot).txt

outputs:
  sentences:
    type: File
    outputBinding:
      glob: "*.txt"
