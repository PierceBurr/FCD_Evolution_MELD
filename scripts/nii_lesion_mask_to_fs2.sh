# This script registers a lesion mask done in mricron or any other software creating a nifti lesion mask
# (?h.lesion.nii) to the freesurfer surfaces
# It assumes that the ?h.lesion.nii is in the main folder 

SUBJECT_DIR=$1  # FreeSurfer output directory
subject_list=$2 # Single subject ID (now treated as a subject, not a file)
script_dir=$3   # Directory where scripts are located

cd "$SUBJECT_DIR" || { echo "ERROR: Failed to change directory to $SUBJECT_DIR"; exit 1; }
export SUBJECTS_DIR="$SUBJECT_DIR"

# Directly assign the passed subject ID (no need for 'cat' anymore)
subjects="$subject_list"
echo "Subjects to process: $subjects"

for s in $subjects
do
    python "$script_dir"/create_identity_reg.py "$s"

    if [ ! -d  "$s/surf_meld" ]; then
        mkdir "$s/surf_meld"
    fi

    # Unzip if the lesion file exists in .nii.gz format
    if [ -e "$s/rh.lesion.nii.gz" ]; then
        gunzip "$s/rh.lesion.nii.gz"
    fi

    # Process right hemisphere lesion mask
    if [ -e "$s/rh.lesion.nii" ]; then
        echo "Transforming right hemisphere lesion for subject $s"
        mri_convert "$s/rh.lesion.nii" "$s/mri/rh.lesion.mgz" -rl "$s/mri/brain.mgz"
        mri_vol2surf --src "$s/mri/rh.lesion.mgz" --out "$s/surf_meld/rh.lesion.mgh" --srcreg "$s/mri/transforms/Identity.dat" --hemi rh
    elif [ -e "$s/lh.lesion.nii" ]; then
        # Process left hemisphere lesion mask if right hemisphere is not found
        echo "Transforming left hemisphere lesion for subject $s"
        mri_convert "$s/lh.lesion.nii" "$s/mri/lh.lesion.mgz" -rl "$s/mri/brain.mgz"
        mri_vol2surf --src "$s/mri/lh.lesion.mgz" --out "$s/surf_meld/lh.lesion.mgh" --srcreg "$s/mri/transforms/Identity.dat" --hemi lh
    else
        echo "No lesion file found for subject $s."
    fi
done

# Call lesion blobbing script and template surface processing
python "$script_dir/lesion_blobbing2.py" "$SUBJECT_DIR" "$subjects"
bash "$script_dir/lesion_labels2.sh" "$SUBJECT_DIR" "$subjects"
