#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: SubworkflowFeatureRequirement
- class: ScatterFeatureRequirement
inputs:
  gs_dir: Directory
  ocr_dir: Directory
  lowercase: boolean?
  align_m: string?
  align_c: string?
  wm_name: string?
outputs:
  wm_mapping:
    type: File
    outputSource: merge-csv/merged
  txt_files:
    type:
      items: File
      type: array
    outputSource: create-word-mappings/word_mapping
steps:
  ls:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, nlppln.commands.ls]

      inputs:
      - type: Directory
        inputBinding:
          position: 2
        id: _:ls#in_dir
      - type:
        - 'null'
        - boolean
        inputBinding:
          prefix: --recursive

        id: _:ls#recursive
      stdout: cwl.output.json

      outputs:
      - type:
          type: array
          items: File
        id: _:ls#out_files
      id: _:ls
    in:
      in_dir: gs_dir
    out:
    - out_files
  ls-2:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, nlppln.commands.ls]

      inputs:
      - type: Directory
        inputBinding:
          position: 2
        id: _:ls-2#in_dir
      - type:
        - 'null'
        - boolean
        inputBinding:
          prefix: --recursive

        id: _:ls-2#recursive
      stdout: cwl.output.json

      outputs:
      - type:
          type: array
          items: File
        id: _:ls-2#out_files
      id: _:ls-2
    in:
      in_dir: ocr_dir
    out:
    - out_files
  normalize-whitespace-punctuation:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, nlppln.commands.normalize_whitespace_punctuation]

      inputs:
      - type: File
        inputBinding:
          position: 1

        id: _:normalize-whitespace-punctuation#meta_in
      outputs:
      - type: File
        outputBinding:
          glob: '*.txt'
        id: _:normalize-whitespace-punctuation#metadata_out
      id: _:normalize-whitespace-punctuation
    in:
      meta_in: ls/out_files
    out:
    - metadata_out
    scatter:
    - meta_in
    scatterMethod: dotproduct
  normalize-whitespace-punctuation-1:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, nlppln.commands.normalize_whitespace_punctuation]

      inputs:
      - type: File
        inputBinding:
          position: 1

        id: _:normalize-whitespace-punctuation-1#meta_in
      outputs:
      - type: File
        outputBinding:
          glob: '*.txt'
        id: _:normalize-whitespace-punctuation-1#metadata_out
      id: _:normalize-whitespace-punctuation-1
    in:
      meta_in: ls-2/out_files
    out:
    - metadata_out
    scatter:
    - meta_in
    scatterMethod: dotproduct
  align-texts-wf-1:
    run:
      cwlVersion: v1.0
      class: Workflow
      requirements:
      - class: ScatterFeatureRequirement
      inputs:
      - type:
        - 'null'
        - string
        id: _:align-texts-wf-1#align_c
      - type:
        - 'null'
        - string
        id: _:align-texts-wf-1#align_m
      - type:
          type: array
          items: File
        id: _:align-texts-wf-1#gs
      - type:
          type: array
          items: File
        id: _:align-texts-wf-1#ocr
      outputs:
      - type:
          items: File
          type: array
        outputSource: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/out_file
        id: _:align-texts-wf-1#alignments
      - type: File
        outputSource: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json-1/merged
        id: _:align-texts-wf-1#changes
      - type: File
        outputSource: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json/merged
        id: _:align-texts-wf-1#metadata
      steps:
      - run:
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
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align#file1
          - type: File
            inputBinding:
              position: 2
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align#file2
          - type:
            - 'null'
            - Directory
            inputBinding:
              prefix: --out_dir=
              separate: false
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align#out_dir
          outputs:
          - type: File
            outputBinding:
              glob: '*-changes.json'
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align#changes
          - type: File
            outputBinding:
              glob: '*-metadata.json'
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align#metadata
          id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#align/_:align
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#align/file1
        - id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#align/file2
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#align/changes
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#align/metadata
        scatter:
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#align/file1
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#align/file2
        scatterMethod: dotproduct
        id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#align
      - run:
          cwlVersion: v1.0
          class: CommandLineTool
          baseCommand: [python, -m, ochre.char_align]

          inputs:
          - type: File
            inputBinding:
              position: 2
            id: file:///home/jvdzwaan/code/ocr/cwl/_:char-align#gs_text
          - type: File
            inputBinding:
              position: 3

            id: file:///home/jvdzwaan/code/ocr/cwl/_:char-align#metadata
          - type: File
            inputBinding:
              position: 1
            id: file:///home/jvdzwaan/code/ocr/cwl/_:char-align#ocr_text
          outputs:
          - type: File
            outputBinding:
              glob: '*.json'
            id: file:///home/jvdzwaan/code/ocr/cwl/_:char-align#out_file
          id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/_:char-align
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/gs_text
        - id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/metadata
        - id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/ocr_text
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/out_file
        scatter:
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/ocr_text
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/gs_text
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/metadata
        scatterMethod: dotproduct
        id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align
      - run:
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
            id: file:///home/jvdzwaan/code/ocr/cwl/_:merge-json#in_files
          - type:
            - 'null'
            - string
            inputBinding:
              prefix: --name=
              separate: false

            id: file:///home/jvdzwaan/code/ocr/cwl/_:merge-json#name
          outputs:
          - type: File
            outputBinding:
              glob: '*.csv'
            id: file:///home/jvdzwaan/code/ocr/cwl/_:merge-json#merged
          id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json/_:merge-json
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json/in_files
        - id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json/name
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json/merged
        id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json
      - run:
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
            id: file:///home/jvdzwaan/code/ocr/cwl/_:merge-json-1#in_files
          - type:
            - 'null'
            - string
            inputBinding:
              prefix: --name=
              separate: false

            id: file:///home/jvdzwaan/code/ocr/cwl/_:merge-json-1#name
          outputs:
          - type: File
            outputBinding:
              glob: '*.csv'
            id: file:///home/jvdzwaan/code/ocr/cwl/_:merge-json-1#merged
          id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json-1/_:merge-json-1
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json-1/in_files
        - id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json-1/name
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json-1/merged
        id: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json-1
      id: _:align-texts-wf-1
    in:
      align_m: align_m
      align_c: align_c
      ocr: normalize-whitespace-punctuation-1/metadata_out
      gs: normalize-whitespace-punctuation/metadata_out
    out:
    - alignments
    - changes
    - metadata
  create-word-mappings:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.create_word_mappings]

      inputs:
      - type: File
        inputBinding:
          position: 2
        id: _:create-word-mappings#alignments
      - type:
        - 'null'
        - boolean
        inputBinding:
          prefix: --lowercase
        id: _:create-word-mappings#lowercase
      - type:
        - 'null'
        - string
        inputBinding:
          prefix: --name

        id: _:create-word-mappings#name
      - type: File
        inputBinding:
          position: 1
        id: _:create-word-mappings#txt
      outputs:
      - type: File
        outputBinding:
          glob: '*.csv'
        id: _:create-word-mappings#word_mapping
      id: _:create-word-mappings
    in:
      lowercase: lowercase
      txt: normalize-whitespace-punctuation/metadata_out
      alignments: align-texts-wf-1/alignments
    out:
    - word_mapping
    scatter:
    - alignments
    - txt
    scatterMethod: dotproduct
  merge-csv:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, nlppln.commands.merge_csv]
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
        id: _:merge-csv#in_files
      - type:
        - 'null'
        - string
        default: merged.csv
        inputBinding:
          prefix: --name=
          separate: false

        id: _:merge-csv#name
      outputs:
      - type: File
        outputBinding:
          glob: $(inputs.name)
        id: _:merge-csv#merged
      id: _:merge-csv
    in:
      in_files: create-word-mappings/word_mapping
      name: wm_name
    out:
    - merged
