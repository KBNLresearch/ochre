#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

baseCommand: ["python", "-m", "ochre.merge_json"]

requirements:
  InitialWorkDirRequirement:
    listing: $(inputs.in_files)

arguments:
  - valueFrom: $(runtime.outdir)
    position: 1

inputs:
  in_files:
    type: File[]
  name:
    type: string?
    inputBinding:
      prefix: --name=
      separate: false

outputs:
  merged:
    type: File
    outputBinding:
      glob: "*.csv"
