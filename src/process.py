#!/usr/bin/env python

import argparse
import bids
import glob
import os
import pandas
import subprocess


parser = argparse.ArgumentParser()
parser.add_argument('--fmriprep_dir', required=True)
parser.add_argument('--out_dir', default='/OUTPUTS')
parser.add_argument('--bphi_hz', default='0.10', type=str)
args = parser.parse_args()


# Work in the output dir to simplify file management
os.chdir(args.out_dir)

# BIDS dir info
bids_fmriprep = bids.layout.BIDSLayout(args.fmriprep_dir, validate=False)

# Find the fmri preprocessed time series and verify there's only one
fmri_niigz = bids_fmriprep.get(
    extension='.nii.gz',
    desc='preproc',
    suffix='bold',
    )
if len(fmri_niigz)!=1:
    raise Exception(f'Found {len(fmri_niigz)} fmri .nii.gz instead of 1')
fmri_niigz = fmri_niigz[0].path

# Now the brain mask
mask_niigz = bids_fmriprep.get(
    extension='.nii.gz',
    desc='brain',
    suffix='mask',
    )
if len(mask_niigz)!=1:
    raise Exception(f'Found {len(mask_niigz)} mask .nii.gz instead of 1')
mask_niigz = mask_niigz[0].path

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
conf.to_csv('confounds.csv', index=False)

# Run the 3dRSFC command
# https://github.com/baxpr/afni-alff/blob/6dc80cf/afni-alff.sh
subprocess.run([
    '3dRSFC',
    '-nosat',
    '-nodetrend',
    '-no_rs_out',
    '-ort', 'confounds.csv',
    '-band', '0.00', args.bphi_hz,
    '-input', fmri_niigz,
    '-mask', mask_niigz,
    '-prefix', 'rsfc',
    ])

# Normalizing factors
out = subprocess.run([
    '3dmaskave',
    '-mask', mask_niigz,
    'rsfc_ALFF+tlrc.HEAD',
    ])
mean_alff = out.stdout.split()[0]
print(f'Mean ALFF: {mean_alff}')

out = subprocess.run([
    '3dmaskave',
    '-mask', mask_niigz,
    'rsfc_fALFF+tlrc.HEAD',
    ])
mean_falff = out.stdout.split()[0]
print(f'Mean fALFF: {mean_falff}')

# Normalize
subprocess.run([
    '3dcalc',
    '-a', 'rsfc_ALFF+tlrc.HEAD',
    f'-expr "a / {mean_alff}"',
    '-prefix', 'rsfc_ALFF_norm',
    ])
subprocess.run([
    '3dcalc',
    '-a', 'rsfc_fALFF+tlrc.HEAD',
    f'-expr "a / {mean_falff}"',
    '-prefix', 'rsfc_fALFF_norm',
    ])

# Convert to nifti
briks = glob.glob('*.BRIK')
for brik in briks:
    subprocess.run(['3dAFNItoNIFTI', brik])
subprocess.run(['gzip', '*.nii'])

