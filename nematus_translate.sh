#!/bin/bash
#
#SBATCH --job-name=nematus_translate
#SBATCH --output=nematus_translate.txt
#
#SBATCH --ntasks=1
#SBATCH -C TitanX
#SBATCH --gres=gpu:1

srun mkdir -p /var/scratch/jvdzwaan/kb-ocr/A8P1/pred/
for filename in /var/scratch/jvdzwaan/kb-ocr/A8P1/test/*.ocr; do
  srun python ~/code/nematus/nematus/translate.py -m /var/scratch/jvdzwaan/kb-ocr/A8P1/model/model-40000 -i "$filename" -o /var/scratch/jvdzwaan/kb-ocr/A8P1/pred/"$(basename "$filename" .ocr).pred"
done
