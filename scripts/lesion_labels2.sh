#!/bin/bash

##############################################################################

## This script moves the lesion label to fsaverage_sym
SUBJECT_DIR=$1
subject_list=$2  # Now treated as a single subject ID

echo "Changing directory to $SUBJECT_DIR"
cd "$SUBJECT_DIR"
export SUBJECTS_DIR="$SUBJECT_DIR"
echo "SUBJECTS_DIR set to $SUBJECT_DIR"

## Directly assign the subject ID,
subjects="$subject_list"
echo "Subjects to process: $subjects"

# for each subject do the following
for s in $subjects
do
    echo "Processing subject: $s"

    # Move lesion Label
    # Move onto left hemisphere
    if [ -e "$s/surf_meld/lh.lesion_linked.mgh" ]
    then
        echo "Found lh.lesion_linked.mgh for $s"
        echo "Applying registration and overwriting lh.on_lh.lesion.mgh..."
        mris_apply_reg --src  "$s/surf_meld/lh.lesion_linked.mgh" --trg "$s/xhemi/surf_meld/lh.on_lh.lesion.mgh" --streg $SUBJECTS_DIR/"$s"/surf/lh.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
        echo "Registration applied for lh.lesion_linked.mgh of $s"
    elif [ -e "$s/surf_meld/rh.lesion_linked.mgh" ]
    then
        echo "Found rh.lesion_linked.mgh for $s"
        echo "Applying registration and overwriting rh.on_lh.lesion.mgh..."
        mris_apply_reg --src "$s/surf_meld/rh.lesion_linked.mgh" --trg "$s/xhemi/surf_meld/rh.on_lh.lesion.mgh" --streg $SUBJECTS_DIR/"$s"/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
        echo "Registration applied for rh.lesion_linked.mgh of $s"
    else
        echo "No lesion_linked.mgh found for $s"
    fi

done
echo "All subjects processed."


