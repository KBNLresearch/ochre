#!/bin/bash
#
#SBATCH --job-name=nematus_translate
#SBATCH --output=nematus_translate_eng-mon_context.txt
#
#SBATCH --ntasks=1
#SBATCH -C TitanX
#SBATCH --gres=gpu:1

for filename in /var/scratch/jvdzwaan/kb-ocr/sample-nematus-text_aligned_blocks-match_gs/sample-test/*.ocr; do
  echo python ~/code/nematus/nematus/translate.py -m /var/scratch/jvdzwaan/kb-ocr/sample-nematus-text_aligned_blocks-match_gs/model/model-110000 -i "$filename" -o /var/scratch/jvdzwaan/kb-ocr/sample-nematus-text_aligned_blocks-match_gs/pred/"$(basename "$filename" .ocr).pred"
done
