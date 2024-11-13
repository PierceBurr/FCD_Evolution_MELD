#!/bin/bash

# command to initiate the meldpipeline. Ensure enviroment is initiated in your path. 
# example: source activate path/anaconda3/envs/meld_env

# Define variables
SUBJECTS_FILE="/path/subject_list.txt"
SUBJECTS_DIR="path/fastsurfer"
SCRIPTS_DIR="paths/scripts"


# Check if the subject list file exists
if [ ! -f "$SUBJECTS_FILE" ]; then
    echo "Subject list file does not exist: $SUBJECTS_FILE"
    exit 1
fi

# Read each subject from the subject list and run the pipeline
while IFS= read -r subject || [[ -n "$subject" ]]; do
    echo "Processing subject: $subject"
    ./meld_pipeline.sh "$SUBJECTS_DIR" "$subject" "$SCRIPTS_DIR"
done < "$SUBJECTS_FILE"

echo "All subjects processed."
