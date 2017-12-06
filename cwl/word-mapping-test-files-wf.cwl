#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: SubworkflowFeatureRequirement
inputs:
  gs_dir: Directory
  ocr_dir: Directory
  gs_dir_name:
    default: gs
    type: string
  ocr_dir_name:
    default: ocr
    type: string
  data_div: File
  lowercase: boolean?
  align_m: string?
  align_c: string?
  wm_name: string?
outputs:
  wm_mapping:
    type: File
    outputSource: word-mapping-wf/wm_mapping
  txt_files:
    type:
      items: File
      type: array
    outputSource: word-mapping-wf/txt_files
steps:
  select-test-files:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.select_test_files]

      stdout: cwl.output.json

      inputs:
      - type: File
        inputBinding:
          position: 2
        id: _:select-test-files#datadivision
      - type: Directory
        inputBinding:
          position: 1
        id: _:select-test-files#in_dir
      - type:
        - 'null'
        - string
        inputBinding:
          prefix: --name

        id: _:select-test-files#name
      outputs:
      - type:
          type: array
          items: File
        id: _:select-test-files#out_files
      id: _:select-test-files
    in:
      in_dir: gs_dir
      datadivision: data_div
    out:
    - out_files
  select-test-files-1:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.select_test_files]

      stdout: cwl.output.json

      inputs:
      - type: File
        inputBinding:
          position: 2
        id: _:select-test-files-1#datadivision
      - type: Directory
        inputBinding:
          position: 1
        id: _:select-test-files-1#in_dir
      - type:
        - 'null'
        - string
        inputBinding:
          prefix: --name

        id: _:select-test-files-1#name
      outputs:
      - type:
          type: array
          items: File
        id: _:select-test-files-1#out_files
      id: _:select-test-files-1
    in:
      in_dir: ocr_dir
      datadivision: data_div
    out:
    - out_files
  save-files-to-dir:
    run:
      cwlVersion: v1.0
      class: ExpressionTool

      requirements:
      - class: InlineJavascriptRequirement

      inputs:
      - type: string
        id: _:save-files-to-dir#dir_name
      - type:
          type: array
          items: File
        id: _:save-files-to-dir#in_files
      outputs:
      - type: Directory
        id: _:save-files-to-dir#out
      expression: |
        ${
          return {"out": {
            "class": "Directory",
            "basename": inputs.dir_name,
            "listing": inputs.in_files
          } };
        }
      id: _:save-files-to-dir
    in:
      dir_name: gs_dir_name
      in_files: select-test-files/out_files
    out:
    - out
  save-files-to-dir-5:
    run:
      cwlVersion: v1.0
      class: ExpressionTool

      requirements:
      - class: InlineJavascriptRequirement

      inputs:
      - type: string
        id: _:save-files-to-dir-5#dir_name
      - type:
          type: array
          items: File
        id: _:save-files-to-dir-5#in_files
      outputs:
      - type: Directory
        id: _:save-files-to-dir-5#out
      expression: |
        ${
          return {"out": {
            "class": "Directory",
            "basename": inputs.dir_name,
            "listing": inputs.in_files
          } };
        }
      id: _:save-files-to-dir-5
    in:
      dir_name: ocr_dir_name
      in_files: select-test-files-1/out_files
    out:
    - out
  word-mapping-wf:
    run:
      cwlVersion: v1.0
      class: Workflow
      requirements:
      - class: SubworkflowFeatureRequirement
      - class: ScatterFeatureRequirement
      inputs:
      - type:
        - 'null'
        - string
        id: _:word-mapping-wf#align_c
      - type:
        - 'null'
        - string
        id: _:word-mapping-wf#align_m
      - type: Directory
        id: _:word-mapping-wf#gs_dir
      - type:
        - 'null'
        - boolean
        id: _:word-mapping-wf#lowercase
      - type: Directory
        id: _:word-mapping-wf#ocr_dir
      - type:
        - 'null'
        - string
        id: _:word-mapping-wf#wm_name
      outputs:
      - type:
          items: File
          type: array
        outputSource: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#create-word-mappings/word_mapping
        id: _:word-mapping-wf#txt_files
      - type: File
        outputSource: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#merge-csv/merged
        id: _:word-mapping-wf#wm_mapping
      steps:
      - run:
          cwlVersion: v1.0
          class: Workflow
          requirements:
          - class: ScatterFeatureRequirement
          inputs:
          - type:
            - 'null'
            - string
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align-texts-wf-1#align_c
          - type:
            - 'null'
            - string
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align-texts-wf-1#align_m
          - type:
              type: array
              items: File
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align-texts-wf-1#gs
          - type:
              type: array
              items: File
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align-texts-wf-1#ocr
          outputs:
          - type:
              items: File
              type: array
            outputSource: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/out_file
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align-texts-wf-1#alignments
          - type: File
            outputSource: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json-1/merged
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align-texts-wf-1#changes
          - type: File
            outputSource: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json/merged
            id: file:///home/jvdzwaan/code/ocr/cwl/_:align-texts-wf-1#metadata
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
          id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#align-texts-wf-1/_:align-texts-wf-1
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#align-texts-wf-1/align_c
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#align-texts-wf-1/align_m
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#align-texts-wf-1/gs
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#align-texts-wf-1/ocr
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#align-texts-wf-1/alignments
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#align-texts-wf-1/changes
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#align-texts-wf-1/metadata
        id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#align-texts-wf-1
      - run:
          cwlVersion: v1.0
          class: CommandLineTool
          baseCommand: [python, -m, ochre.create_word_mappings]

          inputs:
          - type: File
            inputBinding:
              position: 2
            id: file:///home/jvdzwaan/code/ocr/cwl/_:create-word-mappings#alignments
          - type:
            - 'null'
            - boolean
            inputBinding:
              prefix: --lowercase
            id: file:///home/jvdzwaan/code/ocr/cwl/_:create-word-mappings#lowercase
          - type:
            - 'null'
            - string
            inputBinding:
              prefix: --name

            id: file:///home/jvdzwaan/code/ocr/cwl/_:create-word-mappings#name
          - type: File
            inputBinding:
              position: 1
            id: file:///home/jvdzwaan/code/ocr/cwl/_:create-word-mappings#txt
          outputs:
          - type: File
            outputBinding:
              glob: '*.csv'
            id: file:///home/jvdzwaan/code/ocr/cwl/_:create-word-mappings#word_mapping
          id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#create-word-mappings/_:create-word-mappings
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#create-word-mappings/alignments
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#create-word-mappings/lowercase
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#create-word-mappings/txt
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#create-word-mappings/word_mapping
        scatter:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#create-word-mappings/alignments
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#create-word-mappings/txt
        scatterMethod: dotproduct
        id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#create-word-mappings
      - run:
          cwlVersion: v1.0
          class: CommandLineTool
          baseCommand: [python, -m, nlppln.commands.ls]

          inputs:
          - type: Directory
            inputBinding:
              position: 2
            id: file:///home/jvdzwaan/code/ocr/cwl/_:ls#in_dir
          - type:
            - 'null'
            - boolean
            inputBinding:
              prefix: --recursive

            id: file:///home/jvdzwaan/code/ocr/cwl/_:ls#recursive
          stdout: cwl.output.json

          outputs:
          - type:
              type: array
              items: File
            id: file:///home/jvdzwaan/code/ocr/cwl/_:ls#out_files
          id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#ls/_:ls
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#ls/in_dir
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#ls/out_files
        id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#ls
      - run:
          cwlVersion: v1.0
          class: CommandLineTool
          baseCommand: [python, -m, nlppln.commands.ls]

          inputs:
          - type: Directory
            inputBinding:
              position: 2
            id: file:///home/jvdzwaan/code/ocr/cwl/_:ls-2#in_dir
          - type:
            - 'null'
            - boolean
            inputBinding:
              prefix: --recursive

            id: file:///home/jvdzwaan/code/ocr/cwl/_:ls-2#recursive
          stdout: cwl.output.json

          outputs:
          - type:
              type: array
              items: File
            id: file:///home/jvdzwaan/code/ocr/cwl/_:ls-2#out_files
          id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#ls-2/_:ls-2
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#ls-2/in_dir
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#ls-2/out_files
        id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#ls-2
      - run:
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
            id: file:///home/jvdzwaan/code/ocr/cwl/_:merge-csv#in_files
          - type:
            - 'null'
            - string
            default: merged.csv
            inputBinding:
              prefix: --name=
              separate: false

            id: file:///home/jvdzwaan/code/ocr/cwl/_:merge-csv#name
          outputs:
          - type: File
            outputBinding:
              glob: $(inputs.name)
            id: file:///home/jvdzwaan/code/ocr/cwl/_:merge-csv#merged
          id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#merge-csv/_:merge-csv
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#merge-csv/in_files
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#merge-csv/name
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#merge-csv/merged
        id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#merge-csv
      - run:
          cwlVersion: v1.0
          class: CommandLineTool
          baseCommand: [python, -m, nlppln.commands.normalize_whitespace_punctuation]

          inputs:
          - type: File
            inputBinding:
              position: 1

            id: file:///home/jvdzwaan/code/ocr/cwl/_:normalize-whitespace-punctuation#meta_in
          outputs:
          - type: File
            outputBinding:
              glob: '*.txt'
            id: file:///home/jvdzwaan/code/ocr/cwl/_:normalize-whitespace-punctuation#metadata_out
          id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation/_:normalize-whitespace-punctuation
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation/meta_in
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation/metadata_out
        scatter:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation/meta_in
        scatterMethod: dotproduct
        id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation
      - run:
          cwlVersion: v1.0
          class: CommandLineTool
          baseCommand: [python, -m, nlppln.commands.normalize_whitespace_punctuation]

          inputs:
          - type: File
            inputBinding:
              position: 1

            id: file:///home/jvdzwaan/code/ocr/cwl/_:normalize-whitespace-punctuation-1#meta_in
          outputs:
          - type: File
            outputBinding:
              glob: '*.txt'
            id: file:///home/jvdzwaan/code/ocr/cwl/_:normalize-whitespace-punctuation-1#metadata_out
          id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation-1/_:normalize-whitespace-punctuation-1
        in:
        - id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation-1/meta_in
        out:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation-1/metadata_out
        scatter:
        - file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation-1/meta_in
        scatterMethod: dotproduct
        id: file:///home/jvdzwaan/code/ocr/cwl/word-mapping-wf.cwl#normalize-whitespace-punctuation-1
      id: _:word-mapping-wf
    in:
      lowercase: lowercase
      ocr_dir: save-files-to-dir-5/out
      align_c: align_c
      gs_dir: save-files-to-dir/out
      wm_name: wm_name
      align_m: align_m
    out:
    - txt_files
    - wm_mapping
