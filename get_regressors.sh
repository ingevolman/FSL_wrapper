#!/bin/bash

# Get regressors for first level model
# this includes excessive movement outliers and WM & CSF timeseries

######### GENERAL ########################################################################################

# retrieve subject info from first command line argument (./$scriptDir/prep_run_feat_preproc ${run})
subj_id=$1
task=$2

# subject directory
subjDir=/vols/Scratch/ivolman/data_${task}_work/${subj_id}/fMRI
# HCP output subject directory
HCP_subjDir=/vols/Scratch/ivolman/data_MID_HCP_Struc/${subj_id}/T1w


######### Movement outliers ########################################################################################

# get movement outliers - ONLY ON problematic subjects
if [ "$task" == MID ]; then
  if [ "$subj_id" == 107_F07 ] || [ "$subj_id" == 109_F09 ] || \
  [ "$subj_id" == 116_F16 ] || [ "$subj_id" == 117_F17 ] || \
  [ "$subj_id" == 119_F19 ] || [ "$subj_id" == 217_M17 ]; then
    echo "run movement outlier script"
    fsl_motion_outliers -i ${subjDir}/${subj_id:0:3}_MID_restore_brain -o ${subjDir}/motion_outliers_dvars dvars
  else
    echo "no excessive movements - movement outlier script is not run"
  fi
elif [ "$task" == VC ]; then
  if [ "$subj_id" == 109_F09 ] || [ "$subj_id" == 117_F17 ] || \
  [ "$subj_id" == 207_M07 ] || [ "$subj_id" == 211_M11 ] || \
  [ "$subj_id" == 213_M13 ] || [ "$subj_id" == 217_M17 ]; then
    echo "run movement outlier script"
    fsl_motion_outliers -i ${subjDir}/${subj_id:0:3}_VC_restore_brain -o ${subjDir}/motion_outliers_dvars dvars
  else
    echo "no excessive movements - movement outlier script is not run"
  fi
fi


######### WM and CSF regressors ########################################################################################

## use HCP segmentation pipeline output
echo "get WM and CSF regressors using the output from the HCP segmentation pipeline"

# get inverse of acpc.mat
convert_xfm -omat $HCP_subjDir/xfms/acpc2highres.mat -inverse $HCP_subjDir/xfms/acpc.mat

if [ "$subj_id" == 101_F01 ] || [ "$subj_id" == 118_F18 ] || \
[ "$subj_id" == 218_M18 ] ; then
  # these subjects don't have example_func2highres_warp
  # so use the hihghres2example_func.mat instead
  applywarp --interp=nn --in=$HCP_subjDir/aparc+aseg.nii.gz --out=$subjDir/aparc+aseg_func.nii.gz \
    --ref=$subjDir/feat.feat/example_func.nii.gz --premat=$HCP_subjDir/xfms/acpc2highres.mat \
    --postmat=$subjDir/feat.feat/reg/highres2example_func.mat
else
  # get inverse of warp
  invwarp -w $subjDir/feat.feat/reg/example_func2highres_warp -o \
  $subjDir/feat.feat/reg/highres2example_func_warp -r $subjDir/feat.feat/reg/example_func
  # applywarp to bring to EPI space
  applywarp --interp=nn --in=$HCP_subjDir/aparc+aseg.nii.gz --out=$subjDir/aparc+aseg_func.nii.gz \
    --ref=$subjDir/feat.feat/example_func.nii.gz --premat=$HCP_subjDir/xfms/acpc2highres.mat \
    --warp=$subjDir/feat.feat/reg/highres2example_func_warp
fi

# create the masks for WM and CSF
fslmaths $subjDir/aparc+aseg_func.nii.gz -thr 2.0 -uthr 2.0 -bin $subjDir/WM_left.nii.gz
fslmaths $subjDir/aparc+aseg_func.nii.gz -thr 41.0 -uthr 41.0 -bin -add $subjDir/WM_left $subjDir/WM
rm -f $subjDir/WM_left

# CSF
fslmaths $subjDir/aparc+aseg_func.nii.gz -thr 24 -uthr 24 -bin $subjDir/CSF

# erode 1 voxel
fslmaths $subjDir/WM -ero $subjDir/WM_ero
fslmaths $subjDir/CSF -ero $subjDir/CSF_ero

# exclude the clusters that are very small, in order to only remain with one large cluster
cluster --in=$subjDir/WM_ero --thresh=0.5 --oindex=$subjDir/WM_ero_cl --minextent=100
fslmaths $subjDir/WM_ero_cl -thr 1 -uthr 2 -bin $subjDir/WM_ero_cl

# get the timeseries for covariates in first level model
fslmeants -i $subjDir/feat.feat/denoised_data -m $subjDir/WM_ero_cl -o $subjDir/feat.feat/WM_meants.txt
fslmeants -i $subjDir/feat.feat/denoised_data -m $subjDir/CSF_ero -o $subjDir/feat.feat/CSF_meants.txt
