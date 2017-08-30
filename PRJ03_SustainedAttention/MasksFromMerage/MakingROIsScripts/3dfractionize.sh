#!/bin/tcsh


# This script resamples from a high resolution grid (in this case 2x2x2) to a lower resolution grid (i.e. functional)
# Scripts are separated by masks derived from neurosynth, which end in nii.gz and masks drawn in AFNI using the center
# of mass coordinates from the neurosynth regions. Output can be found in folder called: Resampled Masks. Uncomment each 
# separately to run. -clip option can be changed... this just means that if at or above 50% of a voxel falls into a mask
# then it is kept in the mask, if less, not included. 

# Sample command
# foreach mask (MASK1...MASKN)
# 
# cd /Directory/where/masks/are/
# 
# 3dfractionize \
# 	-template LowResGridFile+tlrc -input ${mask}.HighResMask+tlrc -clip .5 \
# 	-prefix ${mask}_resampled
# 	
# end
# end 

# Neurosynth mask resampling
foreach mask (attention ReadingM1 SpeechM)

cd /Users/ghanem2/Desktop/Masks/FinalMasks/

3dfractionize \
	-template CraddockAtlas_200Rois_SBJ09epires+tlrc -input ${mask}.nii.gz -clip .5 \
	-prefix ${mask}_resampled
	
end
end 

# AFNI drawn mask resampling
# foreach mask (AllSpheresNoOverlap AllSpheres ReadingSphere AttentionSphere SpeechSphere)
# 
# cd /Users/ghanem2/Desktop/Masks/FinalMasks/
# 
# 3dfractionize \
# 	-template CraddockAtlas_200Rois_SBJ09epires+tlrc -input ${mask}+tlrc -clip .5 \
# 	-prefix ${mask}_resampled
# 	
# end
# end 