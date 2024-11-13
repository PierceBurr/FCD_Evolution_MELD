##############################################################################
# This script calculates the absolute (modulus) intrinsic curvature 
# and handles errors during execution.

#import relevant packages
import numpy as np
import nibabel as nb
import argparse
import io_meld as io
import os
import sys

#parse commandline arguments pointing to subject_dir etc
parser = argparse.ArgumentParser(description='filter intrinsic curvature')
parser.add_argument('subject_dir', type=str,
                    help='path to subject dir')
parser.add_argument('subject_ids', type=str,
                    help='arrays of ids separated by space')

args = parser.parse_args()

# Save subjects dir and subject ids. Import the text file containing subject ids
subject_dir = args.subject_dir
subject_ids = np.array(args.subject_ids.split(' '))

hemis = ['lh', 'rh']

# Loop over hemispheres and subjects
for h in hemis:
    for s in subject_ids:
        try:
            # Check if the output file already exists
            output_file = os.path.join(subject_dir, s, 'xhemi/surf_meld', f'{h}.pial.K_filtered.mgh')
            if os.path.isfile(output_file):
                print(f"Filtered file already exists for {h} hemisphere in subject {s}, skipping...")
                continue

            # Load the original curvature file
            input_file = os.path.join(subject_dir, s, 'surf_meld', f'{h}.pial.K.mgh')
            if not os.path.isfile(input_file):
                raise FileNotFoundError(f"Curvature file not found: {input_file}")
            
            print(f"Processing subject {s}, hemisphere {h}...")

            # Load the curvature data
            demo = nb.load(input_file)
            curvature = io.load_mgh(input_file)

            # Ensure the data is loaded correctly
            if curvature is None or curvature.size == 0:
                raise ValueError(f"Failed to load curvature data from {input_file}")

            # Compute the absolute (modulus) values of the curvature
            curvature = np.absolute(curvature)

            # Save the filtered curvature data
            io.save_mgh(output_file, curvature, demo)
            print(f"Saved filtered curvature for subject {s}, hemisphere {h} to {output_file}")

        except FileNotFoundError as fnf_error:
            print(f"ERROR: {fnf_error}", file=sys.stderr)

        except ValueError as val_error:
            print(f"ERROR: {val_error}", file=sys.stderr)

        except Exception as e:
            print(f"Unexpected ERROR while processing subject {s}, hemisphere {h}: {e}", file=sys.stderr)
