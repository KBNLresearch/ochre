#!/bin/bash
#
#SBATCH --job-name=lstm_ocr_ad_512
#SBATCH --output=lstm_ocr_ad_512.txt
#
#SBATCH --ntasks=1
#SBATCH -C TitanX
#SBATCH --time=02:00:00
#SBATCH --gres=gpu:1

srun python ../../code/train_lstm.py ../ocr.txt ../gs.txt
