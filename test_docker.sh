#!/usr/bin/env bash

docker run \
    --user root \
    --entrypoint bash \
    --mount type=bind,src=$(pwd -P),dst=/wkdir \
    baxterprogers/afni:24.2.06 \
    -c ' \
    /wkdir/src/alff-reho-main.py \
    --fmri_niigz /wkdir/OUTPUTS/fmri.nii.gz \
    --mask_niigz /wkdir/OUTPUTS/mask.nii.gz \
    --ort_csv /wkdir/OUTPUTS/confounds.csv \
    --out_dir /wkdir/OUTPUTS \
    --bphi_hz 0.10 \
    '
