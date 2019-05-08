#!/bin/bash

## get masks in standard or functional space
# create group mask
# run group level feat

######### GENERAL ########################################################################################

## declare an array variable of the participants
# example of all participants excluding outlier 117
declare -a subj=("101_F01" "102_F02" "103_F03" "104_F04" "105_F05" "107_F07" "108_F08" \
"109_F09" "110_F10" "111_F11" "112_F12" "113_F13" "114_F14" "115_F15" "116_F16" \
"118_F18" "119_F19" "202_M02" "203_M03" "204_M04" "205_M05" "206_M06" "207_M07" "208_M08" \
"209_M09" "210_M10" "211_M11" "212_M12" "213_M13" "214_M14" "216_M16" "217_M17" "218_M18")
# selection for current analysis
#declare -a subj=("101_F01")


# run over all selected subjects
for subj_id in ${subj[@]}; do
  echo ${subj_id}

  # subject directory
  subjDir=/vols/Scratch/ivolman/data_MID_work/${subj_id}/fMRI
  # HCP output subject directory
  HCP_subjDir=/vols/Scratch/ivolman/data_MID_HCP_Struc/${subj_id}/T1w

<<COMMENT
# select the function you want to run from the code below

  # applywarp to bring to standard space
  applywarp --interp=nn --in=$HCP_subjDir/aparc+aseg.nii.gz \
  --out=$subjDir/aparc+aseg_standard.nii.gz --ref=$subjDir/feat.feat/reg/standard.nii.gz \
  --premat=$HCP_subjDir/xfms/acpc2highres.mat \
  --warp=$subjDir/feat.feat/reg/highres2standard_warp

  # create the masks for caudate  by selecting relevant parts of aparc+aseg_standard
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 11.0 -uthr 11.0 -bin \
  $subjDir/Caudate.nii.gz
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 50.0 -uthr 50.0 -bin -add \
  $subjDir/Caudate $subjDir/Caudate

  # create the masks for caudate & NACC
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 11.0 -uthr 11.0 -bin \
  $subjDir/CauNACC.nii.gz
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 26.0 -uthr 26.0 -bin -add \
  $subjDir/CauNACC $subjDir/CauNACC
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 50.0 -uthr 50.0 -bin -add \
  $subjDir/CauNACC $subjDir/CauNACC
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 58.0 -uthr 58.0 -bin -add \
  $subjDir/CauNACC $subjDir/CauNACC
COMMENT

  # create the masks for NACC by selecting relevant parts of aparc+aseg_standard
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 26.0 -uthr 26.0 -bin \
  $subjDir/NACC.nii.gz
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 58.0 -uthr 58.0 -bin -add \
  $subjDir/NACC $subjDir/NACC
  # dilate 1 voxel in standard space (2mm)
  fslmaths $subjDir/NACC -kernel sphere 2 -dilF $subjDir/NACC_dil

<<COMMENT
  # create grey matter mask
    #left subcortical
    fslmaths $subjDir/aparc+aseg_standard -thr 3 -uthr 3 -bin $subjDir/GM
    fslmaths $subjDir/aparc+aseg_standard -thr 9 -uthr 13 -bin $subjDir/GM
    fslmaths $subjDir/aparc+aseg_standard -thr 17 -uthr 20 -add $subjDir/GM -bin $subjDir/GM
    fslmaths $subjDir/aparc+aseg_standard -thr 25 -uthr 27 -add $subjDir/GM -bin $subjDir/GM
    fslmaths $subjDir/aparc+aseg_standard -thr 29 -uthr 29 -add $subjDir/GM -bin $subjDir/GM
    fslmaths $subjDir/aparc+aseg_standard -thr 32 -uthr 39 -add $subjDir/GM -bin $subjDir/GM
    ### left GM
    fslmaths $subjDir/aparc+aseg_standard -thr 1000 -uthr 1999 -add $subjDir/GM -bin $subjDir/GM
    ### right subcortical
    fslmaths $subjDir/aparc+aseg_standard -thr 42 -uthr 42 -add $subjDir/GM -bin $subjDir/GM
    fslmaths $subjDir/aparc+aseg_standard -thr 48 -uthr 56 -add $subjDir/GM -bin $subjDir/GM
    fslmaths $subjDir/aparc+aseg_standard -thr 58 -uthr 59 -add $subjDir/GM -bin $subjDir/GM
    fslmaths $subjDir/aparc+aseg_standard -thr 61 -uthr 61 -add $subjDir/GM -bin $subjDir/GM
    fslmaths $subjDir/aparc+aseg_standard -thr 64 -uthr 71 -add $subjDir/GM -bin $subjDir/GM
    ## right GM
    fslmaths $subjDir/aparc+aseg_standard -thr 2000 -uthr 2999 -add $subjDir/GM -bin $subjDir/GM

    # dilate 1 voxel in standard space (2mm)
    fslmaths $subjDir/GM -kernel sphere 2 -dilF $subjDir/GM_dil

COMMENT

done


# Create average mask across participants

# overall directory
mainDir=/vols/Scratch/ivolman/data_MID_work

## CAUDATE/ NAcc
# general mask directory
roiDir=$mainDir/roi/avFreesurfer
# add masks of all subjects and divide by the number of subjects
# start with creating mask based on first subject
fslmaths $mainDir/${subj[0]}/fMRI/CauNACC $roiDir/CauNACC
# loop over remaining subjects and add their respective masks
for ((i = 1; i < ${#subj[@]}; i++)); do
  echo ${subj[i]}
  fslmaths $roiDir/CauNACC -add $mainDir/${subj[i]}/fMRI/CauNACC $roiDir/CauNACC
done
# average by dividing by the length of subj
fslmaths $roiDir/CauNACC.nii.gz -div ${#subj[@]} $roiDir/CauNACC.nii.gz
# binarise mask
fslmaths $roiDir/CauNACC.nii.gz -thr 0.3 -bin $roiDir/CauNACC.nii.gz
# and dilate 1 voxel of 2mm
fslmaths $roiDir/CauNACC.nii.gz -kernel sphere 2 -dilF $roiDir/CauNACC_dil.nii.gz


## NAcc mask
# general mask directory
roiDir=$mainDir/roi/avFreesurfer
# add masks of all subjects and divide by the number of subjects
# start with creating mask based on first subject
fslmaths $mainDir/${subj[0]}/fMRI/NACC_dil $roiDir/NACC_dil
# loop over remaining subjects and add their respective masks
for ((i = 1; i < ${#subj[@]}; i++)); do
  echo ${subj[i]}
  fslmaths $roiDir/NACC_dil -add $mainDir/${subj[i]}/fMRI/NACC_dil $roiDir/NACC_dil
done
# average by dividing by the length of subj
fslmaths $roiDir/NACC_dil.nii.gz -div ${#subj[@]} $roiDir/NACC_dil.nii.gz
# binarise mask
fslmaths $roiDir/NACC_dil.nii.gz -thr 0.3 -bin $roiDir/NACC_dil.nii.gz
# dilate & erode to fill the holes. The single subject mask was already dilated
# so no need to keep the additional dilation here.
fslmaths $roiDir/NACC_dil.nii.gz -kernel sphere 2 -dilF -ero $roiDir/NACC_dil.nii.gz


## GM mask
# general mask directory
roiDir=$mainDir/roi/avFreesurfer
# add masks of all subjects and divide by the number of subjects
# start with creating mask based on first subject
fslmaths $mainDir/${subj[0]}/fMRI/GM_dil $roiDir/GM_dil
# loop over remaining subjects and add their respective masks
for ((i = 1; i < ${#subj[@]}; i++)); do
  echo ${subj[i]}
  fslmaths $roiDir/GM_dil -add $mainDir/${subj[i]}/fMRI/GM_dil $roiDir/GM_dil
done
# average by dividing by the length of subj
fslmaths $roiDir/GM_dil.nii.gz -div ${#subj[@]} $roiDir/GM_dil.nii.gz
# binarise mask
fslmaths $roiDir/GM_dil.nii.gz -thr 0.3 -bin $roiDir/GM_dil.nii.gz
# dilate & erode to fill the holes. The single subject mask was already dilated
# so no need to keep the additional dilation here.
fslmaths $roiDir/GM_dil.nii.gz -kernel sphere 2 -dilF -ero $roiDir/GM_dil.nii.gz


## AVERAGE T1
# general mask directory
groupDir=$mainDir/group
# add masks of all subjects and divide by the number of subjects
# start with creating mask based on first subject
fslmaths $mainDir/${subj[0]}/fMRI/feat.feat/reg/highres2standard $groupDir/highres2standard
# loop over remaining subjects and add their respective masks
for ((i = 1; i < ${#subj[@]}; i++)); do
  echo ${subj[i]}
  fslmaths $groupDir/highres2standard -add $mainDir/${subj[i]}/fMRI/feat.feat/reg/highres2standard \
  $groupDir/highres2standard
done
# average by dividing by the length of subj
fslmaths $groupDir/highres2standard.nii.gz -div ${#subj[@]} $groupDir/highres2standard.nii.gz
