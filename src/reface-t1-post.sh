#!/usr/bin/env bash
#
# QC PDF for AFNI reface.
#
# Requires ImageMagick.

# Initialize defaults (will be changed later if passed as options)
export label_string=
export OUT_DIR=/OUTPUTS

# Parse options
while [[ $# -gt 0 ]]; do
	key="${1}"
	case $key in
		--label_string)
			export label_string="${2}"; shift; shift ;;
		--out_dir)
			export out_dir="${2}"; shift; shift ;;
		*)
			echo Unknown input "${1}"; shift ;;
	esac
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
		"${label_string}  :   ${piece}" \
		-gravity SouthEast -pointsize 48 -annotate +100+50 "${thedate}" \
		${piece}.png

done

convert deface.png face.png face_plus.png reface.png reface_plus.png "${out_dir}"/refacer.pdf
rm deface.png face.png face_plus.png reface.png reface_plus.png
