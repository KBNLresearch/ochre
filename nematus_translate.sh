#!/bin/bash
#
#SBATCH --job-name=nematus_translate
#SBATCH --output=nematus_translate_kb-ocr-sample.txt
#
#SBATCH --ntasks=1
#SBATCH -C TitanX
#SBATCH --gres=gpu:1

for filename in /var/scratch/jvdzwaan/kb-ocr/sample-nematus-text_aligned_blocks-match_gs/test/*.ocr; do
  python ~/code/nematus/nematus/translate.py -m /var/scratch/jvdzwaan/kb-ocr/sample-nematus-text_aligned_blocks-match_gs/model/model-110000 -i "$filename" -o /var/scratch/jvdzwaan/kb-ocr/sample-nematus-text_aligned_blocks-match_gs/pred/"$(basename "$filename" .ocr).pred"
done
