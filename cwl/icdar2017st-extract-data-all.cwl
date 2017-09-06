#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: SubworkflowFeatureRequirement
inputs:
  in_dir1: Directory
  in_dir2: Directory
  in_dir3: Directory
  in_dir4: Directory
  ocr_dir_name: string
  gs_dir_name: string
  aligned_dir_name: string
outputs:
  gs1:
    type: Directory
    outputSource: save-dir-to-subdir/out
  gs2:
    type: Directory
    outputSource: save-dir-to-subdir-3/out
  gs3:
    type: Directory
    outputSource: save-dir-to-subdir-6/out
  gs4:
    type: Directory
    outputSource: save-dir-to-subdir-9/out
  ocr1:
    type: Directory
    outputSource: save-dir-to-subdir-1/out
  ocr2:
    type: Directory
    outputSource: save-dir-to-subdir-4/out
  ocr3:
    type: Directory
    outputSource: save-dir-to-subdir-7/out
  ocr4:
    type: Directory
    outputSource: save-dir-to-subdir-10/out
  aligned1:
    type: Directory
    outputSource: save-dir-to-subdir-11/out
  aligned2:
    type: Directory
    outputSource: save-dir-to-subdir-8/out
  aligned3:
    type: Directory
    outputSource: save-dir-to-subdir-5/out
  aligned4:
    type: Directory
    outputSource: save-dir-to-subdir-2/out
steps:
  icdar2017st-extract-data:
    run: /home/jvdzwaan/code/ocr/cwl/icdar2017st-extract-data.cwl
    in:
      aligned_dir_name: aligned_dir_name
      gs_dir_name: gs_dir_name
      in_dir: in_dir1
      ocr_dir_name: ocr_dir_name
    out:
    - aligned_dir
    - gs_dir
    - ocr_dir
  save-dir-to-subdir:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir1
      inner_dir: icdar2017st-extract-data/gs_dir
    out:
    - out
  save-dir-to-subdir-1:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir1
      inner_dir: icdar2017st-extract-data/ocr_dir
    out:
    - out
  save-dir-to-subdir-2:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir1
      inner_dir: icdar2017st-extract-data/aligned_dir
    out:
    - out
  icdar2017st-extract-data-1:
    run: /home/jvdzwaan/code/ocr/cwl/icdar2017st-extract-data.cwl
    in:
      aligned_dir_name: aligned_dir_name
      gs_dir_name: gs_dir_name
      in_dir: in_dir2
      ocr_dir_name: ocr_dir_name
    out:
    - aligned_dir
    - gs_dir
    - ocr_dir
  save-dir-to-subdir-3:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir2
      inner_dir: icdar2017st-extract-data-1/gs_dir
    out:
    - out
  save-dir-to-subdir-4:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir2
      inner_dir: icdar2017st-extract-data-1/ocr_dir
    out:
    - out
  save-dir-to-subdir-5:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir2
      inner_dir: icdar2017st-extract-data-1/aligned_dir
    out:
    - out
  icdar2017st-extract-data-2:
    run: /home/jvdzwaan/code/ocr/cwl/icdar2017st-extract-data.cwl
    in:
      aligned_dir_name: aligned_dir_name
      gs_dir_name: gs_dir_name
      in_dir: in_dir3
      ocr_dir_name: ocr_dir_name
    out:
    - aligned_dir
    - gs_dir
    - ocr_dir
  save-dir-to-subdir-6:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir3
      inner_dir: icdar2017st-extract-data-2/gs_dir
    out:
    - out
  save-dir-to-subdir-7:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir3
      inner_dir: icdar2017st-extract-data-2/ocr_dir
    out:
    - out
  save-dir-to-subdir-8:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir3
      inner_dir: icdar2017st-extract-data-2/aligned_dir
    out:
    - out
  icdar2017st-extract-data-3:
    run: /home/jvdzwaan/code/ocr/cwl/icdar2017st-extract-data.cwl
    in:
      aligned_dir_name: aligned_dir_name
      gs_dir_name: gs_dir_name
      in_dir: in_dir4
      ocr_dir_name: ocr_dir_name
    out:
    - aligned_dir
    - gs_dir
    - ocr_dir
  save-dir-to-subdir-9:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir4
      inner_dir: icdar2017st-extract-data-3/gs_dir
    out:
    - out
  save-dir-to-subdir-10:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir4
      inner_dir: icdar2017st-extract-data-3/ocr_dir
    out:
    - out
  save-dir-to-subdir-11:
    run: /home/jvdzwaan/code/nlppln/cwl/save-dir-to-subdir.cwl
    in:
      outer_dir: in_dir4
      inner_dir: icdar2017st-extract-data-3/aligned_dir
    out:
    - out
