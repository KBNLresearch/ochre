#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ocr-transform

requirements:
  - class: DockerRequirement
    dockerPull: ubma/ocr-fileformat
  - class: InlineJavascriptRequirement

inputs:
  in_fmt:
    type: string
    inputBinding:
      position: 1
  out_fmt:
    type: string
    inputBinding:
      position: 2
  in_file:
    type: File
    inputBinding:
      position: 3

stdout: |
  ${
    var nameroot = inputs.in_file.nameroot;
    var ext = 'xml';
    if(inputs.out_fmt == 'text'){
      ext = 'txt';
    }
    return nameroot + '.' + ext;
  }

outputs:
  out_file:
    type: File
    outputBinding:
      glob: $(inputs.in_file.nameroot).*
