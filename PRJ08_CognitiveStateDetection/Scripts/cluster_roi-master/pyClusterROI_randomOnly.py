# pyClusterROI_randomOnly.py
#
# INPUTS:
# 1. maskname: the name of the maskfile that we will be using.
#   EX: "SBJ06_CTask001.Craddock_T2Level_0200.nii"
# 2. outPrefix: the beginning of the output files
#   EX: "SBJ06_CTask001.RandomParc"
# 3. nClust: an integer indicating the number of clusters/ROIs.
#   EX: 200
# 4. nParc: in integer indicating the number of random parcellations to be found.
#   EX: 10
#
# Downloaded 2/3/16: pyClusterROI_test.py from https://github.com/ccraddock/cluster_roi
# Updated 2/3/16 by DJ - cropped to random parcellations only

# ORIGINAL HEADER:
#### pyClusterROI_test.py
# Copyright (C) 2010 R. Cameron Craddock (cameron.craddock@gmail.com)
#
# This script is a part of the pyClusterROI python toolbox for the spatially
# constrained clustering of fMRI data. It is a demonstration of how to use the
# toolbox and a regression test to make sure that the toolbox code works.
#
# For more information refer to:
#
# Craddock, R. C.; James, G. A.; Holtzheimer, P. E.; Hu, X. P. & Mayberg, H. S.
# A whole brain fMRI atlas generated via spatially constrained spectral
# clustering Human Brain Mapping, 2012, 33, 1914-1928 doi: 10.1002/hbm.21333.
#
# ARTICLE{Craddock2012,
#   author = {Craddock, R C and James, G A and Holtzheimer, P E and Hu, X P and
#   Mayberg, H S},
#   title = {{A whole brain fMRI atlas generated via spatially constrained
#   spectral clustering}},
#   journal = {Human Brain Mapping},
#   year = {2012},
#   volume = {33},
#   pages = {1914--1928},
#   number = {8},
#   address = {Department of Neuroscience, Baylor College of Medicine, Houston,
#       TX, United States},
#   pmid = {21769991},
# } 
#
# Documentation, updated source code and other information can be found at the
# NITRC web page: http://www.nitrc.org/projects/cluster_roi/ and on github at
# https://github.com/ccraddock/cluster_roi
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
####


# import the different functions we will use from pyClusterROI
from make_local_connectivity_ones import *

# do not need this if you are peforming group mean clustering
from binfile_parcellation import *

# import if you want to write the results out to nifti
from make_image_from_bin import *

from time import time # to time processing
import os.path # to check for files
import sys # to take arguments


# Get input arguments
maskname=sys.argv[1]
outPrefix=sys.argv[2]
nClust=int(sys.argv[3])
nParc=int(sys.argv[4])
# defaults
# maskname="SBJ06_CTask001.Craddock_T2Level_0200.nii" # the name of the maskfile that we will be using
# outPrefix="SBJ06_CTask001.RandomParc" # the beginning of the output files


T0 = time()


# clustering parameters
NUM_CLUSTERS = nClust
NUM_PARCELLATIONS = nParc # number of randomizations

##### Step 1. Individual Conenctivity Matrices 
# first we need to make the individual connectivity matrices.
# The easiest is random clustering which doesn't require any functional
# data, just the mask
if os.path.isfile('rm_ones_connectivity.npy'):
    print 'connectivity file found!'
else:
    print 'calculating "ones" connectivity...'
    make_local_connectivity_ones( maskname, 'rm_ones_connectivity.npy')

##### Step 2. Individual level clustering
# next we will do the individual level clustering, this is not performed for 
# group-mean clustering, remember that for these functions the output name
# is a prefix that will have NUM_CLUSTERS and .npy added to it by the functions. 


for i in range(0,NUM_PARCELLATIONS):    
    print "===Random Parcellation %d/%d..."%(i,NUM_PARCELLATIONS)
    # For random custering, this is all we need to do, there is no need for group
    # level clustering, remember that the output filename is a prefix, and
    print 'calculating random clusters...'
    binfile_parcellate('rm_ones_connectivity.npy','rm_ones_cluster',[NUM_CLUSTERS])

    ##### Step 3. Group level clustering
    # perform the group level clustering for clustering results containing 100, 150,
    # and 200 clusters. as previously mentioned, this does _not_ have to be done for
    # random clustering

    ##### Step 4. Convert the binary output .npy files to nifti
    # this can be done with or without renumbering the clusters to make sure they
    # are contiguous. remember, we might end up with fewer clusters than we ask for,
    # and this could result in gaps in the cluster numbering. Choose which you like,
    # i use them intermittently below as a regression test

    # write output files for the random clustering
    print 'writing output files...'
    binfile='rm_ones_cluster_'+str(NUM_CLUSTERS)+'.npy'
    imgfile='%s_%dROIs_%d.nii.gz'%(outPrefix,NUM_CLUSTERS,i)#'rm_ones_cluster_'+str(k)+'.nii.gz'
    make_image_from_bin(imgfile,binfile,maskname);
    
    
# Finish and clean up
T1 = time()

print '******************************'
print 'Total running time is ', T1-T0
##### FIN