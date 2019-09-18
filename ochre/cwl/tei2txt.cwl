#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  EnvVarRequirement:
    envDef:
      LC_ALL: C.UTF-8
      LANG: C.UTF-8

doc: |
  Convert tei documents to plain text using `xmllint`.
  This is a very simple solution taken from `digitalhumanities.org <http://digitalhumanities.org/answers/topic/how-do-i-best-convert-hundreds-of-tei-p5-documents-to-plaintext>`_.

  TODO: put in Docker containing xmllint

baseCommand: [xmllint, --xpath, "string(//*[local-name()='body'])"]

stdout: $(inputs.tei_file.nameroot).txt

inputs:
  tei_file:
    type: File
    inputBinding:
      position: 0

outputs:
  txt_file:
    type: stdout
