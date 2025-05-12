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

cd "${out_dir}"

fsleyes render -of mask.png \
	--scene lightbox --displaySpace world --size 1200 600 \
	--hideCursor  -nc 8 -zr -50 70 -ll -ns 24 \
	${meanfmri_niigz} --overlayType volume \
	${mask_niigz} --overlayType label --outline --outlineWidth 2 --lut harvard-oxford-subcortical

fsleyes render -of alff.png \
	--scene lightbox --displaySpace world --size 1200 600 \
	--hideCursor -nc 8 -zr -50 70 -ll -ns 24 \
	${alff_niigz} --overlayType volume -dr 0 3 \
	${mask_niigz} --overlayType label --outline --outlineWidth 2 --lut harvard-oxford-subcortical

fsleyes render -of reho.png \
	--scene lightbox --displaySpace world --size 1200 600 \
	--hideCursor -nc 8 -zr -50 70 -ll -ns 24 \
	${reho_niigz} --overlayType volume -dr 0 1 \
	${mask_niigz} --overlayType label --outline --outlineWidth 2 --lut harvard-oxford-subcortical

convert \
    -gravity NorthWest -pointsize 24 -fill white -undercolor black -annotate +10+10 " Mean fMRI " \
    mask.png mask.png

convert \
    -gravity NorthWest -pointsize 24 -fill white -undercolor black -annotate +10+10 " Normed fALFF " \
    alff.png alff.png

convert \
    -gravity NorthWest -pointsize 24 -fill white -undercolor black -annotate +10+10 " ReHo " \
    reho.png reho.png

montage \
    -mode concatenate mask.png alff.png reho.png \
    -tile 1x -quality 100 -background white -gravity center \
    -border 20 -bordercolor white all.png

convert \
    -size 1300x1700 xc:white \
    -gravity South \( all.png -resize 1200x1600 \) -composite \
    -gravity North -pointsize 24 -fill black -annotate +0+25 "ALFF/ReHo - ${label_info}" \
    -gravity North -pointsize 24 -fill black -annotate +0+60 "$(date)" \
    alff-reho.pdf
