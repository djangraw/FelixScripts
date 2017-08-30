#!/usr/bin/env python
__version__="v2.5 beta8"
welcome_block="""
# Single-Echo ICA to match Multi-Echo ICA, Version %s
#
# Components will be removed at random until a given (input) fraction of variance is removed. 
#
# ---Here's the header for MEICA:
# Kundu, P., Brenowitz, N.D., Voon, V., Worbe, Y., Vertes, P.E., Inati, S.J., Saad, Z.S., 
# Bandettini, P.A. & Bullmore, E.T. Integrated strategy for improving functional 
# connectivity mapping using multiecho fMRI. PNAS (2013).
#
# Kundu, P., Inati, S.J., Evans, J.W., Luh, W.M. & Bandettini, P.A. Differentiating 
#   BOLD and non-BOLD signals in fMRI time series using multi-echo EPI. NeuroImage (2011).
# http://dx.doi.org/10.1016/j.neuroimage.2011.12.028
#
# PROCEDURE 2 : Computes ME-PCA and ME-ICA
# -Computes T2* map 
# -Computes PCA of concatenated ME data, then computes TE-dependence of PCs
# -Computes ICA of TE-dependence PCs
# -Identifies TE-dependent ICs, outputs high-\kappa (BOLD) component
#    and denoised time series
# -or- Computes TE-dependence of each component of a general linear model
#    specified by input (includes MELODIC FastICA mixing matrix)
""" % (__version__)

import os
from optparse import OptionParser
import numpy as np
import nibabel as nib
from sys import stdout,argv
import scipy.stats as stats
import time
import datetime
# SINGLE ECHO: these next few lines are included to add functions that have now been replaced inside this script.
# if __name__=='__main__':
	# selfuncfile='%s/select_model.py' % os.path.dirname(argv[0])
	# execfile(selfuncfile)

#import ipdb

F_MAX=500
Z_MAX = 8

def _interpolate(a, b, fraction):
	"""Returns the point at the given fraction between a and b, where
	'fraction' must be between 0 and 1.
	"""
	return a + (b - a)*fraction;

def scoreatpercentile(a, per, limit=(), interpolation_method='lower'):
	"""
	This function is grabbed from scipy

	"""
	values = np.sort(a, axis=0)
	if limit:
		values = values[(limit[0] <= values) & (values <= limit[1])]

	idx = per /100. * (values.shape[0] - 1)
	if (idx % 1 == 0):
		score = values[idx]
	else:
		if interpolation_method == 'fraction':
			score = _interpolate(values[int(idx)], values[int(idx) + 1],
								 idx % 1)
		elif interpolation_method == 'lower':
			score = values[np.floor(idx)]
		elif interpolation_method == 'higher':
			score = values[np.ceil(idx)]
		else:
			raise ValueError("interpolation_method can only be 'fraction', " \
							 "'lower' or 'higher'")
	return score

def MAD(data, axis=None):
	return np.median(np.abs(data - np.median(data, axis)), axis)

def dice(A,B):
	denom = np.array(A!=0,dtype=np.int).sum(0)+(np.array(B!=0,dtype=np.int).sum(0))
	if denom!=0:
		AB_un = andb([A!=0,B!=0])==2
		numer = np.array(AB_un,dtype=np.int).sum(0)
		return 2.*numer/denom
	else:
		return 0.

def spatclust(data,mask,csize,thr,header,aff,infile=None,dindex=0,tindex=0):
	if infile==None:
		data = data.copy()
		data[data<thr] = 0
		niwrite(unmask(data,mask),aff,'__clin.nii.gz',header)
		infile='__clin.nii.gz'
	addopts=""
	if data!=None and len(np.squeeze(data).shape)>1 and dindex+tindex==0: addopts="-doall"
	else: addopts="-1dindex %s -1tindex %s" % (str(dindex),str(tindex))
	os.system('3dmerge -overwrite %s -dxyz=1  -1clust 1 %i -1thresh %.02f -prefix __clout.nii.gz %s' % (addopts,int(csize),float(thr),infile))
	clustered = fmask(nib.load('__clout.nii.gz').get_data(),mask)!=0
	return clustered

def rankvec(vals):
	asort = np.argsort(vals)
	ranks = np.zeros(vals.shape[0])
	ranks[asort]=np.arange(vals.shape[0])+1
	return ranks

def niwrite(data,affine, name , header=None):
	stdout.write(" + Writing file: %s ...." % name) 
	
	thishead = header
	if thishead == None:
		thishead = head.copy()
		thishead.set_data_shape(list(data.shape))

	outni = nib.Nifti1Image(data,affine,header=thishead)
	outni.to_filename(name)
	print 'done.'

def cat2echos(data,Ne):
	"""
	cat2echos(data,Ne)

	Input:
	data shape is (nx,ny,Ne*nz,nt)
	"""
	nx,ny = data.shape[0:2]
	nz = data.shape[2]/Ne
	if len(data.shape) >3:
		nt = data.shape[3]
	else:
		nt = 1
	return np.reshape(data,(nx,ny,nz,Ne,nt),order='F')

def uncat2echos(data,Ne):
	"""
	uncat2echos(data,Ne)

	Input:
	data shape is (nx,ny,Ne,nz,nt)
	"""
	nx,ny = data.shape[0:2]
	nz = data.shape[2]*Ne
	if len(data.shape) >4:
		nt = data.shape[4]
	else:
		nt = 1
	return np.reshape(data,(nx,ny,nz,nt),order='F')

def makemask(cdat):
	
	nx,ny,nz,Ne,nt = cdat.shape

	mask = np.ones((nx,ny,nz),dtype=np.bool)

	for i in range(Ne):
		tmpmask = (cdat[:,:,:,i,:] != 0).prod(axis=-1,dtype=np.bool)
		mask = mask & tmpmask

	return mask

def fmask(data,mask):
	"""
	fmask(data,mask)

	Input:
	data shape is (nx,ny,nz,...)
	mask shape is (nx,ny,nz)

	Output:
	out shape is (Nm,...)
	"""

	s = data.shape
	sm = mask.shape

	N = s[0]*s[1]*s[2]
	news = []
	news.append(N)

	if len(s) >3:
		news.extend(s[3:])

	tmp1 = np.reshape(data,news)
	fdata = tmp1.compress((mask > 0 ).ravel(),axis=0)

	return fdata.squeeze()

def unmask (data,mask):
	"""
	unmask (data,mask)

	Input:

	data has shape (Nm,nt)
	mask has shape (nx,ny,nz)

	"""
	M = (mask != 0).ravel()
	Nm = M.sum()

	nx,ny,nz = mask.shape

	if len(data.shape) > 1:
		nt = data.shape[1]
	else:
		nt = 1

	out = np.zeros((nx*ny*nz,nt),dtype=data.dtype)
	out[M,:] = np.reshape(data,(Nm,nt))

	return np.reshape(out,(nx,ny,nz,nt))

def t2smap(catd,mask,tes):
	"""
	t2smap(catd,mask,tes)

	Input:

	catd  has shape (nx,ny,nz,Ne,nt)
	mask  has shape (nx,ny,nz)
	tes   is a 1d numpy array
	"""
	nx,ny,nz,Ne,nt = catd.shape
	
	# SINGLE ECHO DATA: JUST RETURN INPUT DATA 3X
	if Ne == 1:
		print 'Single-echo T2smap unknown... returning input.'
		out = catd,catd,catd
		return out
		
	
	N = nx*ny*nz

	echodata = fmask(catd,mask)
	Nm = echodata.shape[0]

	#Do Log Linear fit
	B = np.reshape(np.abs(echodata), (Nm,Ne*nt)).transpose()
	B = np.log(B)
	x = np.array([np.ones(Ne),-tes])
	X = np.tile(x,(1,nt))
	X = np.sort(X)[:,::-1].transpose()

	beta,res,rank,sing = np.linalg.lstsq(X,B)
	t2s = 1/beta[1,:].transpose()
	s0  = np.exp(beta[0,:]).transpose()

	#Goodness of fit
	alpha = (np.abs(B)**2).sum(axis=0)
	t2s_fit = blah = (alpha - res)/(2*res)
	
	out = unmask(t2s,mask),unmask(s0,mask),unmask(t2s_fit,mask)

	return out

def get_coeffs(data,mask,X,add_const=False):
	"""
	get_coeffs(data,X)

	Input:

	data has shape (nx,ny,nz,nt)
	mask has shape (nx,ny,nz)
	X    has shape (nt,nc)

	Output:

	out  has shape (nx,ny,nz,nc)
	""" 
	mdata = fmask(data,mask).transpose()
		
	X=np.atleast_2d(X)
	if X.shape[0]==1: X=X.T
	Xones = np.atleast_2d(np.ones(np.min(mdata.shape))).T
	if add_const: X = np.hstack([X,Xones])

	tmpbetas = np.linalg.lstsq(X,mdata)[0].transpose()
	if add_const: tmpbetas = tmpbetas[:,:-1]
	out = unmask(tmpbetas,mask)

	return out


def andb(arrs):
	result = np.zeros(arrs[0].shape)
	for aa in arrs: result+=np.array(aa,dtype=np.int)
	return result

def optcom(data,t2s,tes,mask):
	"""
	out = optcom(data,t2s)


	Input:

	data.shape = (nx,ny,nz,Ne,Nt)
	t2s.shape  = (nx,ny,nz)
	tes.shape  = (Ne,)

	Output:

	out.shape = (nx,ny,nz,Nt)
	"""
	nx,ny,nz,Ne,Nt = data.shape 

	# SINGLE ECHO: JUST RETURN REGULAR DATA.
	if Ne == 1:
		print 'Single-echo optcom unknown... returning input.'
		return np.reshape(data,(nx,ny,nz,Nt))
		
	fdat = fmask(data,mask)
	ft2s = fmask(t2s,mask)
	
	tes = tes[np.newaxis,:]
	ft2s = ft2s[:,np.newaxis]
	
	alpha = tes * np.exp(-tes /ft2s)
	alpha = np.tile(alpha[:,:,np.newaxis],(1,1,Nt))

	fout  = np.average(fdat,axis = 1,weights=alpha)
	out = unmask(fout,mask)
	print 'Out shape is ', out.shape
	return out

def getelbow(ks):
	nc = ks.shape[0]
	coords = np.array([np.arange(nc),ks])
	p  = coords - np.tile(np.reshape(coords[:,0],(2,1)),(1,nc))
	b  = p[:,-1] 
	b_hat = np.reshape(b/np.sqrt((b**2).sum()),(2,1))
	proj_p_b = p - np.dot(b_hat.T,p)*np.tile(b_hat,(1,nc))
	d = np.sqrt((proj_p_b**2).sum(axis=0))
	k_min_ind = d.argmax()
	k_min  = ks[k_min_ind]
	return k_min_ind

def getfbounds(ne):
	F05s=[None,None,18.5,10.1,7.7,6.6,6.0,5.6,5.3,5.1,5.0]
	F025s=[None,None,38.5,17.4,12.2,10,8.8,8.1,7.6,7.2,6.9]
	F01s=[None,None,98.5,34.1,21.2,16.2,13.8,12.2,11.3,10.7,10.]
	return F05s[ne-1],F025s[ne-1],F01s[ne-1]

def eimask(dd,ees=None):
	if ees==None: ees=range(dd.shape[1])
	imask = np.zeros([dd.shape[0],len(ees)])
	for ee in ees:
		print ee
		lthr = 0.001*scoreatpercentile(dd[:,ee,:].flatten(),98)
		hthr = 5*scoreatpercentile(dd[:,ee,:].flatten(),98)
		print lthr,hthr
		imask[dd[:,ee,:].mean(1) > lthr,ee]=1
		imask[dd[:,ee,:].mean(1) > hthr,ee]=0
	return imask

def tedpca(ste=0,varex_fractoremove=0.3):
	# SINGLE ECHO: new input pcvarexfrac specifies the minimum % variance to remove during PC rejection.
	nx,ny,nz,ne,nt = catd.shape
	ste = np.array([int(ee) for ee in str(ste).split(',')])
	if len(ste) == 1 and ste[0]==-1:
		print "-Computing PCA of optimally combined multi-echo data"
		OCcatd = optcom(catd,t2s,tes,mask)
		OCmask = makemask(OCcatd[:,:,:,np.newaxis,:])
		d = fmask(OCcatd,OCmask)
		eim = eimask(d[:,np.newaxis,:])
		eim = eim[:,0]==1
		d = d[eim,:]
		#ipdb.set_trace()
	elif len(ste) == 1 and ste[0]==0:
		print "-Computing PCA of spatially concatenated multi-echo data"
		ste = np.arange(ne)
		d = np.float64(fmask(catd,mask))
		eim = eimask(d)==1
		d = d[eim]
	else:
		print "-Computing PCA of TE #%s" % ','.join([str(ee) for ee in ste])
		d = np.float64(np.concatenate([fmask(catd[:,:,:,ee,:],mask)[:,np.newaxis,:] for ee in ste-1],axis=1))
		eim = eimask(d)==1
		d = d[eim]

	dz = ((d.T-d.T.mean(0))/d.T.std(0)).T #Variance normalize timeseries
	dz = (dz-dz.mean())/dz.std() #Variance normalize everything
	
	##Do PC dimension selection
	#Get eigenvalue cutoff
	u,s,v = np.linalg.svd(dz,full_matrices=0)
	sp = s/s.sum()
	# eigelb = sp[getelbow(sp)]

	spdif = np.abs(sp[1:]-sp[:-1])
	spdifh = spdif[spdif.shape[0]/2:]
	spdmin = spdif.min()
	spdthr = np.mean([spdifh.max(),spdmin])
	spmin = sp[(spdif.shape[0]/2)+(np.arange(spdifh.shape[0])[spdifh>=spdthr][0])+1]
	spcum = []
	spcumv = 0
	for sss in sp:
		spcumv+=sss
		spcum.append(spcumv)
	spcum = np.array(spcum)
		
	#Compute K and Rho for PCA comps 
	eimum = np.array(np.squeeze(unmask(np.array(np.atleast_2d(eim).T,dtype=np.int).prod(1),mask)),dtype=np.bool)
	vTmix = v.T
	vTmixN =((vTmix.T-vTmix.T.mean(0))/vTmix.T.std(0)).T
	#ctb,KRd,betasv,v_T = fitmodels2(catd,v.T,eimum,t2s,tes,mmixN=vTmixN)
	none,ctb,betasv,v_T = fitmodels_direct_1echo(catd,v.T,eimum,t2s,tes,mmixN=vTmixN,full_sel=False) 
	ctb = ctb[ctb[:,0].argsort(),:] # re-sort in descending order of kappa
	varex = ctb[:,3] # SINGLE ECHO: THIS MAY BE USED LATER FOR COMPONENT REJECTION
	ctb = np.vstack([ctb.T[0:3],sp]).T # columns: number, kappa, rho, singular values (normalized to sum to 1)	
	np.savetxt('comp_table_pca.txt',ctb[ctb[:,1].argsort(),:][::-1])
	np.savetxt('mepca_mix.1D',v[ctb[:,1].argsort()[::-1],:].T)
	# SINGLE ECHO: LEAVE OUT K/RHO CALCS.
	""""
	kappas = ctb[ctb[:,1].argsort(),1]
	rhos = ctb[ctb[:,2].argsort(),2]
	fmin,fmid,fmax = getfbounds(ne)
	kappa_thr = np.average(sorted([fmin,kappas[getelbow(kappas)]/2,fmid]),weights=[kdaw,1,1])
	rho_thr = np.average(sorted([fmin,rhos[getelbow(rhos)]/2,fmid]),weights=[rdaw,1,1])
	if int(kdaw)==-1:
		kappas_lim = kappas[andb([kappas<fmid,kappas>fmin])==2]
		#kappas_lim = kappas[andb([kappas<kappas[getelbow(kappas)],kappas>fmin])==2]
		kappa_thr = kappas_lim[getelbow(kappas_lim)]
		rhos_lim = rhos[andb([rhos<fmid,rhos>fmin])==2]
		rho_thr = rhos_lim[getelbow(rhos_lim)]
		options.stabilize=True
	if int(kdaw)!=-1 and int(rdaw)==-1:
		rhos_lim = rhos[andb([rhos<fmid,rhos>fmin])==2]
		rho_thr = rhos_lim[getelbow(rhos_lim)]
	if options.stabilize:
		pcscore = (np.array(ctb[:,1]>kappa_thr,dtype=np.int)+np.array(ctb[:,2]>rho_thr,dtype=np.int)+np.array(ctb[:,3]>eigelb,dtype=np.int))*np.array(ctb[:,3]>spmin,dtype=np.int)*np.array(spcum<0.95,dtype=np.int)*np.array(ctb[:,2]>fmin,dtype=np.int)*np.array(ctb[:,1]>fmin,dtype=np.int)*np.array(ctb[:,1]!=F_MAX,dtype=np.int)*np.array(ctb[:,2]!=F_MAX,dtype=np.int) 
	else:
		pcscore = (np.array(ctb[:,1]>kappa_thr,dtype=np.int)+np.array(ctb[:,2]>rho_thr,dtype=np.int)+np.array(ctb[:,3]>eigelb,dtype=np.int))*np.array(ctb[:,3]>spmin,dtype=np.int)*np.array(ctb[:,1]!=F_MAX,dtype=np.int)*np.array(ctb[:,2]!=F_MAX,dtype=np.int)
	pcsel = pcscore > 0 
	pcrej = np.array(pcscore==0,dtype=np.int)*np.array(ctb[:,3]>spmin,dtype=np.int) > 0
	"""
	# SINGLE ECHO: REMOVE PC'S RANDOMLY UNTIL A CERTAIN % VAR EXPLAINED HAS BEEN REACHED
	nc = varex.shape[0]
	pcsel = np.zeros(nc,dtype=np.int)
	acc = np.arange(0,nc)
	rej = np.zeros(0,dtype=np.int)
	varex_fracremoved = 0
	while varex_fracremoved < varex_fractoremove:		
		iToRemove = np.random.randint(0,acc.size)
		toRemove = acc[iToRemove]
		acc = np.delete(acc,iToRemove)
		rej = np.append(rej,toRemove)
		varex_fracremoved = varex[rej].sum()/varex.sum()
	# Turn acc into binary vector
	pcsel = np.zeros(nc,dtype=np.bool)
	pcsel[acc] = 1
	
	# Write component outputs
	pca_outfile = np.vstack([ctb[:,0].T,varex.T,pcsel]).T
	np.savetxt('pca_num-var-acc.txt',pca_outfile)
	np.savetxt('pca_fracvarremoved.txt',np.array([varex_fracremoved]))
	
	# Prepare outputs
	dd = u.dot(np.diag(s*np.array(pcsel,dtype=np.int))).dot(v)
	nc = s[pcsel].shape[0]
	print pcsel
	# print "--Selected %i components. Minimum Kappa=%0.2f Rho=%0.2f" % (nc,kappa_thr,rho_thr)

	dd = ((dd.T-dd.T.mean(0))/dd.T.std(0)).T #Variance normalize timeseries
	dd = (dd-dd.mean())/dd.std() #Variance normalize everything

	return nc,dd

def tedica(dd,cost):
	"""
	Input is dimensionally reduced spatially concatenated multi-echo time series dataset from tedpca()
	Output is comptable, mmix, smaps from ICA, and betas from fitting catd to mmix
	"""
	#Do ICA
	climit = float("%s" % options.conv)
	#icanode = mdp.nodes.FastICANode(white_comp=nc, white_parm={'svd':True},approach='symm', g=cost, fine_g=options.finalcost, limit=climit, verbose=True)
	# icanode = mdp.nodes.FastICANode(white_comp=nc,approach='symm', g=cost, fine_g=options.finalcost, primary_limit=climit*100, limit=climit, verbose=True)
	icanode = mdp.nodes.FastICANode(white_comp=nc,approach='symm', g=cost, fine_g=options.finalcost, limit=climit, verbose=True)
	icanode.train(dd)
	smaps = icanode.execute(dd)
	mmix = icanode.get_recmatrix().T
	mmix = (mmix-mmix.mean(0))/mmix.std(0)
	return mmix

def write_split_ts(data,comptable,mmix,suffix=''):
	mdata = fmask(data,mask)
	betas = fmask(get_coeffs(unmask((mdata.T-mdata.T.mean(0)).T,mask),mask,mmix),mask)
	dmdata = mdata.T-mdata.T.mean(0)
	varexpl = (1-((dmdata.T-betas.dot(mmix.T))**2.).sum()/(dmdata**2.).sum())*100
	print 'Variance explained: ', varexpl , '%'
	niwrite(unmask(betas[:,acc].dot(mmix.T[acc,:]),mask),aff,'_'.join(['hik_ts',suffix])+'.nii')
	midkts = betas[:,midk].dot(mmix.T[midk,:])
	lowkts = betas[:,rej].dot(mmix.T[rej,:])
	if len(midk)!=0: niwrite(unmask(midkts,mask),aff,'_'.join(['midk_ts',suffix])+'.nii')
	niwrite(unmask(lowkts,mask),aff,'_'.join(['lowk_ts',suffix])+'.nii')
	niwrite(unmask(fmask(data,mask)-lowkts-midkts,mask),aff,'_'.join(['dn_ts',suffix])+'.nii')
	return varexpl

def split_ts(data,comptable,mmix):
	cbetas = get_coeffs(data-data.mean(-1)[:,:,:,np.newaxis],mask,mmix)
	betas = fmask(cbetas,mask)
	hikts=unmask(betas[:,acc].dot(mmix.T[acc,:]),mask)
	return hikts,data-hikts

def writefeats(cbetas,comptable,mmix,suffix=''):
	#Write signal changes (dS)
	niwrite(cbetas[:,:,:,:],aff,'_'.join(['betas',suffix])+'.nii')
	niwrite(cbetas[:,:,:,acc],aff,'_'.join(['betas_hik',suffix])+'.nii')
	#Compute features (dS/S)
	if options.e2d==None: e2d=np.floor(ne/2)+1
	edm = fmask(catd[:,:,:,e2d-1,:],mask)
	edms = edm/edm.std(-1)[:,np.newaxis]
	edms[edm<1]=0
	hik,noise = split_ts(unmask(edms,mask),comptable,mmix)
	noise = noise-noise.mean(-1)[:,:,:,np.newaxis]

	zfac = 1./(mmix.shape[0]-len(acc)-1)*(noise**2).sum(-1) #noise scaling
	niwrite(zfac,aff,'zfac.nii')
	
	cbetam = fmask(cbetas[:,:,:,acc],mask)
	cbetam = (cbetam-cbetam.mean(0))/cbetam.std(0)
	cbetam = cbetam/fmask(zfac,mask)[:,np.newaxis]
	cbetam[edm.mean(-1)<1,:] = 0
	
	niwrite(unmask(cbetam,mask),aff,'_'.join(['feats',suffix])+'.nii')
	
def computefeats2(data,mmix,mask,normalize=True):
	#Write feature versions of components 
	data = data[mask]
	data_vn = (data-data.mean(axis=-1)[:,np.newaxis])/data.std(axis=-1)[:,np.newaxis]
	data_R = get_coeffs(unmask(data_vn,mask),mask,mmix)[mask]
	data_R[data_R<-.999] = -0.999
	data_R[data_R>.999] = .999
	data_Z = np.arctanh(data_R)
	if normalize:
		#data_Z2 = ((data_Z.T-data_Z.mean(0)[:,np.newaxis])/data_Z.std(0)[:,np.newaxis]).T
		data_Z = (((data_Z.T-data_Z.mean(0)[:,np.newaxis])/data_Z.std(0)[:,np.newaxis])  + (data_Z.mean(0)/data_Z.std(0))[:,np.newaxis]).T
	return data_Z

def writefeats2(data,mmix,mask,suffix=''):
	#Write feature versions of components 
	feats = computefeats2(data,mmix,mask)
	niwrite(unmask(feats,mask),aff,'_'.join(['feats',suffix])+'.nii')

def writect(comptable,ctname='',varexpl='-1',classarr=[]):
	global acc,rej,midk,empty
	if len(classarr)!=0:
		acc,rej,midk,empty = classarr
	nc = comptable.shape[0]
	ts = time.time()
	st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
	# sortab = comptable[comptable[:,1].argsort()[::-1],:]
	sortab = comptable[comptable[:,0].argsort()[::-1],:] # SINGLE ECHO: SORT BY COMP #, NOT KAPPAS (WHICH ARE ALL 0)
	if ctname=='': ctname = 'comp_table.txt'
	open('accepted.txt','w').write(','.join([str(int(cc)) for cc in acc]))
	open('rejected.txt','w').write(','.join([str(int(cc)) for cc in rej]))
	open('midk_rejected.txt','w').write(','.join([str(int(cc)) for cc in midk]))
	open('varex.txt','w').write(','.join([str(float(cc)) for cc in sortab[:,3]])) # SINGLE ECHO: ADDED THIS LINE
	with open(ctname,'w') as f:
		f.write("#\n#SE-ICA Component statistics table for: %s \n#Run on %s \n#\n" % (os.path.abspath(os.path.curdir),st) )
		f.write("#Dataset variance explained by ICA (VEx): %.02f \n" %  ( varexpl ) )
		f.write("#Total components generated by decomposition (TCo): %i \n" %  ( nc ) )
		f.write("#No. accepted BOLD-like components, i.e. effective degrees of freedom for correlation (lower bound; DFe): %i\n" %  ( len(acc) ) )
		f.write("#Total number of rejected components (RJn): %i\n" %  (len(midk)+len(rej)) )
		f.write("#Nominal degress of freedom in denoised time series (..._medn.nii.gz; DFn): %i \n" %  (nt-len(midk)-len(rej)) )
		f.write("#ACC %s \t#Accepted BOLD-like components\n" % ','.join([str(int(cc)) for cc in acc]) )
		f.write("#REJ %s \t#Rejected non-BOLD components\n" % ','.join([str(int(cc)) for cc in rej]) )
		f.write("#MID %s \t#Rejected R2*-weighted artifacts\n" % ','.join([str(int(cc)) for cc in midk]) )
		f.write("#IGN %s \t#Ignored components (kept in denoised time series)\n" % ','.join([str(int(cc)) for cc in empty]) )
		f.write("#VEx	TCo	DFe	RJn	DFn	\n")
		f.write("##%.02f	%i	%i	%i	%i \n" % (varexpl,nc,len(acc),len(midk)+len(rej),nt-len(midk)-len(rej)))
		f.write("#	comp	Kappa	Rho	%%Var	%%Var(norm)	\n")
		for i in range(nc):
			f.write('%d\t%f\t%f\t%.2f\t%.2f\n'%(sortab[i,0],sortab[i,1],sortab[i,2],sortab[i,3],sortab[i,4]))

def fitmodels_direct_1echo(catd,mmix,mask,t2s,tes,fout=None,reindex=False,mmixN=None,full_sel=True,debugout=False):
	"""
   	Usage:
   	
   	fitmodels_direct(fout)
	
   	Input:
   	fout is flag for output of per-component TE-dependence maps
   	t2s is a (nx,ny,nz) ndarray
   	tes is a 1d array
   	"""
	
   	#Compute opt. com. raw data
	tsoc = np.array(optcom(catd,t2s,tes,mask),dtype=float)[mask]
	tsoc_mean = tsoc.mean(axis=-1)
	tsoc_dm = tsoc-tsoc_mean[:,np.newaxis]
	
	#Compute un-normalized weight dataset (features)
	if mmixN == None: mmixN=mmix
	WTS = computefeats2(unmask(tsoc,mask),mmixN,mask,normalize=False)

	#Compute PSC dataset - shouldn't have to refit data
	tsoc_B = get_coeffs(unmask(tsoc_dm,mask),mask,mmix)[mask]
	tsoc_Babs = np.abs(tsoc_B)
	PSC = tsoc_B/tsoc.mean(axis=-1)[:,np.newaxis]*100

	#Compute skews to determine signs based on unnormalized weights, correct mmix & WTS signs based on spatial distribution tails
	from scipy.stats import skew
	signs = skew(WTS,axis=0)
	signs /= np.abs(signs)
	mmix = mmix.copy()
	mmix*=signs
	WTS*=signs
	PSC*=signs
	totvar = (tsoc_B**2).sum()
	totvar_norm = (WTS**2).sum()

	#Compute Betas and means over TEs for TE-dependence analysis
	Ne = tes.shape[0]
	betas = cat2echos(get_coeffs(uncat2echos(catd,Ne),np.tile(mask,(1,1,Ne)),mmix),Ne)
	nx,ny,nz,Ne,nc = betas.shape
	Nm = mask.sum()
	mu = catd.mean(axis=-1)
	tes = np.reshape(tes,(Ne,1))
	fmin,fmid,fmax = getfbounds(ne)

	#Mask arrays
	mumask   = fmask(mu,mask)
	t2smask  = fmask(t2s,mask)
	betamask = fmask(betas,mask)

	if debugout: fout=aff

	#Setup Xmats
	#Model 1
	X1 = mumask.transpose()
	
	#Model 2
	X2 = np.tile(tes,(1,Nm))*mumask.transpose()/t2smask.transpose()
	
	#Tables for component selection
	Kappas = np.zeros([nc])
	Rhos = np.zeros([nc])
	varex = np.zeros([nc])
	varex_norm = np.zeros([nc])
	Z_maps = np.zeros([Nm,nc])
	F_R2_maps = np.zeros([Nm,nc])
	F_S0_maps = np.zeros([Nm,nc])
	Z_clmaps = np.zeros([Nm,nc])
	F_R2_clmaps = np.zeros([Nm,nc])
	F_S0_clmaps = np.zeros([Nm,nc])
	Br_clmaps_R2 = np.zeros([Nm,nc])
	Br_clmaps_S0 = np.zeros([Nm,nc])

	for i in range(nc):

		#size of B is (nc, nx*ny*nz)
		# B = np.atleast_3d(betamask)[:,:,i].transpose() # SINGLE ECHO: NOT NEEDED
		# alpha = (np.abs(B)**2).sum(axis=0) # SINGLE ECHO: NOT NEEDED
		varex[i] = (tsoc_B[:,i]**2).sum()/totvar*100.
		varex_norm[i] = (WTS[:,i]**2).sum()/totvar_norm*100.

		# SINGLE ECHO: ONLY VARIANCE IS NEEDED... LEAVE EVERYTHING ELSE AS ZEROS
		"""
		#S0 Model
		coeffs_S0 = (B*X1).sum(axis=0)/(X1**2).sum(axis=0)
		SSE_S0 = (B - X1*np.tile(coeffs_S0,(Ne,1)))**2
		SSE_S0 = SSE_S0.sum(axis=0)
		F_S0 = (alpha - SSE_S0)*2/(SSE_S0)
		F_S0_maps[:,i] = F_S0

		#R2 Model
		print B.shape
		print X2.shape
		coeffs_R2 = (B*X2).sum(axis=0)/(X2**2).sum(axis=0)
		SSE_R2 = (B - X2*np.tile(coeffs_R2,(Ne,1)))**2
		SSE_R2 = SSE_R2.sum(axis=0)
		F_R2 = (alpha - SSE_R2)*2/(SSE_R2)
		F_R2_maps[:,i] = F_R2

		#Compute weights as Z-values
		wtsZ=(WTS[:,i]-WTS[:,i].mean())/WTS[:,i].std()
		wtsZ[np.abs(wtsZ)>Z_MAX]=(Z_MAX*(np.abs(wtsZ)/wtsZ))[np.abs(wtsZ)>Z_MAX]
		Z_maps[:,i] = wtsZ 

		#Compute Kappa and Rho
		F_S0[F_S0>F_MAX] = F_MAX
		F_R2[F_R2>F_MAX] = F_MAX
		Kappas[i] = np.average(F_R2,weights=np.abs(wtsZ)**2.)
		Rhos[i] = np.average(F_S0,weights=np.abs(wtsZ)**2.)
		"""
		
	#Tabulate component values
	comptab_pre = np.vstack([np.arange(nc),Kappas,Rhos,varex,varex_norm]).T
	if reindex:
		#Re-index all components in Kappa order
		comptab = comptab_pre[comptab_pre[:,1].argsort()[::-1],:]
		Kappas = comptab[:,1]; Rhos = comptab[:,2]; varex = comptab[:,3]; varex_norm = comptab[:,4]
		nnc = np.array(comptab[:,0],dtype=np.int)
		mmix_new = mmix[:,nnc]
		F_S0_maps = F_S0_maps[:,nnc]; F_R2_maps = F_R2_maps[:,nnc]; Z_maps = Z_maps[:,nnc]
		WTS = WTS[:,nnc]; PSC=PSC[:,nnc]; tsoc_B=tsoc_B[:,nnc]; tsoc_Babs=tsoc_Babs[:,nnc]
		comptab[:,0] = np.arange(comptab.shape[0])
	else:
		comptab = comptab_pre
		mmix_new = mmix

	#Full selection including clustering criteria
	seldict=None
	if full_sel: 
		
		# SINGLE ECHO: NONE OF THIS IS NEEDED
		"""
		for i in range(nc):	

			#Save out files
			out = np.zeros((nx,ny,nz,4))
			if fout!=None: 
				ccname = "cc%.3d.nii" % i
			else: ccname = ".cc_temp.nii.gz"

			out[:,:,:,0] = np.squeeze(unmask(PSC[:,i],mask))
			out[:,:,:,1] = np.squeeze(unmask(F_R2_maps[:,i],mask))
			out[:,:,:,2] = np.squeeze(unmask(F_S0_maps[:,i],mask))
			out[:,:,:,3] = np.squeeze(unmask(Z_maps[:,i],mask))
			niwrite(out,fout,ccname)
			os.system('3drefit -sublabel 0 PSC -sublabel 1 F_R2  -sublabel 2 F_SO -sublabel 3 Z_sn %s 2> /dev/null > /dev/null'%ccname)

			csize = np.max([int(Nm*0.0005)+5,20])

			#Do simple clustering on F
			os.system("3dcalc -overwrite -a %s[1..2] -expr 'a*step(a-%i)' -prefix .fcl_in.nii.gz -overwrite" % (ccname,fmin))
			os.system('3dmerge -overwrite -dxyz=1 -1clust 1 %i -doall -prefix .fcl_out.nii.gz .fcl_in.nii.gz' % (csize))
			sel = fmask(nib.load('.fcl_out.nii.gz').get_data(),mask)!=0
			sel = np.array(sel,dtype=np.int)
			F_R2_clmaps[:,i] = sel[:,0]
			F_S0_clmaps[:,i] = sel[:,1]

			#Do simple clustering on Z at p<0.05
			sel = spatclust(None,mask,csize,1.95,head,aff,infile=ccname,dindex=3,tindex=3)
			Z_clmaps[:,i] = sel

			#Do simple clustering on ranked signal-change map
			countsigFR2 = F_R2_clmaps[:,i].sum()
			countsigFS0 = F_S0_clmaps[:,i].sum()
			Br_clmaps_R2[:,i] = spatclust(rankvec(tsoc_Babs[:,i]),mask,csize,max(tsoc_Babs.shape)-countsigFR2,head,aff)
			Br_clmaps_S0[:,i] = spatclust(rankvec(tsoc_Babs[:,i]),mask,csize,max(tsoc_Babs.shape)-countsigFS0,head,aff)
		"""
		# Construct output dictionary
		seldict = {}
		selvars = ['Kappas','Rhos','WTS','varex','Z_maps','F_R2_maps','F_S0_maps',\
			'Z_clmaps','F_R2_clmaps','F_S0_clmaps','tsoc_B','Br_clmaps_R2','Br_clmaps_S0']
		for vv in selvars:
			seldict[vv] = eval(vv)
		
		if debugout or ('DEBUGOUT' in args):
			#Package for debug
			import cPickle as cP
			import zlib
			try: os.system('mkdir compsel.debug')
			except: pass
			selvars = ['Kappas','Rhos','WTS','varex','Z_maps','Z_clmaps','F_R2_clmaps','F_S0_clmaps','Br_clmaps_R2','Br_clmaps_S0']
			for vv in selvars:
				with open('compsel.debug/%s.pkl.gz' % vv,'wb') as ofh:
					print "Writing debug output: compsel.debug/%s.pkl.gz" % vv
					ofh.write(zlib.compress(cP.dumps(eval(vv))))
					ofh.close()

	return seldict,comptab,betas,mmix_new
	
	
	
def selcomps_1echo(seldict,debug=False,olevel=2,oversion=99,knobargs='',varex_fractoremove=0.3):
	
	#Dump dictionary into variable names
	for key in seldict.keys(): exec("%s=seldict['%s']" % (key,key))
	
	nc = varex.shape[0]
	acc = np.arange(0,nc)
	rej = np.zeros(0,dtype=np.int)
	varex_fracremoved = 0
	while varex_fracremoved < varex_fractoremove:
		iToRemove = np.random.randint(0,acc.size)
		toRemove = acc[iToRemove]
		acc = np.delete(acc,iToRemove)
		rej = np.append(rej,toRemove)
		varex_fracremoved = varex[rej].sum()/varex.sum()
	
	print "acc: "
	print acc
	print "rej: "
	print rej
	return list(sorted(acc)),list(sorted(rej)),[],[]	
	# return list(sorted(ncl)),list(sorted(rej)),list(sorted(midk)),list(sorted(ign))
	
	
	
###################################################################################################
# 						Begin Main
###################################################################################################

if __name__=='__main__':

	parser=OptionParser()
	parser.add_option('-d',"--orig_data",dest='data',help="Spatially Concatenated Multi-Echo Dataset",default=None)
	parser.add_option('-e',"--TEs",dest='tes',help="Echo times (in ms) ex: 15,39,63",default=None)
	parser.add_option('',"--mix",dest='mixm',help="Mixing matrix. If not provided, SE-PCA & SE-ICA (MDP) is done.",default=None)
	parser.add_option('',"--manacc",dest='manacc',help="Comma separated list of manually accepted components",default=None)
	parser.add_option('',"--kdaw",dest='kdaw',help="Dimensionality augmentation weight (Kappa). Default 10. -1 for low-dimensional ICA",default=10.)
	parser.add_option('',"--rdaw",dest='rdaw',help="Dimensionality augmentation weight (Rho). Default 1. -1 for low-dimensional ICA",default=1.)
	parser.add_option('',"--conv",dest='conv',help="Convergence limit. Default 2.5e-5",default='2.5e-5')
	parser.add_option('',"--sourceTEs",dest='ste',help="Source TEs for models. ex: -ste 2,3 ; -ste 0 for all, -1 for opt. com. Default -1.",default=0-1)	
	parser.add_option('',"--denoiseTE",dest='e2d',help="TE to denoise. Default middle",default=None)	
	parser.add_option('',"--initcost",dest='initcost',help="Initial cost func. for ICA: pow3,tanh(default),gaus,skew",default='tanh')
	parser.add_option('',"--finalcost",dest='finalcost',help="Final cost func, same opts. as initial",default='tanh')	
	parser.add_option('',"--stabilize",dest='stabilize',action='store_true',help="Stabilize convergence by reducing dimensionality, for low quality data",default=False)
	parser.add_option('',"--fout",dest='fout',help="Output TE-dependence Kappa/Rho SPMs",action="store_true",default=False)
	parser.add_option('',"--label",dest='label',help="Label for output directory.",default=None)
	parser.add_option('',"--pcvarexfrac",dest='pcvarexfrac',help="Fraction of variance to remove during PCA (randomly selected)",default='0.3')
	parser.add_option('',"--icvarexfrac",dest='icvarexfrac',help="Fraction of variance to remove during ICA (randomly selected)",default='0.3')

	(options,args) = parser.parse_args()

	print "-- SE-PCA/SE-ICA Component for SE-ICA %s--" % __version__

	if options.tes==None or options.data==None: 
		print "*+ Need at least data and TEs, use -h for help."		
		sys.exit()

	print "++ Loading Data"
	tes = np.fromstring(options.tes,sep=',',dtype=np.float32) # SINGLE-ECHO: SHOULD JUST BE 1 ECHO
	ne = tes.shape[0] # SINGLE-ECHO: SHOULD BE 1
	catim  = nib.load(options.data)	
	head   = catim.get_header()
	head.extensions = []
	head.set_sform(head.get_sform(),code=1)
	aff = catim.get_affine()
	catd = cat2echos(catim.get_data(),ne)
	nx,ny,nz,Ne,nt = catd.shape
	mu  = catd.mean(axis=-1)
	sig  = catd.std(axis=-1)

	"""Parse options, prepare output directory"""
	if options.fout: options.fout = aff
	else: options.fout=None
	kdaw = float(options.kdaw)
	rdaw = float(options.rdaw)
	if options.label!=None: dirname='%s' % '.'.join(['TED',options.label])
	else: dirname='TED'
	os.system('mkdir %s' % dirname)
	if options.mixm!=None: 
		try:
			os.system('cp %s %s/meica_mix.1D; cp %s %s/%s' % (options.mixm,dirname,options.mixm,dirname,os.path.basename(options.mixm)))
		except:
			pass
	pcvarexfrac = float(options.pcvarexfrac) # SINGLE ECHO: fraction of variance explained to remove during PC selection.
	icvarexfrac = float(options.icvarexfrac) # SINGLE ECHO: fraction of variance explained to remove during IC selection.
	os.chdir(dirname)
	
	print "++ Computing Mask"
	mask  = makemask(catd)

	print "++ Computing T2* map"
	t2s,s0,t2s_fit   = t2smap(catd,mask,tes) # SINGLE ECHO: RETURNS INPUT
	#Condition values
	cap_t2s = scoreatpercentile(t2s.flatten(),99.5)
	t2s[t2s>cap_t2s*10]=cap_t2s 
	niwrite(s0,aff,'s0v.nii')
	niwrite(t2s,aff,'t2sv.nii')
	niwrite(t2s_fit,aff,'t2sF.nii')

	if options.mixm == None:
		print "++ Doing SE-PCA and SE-ICA with MDP"
		import mdp
		nc,dd = tedpca(options.ste,pcvarexfrac) # SINGLE ECHO: MODIFIED TO SELECT COMPONENTS RANDOMLY
		mmix_orig = tedica(dd,cost=options.initcost)
		np.savetxt('__meica_mix.1D',mmix_orig)
		# seldict,comptable,betas,mmix = fitmodels_direct(catd,mmix_orig,mask,t2s,tes,options.fout,reindex=True) # SINGLE ECHO: THIS SHOULD BE REPLACED!
		seldict,comptable,betas,mmix = fitmodels_direct_1echo(catd,mmix_orig,mask,t2s,tes,options.fout,reindex=True) 
		# acc,rej,midk,empty = selcomps(seldict,knobargs=args) # SINGLE ECHO: THIS SHOULD BE REPLACED!
		acc,rej,midk,empty = selcomps_1echo(seldict,knobargs=args,varex_fractoremove=icvarexfrac)
		np.savetxt('meica_mix.1D',mmix)
		del dd
		# SINGLE ECHO: Write component outputs
		pcsel = np.zeros(comptable.shape[0])
		pcsel[acc]=1
		ica_outfile = np.vstack([comptable[:,0].T,seldict['varex'].T,pcsel]).T
		np.savetxt('ica_num-var-acc.txt',ica_outfile)
		varex = seldict['varex']
		varex_fracremoved = varex[rej].sum()/varex.sum()
		np.savetxt('ica_fracvarremoved.txt',np.array([varex_fracremoved]))
		
	else:
		mmix_orig = np.loadtxt('meica_mix.1D')
		eim = eimask(np.float64(fmask(catd,mask)))==1
		eimum = np.array(np.squeeze(unmask(np.array(eim,dtype=np.int).prod(1),mask)),dtype=np.bool)
		seldict,comptable,betas,mmix = fitmodels_direct(catd,mmix_orig,mask,t2s,tes,options.fout)
		acc,rej,midk,empty = selcomps(seldict,knobargs=args)
			
	
	print "++ Writing optimally combined time series"
	ts = optcom(catd,t2s,tes,mask) # SINGLE ECHO: RETURNS INPUT
	niwrite(ts,aff,'ts_OC.nii')
	print "++ Writing Kappa-filtered optimally combined timeseries"
	varexpl = write_split_ts(ts,comptable,mmix,'OC')
	print "++ Writing signal versions of components"
	#ipdb.set_trace()
	ts_B = get_coeffs(ts,mask,mmix)
	niwrite(ts_B[:,:,:,:],aff,'_'.join(['betas','OC'])+'.nii')
	niwrite(ts_B[:,:,:,acc],aff,'_'.join(['betas_hik','OC'])+'.nii')
	print "++ Writing optimally combined high-Kappa features"
	writefeats2(split_ts(ts,comptable,mmix)[0],mmix[:,acc],mask,'OC2')

	print "++ Writing component table"
	writect(comptable,'comp_table.txt',varexpl)

	if options.e2d!=None:
		options.e2d=int(options.e2d)
		print "++ Writing Kappa-filtered TE#%i timeseries" % (options.e2d)
		write_split_ts(catd[:,:,:,options.e2d-1,:],comptable,mmix,'e%i' % options.e2d)
		print "++ Writing high-Kappa TE#%i  features" % (options.e2d)
		writefeats(betas[:,:,:,options.e2d-1,:],comptable,mmix,'e%i' % options.e2d)
