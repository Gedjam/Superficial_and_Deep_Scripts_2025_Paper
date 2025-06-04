#!/bin/bash

MNI_152_FreeSurf="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm/Distance_Analysis_2024_01_25/Distance_to_Superficial_Surface/MNI152_T1_1mm/mri"
MNI_2mm="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm/FSL_HCP1065_FA_2mm.nii.gz"

Right_Superficial="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm/Distance_Analysis_2024_01_25/Distance_to_Superficial_Surface/MNI152_T1_1mm/myaparc_36wm2max_Right_Temporal_Superficial_w_Hippo_Amyg_2mm_Iso_Superfical_Mask.nii.gz"
Right_Deep="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm/Distance_Analysis_2024_01_25/Distance_to_Superficial_Surface/MNI152_T1_1mm/myaparc_36wm2max_Right_Temporal_Superficial_w_Hippo_Amyg_2mm_Iso_Deep_Mask.nii.gz"
Left_Superficial="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm/Distance_Analysis_2024_01_25/Distance_to_Superficial_Surface/MNI152_T1_1mm/myaparc_36wm2max_Left_Temporal_Superficial_w_Hippo_Amyg_2mm_Iso_Superfical_Mask.nii.gz"
Left_Deep="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm/Distance_Analysis_2024_01_25/Distance_to_Superficial_Surface/MNI152_T1_1mm/myaparc_36wm2max_Left_Temporal_Superficial_w_Hippo_Amyg_2mm_Iso_Deep_Mask.nii.gz"

mri_convert ${MNI_152_FreeSurf}/ribbon.mgz ${MNI_152_FreeSurf}/ribbon.nii.gz

##Add the hippocampus and the Amygdala to the ribbon
fslmaths ${MNI_152_FreeSurf}/ribbon.nii.gz -thr 3 -uthr 3 -bin ${MNI_152_FreeSurf}/ribbon_Left_GM.nii.gz
fslmaths ${MNI_152_FreeSurf}/ribbon.nii.gz -thr 2 -uthr 2 -bin ${MNI_152_FreeSurf}/ribbon_Left_WM.nii.gz

fslmaths ${MNI_152_FreeSurf}/ribbon.nii.gz -thr 42 -uthr 42 -bin ${MNI_152_FreeSurf}/ribbon_Right_GM.nii.gz
fslmaths ${MNI_152_FreeSurf}/ribbon.nii.gz -thr 41 -uthr 41 -bin ${MNI_152_FreeSurf}/ribbon_Right_WM.nii.gz

#Add the hippocampus and the Amygdala to the GM mask
fslmaths ${MNI_152_FreeSurf}/myaparc_36.nii.gz -thr 17 -uthr 17 -bin ${MNI_152_FreeSurf}/myaparc_36_Left_Hip.nii.gz
fslmaths ${MNI_152_FreeSurf}/myaparc_36.nii.gz -thr 18 -uthr 18 -bin ${MNI_152_FreeSurf}/myaparc_36_Left_Amy.nii.gz
fslmaths ${MNI_152_FreeSurf}/myaparc_36.nii.gz -thr 53 -uthr 53 -bin ${MNI_152_FreeSurf}/myaparc_36_Right_Hip.nii.gz
fslmaths ${MNI_152_FreeSurf}/myaparc_36.nii.gz -thr 54 -uthr 54 -bin ${MNI_152_FreeSurf}/myaparc_36_Right_Amy.nii.gz

#Add Amy and Hip to the GM ribbon mask
fslmaths ${MNI_152_FreeSurf}/ribbon_Left_GM.nii.gz -add ${MNI_152_FreeSurf}/myaparc_36_Left_Hip.nii.gz -add ${MNI_152_FreeSurf}/myaparc_36_Left_Amy.nii.gz ${MNI_152_FreeSurf}/ribbon_Left_GM_Hip_Amy_Mask.nii.gz
fslmaths ${MNI_152_FreeSurf}/ribbon_Right_GM.nii.gz -add ${MNI_152_FreeSurf}/myaparc_36_Right_Hip.nii.gz -add ${MNI_152_FreeSurf}/myaparc_36_Right_Amy.nii.gz ${MNI_152_FreeSurf}/ribbon_Right_GM_Hip_Amy_Mask.nii.gz

#Run distance in the WM
distancemap -i ${MNI_152_FreeSurf}/ribbon_Left_GM_Hip_Amy_Mask.nii.gz -m ${MNI_152_FreeSurf}/ribbon_Left_WM.nii.gz -o ${MNI_152_FreeSurf}/ribbon_Left_GM_Hip_Amy_Dist.nii.gz
distancemap -i ${MNI_152_FreeSurf}/ribbon_Right_GM_Hip_Amy_Mask.nii.gz -m ${MNI_152_FreeSurf}/ribbon_Right_WM.nii.gz -o ${MNI_152_FreeSurf}/ribbon_Right_GM_Hip_Amy_Dist.nii.gz 

#Resample to 2mm iso space
antsApplyTransforms -d 3 -i ${MNI_152_FreeSurf}/ribbon_Left_GM_Hip_Amy_Dist.nii.gz -r ${MNI_2mm} -o ${MNI_152_FreeSurf}/ribbon_Left_GM_Hip_Amy_Dist_2mm.nii.gz
antsApplyTransforms -d 3 -i ${MNI_152_FreeSurf}/ribbon_Right_GM_Hip_Amy_Dist.nii.gz -r ${MNI_2mm} -o ${MNI_152_FreeSurf}/ribbon_Right_GM_Hip_Amy_Dist_2mm.nii.gz

#Mask out the temporal regions used by both superficial and temporal 
#Add both Superficial and Deep Masks together
fslmaths $Right_Superficial -add $Right_Deep ${MNI_152_FreeSurf}/Combined_Right_Temporal_Mask.nii.gz 
fslmaths $Left_Superficial -add $Left_Deep ${MNI_152_FreeSurf}/Combined_Left_Temporal_Mask.nii.gz 
#Now trim the distance and FA maps
fslmaths ${MNI_152_FreeSurf}/ribbon_Left_GM_Hip_Amy_Dist_2mm.nii.gz -mul ${MNI_152_FreeSurf}/Combined_Left_Temporal_Mask.nii.gz ${MNI_152_FreeSurf}/ribbon_Left_GM_Hip_Amy_Dist_Temporal.nii.gz
fslmaths ${MNI_152_FreeSurf}/ribbon_Right_GM_Hip_Amy_Dist_2mm.nii.gz -mul ${MNI_152_FreeSurf}/Combined_Right_Temporal_Mask.nii.gz ${MNI_152_FreeSurf}/ribbon_Right_GM_Hip_Amy_Dist_Temporal.nii.gz

#Now trim all to get the assoicated FA maps

List="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm/Overall_List.txt"
Output_Folder="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm/Deep_vs_Superficial_WM_FreeSurfer_Def"
FA_Maps="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm"
Script_Dir="/Users/ngh92/Documents/GitHub/dMRI_Dist_Version_2"
Initial_Pathway="/Users/ngh92/Documents/Periventricular_WM_Study/Registered_MAPS_for_Pervientricular_WM/Tensor_Maps_MNI_FA_Reg_2mm/Distance_Analysis_2024_01_25/Distance_to_Superficial_Surface/MNI152_T1_1mm"

fslmaths ${MNI_152_FreeSurf}/ribbon_Left_GM_Hip_Amy_Dist_Temporal.nii.gz -bin ${MNI_152_FreeSurf}/ribbon_Left_GM_Hip_Amy_Dist_Temporal_Mask.nii.gz
fslmaths ${MNI_152_FreeSurf}/ribbon_Right_GM_Hip_Amy_Dist_Temporal.nii.gz -bin ${MNI_152_FreeSurf}/ribbon_Right_GM_Hip_Amy_Dist_Temporal_Mask.nii.gz

for Subj in $(cat $List) #For each subject! 
    do
    for TimeDate in $(ls ${FA_Maps}/${Subj}/)
        do
        echo $Subj $TimeDate
        mkdir -p ${Output_Folder}/FA_Maps/${Subj}/${TimeDate}
 
        for Side in Left Right
            do
            fslmaths ${FA_Maps}/${Subj}/${TimeDate}/${Subj}_${TimeDate}_FA_Reg_TL.nii.gz -mul ${MNI_152_FreeSurf}/ribbon_${Side}_GM_Hip_Amy_Dist_Temporal_Mask.nii.gz ${Output_Folder}/FA_Maps/${Subj}/${TimeDate}/FA_WM_Mask_${Side}_Dist_Temporal
      done
    done 
done