#!/usr/bin/python

import os
from numpy import *
from nifti import *
from pylab import *


ion()

fn = 'HeyDude.woo'
#I_fn = 'FA_stack.EMO.resttr2500e.nii'
I_fn = os.sys.argv[1]

I_nim = NiftiImage(I_fn)
I = I_nim.data.transpose()
J = I_nim.data
print I.shape

# get original timestamp
s = os.stat(fn)[-2]
c=0

while 1:
   s2 = os.stat(fn)[-2]
   #print 's: ' + str(s) + ' s2: ' + str(s2)
   if s2 != s:  # file changed?
      s = s2
      a = os.popen('tail -1 ' + fn)
      coords =  [float(ss) for ss in a.read().split()]
      a.close()
      print coords[3:6]

      figure(1)
      plot(squeeze(I[coords[3],coords[4],coords[5],:]))
      figure(2)
      plot(squeeze(J[:,coords[5],coords[4],coords[3]]))
      #plot([0,20,45,90],squeeze(I[coords[3],coords[4],coords[5],10,:]))

      draw()

      # check image matrix sanity
      figure(3)
      subplot(131)
      img = squeeze(I[:,coords[4],:,5])
      title('Coronal')
      imshow(img)
      subplot(132)
      img = squeeze(I[:,:,coords[5],5])
      title('Axial')
      imshow(img)
      subplot(133)
      img = squeeze(I[coords[3],:,:,5])
      title('Saggital')
      imshow(img)
      draw()



