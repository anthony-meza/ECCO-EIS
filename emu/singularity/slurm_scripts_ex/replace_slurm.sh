#!/bin/bash -e

# Move to parent directory
cd ..

# Create backup directory if it doesn't exist
mkdir -p pbs_backup

# Copy all files starting with "pbs" into pbs_backup
cp pbs* pbs_backup/

# Copy all files starting with "pbs" in slurm_scripts_ex 
# to primary directory 
cp ./slurm_scripts_ex/pbs*.sh. 

#run emu_env, which will configure most of the slurms scripts
#with the correct directories
./emu_env.sh

echo "To complete setup, specify wallhours and nodes (see README for more)"
