#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "-m", "nlppln.commands.rmgarbage"]

inputs:
  in_file:
    type: File

outputs:
  out_file:
    type: File
    outputBinding:
      glob: $(inputs.in_file.nameroot).txt
  metadata_out:
    type: File
    outputBinding:
      glob: $(inputs.in_file.nameroot).txt
