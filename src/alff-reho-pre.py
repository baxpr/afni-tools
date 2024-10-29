#!/usr/bin/env python
#
# Preprocessing for AFNI ALFF/ReHo
#
#   Find fmri and mask images in fmriprep output and copy to outdir
#   Find confounds in fmriprep output, select/filter and store in outdir

import argparse
import bids
import os
import pandas
import shutil


parser = argparse.ArgumentParser()
parser.add_argument('--fmriprep_dir', required=True)
parser.add_argument('--out_dir', default='/OUTPUTS')
args = parser.parse_args()

# BIDS dir info
bids_fmriprep = bids.layout.BIDSLayout(args.fmriprep_dir, validate=False)

# Find the fmri preprocessed time series and verify there's only one
fmri_niigz = bids_fmriprep.get(
    extension='.nii.gz',
    datatype='func',
    desc='preproc',
    suffix='bold',
    )
if len(fmri_niigz)!=1:
    raise Exception(f'Found {len(fmri_niigz)} fmri .nii.gz instead of 1')
fmri_niigz = fmri_niigz[0].path
shutil.copyfile(fmri_niigz, os.path.join(args.out_dir,'fmri.nii.gz'))

# Now the brain mask
mask_niigz = bids_fmriprep.get(
    extension='.nii.gz',
    datatype='func',
    desc='brain',
    suffix='mask',
    )
if len(mask_niigz)!=1:
    raise Exception(f'Found {len(mask_niigz)} mask .nii.gz instead of 1')
mask_niigz = mask_niigz[0].path
shutil.copyfile(mask_niigz, os.path.join(args.out_dir,'mask.nii.gz'))

# Find desc-confounds_timeseries.tsv file in fmriprep output and
# verify there's only one
conf_tsv = bids_fmriprep.get(
    extension='tsv',
    desc='confounds',
    suffix='timeseries',
    )
if len(conf_tsv)!=1:
    raise Exception(f'Found {len(conf_tsv)} confounds.tsv instead of 1')
conf_tsv = conf_tsv[0].path
conf = pandas.read_csv(conf_tsv, sep='\t')

# Discrete cosines handle detrending / lowpass filter for us. They are needed 
# with compcor confounds because compcor are computed after detrending.
keep_cols = [x for x in conf.columns if x.startswith('cosine')]

# Combined CSF/WM compcor (first few), translation, rotation
keep_cols = keep_cols + [
    'a_comp_cor_00',
    'a_comp_cor_01',
    'a_comp_cor_02',
    'a_comp_cor_03',
    'a_comp_cor_04',
    'a_comp_cor_05',
    'trans_x',
    'trans_y',
    'trans_z',
    'rot_x',
    'rot_y',
    'rot_z',
    ]

# Keep just the ones we want, normalize, and save to file for 3dRSFC -ort option
conf = conf[keep_cols]
conf = (conf-conf.mean())/conf.std()
conf.to_csv(os.path.join(args.out_dir, 'confounds.csv'), index=False)
