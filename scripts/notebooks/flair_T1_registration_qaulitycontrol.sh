#!/bin/bash

#scipt to check registration of T1 to FLAIR 

# Set the FreeSurfer subjects directory
export SUBJECTS_DIR='/Users/pierceburr/Documents/Documents/UCL_dissertation/meld/output'

# Function to open FreeView for a subject
open_freeview() {
    local subject="$1"
    local t1_image="${SUBJECTS_DIR}/${subject}/mri/rawavg.mgz"
    local flair_image="${SUBJECTS_DIR}/${subject}/mri/FLAIR_registered.mgz"
    
    # Check if T1 and FLAIR images exist
    if [ ! -f "$t1_image" ]; then
        echo "Error: T1 image does not exist for $subject at $t1_image"
        return 1
    fi
    
    if [ ! -f "$flair_image" ]; then
        echo "Error: FLAIR image does not exist for $subject at $flair_image"
        return 1
    fi
    
    # Open FreeView with T1 and FLAIR images
    freeview -v "$t1_image" -v "$flair_image"
}

# Ask for the subject name
echo "Enter the subject name:"
read subject_name

# Open FreeView for the specified subject
open_freeview "$subject_name"
