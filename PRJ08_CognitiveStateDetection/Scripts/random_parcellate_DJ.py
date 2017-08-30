# Downloaded 2/2/16 from https://github.com/jrcohen02/random_nodes/blob/master/random_parcellate_avg_multi.py
# Modified to just do parcellation, accept custom folder

#!/home/jangrawdc/.conda/envs/python27/bin
import pandas as pd
import numpy as np
import os
import sys
import random
from multiprocessing import Pool


def read_in_data(img_file,template):
    # input: image file (.nii), output: data dictionary with XYZ and value
    global outFolder
    name = random.randint(1,1000000000)
    os.system('3dmaskdump -overwrite -o %s/data_%s.txt -xyz %s' %(outFolder,name,img_file))
    names_list = ['X','Y','Z','Val']
    read_data = pd.read_csv('%s/data_%s.txt' %(outFolder,name), header=None, index_col = [0,1,2], names=names_list, sep=' ')
    os.system('rm -f %s/data_%s.txt' %(outFolder,name))
    name =  random.randint(1,1000000000)
    os.system('3dmaskdump -overwrite -o %s/data_%s.txt -xyz %s' %(outFolder,name,template))
    template_data = pd.read_csv('%s/data_%s.txt' %(outFolder,name), header=None, index_col = [0,1,2], names=names_list, sep=' ')
    os.system('rm -f %s/data_%s.txt' %(outFolder,name))
    read_data[read_data.Val == 0] = np.nan
    read_data[template_data.Val == 0] = np.nan
    read_data[template_data.Val == 2] = np.nan
    read_data['added'] = False
    read_data.dropna(inplace= True, axis = 0,how = 'any')
    read_data.reset_index(drop = True, inplace= True)
    read_data['Voxel Number'] = read_data.index
    return read_data


def assign_voxel(voxel):
    global parcel_data
    global center_of_mass_dict
    x = parcel_data[parcel_data['Voxel Number'] == voxel]['X']
    y = parcel_data[parcel_data['Voxel Number'] == voxel]['Y']
    z = parcel_data[parcel_data['Voxel Number'] == voxel]['Z']
    distances = {}
    for node in range(len(center_of_mass_dict)):
        centerofmass = center_of_mass_dict[node]
        x1,y1,z1 = centerofmass[0],centerofmass[1],centerofmass[2]
        dist = np.sqrt(((x-x1)**2) + ((y-y1)**2) + ((z-z1)**2))
        distances[node] = float(dist)
    node_to_expand = min(distances, key=distances.get)
    print 'added ' + str(voxel) + ' to ' +str(node_to_expand)
    return [node_to_expand, voxel]

def random_parcellate(num_nodes,threads): 
    global parcel_data
    global center_of_mass_dict
    node_voxel_dict = {}
    print 'len parcel_data', len(parcel_data)
    seed_voxels = random.sample(range(len(parcel_data)), num_nodes)
    #print seed_voxels
    for i in range(num_nodes):
        node_voxel_dict[i] = [seed_voxels[i]]
    voxel_neighbor_dict = {}
    parcel_data['added'][seed_voxels] = True
    center_of_mass_dict = {}
    for seed,n in zip(seed_voxels,range(len(seed_voxels))):
        center_of_mass_dict[n] = [float(parcel_data[parcel_data['Voxel Number'] == seed]['X']),float(parcel_data[parcel_data['Voxel Number'] == seed]['Y']),float(parcel_data[parcel_data['Voxel Number'] == seed]['Z'])]
    pool = Pool(threads)
    results = pool.map(assign_voxel,parcel_data['Voxel Number'].values)
    parcel_data['node'] = np.zeros(len(parcel_data))
    for result in results:
        parcel_data['node'][result[1]] = result[0]


def draw_parcellation(standard_image,num_nodes,draw):
    global parcel_data
    global outFolder
    draw_parcel_data = pd.DataFrame()
    draw_parcel_data['X'] = np.array(parcel_data.X)
    draw_parcel_data['Y'] = np.array(parcel_data.Y * -1)
    draw_parcel_data['Z'] = np.array(parcel_data.Z)
    draw_parcel_data['node'] = np.array(parcel_data.node) + 1
    name =  random.randint(1,1000000000)
    draw_parcel_data.to_csv('%s/%s/%s.csv' %(outFolder,num_nodes,name), header = False, index = False)
    if draw == True:
        command = '3dUndump -xyz -master %s -prefix %s/%s/%s.nii %s/%s/%s.csv' %(standard_image,outFolder,num_nodes,name,outFolder,num_nodes,name)
        os.system(command)


def make_parcels(draw=False,num_nodes = 600,threads= 5,standard_image='MNI152_T1_2mm_brain.nii',template='MNI.nii'):
    global parcel_data
    print "===Reading in data...==="
    parcel_data = read_in_data(standard_image,template)
    print "===Creating random parcellation...==="
    random_parcellate(num_nodes,threads) 
    print "===Sending result to .csv and .nii files...==="
    draw_parcellation(standard_image,num_nodes,draw=draw)

# subject = sys.argv[1]
# analyze(subject=subject)
# subjects = [114, 116, 117, 118, 201, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218]
# group_analysis(subjects)

# Parse inputs
nParc = int(sys.argv[1]) # num of parcellations
nROIs = int(sys.argv[2]) # num of ROIs in each
print "Creating %d random parcellations with %d ROIs each..."%(nParc,nROIs)
#segFile = sys.argv[3] # dataset containing GM/WM/CSF segmentation breakdown

# Declare folders and files
global outFolder
outFolder = "/data/jangrawdc/PRJ08_CognitiveStateDetection/Parcellations"
stdImage = outFolder + '/MNI_avg152T1+tlrc'
templateImage = outFolder + '/MNI_avg152T1+tlrc' 

# make random parcellations
for i in range(0,nParc):
    make_parcels(draw = True, num_nodes = nROIs,threads = 5, standard_image = stdImage, template = templateImage)

