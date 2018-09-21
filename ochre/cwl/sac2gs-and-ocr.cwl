#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.sac2gs_and_ocr"]

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

inputs:
  in_dir:
    type: Directory
    inputBinding:
      position: 1

stdout: cwl.output.json

outputs:
  gs_de:
    type: File[]
  ocr_de:
    type: File[]
  gs_fr:
    type: File[]
  ocr_fr:
    type: File[]
