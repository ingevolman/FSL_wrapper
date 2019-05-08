#!/bin/bash


# run randomise two-sample unpaired t-test

# initiate directories
mainDir=/vols/Scratch/ivolman/data_VC_work
#mkdir -p $mainDir/group/inputTwoSamp
roiDir=$mainDir/roi/avFreesurfer/
#model="ant_gammaHrfMov"
#model="fb_gammaHrfMov"
#model="gammaHrFMov_aPE"
model="gammaHrfMov"


# get the correct directory for the model
if [ ${model} == "gammaHrfMov" ]; then
  groupDir=$mainDir/group/BasicModel
  declare -a cope=("cope1")
fi

InputTwoSampDir=$groupDir/inputTwoSamp
if [ ! -d "$InputTwoSampDir" ]; then
  mkdir -p $InputTwoSampDir
fi

# run over copes to create a 4D image
for run in ${cope[@]}; do
  # first create 4D image with all images for selected COPE
  # exclude subject 117 as this is a movement outlier
  echo "prepare 4D image for model: ${model} - ${run}"
  fslmerge -t $InputTwoSampDir/TwoSamp4D${run} \
  $mainDir/101_F01/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/102_F02/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/104_F04/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/107_F07/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/108_F08/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/109_F09/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/112_F12/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/114_F14/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/115_F15/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/203_M03/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/205_M05/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/206_M06/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/210_M10/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/211_M11/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/213_M13/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/214_M14/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/218_M18/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/103_F03/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/105_F05/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/110_F10/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/111_F11/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/113_F13/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/116_F16/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/118_F18/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/119_F19/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/202_M02/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/204_M04/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/207_M07/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/208_M08/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/209_M09/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/212_M12/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/216_M16/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run} \
  $mainDir/217_M17/fMRI/feat.feat/${model}.feat/reg_standard/stats/${run}
done

# create design.mat
group1=({0..16}) # check using echo ${group1[@]}
group2=({17..32})
col1=($(for v in ${group1[@]}; do echo 1; done) ) # check length by echo "${#col1[@]}"
col1+=($(for v in ${group2[@]}; do echo 0; done) )
col2=($(for v in ${group1[@]}; do echo 0; done) ) # check length by echo "${#col1[@]}"
col2+=($(for v in ${group2[@]}; do echo 1; done) )
#  combine in two columns and save
printf "%s\n" "$(paste <(printf "%s\n" "${col1[@]}") <(printf "%s\n" "${col2[@]}") )" \
> $InputTwoSampDir/design.txt
# convert txt to mat
Text2Vest $InputTwoSampDir/design.txt $InputTwoSampDir/design.mat

# create design.con
declare -a con1=(1 1)
declare -a con2=(1 0)
declare -a con3=(-1 0)
declare -a con4=(0 1)
declare -a con5=(0 -1)
declare -a con6=(1 -1)
declare -a con7=(-1 1)

# combine and save
printf "%s\t%s\n" "${con1[@]}" "${con2[@]}" "${con3[@]}" "${con4[@]}" "${con5[@]}" \
"${con6[@]}" "${con7[@]}" > $InputTwoSampDir/contrasts.txt
# convert txt to con
Text2Vest $InputTwoSampDir/contrasts.txt $InputTwoSampDir/design.con

# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -T option means TFCE correction
RandDir=$groupDir/RandTwoSampCauNADilTFCE
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
for run in ${cope[@]}; do
  # run randomise with -1 for sign-flips for contrast over both groups and -d with design input
  # the input is the 4D image created above over all subjects and the output is saved in directory
  # mentioned after -o.
  # -T indicated TFCE correction
  echo "run randomise over all subjects within the caudate ACC mask for: ${model} - ${run}"
  randomise_parallel -i $InputTwoSampDir/TwoSamp4D${run} -o $RandDir/TwoSamp${run}T \
  -1 -d $InputTwoSampDir/design.mat -t $InputTwoSampDir/design.con -m $roiDir/CauNACC_dil -T
done

# run randomise on whole brain using grey matter mask
RandDir=$groupDir/RandTwoSampGMDilTFCE
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
for run in ${cope[@]}; do
  # run randomise with -1 for sign-flips for contrast over both groups and -d with design input
  # the input is the 4D image created above over all subjects and the output is saved in directory
  # mentioned after -o.
  # -T indicated TFCE correction
  echo "run randomise over all subjects within the grey matter mask for: ${model} - ${run}"
  randomise_parallel -i $InputTwoSampDir/TwoSamp4D${run} -o $RandDir/TwoSamp${run}T \
  -1 -d $InputTwoSampDir/design.mat -t $InputTwoSampDir/design.con -m $roiDir/GM_dil -T
done

# look at results

# for Basic model (gammaHrfMov)
if [ ${model} == "gammaHrfMov" ] ; then
  # investigate results COPE 1
  declare -a array=(1 3 5)
  RandDir=$groupDir/RandTwoSampCauNADilTFCE
  for i in ${array[@]}; do
    fslmaths $RandDir/TwoSampcope1T_tfce_corrp_tstat${i} -thr 0.95 -bin \
    -mul $RandDir/TwoSampcope1T_tstat${i} $RandDir/TwoSampcope1T_thresh_tstat${i}
    cluster --in=$RandDir/TwoSampcope1T_thresh_tstat${i} --thresh=0.0001 \
    --oindex=$RandDir/TwoSampcope1T_cluster_index${i} \
    --olmax=$RandDir/TwoSampcope1T_lmax${i}.txt \
    --osize=$RandDir/TwoSampcope1T_cluster_size${i} --mm
  done
  # extract values
  # first create binarised image of significant clusters
  fslmaths $RandDir/TwoSampcope1T_tfce_corrp_tstat5.nii.gz -thr 0.95 -bin \
  $RandDir/TwoSampcope1T_tfce_corrp_tstat5_0.95thr_bin
  # then extract the values using the 4D image of all subjects
  # this creates an average value over all voxels per subject.
  fslmeants -i $InputTwoSampDir/TwoSamp4Dcope1.nii.gz -m \
  $RandDir/TwoSampcope1T_tfce_corrp_tstat5_0.95thr_bin -o $RandDir/Values_TwoSampcope1T_tstats5.txt

  # investigate results COPE 3 in caudate mask
  declare -a array=(1 2 4)
  RandDir=$groupDir/RandTwoSampCauNADilTFCE
  for i in ${array[@]}; do
    fslmaths $RandDir/TwoSampcope3T_tfce_corrp_tstat${i} -thr 0.95 -bin \
    -mul $RandDir/TwoSampcope3T_tstat${i} $RandDir/TwoSampcope3T_thresh_tstat${i}
    cluster --in=$RandDir/TwoSampcope3T_thresh_tstat${i} --thresh=0.0001 \
    --oindex=$RandDir/TwoSampcope3T_cluster_index${i} \
    --olmax=$RandDir/TwoSampcope3T_lmax${i}.txt \
    --osize=$RandDir/TwoSampcope3T_cluster_size${i} --mm
  done
  # extract values
  # first create binarised image of significant clusters
  fslmaths $RandDir/TwoSampcope3T_tfce_corrp_tstat4.nii.gz -thr 0.95 -bin \
  $RandDir/TwoSampcope3T_tfce_corrp_tstat4_0.95thr_bin
  # then extract the values using the 4D image of all subjects
  # this creates an average value over all voxels per subject.
  fslmeants -i $InputTwoSampDir/TwoSamp4Dcope3.nii.gz -m \
  $RandDir/TwoSampcope3T_tfce_corrp_tstat4_0.95thr_bin -o $RandDir/Values_TwoSampcope3T_tstats4.txt


  # investigate results COPE 3 in GM mask
  declare -a array=(1)
  RandDir=$groupDir/RandTwoSampGMDilTFCE
  for i in ${array[@]}; do
    fslmaths $RandDir/TwoSampcope3T_tfce_corrp_tstat${i} -thr 0.95 -bin \
    -mul $RandDir/TwoSampcope3T_tstat${i} $RandDir/TwoSampcope3T_thresh_tstat${i}
    cluster --in=$RandDir/TwoSampcope3T_thresh_tstat${i} --thresh=0.0001 \
    --oindex=$RandDir/TwoSampcope3T_cluster_index${i} \
    --olmax=$RandDir/TwoSampcope3T_lmax${i}.txt \
    --osize=$RandDir/TwoSampcope3T_cluster_size${i} --mm
  done
fi


# get location clusters
#atlasquery -a "MNI Structural Atlas" -m "$RandDir/TwoSampCope1LitSubsetLithiumT_cluster_index3"
