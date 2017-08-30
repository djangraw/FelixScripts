import wave, struct, math
from scipy.io.wavfile import write, read
import nibabel as nib
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import periodogram as pdg
import os

'''load base image/timeseries and GM mask'''
img = nib.load('S20_MC.nii')
#gm = nib.load('gm.nii')
img = img.get_data()
#gm = gm.get_data()

'''masks out all non-cortex'''
#for i in range(len(img[0,0,0,:])):
#indent here --> img[:,:,:,i] = img[:,:,:,i][ gm != 0 ]

'''flattens cortex to the average overall timeseries (global signal?)'''
avg1 = np.ndarray.mean(img, axis=0)
avg2 = np.ndarray.mean(avg1, axis=0)
avg3 = np.ndarray.mean(avg2, axis=0)

'''Generates array of PSDs to be converted to sound, corresponding to activation over time'''
TR = 3
n = 60. / TR
f = 1./TR
i=0
psd_evolution = []
while(i+n < len(avg3)):
    ts = avg3[i:i+n]    
    freq , pxx = pdg(ts, fs=f)
    pxx = pxx / np.max(pxx)
    psd_evolution.append( pxx )
    i+=1

def gen_value(frequency , sampleRate , i ):
    value = int(32767.0*math.cos(frequency*math.pi*float(i)/float(sampleRate)))    
    return(value)
    
    
def gen_master(duration, sampleRate, freqs , filename, weights):
    wavef = wave.open(filename,'w')
    wavef.setnchannels(1) # mono
    wavef.setsampwidth(2) 
    wavef.setframerate(sampleRate)    
    
    for i in range(int(duration * sampleRate)):
        value = 0
        for j in range(len(freqs)):
            value += weights[j] * gen_value(freqs[j], 44100, i)
        data = struct.pack('<l', value)
        wavef.writeframesraw( data )
    wavef.writeframes('')
    wavef.close()    
    return(weights)
    
def stitch(file_a , file_b ):
    a=read(file_a)
    b=read(file_b)
    c=np.append(a[1] , b[1])
    d=write(file_a , 44100 , c)
    os.remove(file_b)
    return()


for j in range(len(psd_evolution)):
    if(j==0):
        gen_master(0.5, 44100, np.arange(500,975,45), 'psd.wav' , psd_evolution[j])
    else:
        gen_master(0.5, 44100, np.arange(500,975,45), 'temp.wav' , psd_evolution[j])
        stitch('psd.wav','temp.wav')