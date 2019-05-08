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
subjDir=/vols/Scratch/ivolman/data_MID_work/${subj_id}/fMRI
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
if [ "$ana" == ant_gammaHrfMov ] || [ "$ana" == fb_gammaHrfMov ] \
|| [ "$ana" == onlyRE_PE_gammaHrfMov ] || [ "$ana" == gammaHrfMov ] \
|| [ "$ana" == gammaHrFMov_aPE ] || [ "$ana" == gammaHrfMov_REPE ]
#|| [ "$ana" == gammaHrfMovAntRew ] \
#|| [ "$ana" == gammaHrfMovAntNoRew ] || [ "$ana" == gammaHrfMovRewHit ] \
#|| [ "$ana" == gammaHrfMovRewLoss ] ;
then
  echo "combining motion parameters and WM time series into confound EV"
  paste ${featDir}/WM_meants.txt ${featDir}/mc/*.par > ${featDir}/confoundEVs.txt
else
  echo "using WM time series as confound EV"
  paste ${featDir}/WM_meants.txt > ${featDir}/confoundEVs.txt
fi
# check if the participant was classified with excessive motion and include the
# results from the motion outlier detection script here as well.
if [ "$subj_id" == 107_F07 ] || [ "$subj_id" == 109_F09 ] || \
[ "$subj_id" == 116_F16 ] || [ "$subj_id" == 117_F17 ] || \
[ "$subj_id" == 119_F19 ] || [ "$subj_id" == 217_M17 ]; then
  echo "participant with excessive motion"
  echo "combine the confound EV with the motion outlier file"
  paste ${featDir}/confoundEVs.txt ${subjDir}/motion_outliers_dvars > ${featDir}/temp.txt
  # rename the new list to confoundEVs
  mv ${featDir}/temp.txt ${featDir}/confoundEVs.txt
  echo "and use this combined EV file as confound EVs file"
fi

# create input variables for .fsf
CONFOUNDEV=${featDir}/confoundEVs.txt
if [ "$ana" == ant_gammaHrfMov ] || [ "$ana" == gammaHrfMov ] \
|| [ "$ana" == gammaHrFMov_aPE ] || [ "$ana" == gammaHrfMov_REPE ]
#|| [ "$ana" == gammaHrfMovAntRew ] \
#|| [ "$ana" == gammaHrfMovAntNoRew ] || [ "$ana" == gammaHrfMovRewHit ] \
#|| [ "$ana" == gammaHrfMovRewLoss ] ;
then
  FILEANTREW=${subjDir}/task/featRegrAntRew.txt
  FILEANTNOREW=${subjDir}/task/featRegrAntNoRew.txt
  FILEANTNOMOV=${subjDir}/task/featRegrAntNoMov.txt
fi
if [ "$ana" == ant_gammaHrfMov ] || [ "$ana" == onlyRE_PE_gammaHrfMov ] ; then
  FILEANTPARAM=${subjDir}/task/featRegrAntRewParam.txt
fi
if [ "$ana" == fb_gammaHrfMov ] || [ "$ana" == gammaHrfMov ] \
|| [ "$ana" == gammaHrFMov_aPE ]
#|| [ "$ana" == gammaHrfMovAntRew ] \
#|| [ "$ana" == gammaHrfMovAntNoRew ] || [ "$ana" == gammaHrfMovRewHit ] \
#|| [ "$ana" == gammaHrfMovRewLoss ] ;
then
  FILEFHITREW=${subjDir}/task/featRegrFHitRew.txt
  FILEFLOSSREW=${subjDir}/task/featRegrFLossRew.txt
  FILEFHITNOREW=${subjDir}/task/featRegrFHitNoRew.txt
  FILEFLOSSNOREW=${subjDir}/task/featRegrFLossNoRew.txt
  FILEFNOMOV=${subjDir}/task/featRegrFNoMov.txt
  FILEFERROR=${subjDir}/task/featRegrError.txt
fi
if [ "$ana" == fb_gammaHrfMov ] || [ "$ana" == onlyRE_PE_gammaHrfMov ] ; then
  FILEFBPARAM=${subjDir}/task/featRegrFRewParam.txt
fi
if [ "$ana" == gammaHrFMov_aPE ] ; then
  FILEAPEPARAM=${subjDir}/task/featRegrAbsFRewParam.txt
fi
if [ "$ana" == gammaHrfMov_REPE ] ; then
  FILEANTPARAM=${subjDir}/task/featRegrAntRewParam.txt
  FILEFBPARAM=${subjDir}/task/featRegrFRewParam.txt
  FILEFREW=${subjDir}/task/featRegrFRew.txt
  FILEFNOREW=${subjDir}/task/featRegrFNoRew.txt
  FILEFNOMOV=${subjDir}/task/featRegrFNoMov.txt
  FILEFERROR=${subjDir}/task/featRegrError.txt
fi

#if [ "$ana" == gammaHrfMovAntRew ]; then
#  CONTRAST="AntRew"
#  INPUT1=1; INPUT2=0; INPUT3=0; INPUT4=0; INPUT5=0; INPUT6=0; INPUT7=0;
#  INPUT8=0; INPUT9=0
#elif [ "$ana" == gammaHrfMovAntNoRew ]; then
#  CONTRAST="AntNoRew"
#  INPUT1=0; INPUT2=1; INPUT3=0; INPUT4=0; INPUT5=0; INPUT6=0; INPUT7=0;
#  INPUT8=0; INPUT9=0
#elif [ "$ana" == gammaHrfMovRewHit ]; then
#  CONTRAST="RewHit"
#  INPUT1=0; INPUT2=0; INPUT3=0; INPUT4=1; INPUT5=0; INPUT6=0; INPUT7=0;
#  INPUT8=0; INPUT9=0
#elif [ "$ana" == gammaHrfMovRewLoss ]; then
#  CONTRAST="RewLoss"
#  INPUT1=0; INPUT2=0; INPUT3=0; INPUT4=0; INPUT5=1; INPUT6=0; INPUT7=0;
#  INPUT8=0; INPUT9=0
#fi

# fill template
# anticipation only model - does not contain error regressor so is the same for
# all participants
if [ "$ana" == ant_gammaHrfMov ] ; then
  template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRFAnticipation.fsf'
  echo "using ${template}"
  # replace variable names in templateFirstLevel.fsf with subject specific data
  for i in ${template}; do
    sed -e 's@DATAFILE@'$DATAFILE'@g' \
    -e 's@TOTALVOL@'$TOTALVOL'@g' \
    -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
    -e 's@FILEANTREW@'$FILEANTREW'@g' \
    -e 's@FILEANTNOREW@'$FILEANTNOREW'@g' \
    -e 's@FILEANTNOMOV@'$FILEANTNOMOV'@g' \
    -e 's@FILEANTPARAM@'$FILEANTPARAM'@g' \
      <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
  done
# model with only parametric regressors of RE and PE
# this model also does not contain an error regressor thus can be run over all participants
elif [ "$ana" == onlyRE_PE_gammaHrfMov ] ; then
  template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRFOnlyREPE.fsf'
  echo "using ${template}"
  # replace variable names in templateFirstLevel.fsf with subject specific data
  for i in ${template}; do
    sed -e 's@DATAFILE@'$DATAFILE'@g' \
    -e 's@TOTALVOL@'$TOTALVOL'@g' \
    -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
    -e 's@FILEANTPARAM@'$FILEANTPARAM'@g' \
    -e 's@FILEFBPARAM@'$FILEFBPARAM'@g' \
      <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
    done
# models with specific contrast and error regressor
elif [ -s ${FILEFERROR} ]; then
  # other models with error regressor
  # feedback model
  if [[ "$ana" == fb_gammaHrfMov ]]; then
    #statements
    template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRFFeedback.fsf'
    echo "using ${template}"
    # replace variable names in templateFirstLevel.fsf with subject specific data
    for i in ${template}; do
      sed -e 's@DATAFILE@'$DATAFILE'@g' \
      -e 's@TOTALVOL@'$TOTALVOL'@g' \
      -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
      -e 's@FILEFHITREW@'$FILEFHITREW'@g' \
      -e 's@FILEFLOSSREW@'$FILEFLOSSREW'@g' \
      -e 's@FILEFHITNOREW@'$FILEFHITNOREW'@g' \
      -e 's@FILEFLOSSNOREW@'$FILEFLOSSNOREW'@g' \
      -e 's@FILEFNOMOV@'$FILEFNOMOV'@g' \
      -e 's@FILEFERROR@'$FILEFERROR'@g' \
      -e 's@FILEFBPARAM@'$FILEFBPARAM'@g' \
        <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
    done
  elif [ "$ana" == gammaHrFMov_aPE ]; then
    template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRF_aPE.fsf'
    echo "using ${template}"
    #echo "using templateFirstLevel.fsf"
    # replace variable names in templateFirstLevel.fsf with subject specific data
    for i in ${template}; do
      sed -e 's@DATAFILE@'$DATAFILE'@g' \
      -e 's@TOTALVOL@'$TOTALVOL'@g' \
      -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
      -e 's@FILEANTREW@'$FILEANTREW'@g' \
      -e 's@FILEANTNOREW@'$FILEANTNOREW'@g' \
      -e 's@FILEANTNOMOV@'$FILEANTNOMOV'@g' \
      -e 's@FILEFHITREW@'$FILEFHITREW'@g' \
      -e 's@FILEFLOSSREW@'$FILEFLOSSREW'@g' \
      -e 's@FILEFHITNOREW@'$FILEFHITNOREW'@g' \
      -e 's@FILEFLOSSNOREW@'$FILEFLOSSNOREW'@g' \
      -e 's@FILEFNOMOV@'$FILEFNOMOV'@g' \
      -e 's@FILEFERROR@'$FILEFERROR'@g' \
      -e 's@FILEAPEPARAM@'$FILEAPEPARAM'@g' \
      <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
    done
  elif [ "$ana" == gammaHrfMov_REPE ]; then
    template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRF_REPE.fsf'
    echo "using ${template}"
    #echo "using templateFirstLevel.fsf"
    # replace variable names in templateFirstLevel.fsf with subject specific data
    for i in ${template}; do
      sed -e 's@DATAFILE@'$DATAFILE'@g' \
      -e 's@TOTALVOL@'$TOTALVOL'@g' \
      -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
      -e 's@FILEANTPARAM@'$FILEANTPARAM'@g' \
      -e 's@FILEFBPARAM@'$FILEFBPARAM'@g' \
      -e 's@FILEANTREW@'$FILEANTREW'@g' \
      -e 's@FILEANTNOREW@'$FILEANTNOREW'@g' \
      -e 's@FILEANTNOMOV@'$FILEANTNOMOV'@g' \
      -e 's@FILEFREW@'$FILEFREW'@g' \
      -e 's@FILEFNOREW@'$FILEFNOREW'@g' \
      -e 's@FILEFNOMOV@'$FILEFNOMOV'@g' \
      -e 's@FILEFERROR@'$FILEFERROR'@g' \
      <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
    done
else
    # get the template
    if [ "$ana" == gammaHrf ] || [ "$ana" == gammaHrfMov ] ;then
      template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRF.fsf'
    else
      template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevel.fsf'
    fi
    echo "using ${template}"
    #echo "using templateFirstLevel.fsf"
    # replace variable names in templateFirstLevel.fsf with subject specific data
    for i in ${template}; do
      sed -e 's@DATAFILE@'$DATAFILE'@g' \
      -e 's@TOTALVOL@'$TOTALVOL'@g' \
      -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
      -e 's@FILEANTREW@'$FILEANTREW'@g' \
      -e 's@FILEANTNOREW@'$FILEANTNOREW'@g' \
      -e 's@FILEANTNOMOV@'$FILEANTNOMOV'@g' \
      -e 's@FILEFHITREW@'$FILEFHITREW'@g' \
      -e 's@FILEFLOSSREW@'$FILEFLOSSREW'@g' \
      -e 's@FILEFHITNOREW@'$FILEFHITNOREW'@g' \
      -e 's@FILEFLOSSNOREW@'$FILEFLOSSNOREW'@g' \
      -e 's@FILEFNOMOV@'$FILEFNOMOV'@g' \
      -e 's@FILEFERROR@'$FILEFERROR'@g' \
      <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
    done
  fi
# models with specific contrast without error regressor
# other models without error regressor
elif [[ "$ana" == fb_gammaHrfMov ]]; then
  #statements
  template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRFFeedbackNoError.fsf'
  echo "using ${template}"
  # replace variable names in templateFirstLevel.fsf with subject specific data
  for i in ${template}; do
    sed -e 's@DATAFILE@'$DATAFILE'@g' \
    -e 's@TOTALVOL@'$TOTALVOL'@g' \
    -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
    -e 's@FILEFHITREW@'$FILEFHITREW'@g' \
    -e 's@FILEFLOSSREW@'$FILEFLOSSREW'@g' \
    -e 's@FILEFHITNOREW@'$FILEFHITNOREW'@g' \
    -e 's@FILEFLOSSNOREW@'$FILEFLOSSNOREW'@g' \
    -e 's@FILEFNOMOV@'$FILEFNOMOV'@g' \
    -e 's@FILEFBPARAM@'$FILEFBPARAM'@g' \
      <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
    done
elif [ "$ana" == gammaHrFMov_aPE ]; then
    template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRFNoError_aPE.fsf'
    echo "using ${template}"
    # replace variable names in templateFirstLevel.fsf with subject specific data
    for i in ${template}; do
      sed -e 's@DATAFILE@'$DATAFILE'@g' \
      -e 's@TOTALVOL@'$TOTALVOL'@g' \
      -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
      -e 's@FILEANTREW@'$FILEANTREW'@g' \
      -e 's@FILEANTNOREW@'$FILEANTNOREW'@g' \
      -e 's@FILEANTNOMOV@'$FILEANTNOMOV'@g' \
      -e 's@FILEFHITREW@'$FILEFHITREW'@g' \
      -e 's@FILEFLOSSREW@'$FILEFLOSSREW'@g' \
      -e 's@FILEFHITNOREW@'$FILEFHITNOREW'@g' \
      -e 's@FILEFLOSSNOREW@'$FILEFLOSSNOREW'@g' \
      -e 's@FILEFNOMOV@'$FILEFNOMOV'@g' \
      -e 's@FILEAPEPARAM@'$FILEAPEPARAM'@g' \
      <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
    done
elif [ "$ana" == gammaHrfMov_REPE ]; then
  template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRFNoError_REPE.fsf'
  echo "using ${template}"
  # replace variable names in templateFirstLevel.fsf with subject specific data
  for i in ${template}; do
    sed -e 's@DATAFILE@'$DATAFILE'@g' \
    -e 's@TOTALVOL@'$TOTALVOL'@g' \
    -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
    -e 's@FILEANTPARAM@'$FILEANTPARAM'@g' \
    -e 's@FILEFBPARAM@'$FILEFBPARAM'@g' \
    -e 's@FILEANTREW@'$FILEANTREW'@g' \
    -e 's@FILEANTNOREW@'$FILEANTNOREW'@g' \
    -e 's@FILEANTNOMOV@'$FILEANTNOMOV'@g' \
    -e 's@FILEFREW@'$FILEFREW'@g' \
    -e 's@FILEFNOREW@'$FILEFNOREW'@g' \
    -e 's@FILEFNOMOV@'$FILEFNOMOV'@g' \
    <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
  done
else
  echo "error file is empty"
  # get the template
  if [ "$ana" == gammaHrf ] || [ "$ana" == gammaHrfMov ]; then
    template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelHRFNoError.fsf'
  else
    template=/vols/Scratch/ivolman/data_MID_work/'templateFirstLevelNoError.fsf'
  fi
  echo "using ${template}"
  # replace variable names in templateFirstLevel.fsf with subject specific data
  for i in ${template}; do
    sed -e 's@DATAFILE@'$DATAFILE'@g' \
    -e 's@TOTALVOL@'$TOTALVOL'@g' \
    -e 's@CONFOUNDEV@'$CONFOUNDEV'@g' \
    -e 's@FILEANTREW@'$FILEANTREW'@g' \
    -e 's@FILEANTNOREW@'$FILEANTNOREW'@g' \
    -e 's@FILEANTNOMOV@'$FILEANTNOMOV'@g' \
    -e 's@FILEFHITREW@'$FILEFHITREW'@g' \
    -e 's@FILEFLOSSREW@'$FILEFLOSSREW'@g' \
    -e 's@FILEFHITNOREW@'$FILEFHITNOREW'@g' \
    -e 's@FILEFLOSSNOREW@'$FILEFLOSSNOREW'@g' \
    -e 's@FILEFNOMOV@'$FILEFNOMOV'@g' \
    <$i> ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
  done
fi


######### run FEAT ######################################################

echo "run first level analysis in feat"
# run feat using the newly created fsf file
feat ${subjDir}/FEATFirstLevel_${subj_id:0:3}.fsf
