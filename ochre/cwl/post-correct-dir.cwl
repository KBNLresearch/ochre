#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  charset: File
  model: File
outputs:
  corrected:
    type:
      items: File
      type: array
    outputSource: lstm-synced-correct-ocr/corrected
steps:
  ls-4:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, nlppln.commands.ls]

      inputs:
      - type: Directory
        inputBinding:
          position: 2
        id: _:ls-4#in_dir
      - type:
        - 'null'
        - boolean
        inputBinding:
          prefix: --recursive

        id: _:ls-4#recursive
      stdout: cwl.output.json

      outputs:
      - type:
          type: array
          items: File
        id: _:ls-4#out_files
      id: _:ls-4
    in:
      in_dir: in_dir
    out:
    - out_files
  lstm-synced-correct-ocr:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.lstm_synced_correct_ocr]

      inputs:
      - type: File
        inputBinding:
          position: 2
        id: _:lstm-synced-correct-ocr#charset
      - type: File
        inputBinding:
          position: 1
        id: _:lstm-synced-correct-ocr#model
      - type: File
        inputBinding:
          position: 3

        id: _:lstm-synced-correct-ocr#txt
      outputs:
      - type: File
        outputBinding:
          glob: $(inputs.txt.basename)
        id: _:lstm-synced-correct-ocr#corrected
      id: _:lstm-synced-correct-ocr
    in:
      txt: ls-4/out_files
      model: model
      charset: charset
    out:
    - corrected
    scatter:
    - txt
    scatterMethod: dotproduct
