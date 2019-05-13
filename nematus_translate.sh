#!/bin/bash
#
#SBATCH --job-name=nematus_translate
#SBATCH --output=nematus_translate_eng-mon_context.txt
#
#SBATCH --ntasks=1
#SBATCH -C TitanX
#SBATCH --gres=gpu:1

inputdir = /var/scratch/jvdzwaan/kb-ocr/sample-nematus-text_aligned_blocks-match_gs/sample-test/
modelfile = /var/scratch/jvdzwaan/kb-ocr/sample-nematus-text_aligned_blocks-match_gs/model/model-110000
outputdir = /var/scratch/jvdzwaan/kb-ocr/sample-nematus-text_aligned_blocks-match_gs/pred

for filename in "$inputdir"/*.ocr; do
  echo	srun python ~/code/nematus/nematus/translate.py -m "$modelfile" -i "$filename" -o "$outputdir/$(basename "$filename" .ocr).pred"
done
