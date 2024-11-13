#!/bin/bash

#script that registers T1 to FlAIR 

# Path to the subject list file
subject_list="path/scripts/subject_list2.txt"

# Loop through each subject in the list
while IFS= read -r subject; do
  echo "Processing subject: $subject"
  
  # Define paths for each subject
  t1_image_mgz="/pathto/$subject/mri/T1.mgz"
  t1_image_nii="/pathto/$subject/T1.nii.gz"
  flair_image="/pathto/$subject/flair.nii"
  output_dir="/pathto/$subject"
  
  # Create output directory if it doesn't exist
  mkdir -p $output_dir

  # Step 1: Convert T1-weighted image from MGZ to NIFTI
  mri_convert $t1_image_mgz $t1_image_nii

  # Step 2: Register the FLAIR image to the T1-weighted image with --satit
  mri_robust_register --mov $flair_image \
                      --dst $t1_image_nii \
                      --lta $output_dir/flair_to_t1.lta \
                      --mapmov $output_dir/flair_registered.nii.gz \
                      --satit

  # Step 3: Convert the registered FLAIR image back to MGZ
  mri_convert $output_dir/flair_registered.nii.gz $output_dir/flair_registered.mgz

  # Optional: Verify the results using Freeview (commented out for batch processing)
  # freeview $t1_image_mgz $output_dir/flair_registered.mgz

done < "$subject_list"

echo "All subjects processed."



