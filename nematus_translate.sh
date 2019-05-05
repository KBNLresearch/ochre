#!/bin/bash
#
#SBATCH --job-name=nematus_translate
#SBATCH --output=nematus_translate_eng-mon_context.txt
#
#SBATCH --ntasks=1
#SBATCH -C TitanX
#SBATCH --gres=gpu:1

srun mkdir -p /var/scratch/jvdzwaan/nematus/
srun python ~/code/nematus/nematus/translate.py -m /var/scratch/jvdzwaan/nematus/model/model-120000 -i /home/jvdzwaan/data/nematus/test-eng_mon-context.ocr -o /var/scratch/jvdzwaan/nematus/test-eng_mon-context.pred
