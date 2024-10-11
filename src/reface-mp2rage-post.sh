#!/usr/bin/env bash
#
# Finalize AFNI reface of mp2rage.
#
# Requires FSL, ImageMagick.

# Initialize defaults
export label_info=
export targets_niigz=
export out_dir=/OUTPUTS

# Parse options
while [[ $# -gt 0 ]]; do
	key="${1}"
	case $key in
		--label_info)
			label_info="${2}"; shift; shift ;;
		--targets_niigz)
            next="$2"
            while ! [[ "$next" =~ -.* ]] && [[ $# > 1 ]]; do
                targets_niigz+=("$next")
                shift
                next="$2"
            done
            shift ;;
		--out_dir)
			out_dir="${2}"; shift; shift ;;
		*)
			echo Unknown input "${1}"; shift ;;
	esac
done


# Apply face mask to target images
# Face voxels are exactly zero in the img.deface output from AFNI
for tgt in ${targets_niigz[@]}; do
    outname=$(basename ${tgt} .nii.gz)_deface.nii.gz
    echo Target ${tgt} Outname ${outname}
    fslmaths ${out_dir}/img.deface.nii.gz -bin -mul ${tgt} ${out_dir}/${outname}
done


# Make PDF
thedate=$(date)
cd "${out_dir}"/img_QC
for piece in deface face face_plus reface reface_plus ; do

	montage \
		-mode concatenate img.${piece}.???.png \
		-tile 1x -trim -quality 100 -background white -gravity center -resize 1200x1400 \
		-border 20 -bordercolor white ${piece}.png

	convert -size 2600x3365 xc:white \
		-gravity center \( ${piece}.png -resize '2400x3000' \) -composite \
		-gravity center -pointsize 48 -annotate +0-1600 \
		"${label_info}  :   ${piece}" \
		-gravity SouthEast -pointsize 48 -annotate +100+50 "${thedate}" \
		${piece}.png

done

convert deface.png face.png face_plus.png reface.png reface_plus.png "${out_dir}"/refacer.pdf
rm deface.png face.png face_plus.png reface.png reface_plus.png
