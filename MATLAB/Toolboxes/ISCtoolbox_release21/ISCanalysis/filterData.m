function filterData(Params,subjectNr,sessionNr)
% This function filters pre-processed fMRI data using stationary wavelet transform.
% Filtered data can be accessed using memory-pointer objects. Pointers can be loaded into
% Matlab workspace with using the command "load memMaps".
%
% inputs:
% Params - analysis parameters from initParams.m
% subjectNr - subject index
% sessionNr - session index


% Last modified 5.8.2013 by Juha Pajula
% Tampere University of Technology
% Department of Signal Processing
% e-mail: juha.pajula@tut.fi


numFilt = 4;
WaveletType = 'db';

%numFilt = 1;
%WaveletType = 'battle';

showTime(1);

Pub = Params.PublicParams;
Priv = Params.PrivateParams;

if ~Pub.calcStandard
    disp('Standard analysis not selected, filtering skipped...')
    return
end
if Pub.nrFreqBands == 0
    disp('No frequency subbands selected, filtering skipped...')
    return
end


% load memory maps:
load([Pub.dataDestination 'memMaps'])

    
[~,~,en] = computer;

mmapSource = memMaps.(Priv.origMapName).([Priv.prefixSession num2str(sessionNr)]).([...
    Priv.prefixSubject num2str(subjectNr)]);
mmapDest = memMaps.(Priv.filtMapName).([Priv.prefixSession num2str(sessionNr)]).([...
    Priv.prefixSubjectFilt num2str(subjectNr)]);
clear memMaps
FB = Priv.prefixFreqBand;
for xxz = 1:Pub.nrFreqBands
    if mmapDest.([FB num2str(xxz)]).Writable == false
        disp('Subband data written already, filtering canceled...')
        save([Pub.dataDestination '/tmp/rerun_' num2str(subjectNr)],'subjectNr')
        return
    end
end

levels = Priv.maxScale;
dsize = Priv.dataSize(sessionNr,:);
if strcmp(Pub.fileFormat,'nii')
    bmask = load_nii(Priv.brainMask);
    bmask = single(bmask.img);
elseif strcmp(Pub.fileFormat,'mat')
    bmask = load(Priv.brainMask);
    fiel = fields(bmask);
    bmask = bmask.(fiel{1});
    bmask = single(bmask);
else
    error('Mask must be mat- or nii-file!')
end
bmask = logical(bmask);

% obtain quadrature mirror filter pair for reconstruction:
h = loadFilterCoeffs(numFilt,WaveletType);
h = h/sum(h);
RecLow = sqrt(2)*h;
RecHigh = RecLow(end:-1:1);
RecHigh(2:2:end) = -RecHigh(2:2:end);
% time-reverse reconstruction filters to obtain decomposition filters:
DecHigh = RecHigh(end:-1:1);
DecLow = RecLow(end:-1:1);
DecHighOrig = DecHigh;
DecLowOrig = DecLow;

ts_x = zeros(size(mmapSource.Data(1).tyz(:,:,:)));
filt_x = zeros([size(mmapSource.Data(1).tyz(:,:,:)) levels+1]);

% DWT:
flag = 1;
for xx = 1:dsize(1)
    disp(['x: ' num2str(xx) '/'  num2str(dsize(1))])
    if sum(sum(squeeze(bmask(xx,:,:)))) > 0
        ts_x = mmapSource.Data(xx).tyz(:,:,:);
        if ~strcmp(Priv.computerInfo.endian,en)
            ts_x = swapbytes(ts_x);
        end
        for yy = 1:dsize(2)
            for zz = 1:dsize(3)
                if bmask(xx,yy,zz)
                    %  size(ts_x)
                    ts = ts_x(:,yy,zz);
                    ts = ts(:)';
                    N = length(ts);
                    Norig = N;
                    if flag
                        k = 1;
                        LL = 2^1;
                        while ( LL < N )
                            k = k + 1;
                            LL = 2^k;
                        end
                    end
                    DecHigh = DecHighOrig;
                    DecLow = DecLowOrig;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % SWT decomposition:
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    % symmetric signal extension:
                    if rem(Norig,2)
                        ts(N+1) = ts(N);
                        N = N+1;
                    end
                    if flag
                        startInds = N - floor((LL-N)/2) + 1:N;
                        endInds = 1:floor((LL-N)/2);
                        Inds = [startInds 1:N endInds]';
                        limits_orig_inds = [length(startInds)+1 length(startInds)+N];
                        if rem(Norig,2)
                            limits_orig_inds(2) = limits_orig_inds(2)-1;
                        end
                        flag = 1;
                    end
                    if N < floor((LL-N)/2)
                        inds = mod(Inds,N);
                        Inds(Inds==0) = N;
                    end
                    ts = ts(Inds);
                    N = length(ts);
                    
                    % Compute approximation and detail coeffs.
                    for k = 1:levels
                        L = length(DecLow);
                        
                        indLast = 2*ceil(N/2);
                        % periodic extension to avoid border distortions in filtering:
                        if rem(N,2)
                            ts(N+1) = ts(N);
                            N = N+1;
                        end
                        inds = [ N - (L/2) + 1:N , 1:N , 1:(L/2) ]';
                        if N < (L/2)
                            inds = mod(inds,N);
                            inds(inds==0) = N;
                        end
                        ts = ts(inds);
                        
                        % filtering:
                        d = conv2(ts(:),DecHigh(:),'full')';
                        a = conv2(ts(:),DecLow(:),'full')';
                        d = d((L+1):(L+N));
                        ts = a((L+1):(L+N));
                        filt_x(:,yy,zz,k) = d(...
                            limits_orig_inds(1):limits_orig_inds(2));
                        
                        % zero-pad filters:
                        DH = zeros(1,2*length(DecHigh));
                        DL = DH;
                        DH(1:2:end) = DecHigh;
                        DL(1:2:end) = DecLow;
                        DecHigh = DH;
                        DecLow = DL;
                        
                    end
                    
                    % add last coefficient:
                    filt_x(:,yy,zz,k+1) = ts(limits_orig_inds(1):limits_orig_inds(2));
                    % time-series check:
                    if ( xx == round(Priv.dataSize(1)/2) ) && ...
                            ( yy == round(Priv.dataSize(2)/2) ) && ...
                            ( zz == round(Priv.dataSize(3)/2) )
                        disp('Filtered time-series check:')
                        for rr = 1:levels+1
                            disp(['Coordinate (' num2str(xx) ',' num2str(yy) ',' num2str(zz) '), Band ' num2str(rr) ':'])
                            ttest = filt_x(1:6,round(Priv.dataSize(2)/2),round(Priv.dataSize(3)/2),rr)'
                            if max(max(max(max(filt_x)))) > 10^20
                                error('Unexpected value found!! Possible cause: processing distributed over multiple memory architectures.')
                            end
                        end
                    end
                    
                end
                
            end
        end
        % save data to disk:
        for k = 1:levels + 1
            fl = 1;
            while ( fl ~= 0 )
                try
                    mmapDest.([FB num2str(k)]).Data(xx).tyz(:,:,:) = ...
                        single( filt_x(:,:,:,k) );
                    fl = 0;
                catch err
                    disp(err.message)
                    fl = fl + 1;
                    if fl == 20
                        return
                    end
                end
            end
        end
    end
    
end
% Set files non-writable:
for m = 1:levels+1
    mmapDest.([FB num2str(m)]).Writable = false;
end


%to guarantee different random numbers in all distributed cases
%rng(str2num([num2str(subjectNr),num2str(sessionNr)]));


% add memmap object to memMaps -struct
%    load([Pub.dataDestination 'memMaps'])
%    memMaps.(Priv.filtMapName).([Priv.prefixSession num2str(sessionNr)]).([...
 %       Priv.prefixSubjectFilt num2str(subjectNr)]) = mmapDest;

    save([Pub.dataDestination '/tmp/' num2str(sessionNr) '_' num2str(subjectNr) '_memMaps'],'mmapDest')

showTime(0);



% load daubechies filter 1,2,3, or 4
function h = loadFilterCoeffs(numFilt,type)

switch type
    case 'db'
        switch numFilt
            case 1
                h = [0.50000000000000   0.50000000000000]';
            case 2
                h = [0.34150635094622   0.59150635094587   0.15849364905378  -0.09150635094587]';
                
            case 3
                h = [0.23523360389270   0.57055845791731   0.32518250026371  ...
                    -0.09546720778426 -0.06041610415535   0.02490874986589]';
                
            case 4
                h = [0.16290171402562   0.50547285754565   0.44610006912319  -0.01978751311791 ...
                    -0.13225358368437   0.02180815023739   0.02325180053556  -0.00749349466513]';
        end
        
    case 'battle'
        
        switch numFilt
            case 1
                g = [0.578163    0.280931   -0.0488618   -0.0367309 ...
                    0.012003    0.00706442 -0.00274588 -0.00155701 ...
                    0.000652922 0.000361781 -0.000158601 -0.0000867523
                    ];                
            case 3                
                g = [0.541736    0.30683    -0.035498    -0.0778079 ...
                    0.0226846   0.0297468     -0.0121455 -0.0127154 ...
                    0.00614143 0.00579932    -0.00307863 -0.00274529 ...
                    0.00154624 0.00133086 -0.000780468 -0.00065562 ...
                    0.000395946 0.000326749 -0.000201818 -0.000164264 ...
                    0.000103307
                    ];                
            case 5
                g = [0.528374    0.312869    -0.0261771   -0.0914068 ...
                    0.0208414    0.0433544 -0.0148537 -0.0229951  ...
                    0.00990635 0.0128754    -0.00639886 -0.00746848 ...
                    0.00407882 0.00444002 -0.00258816    -0.00268646 ...
                    0.00164132 0.00164659 -0.00104207 -0.00101912 ...
                    0.000662836 0.000635563 -0.000422485 -0.000398759 ...
                    0.000269842 0.000251419 -0.000172685 -0.000159168 ...
                    0.000110709 0.000101113
                    ];
        end
        l = length(g);
        h = zeros(1,2*l-1);
        h(l:2*l-1) = g;
        h(1:l-1) = fliplr(g(2:l));        
        h = h(:);
end
