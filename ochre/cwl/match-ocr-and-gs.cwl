#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

baseCommand: ["python", "-m", "ochre.match_ocr_and_gs"]

inputs:
  ocr_dir:
    type: Directory
    inputBinding:
     position: 0
  gs_dir:
    type: Directory
    inputBinding:
      position: 1

outputs:
  ocr:
    type: Directory
    outputBinding:
      glob: $(runtime.outdir)/ocr
  gs:
    type: Directory
    outputBinding:
      glob: "gs"
