#!/bin/bash
#
#SBATCH --job-name=2017_baseline
#SBATCH --output=2017_baseline.txt
#
#SBATCH --ntasks=1
#SBATCH -C TitanX
#SBATCH --time=15:00:00
#SBATCH --gres=gpu:1

module load python/3.5.2
module load python-extra/python3.5/r0.5.0
module load cuda80/toolkit/8.0.61
module load tensorflow/python3.x/gpu/r1.4.0-py3
module load keras/python3.5/r2.0.2
module load cuDNN/cuda80/5.1.5

srun python /home/jvdzwaan/code/ochre/2017_baseline.py
