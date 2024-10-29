#!/usr/bin/env python
#
# ALFF and REHO via AFNI
#
# FIXME Needs QC post container with FSL

import argparse
import glob
import os
import subprocess


parser = argparse.ArgumentParser()
parser.add_argument('--fmri_niigz', required=True)
parser.add_argument('--mask_niigz', required=True)
parser.add_argument('--ort_csv', required=True)
parser.add_argument('--out_dir', default='/OUTPUTS')
parser.add_argument('--bphi_hz', default='0.10', type=str)
args = parser.parse_args()


# Work in the output dir to simplify file management
os.chdir(args.out_dir)

# Run the 3dRSFC command
# https://github.com/baxpr/afni-alff/blob/6dc80cf/afni-alff.sh
subprocess.run([
    '3dRSFC',
    '-nosat',
    '-nodetrend',
    '-no_rs_out',
    '-ort', args.ort_csv,
    '-band', '0.00', args.bphi_hz,
    '-input', args.fmri_niigz,
    '-mask', args.mask_niigz,
    '-prefix', 'rsfc',
    ])

# Normalizing factors
out = subprocess.run([
    '3dmaskave',
    '-mask', args.mask_niigz,
    'rsfc_ALFF+tlrc.HEAD',
    ], check=True, stdout=subprocess.PIPE, text=True).stdout
print(out)
mean_alff = out.split()[0]
print(f'Mean ALFF: {mean_alff}')

out = subprocess.check_output([
    '3dmaskave',
    '-mask', args.mask_niigz,
    'rsfc_fALFF+tlrc.HEAD',
    ], text=True)
mean_falff = out.split()[0]
print(f'Mean fALFF: {mean_falff}')

# Normalize
subprocess.run([
    '3dcalc',
    '-a', 'rsfc_ALFF+tlrc.HEAD',
    '-expr', f' "a / {mean_alff}"',
    '-prefix', 'rsfc_ALFF_norm',
    ])
subprocess.run([
    '3dcalc',
    '-a', 'rsfc_fALFF+tlrc.HEAD',
    '-expr', f'"a / {mean_falff}"',
    '-prefix', 'rsfc_fALFF_norm',
    ])

# Convert to nifti
briks = glob.glob(os.path.join(args.out_dir, '*.BRIK'))
for brik in briks:
    subprocess.run(['3dAFNItoNIFTI', brik])
niis = glob.glob(os.path.join(args.out_dir, '*.nii'))
for nii in niis:
    subprocess.run(['gzip', nii])
