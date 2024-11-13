##############################################################################
# This script defragments the lesion label, filling in holes by expanding and contracting across the surface

#import relevant packages
import numpy as np
import nibabel as nb
import argparse
import os
import io_meld as io

def get_neighbours(surface):
    coords, faces = nb.freesurfer.io.read_geometry(surface)
    neighbours = [[] for i in range(len(coords))]
    for tri in faces:
        neighbours[tri[0]].extend([tri[1], tri[2]])
        neighbours[tri[2]].extend([tri[1], tri[0]])
        neighbours[tri[1]].extend([tri[0], tri[2]])
    # Get unique neighbours
    for k in range(len(neighbours)):
        neighbours[k] = f7(neighbours[k])
    return np.array(neighbours, dtype=object)


def f7(seq):
    seen = set()
    seen_add = seen.add
    return [x for x in seq if not (x in seen or seen_add(x))]


def defrag_surface(lesion, surface):
    neighbours = get_neighbours(surface)
    # find basic lesion vertices
    patch = np.where(lesion > 0)[0]
    steps = 5
    # expanding stage: add neighbours
    for k in range(steps):
        new_patch = neighbours[patch]
        # shrinking stage: remove edge vertices
        out = np.concatenate(new_patch).ravel()
        patch = np.unique(out)
    not_patch = np.setdiff1d(list(range(len(neighbours))), patch)
    for k in range(steps):
        new_not_patch = neighbours[not_patch]
        out = np.concatenate(new_not_patch).ravel()
        not_patch = np.unique(out)
    patch = np.setdiff1d(list(range(len(neighbours))), not_patch)
    lesion[:] = 0
    lesion[patch] = 1
    return lesion


# parse commandline arguments pointing to subject_dir etc
parser = argparse.ArgumentParser(description='Defragment volumetrically created lesion masks on the surface')
parser.add_argument('subject_dir', type=str,
                    help='Path to subject dir')
parser.add_argument('subject_id', type=str,
                    help='Single subject ID')

args = parser.parse_args()

# Debugging: Print parsed arguments
print(f"Subject directory: {args.subject_dir}")
print(f"Subject ID: {args.subject_id}")

# Save subject dir and subject ID
subject_dir = args.subject_dir
subject_id = args.subject_id

# Verify if subject directory exists
subject_path = os.path.join(subject_dir, subject_id)
if not os.path.isdir(subject_path):
    print(f"ERROR: Subject path {subject_path} is not a valid directory.")
    exit(1)

print(f"Processing subject: {subject_id}")

# List of hemispheres
hemis = ['lh', 'rh']

# Loop over hemispheres and process each
for h in hemis:
    # Debugging: Print which hemisphere is being processed
    print(f"Processing hemisphere: {h}")

    # Only do lesion mask if present
    lesion_file = os.path.join(subject_dir, subject_id, 'surf_meld', f'{h}.lesion.mgh')
    print(f"Looking for lesion file: {lesion_file}")

    if os.path.isfile(lesion_file):
        print(f"Found lesion file for {h} hemisphere. Proceeding with defragmentation.")
        demo = nb.load(lesion_file)
        lesion = io.import_mgh(lesion_file)
        print(f"Lesion file loaded successfully for {h} hemisphere.")

        # Debugging: Check lesion data shape
        print(f"Lesion data shape: {lesion.shape}")

        defragged = defrag_surface(lesion, os.path.join(subject_dir, subject_id, 'surf', f'{h}.white'))
        print(f"Defragmentation completed for {h} hemisphere.")

        output_file = os.path.join(subject_dir, subject_id, 'surf_meld', f'{h}.lesion_linked.mgh')
        io.save_mgh(output_file, defragged, demo)
        print(f"Saved defragged lesion file to: {output_file}")
    else:
        print(f"No lesion file found for {subject_id}, hemisphere {h}. Skipping.")
