#!/bin/bash

#Will delete all old stuff everywhere.
sbatch -p mghpcc-compute -w "compute-m7c1-0-3"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
sbatch -p mghpcc-compute -w "compute-m7c1-0-4"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
#sbatch -p mghpcc-compute -w "compute-m7c1-0-5"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
sbatch -p mghpcc-compute -w "compute-m7c1-0-6"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
sbatch -p mghpcc-compute -w "compute-m7c1-0-7"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
sbatch -p mghpcc-short -w "compute-m7c1-0-8"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
sbatch -p mghpcc-short -w "compute-m7c1-0-9"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
sbatch -p mghpcc-short -w "compute-m7c1-0-10"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
sbatch -p mghpcc-short -w "compute-m7c1-0-11"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
sbatch -p mghpcc-gpu -w "gpu-m7c1-0-1"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh
#Will delete all old stuff everywhere.
sbatch -p mghpcc-gpu -w "gpu-m7c1-0-2"  -n 1 -c 1  --mem=1MB /project/Path-Steen/Patrick/MGHPCC/deleteScript.sh

rm /project/Path-steen/Patrick/MGHPCC/slurm*.out