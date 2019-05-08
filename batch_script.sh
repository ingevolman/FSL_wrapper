#!/bin/bash

# batch file
# To run use sh /home/fs0/ivolman/code/batch_script.sh
# View the log files using less, and q to exit less view.
# To visualise images use: fslview_deprecated & or FLSeyes via mount

# Don't forget to run RunBatch_MID before process = "get_reg" - you need the
# segmented images for this process.

# assign the correct fls version
export FSLDIR=/opt/fmrib/fsltmp/fsl_FinalFive
PATH=${FSLDIR}/bin:${PATH}
. ${FSLDIR}/etc/fslconf/fsl.sh
# test if it worked by typing 'which fast'

# Input task
# Options: "MID", "VC" % MID task or visual checkerboard
task="VC"

# options for model: gammaHrfMov, ant_gammaHrfMov, fb_gammaHrfMov, onlyRE_PE_gammaHrfMov,
# gammaHrFMov_aPE, gammaHrfMov_REPE
# model onlyRE_PE_gammaHrfMov includes RE and PE EVs and confound regressors
# afb_gammaHrFMov includes the absolute prediction error
model="gammaHrfMov"

# Input the process to run here.
# Options: preproc, denoising, get_reg or first_level, mv_feat
process="first_level"

## declare an array variable of the participants
# example of all participants
#declare -a subj=("101_F01" "102_F02" "103_F03" "104_F04" "105_F05" "107_F07" "108_F08" \
#"109_F09" "110_F10" "111_F11" "112_F12" "113_F13" "114_F14" "115_F15" "116_F16" "117_F17" \
#"118_F18" "119_F19" "202_M02" "203_M03" "204_M04" "205_M05" "206_M06" "207_M07" "208_M08" \
#"209_M09" "210_M10" "211_M11" "212_M12" "213_M13" "214_M14" "216_M16" "217_M17" "218_M18")

# selection for current analysis
declare -a subj=( "101_F01" "118_F18" "218_M18" )

# the overall working and script directory
codeDir=/home/fs0/ivolman/code
#workDir=/vols/Scratch/ivolman/data_MID_work
workDir=/vols/Scratch/ivolman/data_${task}_work
# create a logDir in the work directory if it does not exist yet.
logDir=$workDir/log
mkdir -p $logDir


## RUN ################################################################################

# run over all selected subjects
for run in ${subj[@]}; do
  echo ${run}

  ## PREPROCESSING
  if [ "$process" = "preproc" ]
  then
    echo "process: preprocessing"
    # run preparation for feat and the running of feat script
    #./$codeDir/prep_run_feat_preproc ${run}
    if [ "$run" == 101_F01 ] || [ "$run" == 118_F18 ] || [ "$run" == 218_M18 ]
    then
      # the prep_run_feat_preproc_noFMAD script will run feat without a fieldmap
      echo "feat without fieldmap"
      fsl_sub -q short.q -l $logDir -N "FEAT" sh $codeDir/prep_run_feat_preproc_noFMAD.sh ${run} ${task}
    else
      fsl_sub -q short.q -l $logDir -N "FEAT" sh $codeDir/prep_run_feat_preproc.sh ${run} ${task}
    fi

  ## MELODIC DENOISING
  # first assign melodic labels
  elif [ "$process" = "denoising" ]
  then
    echo "process: denoising"
    # run denoising based on melodic labels
    fsl_sub -q veryshort.q -l $logDir -N "MELODIC" sh $codeDir/melodic_denoising.sh ${run} ${task}

  ## PREPARE REGRESSORS
  # First prepare the regressors for first level analyses using RunBatch_MID.sh or VC
elif [ "$process" = "get_reg" ] # for F01, F18, M18: does not seem to work as example_func2highres_warp, also for MID data this is not there
  then
    # Make sure to run the HCP pipeline using Lennart Verhagen's script to get the
    # white matter and CSF masks

    # get the regressors - these are the excessive movement regressors, normal
    # movement and the white matter and CSF regressors.
    echo "process: get regressors"
    fsl_sub -q veryshort.q -l $logDir -N "REGR" sh $codeDir/get_regressors.sh ${run} ${task}

  ## FEAT first level
  elif [ "$process" = "first_level" ]
  then
    echo "process: first_level"
    # which model do you want to run. either "" (model including FLOBS, but no
    # motion parameters), "gammaHrf" (model using the gamma HRF, but further same as
    # ""), or "gammaHrfMov" which additional includes the movement parameters.
    #model="gammaHrfMovAntRew"  #"gammaHrfMovRewHit" #"gammaHrfMovAntNoRew" #"gammaHrfMovAntRew"
    #model="gammaHrfMov"
    echo "model: ${model}"
    if [ "$task" = "MID" ]
    then
      echo task = MID
      # run the script first_level_ana
      sh $codeDir/first_level_ana.sh ${run} ${model}
    elif [  "$task" = "VC"  ]; then
      echo task = VC
      # run the script first_level_ana
      sh $codeDir/first_level_ana_VC.sh ${run} ${model}
    fi
  ## copy first level
  elif [ "$process" = "mv_feat" ]
  then
    # check if the references are ok, also to the feat model as another name is created
    # if there already was a denoised_data.feat directory present
    echo "model: ${model}"
    subjDir=/vols/Scratch/ivolman/data_${task}_work/${run}/fMRI
    mv ${subjDir}/feat.feat/denoised_data.feat ${subjDir}/feat.feat/${model}.feat

    # also copy the reg to this new model directory to be used for registration
    # to standard space
    cp -R ${subjDir}/feat.feat/reg ${subjDir}/feat.feat/${model}.feat/reg


  # registration to standard space
  elif [ "$process" = "registration" ]
  then
    # best approach at the moment is to create a very simple group model to get the COPEs
    # registered to standard space, get a group summary of T1 etc.
    XXX
  fi

done


<<COMMENT
# EXTRA: to organise and copy files
# selection for current analysis
declare -a subj=("101_F01" "102_F02" "103_F03" "104_F04" "105_F05" "107_F07" "108_F08" \
"109_F09" "110_F10" "111_F11" "112_F12" "113_F13" "114_F14" "115_F15" "116_F16" "117_F17" \
"118_F18" "119_F19" "202_M02" "203_M03" "204_M04" "205_M05" "206_M06" "207_M07" "208_M08" \
"209_M09" "210_M10" "211_M11" "212_M12" "213_M13" "214_M14" "216_M16" "217_M17" "218_M18")

# selection for current analysis
declare -a subj=( "209_M09" )

#ana="gammaHrfMovRewLoss"
for run in ${subj[@]}; do
  echo ${run}
  #mv /vols/Scratch/ivolman/data_VC_work/${run}/fMRI/*VisualCheckerboard* \
  #/vols/Scratch/ivolman/data_VC_work/${run}/fMRI/${run:0:3}_VC.nii.gz
  #mv /vols/Scratch/ivolman/data_VC_work/${run}/fMRI/*anatomy* \
  #/vols/Scratch/ivolman/data_VC_work/${run}/fMRI/${run:0:3}_anatomy.nii.gz
  mv /vols/Scratch/ivolman/data_VC_work/${run}/fMRI/*grefieldmapping*1001* \
  /vols/Scratch/ivolman/data_VC_work/${run}/fMRI/${run:0:3}_MagnitudeImage.nii.gz
  mv /vols/Scratch/ivolman/data_VC_work/${run}/fMRI/*grefieldmapping*2001* \
  /vols/Scratch/ivolman/data_VC_work/${run}/fMRI/${run:0:3}_PhaseImage.nii.gz
  #rm -rf /vols/Scratch/ivolman/data_MID_work/${run}/fMRI/feat.feat/gammaHrfMov.feat/featquery_NACC
done

  #scp -r ivolman@jalapeno.fmrib.ox.ac.uk:/vols/Scratch/ivolman/data_MID_work/${run}/fMRI Volumes/Inge_Book/Lithium_Inge/data_MID_work/${run}/fMRI
  #mv Volumes/Inge_Book/Lithium_Inge/data_MID_work/${run}/fMRI/feat.feat Volumes/Inge_Book/Lithium_Inge/data_MID_work/${run}/fMRI/feat_nofuncbet.feat
  #mv /vols/Scratch/ivolman/data_MID_work/${run}/fMRI/feat.feat /vols/Scratch/ivolman/data_MID_work/${run}/fMRI/feat_nofuncbet.feat
  #rm -rf /vols/Scratch/ivolman/data_MID_work/${run}/fMRI/feat.feat
  mv /vols/Scratch/ivolman/data_MID_work/${run}/fMRI/feat.feat/gammaHrfMov.feat \
  /vols/Scratch/ivolman/data_MID_work/${run}/fMRI/feat.feat/gammaHrfMov.feat_OLD
  mv /vols/Scratch/ivolman/data_MID_work/group/BasicModel \
  /vols/Scratch/ivolman/data_MID_work/group/BasicModel_OLD
  cp -R /vols/Scratch/ivolman/data_MID_work/${run}/fMRI/feat.feat/reg \
  /vols/Scratch/ivolman/data_MID_work/${run}/fMRI/feat.feat/fb_gammaHrfMov.feat/reg
done

COMMENT
