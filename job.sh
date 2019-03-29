#!/bin/bash
#
#SBATCH --job-name=2017_baseline
#SBATCH --output=2017_baseline.txt
#
#SBATCH --ntasks=1
#SBATCH -C TitanX
#SBATCH --time=15:00:00
#SBATCH --gres=gpu:1

srun python /home/jvdzwaan/code/ochre/2017_baseline.py
