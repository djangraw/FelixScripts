#!/bin/tcsh

## This script will take a 3d mask (like one downloaded from neurosynth or from functional activation) and create clusters

3dclust \
	-savemask SpeechM.nii.gz \
	-1Dformat \
	-1clip 8 \
	-nosum \
	-1dindex 0 \
	-1tindex 0 \
	-2thresh -0.5 0.5 \
	-dxyz=1 2.01 36 /Users/ghanem2/Desktop/Masks/speech_mask.nii.gz \
	> SpeechM.1D
		
end

# line 6: save mask with each cluster saved as a different number 1...n clusters based on size
# line 7: write cluster info to a 1D file
# line 8: Clip intensities in range (-val,val) to zero
# line 9: suppress printout of totals
# line 10: only place value -1dindex 'k' here if you want to address a specific dataset subbrik and ignore others
# line 11: only place value -1tindex 'j' here if you want to refer to specific subbrik threshold and ignore others
# line 12: Zero out voxels where the threshold sub-brick value lies between 't1' and 't2' (exclusive).  If t1=-t2, is the same as '-1thresh t2'.
# line 13: (-dxyz=1 rmm vmul inputfile) spatial clusters are defined by connectivity in true 3D distance. 
# line 13: this forces all 3 voxel dimensions to equal 1 mm. 
# line 13: rmm is the max number of grid cells voxels can be to be considered directly connected and vmul is the min number of voxels to keep in clust
 