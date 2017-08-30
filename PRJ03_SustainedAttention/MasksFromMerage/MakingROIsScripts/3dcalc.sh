#!/bin/tcsh

# This script combined the individual "term masks" (downloaded from neurosynth) into one network mask

cd /Users/ghanem2/Desktop/Masks/FinalMasks/

# Attention Mask 
3dcalc -a 'arousal.nii.gz' -b 'attentional_control.nii.gz' -c 'dorsal_attention.nii.gz' -d 'executive_control.nii.gz' -e 'executive_function.nii.gz' -f 'executive_functions.nii.gz' -g 'orienting.nii.gz' -h 'salience.nii.gz' -i 'salience_net.nii.gz' -j 'switching.nii.gz' \
            -expr 'a+b+c+d+e+f+g+h+i+j' \
            -prefix attention_mask.nii.gz  
            
end


# Speech Mask
# 3dcalc -a 'language.nii.gz' -b 'reading.nii.gz' -c 'word.nii.gz' \
#             -expr 'a+b+c' \
#             -prefix speech_mask.nii.gz  
#             
# end

# Reading Mask
# 3dcalc -a 'language_comp.nii.gz' -b 'speech.nii.gz' -c 'speech_perception.nii.gz' \
#             -expr 'a+b+c' \
#             -prefix speech_mask.nii.gz  
#             
# end  

# Combine spherical seeds drawn in AFNI using ROI mask center of mass 
# 3dcalc -a 'ReadingSphere+tlrc.BRIK.gz' -b 'SpeechSphere+tlrc.BRIK.gz' -c 'AttentionSphere+tlrc.BRIK.gz' \
#             -expr 'a+b+c' \
#             -prefix AllSpheres+tlrc.BRIK.gz  
#             
# end   
                                 