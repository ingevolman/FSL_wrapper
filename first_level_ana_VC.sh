#!/bin/bash

# First level model

# first model without motion regressors, only the extreme motion and WM is
# included. Later- check if motion regressors have an effect.

# These feat analysis includes FILM prewhitening (standard), WM confound EVs
# and motion outliers if present, temporal derivative (standard)
# head motion parameters are not included. If I do decide to include it at
# some point: check for correlations with task.

######### GENERAL ##############################################################

# retrieve subject info from first command line argument
# (./$scriptDir/prep_run_feat_preproc ${run})
subj_id=$1
ana=$2
# $1 refers to the first command line argument, so if you typed ./XXX 101_F01
# into the command line then 101_F01 would be the value of subj_id.

# subject and feat directory
subjDir=/vols/Scratch/ivolman/data_VC_work/${subj_id}/fMRI
featDir=${subjDir}/feat.feat


######### prepare FEAT ######################################################

echo "prepare feat template for first level analysis"

# subject specific denoised data based on Melodic denoising.
DATAFILE=${featDir}/denoised_data
# Get nr of total volumes of 4D file
TOTALVOL=$(fslnvols $DATAFILE)

# prepare confound file
# first check if motion parameters need to be added
# WM time series are always added
if [ "$ana" == gammaHrfMov ] ;
then
  echo "combining motion parameters and WM time series into confound EV"
  paste ${featDir}/WM_meants.txt ${featDir}/mc/*.par > ${featDir}/confoundEVs.txt
else
  echo "using WM time series as confound EV"
  paste ${featDir}/WM_meants.txt > ${featDir}/confoundEVs.txt
fi
# check if the participant was classified with excessive motion and include the
# results from the motion outlier detection script here as well.
if [ "$subj_id" == 109_F09 ] || [ "$subj_id" == 117_F17 ] || \
[ "$subj_id" == 207_M07 ] || [ "$subj_id" == 211_M11 ] || \
[ "$subj_id" == 213_M13 ] || [ "$subj_id" == 217_M17 ]; then
  echo "participant with excessive motion"
  echo "combine the confound EV with the motion outlier file"
  paste ${featDir}/confoundEVs.txt ${subjDir}/motion_outliers_dvars > ${featDir}/temp.txt
  # rename the new list to confoundEVs
  mv ${featDir}/temp.txt ${featDir}/confoundEVs.txt
  echo "and use this combined EV file as confound EVs file"
fi

# create input variables for .fsf
CONFOUNDEV=${featDir}/confoundEVs.txt
if [ "$ana" == gammaHrfMov ];
then
  FILEFIX=${subjDir}/task/featRegrFixation.txt
  FILECHECK=${subjDir}/task/featRegrCheckerboard.txt
fi

# fill template
# get the template
#if [ "$ana" == gammaHrfMov ] ;then
  template=/vols/Scratch/ivolman/data_VC_work/'templateFirstLevelHRF.fsf'
#else
#  template=/vols/Scratch/ivolman/data_VC_work/'templateFirstLevel.fsf'
#fi
echo "using ${template}"
# replace variable names in templateFirstLevel.fsf with subject specific data
for i in ${template}; do
  sed -e 's@DATAFILE@'$DATAFILE'@g' \
  -e 's@TOTALVOL@'$TOTALVOL'@g' \
  -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
  -e 's@FILEFIX@'$FILEFIX'@g' \
  -e 's@FILECHECK@'$FILECHECK'@g' \
  <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
done


######### run FEAT ######################################################

echo "run first level analysis in feat"
# run feat using the newly created fsf file
feat ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
