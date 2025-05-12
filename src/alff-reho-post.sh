#!/usr/bin/env bash
#
# QC report for ALFF / ReHo, to be run in an FSL container with ImageMagick
#
# Show the normalized fractional ALFF as used in
# McHugo M, Rogers BP, Avery SN, Armstrong K, Blackford JU, Vandekar SN, 
# Roeske MJ, Woodward ND, Heckers S. Increased amplitude of hippocampal 
# low frequency fluctuations in early psychosis: A two-year follow-up 
# study. Schizophr Res. 2022 Mar;241:260-266. 
# doi: 10.1016/j.schres.2022.02.003. PMID: 35180665; PMCID: PMC8960358.
# https://pmc.ncbi.nlm.nih.gov/articles/PMC8960358/


export out_dir=/OUTPUTS
export label_info=""
export meanfmri_niigz=/OUTPUTS/meanfmri.nii.gz
export mask_niigz=/OUTPUTS/mask.nii.gz
export alff_niigz=/OUTPUTS/rsfc_fALFF_norm.nii.gz
export reho_niigz=/OUTPUTS/rsfc_REHO.nii.gz

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in      
        --out_dir)           export out_dir="$2";           shift; shift ;;
        --label_info)        export label_info="$2";        shift; shift ;;
        --meanfmri_niigz)    export meanfmri_niigz="$2";    shift; shift ;;
        --mask_niigz)        export mask_niigz="$2";        shift; shift ;;
        --alff_niigz)        export alff_niigz="$2";        shift; shift ;;
        --reho_niigz)        export reho_niigz="$2";        shift; shift ;;
        *) echo "Input ${1} not recognized"; shift ;;
    esac
done

