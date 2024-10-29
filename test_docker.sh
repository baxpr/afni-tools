#!/usr/bin/env bash

docker run \
    --entrypoint bash \
    --mount type=bind,src=$(pwd -P)/INPUTS,dst=/INPUTS \
    --mount type=bind,src=$(pwd -P)/OUTPUTS,dst=/OUTPUTS \
    baxterprogers/afni:24.2.06 \
    -c ' \
    --fmri_niigz /OUTPUTS/fmri.nii.gz \
    --mask_niigz /OUTPUTS/mask.nii.gz \
    --ort_csv /OUTPUTS/confounds.csv \
    --bphi_hz 0.10 \
    '
