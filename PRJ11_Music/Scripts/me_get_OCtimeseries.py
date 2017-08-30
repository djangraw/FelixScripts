#!/usr/bin/env python
__version__="0.1"
import sys
import os
help_desc="""
This program generates optimally combined time-series based on T2* maps previously computed:

Usage:
------

At a minimum, this program will require:

   * ME Dataset: This will be a 4D dataset in which the different echoes have been concatenated in the Z-direction. This
                 means that for a dataset with Ne echoes and dimensions (Nx,Ny,Nz,Nt) the input to this QA program should
                 be a dataset with dimensions (Nx,Ny,Nz*Ne,Nt). Such datasets can be easily created using AFNI program
                 3dZcat (e.g., 3dZcat -prefix MEdataset.nii E01.nii E02.nii E03.nii).
                 To pass the ME dataset please use -d or --orig_data

   * Echo times: The program needs to know the echo times (in milisenconds) used during data acquisition. There are two
                 ways to provide the echo times. You can provide them on the command line using -e and a list of echo times
                 separated by commas. You can also provide them via a text file with --tes_file. The file should contain
                 a single line of text with the echo times separated by commas (e.g., 12,24,35). 

  * Mask of valid voxels: a mask that tells the program which voxels are not valid. These voxels will have zeros as output. These
                 are voxels for which the T2* maps are known to be erroneous.This is provided via --mask

  * T2* Maps:   voxel-wise T2* estimates map. This is provided via --t2s

Additional information the program can take as inputs include:

   * Prefix: provided with the option --prefix PREFIX. All outputs will start with this prefix. If not provided, the default
                prefix is sbj

   * Output Directory: provided with the option --out_dir DIR. All files will be written to this location. If not provided,
                files will be written to the current directory.

Sample Usage Lines:
-------------------

  $ python me_get_OCtimeseries.py --tes_file Echoes.1D -d SBJ_ZcatEchoes.nii --prefix SBJ_RESULT --mask SBJ_mask.nii --t2s SBJ_t2s.nii

Program Outputs:
----------------
    
    * <prefix>.OCTS.nii: Voxel-wise optimally combined timeseries.
    
Dependences:
------------
This program was coded and tested with Python 2.7.10.
   
This program requires:

   * Numpy:           Python package for manipulation of numeric arrays. To install, please run: pip install numpy.
   * Scipy:           Scientific Library for Python. To install, please run: pip install scipy.
   * Nibabel:         Library to load NeuroImaging datasets. To install, please run: pip install nibabel.
   * SKLearn:         Python modules for machine learning and data mining. To install, please run: pip install sklearn
   * multiprocessing: Backport for multiprocesing package. To install, please run: pip install multiprocessing.
   * argparse:        Python argument parser. To install, please run: pip install argparse
"""
# =================================================================================================================
# =================================         FUNCTION DEFINITIONS            =======================================
# =================================================================================================================   

# === FUNCTION: dep_check
def dep_check():
    print "++ INFO [Main]: Checking for dependencies...."
    fails                = 0
    modules = set(["numpy","argparse","scipy","sklearn","multiprocessing","nibabel"])
    
    for m in modules:
        try:
            __import__(m)
        except ImportError:
            fails += 1
            print "++ ERROR [Main]: Can't import Module %s. Please install." % m

    if fails == 0:
        print(" +              All Dependencies are OK.")
    else:
        print(" +               All dependencies not available. Please install according to above error messages.")
        print(" +               Program exited.")
        sys.exit()
        
# === FUNCTION: niiLoad
def niiLoad(path):
    """
    This function reads nifti datasets
    
    Parameters:
    -----------
    path: string containing the path to the NIFTI file you want to read.
    
    Returns:
    --------
    data: a numpy array with the data
    aff:  the affine transformation associated with the dataset. Needed in order to write to disk again.
    head: the header of the nifti dataset.
    """
    mepi_dset       = nib.load(path)
    data            = mepi_dset.get_data()
    aff             = mepi_dset.get_affine()
    head            = mepi_dset.get_header()
    head.extensions = []
    head.set_sform(head.get_sform(),code=1)
    return data,aff,head

# === FUNCTION: mask4MEdata
def mask4MEdata(data):
    """
    This function will create a mask for ME data taking into
    account the time series of all echoes. It expects datasets already masked in AFNI. What this function does
    is to compose a new mask that only includes voxels that were included by 3dAutomask for all echoes.
	
    Paramters:
    ----------
    data: this is a (Nx,Ny,Nz,Ne,Nt) array with ME data.

    Returns:
    --------
    mask: this is a (Nx,Ny,Nz) marking all voxels that have valid time-series for all echo times.
    """
    # Create mask taking into account all echoes
    Nx,Ny,Nz,Ne,Nt = data.shape
    mask           = np.ones((Nx,Ny,Nz),dtype=np.bool)
    for i in range(Ne):
        #tmpmask = (data[:,:,:,i,:] >10).prod(axis=-1,dtype=np.bool)
        tmpmask = (data[:,:,:,i,:] != 0).prod(axis=-1,dtype=np.bool)
    mask    = mask & tmpmask
    return mask

# === FUNCTION: niiwrite_nv
def niiwrite_nv(data,mask,temp_path,aff,temp_header):
        """
        This function will write NIFTI datasets

        Parameters:
        ----------
        data: this is (Nv, Nt) or (Nv,) array. No z-cat ME datasets allowed.
        mask: this is (Nx,Ny,Nz) array with Nv entries equal to True. This is an intracranial voxel mask.
        temp_path: this is the output directory.
        aff: affine transformation associated with this dataset.
        temp_header: header for the dataset.  
        
        Returns:
        --------
        None.
        """
        Nx,Ny,Nz   = mask.shape
        if (data.ndim ==1):
                temp       = np.zeros((Nx,Ny,Nz),order='F')
                temp[mask] = data
        if (data.ndim ==2):
                        _,Nt = data.shape
                        temp         = np.zeros((Nx,Ny,Nz,Nt),order='F')
                        temp[mask,:] = data
        if (data.ndim ==3):
                        Nv, Ne, Nt   = data.shape
                        temp         = np.zeros((Nx,Ny,Nz,Nt),order='F')
                        temp[mask,:] = np.squeeze(data[:,0,:])
                        for e in range(1,Ne):
                                aux       = np.zeros((Nx,Ny,Nz,Nt),order='F')
                                aux[mask,:] = np.squeeze(data[:,e,:])
                                temp = np.concatenate((temp,aux),axis=2)

        outni      = nib.Nifti1Image(temp,aff,header=temp_header)
        outni.to_filename(temp_path)
        print(" +              Dataset %s written to disk" % (temp_path))


def make_optcom(data,t2s,tes):
    """
    Generates the optimally combined time series. 

    Parameters:
    -----------
    data: this is the original ME dataset with the mean in a (Nv,Ne,Nt) array.
    t2s:  this is the static T2s map in a (Nv,) array.
    tes:  echo times in a (Ne,) array.

    Returns:
    --------
    octs: optimally combined time series in a (Nv,Nt) array.    
    """
    Nv,Ne,Nt = data.shape
    ft2s  = t2s[:,np.newaxis]
    alpha = tes * np.exp(-tes /ft2s)
    alpha = np.tile(alpha[:,:,np.newaxis],(1,1,Nt))
    octs  = np.average(data,axis = 1,weights=alpha)
    return octs

# === FUNCTION: getMeanByPolyFit	
def getMeanByPolyFit(data,Ncpus,polort=4):
   """ 
   This function computes the mean across time for all voxels and echoes using
   legendre polynomial fitting. More robust against slow dirfts

   Parameters
   ----------
   data:   ME dataset (Nv,Ne,Nt)
   polort: order for the legendre polynomials to fit.
   Returns
   -------
   mean:   (Nv,Ne)
   """
   Nv,Ne,Nt = data.shape
   aux = np.reshape(data.copy(),(Nv*Ne,Nt))
   drift = np.zeros((Nt,polort))
   x     = np.linspace(-1,1-2/Nt,Nt)
   for n in range(polort):
      drift[:,n]=np.polyval(legendre(n),x)
   # 2. Fit polynomials to residuals
   linRegObj= LinearRegression(normalize=False,fit_intercept=False, n_jobs=Ncpus)
   linRegObj.fit(drift,aux.T)
   mean    = np.reshape(linRegObj.coef_[:,0],(Nv,Ne))
   return mean

# === FUNCTION: computeQA
def computeQA(data,tes,Ncpus,data_mean=None,S0=None):
    """
    Simple function to compute the amount of variance in the data that is explained by
    the ME fit
    
    Parameters:
    -----------
    data: ME dataset (Nv,Ne,Nt)
    tes:  Echo times used during acquisition
    Ncpus: number of CPUs for parallelization across voxels
    data_mean: mean across time of the input data.
    Returns:
    --------
    SSE:  Voxelwise mean across time of the Sum of Squared Errors for the TE fit. (Nv,)  
    rankSSE: ranked version from 0 to 100 of SSE (good for kappa computation)     (Nv,)
    """
    Nv,Ne,Nt        = data.shape
    if data_mean is None:
       data_mean = getMeanByPolyFit(data,Ncpus,polort=4)
    data_demean            = data - data_mean[:,:,np.newaxis]
    dkappa, drho,residual,rcond,data_hat = linearFit(data,tes,Ncpus,data_mean)
    data_hat_mean                        = getMeanByPolyFit(data_hat,Ncpus,polort=4)
    data_demean_hat                      = data_hat - data_hat_mean[:,:,np.newaxis]

    SSE             = ((data_demean - data_demean_hat)**2).sum(axis=-1).max(axis=-1)
    rankSSE         = 100.*rankdata(1./SSE)/Nv
    
    Npoly = np.int(10)
    print("++ INFO: Generating legendre polynomials of order [%i]." % Npoly)
    x = np.linspace(-1,1-2/Nt,Nt)
    drift = np.zeros((Nt, Npoly))
    for n in range(Npoly):
        drift[:,n] = np.polyval(legendre(n),x)
    # 2. Fit polynomials to residuals
    linRegObj        = LinearRegression(normalize=False,fit_intercept=True, n_jobs=Ncpus)
    linRegObj.fit(drift,residual.T)
    fit2residual      = np.transpose(linRegObj.predict(drift))
    fit2residual_std  = fit2residual.std(axis=1)
    if S0 is None:
       fit2residual_norm = ( fit2residual ) / fit2residual.mean(axis=1)[:,np.newaxis]
       meqa_norm         = fit2residual_norm.std(axis=1)
    else:
       norm_residual = 100*(fit2residual)/S0[:,np.newaxis]
       meqa_norm     = norm_residual.std(axis=1)
    return SSE,rankSSE,residual,fit2residual,fit2residual_std,meqa_norm

# === FUNCTION: make_static_maps
def make_static_maps(S,tes):
   """
   This function will compute the static T2S and S0 maps. These are required
   for the computation of kappa and rho
   
   Parameters:
   -----------
   S: ME masked dataset in np.array(Nv,Ne,Nt)
   tes:  Echo times in np.array (Ne,)

   Returns:
   --------
   S0mean: S0 static map in np.array(Nv,)
   T2Smean: T2S map in np.array(Nv,)
   GoodVoxels: Mask with voxels that did not need correction

   """
   Nv,Ne,Nt = S.shape
   # 1. Create B matrix
   B = np.reshape(np.abs(S), (Nv,Ne*Nt)).transpose()
   B_iszero        = (B==0)
   B_zerosPerVoxel = np.reshape(sum(B_iszero),(Nv,1))
   GoodVoxels       = sum(B_zerosPerVoxel.transpose()==0)
   B[B==0] = 0.000000001
   B = np.log(B)
   # 2. Create the A matrix
   a = np.array([np.ones(Ne),-tes])
   A = np.tile(a,(1,Nt))
   A = np.sort(A)[:,::-1].transpose()
   # 5. Solve the system
   X,res,rank,sing = np.linalg.lstsq(A,B)
   # 6. Extract results
   S0mean  = np.exp(X[0,:]).transpose()
   T2Smean = 1.0/X[1,:].transpose()
   GoodVoxels[T2Smean>500] = 0
   GoodVoxels[T2Smean<-500] = 0
   T2Smean[T2Smean>500] = 500
   T2Smean[T2Smean<-500] = -500
   return S0mean, T2Smean, GoodVoxels

# === FUNCTION: make_static_maps_opt
def objective(x,Sv,aux_tes):
    return np.sqrt(sum((Sv-(x[0]*np.exp(-aux_tes/x[1])))*(Sv-(x[0]*np.exp(-aux_tes/x[1])))))

def make_static_opt_perVoxel(item):
   data_mean = item['data_mean']
   tes       = item['tes']
   So_init   = item['So_init']
   T2s_init  = item['T2s_init']
   So_min    = item['So_min']
   So_max    = item['So_max']
   T2s_min   = item['T2s_min']
   T2s_max   = item['T2s_max']
   Optimizer = item['Optimizer']
   result      = opt.minimize(objective, [So_init,T2s_init],args=(data_mean,tes), method=Optimizer,bounds=((So_min, So_max), (T2s_min, T2s_max)))
   v_fiterror  = result.fun
   v_S0        = result.x[0]
   v_t2s       = result.x[1]
   if (~result.success) or (v_t2s >= T2s_max-.05) or (v_t2s <= T2s_min+.05) or (v_S0 >= So_max-.05) or (v_S0 <= So_min+.05): 
     v_badFit  = 1
   else:
     v_badFit  = 0
   return {'v_S0':v_S0, 'v_t2s':v_t2s, 'v_fiterror':v_fiterror, 'v_badFit':v_badFit}

def make_static_maps_opt(data_mean,tes,Ncpus,So_init=2500,T2s_init=40,So_min=100,So_max=10000,T2s_min=10, T2s_max=300,Optimizer='SLSQP'):
   """
   This function computes static maps of S0 and T2s using scipy optimization

   Parameters:
   -----------
   data_mean: Mean across time of the ME dataset (Nv,Ne)
   tes:       Echo times used to acquire the data
   So_init:   Initial Guess for the S0 value.  Default=2500
   T2s_init:  Initial Guess for the T2s value. Default=40ms
   So_min:    Lowest admissible S0 value.      Default=100
   So_max:    Highest admissible S0 value.     Default=10000
   T2s_min:   Lowest admissible T2s value.     Default=10ms
   T2s_max:   Highest admissible T2s value.    Default=300ms
   Optimizer: Optimization Algorithm.          Default=SLSQP
   Returns:
   --------
   S0:        Static S0 map  (Nv,)
   t2s:       Static T2s map (Nv,)
   SSE:       Sum of Squared Errors (Nv,)
   BadFits:   Voxels marked as bad fits by the optimizer (Nv,)
   """
   print(" + INFO [make_static_maps_opt]: Initial conditions [So=%i, T2s=%i]" % (So_init, T2s_init))
   print(" + INFO [make_static_maps_opt]: Bounds So=[%i,%i] & T2s=[%i,%i]" % (So_min, So_max, T2s_min, T2s_max))
   print(" + INFO [make_static_maps_opt]: Optimizer = %s" % Optimizer)
   
   Nv,Ne    = data_mean.shape
   S0       = np.zeros(Nv,)
   t2s      = np.zeros(Nv,)
   badFits  = np.zeros(Nv,)
   fiterror = np.zeros(Nv,)

   print(" +              Multi-process Static Map Fit -> Ncpus = %d" % Ncpus)
   pool   = Pool(processes=Ncpus)
   result = pool.map(make_static_opt_perVoxel, [{'data_mean':data_mean[v,:],'tes':tes,'So_init':So_init,'So_max':So_max,'So_min':So_min,'T2s_init':T2s_init,'T2s_max':T2s_max,'T2s_min':T2s_min,'Optimizer':Optimizer} for v in np.arange(Nv)]) 
   for v in np.arange(Nv):
     S0[v]  = result[v]['v_S0']
     t2s[v] = result[v]['v_t2s']
     fiterror[v] = result[v]['v_fiterror']
     badFits[v]  = result[v]['v_badFit']
   print(" + INFO [make_static_maps_opt]: Number of Voxels with errors: %i" % badFits.sum())
   return S0, t2s, fiterror, badFits

# =================================================================================================================
# =================================             MAIN PROGRAM                =======================================
# =================================================================================================================

if __name__=='__main__':
    print("------------------------------------")
    print("-- SFIM ME-RT version %s         --" % __version__)
    print("------------------------------------")
    dep_check()
    import numpy              as np
    import nibabel            as nib
    import scipy.optimize     as opt
    from argparse             import ArgumentParser,RawTextHelpFormatter
    from multiprocessing      import cpu_count,Pool
    from scipy.special        import legendre
    from sklearn.linear_model import LinearRegression
    from scipy.stats          import rankdata,scoreatpercentile
    
    # =================================================================================================================
    # =================================         PARSING OF INPUT PARAMETERS     =======================================
    # =================================================================================================================
    parser = ArgumentParser(description=help_desc,formatter_class=RawTextHelpFormatter)
    statFitGrp = parser.add_argument_group('Arguments for static T2* and S0 fits')
    parser.add_argument("-d","--orig_data",        dest='data_file',      help="Spatially concatenated Multi-Echo Dataset",type=str,   default=None)
    parser.add_argument(     "--t2s",              dest='t2s_file',       help="Static T2* Map Dataset"                   ,type=str,   default=None)
    parser.add_argument("-e","--TEs",              dest='tes',            help="Echo times (in ms) ex: 15,39,63",          type=str,   default=None)
    parser.add_argument(     "--tes_file",         dest='tes_file',       help="Path to file with Echo time information",  type=str,   default=None)
    parser.add_argument(     "--out_dir",          dest='out_dir',        help="Output Directory. Default: current directory",type=str,default='./')
    parser.add_argument(     "--prefix",           dest='prefix',         help="Output File Prefix. Default = sbj",type=str,default='sbj')
    parser.add_argument(     "--mask",             dest='mask_file',      help='Path to the mask to use during the analysis. If not provided, one will be computed automatically',type=str, default=None)
    options  = parser.parse_args()
    
    # Control all necessary inputs are available
    # ------------------------------------------
    if options.tes is None and options.tes_file is None:
        print("++ Error: No information about echo times provided. Please do so via --TEs or --tes_file")
        sys.exit()
    if (not (options.tes is None)) and (not (options.tes_file is None)):
        print("++ Error: Echo times provided in two different ways (--TEs and --tes_file). Please select only one input mode.")
        sys.exit()
    if options.data_file is None:
        print("++ Error: No ME input dataset provided. Please provide one using the -d or --orig_data parameter.")
        sys.exit()
    if options.t2s_file is None:
        print("++ Error: No T2* map dataset provided. Please provide one using the --t2s parameter.")
        sys.exit()
    if options.mask_file is None:
        print("++ Error: No mask dataset provided. Please provide one using the --mask parameter.")
        sys.exit()
    
    # Control for existence of files and directories
    # ----------------------------------------------
    if not os.path.exists(options.data_file):
        print("++ Error: Datafile [%s] does not exists." % options.data_file)
        sys.exit()
    if not os.path.exists(options.t2s_file):
        print("++ Error: T2* Map [%s] does not exists." % options.t2s_file)
        sys.exit()
    if options.tes_file!=None and (not os.path.exists(options.tes_file)):
        print("++ Error: Echo Times file [%s] does not exists." % options.tes_file)
        sys.exit()
    if (not os.path.exists(options.out_dir)) or (not os.path.isdir(options.out_dir)):
        print("++ Error: Output directory [%s] does not exists." % options.out_dir)
        sys.exit()
    if not os.path.exists(options.data_file):
        print("++ Error: Provided mask [%s] does not exists." % options.mask_file)
        sys.exit()
    
    # Set all output paths
    # --------------------
    outputDir = os.path.abspath(options.out_dir)
    
    # =================================================================================================================
    # =================================         LOADING DATA INTO MEMORY        =======================================
    # =================================================================================================================
    
    # Load echo times information
    # ---------------------------
    if options.tes!=None:
        print("++ INFO [Main]: Reading echo times from input parameters.")
        tes      = np.fromstring(options.tes,sep=',',dtype=np.float64)
    if options.tes_file!=None:
        print("++ INFO [Main]: Reading echo times from input echo time file.")
        tes         = np.loadtxt(options.tes_file,delimiter=',')
    Ne = tes.shape[0]
    print(" +              Echo times: %s" % (str(tes)))
    
    # Load ME-EPI data
    # ----------------
    print("++ INFO [Main]: Loading ME dataset....")
    mepi_data,mepi_aff,mepi_head  = niiLoad(options.data_file)
    Nx,Ny,Nz,Nt                   = mepi_data.shape
    Nz                            = Nz/Ne # Because the input was the Z-concatenated dataset
    mepi_data                     = mepi_data.reshape((Nx,Ny,Nz,Ne,Nt),order='F')
    print(" +              Dataset dimensions: [Nx=%i,Ny=%i,Nz=%i,Ne=%i,Nt=%i]" % (Nx,Ny,Nz,Ne,Nt))
   
    # =================================================================================================================
    # =================================       LOAD PRE-COMPUTED T2* MAP          ======================================
    # =================================================================================================================
    print("++ INFO [Main]: Loading Pre-computed T2* map...")     
    t2s_data, t2s_aff, t2s_head = niiLoad(options.t2s_file)
    t2s_Nx, t2s_Ny, t2s_Nz      = t2s_data.shape
    print(" +              Dataset dimensions: [Nx=%i,Ny=%i,Nz=%i]" % (t2s_Nx, t2s_Ny, t2s_Nz))
    
    # =================================================================================================================
    # =================================        ORIGINAL MASK / RESHAPE          =======================================
    # =================================================================================================================
    print("++ INFO [Main]: Loading user-provided mask.")
    mask,_,_       = niiLoad(options.mask_file)
    mask = (mask>0)
    Nv             = np.sum(mask)
   
    # Put the data into a 3Dx format (Nvoxels, Nechoes, Ndatapoints)
    SME = mepi_data[mask,:,:].astype(float) #(Nv,Ne,Nt)
    t2s = t2s_data[mask].astype(float) #(Nv,)
    print("++ INFO [Main]: Working on SME[%s]" % str(SME.shape))  
    print("++ INFO [Main]: Working on t2s[%s]" % str(t2s.shape))  
    # =================================================================================================================
    # =================================        COMPUTE OPTIMALLY COMBINED       =======================================
    # =================================================================================================================
    print("++ Info [Main]: Compute Optimally Combined Time series.")
    octs = make_optcom(SME,t2s,tes)
    OCTS_path  = os.path.join(outputDir,options.prefix+'.OCTS.nii')
    niiwrite_nv(octs ,mask,OCTS_path, mepi_aff ,mepi_head)
