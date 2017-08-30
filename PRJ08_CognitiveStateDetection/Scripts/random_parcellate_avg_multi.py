# Downloaded 2/2/16 from https://github.com/jrcohen02/random_nodes/blob/master/random_parcellate_avg_multi.py
#!/home/despo/mb3152/anaconda/bin/python
import pandas as pd
import os
import sys
from collections import defaultdict
from scipy.spatial.distance import euclidean
import random
from scipy.stats.stats import pearsonr
from multiprocessing import Pool
import numpy as np
import itertools
import math
import operator
import time
import numpy as np
from random import choice
import networkx as nx
from brainx import util, modularity, weighted_modularity

def within_community_degree(weighted_partition, nan = 0.0, catch_edgeless_node=True):
    ''' Computes "within-module degree" (z-score) for each node (Guimera 2007, J Stat Mech)

    ------
    Parameters
    ------
    weighted_partition: Louvain Weighted Partition
        louvain = weighted_modularity.LouvainCommunityDetection(graph)
        weighted_partitions = louvain.run()
        weighted_partition = weighted_partition[0], where index is the partition level
    nan : int
        number to replace unexpected values (e.g., -infinity) with
        default = 0.0
    catch_edgeless_node: Boolean
        raise ValueError if node degree is zero
        default = True

    ------
    Returns
    ------
    within_community_degree: dict
        Dictionary of the within community degree of each node.

    '''
    wc_dict = {}
    for c, community in enumerate(weighted_partition.communities):
        community_degrees = []
        for node in community: #get average within-community-degree
            node_degree = weighted_partition.node_degree(node)
            if node_degree == 0.0: #catch edgeless nodes
                if catch_edgeless_node:
                    raise ValueError("Node {} is edgeless".format(node))
                wc_dict[node] = 0.0
                continue
            community_degrees.append(weighted_partition.node_degree_by_community(node)[c])
        for node in community: #get node's within_community-degree z-score
            within_community_degree = weighted_partition.node_degree_by_community(node)[c]
            std = np.std(community_degrees) # std of community's degrees
            mean = np.mean(community_degrees) # mean of community's degrees
            if std == 0.0: #so we don't divide by 0
                wc_dict[node] = (within_community_degree - mean) #z_score
                continue
            wc_dict[node] = ((within_community_degree - mean) / std) #z_score
    return wc_dict

def participation_coefficient(weighted_partition, catch_edgeless_node=True):
    '''
    Computes the participation coefficient for each node (Guimera 2007, J Stat Mech)

    ------
    Parameters
    ------
    weighted_partition: Louvain Weighted Partition
        louvain = weighted_modularity.LouvainCommunityDetection(graph)
        weighted_partitions = louvain.run()
        weighted_partition = weighted_partition[0], where index is the partition level
    catch_edgeless_node: Boolean
        raise ValueError if node degree is zero
        default = True

    ------
    Returns
    ------
    participation_coefficient: dict
        Dictionary of the participation coefficient of each node.
    '''
    pc_dict = {}
    for node in weighted_partition.graph:
        node_degree = weighted_partition.node_degree(node)
        if node_degree == 0.0: 
            if catch_edgeless_node:
                raise ValueError("Node {} is edgeless".format(node))
            pc_dict[node] = 0.0
            continue    
        pc = 0.0
        for comm_degree in weighted_partition.node_degree_by_community(node):
            try:
                pc = pc + ((comm_degree/node_degree)**2)
            except:
                continue
        pc = 1-pc
        pc_dict[node] = pc
    return pc_dict

def read_in_data(img_file,template):
    # input: image file (.nii), output: data dictionary with XYZ and value
    name = random.randint(1,1000000000)
    os.system('3dmaskdump -overwrite -o /home/despo/mb3152/random_nodes/data_%s.txt -xyz %s' %(name,img_file))
    names_list = ['X','Y','Z','Val']
    read_data = pd.read_csv('/home/despo/mb3152/random_nodes/data_%s.txt' %(name), header=None, index_col = [0,1,2], names=names_list, sep=' ')
    os.system('rm -f /home/despo/mb3152/random_nodes/data_%s.txt' %(name))
    name =  random.randint(1,1000000000)
    os.system('3dmaskdump -overwrite -o /home/despo/mb3152/random_nodes/data_%s.txt -xyz %s' %(name,template))
    template_data = pd.read_csv('/home/despo/mb3152/random_nodes/data_%s.txt' %(name), header=None, index_col = [0,1,2], names=names_list, sep=' ')
    os.system('rm -f /home/despo/mb3152/random_nodes/data_%s.txt' %(name))
    read_data[read_data.Val == 0] = np.nan
    read_data[template_data.Val == 0] = np.nan
    read_data[template_data.Val == 2] = np.nan
    read_data['added'] = False
    read_data.dropna(inplace= True, axis = 0,how = 'any')
    read_data.reset_index(drop = True, inplace= True)
    read_data['Voxel Number'] = read_data.index
    return read_data


def read_in_epi_data(directory,subject,blocks = 6):
    blocks = range(1,blocks+1)
    for block in blocks:
        name = random.randint(1,1000000000)
        img_file = str(directory) + '%s/Rest/w%s-EPI-00%s-CoReg_r.nii' %(subject,subject,block)
        os.system('3dmaskdump -overwrite -o /home/despo/mb3152/random_nodes/data_%s.txt -xyz %s ' %(str(name), str(img_file)))
        names_list = ['X','Y','Z']
        names_list.extend([str(i) for i in range(435)])
        epi_data = pd.read_csv('/home/despo/mb3152/random_nodes/data_%s.txt' %(name), header=None, index_col = [0,1,2], names=names_list, sep=' ')
        os.system('rm -f /home/despo/mb3152/random_nodes/data_%s.txt' %(name))
        if block == 1:
            sub_data = epi_data.copy()
        else:
            epi_data.drop('X',1,inplace=True)
            epi_data.drop('Y',1,inplace=True)
            epi_data.drop('Z',1,inplace=True)
            sub_data = sub_data.append(epi_data)
    return sub_data

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


def avg_time_series_across_nodes(df):
    """outputs node's avg'ed voxel time series"""
    time_points = len(df.TimeSeries.values)
    num_nodes = int(max(df.Node.values))
    avg_time_series = {}
    for i in range(1,num_nodes+1): 
        mean = np.nanmean(df.TimeSeries[df.Node==i].values)
        if abs(np.mean(mean)) >= 0:
            avg_time_series[i] = mean
        else:
            avg_time_series[i] = mean * np.nan
    return avg_time_series

def calc_pearson_corr(t1, t2):
    corr = pearsonr(t1,t2)[0]
    if abs(corr) >= 0:
        return corr
    else:
        print t1
        print t2
        return np.nan

def generate_node_corr_matrix(avg_time_series):
    matrix = np.zeros((len(avg_time_series), len(avg_time_series)))
    for i,i2 in zip(avg_time_series.keys(),range(len(avg_time_series))):
        for j,j2 in zip(avg_time_series.keys(),range(len(avg_time_series))):
            matrix[i2,j2] = calc_pearson_corr(avg_time_series[i],avg_time_series[j])
    return matrix

def generate_voxel_corr_matrix(node_corr_matrix):
    global data
    voxel_corr_matrix = np.empty((len(data),len(data)))
    voxel_corr_matrix.fill(np.nan)
    for i in range(len(data)):
        for j in range(len(data)):
            voxel_i = data[data['Voxel Number']==i]
            voxel_j = data[data['Voxel Number']==j] 
            node_i = voxel_i['node'] 
            node_j = voxel_j['node']
            voxel_corr_matrix[i,j] = node_corr_matrix[node_i, node_j]
    return voxel_corr_matrix


def draw_parcellation(standard_image,num_nodes,draw):
    global parcel_data
    draw_parcel_data = pd.DataFrame()
    draw_parcel_data['X'] = np.array(parcel_data.X)
    draw_parcel_data['Y'] = np.array(parcel_data.Y * -1)
    draw_parcel_data['Z'] = np.array(parcel_data.Z)
    draw_parcel_data['node'] = np.array(parcel_data.node) + 1
    name =  random.randint(1,1000000000)
    draw_parcel_data.to_csv('/home/despo/mb3152/random_nodes/%s/%s.csv' %(num_nodes,name), header = False, index = False)
    if draw == True:
        command = '3dUndump -xyz -master %s -prefix /home/despo/mb3152/random_nodes/%s/%s.nii /home/despo/mb3152/random_nodes/%s/%s.csv' %(standard_image,num_nodes,name,num_nodes,name)
        os.system(command)


def make_parcels(draw=False,num_nodes = 600,threads= 5,standard_image='/home/despo/mb3152/random_nodes/MNI152_T1_2mm_brain.nii',template='/home/despo/mb3152/random_nodes/MNI.nii'):
    global parcel_data
    parcel_data = read_in_data(standard_image,template)
    random_parcellate(num_nodes,threads) 
    draw_parcellation(standard_image,num_nodes,draw=draw)

def make_graph(matrix,cost=0.15):
    mask, real_cost = util.threshold_adjacency_matrix(matrix, cost)
    # true_cost = util.find_true_cost(mask)
    graph = nx.from_numpy_matrix(mask)
    return graph

def graph_analysis (graph):
    part = modularity.newman_partition(graph)
    print part.modularity()
    part = util.dictset_to_listset(part.index)
    part = weighted_modularity.WeightedPartition(graph,part)
    pc = np.array(participation_coefficient(part,catch_edgeless_node=False).values())
    wmd = np.array(within_community_degree(part,catch_edgeless_node=False).values())
    return pc,wmd

def array_df (new_df):
    df = pd.DataFrame()
    df['X'] = new_df.X.values
    df['Y'] = new_df.Y.values
    df['Z'] = new_df.Z.values
    tss = []
    for i in range(len(df)):
        tss.append(new_df.iloc[i][4:])
    df['TimeSeries'] = tss
    return df

def analyze(subject, directory = '/home/despo/mb3152/data/Rest.ShamTMS/Data/',standard_image='/home/despo/mb3152/random_nodes/MNI152_T1_2mm_brain.nii',num_nodes=600):
    # subject= '114'
    # directory = '/home/despo/mb3152/data/Rest.ShamTMS/Data/'
    # standard_image='/home/despo/mb3152/random_nodes/MNI152_T1_2mm_brain.nii'
    # num_nodes=600
    epi_data = read_in_epi_data(directory = directory,subject =subject,blocks=6)
    epi_data = array_df(epi_data)
    parcel_files = os.listdir('/home/despo/mb3152/random_nodes/%s/' %(num_nodes))
    parcels = []
    for i in parcel_files:
        if i[-1]== 'v':
            parcels.append(i)
    run = 0
    num_runs = len(parcels)
    for parcel in parcels:
        run = run +1
        parcel = pd.read_csv('/home/despo/mb3152/random_nodes/%s/%s' %(num_nodes,parcel),header=None, names = ['X','Y','Z','Node'])
        parcel.Y = parcel.Y * -1
        temp_df = pd.DataFrame()
        temp_df['X'] = parcel.X.values
        temp_df['Y'] = parcel.Y.values
        temp_df['Z'] = parcel.Z.values
        temp_df['Node'] = parcel.Node.values
        temp_df['wmd'] = 0
        temp_df['pc'] = 0
        new_df = pd.merge(parcel,epi_data,how='inner',on=['X','Y','Z'])
        time_series = avg_time_series_across_nodes(new_df)
        missing_nodes = []
        for t in range(1,num_nodes+1):
            if np.std(time_series[t]) == 0:
                missing_nodes.append(t)
                time_series.pop(t,None)
        matrix = generate_node_corr_matrix(time_series)
        graph = make_graph(matrix,cost=0.05)
        pc,wmd = graph_analysis(graph)
        pc = list(pc)
        wmd = list(wmd)
        for n in missing_nodes:
            pc.insert((n-1),np.nan)
            wmd.insert((n-1),np.nan)
        node = 0
        for p,w in zip(pc,wmd):
            node = node + 1
            temp_df['wmd'][temp_df.Node == node] = w
            temp_df['pc'][temp_df.Node == node] = p
        if run == 1:
            store_data = temp_df.copy()
            del temp_df
        else:
            store_data = store_data.add(temp_df)
            del temp_df
        if run == num_runs:
            break

    final_data = store_data/run
    final_data.Y = final_data.Y * -1
    name = 'final_pc_%s' %(subject)
    draw_data = pd.DataFrame()
    draw_data['X'] = np.array(final_data.X)
    draw_data['Y'] = np.array(final_data.Y)
    draw_data['Z'] = np.array(final_data.Z)
    draw_data['pc'] = np.array(final_data.pc*1000)
    draw_data.to_csv('/home/despo/mb3152/random_nodes/%s/%s.csv' %(num_nodes,name), header = False, index = False)
    command = '3dUndump -xyz -master %s -prefix /home/despo/mb3152/random_nodes/%s/%s.nii /home/despo/mb3152/random_nodes/%s/%s.csv' %(standard_image,num_nodes,name,num_nodes,name)
    os.system(command)
    del draw_data
    name = 'final_wmd_%s' %(subject)
    draw_data = pd.DataFrame()
    draw_data['X'] = np.array(final_data.X)
    draw_data['Y'] = np.array(final_data.Y)
    draw_data['Z'] = np.array(final_data.Z)
    draw_data['wmd'] = np.array(final_data.wmd*1000)
    draw_data.to_csv('/home/despo/mb3152/random_nodes/%s/%s.csv' %(num_nodes,name), header = False, index = False)
    command = '3dUndump -xyz -master %s -prefix /home/despo/mb3152/random_nodes/%s/%s.nii /home/despo/mb3152/random_nodes/%s/%s.csv' %(standard_image,num_nodes,name,num_nodes,name)
    os.system(command)

def plot(subject,hemi='lh',hub='pc',num_nodes=600):
    from surfer import Brain, io
    hemi = hemi
    brain = Brain("fsaverage", "%s" %(hemi), "pial",config_opts=dict(background="white"))
    image = io.project_volume_data('/home/despo/mb3152/random_nodes/%s/final_%s_%s.nii'%(num_nodes,hub,subject),hemi, subject_id="fsaverage", projsum = 'max', smooth_fwhm = 0)
    brain.add_data(image,min=1,colormap = "Reds", smoothing_steps = 0, colorbar= True)

def plot_group(hub,num_nodes,hemi='lh'):
    from surfer import Brain, io
    brain = Brain("fsaverage", "%s" %(hemi), "pial",config_opts=dict(background="white"))
    if hub == 'pc' or hub =='wmd':
        image = io.project_volume_data('/home/despo/mb3152/random_nodes/%s/group_%s.nii'%(num_nodes,hub),hemi, subject_id="fsaverage", projsum = 'max', smooth_fwhm = 20)
        brain.add_data(image,colormap = "Reds", colorbar= True)
    else:
        pc_image = io.project_volume_data('/home/despo/mb3152/random_nodes/%s/group_pc.nii'%(num_nodes),hemi, subject_id="fsaverage", projsum = 'max', smooth_fwhm = 20)
        wmd_image = io.project_volume_data('/home/despo/mb3152/random_nodes/%s/group_wmd.nii'%(num_nodes),hemi, subject_id="fsaverage", projsum = 'max', smooth_fwhm = 20) 
        wmd_thresh = np.nanmean(wmd_image[wmd_image>0])
        pc_thresh = np.nanmean(pc_image[pc_image >0])
        #find connetor hub activity
        connector_hub_image = pc_image.copy()
        connector_hub_image[pc_image < pc_thresh] = 0.
        connector_hub_image[wmd_image < wmd_thresh] = 0.
        #find sattelite connector activty
        satellite_image = pc_image.copy()
        satellite_image[pc_image < pc_thresh] = 0.
        satellite_image[wmd_image > wmd_thresh] = 0.
        # find provincial hub activity
        provincial_hub_image = wmd_image.copy()
        provincial_hub_image[pc_image > pc_thresh] = 0.
        provincial_hub_image[wmd_image < wmd_thresh] = 0.

        node_image = pc_image.copy()
        node_image[provincial_hub_image > 0] = 0
        node_image[connector_hub_image > 0] = 0
        node_image[satellite_image > 0] = 0
        node_image[node_image > 0] = 1

        # brain.add_data(node_image,thresh= 0, max = 2, colormap = 'gray',hemi=hemi,smoothing_steps = 0)
        brain.add_data(connector_hub_image,thresh= np.nanmin(pc_image),max=pc_thresh + np.std(pc_image), colormap = 'Reds',hemi=hemi,smoothing_steps = 0)
        brain.add_data(satellite_image,thresh= np.nanmin(pc_image),max=pc_thresh + np.std(pc_image),colormap = 'autumn',hemi=hemi,smoothing_steps = 0)
        brain.add_data(provincial_hub_image,thresh=np.nanmin(wmd_image),max=wmd_thresh +np.std(wmd_image),colormap = 'Blues',hemi=hemi,smoothing_steps = 0)

def group_analysis(subjects,num_nodes=600):
    standard_image='/home/despo/mb3152/random_nodes/MNI152_T1_2mm_brain.nii'
    wmd_data_array = []
    pc_data_array = []
    for subject in subjects:
        command = "wmd_data_%s = pd.read_csv('/home/despo/mb3152/random_nodes/600/final_wmd_%s.csv',header =None)"%(subject,subject)
        exec(command)
        command = "pc_data_%s = pd.read_csv('/home/despo/mb3152/random_nodes/600/final_pc_%s.csv',header =None)"%(subject,subject)
        exec(command)
        command = "wmd_data_array.append(wmd_data_%s)" %(subject)
        exec(command)
        command = "pc_data_array.append(pc_data_%s)" %(subject)
        exec(command)
    wmd_data = pd.DataFrame()
    wmd_data['X'] = np.array(wmd_data_array[0][0])
    wmd_data['Y'] = np.array(wmd_data_array[0][1])
    wmd_data['Z'] = np.array(wmd_data_array[0][2])
    wmd_data['value'] = 0
    for n in range(len(wmd_data)):
        values = []
        for s in range(len(subjects)):
            values.append(wmd_data_array[s][3][n])
        wmd_data['value'][n] = np.nanmean(values)

    pc_data = pd.DataFrame()
    pc_data['X'] = np.array(pc_data_array[0][0])
    pc_data['Y'] = np.array(pc_data_array[0][1])
    pc_data['Z'] = np.array(pc_data_array[0][2])
    pc_data['value'] = 0
    for n in range(len(pc_data)):
        values = []
        for s in range(len(subjects)):
            values.append(pc_data_array[s][3][n])
        pc_data['value'][n] = np.nanmean(values)


    wmd_data['value'] = wmd_data['value'] + abs(np.nanmin(wmd_data['value'][wmd_data['value']<0])) + 0.000000000000001
    name = "group_pc"
    pc_data.to_csv('/home/despo/mb3152/random_nodes/%s/%s.csv' %(num_nodes,name), header = False, index = False)
    command = '3dUndump -xyz -master %s -prefix /home/despo/mb3152/random_nodes/%s/%s.nii /home/despo/mb3152/random_nodes/%s/%s.csv' %(standard_image,num_nodes,name,num_nodes,name)
    os.system(command)
    name = "group_wmd"
    wmd_data.to_csv('/home/despo/mb3152/random_nodes/%s/%s.csv' %(num_nodes,name), header = False, index = False)
    command = '3dUndump -xyz -master %s -prefix /home/despo/mb3152/random_nodes/%s/%s.nii /home/despo/mb3152/random_nodes/%s/%s.csv' %(standard_image,num_nodes,name,num_nodes,name)
    os.system(command)


def draw_single(subject,num_nodes=600):
    name = 'final_pc_%s' %(subject)
    standard_image='/home/despo/mb3152/random_nodes/MNI152_T1_2mm_brain.nii'
    command = '3dUndump -xyz -master %s -prefix /home/despo/mb3152/random_nodes/%s/%s.nii /home/despo/mb3152/random_nodes/%s/%s.csv' %(standard_image,num_nodes,name,num_nodes,name)
    os.system(command)
    name = 'final_wmd_%s' %(subject)
    command = '3dUndump -xyz -master %s -prefix /home/despo/mb3152/random_nodes/%s/%s.nii /home/despo/mb3152/random_nodes/%s/%s.csv' %(standard_image,num_nodes,name,num_nodes,name)
    os.system(command)


subject = sys.argv[1]
analyze(subject=subject)
# subjects = [114, 116, 117, 118, 201, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218]
# group_analysis(subjects)
