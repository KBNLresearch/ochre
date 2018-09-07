#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.select_vudnc_files"]

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
  out_files:
    type: File[]
