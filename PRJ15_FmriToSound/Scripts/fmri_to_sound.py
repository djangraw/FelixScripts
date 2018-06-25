import wave, struct, math
import numpy as np
import nibabel as nib
from scipy.io.wavfile import write, read
import os


def fmri_encoding(fmri , threshold , time_slice):
    img = nib.load(fmri)
    data = img.get_data()
    time_slice = np.asarray(data[:,:,:,time_slice] / np.max(time_slice))
    hist = np.histogram(time_slice , bins=40 , range=(threshold , np.max(time_slice)))[0]
    weights = hist / np.float(((np.cumsum(hist))[-1]))
    
    return(weights)


def gen_value(frequency , sampleRate , i , weight):
    value = int(32767.0*math.cos(frequency*math.pi*float(i)/float(sampleRate)))    
    return(value)


def gen_master(duration, sampleRate, freqs , time_slice , filename):
    wavef = wave.open(filename,'w')
    wavef.setnchannels(1) # mono
    wavef.setsampwidth(2) 
    wavef.setframerate(sampleRate)    

    weights = fmri_encoding('dBOLD_rest.nii' , 6 , time_slice)        
    for i in range(int(duration * sampleRate)):
        value = 0
        for j in range(len(freqs)):
            value += weights[j] * gen_value(freqs[j], 44100, i, weights[j])
        data = struct.pack('<h', value)
        wavef.writeframesraw( data )
    wavef.writeframes('')
    wavef.close()    
    return(weights)

def stitch(file_a , file_b , new_filename):
    a=read(file_a)
    b=read(file_b)
    c=np.append(a[1] , b[1])
    d=write(file_a , 44100 , c)
    os.remove(file_b)
    return()
    
img=nib.load('dBOLD_rest.nii')
data=img.get_data()
n_slices = np.shape(data)[3]

for k in range(n_slices):
    print(k)
    W = [[]]
    if(k==0):
        weights = gen_master(2, 44100, np.arange(500,1000,50) , [k] , 'master.wav')
        W.append(weights)
        k+=1
    else:
        weights = gen_master(2, 44100, np.arange(500,1000,12.5) , [k] , 'temp.wav')
        stitch('master.wav','temp.wav','final.wav')
        W.append(weights)
        k+=1
    


#duration, sampleRate, freqs , time_range = 2, 44100, np.arange(500,1000,50) , [100,101]
