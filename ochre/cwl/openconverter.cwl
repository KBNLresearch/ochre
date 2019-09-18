#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["/usr/lib/jvm/java-1.8.0-openjdk-amd64/bin/java", "-jar", "/home/jvdzwaan/code/OpenConvert/dist/OpenConvert.jar"]

arguments:
  - valueFrom: $(runtime.outdir)
    position: 1

inputs:
  in_dir:
    type: Directory
    inputBinding:
      position: 0

  from:
    type: string
    default: tei
    inputBinding:
      prefix: -from

  to:
    type: string
    default: txt
    inputBinding:
      prefix: -to


outputs:
  out_files:
    type: File[]
    outputBinding:
      glob: "*"
