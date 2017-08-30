#!/usr/bin/env python
__version__="0.1"
import sys
import os
help_desc="""
This program generates static T2* and S0 maps from multi-echo data. It can do this in two different ways:

  * Log-linear fit: much faster, but more prone to errors
  * Non-linear Optimization: much slower, but potentially more accurate. Plus it can identify voxels with problematic 
    decay

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

   * Procedure:  By default the program will use the log-linear approach. To instruct the program to use the more computationally
                 demanding non-linear approach, the following parameter must be given: --non-linear

Additional information the program can take as inputs include:

   * Intra-cranial mask: provided with the --mask option followed by the name of the mask dataset. The mask must have Nx,Ny,Nz
                dimensions. If no mask is provided, the program will attempt its automatic computation.

   * Prefix: provided with the option --prefix PREFIX. All outputs will start with this prefix. If not provided, the default
                prefix is sbj

   * Output Directory: provided with the option --out_dir DIR. All files will be written to this location. If not provided,
                files will be written to the current directory.

   * Debug: if --debug is provided, additional files will be written to disk.

Additional parameters specific to the Non-Linear Optimization:

   In addition, this program can also be used to generate static T2* and S0 maps using a non-linear optimizer. To request
   the computation of such maps you must use the --get_static_maps option. Other parameters associated with this particular
   procdure are:
      --non_linear:Instructs the program to use this advanced method when computing the maps
      --So_init:   Initial Guess for the S0 value.  Default=2500
      --T2s_init:  Initial Guess for the T2s value. Default=40ms
      --So_min:    Lowest admissible S0 value.      Default=100
      --So_max:    Highest admissible S0 value.     Default=10000
      --T2s_min:   Lowest admissible T2s value.     Default=10ms
      --T2s_max:   Highest admissible T2s value.    Default=300ms  
  If none of these are provided, the software will use the default values. 

Sample Usage Lines:
-------------------

  $ python me_get_staticT2star.py --tes_file Echoes.1D -d SBJ_ZcatEchoes.nii --prefix SBJ_RESULT --mask SBJ_mask.nii
  $ python me_get_staticT2star.py --tes_file 14,26,44,68 -d SBJ_ZcatEchoes.nii --prefix SBJ_RESULT --mask SBJ_mask.nii
  $ python me_get_staticT2star.py --non_linear --tes_file 14,26,44,68 -d SBJ_ZcatEchoes.nii --prefix SBJ_RESULT --mask SBJ_mask.nii
  $ python me_get_staticT2star.py --non_linear --tes_file 14,26,44,68 -d SBJ_ZcatEchoes.nii 

Program Outputs:
----------------
    
    * <prefix>.sTE.t2s.nii: Voxel-wise static T2* map.
    * <prefix>.sTE.S0.nii:  Voxel-wise static So map.
    * <prefix>.SME.nii:     Average decay curves per voxel. 
    * <prefix>.sTE.SSE.nii: Voxel-wise Squared Standard Errors associated with the non-linear static fit.
    * <prefix>.sTE.mask.nii:Mask with voxels for which the non-linear optimizer was able to find values for t2s and So within
      the provided ranges. I usually find a few bad voxels in the ventricles and CSF around the brain. Other than that, the 
      mask should contain the whole intracranial volume. (1=good voxels | 0=bad voxels).
    
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
    parser.add_argument("-e","--TEs",              dest='tes',            help="Echo times (in ms) ex: 15,39,63",          type=str,   default=None)
    parser.add_argument(     "--tes_file",         dest='tes_file',       help="Path to file with Echo time information",  type=str,   default=None)
    parser.add_argument(     "--out_dir",          dest='out_dir',        help="Output Directory. Default: current directory",type=str,default='./')
    parser.add_argument(     "--prefix",           dest='prefix',         help="Output File Prefix. Default = sbj",type=str,default='sbj')
    parser.add_argument(     "--ncpus",            dest='Ncpus',          help='Number of cpus available. Default will be #available/2', default=None, type=int)
    parser.add_argument(     "--mask",             dest='mask_file',      help='Path to the mask to use during the analysis. If not provided, one will be computed automatically',type=str, default=None)
    parser.add_argument(     "--debug",            dest='debug',          help='Flag to write out additional files',action='store_true')
    
    statFitGrp.add_argument("--non_linear", dest='non_linear', help='Use this flag to attempt non linear fit method', action='store_true', default=False)
    statFitGrp.add_argument("--So_init"   , dest='So_init'   , help='Initial Guess for the S0 value.  Default=2500', type=float, default=2500)
    statFitGrp.add_argument("--T2s_init"  , dest='T2s_init'  , help='Initial Guess for the T2s value. Default=40ms', type=float, default=40)
    statFitGrp.add_argument("--So_min"    , dest='So_min'    , help='Lowest admissible S0 value.      Default=100', type=float,  default=100)
    statFitGrp.add_argument("--So_max"    , dest='So_max'    , help='Highest admissible S0 value.     Default=10000', type=float,default=10000)
    statFitGrp.add_argument("--T2s_min"   , dest='T2s_min'   , help='Lowest admissible T2s value.     Default=10ms', type=float, default=10)
    statFitGrp.add_argument("--T2s_max"   , dest='T2s_max'   , help='Highest admissible T2s value.    Default=300ms', type=float,default=300)
    options  = parser.parse_args()
    So_init  = float(options.So_init)
    So_min   = float(options.So_min)
    So_max   = float(options.So_max)
    T2s_init = float(options.T2s_init)
    T2s_min  = float(options.T2s_min)
    T2s_max  = float(options.T2s_max)
    
    # If no number of CPUs is provided, we will use half the available number of CPUs or 1 if only 1 is available
    if cpu_count()==1:
        Ncpus = 1;
    else:
        if (options.Ncpus is None) or (options.Ncpus > cpu_count()):
            Ncpus = int(cpu_count()/2)
        else:
            Ncpus = int(options.Ncpus) 
    print("++ INFO [Main]: Number of CPUs to use: %d" % (Ncpus))
    
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
    
    # Control for existence of files and directories
    # ----------------------------------------------
    if not os.path.exists(options.data_file):
        print("++ Error: Datafile [%s] does not exists." % options.data_file)
        sys.exit()
    if options.tes_file!=None and (not os.path.exists(options.tes_file)):
        print("++ Error: Echo Times file [%s] does not exists." % options.tes_file)
        sys.exit()
    if (not os.path.exists(options.out_dir)) or (not os.path.isdir(options.out_dir)):
        print("++ Error: Output directory [%s] does not exists." % options.out_dir)
    
    # Print info about the type of fit approach selected
    # --------------------------------------------------
    if options.non_linear:
       print("++ INFO [Main]: Use Non-Linear fit approach.");
    else:
       print("++ INFO [Main]: Use Linear fit approach.");

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
    # =================================        ORIGINAL MASK / RESHAPE          =======================================
    # =================================================================================================================
    origMask_path   = os.path.join(outputDir,options.prefix+'.mask.orig.nii')     
    if options.mask_file==None:
        print("++ INFO [Main]: Generating initial mask from data.")
        mask           = mask4MEdata(mepi_data)
        if options.debug:
            niiwrite_nv(mask[mask],mask,options.out_dir+options.prefix+'.mask.orig.nii',mepi_aff ,mepi_head)
    else:
        print("++ INFO [Main]: Using user-provided mask.")
        if not os.path.exists(options.data_file):
            print("++ Error: Provided mask [%s] does not exists." % options.mask_file)
            sys.exit()
        mask,_,_       = niiLoad(options.mask_file)
        mask = (mask>0)
        
    Nv             = np.sum(mask)
    print(" +              Number of Voxels in mask [Nv=%i]" % Nv)
    print(" +              Size of Mask[%s] - Type = %s" % (str(mask.shape),str(mask.dtype)))
    # Put the data into a 3Dx format (Nvoxels, Nechoes, Ndatapoints)
    SME      = mepi_data[mask,:,:].astype(float) #(Nv,Ne,Nt)
    
    # =================================================================================================================
    # =================================        COMPUTE MEAN ACROSS TIME         =======================================
    # =================================================================================================================
    print("++ INFO [Main]: Computing Mean across time for all echoes....")
    # There are two options here:
    #   (1) Simply use the mean command.
    #       Smean_case01 = SME.mean(axis=-1)
    #   (2) Compute the mean at the same time you fit some legendre polynomials, to remove the influence
    #   of small drits in the computation. It should make almost no difference.
    Smean_case02 = getMeanByPolyFit(SME,Ncpus,polort=4)
    SME_mean     = Smean_case02
    SME_mean_path  = os.path.join(outputDir,options.prefix+'.SME.nii')
    niiwrite_nv(SME_mean,mask,SME_mean_path, mepi_aff ,mepi_head)   
 
    # =================================================================================================================
    # =================================                STATIC FIT               =======================================
    # =================================================================================================================
    stFit_S0_path  = os.path.join(outputDir,options.prefix+'.sTE.S0.nii')
    stFit_t2s_path = os.path.join(outputDir,options.prefix+'.sTE.t2s.nii')
    stFit_bVx_path = os.path.join(outputDir,options.prefix+'.sTE.mask.nii')
    if options.non_linear:
        print "++ INFO [Main]: Comuting Static T2* and S0 maps via non-linear optimization..."
        stFit_SSE_path = os.path.join(outputDir,options.prefix+'.sTE.SSE.nii')
        mask_bad_staticFit = np.zeros((Nv,), dtype=bool)

        S0, t2s, SSE, mask_bad_staticFit = make_static_maps_opt(SME_mean,tes,Ncpus,So_init=So_init,T2s_init=T2s_init,So_min=So_min,So_max=So_max,T2s_min=T2s_min, T2s_max=T2s_max)

        mask_good_staticFit = np.logical_not(mask_bad_staticFit)
        niiwrite_nv(SSE               ,mask,stFit_SSE_path,mepi_aff ,mepi_head)
    else:
       print "++ INFO [Main]: Computing Static S0 and T2* maps via log-linear fit..."
       S0, t2s, mask_good_staticFit = make_static_maps(SME,tes)
    niiwrite_nv(S0                ,mask,stFit_S0_path, mepi_aff ,mepi_head)
    niiwrite_nv(t2s               ,mask,stFit_t2s_path,mepi_aff ,mepi_head)
    niiwrite_nv(mask_good_staticFit,mask,stFit_bVx_path,mepi_aff ,mepi_head)
