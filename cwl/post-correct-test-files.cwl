#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  datadivision: File
  div_name:
    default: test
    type: string
  charset: File
  model: File
outputs:
  corrected:
    type:
      items: File
      type: array
    outputSource: lstm-synced-correct-ocr-1/corrected
steps:
  select-test-files-2:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.select_test_files]

      stdout: cwl.output.json

      inputs:
      - type: File
        inputBinding:
          position: 2
        id: _:select-test-files-2#datadivision
      - type: Directory
        inputBinding:
          position: 1
        id: _:select-test-files-2#in_dir
      - type:
        - 'null'
        - string
        inputBinding:
          prefix: --name

        id: _:select-test-files-2#name
      outputs:
      - type:
          type: array
          items: File
        id: _:select-test-files-2#out_files
      id: _:select-test-files-2
    in:
      in_dir: in_dir
      datadivision: datadivision
    out:
    - out_files
  lstm-synced-correct-ocr-1:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.lstm_synced_correct_ocr]

      inputs:
      - type: File
        inputBinding:
          position: 2
        id: _:lstm-synced-correct-ocr-1#charset
      - type: File
        inputBinding:
          position: 1
        id: _:lstm-synced-correct-ocr-1#model
      - type: File
        inputBinding:
          position: 3

        id: _:lstm-synced-correct-ocr-1#txt
      outputs:
      - type: File
        outputBinding:
          glob: $(inputs.txt.basename)
        id: _:lstm-synced-correct-ocr-1#corrected
      id: _:lstm-synced-correct-ocr-1
    in:
      txt: select-test-files-2/out_files
      model: model
      charset: charset
    out:
    - corrected
    scatter:
    - txt
    scatterMethod: dotproduct
