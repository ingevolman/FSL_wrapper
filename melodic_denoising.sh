#!/bin/bash

# this script processes the denoising based on melodic labelling

# retrieve subject info from first command line argument (./$scriptDir/prep_run_feat_preproc ${run})
subj_id=$1
task=$2

# relevant directory
featDir=/vols/Scratch/ivolman/data_${task}_work/${subj_id}/fMRI/feat.feat

# get list with melodic noise labels
# read the Melodic_labels file by running over the lines. Only the final line of the
# file is relevant and saved in 'name'.
while IFS='' read -r line || [[ -n "$line" ]]; do
    name="$line"
done < $featDir/Melodic_labels
# remove the brackets and white spaces from name and store this under label
label="$(echo -e "${name}" | sed 's/[][]//g' | tr -d '[:space:]')"
echo Noise components: $label

# check if there are noise components.
# if not, copy the filtered_func_data to denoised_data
# if yes, perform the denoising.
if [ -z "$label" ]; # if label is empty
then
  echo label is empty
  echo copy filtered_func_data to denoised_data variable
  cp $featDir/filtered_func_data.nii.gz $featDir/denoised_data.nii.gz
else # label is not empty
  # perform melodic denoising
  fsl_regfilt -i $featDir/filtered_func_data -o $featDir/denoised_data -d \
  $featDir/filtered_func_data.ica/melodic_mix -f "${label}"
fi
