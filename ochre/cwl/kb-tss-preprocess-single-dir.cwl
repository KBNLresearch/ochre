#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
- class: ScatterFeatureRequirement
inputs:
  in_dir: Directory
  recursive:
    default: true
    type: boolean
  endswith:
    default: alto.xml
    type: string
  element:
    default:
    - SP
    type: string[]
  in_fmt:
    default: alto
    type: string
  out_fmt:
    default: text
    type: string
outputs:
  text_files:
    type:
      type: array
      items: File
    outputSource: kb-tss-concat-files/out_files
steps:
  ls:
    run: ls.cwl
    in:
      endswith: endswith
      in_dir: in_dir
      recursive: recursive
    out:
    - out_files
  remove-xml-elements-1:
    run: remove-xml-elements.cwl
    in:
      xml_file: ls/out_files
      element: element
    out:
    - out_file
    scatter:
    - xml_file
    scatterMethod: dotproduct
  ocr-transform-1:
    run: ocr-transform.cwl
    in:
      out_fmt: out_fmt
      in_file: remove-xml-elements-1/out_file
      in_fmt: in_fmt
    out:
    - out_file
    scatter:
    - in_file
    scatterMethod: dotproduct
  kb-tss-concat-files:
    run: kb-tss-concat-files.cwl
    in:
      in_files: ocr-transform-1/out_file
    out:
    - out_files
