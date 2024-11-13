#!/bin/bash

generate_freeview_command() {
    base_path="/Users/pierceburr/Documents/Documents/UCL_dissertation/meld/output/fastsurfer/"
    subject_path="$base_path/$1"

    if [ ! -d "$subject_path" ]; then
        echo "Subject directory '$1' not found."
        exit 1
    fi

    t1_path="$subject_path/mri/brain.mgz"
    wm_path="$subject_path/mri/wm.mgz"
    brainmask_path="$subject_path/mri/brainmask.mgz"
    aseg_path="$subject_path/mri/aseg.mgz:colormap=lut:opacity=0.2"
    lh_white_path="$subject_path/surf/lh.white:edgecolor=blue"
    lh_pial_path="$subject_path/surf/lh.pial:edgecolor=red"
    rh_white_path="$subject_path/surf/rh.white:edgecolor=blue"
    rh_pial_path="$subject_path/surf/rh.pial:edgecolor=red"
    aparc_path="$subject_path/mri/aparc+aseg.mgz:colormap=lut:opacity=0.2"

    freeview_command="freeview -v $t1_path $wm_path $brainmask_path $aseg_path $aparc_path -f $lh_white_path $lh_pial_path $rh_white_path $rh_pial_path"
    echo "Executing FreeView command:"
    echo "$freeview_command"
    $freeview_command
}

# Input subject name
echo "Enter the subject name: "
read subject_name

# Generate and execute the FreeView command
generate_freeview_command "$subject_name"


