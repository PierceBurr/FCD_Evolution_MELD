MELD_DIR=$1
SUBJECT_DIR="$MELD_DIR"/output/
subject_list="$SUBJECT_DIR""subject_ids.txt"
script_dir="$MELD_DIR"/scripts/
echo $SUBJECT_DIR
cd "$SUBJECT_DIR"
export SUBJECTS_DIR="$SUBJECT_DIR"
## Import list of subjects
subjects=$(<"$subject_list")
echo $subjects
for s in $subjects;
do


python "$script_dir"create_identity_reg.py "$s"

if [ ! -d  "$s"/surf_meld ];
then
mkdir "$s"/surf_meld
fi

#detect if lesion and which hemisphere
if [ -e  "$s"/mri/rh.lesion.nii ];
then
mri_vol2surf --src "$s"/mri/rh.lesion.nii --out "$s"/surf_meld/rh.lesion.mgh --hemi rh --srcreg "$s"/mri/transforms/Identity.dat

elif [ -e  "$s"/mri/lh.lesion.nii ];
then
mri_vol2surf --src "$s"/mri/lh.lesion.nii --out "$s"/surf_meld/lh.lesion.mgh --hemi lh --srcreg "$s"/mri/transforms/Identity.dat
fi

done

python "$script_dir"lesion_blobbing.py "$SUBJECT_DIR" "$subject_list"


