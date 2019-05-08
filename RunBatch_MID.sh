#!/bin/env bash

# This script contains example code to use the HCP Pipelines for processing
# of structural images following the OxfordStructural fork.
#
# The HCP Pipelines come with their own set of Examples (in the
# Pipelines/Examples/Scripts folder). They contain three *Batch.sh scripts
# for Pre-, FreeSurfer-, and Post- processing of structural images. This
# scripts contains example code to run the three structural processing batches.
#
# the order of the HCP pipeline is:
# PreFreeSurfer —> FreeSurfer —> PostFreeSurfer
#   |—> fMRIVolume (not used) —> fMRISurface(not used) —> ICA+FIX (not used)
#  (|-> CleanupFunctionalPipelineBatch, frees up a lot of space)
#   |—> DiffusionPreprocessing (not used) —> BedpostX (not used)
#  (|-> CleanupStructuralPipelineBatch, mostly cosmetic)

# @ obtained from Lennart Verhagen

# specify the data
StudyFolder=~/scratch/data_MID_HCP_Struc
#SubjList="101_F01 102_F02 103_F03 104_F04 105_F05 107_F07 108_F08 109_F09 110_F10 111_F11 112_F12 113_F13 114_F14 115_F15
#116_F16 117_F17 118_F18 119_F19 202_M02 203_M03 204_M04 205_M05 206_M06 207_M07 208_M08 209_M09 210_M10 211_M11 212_M12
#213_M13 214_M14 216_M16 217_M17 218_M18"
SubjList="102_F02 103_F03 104_F04 105_F05 107_F07 108_F08 109_F09 110_F10 111_F11 112_F12 113_F13
114_F14 115_F15 116_F16 117_F17 118_F18 119_F19 202_M02 203_M03 204_M04 205_M05 206_M06 207_M07
208_M08 209_M09 210_M10 211_M11 212_M12 213_M13 214_M14 216_M16 217_M17 218_M18"
Scanner="3T"

# specify the task
Task="CLEANSTRUCT"  # "PRE" "FREE" "POST" "CLEANSTRUCT"

# specify the batch scripts folder
#export HCPPIPEDIR=~/code/HCP-pipelines
export HCPPIPEDIR=/vols/Data/daa/scripts/HCP-pipelines
BatchFolder=$HCPPIPEDIR/Examples/Scripts

# retrieve the current folder
THISDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#THISDIR=${ORCADIR}/project/modConn
#BatchFolder=$THISDIR

# replace spaces by "@"
SubjListSafe="${SubjList// /@}"

# run the "PRE-FREESURFER" task
if [[ $Task = "PRE" ]] ; then
  ${THISDIR}/PreFreeSurferPipelineBatch_MID.sh \
    --StudyFolder="$StudyFolder" \
    --SubjList="$SubjListSafe"
fi

# run the "FREESURFER" task
if [[ $Task = "FREE" ]] ; then
  $BatchFolder/FreeSurferPipelineBatch.sh \
    --StudyFolder="$StudyFolder" \
    --SubjList="$SubjListSafe"
  # you could add the "--noT2w" option to enforce skipping T2w image
  # processing, but if these images do not exist it will detect so
  # automatically.
fi

# run the "POST-FREESURFER" task
if [[ $Task = "POST" ]] ; then
  $BatchFolder/PostFreeSurferPipelineBatch.sh \
    --StudyFolder="$StudyFolder" \
    --SubjList="$SubjListSafe"
fi

# run the "CLEAN-UP STRUCT" task
if [[ $Task = "CLEANSTRUCT" ]] ; then
  $BatchFolder/CleanupStructuralPipelineBatch.sh \
    --StudyFolder="$StudyFolder" \
    --SubjList="$SubjListSafe"
fi
