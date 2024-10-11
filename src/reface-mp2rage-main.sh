#!/usr/bin/env bash
#
# Pipeline for refacing an mp2rage series using AFNI.
#
# Requires AFNI container

# Initialize defaults
export ref_niigz=/INPUTS/robust.nii.gz
export out_dir=/OUTPUTS

# Parse options
while [[ $# -gt 0 ]]; do
	key="${1}"
	case $key in
		--ref_niigz)
			ref_niigz="${2}"; shift; shift ;;
		--out_dir)
			out_dir="${2}"; shift; shift ;;
		*)
			echo Unknown input "${1}"; shift ;;
	esac
done

# Reface
@afni_refacer_run \
	-input "${ref_niigz}" \
	-mode_all \
	-prefix "${out_dir}"/img
