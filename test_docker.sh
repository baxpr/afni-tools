#!/usr/bin/env bash

docker run \
    --entrypoint bash \
    --mount type=bind,src=$(pwd -P),dst=/wkdir \
    baxterprogers/afni:24.2.06 \
    -c ' \
    /wkdir/src/alff-reho-main.py \
    --fmri_niigz /wkdir/OUTPUTS/fmri.nii.gz \
    --mask_niigz /wkdir/OUTPUTS/mask.nii.gz \
    --ort_csv /OUTPUTS/confounds.csv \
    --bphi_hz 0.10 \
    '
