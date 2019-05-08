#!/bin/bash

# This script prepares data for preprocessing through feat, it prepares a feat.fsf
# file for the preprocessing and it runs that subject specific feat.fsf file.
# This script is written to be called by batch_script

######### GENERAL ########################################################################################

# retrieve subject & task info from first command line argument
# (./$scriptDir/prep_run_feat_preproc ${run})
subj_id=$1
task=$2
#$1 refers to the first command line argument, so if you typed ./batchFSL 103_F03
# into the command line then 103_F03 would be the value of subj_id.

# subject directory
subjDir=/vols/Scratch/ivolman/data_${task}_work/${subj_id}/fMRI


######### PREPARATIONS ########################################################################################

echo "prepare scans for further processing"

## ANATOMY

echo "brain extraction and bias correction of anatomy scan"

# brain extraction on anatomical images using BET (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide)
bet $subjDir/${subj_id:0:3}_anatomy.nii.gz $subjDir/${subj_id:0:3}_anatomy_brain.nii.gz

# bias correction using FAST - option -b outputs an estimated bias field
# Ref for publication: Zhang, Y. and Brady, M. and Smith, S. Segmentation of brain
# MR images through a hidden Markov random field model and the expectation-maximization
# algorithm. IEEE Trans Med Imag, 20(1):45-57, 2001.)
# make tmpDir to store all irrelevant output
tmpDir=$(mktemp -d $subjDir/tmp.fast.XXXXXXXX)
fast --type=1 -b --out=$tmpDir/output $subjDir/${subj_id:0:3}_anatomy_brain.nii.gz

# clean up
mv $tmpDir/output_bias.nii.gz $subjDir/ana_biasfield.nii.gz
rm -rf $tmpDir

# apply the bias field on the full bias-correct full image
fslmaths $subjDir/${subj_id:0:3}_anatomy -div $subjDir/ana_biasfield $subjDir/${subj_id:0:3}_anatomy_restore

# run a new brain extraction (BET) on the bias corrected output
bet $subjDir/${subj_id:0:3}_anatomy_restore.nii.gz $subjDir/${subj_id:0:3}_anatomy_restore_brain.nii.gz


## Functional

echo "brain extraction and bias correction of functional scan"

# brain extraction on anatomical images using BET (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide)
# -F This option uses bet2 to determine a brain mask on the basis of the first volume
# in a 4D data set, and applies this to the whole data set.
# This is principally intended for use on FMRI data, for example to remove eyeballs.
# Because it is normally important (in this application) that masking be liberal
# (ie that there be little risk of cutting out valid brain voxels) the -f threshold
# is reduced to 0.3, and also the brain mask is "dilated" slightly before being used.
bet $subjDir/${subj_id:0:3}_${task}.nii.gz $subjDir/${subj_id:0:3}_${task}_brain.nii.gz -F

# bias correction using FAST - option -b outputs an estimated bias field
# make tmpDir to store all irrelevant output
tmpDir=$(mktemp -d $subjDir/tmp.fast.XXXXXXXX)
fast --type=2 -b --out=$tmpDir/output $subjDir/${subj_id:0:3}_${task}_brain.nii.gz

# clean up
mv $tmpDir/output_bias.nii.gz $subjDir/func_biasfield.nii.gz
rm -rf $tmpDir

# apply the bias field on the full bias-correct full image
fslmaths $subjDir/${subj_id:0:3}_${task} -div $subjDir/func_biasfield $subjDir/${subj_id:0:3}_${task}_restore

# run a new brain extraction (BET) on the bias corrected output
bet $subjDir/${subj_id:0:3}_${task}_restore.nii.gz $subjDir/${subj_id:0:3}_${task}_restore_brain.nii.gz -F


## FIELDMAP

echo "brain extraction, bias correction and erosion of magnitude scan"

# brain extraction on magnitude fieldmaps using BET (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide)
bet $subjDir/${subj_id:0:3}_MagnitudeImage.nii.gz $subjDir/${subj_id:0:3}_MagnitudeImage_brain.nii.gz

# bias correction using FAST - option -b outputs an estimated bias field
# Ref for publication: Zhang, Y. and Brady, M. and Smith, S. Segmentation of brain MR
# images through a hidden Markov random field model and the expectation-maximization
# algorithm. IEEE Trans Med Imag, 20(1):45-57, 2001.)
# make tmpDir to store all irrelevant output
tmpDir=$(mktemp -d $subjDir/tmp.fast.XXXXXXXX)
fast --type=2 -b --out=$tmpDir/output $subjDir/${subj_id:0:3}_MagnitudeImage_brain.nii.gz

# clean up
mv $tmpDir/output_bias.nii.gz $subjDir/biasfield.nii.gz
rm -rf $tmpDir

# apply the bias field on the full bias-correct full image
fslmaths $subjDir/${subj_id:0:3}_MagnitudeImage -div $subjDir/biasfield $subjDir/${subj_id:0:3}_MagnitudeImage_restore

# run a new brain extraction (BET) on the bias corrected output
bet $subjDir/${subj_id:0:3}_MagnitudeImage_restore.nii.gz $subjDir/${subj_id:0:3}_MagnitudeImage_restore_brain.nii.gz

# erode the magnitude brain image by shaving of one voxel from each side
fslmaths $subjDir/${subj_id:0:3}_MagnitudeImage_restore_brain.nii.gz -ero $subjDir/${subj_id:0:3}_MagnitudeImage_restore_brain_ero.nii.gz

# create fieldmap images
echo "create fieldmap image"
fsl_prepare_fieldmap SIEMENS $subjDir/${subj_id:0:3}_PhaseImage.nii.gz $subjDir/${subj_id:0:3}_MagnitudeImage_restore_brain_ero.nii.gz \
$subjDir/${subj_id:0:3}_FMAP_RADS.nii.gz 2.46


######### PREPARE FEAT FILE ########################################################################################

echo "prepare feat template"

# subject specific feat changes
OUTDIR=$subjDir/feat
DATAFILE=${subjDir}/${subj_id:0:3}_${task}_restore_brain
TOTALVOL=$(fslnvols $DATAFILE)   # nr of total volumes of 4D file
FMAPRADS=${subjDir}/${subj_id:0:3}_FMAP_RADS
FMAPMAG=${subjDir}/${subj_id:0:3}_MagnitudeImage_restore_brain
ANATOMY=${subjDir}/${subj_id:0:3}_anatomy_restore_brain

# replace variable names in template.fsf with the actual subject specific indices.
for i in /vols/Scratch/ivolman/data_${task}_work/'template.fsf'; do
  sed -e 's@OUTDIR@'$OUTDIR'@g' \
   -e 's@TOTALVOL@'$TOTALVOL'@g' \
   -e 's@DATAFILE@'$DATAFILE'@g' \
   -e 's@FMAPRADS@'$FMAPRADS'@g' \
   -e 's@FMAPMAG@'$FMAPMAG'@g' \
   -e 's@ANATOMY@'$ANATOMY'@g' <$i> ${subjDir}/FEAT_${subj_id:0:3}.fsf
 done


######### RUN FEAT ########################################################################################

# run feat using the newly created fsf file
echo "run feat"
feat ${subjDir}/FEAT_${subj_id:0:3}.fsf


######### POST FEAT PROCESSING ########################################################################################

# prepare melodic report for visualisation
# align the melodic_IC file with the standard brain.
echo "prepare melodic report for visualisation"
melDir=$subjDir/feat.feat/filtered_func_data.ica
flirt -in $melDir/melodic_IC.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_2mm -out $melDir/melodic_flirted -applyxfm -init ${subjDir}/feat.feat/reg/example_func2standard.mat
