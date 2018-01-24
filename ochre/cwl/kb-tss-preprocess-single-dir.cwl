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
      items: File
      type: array
    outputSource: ocr-transform/out_file
steps:
  ls-5:
    run: ls.cwl
    in:
      endswith: endswith
      in_dir: in_dir
      recursive: recursive
    out:
    - out_files
  remove-xml-elements:
    run: remove-xml-elements.cwl
    in:
      xml_file: ls-5/out_files
      element: element
    out:
    - out_file
    scatter:
    - xml_file
    scatterMethod: dotproduct
  ocr-transform:
    run: ocr-transform.cwl
    in:
      out_fmt: out_fmt
      in_file: remove-xml-elements/out_file
      in_fmt: in_fmt
    out:
    - out_file
    scatter:
    - in_file
    scatterMethod: dotproduct
