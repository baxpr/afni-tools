#!/usr/bin/env bash
#
# Pipeline for refacing an image using AFNI.
#
# Requires AFNI container.

# Initialize defaults (will be changed later if passed as options)
export img_niigz=/INPUTS/t1.nii.gz
export OUT_DIR=/OUTPUTS

# Parse options
while [[ $# -gt 0 ]]; do
	key="${1}"
	case $key in
		--img_niigz)
			export img_niigz="${2}"; shift; shift ;;
		--out_dir)
			export out_dir="${2}"; shift; shift ;;
		*)
			echo Unknown input "${1}"; shift ;;
	esac
done

# Reface
@afni_refacer_run \
	-input "${img_niigz}" \
	-mode_all \
	-prefix "${out_dir}"/img
