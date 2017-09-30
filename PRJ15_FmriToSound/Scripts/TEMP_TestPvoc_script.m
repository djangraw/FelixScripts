% TEMP_TestPvoc_script.m
%
% Created 9/29/17 by DJ.

[d,sr]=audioread('handel.wav'); 
% sr = 16000;
% 1024 samples is about 60 ms at 16kHz, a good window 
y=pvoc(d,.75,1024); 
% Compare original and resynthesis 
sound(d,sr) 
sound(y,sr/.75)