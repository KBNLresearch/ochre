#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
inputs:
  data_file: File
  ocr_dir_name:
    default: ocr
    type: string
  gs_dir_name:
    default: gs
    type: string
  de_dir_name:
    default: de
    type: string
  fr_dir_name:
    default: fr
    type: string
outputs:
  ocr_de:
    type: Directory
    outputSource: save-dir-to-subdir/out
  gs_de:
    type: Directory
    outputSource: save-dir-to-subdir-1/out
  ocr_fr:
    type: Directory
    outputSource: save-dir-to-subdir-2/out
  gs_fr:
    type: Directory
    outputSource: save-dir-to-subdir-3/out
steps:
  tar:
    run: tar.cwl
    in:
      in_file: data_file
    out:
    - out
  sac2gs-and-ocr:
    run: sac2gs-and-ocr.cwl
    in:
      in_dir: tar/out
    out:
    - gs_de
    - gs_fr
    - ocr_de
    - ocr_fr
  mkdir:
    run: mkdir.cwl
    in:
      dir_name: de_dir_name
    out:
    - out
  mkdir-1:
    run: mkdir.cwl
    in:
      dir_name: fr_dir_name
    out:
    - out
  save-files-to-dir-9:
    run: save-files-to-dir.cwl
    in:
      dir_name: ocr_dir_name
      in_files: sac2gs-and-ocr/ocr_de
    out:
    - out
  save-dir-to-subdir:
    run: save-dir-to-subdir.cwl
    in:
      outer_dir: mkdir/out
      inner_dir: save-files-to-dir-9/out
    out:
    - out
  save-files-to-dir-10:
    run: save-files-to-dir.cwl
    in:
      dir_name: gs_dir_name
      in_files: sac2gs-and-ocr/gs_de
    out:
    - out
  save-dir-to-subdir-1:
    run: save-dir-to-subdir.cwl
    in:
      outer_dir: mkdir/out
      inner_dir: save-files-to-dir-10/out
    out:
    - out
  save-files-to-dir-11:
    run: save-files-to-dir.cwl
    in:
      dir_name: ocr_dir_name
      in_files: sac2gs-and-ocr/ocr_fr
    out:
    - out
  save-dir-to-subdir-2:
    run: save-dir-to-subdir.cwl
    in:
      outer_dir: mkdir-1/out
      inner_dir: save-files-to-dir-11/out
    out:
    - out
  save-files-to-dir-12:
    run: save-files-to-dir.cwl
    in:
      dir_name: gs_dir_name
      in_files: sac2gs-and-ocr/gs_fr
    out:
    - out
  save-dir-to-subdir-3:
    run: save-dir-to-subdir.cwl
    in:
      outer_dir: mkdir-1/out
      inner_dir: save-files-to-dir-12/out
    out:
    - out
