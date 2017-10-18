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
    outputSource: merge-json/merged
  ocr_dir:
    type: Directory
    outputSource: save-files-to-dir-1/out
  gs_char_counts:
    type: File
    outputSource: merge-json-1/merged
  gs_dir:
    type: Directory
    outputSource: save-files-to-dir/out
  changes:
    type: File
    outputSource: align-texts-wf/changes
  metadata:
    type: File
    outputSource: align-texts-wf/metadata
  aligned_dir:
    type: Directory
    outputSource: save-files-to-dir-2/out
steps:
  vudnc-select-files:
    run: /home/jvdzwaan/code/ocr/cwl/vudnc-select-files.cwl
    in:
      in_dir: in_dir
    out:
    - out_files
  vudnc2ocr-and-gs:
    run: /home/jvdzwaan/code/ocr/cwl/vudnc2ocr-and-gs.cwl
    in:
      in_file: vudnc-select-files/out_files
    out:
    - gs
    - ocr
    scatter:
    - in_file
    scatterMethod: dotproduct
  remove-empty-files:
    run: /home/jvdzwaan/code/ocr/cwl/remove-empty-files.cwl
    in:
      ocr_files: vudnc2ocr-and-gs/ocr
      gs_files: vudnc2ocr-and-gs/gs
    out:
    - gs
    - ocr
  save-files-to-dir:
    run: /home/jvdzwaan/code/nlppln/cwl/save-files-to-dir.cwl
    in:
      dir_name: gs_dir_name
      in_files: remove-empty-files/gs
    out:
    - out
  save-files-to-dir-1:
    run: /home/jvdzwaan/code/nlppln/cwl/save-files-to-dir.cwl
    in:
      dir_name: ocr_dir_name
      in_files: remove-empty-files/ocr
    out:
    - out
  count-chars:
    run: /home/jvdzwaan/code/ocr/cwl/count-chars.cwl
    in:
      in_file: remove-empty-files/ocr
    out:
    - char_counts
    scatter:
    - in_file
    scatterMethod: dotproduct
  merge-json:
    run: /home/jvdzwaan/code/ocr/cwl/merge-json.cwl
    in:
      in_files: count-chars/char_counts
      name: ocr_n
    out:
    - merged
  count-chars-1:
    run: /home/jvdzwaan/code/ocr/cwl/count-chars.cwl
    in:
      in_file: remove-empty-files/gs
    out:
    - char_counts
    scatter:
    - in_file
    scatterMethod: dotproduct
  merge-json-1:
    run: /home/jvdzwaan/code/ocr/cwl/merge-json.cwl
    in:
      in_files: count-chars-1/char_counts
      name: gs_n
    out:
    - merged
  align-texts-wf:
    run: /home/jvdzwaan/code/ocr/cwl/align-texts-wf.cwl
    in:
      align_m: align_m
      align_c: align_c
      ocr: remove-empty-files/ocr
      gs: remove-empty-files/gs
    out:
    - alignments
    - changes
    - metadata
  save-files-to-dir-2:
    run: /home/jvdzwaan/code/nlppln/cwl/save-files-to-dir.cwl
    in:
      dir_name: aligned_dir_name
      in_files: align-texts-wf/alignments
    out:
    - out
