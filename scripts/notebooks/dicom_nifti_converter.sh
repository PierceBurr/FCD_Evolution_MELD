#!/bin/bash
#scipt that converts dicoms to nifti. Ensure files are in Bids format 
# Ensure you have done the following before: conda install conda-forge::dcm2niix

# Check if dcm2niix is installed
if ! command -v dcm2niix &> /dev/null; then
    echo "dcm2niix could not be found. Please install it using 'conda install -c conda-forge dcm2niix' or another method."
    exit 1
fi

# Set the base directory where 'Sub*' folders are located
base_dir='pathto/FCD_MRI'

# Iterate over 'Sub*' folders
for sub_folder in "$base_dir"/Sub*; do
    echo "Processing Sub folder: $sub_folder"
    if [[ -d "$sub_folder" ]]; then
        echo "  Found Sub folder: $sub_folder"
        
        # Iterate over 'Ses*' folders inside 'Sub*' folder
        for ses_folder in "$sub_folder"/ses_*; do
            echo "    Processing Ses folder: $ses_folder"
            if [[ -d "$ses_folder" ]]; then
                echo "      Found Ses folder: $ses_folder"
                
                # Check if 'anat' folder exists inside 'Ses*' folder
                anat_folder="$ses_folder/anat"
                if [[ -d "$anat_folder" ]]; then
                    echo "        Found 'anat' folder in $ses_folder"
                    
                    # Create 'nifti' folder within 'Ses*' folder
                    nifti_folder="$ses_folder/nifti"
                    mkdir -p "$nifti_folder"
                    echo "        Created 'nifti' folder in $ses_folder"

                    # Iterate over folders within 'anat' folder starting with "00"
                    for dicom_folder in "$anat_folder"/00*; do
                        echo "          Processing DICOM folder: $dicom_folder"
                        if [[ -d "$dicom_folder" ]]; then
                            echo "            Found DICOM folder: $dicom_folder"
                            # Run dcm2niix for each DICOM folder
                            dcm2niix -v 1 -o "$nifti_folder" "$dicom_folder"
                            if [[ $? -eq 0 ]]; then
                                echo "            Conversion complete for $dicom_folder"
                            else
                                echo "            Conversion failed for $dicom_folder"
                            fi
                        else
                            echo "            No DICOM folders found in $anat_folder"
                        fi
                    done
                else
                    echo "        No 'anat' folder found in $ses_folder"
                fi
            else
                echo "      No 'Ses_*' folder found in $sub_folder"
            fi
        done
    else
        echo "  No 'Sub*' folder found in $base_dir"
    fi
done

