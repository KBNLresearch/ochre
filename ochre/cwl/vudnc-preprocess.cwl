#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: SubworkflowFeatureRequirement
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  ocr_dir_name: string
  gs_dir_name: string
  aligned_dir_name: string
  ocr_n: string?
  gs_n: string?
  align_m: string?
  align_c: string?
outputs:
  ocr_char_counts:
    type: File
    outputSource: merge-json-2/merged
  ocr_dir:
    type: Directory
    outputSource: save-files-to-dir-2/out
  gs_char_counts:
    type: File
    outputSource: merge-json-3/merged
  gs_dir:
    type: Directory
    outputSource: save-files-to-dir-1/out
  changes:
    type: File
    outputSource: align-texts-wf/changes
  metadata:
    type: File
    outputSource: align-texts-wf/metadata
  aligned_dir:
    type: Directory
    outputSource: save-files-to-dir-3/out
steps:
  vudnc-select-files:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.select_vudnc_files]

      inputs:
      - type: Directory
        inputBinding:
          position: 1

        id: _:vudnc-select-files#in_dir
      stdout: cwl.output.json

      outputs:
      - type:
          type: array
          items: File
        id: _:vudnc-select-files#out_files
      id: _:vudnc-select-files
    in:
      in_dir: in_dir
    out:
    - out_files
  vudnc2ocr-and-gs:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.vudnc2ocr_and_gs]

      inputs:
      - type: File
        inputBinding:
          position: 1
        id: _:vudnc2ocr-and-gs#in_file
      - type:
        - 'null'
        - Directory
        inputBinding:
          prefix: --out_dir=
          separate: false

        id: _:vudnc2ocr-and-gs#out_dir
      outputs:
      - type: File
        outputBinding:
          glob: '*.gs.txt'
        id: _:vudnc2ocr-and-gs#gs
      - type: File
        outputBinding:
          glob: '*.ocr.txt'
        id: _:vudnc2ocr-and-gs#ocr
      id: _:vudnc2ocr-and-gs
    in:
      in_file: vudnc-select-files/out_files
    out:
    - gs
    - ocr
    scatter:
    - in_file
    scatterMethod: dotproduct
  remove-empty-files:
    run:
      cwlVersion: v1.0
      class: CommandLineTool

      baseCommand: [python, -m, ochre.remove_empty_files]

      requirements:
      - listing: |
          ${
            return inputs.ocr_files.concat(inputs.gs_files);
          }
        class: InitialWorkDirRequirement
      - {class: InlineJavascriptRequirement}

      arguments:
      - valueFrom: $(runtime.outdir)
        position: 1

      inputs:
      - type:

          type: array
          items: File
        id: _:remove-empty-files#gs_files
      - type:
          type: array
          items: File
        id: _:remove-empty-files#ocr_files
      stdout: cwl.output.json

      outputs:
      - type:
          type: array
          items: File
        id: _:remove-empty-files#gs
      - type:
          type: array
          items: File
        id: _:remove-empty-files#ocr
      id: _:remove-empty-files
    in:
      ocr_files: vudnc2ocr-and-gs/ocr
      gs_files: vudnc2ocr-and-gs/gs
    out:
    - gs
    - ocr
  save-files-to-dir-1:
    run:
      cwlVersion: v1.0
      class: ExpressionTool

      requirements:
      - class: InlineJavascriptRequirement

      inputs:
      - type: string
        id: _:save-files-to-dir-1#dir_name
      - type:
          type: array
          items: File
        id: _:save-files-to-dir-1#in_files
      outputs:
      - type: Directory
        id: _:save-files-to-dir-1#out
      expression: |
        ${
          return {"out": {
            "class": "Directory",
            "basename": inputs.dir_name,
            "listing": inputs.in_files
          } };
        }
      id: _:save-files-to-dir-1
    in:
      dir_name: gs_dir_name
      in_files: remove-empty-files/gs
    out:
    - out
  save-files-to-dir-2:
    run:
      cwlVersion: v1.0
      class: ExpressionTool

      requirements:
      - class: InlineJavascriptRequirement

      inputs:
      - type: string
        id: _:save-files-to-dir-2#dir_name
      - type:
          type: array
          items: File
        id: _:save-files-to-dir-2#in_files
      outputs:
      - type: Directory
        id: _:save-files-to-dir-2#out
      expression: |
        ${
          return {"out": {
            "class": "Directory",
            "basename": inputs.dir_name,
            "listing": inputs.in_files
          } };
        }
      id: _:save-files-to-dir-2
    in:
      dir_name: ocr_dir_name
      in_files: remove-empty-files/ocr
    out:
    - out
  count-chars:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.count_chars]

      inputs:
      - type: File
        inputBinding:
          position: 1

        id: _:count-chars#in_file
      outputs:
      - type: File
        outputBinding:
          glob: '*.json'
        id: _:count-chars#char_counts
      id: _:count-chars
    in:
      in_file: remove-empty-files/ocr
    out:
    - char_counts
    scatter:
    - in_file
    scatterMethod: dotproduct
  merge-json-2:
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
        id: _:merge-json-2#in_files
      - type:
        - 'null'
        - string
        inputBinding:
          prefix: --name=
          separate: false

        id: _:merge-json-2#name
      outputs:
      - type: File
        outputBinding:
          glob: '*.csv'
        id: _:merge-json-2#merged
      id: _:merge-json-2
    in:
      in_files: count-chars/char_counts
      name: ocr_n
    out:
    - merged
  count-chars-1:
    run:
      cwlVersion: v1.0
      class: CommandLineTool
      baseCommand: [python, -m, ochre.count_chars]

      inputs:
      - type: File
        inputBinding:
          position: 1

        id: _:count-chars-1#in_file
      outputs:
      - type: File
        outputBinding:
          glob: '*.json'
        id: _:count-chars-1#char_counts
      id: _:count-chars-1
    in:
      in_file: remove-empty-files/gs
    out:
    - char_counts
    scatter:
    - in_file
    scatterMethod: dotproduct
  merge-json-3:
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
        id: _:merge-json-3#in_files
      - type:
        - 'null'
        - string
        inputBinding:
          prefix: --name=
          separate: false

        id: _:merge-json-3#name
      outputs:
      - type: File
        outputBinding:
          glob: '*.csv'
        id: _:merge-json-3#merged
      id: _:merge-json-3
    in:
      in_files: count-chars-1/char_counts
      name: gs_n
    out:
    - merged
  align-texts-wf:
    run:
      cwlVersion: v1.0
      class: Workflow
      requirements:
      - class: ScatterFeatureRequirement
      inputs:
      - type:
        - 'null'
        - string
        id: _:align-texts-wf#align_c
      - type:
        - 'null'
        - string
        id: _:align-texts-wf#align_m
      - type:
          type: array
          items: File
        id: _:align-texts-wf#gs
      - type:
          type: array
          items: File
        id: _:align-texts-wf#ocr
      outputs:
      - type:
          items: File
          type: array
        outputSource: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#char-align/out_file
        id: _:align-texts-wf#alignments
      - type: File
        outputSource: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json-1/merged
        id: _:align-texts-wf#changes
      - type: File
        outputSource: file:///home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl#merge-json/merged
        id: _:align-texts-wf#metadata
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
      id: _:align-texts-wf
    in:
      align_m: align_m
      align_c: align_c
      ocr: remove-empty-files/ocr
      gs: remove-empty-files/gs
    out:
    - alignments
    - changes
    - metadata
  save-files-to-dir-3:
    run:
      cwlVersion: v1.0
      class: ExpressionTool

      requirements:
      - class: InlineJavascriptRequirement

      inputs:
      - type: string
        id: _:save-files-to-dir-3#dir_name
      - type:
          type: array
          items: File
        id: _:save-files-to-dir-3#in_files
      outputs:
      - type: Directory
        id: _:save-files-to-dir-3#out
      expression: |
        ${
          return {"out": {
            "class": "Directory",
            "basename": inputs.dir_name,
            "listing": inputs.in_files
          } };
        }
      id: _:save-files-to-dir-3
    in:
      dir_name: aligned_dir_name
      in_files: align-texts-wf/alignments
    out:
    - out
