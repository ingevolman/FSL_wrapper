#!/usr/bin/env bash
set -e

#~ND~FORMAT~MARKDOWN~
#~ND~START~
#
# # PreFreeSurferPipelineBatch.sh
#
# ## Copyright Notice
#
# Copyright (C) 2013-2016 The Human Connectome Project
#
# * Washington University in St. Louis
# * University of Minnesota
# * Oxford University
#
# ## Author(s)
#
# * Matthey F. Glasser, Department of Anatomy and Neurobiology,
#   Washington University in St. Louis
# * Timothy B. Brown, Neuroinformatics Research Group,
#   Washington University in St. Louis
#
# ## Product
#
# [Human Connectome Project][HCP] (HCP) Pipelines
#
# ## License
#
# See the [LICENSE](https://github.com/Washington-University/Pipelines/blob/master/LICENSE.md) file
#
# ## Description:
#
# Example script for running the Pre-FreeSurfer phase of the HCP Structural
# Preprocessing pipeline
#
# See [Glasser et al. 2013][GlasserEtAl].
#
# ## Prerequisites
#
# ### Installed software
#
# * FSL (version 5.0.6)
# * FreeSurfer (version 5.3.0-HCP)
# * gradunwarp (HCP version 1.0.2) - if doing gradient distortion correction
#
# ### Environment variables
#
# Should be set in script file pointed to by EnvironmentScript variable.
# See setting of the EnvironmentScript variable in the main() function
# below.
#
# * FSLDIR - main FSL installation directory
# * FREESURFER_HOME - main FreeSurfer installation directory
# * HCPPIPEDIR - main HCP Pipelines installation directory
# * CARET7DIR - main Connectome Workbench installation directory
# * PATH - must point to where gradient_unwarp.py is if doing gradient unwarping
#
# <!-- References -->
# [HCP]: http://www.humanconnectome.org
# [GlasserEtAl]: http://www.ncbi.nlm.nih.gov/pubmed/23668970
#
#~ND~END~

# Function: get_batch_options
# Description
#
#   Retrieve the following command line parameter values if specified
#
#   --StudyFolder= - primary study folder containing subject ID subdirectories
#   --Subjlist=    - quoted, space separated list of subject IDs on which
#                    to run the pipeline
#   --runlocal     - if specified (without an argument), processing is run
#                    on "this" machine as opposed to being submitted to a
#                    computing grid
#
#   Set the values of the following global variables to reflect command
#   line specified parameters
#
#   command_line_specified_study_folder
#   command_line_specified_subj_list
#   command_line_specified_run_local
#
#   These values are intended to be used to override any values set
#   directly within this script file
get_batch_options() {
  # set defaults
  args=""
  export HCPPIPEDIR="/vols/Data/daa/scripts/HCP-pipelines"
  EnvironmentScript="$HCPPIPEDIR/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script
  StudyFolder="${HOME}/scratch/data_MID_HCP_Struc" #Location of Subject folders (named by subjectID)
  Subjlist="PL02" #Space delimited list of subject IDs
  Scanner="3T" # Scanner specific subfolder of unprocessed MR data, usually either 3T or 7T
  LogDir="./log"
  runlocal="FALSE"

  # parse the input arguments
  for a in "$@" ; do
    case $a in
      --StudyFolder=*)  StudyFolder="${a#*=}"; shift ;;
      --SubjList=*)     SubjList="${a#*=}"; shift ;;
      --Scanner=*)      Scanner="${a#*=}"; shift ;;
      --LogDir=*)       LogDir="${a#*=}"; shift ;;
      --runlocal)       runlocal="TRUE"; shift ;;
      *)                args="$args $a"; shift ;; # unsupported argument
    esac
  done

  # check if no redundant arguments have been set
  if [[ -n $args ]] ; then
    >&2 echo ""; >&2 echo "unsupported arguments are given:" $args
    exit 1
  fi
}

# Requirements for this script
#  installed versions of: FSL (version 5.0.6), FreeSurfer (version 5.3.0-HCP), gradunwarp (HCP version 1.0.2) if doing gradient distortion correction
#  environment: FSLDIR , FREESURFER_HOME , HCPPIPEDIR , CARET7DIR , PATH (for gradient_unwarp.py)

# Function: main
# Description: main processing work of this script
main()
{
	get_batch_options "$@"

  # Report major script control variables to user
  echo "StudyFolder: ${StudyFolder}"
  echo "SubjList: ${SubjList}"
  echo "EnvironmentScript: ${EnvironmentScript}"
  echo "Run locally: ${runlocal}"

  # Set up pipeline environment variables and software
  source ${EnvironmentScript}

  #if [[ -n $SGE_ROOT ]] ; then
      QUEUE="-q long.q"
      #QUEUE="-q hcp_priority.q"
  #fi

  # If PRINTCOM is not a null or empty string variable, then
    # this script and other scripts that it calls will simply
	# print out the primary commands it otherwise would run.
	# This printing will be done using the command specified
	# in the PRINTCOM variable
  PRINTCOM=""
  #PRINTCOM="echo"

  # Establish queuing command based on command line option
  if [[ $runlocal == TRUE ]] ; then
      echo "About to run ${HCPPIPEDIR}/PreFreeSurfer/PreFreeSurferPipeline.sh"
      queuing_command=""
  else
      echo "About to use fsl_sub to queue or run ${HCPPIPEDIR}/PreFreeSurfer/PreFreeSurferPipeline.sh"
      mkdir -p $LogDir # ensure the directory to store fsl_sub logfiles exists
      queuing_command="${FSLDIR}/bin/fsl_sub ${QUEUE} -l $LogDir"
  fi

  #
  # Inputs:
  #
  # Scripts called by this script do NOT assume anything about the form of the
  # input names or paths. This batch script assumes the HCP raw data naming
  # convention, e.g.
  #
  # ${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_T1w_MPR1.nii.gz
  # ${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR2/${Subject}_3T_T1w_MPR2.nii.gz
  #
  # ${StudyFolder}/${Subject}/unprocessed/3T/T2w_SPC1/${Subject}_3T_T2w_SPC1.nii.gz
  # ${StudyFolder}/${Subject}/unprocessed/3T/T2w_SPC2/${Subject}_3T_T2w_SPC2.nii.gz
  #
  # ${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_FieldMap_Magnitude.nii.gz
  # ${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_FieldMap_Phase.nii.gz

  # Scan settings:
  #
  # Change the Scan Settings (e.g. Sample Spacings and $UnwarpDir) to match your
  # images. These are set to match the HCP Protocol by default.

  # Readout Distortion Correction:
  #
  # You have the option of using either gradient echo field maps or spin echo
  # field maps to perform readout distortion correction on your structural
  # images, or not to do readout distortion correction at all.
  #
  # The HCP Pipeline Scripts currently support the use of gradient echo field
  # maps or spin echo field maps as they are produced by the Siemens Connectom
  # Scanner. They also support the use of gradient echo field maps as generated
  # by General Electric scanners.
  #
  # Change either the gradient echo field map or spin echo field map scan
  # settings to match your data. This script is setup to use gradient echo
  # field maps from the Siemens Connectom Scanner using the HCP Protocol.

  # Gradient Distortion Correction:
  #
  # If using gradient distortion correction, use the coefficents from your
  # scanner. The HCP gradient distortion coefficents are only available through
  # Siemens. Gradient distortion in standard scanners like the Trio is much
  # less than for the HCP Skyra.

  # DO WORK

  # Cycle through specified subjects
  for Subject in ${SubjList//@/ } ; do
    echo $Subject

    # Input Images

    # Detect Number of T1w Images
    numT1ws=`ls ${StudyFolder}/${Subject}/unprocessed/${Scanner} | grep T1w_MPR.$ | wc -l`
    echo "Found ${numT1ws} T1w Images for subject ${Subject}"
    T1wInputImages=""
    i=1
    while [ $i -le $numT1ws ] ; do
      T1wInputImages=`echo "${T1wInputImages}${StudyFolder}/${Subject}/unprocessed/${Scanner}/T1w_MPR${i}/${Subject}_${Scanner}_T1w_MPR${i}.nii.gz@"`
      i=$(($i+1))
    done

    # Detect Number of T2w Images
    numT2ws=`ls ${StudyFolder}/${Subject}/unprocessed/${Scanner} | grep T2w_SPC.$ | wc -l`
    echo "Found ${numT2ws} T2w Images for subject ${Subject}"
    T2wInputImages=""
    i=1
    while [ $i -le $numT2ws ] ; do
      T2wInputImages=`echo "${T2wInputImages}${StudyFolder}/${Subject}/unprocessed/${Scanner}/T2w_SPC${i}/${Subject}_${Scanner}_T2w_SPC${i}.nii.gz@"`
      i=$(($i+1))
    done

    # Readout Distortion Correction:
    #
    #   Currently supported Averaging and readout distortion correction
    #   methods: (i.e. supported values for the AvgrdcSTRING variable in this
    #   script and the --avgrdcmethod= command line option for the
    #   PreFreeSurferPipeline.sh script.)
    #
    #   "NONE"
    #     Average any repeats but do no readout distortion correction
    #
    #   "FIELDMAP"
    #     This value is equivalent to the "SiemensFieldMap" value described
    #     below. Use of the "SiemensFieldMap" value is prefered, but
    #     "FIELDMAP" is included for backward compatibility with the versions
    #     of these scripts that only supported use of Siemens-specific
    #     Gradient Echo Field Maps and did not support Gradient Echo Field
    #     Maps from any other scanner vendor.
    #
    #   "TOPUP"
    #     Average any repeats and use Spin Echo Field Maps for readout
    #     distortion correction
    #
    #   "GeneralElectricFieldMap"
    #     Average any repeats and use General Electric specific Gradient
    #     Echo Field Map for readout distortion correction
    #
    #   "SiemensFieldMap"
    #     Average any repeats and use Siemens specific Gradient Echo
    #     Field Maps for readout distortion correction
    #
    # Current Setup is for Siemens specific Gradient Echo Field Maps
    #
    #   The following settings for AvgrdcSTRING, MagnitudeInputName,
    #   PhaseInputName, and TE are for using the Siemens specific
    #   Gradient Echo Field Maps that are collected and used in the
    #   standard HCP protocol.
    #
    #   Note: The AvgrdcSTRING variable could also be set to the value
    #   "FIELDMAP" which is equivalent to "SiemensFieldMap".
    AvgrdcSTRING="SiemensFieldMap"

    # ----------------------------------------------------------------------
    # Variables related to using Siemens specific Gradient Echo Field Maps
    # ----------------------------------------------------------------------

    # The MagnitudeInputName variable should be set to a 4D magitude volume
    # with two 3D timepoints or "NONE" if not used
    MagnitudeInputName="${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_FieldMap_Magnitude.nii.gz"

    # The PhaseInputName variable should be set to a 3D phase difference
    # volume or "NONE" if not used
    PhaseInputName="${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_FieldMap_Phase.nii.gz"

    # Test for the existance of the Gradient Echo Fieldmap images
    UseGradEchoFieldmap="TRUE"
    [[ ! -r $MagnitudeInputName ]] || [[ ! -r $PhaseInputName ]] && UseGradEchoFieldmap="FALSE"

    # The TE variable should be set to 2.46ms for 3T scanner, 1.02ms for 7T
    # scanner or "NONE" if not using
    if [[ $Scanner = "3T" ]] ; then
      TE="2.46"
    elif [[ $Scanner = "7T" ]] ; then
      TE="1.02"
    fi

    # if no gradient echo fieldmap is detected, set all configurations to NONE
    if [[ $UseGradEchoFieldmap = "FALSE" ]] ; then
      AvgrdcSTRING="NONE"
      MagnitudeInputName="NONE"
      PhaseInputName="NONE"
      TE="NONE"
    fi

    # ----------------------------------------------------------------------
    # Variables related to using Spin Echo Field Maps
    # ----------------------------------------------------------------------

    # The following variables would be set to values other than "NONE" for
    # using Spin Echo Field Maps (i.e. when AvgrdcSTRING="TOPUP")

    # The SpinEchoPhaseEncodeNegative variable should be set to the
    # spin echo field map volume with a negative phase encoding direction
    # (LR in 3T HCP data, AP in 7T HCP data), and set to "NONE" if not
    # using Spin Echo Field Maps (i.e. if AvgrdcSTRING is not equal to
    # "TOPUP")
    #
    # Example values for when using Spin Echo Field Maps:
    #   ${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_SpinEchoFieldMap_LR.nii.gz
    #   ${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_SpinEchoFieldMap_AP.nii.gz
    SpinEchoPhaseEncodeNegative="NONE"

    # The SpinEchoPhaseEncodePositive variable should be set to the
    # spin echo field map volume with positive phase encoding direction
    # (RL in 3T HCP data, PA in 7T HCP data), and set to "NONE" if not
    # using Spin Echo Field Maps (i.e. if AvgrdcSTRING is not equal to "TOPUP")
    #
    # Example values for when using Spin Echo Field Maps:
    #   ${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_SpinEchoFieldMap_RL.nii.gz
    #   ${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_SpinEchoFieldMap_PA.nii.gz
    SpinEchoPhaseEncodePositive="NONE"

    # Echo Spacing or Dwelltime of spin echo EPI MRI image. Specified in seconds.
    # Set to "NONE" if not used.
    #
    # Dwelltime = 1/(BandwidthPerPixelPhaseEncode * # of phase encoding samples)
    # DICOM field (0019,1028) = BandwidthPerPixelPhaseEncode
    # DICOM field (0051,100b) = AcquisitionMatrixText first value (# of phase encoding samples).
    # On Siemens, iPAT/GRAPPA factors have already been accounted for.
    #
    # Example value for when using Spin Echo Field Maps:
    #   0.000580002668012
    DwellTime="NONE"

    # Spin Echo Unwarping Direction
    # x or y (minus or not does not matter)
    # "NONE" if not used
    #
    # Example values for when using Spin Echo Field Maps: x, -x, y, -y
    # Note: +x or +y are not supported. For positive values, DO NOT include the + sign
    SEUnwarpDir="NONE"

    # Topup Configuration file
    # "NONE" if not used
    TopupConfig="NONE"

    # ----------------------------------------------------------------------
    # Variables related to using General Electric specific Gradient Echo
    # Field Maps
    # ----------------------------------------------------------------------

    # The following variables would be set to values other than "NONE" for
    # using General Electric specific Gradient Echo Field Maps (i.e. when
    # AvgrdcSTRING="GeneralElectricFieldMap")

    # Example value for when using General Electric Gradient Echo Field Map
    #
    # GEB0InputName should be a General Electric style B0 fieldmap with two
    # volumes
    #   1) fieldmap in deg and
    #   2) magnitude,
    # set to NONE if using TOPUP or FIELDMAP/SiemensFieldMap
    #
    #   GEB0InputName="${StudyFolder}/${Subject}/unprocessed/3T/T1w_MPR1/${Subject}_3T_GradientEchoFieldMap.nii.gz"
    GEB0InputName="NONE"

    # Templates

    # Hires T1w MNI template
    #T1wTemplate="${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm.nii.gz"
    T1wTemplate="${HCPPIPEDIR_Templates}/MNI152_T1_1mm.nii.gz"

    # Hires brain extracted MNI template
    #T1wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm_brain.nii.gz"
    T1wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T1_1mm_brain.nii.gz"

    # Lowres T1w MNI template
    T1wTemplate2mm="${HCPPIPEDIR_Templates}/MNI152_T1_2mm.nii.gz"

    # Hires T2w MNI Template
    #T2wTemplate="${HCPPIPEDIR_Templates}/MNI152_T2_0.7mm.nii.gz"
    T2wTemplate="${HCPPIPEDIR_Templates}/MNI152_T2_1mm.nii.gz"

    # Hires T2w brain extracted MNI Template
    #T2wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T2_0.7mm_brain.nii.gz"
    T2wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T2_1mm_brain.nii.gz"

    # Lowres T2w MNI Template
    T2wTemplate2mm="${HCPPIPEDIR_Templates}/MNI152_T2_2mm.nii.gz"

    # Hires MNI brain mask template
    #TemplateMask="${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm_brain_mask.nii.gz"
    TemplateMask="${HCPPIPEDIR_Templates}/MNI152_T1_1mm_brain_mask.nii.gz"

    # Lowres MNI brain mask template
    Template2mmMask="${HCPPIPEDIR_Templates}/MNI152_T1_2mm_brain_mask_dil.nii.gz"

    # Structural Scan Settings
		#
		# set all these values to NONE if not doing readout distortion correction
		#
		# Sample values for when using General Electric Gradient Echo Field Maps
		#   T1wSampleSpacing="0.000011999" # For General Electric scanners, 1/((0018,0095)*(0028,0010))
		#   T2wSampleSpacing="0.000008000" # For General Electric scanners, 1/((0018,0095)*(0028,0010))
		#   UnwarpDir="y"

		# The values set below are for the HCP Protocol using the Siemens
		# Connectom Scanner

		# DICOM field (0019,1018) in s or "NONE" if not used
		T1wSampleSpacing="0.0000074"

		# DICOM field (0019,1018) in s or "NONE" if not used
		T2wSampleSpacing="0.0000021"

		# z appears to be best for Siemens Gradient Echo Field Maps
		# or "NONE" if not used
		UnwarpDir="z"

    # The values below are example values for the FMRIB 7T (commented out)
    #T1wSampleSpacing="0.00001627604167"
    #T2wSampleSpacing="0.00000500160051"
    #UnwarpDir="y-" # y- refers to A>>P

    # if no gradient echo fieldmap is detected, set all configurations to NONE
    if [[ $UseGradEchoFieldmap = "FALSE" ]] ; then
      T1wSampleSpacing="NONE"
      T2wSampleSpacing="NONE"
      UnwarpDir="NONE"
    fi

    # Config settings of the "Oxford Structural" fork
    InitBiasCorr="TRUE" # perform initial bias correct to improve registration ("TRUE", "FALSE")
    BiasCorr="FAST" # method for actual bias correction (after registration) set to "sqrtT1wbyT2w" for HCP default, or set to "FAST" to use RobustBiasCorr.sh based on fsl_anat and fast
    if [[ $Scanner = "7T" ]] ; then
      MaskArtery="TRUE" # mask arteries in registration and bias correction (important for 7T data) ("TRUE", "FALSE")
      BiasFieldSmoothingSigma="5"
    else
      MaskArtery="FALSE"
      #BiasFieldSmoothingSigma="8"
      BiasFieldSmoothingSigma="5"
    fi
    FixNegValMethod="thr" # method to ensure the image does not contain negative values (after spline interpolation) (none, thr, abs, smooth)

    # Other Config Settings

		# BrainSize in mm, 150 for humans
		BrainSize="150"

		# FNIRT 2mm T1w Config
		FNIRTConfig="${HCPPIPEDIR_Config}/T1_2_MNI152_2mm.cnf"

		# Location of Coeffs file or "NONE" to skip
		# GradientDistortionCoeffs="${HCPPIPEDIR_Config}/coeff_SC72C_Skyra.grad"

		# Set to NONE to skip gradient distortion correction
		GradientDistortionCoeffs="NONE"

    # Run (or submit to be run) the PreFreeSurferPipeline.sh script
		# with all the specified parameter values

    ${queuing_command} ${HCPPIPEDIR}/PreFreeSurfer/PreFreeSurferPipeline.sh \
      --path="$StudyFolder" \
      --subject="$Subject" \
      --t1="$T1wInputImages" \
      --t2="$T2wInputImages" \
      --t1template="$T1wTemplate" \
      --t1templatebrain="$T1wTemplateBrain" \
      --t1template2mm="$T1wTemplate2mm" \
      --t2template="$T2wTemplate" \
      --t2templatebrain="$T2wTemplateBrain" \
      --t2template2mm="$T2wTemplate2mm" \
      --templatemask="$TemplateMask" \
      --template2mmmask="$Template2mmMask" \
      --brainsize="$BrainSize" \
      --fnirtconfig="$FNIRTConfig" \
      --fmapmag="$MagnitudeInputName" \
      --fmapphase="$PhaseInputName" \
      --fmapgeneralelectric="$GEB0InputName" \
      --echodiff="$TE" \
      --SEPhaseNeg="$SpinEchoPhaseEncodeNegative" \
      --SEPhasePos="$SpinEchoPhaseEncodePositive" \
      --echospacing="$DwellTime" \
      --seunwarpdir="$SEUnwarpDir" \
      --t1samplespacing="$T1wSampleSpacing" \
      --t2samplespacing="$T2wSampleSpacing" \
      --unwarpdir="$UnwarpDir" \
      --gdcoeffs="$GradientDistortionCoeffs" \
      --avgrdcmethod="$AvgrdcSTRING" \
      --topupconfig="$TopupConfig" \
      --initbiascorr="$InitBiasCorr" \
      --biascorr="$BiasCorr" \
      --bfsigma="$BiasFieldSmoothingSigma" \
      --maskartery="$MaskArtery" \
      --fixnegvalmethod="$FixNegValMethod" \
      --printcom=$PRINTCOM

  done
}

# Invoke the main function to get things started
main "$@"
