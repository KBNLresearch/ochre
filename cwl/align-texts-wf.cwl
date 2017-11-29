#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  gs: File[]
  ocr: File[]
  align_m: string?
  align_c: string?
outputs:
  alignments:
    type:
      items: File
      type: array
    outputSource: char-align/out_file
  changes:
    type: File
    outputSource: merge-json-1/merged
  metadata:
    type: File
    outputSource: merge-json/merged
steps:
  align:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, /align.py]
      hints:
      - class: DockerRequirement
        dockerPull: nlppln/align:0.1.0
      inputs:
      - type: File
        inputBinding:
          position: 1
        id: _:align#file1
      - type: File
        inputBinding:
          position: 2
        id: _:align#file2
      - type:
        - 'null'
        - Directory
        inputBinding:
          prefix: --out_dir=
          separate: false
        id: _:align#out_dir
      outputs:
      - type: File
        outputBinding:
          glob: '*-changes.json'
        id: _:align#changes
      - type: File
        outputBinding:
          glob: '*-metadata.json'
        id: _:align#metadata
      id: _:align
    in:
      file2: gs
      file1: ocr
    out:
    - changes
    - metadata
    scatter:
    - file1
    - file2
    scatterMethod: dotproduct
  merge-json:
    run:
      cwlVersion: v1.0
      class: CommandLineTool

      baseCommand: [python, -m, ochre.merge_json]

      requirements:
      - listing: $(inputs.in_files)

        class: InitialWorkDirRequirement
      arguments:
      - valueFrom: $(runtime.outdir)
        position: 1

      inputs:
      - type:
          type: array
          items: File
        id: _:merge-json#in_files
      - type:
        - 'null'
        - string
        inputBinding:
          prefix: --name=
          separate: false
        id: _:merge-json#name
      - type:
        - 'null'
        - Directory
        inputBinding:
          prefix: --out_dir=
          separate: false

        id: _:merge-json#out_dir
      outputs:
      - type: File
        outputBinding:
          glob: '*.csv'
        id: _:merge-json#merged
      id: _:merge-json
    in:
      in_files: align/metadata
      name: align_m
    out:
    - merged
  merge-json-1:
    run:
      cwlVersion: v1.0
      class: CommandLineTool

      baseCommand: [python, -m, ochre.merge_json]

      requirements:
      - listing: $(inputs.in_files)

        class: InitialWorkDirRequirement
      arguments:
      - valueFrom: $(runtime.outdir)
        position: 1

      inputs:
      - type:
          type: array
          items: File
        id: _:merge-json-1#in_files
      - type:
        - 'null'
        - string
        inputBinding:
          prefix: --name=
          separate: false
        id: _:merge-json-1#name
      - type:
        - 'null'
        - Directory
        inputBinding:
          prefix: --out_dir=
          separate: false

        id: _:merge-json-1#out_dir
      outputs:
      - type: File
        outputBinding:
          glob: '*.csv'
        id: _:merge-json-1#merged
      id: _:merge-json-1
    in:
      in_files: align/changes
      name: align_c
    out:
    - merged
  char-align:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.char_align]

      inputs:
      - type: File
        inputBinding:
          position: 2
        id: _:char-align#gs_text
      - type: File
        inputBinding:
          position: 3
        id: _:char-align#metadata
      - type: File
        inputBinding:
          position: 1
        id: _:char-align#ocr_text
      - type:
        - 'null'
        - Directory
        inputBinding:
          prefix: --out_dir=
          separate: false

        id: _:char-align#out_dir
      outputs:
      - type: File
        outputBinding:
          glob: '*.json'
        id: _:char-align#out_file
      id: _:char-align
    in:
      ocr_text: ocr
      metadata: align/metadata
      gs_text: gs
    out:
    - out_file
    scatter:
    - ocr_text
    - gs_text
    - metadata
    scatterMethod: dotproduct
