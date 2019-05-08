#!/bin/bash


# check the size of the caudate mask and whole brain grey matter mask.
# are they different between the two groups?


# create 4D images with all masks in order of groups
mainDir=/vols/Scratch/ivolman/data_MID_work
#mkdir -p $mainDir/group/inputTwoSamp
roiDir=$mainDir/roi/avFreesurfer/

# get masks of CSF, white matter in standard space. i had already calculated the GM in 'get_masks'
# run over participants
declare -a subj=( "101_F01" "102_F02" "103_F03" "104_F04" "105_F05" "107_F07" "108_F08" \
"109_F09" "110_F10" "111_F11" "112_F12" "113_F13" "114_F14" "115_F15" "116_F16" "117_F17" \
"118_F18" "119_F19" "202_M02" "203_M03" "204_M04" "205_M05" "206_M06" "207_M07" "208_M08" \
"209_M09" "210_M10" "211_M11" "212_M12" "213_M13" "214_M14" "216_M16" "217_M17" "218_M18")
for run in ${subj[@]}; do
  echo ${run}
  # subject directory
  subjDir=/vols/Scratch/ivolman/data_MID_work/${run}/fMRI
  # create the masks for WM - incl 251-255????
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 2.0 -uthr 2.0 -bin $subjDir/WM_standard_left.nii.gz
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 41.0 -uthr 41.0 -bin -add \
  $subjDir/WM_standard_left $subjDir/WM_standard
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 251.0 -uthr 255.0 -bin -add \
  $subjDir/WM_standard $subjDir/WM_standard
  rm -f $subjDir/WM_standard_left

  # CSF
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 24 -uthr 24 -bin $subjDir/CSF_standard
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 4 -uthr 4 -bin -add \
  $subjDir/CSF_standard $subjDir/CSF_standard
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 14 -uthr 14 -bin -add \
  $subjDir/CSF_standard $subjDir/CSF_standard
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 31 -uthr 31 -bin -add \
  $subjDir/CSF_standard $subjDir/CSF_standard
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 43 -uthr 43 -bin -add \
  $subjDir/CSF_standard $subjDir/CSF_standard
  fslmaths $subjDir/aparc+aseg_standard.nii.gz -thr 63 -uthr 63 -bin -add \
  $subjDir/CSF_standard $subjDir/CSF_standard
  # incl 4, 14, 31, 63 & 43??
done

# get amount of voxels as well as volume in
# initiate file with first participant
declare -a GM_size=$(fslstats $mainDir/101_F01/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/102_F02/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/104_F04/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/107_F07/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/108_F08/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/109_F09/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/112_F12/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/114_F14/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/115_F15/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/203_M03/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/205_M05/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/206_M06/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/210_M10/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/211_M11/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/213_M13/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/214_M14/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/218_M18/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/103_F03/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/105_F05/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/110_F10/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/111_F11/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/113_F13/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/116_F16/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/118_F18/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/119_F19/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/202_M02/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/204_M04/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/207_M07/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/208_M08/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/209_M09/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/212_M12/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/216_M16/fMRI/GM -V)
GM_size+=$(fslstats $mainDir/217_M17/fMRI/GM -V)

echo "$GM_size" > $mainDir/roi/GM_size.txt

declare -a WM_size=$(fslstats $mainDir/101_F01/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/102_F02/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/104_F04/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/107_F07/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/108_F08/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/109_F09/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/112_F12/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/114_F14/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/115_F15/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/203_M03/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/205_M05/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/206_M06/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/210_M10/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/211_M11/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/213_M13/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/214_M14/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/218_M18/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/103_F03/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/105_F05/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/110_F10/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/111_F11/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/113_F13/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/116_F16/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/118_F18/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/119_F19/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/202_M02/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/204_M04/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/207_M07/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/208_M08/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/209_M09/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/212_M12/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/216_M16/fMRI/WM_standard -V)
WM_size+=$(fslstats $mainDir/217_M17/fMRI/WM_standard -V)

echo "$WM_size" > $mainDir/roi/WM_size.txt

declare -a CSF_size=$(fslstats $mainDir/101_F01/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/102_F02/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/104_F04/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/107_F07/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/108_F08/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/109_F09/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/112_F12/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/114_F14/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/115_F15/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/203_M03/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/205_M05/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/206_M06/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/210_M10/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/211_M11/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/213_M13/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/214_M14/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/218_M18/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/103_F03/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/105_F05/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/110_F10/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/111_F11/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/113_F13/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/116_F16/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/118_F18/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/119_F19/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/202_M02/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/204_M04/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/207_M07/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/208_M08/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/209_M09/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/212_M12/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/216_M16/fMRI/CSF_standard -V)
CSF_size+=$(fslstats $mainDir/217_M17/fMRI/CSF_standard -V)

echo "$CSF_size" > $mainDir/roi/CSF_size.txt

declare -a CauNACC_size=$(fslstats $mainDir/101_F01/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/102_F02/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/104_F04/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/107_F07/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/108_F08/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/109_F09/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/112_F12/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/114_F14/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/115_F15/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/203_M03/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/205_M05/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/206_M06/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/210_M10/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/211_M11/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/213_M13/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/214_M14/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/218_M18/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/103_F03/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/105_F05/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/110_F10/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/111_F11/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/113_F13/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/116_F16/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/118_F18/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/119_F19/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/202_M02/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/204_M04/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/207_M07/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/208_M08/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/209_M09/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/212_M12/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/216_M16/fMRI/CauNACC -V)
CauNACC_size+=$(fslstats $mainDir/217_M17/fMRI/CauNACC -V)

echo "$CauNACC_size" > $mainDir/roi/CauNACC_size.txt
