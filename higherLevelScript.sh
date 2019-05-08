#!/bin/bash


# run randomise two-sample unpaired t-test

# initiate directories
mainDir=/vols/Scratch/ivolman/data_MID_work
#mkdir -p $mainDir/group/inputTwoSamp
roiDir=$mainDir/roi/avFreesurfer/
#model="ant_gammaHrfMov"
#model="fb_gammaHrfMov"
#model="gammaHrFMov_aPE"
model="gammaHrfMov_REPE"


# get the correct directory for the model
if [ ${model} == "gammaHrfMov" ]; then
  groupDir=$mainDir/group/BasicModel
  declare -a cope=("cope1" "cope3")
elif [ ${model} == "ant_gammaHrfMov" ]; then
  groupDir=$mainDir/group/Anticipation
  declare -a cope=("cope1" "cope2")
elif [ ${model} == "fb_gammaHrfMov" ]; then
  groupDir=$mainDir/group/Feedback_HitLoss
  declare -a cope=("cope1" "cope2")
elif [ ${model} == "onlyRE_PE_gammaHrfMov" ]; then
  groupDir=$mainDir/group/OnlyRE_PE
  declare -a cope=("cope1" "cope2")
elif [ ${model} == "gammaHrFMov_aPE" ] ; then
  groupDir=$mainDir/group/BasicModel_WithaPE
  declare -a cope=("cope1" "cope2" "cope3")
elif [ ${model} == "gammaHrfMov_REPE" ] ; then
  groupDir=$mainDir/group/BasicModel_REPE
  declare -a cope=("cope1" "cope2" "cope3")
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

# for onlyRE_PE_gammaHrfMov model
if [ ${model} == "onlyRE_PE_gammaHrfMov" ]; then
  # investigate results COPE 2 in caudate mask
  declare -a array=(1 2 4)
  RandDir=$groupDir/RandTwoSampCauNADilTFCE
  for i in ${array[@]}; do
    fslmaths $RandDir/TwoSampcope2T_tfce_corrp_tstat${i} -thr 0.95 -bin \
    -mul $RandDir/TwoSampcope2T_tstat${i} $RandDir/TwoSampcope2T_thresh_tstat${i}
    cluster --in=$RandDir/TwoSampcope2T_thresh_tstat${i} --thresh=0.0001 \
    --oindex=$RandDir/TwoSampcope2T_cluster_index${i} \
    --olmax=$RandDir/TwoSampcope2T_lmax${i}.txt \
    --osize=$RandDir/TwoSampcope2T_cluster_size${i} --mm
  done
  # extract values
  # first create binarised image of significant clusters
  fslmaths $RandDir/TwoSampcope2T_tfce_corrp_tstat4.nii.gz -thr 0.95 -bin \
  $RandDir/TwoSampcope2T_tfce_corrp_tstat4_0.95thr_bin
  # then extract the values using the 4D image of all subjects
  # this creates an average value over all voxels per subject.
  fslmeants -i $InputTwoSampDir/TwoSamp4Dcope2.nii.gz -m \
  $RandDir/TwoSampcope2T_tfce_corrp_tstat4_0.95thr_bin -o $RandDir/Values_TwoSampcope2T_tstats4.txt

fi

# for gammaHrfMov_REPE model
if [ ${model} == "gammaHrfMov_REPE" ]; then
  # investigate results COPE 3 in caudate mask (PE effect)
  declare -a array=(2 6) # contasts for positive Placebo and Placebo > Lithium
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
  fslmaths $RandDir/TwoSampcope3T_tfce_corrp_tstat6.nii.gz -thr 0.95 -bin \
  $RandDir/TwoSampcope3T_tfce_corrp_tstat6_0.95thr_bin
  # then extract the values using the 4D image of all subjects
  # this creates an average value over all voxels per subject.
  fslmeants -i $InputTwoSampDir/TwoSamp4Dcope3.nii.gz -m \
  $RandDir/TwoSampcope3T_tfce_corrp_tstat6_0.95thr_bin -o $RandDir/Values_TwoSampcope3T_tstats6.txt

fi

# get location clusters
#atlasquery -a "MNI Structural Atlas" -m "$RandDir/TwoSampCope1LitSubsetLithiumT_cluster_index3"



#####Lithium Levels subset#############################################
# analyses on subset of the data for which lithium levels are available
# (just one is missing..)

## get subset including only people from whom we have lithium values
# run over copes to create a 4D image
for run in ${cope[@]}; do
  # first create 4D image with all images for selected COPE
  # exclude subject 117 as this is a movement outlier
  echo "prepare 4D image on subjects with lithium values for model: ${model} - ${run}"
  fslmerge -t $InputTwoSampDir/TwoSamp4D${run}LitSubset \
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
  # excluded
  # lithium group
  #$mainDir/105_F05/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope1 \
done

## create design.mat for subset
#group1=({0..16}) # check using echo ${group1[@]}
#group2=({17..31})
#col1=($(for v in ${group1[@]}; do echo 1; done) ) # check length by echo "${#col1[@]}"
#col1+=($(for v in ${group2[@]}; do echo 0; done) )
#col2=($(for v in ${group1[@]}; do echo 0; done) ) # check length by echo "${#col1[@]}"
#col2+=($(for v in ${group2[@]}; do echo 1; done) )
##  combine in two columns and save
#printf "%s\n" "$(paste <(printf "%s\n" "${col1[@]}") <(printf "%s\n" "${col2[@]}") )" \
#> $InputTwoSampDir/designLitSubset.txt
## convert txt to mat
#Text2Vest $InputTwoSampDir/designLitSubset.txt $InputTwoSampDir/designLitSubset.mat
#
## run randomise
## use caudate Acc dilation mask - CauNACC_dil.nii.gz
## -T option means TFCE correction
#RandDir=$groupDir/RandTwoSampLitSubsetCauNADilTFCE
#if [ ! -d "$RandDir" ]; then
#  mkdir -p $RandDir
#fi
#for run in ${cope[@]}; do
#  # run randomise with -1 for sign-flips for contrast over both groups and -d with design input
#  # the input is the 4D image created above over all subjects and the output is saved in directory
#  # mentioned after -o.
#  # -T indicated TFCE correction
#  echo "run randomise over the subjects with lithium values within the caudate ACC \
#  mask for: ${model} - ${run}"
#  randomise_parallel -i $InputTwoSampDir/TwoSamp4D${run}LitSubset -o $RandDir/TwoSamp${run}LitSubsetT \
#  -1 -d $InputTwoSampDir/designLitSubset.mat -t $InputTwoSampDir/design.con -m $roiDir/CauNACC_dil -T
#done
#
## run randomise on whole brain using grey matter mask
#RandDir=$groupDir/RandTwoSampLitSubsetGMDilTFCE
#if [ ! -d "$RandDir" ]; then
#  mkdir -p $RandDir
#fi
#for run in ${cope[@]}; do
#  # run randomise with -1 for sign-flips for contrast over both groups and -d with design input
#  # the input is the 4D image created above over all subjects and the output is saved in directory
#  # mentioned after -o.
#  # -T indicated TFCE correction
#  echo "run randomise over the subjects with lithium values within the grey matter mask for: ${model} - ${run}"
#  randomise_parallel -i $InputTwoSampDir/TwoSamp4D${run}LitSubset -o $RandDir/TwoSamp${run}LitSubsetT \
#  -1 -d $InputTwoSampDir/designLitSubset.mat -t $InputTwoSampDir/design.con -m $roiDir/GM_dil -T
#done


# same analyses but now with lithium values as nuisance variables
# include mean centered lithium values as nuisance variable
# get actual levels
declare -a lithium=(0.7 0.8 0.8 0.6 0.5 0.8 0.6 0.6 0.4 0.6 0.7 0.8 0.4 1.4 0.7)
# mean center
# get mean
tot=0
for i in "${lithium[@]}"; do
  tot=$(echo $tot + $i | bc -l);
done
echo ${tot}
av=$(echo "$tot / ${#lithium[@]}" | bc -l)
# create mean centered variable
declare -a lithiumDemeaned=lithium
for (( i = 0 ; i < ${#lithium[@]} ; i++ )) do lithiumDemeaned[$i]=$(echo "${lithium[$i]} - $av" | bc -l) ; done
# create variable to include in design matrix with 0 for control group
group1=({0..16}) # check using echo ${group1[@]}
declare -a NuisLithium=($(for v in ${group1[@]}; do echo 0; done) )
NuisLithium+=(${lithiumDemeaned[@]})

# add to design matrix
# create design.mat
group1=({0..16}) # check using echo ${group1[@]}
group2=({17..31})
col1=($(for v in ${group1[@]}; do echo 1; done) ) # check length by echo "${#col1[@]}"
col1+=($(for v in ${group2[@]}; do echo 0; done) )
col2=($(for v in ${group1[@]}; do echo 0; done) ) # check length by echo "${#col1[@]}"
col2+=($(for v in ${group2[@]}; do echo 1; done) )
#  combine in two columns and save
printf "%s\n" "$(paste <(printf "%s\n" "${col1[@]}") <(printf "%s\n" "${col2[@]}") \
<(printf "%s\n" "${NuisLithium[@]}") )" > $InputTwoSampDir/designLithium.txt
# convert txt to mat
Text2Vest $InputTwoSampDir/designLithium.txt $InputTwoSampDir/designLithium.mat

# create design.con
declare -a con1=(1 1 0)
declare -a con2=(1 0 0)
declare -a con3=(0 1 0)
declare -a con4=(1 -1 0)
declare -a con5=(-1 1 0)
declare -a con6=(0 0 1)
declare -a con7=(0 0 -1)
# combine and save
printf "%s\t%s\t%s\n" "${con1[@]}" "${con2[@]}" "${con3[@]}" "${con4[@]}" "${con5[@]}" \
"${con6[@]}"  "${con7[@]}" > $InputTwoSampDir/contrastsLithium.txt
# convert txt to con
Text2Vest $InputTwoSampDir/contrastsLithium.txt $InputTwoSampDir/designLithium.con

# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -T option means TFCE correction
RandDir=$groupDir/RandTwoSampLitSubsetCauNADilTFCE
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
for run in ${cope[@]}; do
  # run randomise with -1 for sign-flips for contrast over both groups and -d with design input
  # the input is the 4D image created above over all subjects and the output is saved in directory
  # mentioned after -o.
  # -T indicated TFCE correction
  echo "run randomise over the subjects with lithium values including lithium correlation \
  within the caudate ACC mask for: ${model} - ${run}"
  randomise_parallel -i $InputTwoSampDir/TwoSamp4D${run}LitSubset -o \
  $RandDir/TwoSamp${run}LitSubsetLithiumT -1 -d $InputTwoSampDir/designLithium.mat \
  -t $InputTwoSampDir/designLithium.con -m $roiDir/CauNACC_dil -T
done

# run randomise on whole brain using grey matter mask
RandDir=$groupDir/RandTwoSampLitSubsetGMDilTFCE
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
for run in ${cope[@]}; do
  # run randomise with -1 for sign-flips for contrast over both groups and -d with design input
  # the input is the 4D image created above over all subjects and the output is saved in directory
  # mentioned after -o.
  # -T indicated TFCE correction
  echo "run randomise over the subjects with lithium values including lithium correlation \
  within the grey matter mask for: ${model} - ${run}"
  randomise_parallel -i $InputTwoSampDir/TwoSamp4D${run}LitSubset -o \
  $RandDir/TwoSamp${run}LitSubsetLithiumT -1 -d $InputTwoSampDir/designLithium.mat \
  -t $InputTwoSampDir/designLithium.con -m $roiDir/GM_dil -T
done

#RandDir=$groupDir/RandTwoSampLitSubsetCauNADilTFCE
#randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3LitSubset -o $RandDir/TwoSampCope3LitSubsetLithiumvT \
#-d $InputTwoSampDir/designLithium.mat -t $InputTwoSampDir/designLithium.con -v 5 -m $roiDir/CauNACC_dil -T

#RandDir=$groupDir/RandTwoSampLitSubsetCauNADilTFCE
#randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3LitSubset -o $RandDir/TwoSampCope3LitSubsetLithiumDT \
#-d $InputTwoSampDir/designLithium.mat -t $InputTwoSampDir/designLithium.con -m $roiDir/CauNACC_dil -D -T


# investigate results
RandDir=$groupDir/RandTwoSampLitSubsetGMDilTFCE
#RandDir=$groupDir/RandTwoSampLitSubsetCauNADilTFCE
#input=$RandDir/TwoSampCope1LitSubsetLithiumT
fslmaths $RandDir/TwoSampCope3LitSubsetLithiumT_tfce_corrp_tstat1 -thr 0.95 -bin \
-mul $RandDir/TwoSampCope3LitSubsetLithiumT_tstat1 $RandDir/TwoSampCope3LitSubsetLithiumT_thresh_tstat1

cluster --in=$RandDir/TwoSampCope3LitSubsetLithiumT_thresh_tstat1 --thresh=0.0001 \
--oindex=$RandDir/TwoSampCope3LitSubsetLithiumT_cluster_index1 \
--olmax=$RandDir/TwoSampCope3LitSubsetLithiumT_lmax1.txt \
--osize=$RandDir/TwoSampCope3LitSubsetLithiumT_cluster_size1 --mm

# get location clusters
atlasquery -a "MNI Structural Atlas" -m "$RandDir/TwoSampCope1LitSubsetLithiumT_cluster_index3"




<<COMMENT
# run randomise long on 1 contrast
# create design.con
declare -a con1=(-1 1)
# combine and save
printf "%s\t%s\n" "${con1[@]}" \
> $InputTwoSampDir/contrastSingle.txt
# convert txt to con
Text2Vest $InputTwoSampDir/contrastSingle.txt $InputTwoSampDir/designSingleCon.con
# randomise - cannot do this paralel
RandDir=$groupDir/RandTwoSampCauNADilTFCE
fsl_sub -q long.q randomise -i $InputTwoSampDir/TwoSamp4DCope1 -o $RandDir/TwoSampCope1Tn0 \
-d $InputTwoSampDir/design.mat -t $InputTwoSampDir/designSingleCon.con -m $roiDir/CauNACC_dil -T

# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -x option means voxel-based thresholding
RandDir=$groupDir/RandTwoSampCauNADilVoxel
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope1 -o $RandDir/TwoSampCope1T \
-d $InputTwoSampDir/design.mat -t $InputTwoSampDir/design.con -m $roiDir/CauNACC_dil -x

# now for COPE3
# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -T option means TFCE correction
RandDir=$groupDir/RandTwoSampCauNADilTFCE
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3 -o $RandDir/TwoSampCope3T \
-d $InputTwoSampDir/design.mat -t $InputTwoSampDir/design.con -m $roiDir/CauNACC_dil -T

# use GM mask
RandDir=$groupDir/RandTwoSampGMDilTFCE
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3 -o $RandDir/TwoSampCope3T \
-d $InputTwoSampDir/design.mat -t $InputTwoSampDir/design.con -m $roiDir/GM_dil -T

COMMENT
##############################################################################

# include gender as nuisance variable - to adjust for gender
# one variable is created and mean centred across both groups in order to adjust
# for any potential effect it might have on group

# get gender assignment - F = 0, M = 1
declare -a gender=(0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1)

# mean center
# get mean
tot=0
for i in ${gender[@]}; do
 let tot+=$i
done
av=$(echo "$tot / ${#gender[@]}" | bc -l)
# create mean centered variable
declare -a genderDemeaned=gender
for (( i = 0 ; i < ${#gender[@]} ; i++ )) do genderDemeaned[$i]=$(echo "${gender[$i]} - $av" | bc -l) ; done

# add to design matrix
# create design.mat
group1=({0..16}) # check using echo ${group1[@]}
group2=({17..32})
col1=($(for v in ${group1[@]}; do echo 1; done) ) # check length by echo "${#col1[@]}"
col1+=($(for v in ${group2[@]}; do echo 0; done) )
col2=($(for v in ${group1[@]}; do echo 0; done) ) # check length by echo "${#col1[@]}"
col2+=($(for v in ${group2[@]}; do echo 1; done) )
#  combine in two columns and save
printf "%s\n" "$(paste <(printf "%s\n" "${col1[@]}") <(printf "%s\n" "${col2[@]}") \
<(printf "%s\n" "${genderDemeaned[@]}") )" > $InputTwoSampDir/designGender.txt
# convert txt to mat
Text2Vest $InputTwoSampDir/designGender.txt $InputTwoSampDir/designGender.mat

# create design.con
declare -a con1=(1 0 0)
declare -a con2=(0 1 0)
declare -a con3=(1 -1 0)
declare -a con4=(-1 1 0)
# combine and save
printf "%s\t%s\t%s\n" "${con1[@]}" "${con2[@]}" "${con3[@]}" "${con4[@]}" > $InputTwoSampDir/contrastsGender.txt
# convert txt to con
Text2Vest $InputTwoSampDir/contrastsGender.txt $InputTwoSampDir/designGender.con

# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -T option means TFCE correction
RandDir=$groupDir/RandTwoSampCauNADilTFCE
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope1 -o $RandDir/TwoSampCope1GenderT \
-d $InputTwoSampDir/designGender.mat -t $InputTwoSampDir/designGender.con -m $roiDir/CauNACC_dil -T

# run randomise on whole brain using grey matter mask
RandDir=$groupDir/RandTwoSampGMDilTFCE
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope1 -o $RandDir/TwoSampCope1GenderT \
-d $InputTwoSampDir/designGender.mat -t $InputTwoSampDir/designGender.con -m $roiDir/GM_dil -T

# now for COPE3
# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -T option means TFCE correction
RandDir=$groupDir/RandTwoSampCauNADilTFCE
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3 -o $RandDir/TwoSampCope3GenderT \
-d $InputTwoSampDir/designGender.mat -t $InputTwoSampDir/designGender.con -m $roiDir/CauNACC_dil -T

# use GM mask
RandDir=$groupDir/RandTwoSampGMDilTFCE
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3 -o $RandDir/TwoSampCope3GenderT \
-d $InputTwoSampDir/designGender.mat -t $InputTwoSampDir/designGender.con -m $roiDir/GM_dil -T



###################Include age & gender covariates##################################

declare -a age=(19 21 20 20 19 20 25 21 18 19 29 31 23 21 20 21 21 20 26 29 22 \
22 21 24 23 23 20 22 19 20 22 18)

declare -a gender=(0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1)

# mean center age
# get mean
tot_age=0
for i in ${age[@]}; do
 let tot_age+=$i
done
av=$(echo "$tot_age / ${#age[@]}" | bc -l)
# create mean centered variable
declare -a ageDemeaned=age
for (( i = 0 ; i < ${#age[@]} ; i++ )) do ageDemeaned[$i]=$(echo "${age[$i]} - $av" | bc -l) ; done

# mean center gender
# get mean
tot_gen=0
for i in ${gender[@]}; do
 let tot_gen+=$i
done
av=$(echo "$tot_gen / ${#gender[@]}" | bc -l)
# create mean centered variable
declare -a genderDemeaned=gender
for (( i = 0 ; i < ${#gender[@]} ; i++ )) do genderDemeaned[$i]=$(echo "${gender[$i]} - $av" | bc -l) ; done

# add to design matrix
# create design.mat
group1=({0..16}) # check using echo ${group1[@]}
group2=({17..31})
col1=($(for v in ${group1[@]}; do echo 1; done) ) # check length by echo "${#col1[@]}"
col1+=($(for v in ${group2[@]}; do echo 0; done) )
col2=($(for v in ${group1[@]}; do echo 0; done) ) # check length by echo "${#col1[@]}"
col2+=($(for v in ${group2[@]}; do echo 1; done) )
#  combine in two columns and save
printf "%s\n" "$(paste <(printf "%s\n" "${col1[@]}") <(printf "%s\n" "${col2[@]}") \
<(printf "%s\n" "${NuisLithium[@]}") <(printf "%s\n" "${ageDemeaned[@]}") \
<(printf "%s\n" "${genderDemeaned[@]}") )" > $InputTwoSampDir/designLithiumAgeGender.txt
# convert txt to mat
Text2Vest $InputTwoSampDir/designLithiumAgeGender.txt $InputTwoSampDir/designLithiumAgeGender.mat

# create design.con
declare -a con1=(1 1 0 0 0)
declare -a con2=(1 0 0 0 0)
declare -a con3=(0 1 0 0 0)
declare -a con4=(1 -1 0 0 0)
declare -a con5=(-1 1 0 0 0)
declare -a con6=(0 0 1 0 0)
declare -a con7=(0 0 -1 0 0)
# combine and save
printf "%s\t%s\t%s\t%s\t%s\n" "${con1[@]}" "${con2[@]}" "${con3[@]}" "${con4[@]}" "${con5[@]}" \
"${con6[@]}"  "${con7[@]}" > $InputTwoSampDir/contrastsLithiumAgeGender.txt
# convert txt to con
Text2Vest $InputTwoSampDir/contrastsLithiumAgeGender.txt $InputTwoSampDir/designLithiumAgeGender.con


# now for COPE3
# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -T option means TFCE correction
RandDir=$groupDir/RandTwoSampLitSubsetCauNADilTFCE
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3LitSubset -o $RandDir/TwoSampCope3LitSubsetLithiumAgeGenT \
-1 -d $InputTwoSampDir/designLithiumAgeGender.mat -t $InputTwoSampDir/designLithiumAgeGender.con -m $roiDir/CauNACC_dil -T


###################Lithium analyses for Lithium group only##########################

## get subset for COPE3 including only people from whom we have lithium values
fslmerge -t $InputTwoSampDir/TwoSamp4DCope3LitOnly \
$mainDir/103_F03/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/110_F10/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/111_F11/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/113_F13/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/116_F16/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/118_F18/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/119_F19/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/202_M02/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/204_M04/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/207_M07/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/208_M08/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/209_M09/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/212_M12/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/216_M16/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3 \
$mainDir/217_M17/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope3
# excluded
# lithium group
#$mainDir/105_F05/fMRI/feat.feat/gammaHrfMov.feat/reg_standard/stats/cope1 \

# include lithium values as nuisance variable
# one variable is created and mean centred
# get actual levels
declare -a lithium=(0.7 0.8 0.8 0.6 0.5 0.8 0.6 0.6 0.4 0.6 0.7 0.8 0.4 1.4 0.7)
# mean center
# get mean
tot=0
for i in "${lithium[@]}"; do
  tot=$(echo $tot + $i | bc -l);
done
echo ${tot}
av=$(echo "$tot / ${#lithium[@]}" | bc -l)
# create mean centered variable
declare -a lithiumDemeaned=lithium
for (( i = 0 ; i < ${#lithium[@]} ; i++ )) do lithiumDemeaned[$i]=$(echo "${lithium[$i]} - $av" | bc -l) ; done

# add to design matrix
# create design.mat
group2=({0..14})
col1=($(for v in ${group2[@]}; do echo 1; done) ) # check length by echo "${#col1[@]}"
#  combine in two columns and save
printf "%s\n" "$(paste <(printf "%s\n" "${col1[@]}") <(printf "%s\n" "${lithiumDemeaned[@]}") )" \
> $InputTwoSampDir/designLitOnly.txt
# convert txt to mat
Text2Vest $InputTwoSampDir/designLitOnly.txt $InputTwoSampDir/designLitOnly.mat

# create design.con
declare -a con1=(1 0)
declare -a con2=(-1 0)
declare -a con3=(0 1)
declare -a con4=(0 -1)
# combine and save
printf "%s\t%s\n" "${con1[@]}" "${con2[@]}" "${con3[@]}" "${con4[@]}" \
> $InputTwoSampDir/contrastsLitOnly.txt
# convert txt to con
Text2Vest $InputTwoSampDir/contrastsLitOnly.txt $InputTwoSampDir/designLitOnly.con

# now for COPE3
# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -T option means TFCE correction
RandDir=$groupDir/RandTwoSampLitOnlyCauNADilTFCE
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3LitOnly -o $RandDir/TwoSampCope3LitOnlyLithiumT \
-d $InputTwoSampDir/designLitOnly.mat -t $InputTwoSampDir/designLitOnly.con -m $roiDir/CauNACC_dil -T


##########################Any effects over both groups without considering group?######
# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -T option means TFCE correction
RandDir=$groupDir/RandOneSampCauNADilTFCE
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope1 -o $RandDir/OneSampCope1T \
-1 -m $roiDir/CauNACC_dil -T

# run randomise on whole brain using grey matter mask
RandDir=$groupDir/RandOneSampGMDilTFCE
if [ ! -d "$RandDir" ]; then
  mkdir -p $RandDir
fi
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope1 -o $RandDir/OneSampCope1T \
-1 -m $roiDir/GM_dil -T

# now for COPE3
# run randomise
# use caudate Acc dilation mask - CauNACC_dil.nii.gz
# -T option means TFCE correction
RandDir=$groupDir/RandOneSampCauNADilTFCE
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3 -o $RandDir/OneSampCope3T \
-1 -m $roiDir/CauNACC_dil -T

# use GM mask
RandDir=$groupDir/RandOneSampGMDilTFCE
randomise_parallel -i $InputTwoSampDir/TwoSamp4DCope3 -o $RandDir/OneSampCope3T \
-1 -m $roiDir/GM_dil -T


<<COMMENT
## OLD????

# This script is still partly in development and mainly used to use randomise_parallel

# to run use sh /home/fs0/ivolman/code/higherLevelScript.sh
# view the log files using less, and q to exit less view.
# to visualise images use: fslview_deprecated & or FLSeyes via mount

mainDir=/vols/Scratch/ivolman/data_MID_work
groupDir=/vols/Scratch/ivolman/data_MID_work/group

# tutorial on https://www.youtube.com/watch?v=Ukl1VWobviw
#one sample t test
randomise_parallel -i $groupDir/input/cope1/filtered* -o $groupDir/RandCope1OneSampTGMDil \
-1 -T -m $mainDir/roi/avFreesurfer/GM_dil.nii.gz -T


randomise_parallel -i $groupDir/input/filtered* -o $groupDir/Randtest -d \
$groupDir/input/design.mat -t $groupDir/input/design.con -m \
$mainDir/roi/avFreesurfer/CauNACC_dil.nii.gz -T

# check results
fslstats $groupDir/Randtest -R

# and to check how many are above significance thershold
fslstats $groupDir/Randtest -l 0.95 -v

<<COMMENT
# OLD

# task to run. Options: copyCOPE
task="copyCOPE"

## declare an array variable of the participants
# example of all participants
declare -a subj=("101_F01" "102_F02" "103_F03" "104_F04" "105_F05" "107_F07" \
"108_F08" "109_F09" "110_F10" "111_F11" "112_F12" "113_F13" "114_F14" "115_F15" \
"116_F16" "117_F17" "118_F18" "119_F19" "202_M02" "203_M03" "204_M04" "205_M05" \
"206_M06" "207_M07" "208_M08" "209_M09" "210_M10" "211_M11" "212_M12" "213_M13" \
"214_M14" "216_M16" "217_M17" "218_M18")

# array with group codes: 0 = placebo, 1 = lithium
# IMPORTANT. These values are linked to the subj array above.
# extra info: array starts at 0, so to look at 3rd input use echo ${groupCode[2]}
groupCode=(0 0 1 0 1 0 0 0 1 1 0 1 0 0 1 1 1 1 1 0 1 0 0 1 1 1 0 0 1 0 0 1 1 0)

# the overall working and script directory
codeDir=/home/fs0/ivolman/code
workDir=/vols/Scratch/ivolman/data_MID_work
groupDir=${workDir}/group
mkdir -p $groupDir

## RUN ################################################################################


if [ "$task" = "copyCOPE" ]
then
  echo "copy all the COPE files for the higher level analyses"
  # create relevant directories
  AntRewDir=${groupDir}/antRew
  AntNoRewDir=${groupDir}/antNoRew
  mkdir -p $AntRewDir
  mkdir -p $AntNoRewDir

  # run over all selected subjects - using there place in the array is index
  for run in ${!subj[@]}; do
    echo ${subj[$run]}
    subjDir=/vols/Scratch/ivolman/data_MID_work/${subj[$run]}
    COPEDir=${subjDir}/fMRI/feat.feat/denoised_data.feat/stats
    # AntRew COPE
    cp ${COPEDir}/cope1.nii.gz ${AntRewDir}/AntRew_COPE_${subj[$run]:0:3}_\
G${groupCode[$run]}.nii.gz
    # AntNoRew COPE
    cp ${COPEDir}/cope2.nii.gz ${AntNoRewDir}/AntNoRew_COPE_${subj[$run]:0:3}_\
G${groupCode[$run]}.nii.gz


  done

fi
COMMENT
