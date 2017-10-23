#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "ochre.select_test_files"]

stdout: cwl.output.json

inputs:
  in_dir:
    type: Directory
    inputBinding:
      position: 1
  datadivision:
    type: File
    inputBinding:
      position: 2
  name:
    type: string?
    inputBinding:
      prefix: --name
  out_dir:
    type: Directory?
    inputBinding:
      prefix: --out_dir=
      separate: false

outputs:
  out_files:
    type: File[]
