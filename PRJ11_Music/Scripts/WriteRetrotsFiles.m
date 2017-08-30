function [Opt, R, E] = WriteRetrotsFiles(physioMatFile,nSlices,TR)

if ischar(physioMatFile)
    physio = ImportBiopacData(physioMatFile);
else
    physio = physioMatFile;
end
if ~exist('nSlices','var') || isempty(nSlices)
    nSlices = 34;
end
if ~exist('TR','var') || isempty(TR)
    TR = 2;
end
Fs = 1/(physio.time(2)-physio.time(1));

% Write .dat files
save('resp.dat',physio.resp.data,'-ascii');
save('cardio.dat',physio.pulseox.data,'-ascii');

% Set up RetroTS.m
Opt.Respfile = 'resp.dat';
Opt.Cardfile = 'cardio.dat';
Opt.PhysFS = Fs;
Opt.Nslices = nSlices;
Opt.VolTR = TR;

% Call RetroTS.m
[Opt, R, E] = RetroTS(Opt);

%  Opt is the options structure with the following fields
%     Mandatory:
%     ----------
%     Respfile: Respiration data file
%     Cardfile: Cardiac data file
%     PhysFS: Physioliogical signal sampling frequency in Hz.
%     Nslices: Number of slices
%     VolTR: Volume TR in seconds
%     Optional:
%     ---------
%     Prefix: Prefix of output file
%     SliceOffset: Vector of slice acquisition time offsets in seconds.
%                  (default is equivalent of alt+z)
%     RVTshifts: Vector of shifts in seconds of RVT signal. 
%                (default is [0:5:20])
%     RespCutoffFreq: Cut off frequency in Hz for respiratory lowpass filter
%                     (default 3 Hz)
%     CardCutoffFreq: Cut off frequency in Hz for cardiac lowpass filter
%                     (default 3 Hz)
%     ResamKernel: Resampling kernel. 
%                 (default is 'linear', see help interp1 for more options)
%     FIROrder: Order of FIR filter. (default is 40)
%     Quiet: [1]/0  flag. (defaut is 1) Show talkative progress as the program runs
%     Demo: [1]/0 flag. (default is 0)
%     RVT_out: [1]/0 flag for writing RVT regressors
%     Card_out: [1]/0 flag for writing Card regressors
%     Resp_out: [1]/0 flag for writing Resp regressors
%     SliceOrder: ['alt+z']/'alt-z'/'seq+z'/'seq-z'/'Custom'/filename.1D
%                 Slice timing information in seconds. The default is
%                 alt+z. See 3dTshift help for more info. 'Custom' allows
%                 the program to use the values stored in the
%                 Opt.SliceOffset array. If a value is placed into the
%                 SliceOrder field other than these, it is assumed to be
%                 the name of a 1D / text file containing the times for
%                 each slice (also in seconds).