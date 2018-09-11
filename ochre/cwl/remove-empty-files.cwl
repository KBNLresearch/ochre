#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

baseCommand: ["python", "-m", "ochre.remove_empty_files"]

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

inputs:
  ocr_dir:
    type: Directory
    inputBinding:
      position: 2
  gs_dir:
    type: Directory
    inputBinding:
      position: 1

stdout: cwl.output.json

outputs:
  ocr:
    type: File[]
  gs:
    type: File[]
