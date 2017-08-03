#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "/align.py"]
hints:
  - class: DockerRequirement
    dockerPull: nlppln/nlppln-align:0.1.0
inputs:
  file1:
    type: File
    inputBinding:
      position: 1
  file2:
    type: File
    inputBinding:
      position: 2
  out_dir:
    type: Directory?
    inputBinding:
      prefix: --out_dir=
      separate: false
outputs:
  metadata:
    type: File
    outputBinding:
      glob: "*-metadata.json"
  changes:
    type: File
    outputBinding:
      glob: "*-changes.json"
