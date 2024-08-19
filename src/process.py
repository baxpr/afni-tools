#!/usr/bin/env python

import argparse
import bids
import os
import pandas


parser = argparse.ArgumentParser()
parser.add_argument('--fmriprep_dir', required=True)
parser.add_argument('--out_dir', default='/OUTPUTS')
args = parser.parse_args()


# Find desc-confounds_timeseries.tsv file in fmriprep output and
# verify there's only one
bids_fmriprep = bids.layout.BIDSLayout(args.fmriprep_dir, validate=False)
conf_tsv = bids_fmriprep.get(
    extension='tsv',
    desc='confounds',
    suffix='timeseries',
    )
if len(conf_tsv)!=1:
    raise Exception(f'Found {len(conf_tsv)} confounds.tsv instead of 1')
conf_tsv = conf_tsv[0].path
conf = pandas.read_csv(conf_tsv, sep='\t')

# Discrete cosines handle detrending for us. They are needed with
# compcor confounds because compcor are computed after detrending.
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

# Keep just the ones we want and save to file for 3dRSFC -ort option
conf[keep_cols].to_csv(os.path.join(args.out_dir, 'alff_confounds.csv'), index=False)

