########### master script for running the meld pipeline.  ########



subjects_dir="$1"
subject_ids="$2"
script_dir="$3"


#register to symmetric fsaverage xhemi
echo "Creating registration to template surface"
bash "$script_dir"/create_xhemi2.sh "$subjects_dir" "$subject_ids"

#create basic features
echo "Sampling features in native space"
bash "$script_dir"/sample_T1_smooth_features2.sh "$subjects_dir" "$subject_ids" "$script_dir"
bash "$script_dir"/sample_FLAIR_smooth_features2.sh "$subjects_dir" "$subject_ids" "$script_dir"

echo "Filtering intrinsic curvature"
python "$script_dir"/filter_intrinsic_curvature2.py "$subjects_dir" "$subject_ids"

# move features and lesions to template
echo "Moving features to template surface"
bash "$script_dir"/move_to_xhemi_flip.sh "$subjects_dir" "$subject_ids"

echo "transforming .nii lists, blobbing and creating lesionlinked file"
bash "$script_dir"/nii_lesion_mask_to_fs2.sh "$subjects_dir" "$subject_ids" "$script_dir"
