#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

baseCommand: ["python", "-m", "ochre.kb_tss_concat_files"]

requirements:
  InitialWorkDirRequirement:
    listing: $(inputs.in_files)

arguments:
  - valueFrom: $(runtime.outdir)
    position: 1

inputs:
  in_files:
    type: File[]

outputs:
  out_files:
    type: File[]
    outputBinding:
      glob: "*.txt"
