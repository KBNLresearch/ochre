#!/usr/bin/env cwlrunner
cwlVersion: v1.0
class: CommandLineTool

baseCommand: ["python", "-m", "ochre.kb_tss_remove_empty_files"]

inputs:
  in_dir1:
    type: Directory
    inputBinding:
      position: 1
  in_dir2:
    type: Directory
    inputBinding:
      position: 2
  in_dir3:
    type: Directory
    inputBinding:
      position: 3

stdout: cwl.output.json

outputs:
  files1: File[]
  files2: File[]
  files3: File[]
