% REX (Roi Extraction) Extracts values from the selected data files at the specified ROI(s).
%
% REX; Interactive parameter definition
%
% MEANS=REX(SOURCES, ROIS);
% where SOURCES is a list of M source volume files (image files to extract from)
% and ROIS is list of N roi files (image or .tal files)
% returns the mean values of each of the source volume files at the voxels
% identified by each ROI in the matrix MEANS (with size M x N).
%
% REX(SOURCES, ROIS, 'paramname1',paramvalue1,'paramname2',paramvalue2,...);
%   permits the specification of additional parameters:
%       'summary_measure' :     choice of summary measure (across voxels) [{'mean'},'eigenvariate','weighted mean','median','sum','weighted sum','count','max',min']
%       'level' :               summarize across [{'rois'},'clusters','peaks','voxels']
%       'scaling' :             type of scaling (for timeseries extraction) [{'none'},'global','roi']
%       'conjunction_mask':     filename of conjunction mask volume(s)
%       'output_type' :         choice of saving output ['none','save','savefiles',{'saverex'}]
%       'gui' :                 starts the gui [{0},1] 
%       'select_clusters'       asks user to select one or more clusters if multiple clusters exists within each ROI [{0},1]
%       'disregard_zeros'       when datatype has no NaN representation treat 0 as NaN [0,{1}]
%       'selected_clusters'     (for 'select_clusters'=0) indexes of clusters to select (by default this value is empty and all of the clusters will be selected) 
%       'dims' :                (for 'eigenvariate' summary measure only): number of eigenvariates to extract from the data
%       'covariates' :          (for 'eigenvariate' summary measure only): covariates to be regressed-out before computing svd
%       'pca' :                 (for 'eigenvariate' summary measure only): PCA decomposition 1 = first extract component represents mean signal, next components represent principal component decomposition of covariance matrix); 0 = components represent SVD decomposition of the second moment (X'*X) matrix [0,{1}] 
%       'mindist' :             (for 'peak' level only): minimum distance (mm) between peaks 
%       'maxpeak' :             (for 'peak' level only): maximum number of peaks per cluster
%       'fsanatomical' :        (for ROIs defined on freesurfer cortical surfaces): subject-specific freesurfer-generated mri/T1.nii structural file 
%       'output_files':         (for output_type 'save' or 'savefiles' only): cell array of files to create {'data.txt','data.mat','roi.tal','roi.img','roi#.img'}
%
% other command-line usages:
% rex open   : opens existing REX.mat file

% last modified, 2/7/02 Sue Whitfield
% last modified 07/09: Update to spm5/spm8b/spm8;
%                      Allows rois to be defined from roi image files (.nii,
%                       .img)
%                      Allows averaging over a subset of clusters (if the
%                       roi contains more than one connected set)
%                      Allows the specification of an additional
%                       conjunction mask (the intersection of this mask and
%                       each roi will be used as voxels to extract the
%                       average from)
%                      Incorporates additional summary measures (eigenvariate,
%                       weighted mean, median, and count)
%                      Incorporates scaling options (whole-brain and within-roi)
%                      Allows source files to be defined from a SPM.mat
%                       file (first-level or second-level analyses)
%                      Incorporate plots of contrast estimates,
%                       fitted&adjusted response, event-related response
%                       estimates, etc.
%                      Incorporate analysis options to perform ROI-based analyses 
%                       replicating SPM voxel-based analyses
%

% version 2.1 (06/2009)

function varargout=rex(ImgF, roi_path_array, varargin)

if nargin>=1 && ischar(ImgF) && (nargin==1 || (size(ImgF,1)==1 && any(strcmp(ImgF,{'open','display','results','plots','split','atlas'})))),
    switch(lower(ImgF)),
        case 'open', 
            if nargin>1, temp=roi_path_array;opts=varargin;
            else temp=spm_select(1,'REX.*\.mat$','Select REX.mat file');opts={};
            end
            load(deblank(temp),'params');params.output_folder=fileparts(temp);rex(params,'gui',1,'steps',[],opts{:});
        case 'display', 
            if nargin>1, temp=roi_path_array;
            else temp=spm_select(1,'REX.*\.mat$','Select REX.mat file');
            end
            load(deblank(temp),'params');params.output_folder=fileparts(temp);rex_display(params);
        case 'results', 
            if nargin>1, temp=roi_path_array;opts=varargin;
            else temp=spm_select(1,'REX.*\.mat$','Select REX.mat file');opts={};
            end
            load(deblank(temp),'params');params.output_folder=fileparts(temp);rex(params,'gui',0,'output_type','none','steps',{'results'},opts{:});
        case 'plots', 
            if nargin>1, temp=roi_path_array;opts=varargin;
            else temp=spm_select(1,'REX.*\.mat$','Select REX.mat file');opts={};
            end
            load(deblank(temp),'params');params.output_folder=fileparts(temp);rex(params,'gui',0,'output_type','none','steps',{'plots'},opts{:});
        case 'split',
            if nargin>1, temp=roi_path_array; opts=varargin;
            else temp=spm_select(1,'.*\.nii|.*\.img','Select image file'); opts={};
            end
            rex(temp,temp,'level','clusters','output_type','savefiles','output_files','roi#.img','select_clusters',0,'disregard_zeros',0,'steps',{'extract'},'gui',0,opts{:});
        case 'atlas',
            if nargin>1, temp=roi_path_array; opts=varargin;
            else temp=spm_select(1,'.*\.nii|.*\.img','Select image file'); opts={};
            end
            rex(temp,temp,'level','clusters','output_type','none','select_clusters',0,'steps',{'extract','display'},'gui',0,opts{:});
        otherwise,
            if ~isempty(dir(ImgF)),
                load(ImgF,'params');
                params.output_folder=fileparts(ImgF);
                varargout{1}=rex(params);
            end
    end
    return;
elseif nargin>0, % COMMAND-LINE OPTIONS
    fields={'sources','',...
        'rois','',...
        'conjunction_mask','',...           % conjunction mask volume file(s)
        'spm_file','',...                   % SPM.mat file
        'scaling','none',...                % ['none','global','roi']
        'summary_measure','mean',...        % [{'mean'},'eigenvariate','weighted mean','median','sum','weighted sum','count','max',min']
        'output_type','',...                % ['none','save','savefiles','saverex']
        'level','rois',...                  % ['rois','clusters','peaks','voxels']
        'dims',1,...                        % (for eigenvariate measure: number of dimensions to extract)
        'gui',[],...                        % use gui
        'mindist',20,...                    %
        'maxpeak',32,...                    %
        'roi_threshold',0,...               %
        'disregard_zeros',1,...             %
        'output_files',{'data.mat','data.txt','roi.tal','roi.img'},...               %
        'output_folder',pwd,...
        'output_rex','REX.mat',...
        'fsanatomical','',...
        'covariates',[],...                 %
        'pca',1,...                         %
        'select_clusters',0,...             % asks user to select one or more clusters if multiple clusters exists within each ROI
        'selected_clusters',[],...          % asks user to select one or more clusters if multiple clusters exists within each ROI
        'steps',[]};                        % cell array of additional steps to run after gui launches (rex_gui valid arguments, e.g. 'extract','results','plots','display')
    if isstruct(ImgF), % CONTINUES PREVIOUS SESSION
        params=ImgF;
        for n1=0:2:nargin-2, if ~n1, params=setfield(params,(roi_path_array),varargin{n1+1}); else, params=setfield(params,(varargin{n1}),varargin{n1+1}); end; end
        for n1=1:2:length(fields), if ~isfield(params,fields{n1}), params=setfield(params,fields{n1},fields{n1+1}); end; end
        if isempty(params.output_type),if nargout>0, params.output_type='none'; else, params.output_type='save'; end; end
        if isempty(params.gui),if nargout>0, params.gui=0; else, params.gui=1; end; end
    else,
        params=[]; for n1=1:2:nargin-2, params=setfield(params,lower(varargin{n1}),varargin{n1+1}); end
        for n1=1:2:length(fields), if ~isfield(params,fields{n1}), params=setfield(params,fields{n1},fields{n1+1}); end; end
        if isempty(params.output_type),if nargout>0, params.output_type='none'; else, params.output_type='save'; end; end
        if isempty(params.gui),if nargout>0, params.gui=0; else, params.gui=1; end; end
        params.sources=ImgF;
        params.rois=char(expandframe(roi_path_array));
    end
    if ~params.gui, % COMMAND-LINE 
        if ~isempty(params.spm_file)&&(~isfield(params,'SPM')||isempty(params.SPM)),
            params.SPM=load(params.spm_file);
        end
        if ~isfield(params,'VF') && ~isempty(params.sources),
            temp=params.sources;
            [nill,nill,ext]=fileparts(deblank(temp(1,:)));
            if size(temp,1)==1 && strcmp(ext,'.mat'),
                params.spm_file=deblank(temp);
                params.SPM=load(params.spm_file,'SPM');
                params.sources=strvcat(params.SPM.SPM.xY.VY(:).fname);
                try,
                    params.VF=params.SPM.SPM.xY.VY;
                    nill=spm_read_vols(params.VF(1));
                catch,
                    str=lasterror;%disp(['Warning: ',str.message]);
                    try,
                        params.VF=spm_vol(params.sources);
                    catch,
                        str=lasterror;%disp(['Warning: ',str.message]);
                        try,
                            temp=strvcat(data.params.SPM.SPM.xY.P{:});
                            data.params.VF=spm_vol(temp);
                            data.params.sources=temp;
                        catch,
                            str=lasterror;%disp(['Warning: ',str.message]);
                            cwd=pwd;[filepath,nill,nill]=fileparts(params.spm_file);if isempty(filepath),filepath='.';end;cd(filepath);
                            params.VF=rex_vol(params.sources,8);
                            cd(cwd);
                        end
                    end
                end
            else,
                %params.spm_file='';
                params.sources=temp;
                params.VF=spm_vol(temp);
            end
        end
        if ~isfield(params,'VM') && ~isempty(params.conjunction_mask),
            params.VM=spm_vol(params.conjunction_mask);
        end
        if ~isfield(params,'ROIdata')||isempty(params.ROIdata),
            [params.ROIdata,params.ROInames,params.ROIinfo.basis,params.ROIinfo.voxels,params.ROIinfo.files,params.ROIinfo.select,params.ROIinfo.trans]=rex_do(params,1);
        end
        data.params=params; for n1=1:length(params.steps), data=rex_gui([],[],params.steps{n1},data,0); end; params=data.params;
        if strcmpi(params.output_type,'save')||strcmpi(params.output_type,'saverex'), 
            save(fullfile(params.output_folder,params.output_rex),'params'); 
        end
        varargout={params.ROIdata,params.ROInames,params};
        return; 
    end
else
    if ~isempty(dir('REX.mat')),
        [answ]=questdlg('Continue from previous session?','','Yes','No (starts a new session)','Yes');
        if strcmp(answ,'Yes'),load('REX.mat');params.output_folder=pwd;rex(params,'gui',1,'steps',[]);return;end
    end
    % GUI INIT
    fields={'sources','',...
        'rois','',...
        'conjunction_mask','',...           % conjunction mask volume file
        'spm_file','',...                   % SPM.mat file
        'scaling','none',...                % ['none','global','roi']
        'summary_measure','mean',...        % [{'mean'},'eigenvariate','weighted mean','median','sum','weighted sum','count','max','min']
        'output_type','saverex',...         % ['none','save','savefiles','saverex']
        'level','rois',...                  % ['rois','clusters','peaks','voxels']
        'dims',1,...
        'gui',1,...
        'mindist',20,...                     
        'maxpeak',32,...                     
        'roi_threshold',0,...               %
        'disregard_zeros',1,...             %
        'output_files',{'data.mat','data.txt','roi.tal','roi.img'},...               %
        'output_folder',pwd,...
        'output_rex','REX.mat',...
        'fsanatomical','',...
        'covariates',[],...                 %
        'pca',1,...                         %
        'select_clusters',0,...
        'selected_clusters',[],...
        'steps',[]};
    params=[]; for n1=1:2:length(fields), if ~isfield(params,fields{n1}), params=setfield(params,fields{n1},fields{n1+1}); end; end
end

% GUI INITIALIZATION
try,spm('Defaults','fMRI');end
guistruct=struct('level',struct('gui',{{'ROI-level: Extracts one dataset separately for each ROI file','Cluster-level: Extracts one dataset separately for each connected / labeled area within each ROI file','Peak-level: Extracts one dataset separately for each local-maximum area within each ROI file','Voxel-level: Extracts one dataset separately for each voxel within each ROI file'}},...
    'values',{{'rois','clusters','peaks','voxels'}}),...
    'summary_measure',struct('gui',{{'Extract mean','Extract eigenvariate','Extract weighted-mean','Extract median','Extract sum','Extract weighted-sum','Extract positive-voxels count','Extract maximum','Extract minimum'}},...
    'values',{{'mean','eigenvariate','weighted mean','median','sum','weighted sum','count','max','min'}}),...
    'scaling',struct('gui',{{'No scaling','global scaling','within-roi scaling'}},...
    'values',{{'none','global','roi'}}),...
    'output_type',struct('gui',{{'Save REX project & output files','Save REX project only','Save output files only','No output files'}},...
    'values',{{'save','saverex','savefiles','none'}}));
handles(1)=figure('units','norm','position',[.2,.4,.2,.5],'name','REX','menubar','none','numbertitle','off','color','w');
handles(2)=uicontrol('units','norm','position',[.05,.900, .4,.075],'style','pushbutton','string','Sources','callback',{@rex_gui,'sources'});
handles(3)=uicontrol('units','norm','position',[.50,.900, .4,.050],'style','text','string','not selected','foregroundcolor','r','backgroundcolor','w');
handles(4)=uicontrol('units','norm','position',[.05,.800, .4,.075],'style','pushbutton','string','ROIs','callback',{@rex_gui,'rois'});
handles(5)=uicontrol('units','norm','position',[.50,.800, .4,.050],'style','text','string','not selected','foregroundcolor','r','backgroundcolor','w');
handles(6)=uicontrol('units','norm','position',[.05,.700, .9,.075],'style','popupmenu','string',strvcat(guistruct.level.gui{:}),'value',strmatch(lower(params.level),guistruct.level.values,'exact'),'callback',{@rex_gui,'level'});
handles(7)=uicontrol('units','norm','position',[.05,.550, .9,.075],'style','popupmenu','string',strvcat(guistruct.summary_measure.gui{:}),'value',strmatch(lower(params.summary_measure),guistruct.summary_measure.values,'exact'),'callback',{@rex_gui,'summary_measure'});
handles(8)=uicontrol('units','norm','position',[.05,.475, .9,.075],'style','popupmenu','string',strvcat(guistruct.scaling.gui{:}),'value',strmatch(lower(params.scaling),guistruct.scaling.values,'exact'),'callback',{@rex_gui,'scaling'});
handles(9)=uicontrol('units','norm','position',[.09,.01, .3,.075],'style','pushbutton','string','Extract','enable','off','callback',{@rex_gui,'extract'});
handles(10)=uicontrol('units','norm','position',[.69,.01, .3,.075],'style','pushbutton','string','plots','enable','off','callback',{@rex_gui,'plots'});
handles(11)=uicontrol('units','norm','position',[.05,.625, .9,.075],'style','popupmenu','string',strvcat('No conjunction mask','Use conjunction mask'),'value',1+~isempty(params.conjunction_mask),'callback',{@rex_gui,'conjunction'});
handles(12)=uicontrol('units','norm','position',[.39,.01, .3,.075],'style','pushbutton','string','Results','enable','off','callback',{@rex_gui,'results'});
handles(13)=uicontrol('units','norm','position',[.05,.400, .9,.075],'style','popupmenu','string',strvcat(guistruct.output_type.gui{:}),'value',strmatch(lower(params.output_type),guistruct.output_type.values,'exact'),'callback',{@rex_gui,'output_type'});
subplot(212);a=zeros(1,361);b=1+a;c=2+b;imagesc(reshape(...
    [c(1:361),b(1:9),c(1:90),1,1,2,b(1:12),c(1:31),1,c(1:54),b(1:4),0,2,b(1:9),c(1:33),1,c(1:52),b(1:14),2,2,b(1:5),c(1:79),1,2,1,a(1:4),1,1,2,1,0,1,1,1,2,2,1,1,0,1,0,0,1,1,c(1:25),0,c(1:50),1,1,1,0,c(1:5),1,1,0,1,2,2,1,0,1,2,b(1:8),c(1:75),1,2,2,1,c(1:4),b(1:4),0,1,0,2,1,0,1,2,0,b(1:4),0,0,1,1,c(1:71),1,1,1,c(1:6),1,2,1,1,1,0,1,1,1,2,1,1,2,1,c(1:6),1,0,c(1:22),0,c(1:47),1,1,2,0,2,1,2,1,2,2,b(1:4),0,0,b(1:4),2,2,1,0,0,1,a(1:4),1,0,1,c(1:21),1,c(1:47),1,1,2,2,2,1,c(1:4),b(1:9),2,1,2,1,a(1:6),1,1,1,0,0,1,c(1:19),1,c(1:46),1,1,1,0,2,2,2,1,2,2,2,b(1:13),0,2,1,0,1,c(1:7),1,1,0,1,c(1:16),1,c(1:45),1,1,1,2,2,b(1:4),2,b(1:6),2,1,0,1,1,1,0,1,1,0,0,1,1,0,c(1:6),1,0,b(1:6),0,0,c(1:9),1,c(1:45),1,1,1,0,1,c(1:4),b(1:8),0,b(1:4),2,0,1,1,0,0,0,1,0,0,c(1:6),1,1,0,0,0,1,1,0,1,1,c(1:8),1,c(1:44),b(1:4),c(1:6),b(1:5),0,0,b(1:9),2,0,1,0,1,1,1,0,0,1,0,0,1,a(1:5),1,1,0,0,1,1,0,c(1:51),b(1:5),...
        c(1:4),1,1,0,1,1,0,1,1,0,b(1:4),2,1,1,2,2,1,c(1:4),1,1,0,1,1,1,a(1:6),b(1:4),0,1,0,0,c(1:49),1,1,0,0,2,1,2,2,2,1,1,0,b(1:5),0,0,b(1:8),2,b(1:7),0,0,0,1,0,0,1,1,0,0,0,1,0,0,1,1,0,0,0,c(1:47),b(1:5),2,2,1,2,b(1:6),0,b(1:4),0,b(1:6),0,2,1,1,0,0,1,1,0,0,1,1,0,1,1,1,a(1:4),1,0,b(1:6),0,c(1:46),b(1:5),2,2,2,0,1,1,0,1,1,0,b(1:5),0,b(1:4),0,2,a(1:4),2,0,1,1,0,1,1,1,2,2,1,2,1,1,0,1,2,1,0,1,1,0,0,1,0,0,c(1:44),b(1:5),2,2,b(1:6),0,b(1:5),0,b(1:4),0,0,1,1,0,1,1,0,0,0,1,2,a(1:9),1,1,0,b(1:9),0,0,c(1:43),b(1:5),2,2,1,0,b(1:4),0,b(1:4),0,0,b(1:5),0,b(1:5),a(1:5),c(1:5),0,0,1,a(1:4),1,2,b(1:4),0,1,0,1,0,c(1:43),1,1,1,0,2,1,1,1,0,1,1,1,0,0,b(1:4),0,0,1,0,0,2,b(1:7),2,1,0,1,1,2,0,2,a(1:7),b(1:7),0,1,1,0,0,0,1,c(1:41),1,0,1,1,1,2,1,0,0,1,1,0,1,1,0,0,1,0,1,1,0,1,1,1,0,b(1:4),0,2,b(1:5),2,2,1,0,1,a(1:5),b(1:4),0,1,1,1,0,0,1,1,1,0,0,c(1:41),0,0,b(1:5),0,1,1,1,0,b(1:5),0,0,b(1:4),0,0,...
        b(1:4),2,0,1,a(1:6),1,1,1,0,1,1,0,0,b(1:5),2,1,1,0,0,1,1,1,0,1,0,c(1:39),1,0,0,b(1:6),0,0,1,0,1,1,0,0,0,1,0,0,1,1,0,1,0,1,1,2,1,0,2,2,0,0,0,2,0,1,1,0,0,0,1,1,a(1:4),b(1:6),0,b(1:6),0,c(1:39),b(1:11),2,b(1:4),0,0,0,b(1:8),0,0,1,2,2,1,1,2,2,b(1:8),0,2,1,1,0,1,1,2,1,0,1,0,0,1,1,1,0,1,0,c(1:39),0,1,1,0,1,1,0,1,1,0,1,1,0,b(1:8),2,0,2,0,b(1:11),0,0,b(1:5),a(1:4),1,0,0,1,0,1,0,1,0,1,1,1,0,1,1,0,c(1:39),0,1,1,1,0,1,1,0,1,0,1,0,0,0,b(1:5),0,b(1:7),0,0,b(1:6),0,1,2,1,2,1,0,1,0,0,1,0,0,0,1,1,2,1,1,1,0,1,1,1,0,1,1,0,c(1:38),1,0,1,1,0,1,1,0,b(1:4),a(1:6),b(1:4),0,0,0,1,1,0,b(1:5),2,0,b(1:4),0,0,1,a(1:5),1,0,1,1,1,2,1,1,0,1,1,1,0,1,1,1,0,1,c(1:37),0,1,1,1,0,1,1,0,0,1,1,1,0,1,0,0,1,0,1,1,0,0,1,1,1,0,0,b(1:4),0,1,1,a(1:5),2,2,0,1,a(1:7),1,1,2,1,1,a(1:4),1,1,0,1,0,c(1:37),0,0,1,1,1,0,b(1:4),0,b(1:5),a(1:4),b(1:4),0,0,b(1:4),2,2,1,1,2,0,0,1,2,2,2,a(1:4),1,1,0,1,0,1,1,1,2,1,1,0,0,...
        b(1:4),0,1,1,1,c(1:36),0,0,1,2,1,1,1,0,1,1,0,2,1,0,1,0,1,1,a(1:4),b(1:6),0,0,b(1:5),0,2,1,1,2,1,1,a(1:6),1,0,0,1,2,1,1,0,0,b(1:5),0,1,1,1,c(1:35),0,1,0,1,1,0,b(1:8),a(1:11),1,0,1,0,0,0,1,2,1,1,1,0,b(1:4),2,1,1,0,0,1,0,0,1,1,1,0,b(1:5),0,1,1,1,0,0,0,1,c(1:36),a(1:4),b(1:4),0,1,a(1:5),1,1,0,0,1,0,0,1,0,1,a(1:4),1,2,1,1,1,2,1,0,1,a(1:7),1,1,2,a(1:5),b(1:4),0,0,1,1,0,b(1:4),c(1:35),1,1,1,0,1,0,1,0,0,0,1,a(1:4),b(1:5),0,1,0,0,0,b(1:7),0,b(1:4),0,0,2,2,1,a(1:10),1,2,2,b(1:11),0,c(1:35),1,1,1,0,1,1,1,a(1:7),b(1:5),a(1:4),1,0,0,b(1:8),0,1,2,1,1,1,2,2,1,1,2,2,a(1:4),1,0,0,b(1:9),0,0,1,1,0,c(1:35),0,1,0,0,1,0,0,b(1:4),0,0,b(1:4),0,1,1,1,0,0,1,2,0,0,0,1,0,2,1,1,2,2,2,1,1,a(1:4),1,1,1,0,2,2,0,1,1,1,0,b(1:5),0,1,1,1,a(1:5),c(1:34),1,0,0,1,0,b(1:4),a(1:4),1,2,1,1,0,1,1,1,0,0,0,1,1,0,0,1,0,0,0,1,1,2,1,1,1,0,0,b(1:9),a(1:4),b(1:6),0,1,1,0,0,2,1,0,0,c(1:34),b(1:6),0,1,...
        a(1:4),b(1:6),2,2,0,0,1,0,1,2,b(1:9),2,1,1,a(1:5),1,2,1,0,1,2,1,1,1,2,b(1:6),0,1,1,1,0,2,1,1,0,c(1:34),1,0,0,0,1,0,0,1,0,0,b(1:5),c(1:5),1,a(1:5),1,1,0,b(1:7),0,0,c(1:6),1,0,1,0,0,0,1,0,b(1:6),0,1,1,1,0,b(1:4),0,c(1:34),0,1,0,1,1,0,0,b(1:4),0,1,1,2,2,1,1,1,2,1,1,1,a(1:7),1,0,1,0,0,1,1,0,1,2,2,1,1,c(1:5),0,0,2,b(1:8),0,1,0,b(1:4),0,0,c(1:33),0,0,0,1,0,1,1,0,1,0,b(1:7),2,1,2,2,1,0,1,a(1:8),b(1:5),a(1:6),1,2,1,0,0,1,a(1:5),1,2,1,1,1,0,1,1,1,0,1,2,2,1,1,c(1:33),0,0,1,1,0,1,0,1,0,0,0,1,1,1,0,1,1,c(1:4),a(1:5),1,1,0,0,1,1,0,b(1:4),a(1:7),1,1,1,0,1,2,1,1,2,0,1,1,2,b(1:6),0,b(1:5),c(1:32),1,0,1,0,1,0,1,0,1,1,1,0,0,1,1,0,1,2,1,1,0,0,0,1,a(1:5),1,1,0,b(1:4),2,1,a(1:4),1,1,a(1:5),1,1,a(1:4),b(1:10),2,b(1:4),c(1:32),0,0,0,1,1,1,0,1,1,1,a(1:7),1,a(1:6),1,a(1:4),b(1:6),2,2,2,1,c(1:9),1,1,0,0,0,1,1,2,2,b(1:6),0,b(1:5),0,c(1:31),1,0,1,0,1,1,1,0,b(1:6),a(1:5),1,a(1:5),1,0,1,...
        0,0,0,1,1,1,0,1,1,0,0,1,1,2,2,2,1,0,1,2,1,1,1,0,0,1,0,1,0,1,1,2,b(1:10),0,c(1:31),0,0,0,b(1:9),a(1:8),1,0,1,0,0,0,1,0,0,1,0,0,0,1,0,b(1:5),0,0,1,2,2,1,0,1,0,1,1,a(1:4),b(1:5),0,b(1:4),0,0,1,2,1,1,c(1:29),1,0,1,0,0,1,1,1,0,b(1:4),0,2,b(1:7),a(1:9),b(1:4),0,0,1,1,2,b(1:5),c(1:6),0,1,1,1,0,0,b(1:5),0,b(1:10),c(1:29),0,1,1,0,0,b(1:9),2,1,1,2,b(1:6),a(1:5),1,1,0,0,1,0,1,0,0,1,2,0,c(1:4),0,1,a(1:4),1,2,a(1:4),b(1:4),0,1,0,b(1:7),0,1,c(1:29),1,0,0,0,1,0,b(1:5),0,1,1,0,b(1:7),2,1,1,1,0,0,0,1,1,0,0,1,0,b(1:5),c(1:6),0,1,2,1,1,a(1:4),1,2,1,1,1,0,b(1:4),2,1,1,1,0,1,1,1,c(1:29),1,0,0,b(1:7),0,b(1:6),2,2,b(1:8),0,0,1,a(1:4),1,0,1,1,0,0,c(1:9),1,0,1,1,0,0,0,b(1:5),0,b(1:10),c(1:30),0,0,b(1:7),0,1,0,2,1,1,1,2,1,1,0,1,1,0,0,0,1,1,a(1:8),1,2,1,0,c(1:6),1,0,0,1,2,1,1,0,0,1,0,b(1:4),0,b(1:12),c(1:29),0,0,b(1:6),0,b(1:4),2,b(1:8),a(1:10),1,0,0,b(1:4),0,1,c(1:5),b(1:4),0,0,b(1:11),2,1,0,...
        b(1:7),c(1:28),0,1,1,1,0,b(1:4),0,2,1,1,1,2,1,2,2,1,2,1,1,1,a(1:6),1,0,0,0,1,0,0,1,a(1:5),c(1:8),1,0,0,2,0,0,2,b(1:5),2,b(1:11),c(1:28),a(1:4),b(1:13),2,b(1:4),0,1,a(1:9),1,0,0,1,1,a(1:4),1,1,2,2,a(1:5),1,0,0,0,b(1:15),0,1,1,1,c(1:28),0,1,0,b(1:5),0,1,1,c(1:4),1,2,2,b(1:4),0,0,0,1,a(1:5),1,2,b(1:5),c(1:9),0,0,1,2,0,0,b(1:8),2,1,1,2,2,1,2,2,2,b(1:4),c(1:27),1,0,0,1,1,0,1,0,0,1,2,1,c(1:4),1,2,b(1:5),a(1:4),1,0,0,0,b(1:7),0,0,1,c(1:4),0,1,a(1:7),b(1:21),c(1:28),0,0,1,0,0,1,0,0,1,2,2,2,b(1:4),2,b(1:5),a(1:6),2,0,1,1,1,0,0,0,1,1,1,0,c(1:7),0,0,b(1:9),0,b(1:9),2,1,1,0,1,1,c(1:27),0,1,1,1,0,b(1:4),2,2,1,2,1,1,1,2,2,b(1:4),a(1:4),1,0,1,1,0,1,1,2,0,1,0,0,c(1:8),a(1:6),b(1:10),2,b(1:8),0,0,2,1,c(1:26),0,1,1,1,0,0,1,0,1,2,1,2,1,1,2,1,2,2,1,1,2,1,0,0,1,1,0,0,1,1,1,0,2,b(1:6),c(1:8),a(1:5),b(1:20),0,0,1,1,c(1:26),0,1,1,1,0,b(1:4),2,2,2,b(1:5),2,1,1,1,2,1,2,1,0,1,0,1,1,0,0,...
        b(1:6),c(1:5),a(1:6),1,0,0,b(1:4),2,b(1:13),0,0,1,0,1,1,c(1:26),b(1:8),2,b(1:4),2,1,2,2,b(1:5),2,2,b(1:7),0,1,2,2,1,1,0,c(1:5),a(1:7),b(1:14),0,b(1:5),0,b(1:5),c(1:25),0,1,1,1,0,1,0,0,2,1,2,1,2,2,2,b(1:10),a(1:5),1,2,0,b(1:5),0,c(1:4),a(1:7),1,1,0,b(1:5),2,b(1:11),0,b(1:5),c(1:25),0,b(1:4),0,0,0,2,2,1,2,2,1,1,2,1,1,1,2,b(1:7),0,0,0,1,0,0,0,b(1:5),0,c(1:4),a(1:6),b(1:6),2,b(1:5),0,b(1:5),0,1,0,b(1:7),c(1:24),0,b(1:4),0,0,1,2,1,1,2,1,0,1,1,1,0,1,0,b(1:7),0,0,1,1,1,0,b(1:6),0,2,2,2,a(1:5),2,1,1,2,b(1:23),0,1,1,c(1:23),0,b(1:5),0,0,1,2,1,1,a(1:4),1,a(1:4),1,1,2,1,1,1,0,0,1,0,1,0,0,1,1,1,0,1,1,0,2,2,2,a(1:4),1,2,1,1,2,1,1,1,0,b(1:14),0,1,1,1,0,0,1,1,1,c(1:22),0,0,b(1:4),0,2,1,2,1,a(1:5),1,0,0,0,1,0,1,1,2,1,1,0,1,a(1:6),b(1:5),0,2,2,a(1:5),2,0,b(1:5),0,0,2,b(1:6),2,b(1:7),0,b(1:7),c(1:21),0,1,0,b(1:5),2,1,2,1,1,0,1,0,1,a(1:5),1,0,0,b(1:4),2,0,1,1,1,0,1,2,1,1,1,0,0,0,2,...
        a(1:5),2,0,1,1,1,2,1,0,0,b(1:4),2,b(1:14),0,1,1,1,c(1:21),b(1:4),0,1,1,0,0,0,1,1,1,0,0,0,1,1,0,1,a(1:5),b(1:4),0,0,1,1,2,b(1:7),0,1,2,a(1:4),1,2,b(1:4),0,b(1:4),0,b(1:17),0,1,2,1,c(1:20),0,1,1,1,0,0,1,a(1:4),1,1,0,0,0,1,1,0,1,1,1,2,0,1,0,1,1,1,0,1,2,1,2,0,0,1,1,1,0,0,2,0,2,a(1:5),b(1:8),0,1,0,b(1:22),c(1:19),0,1,1,0,1,a(1:5),1,a(1:9),1,1,0,b(1:5),0,1,a(1:4),1,0,0,1,1,0,0,1,1,1,a(1:6),b(1:18),2,2,b(1:13),c(1:18),0,0,0,1,1,2,1,0,1,0,1,0,1,1,a(1:4),1,0,0,0,b(1:4),0,1,a(1:9),b(1:5),2,2,1,a(1:4),1,0,b(1:4),0,b(1:7),0,b(1:4),2,1,1,1,0,b(1:5),2,1,1,1,0,1,c(1:18),0,0,0,1,1,1,0,0,0,1,0,1,1,a(1:8),b(1:5),0,1,0,1,0,0,1,a(1:4),b(1:5),2,a(1:8),b(1:15),0,1,1,1,2,b(1:5),2,b(1:7),c(1:17),0,0,b(1:7),0,0,1,1,0,0,1,1,0,1,a(1:4),1,a(1:6),1,1,a(1:7),b(1:5),a(1:7),b(1:20),2,1,1,1,0,b(1:9),c(1:17),0,1,0,b(1:7),0,1,1,0,1,0,1,0,0,1,0,0,0,1,1,0,0,0,1,0,1,0,0,1,0,0,0,b(1:5),a(1:9),...
        b(1:4),0,b(1:13),0,1,1,2,1,1,0,b(1:9),c(1:15),a(1:5),1,1,1,0,0,1,0,1,0,0,1,0,0,0,1,2,2,2,1,2,1,1,0,0,0,b(1:4),a(1:4),1,0,0,1,0,1,a(1:7),1,0,1,1,0,b(1:15),2,b(1:13),0,0,c(1:15),0,0,0,1,a(1:5),1,a(1:4),1,1,c(1:4),1,2,b(1:5),2,1,0,0,0,1,1,a(1:6),b(1:4),a(1:6),1,0,b(1:19),2,b(1:5),0,1,1,2,2,1,1,2,0,1,c(1:14),0,0,0,1,a(1:6),1,a(1:4),2,2,1,2,b(1:4),c(1:5),1,1,1,0,0,1,1,a(1:5),b(1:5),a(1:4),1,0,0,0,b(1:5),0,b(1:13),2,2,2,b(1:11),0,1,c(1:14),a(1:11),1,1,2,2,1,2,b(1:4),c(1:4),1,1,c(1:4),1,1,1,0,0,0,1,a(1:4),1,1,1,a(1:4),1,a(1:4),b(1:6),0,b(1:11),0,1,2,2,b(1:7),2,1,1,0,1,c(1:12),a(1:4),1,0,0,1,0,1,1,0,0,1,2,2,1,1,2,1,1,c(1:5),1,1,1,c(1:5),1,1,2,2,0,1,1,0,0,b(1:6),0,1,1,1,0,0,b(1:7),0,b(1:13),2,2,2,b(1:9),0,1,0,c(1:11),1,0,0,0,1,1,0,b(1:6),2,2,2,1,1,1,c(1:5),0,0,c(1:12),1,0,1,0,0,b(1:10),2,0,b(1:14),0,0,b(1:4),0,0,2,2,b(1:10),0,0,c(1:10),0,1,0,0,1,0,0,1,0,b(1:4),2,2,...
        1,1,2,1,c(1:4),1,1,0,1,c(1:5),1,c(1:5),0,0,0,1,0,1,1,1,0,1,1,0,b(1:5),0,b(1:6),2,b(1:7),0,0,1,0,b(1:5),2,1,0,b(1:7),0,1,1,c(1:9),1,1,0,0,0,1,0,1,1,1,0,0,b(1:4),2,2,2,1,2,2,b(1:4),0,1,2,2,2,1,1,c(1:4),1,a(1:4),1,1,0,1,1,0,b(1:7),0,b(1:15),0,1,1,0,1,1,0,0,0,2,1,1,0,b(1:8),c(1:11),a(1:5),b(1:4),0,0,1,1,c(1:7),1,2,1,1,0,1,c(1:4),1,1,2,2,1,0,0,1,a(1:4),b(1:5),0,b(1:5),0,0,b(1:21),0,b(1:5),0,1,1,2,1,2,1,0,0,c(1:11),a(1:6),1,1,1,0,1,1,1,c(1:8),1,2,a(1:4),1,1,0,0,1,a(1:5),1,a(1:4),1,1,1,0,1,1,0,0,1,0,0,0,b(1:6),0,1,1,0,2,1,0,1,1,0,1,0,0,1,1,1,0,1,1,0,2,1,1,0,1,1,1,2,0,0,0,c(1:11),1,1,0,b(1:4),0,1,1,1,c(1:4),1,1,2,2,2,1,0,1,a(1:8),1,1,a(1:4),1,a(1:4),1,1,0,b(1:6),0,0,0,b(1:9),0,0,1,1,0,1,1,1,0,1,1,0,0,1,1,1,0,2,2,1,1,1,2,1,1,0,0,1,c(1:10),b(1:13),c(1:7),b(1:4),0,1,1,a(1:6),2,a(1:4),1,a(1:4),b(1:6),0,1,1,1,0,1,1,1,2,1,1,2,2,b(1:4),2,1,0,0,1,0,1,0,1,a(1:5),2,b(1:8),...
        0,0,1,c(1:9),1,1,1,0,1,1,2,2,1,1,1,0,1,1,c(1:6),1,0,0,1,1,0,0,1,0,0,0,1,1,0,2,0,0,1,0,1,a(1:4),1,2,1,2,1,0,b(1:4),0,0,b(1:7),2,1,1,0,1,1,1,0,b(1:6),0,b(1:8),2,0,1,2,1,1,c(1:9),1,1,0,1,0,b(1:7),0,1,1,0,1,2,b(1:4),0,1,1,1,0,1,a(1:5),1,a(1:4),1,a(1:7),b(1:4),0,1,0,0,1,0,0,b(1:6),2,1,1,1,a(1:4),b(1:5),0,0,b(1:4),2,1,2,1,1,1,0,2,2,1,1,c(1:10),b(1:4),0,1,0,1,0,1,1,0,1,0,0,b(1:4),0,0,1,1,0,1,1,a(1:10),1,a(1:5),1,0,0,0,b(1:6),0,1,0,1,1,2,1,1,2,1,1,0,1,1,0,0,0,1,1,1,0,0,1,0,0,0,1,0,2,2,1,2,2,0,0,0,1,1,1,c(1:11),1,0,0,1,0,0,0,b(1:5),0,1,1,1,0,0,b(1:6),0,1,a(1:4),1,a(1:4),1,1,0,1,1,0,0,0,1,0,0,1,1,1,a(1:4),1,0,b(1:11),0,1,0,0,1,1,1,0,1,1,0,0,0,1,2,2,2,1,2,1,1,0,1,1,1,c(1:11),1,1,1,0,0,1,0,0,1,0,1,1,0,1,1,0,b(1:5),0,0,1,0,0,0,1,1,2,a(1:5),1,0,0,1,1,a(1:6),1,0,1,1,0,1,1,1,0,0,b(1:5),2,1,a(1:5),b(1:7),a(1:4),2,2,2,b(1:4),0,1,2,2,1,c(1:11),1,0,1,a(1:4),1,1,0,0,1,0,1,0,...
        1,1,1,0,0,1,1,a(1:5),1,1,a(1:6),1,0,0,1,a(1:7),1,0,1,1,0,1,0,1,0,0,b(1:9),a(1:4),1,1,1,0,1,0,1,0,1,2,b(1:4),0,1,0,0,0,c(1:14),0,1,a(1:8),1,0,1,1,0,0,0,1,0,0,1,1,0,0,1,1,1,a(1:11),1,a(1:5),b(1:6),0,1,1,0,0,0,1,0,b(1:6),0,0,b(1:6),0,1,1,0,0,2,2,0,0,1,0,1,1,0,0,0,c(1:14),0,0,0,1,1,a(1:4),1,0,1,1,1,0,b(1:4),0,1,1,1,0,1,0,b(1:4),0,0,0,1,a(1:13),1,2,1,0,1,1,0,0,0,b(1:6),0,1,0,b(1:8),0,1,0,0,2,0,0,1,0,1,0,1,0,0,0,c(1:14),a(1:4),1,a(1:6),1,0,1,1,1,0,b(1:4),0,0,1,1,1,a(1:11),1,a(1:4),2,0,0,0,b(1:5),0,1,0,0,0,b(1:7),0,b(1:5),0,1,1,a(1:4),1,2,b(1:4),0,0,0,1,0,1,c(1:15),0,1,a(1:5),1,0,1,0,1,1,0,0,0,1,0,0,1,0,2,a(1:14),1,0,0,0,1,0,0,1,0,b(1:4),0,2,2,0,0,b(1:8),0,0,1,1,1,0,0,0,1,0,1,1,1,0,2,1,1,0,1,1,a(1:4),c(1:16),1,0,1,1,a(1:5),1,0,0,1,0,1,1,0,1,0,2,a(1:11),1,1,1,0,2,1,0,0,1,0,b(1:9),0,1,0,0,0,b(1:5),0,1,1,0,b(1:4),a(1:6),1,1,2,b(1:4),a(1:4),c(1:17),b(1:5),a(1:4),...
        1,1,0,0,1,1,1,a(1:6),1,0,0,b(1:11),0,b(1:5),0,2,0,1,0,0,1,1,0,1,0,0,b(1:13),0,1,1,0,0,b(1:4),2,1,1,1,0,0,0,1,0,c(1:17),0,0,0,1,0,0,0,1,1,1,2,2,2,0,0,2,1,0,1,a(1:5),1,2,2,2,1,c(1:6),1,1,2,2,b(1:4),0,b(1:5),0,1,1,0,0,b(1:8),2,b(1:6),0,0,0,1,1,1,2,2,1,1,1,a(1:4),c(1:17),0,0,1,a(1:6),1,1,2,2,1,2,2,1,1,c(1:4),1,2,2,2,b(1:5),2,2,1,2,2,1,2,2,2,1,2,1,0,0,b(1:5),0,1,1,0,0,b(1:8),2,1,1,1,0,b(1:6),2,2,1,1,0,1,1,a(1:4),c(1:13),1,0,1,a(1:9),1,1,1,2,b(1:4),2,1,1,1,2,2,0,1,1,2,1,2,2,1,c(1:7),1,2,2,1,1,1,0,b(1:12),0,b(1:9),0,0,b(1:4),2,b(1:7),a(1:4),c(1:14),b(1:4),a(1:7),1,1,c(1:4),b(1:4),2,1,1,2,1,1,0,1,1,2,2,2,1,1,1,2,1,2,1,1,1,2,1,2,2,b(1:11),0,1,1,0,b(1:5),0,0,0,1,1,0,b(1:9),0,1,1,0,0,0,c(1:14),b(1:5),a(1:5),1,0,1,1,2,2,1,1,c(1:5),1,1,0,1,0,0,1,2,1,2,2,1,2,2,2,1,1,2,2,1,c(1:4),b(1:12),2,1,0,1,1,0,1,1,a(1:5),b(1:5),2,2,1,1,1,0,1,1,0,0,1,c(1:14),b(1:4),0,0,0,...
        1,0,0,1,0,0,c(1:7),1,c(1:4),0,1,1,a(1:5),c(1:10),1,2,2,1,1,0,0,b(1:5),0,1,0,0,1,1,0,0,0,1,1,1,a(1:4),b(1:10),0,0,1,1,0,0,c(1:16),0,0,0,1,0,0,1,0,0,1,0,0,1,1,2,2,2,1,c(1:5),0,1,0,1,0,1,1,0,0,1,2,2,1,1,2,2,1,2,1,1,2,2,b(1:5),2,1,1,1,0,2,1,0,1,1,0,b(1:4),0,0,0,b(1:8),0,1,1,1,0,1,1,0,0,c(1:19),0,1,1,1,0,1,0,0,1,0,0,1,c(1:6),1,1,2,0,0,1,2,0,0,1,1,0,1,1,c(1:11),1,0,b(1:6),0,1,2,1,0,1,1,0,1,1,0,1,1,0,b(1:11),0,1,1,1,0,0,c(1:21),1,1,1,0,0,0,1,0,0,1,1,c(1:9),1,0,1,2,0,0,1,0,0,1,c(1:5),1,c(1:4),1,2,1,0,b(1:5),0,0,1,1,0,0,1,1,0,0,0,1,1,0,0,b(1:8),0,0,1,0,1,1,0,0,c(1:26),1,1,0,0,1,0,1,c(1:8),0,0,1,1,a(1:6),1,1,0,c(1:10),1,0,b(1:5),0,1,1,2,0,0,1,2,1,0,1,1,1,0,b(1:4),0,1,1,0,0,1,1,1,a(1:4),c(1:28),0,1,1,1,0,1,1,c(1:4),1,2,2,0,0,1,1,0,0,0,1,1,0,0,1,1,1,c(1:6),1,2,b(1:4),0,0,0,b(1:5),0,0,1,1,1,0,1,1,2,0,b(1:4),0,1,0,0,0,1,1,1,a(1:4),c(1:29),0,1,1,0,1,c(1:6),1,2,0,...
        1,1,1,0,0,0,1,1,0,0,2,1,1,1,c(1:5),1,2,0,2,1,1,0,0,0,1,1,1,2,b(1:6),0,1,2,1,1,1,0,1,0,0,0,1,0,1,1,1,0,0,0,1,c(1:30),1,0,1,0,1,1,c(1:6),0,0,1,1,2,1,a(1:6),1,2,1,1,1,c(1:6),0,0,1,0,0,0,b(1:5),0,b(1:5),2,2,1,2,1,1,2,1,2,0,b(1:4),0,0,0,1,1,1,c(1:15),1,c(1:14),0,0,1,1,0,0,1,2,2,2,1,2,2,0,2,1,1,1,0,0,0,1,0,0,0,2,2,1,1,2,2,1,2,2,1,0,0,1,1,0,0,0,1,2,1,2,0,0,1,1,1,0,0,1,2,2,1,c(1:4),b(1:4),a(1:4),1,1,c(1:31),0,1,0,1,0,1,1,2,1,c(1:4),0,1,1,a(1:10),2,b(1:5),2,1,1,0,1,1,1,0,0,1,1,0,2,1,0,0,1,1,1,0,1,1,1,c(1:4),b(1:5),0,0,0,1,1,1,c(1:33),a(1:5),1,2,1,0,2,2,2,1,0,1,1,0,1,0,0,1,a(1:5),1,1,0,1,2,1,1,0,0,1,1,0,0,0,1,0,1,1,0,0,0,b(1:8),c(1:5),1,0,1,0,0,1,1,1,c(1:34),0,0,b(1:5),2,2,1,2,1,1,0,0,1,1,0,0,1,1,a(1:6),1,1,0,1,1,1,a(1:8),2,1,1,0,0,0,b(1:4),0,b(1:4),2,2,2,b(1:4),0,1,0,1,1,c(1:34),1,0,1,1,1,0,1,a(1:7),1,2,1,0,1,0,0,1,1,a(1:4),b(1:6),a(1:6),1,2,1,1,...
        a(1:6),b(1:8),2,1,1,0,0,b(1:5),c(1:36),0,1,1,0,0,0,1,1,a(1:5),1,2,2,1,2,1,1,0,0,1,1,a(1:14),1,1,a(1:7),b(1:4),0,0,1,1,1,2,2,0,0,1,1,1,0,1,c(1:38),a(1:6),2,0,0,1,0,0,0,1,1,0,1,1,a(1:19),1,0,0,0,1,0,0,0,b(1:12),0,b(1:5),c(1:40),0,0,0,1,0,0,0,1,1,0,0,0,2,a(1:10),c(1:6),a(1:7),1,a(1:8),1,1,2,b(1:7),0,0,1,1,1,0,c(1:42),a(1:8),1,0,1,1,a(1:5),c(1:14),a(1:4),1,1,a(1:4),1,0,0,0,1,1,0,b(1:8),0,1,0,c(1:44),a(1:8),1,0,1,1,1,a(1:4),c(1:14),0,1,0,1,1,1,0,0,1,1,0,0,0,b(1:8),2,0,1,2,0,c(1:45),0,1,a(1:8),1,a(1:6),c(1:15),0,1,1,1,a(1:9),1,1,1,2,1,1,1,0,0,2,1,0,c(1:46),0,1,0,0,1,a(1:6),1,a(1:4),c(1:16),1,1,0,1,0,1,1,2,2,a(1:4),b(1:6),0,1,2,1,c(1:47),0,1,1,2,0,0,1,0,0,1,0,0,0,1,0,0,0,c(1:16),0,b(1:4),2,2,2,a(1:5),b(1:5),0,c(1:51),1,0,1,2,0,1,0,1,1,2,1,2,a(1:4),c(1:17),1,c(1:6),a(1:4),b(1:6),0,c(1:53),0,1,1,1,c(1:5),0,1,1,0,0,c(1:23),1,1,1,0,0,b(1:6),0,c(1:56),0,...
        b(1:4),0,1,0,1,1,c(1:24),1,1,1,0,2,1,0,0,1,1,1,0,c(1:29),1,c(1:31),1,0,0,0,c(1:24),b(1:11),0,0,c(1:90),b(1:10),0,0,c(1:90),1,0,b(1:5),0,1,0,0,0,c(1:92),b(1:8),0,1,c(1:96),b(1:4),c(1:237)],[102,137]));set(gca,'xlim',[-40,178],'ylim',[-23,126]);colormap(gray);axis off;drawnow;
spm_ver = spm('ver','',1);
switch(lower(spm_ver)),
    case 'spm99', spm_ver=1;
    case 'spm2', spm_ver=2;
    case 'spm5', spm_ver=5;
    case {'spm8','spm8b'}, spm_ver=8;
    case {'spm12','spm12b'}, spm_ver=12;
    otherwise, disp(['Warning! unrecognized SPM version ',spm_ver]); spm_ver=5;
end
data.gui.spm_ver=spm_ver;
data.handles=handles;
data.params=params;
set(handles(1),'userdata',data);
% UPDATES ALREADY-DEFINED VALUES
if ~isempty(params.sources), rex_gui([],[],'sources',handles(1),0); end
if ~isempty(params.rois), rex_gui([],[],'rois',handles(1),0); end
if ~isempty(params.conjunction_mask), rex_gui([],[],'conjunction',handles(1),0); end
subplot(212);cla;
% PERFORM ADDITIONAL STEPS IF ANY
for n1=1:length(params.steps), rex_gui([],[],params.steps{n1},handles(1),0); end
varargout={[],[],[]};
return




% CALLBACK FUNCTION FOR GUI
function data=rex_gui(varargin);
%disp(varargin)
option=varargin{3};
if nargin<4, fig=gcbf; else, fig=varargin{4}; end
if nargin<5, interactive=1; else, interactive=varargin{5}; end
if isstruct(fig), data=fig; fig=[]; else, data=get(fig,'userdata'); end
SKIPLOAD=false;
switch(option),
    case 'sources',
        if ~isempty(data.params.spm_file), temp=data.params.spm_file; else, temp=data.params.sources; end
        if interactive,
            if data.gui.spm_ver<=2,     temp=spm_get(Inf,'*','Select files to extract from');
            else,                       temp=spm_select(Inf,'SPM\.mat$|\.img$|\.nii$','Select files to extract from',mat2cell(temp,ones(size(temp,1),1),size(temp,2))); end
        end
        if ~SKIPLOAD&&~isempty(temp),
            [nill,nill,ext]=fileparts(deblank(temp(1,:)));
            if size(temp,1)==1 && strcmp(ext,'.mat'),
                hf=msgbox('Loading header files. Please wait...');
                data.params.spm_file=deblank(temp);
                data.params.SPM=load(data.params.spm_file,'SPM');
                data.params.sources=strvcat(data.params.SPM.SPM.xY.VY(:).fname);
                try,
                    data.params.VF=data.params.SPM.SPM.xY.VY;
                    temp=spm_read_vols(data.params.VF(1));
                catch,
                    str=lasterror;%disp(['Warning: ',str.message]);
                    try,
                        data.params.VF=spm_vol(data.params.sources);
                    catch,
                        str=lasterror;%disp(['Warning: ',str.message]);
                        try,
                            temp=strvcat(data.params.SPM.SPM.xY.P{:});
                            data.params.VF=spm_vol(temp);
                            data.params.sources=temp;
                        catch,
                            str=lasterror;%disp(['Warning: ',str.message]);
                            cwd=pwd;[filepath,nill,nill]=fileparts(data.params.spm_file);if isempty(filepath),filepath='.';end;cd(filepath);
                            data.params.VF=rex_vol(data.params.sources,data.gui.spm_ver);
                            cd(cwd);
                        end
                    end
                end
                set(data.handles(3),'string',[num2str(length(data.params.VF)),' files selected'],'foregroundcolor','g');
                close(hf);
            else,
                data.params.spm_file='';
                data.params.sources=temp;
                hf=msgbox('Loading header files. Please wait...');data.params.VF=spm_vol(temp);close(hf);
                set(data.handles(3),'string',[num2str(length(data.params.VF)),' files selected'],'foregroundcolor','g');
            end
            set(fig,'userdata',data);
        end
        if ~(isempty(data.params.sources) || isempty(data.params.rois)),
            set(data.handles([9,10,12]),'enable','on');
        end
    case 'rois',
        temp=data.params.rois;
        if interactive,
            if data.gui.spm_ver<=2,     temp=spm_get(Inf,'*','Select files defining ROIs (image or .tal files)');
            else,                       temp=spm_select(Inf,'\.tal$|\.img$|\.nii$','Select files to extract from',mat2cell(temp,ones(size(temp,1),1),size(temp,2))); end
        end
        if ~isempty(temp),
            data.params.rois=temp;
            set(data.handles(5),'string',[num2str(size(temp,1)),' files selected'],'foregroundcolor','g');
            set(fig,'userdata',data);
        end
        if ~(isempty(data.params.sources) || isempty(data.params.rois)),
            set(data.handles(9),'enable','on');
        end
    case 'level',
        value=get(data.handles(6),'value');
        switch(value),
            case 1, %'Extract data from each ROI'
                data.params.level='rois';
                set(data.handles(7),'enable','on');
            case 2, %'Extract data from each cluster'
                data.params.level='clusters';
                set(data.handles(7),'enable','on');
            case 3, %'Extract data from each peak'
                temp=inputdlg({'Minimum distance between peaks (mm)?','Maximum number of peaks per cluster?'},'',1,{num2str(data.params.mindist),num2str(data.params.maxpeak)});
                if ~isempty(temp)&&~isempty(str2num(temp{1}))&&~isempty(str2num(temp{2})),
                    data.params.mindist=max(0,str2num(temp{1}));
                    data.params.maxpeak=max(1,str2num(temp{2}));
                    data.params.level='peaks';
                    set(data.handles(7),'enable','on');
                end
            case 4, %'Extract data from each voxel'
                data.params.level='voxels';
                set(data.handles(7),'enable','off');
        end
        set(fig,'userdata',data);
    case 'conjunction',
        value=get(data.handles(11),'value');
        switch(value),
            case 1, %'no conjunction mask'
                data.params.conjunction_mask='';
            case 2, %'use conjunction mask'
                temp=data.params.conjunction_mask;
                if interactive,
                    if data.gui.spm_ver<=2,     temp=spm_get(Inf,'*','Select conjunction mask(s)');
                    else,                       temp=spm_select(Inf,'\.img$|\.nii$','Select conjunction mask(s)',mat2cell(temp,ones(size(temp,1),1),size(temp,2))); end
                end
                if ~isempty(temp),
                    hf=msgbox('Loading header files. Please wait...');data.params.VM=spm_vol(temp);close(hf);
                    data.params.conjunction_mask=temp;
                else,
                    data.params.conjunction_mask='';
                    set(data.handles(11),'value',1);
                end
        end
        set(fig,'userdata',data);
    case 'summary_measure',
        value=get(data.handles(7),'value');
        switch(value),
            case 1, %'Extract mean'
                data.params.summary_measure='mean';
            case 2, %'Extract eigenvariate'
                if isfield(data.params,'VF')&&length(data.params.VF)==1, 
                    errordlg(['You need multiple source volumes to perform eigenvariate estimation']); 
                    set(data.handles(7),'value',1);
                else, 
                    data.params.summary_measure='eigenvariate'; 
                    temp=inputdlg('Number of eigenvariates?','',1,{num2str(data.params.dims)});
                    if ~isempty(temp)&&~isempty(str2num(temp{1})),
                        data.params.dims=max(1,str2num(temp{1}));
                    end
                end
            case 3, %'Extract weighted-mean'
                data.params.summary_measure='weighted mean';
            case 4, %'Extract median'
                data.params.summary_measure='median';
            case 5, %'Extract sum'
                data.params.summary_measure='sum';
            case 6, %'Extract weighted-sum'
                data.params.summary_measure='weighted sum';
            case 7, %'Extract voxel count'
                data.params.summary_measure='count';
            case 8, %'Extract maximum'
                data.params.summary_measure='max';
            case 9, %'Extract minimum'
                data.params.summary_measure='min';
        end
        set(fig,'userdata',data);
    case 'scaling',
        value=get(data.handles(8),'value');
        switch(value),
            case 1, %'No scaling'
                data.params.scaling='none';
            case 2, %'global scaling'
                data.params.scaling='global';
            case 3, %'within-roi scaling'
                if isfield(data.params,'VF')&&length(data.params.VF)==1, 
                    errordlg(['You need multiple source volumes to perform within-roi scaling']); 
                    set(data.handles(8),'value',1);
                else, data.params.scaling='roi'; end
        end
        set(fig,'userdata',data);
    case 'output_type',
        value=get(data.handles(13),'value');
        switch(value),
            case {1,3}, %'save' 'savefiles'
                tfig=figure('units','norm','position',[.4,.6,.2,.3],'name','Output files','menubar','none','numbertitle','off','color','w');
                th(1)=uicontrol('units','norm','position',[.1,.7,.8,.1],'style','checkbox','string','Data files (.mat)','value',~isempty(strmatch('data.mat',data.params.output_files,'exact')));
                th(2)=uicontrol('units','norm','position',[.1,.6,.8,.1],'style','checkbox','string','Data files (.txt)','value',~isempty(strmatch('data.txt',data.params.output_files,'exact')));
                th(3)=uicontrol('units','norm','position',[.1,.5,.8,.1],'style','checkbox','string','ROI files (.tal)','value',~isempty(strmatch('roi.tal',data.params.output_files,'exact')));
                th(4)=uicontrol('units','norm','position',[.1,.4,.8,.1],'style','checkbox','string','ROI files (.img)','value',~isempty(strmatch('roi.img',data.params.output_files,'exact')));
                th(5)=uicontrol('units','norm','position',[.1,.3,.8,.1],'style','checkbox','string','ROI# files (.img)','value',~isempty(strmatch('roi#.img',data.params.output_files,'exact')));
                th(6)=uicontrol('units','norm','position',[.1,.2,.8,.1],'style','pushbutton','string','Done','callback','uiresume');
                uiwait(tfig);
                data.params.output_files={};
                if get(th(1),'value'), data.params.output_files{end+1}='data.mat'; end
                if get(th(2),'value'), data.params.output_files{end+1}='data.txt'; end
                if get(th(3),'value'), data.params.output_files{end+1}='roi.tal'; end
                if get(th(4),'value'), data.params.output_files{end+1}='roi.img'; end
                if get(th(5),'value'), data.params.output_files{end+1}='roi#.img'; end
                close(tfig);
                if value==1, data.params.output_type='save';
                else data.params.output_type='savefiles';
                end
            case 2, %'saverex'
                data.params.output_type='saverex';
            case 4, %'none'
                data.params.output_type='none';
        end
        set(fig,'userdata',data);
    case 'extract',
        [data.params.ROIdata,data.params.ROInames,data.params.ROIinfo.basis,data.params.ROIinfo.voxels,data.params.ROIinfo.files,data.params.ROIinfo.select,data.params.ROIinfo.trans]=rex_do(data,~data.params.gui||(isfield(data.params,'steps')&&any(strcmp(data.params.steps,'nodisplay'))));
        if strcmpi(data.params.output_type,'save')||strcmpi(data.params.output_type,'saverex'), params=data.params;save(fullfile(params.output_folder,params.output_rex),'params');end
        if ishandle(fig),
            set(data.handles([10,12]),'enable','on');
            set(fig,'userdata',data);
        end
    case 'display',
        rex_display(data.params);
    case {'results','plots'},
        if ~isfield(data.params,'ROIdata'),
            msgbox('You need to extract data first');
            return;
        end
        % selects SPM.mat if not already there
        if isempty(data.params.spm_file),
            temp=spm_select(Inf,'SPM\.mat$','Select SPM.mat file'); 
            [nill,nill,ext]=fileparts(deblank(temp(1,:)));
            if size(temp,1)==1 && strcmp(ext,'.mat'),
                hf=msgbox('Loading header files. Please wait...');
                data.params.spm_file=deblank(temp);
                data.params.SPM=load(data.params.spm_file,'SPM');
                if size(data.params.SPM.SPM.xX.X,1)~=size(data.params.ROIdata,1),
                    close(hf);
                    errordlg(['The number of datapoints extracted (',num2str(size(data.params.ROIdata,1)),') does not match the design size (',num2str(size(data.params.SPM.SPM.xX.X,1)),')']); 
                    data.params.spm_file='';data.params.SPM=[];
                    if ishandle(fig), set(fig,'userdata',data); end
                    return;
                end
                close(hf);
                if ishandle(fig), set(fig,'userdata',data); end
            else, return; end
        end
        switch(option),
            case 'results',
                if isfield(data.params,'s'),
                    if isempty(data.params.s), s=1:length(data.params.ROInames);
                    else, s=data.params.s; end;
                elseif length(data.params.ROInames)>1,
                    [s,v] = listdlg('PromptString',['Select ROIs '],...
                        'SelectionMode','multiple',...
                        'ListString',strvcat(data.params.ROInames),...
                        'InitialValue',1:length(data.params.ROInames),...
                        'ListSize',[300,300]);
                else, s=1; end
                if length(s)>0,
                    try, cname=data.params.SPM.SPM.xX_multivariate.Ynames;
                    catch, cname={};
                    end
                    if isfield(data.params.SPM.SPM,'xX_multivariate')&&isfield(data.params.SPM.SPM.xX_multivariate,'dof')
                        c=data.params.SPM.SPM.xX_multivariate.C;
                        xX=data.params.SPM.SPM.xX_multivariate;
                    else
                        if isfield(data.params,'ic')&&~isempty(data.params.ic), Ic=data.params.ic;
                        elseif isfield(data.params,'gui')&&~data.params.gui&&isfield(data.params.SPM.SPM,'xCon')&&numel(data.params.SPM.SPM.xCon)==1, Ic=1;
                        else [Ic,data.params.SPM.SPM.xCon] = spm_conman(data.params.SPM.SPM,'T|F',inf,'Select contrast','',1);
                        end
                        c=[data.params.SPM.SPM.xCon(Ic).c];
                        if isempty(cname), cname={data.params.SPM.SPM.xCon(Ic).name}; end
                        xX=data.params.SPM.SPM.xX;
                    end
                    [cbeta,CI,T,p,P,dof]=rex_test(xX,data.params.ROIdata(:,s),c,'figure',cname,{data.params.ROInames{s}},s,data.params.ROIinfo);
                    if strcmpi(data.params.output_type,'save')||strcmpi(data.params.output_type,'saverex'),
                        params=data.params;
                        params.results=struct('beta',cbeta,'CI',CI,'T',T,'p_unc',p,'p_FDR',P,'dof',dof,'contrast',c,'contrast_name',{cname},'ROI_name',{{data.params.ROInames{s}}});
                        save(fullfile(params.output_folder,params.output_rex),'params');
                        clear params;
                    end
                    
                    if ishandle(fig), set(fig,'userdata',data); end
                end
            case 'plots',
                % selects ROI
                hfig=figure('units','norm','position',[.41,.4,.4,.5],'name','REX plots','numbertitle','off','color','w');
                names=data.params.ROInames;
                nroi=spm_input('Which roi?',-1,'m',{strvcat(names{:})});
                % computes GLM model
                [Beta,ResMS]=rex_modelestimate(data.params.SPM.SPM.xX,data.params.ROIdata);
                % plots
                spm_graph(data.params.ROIdata(:,nroi),Beta(:,nroi),ResMS(:,nroi),data.params.SPM.SPM,hfig);
        end
        
end
return;




% MAIN DATA EXTRACTION ROUTINE
function varargout=rex_do(params,silence)
txt={};ROInames={};
if isfield(params,'params'), if isfield(params,'handles'), handles=params.handles; else, handles=[]; end; params=params.params; 
else, handles=[]; end
%if ~isfield(params,'VF'), params.VF=[]; end
if ~isfield(params,'VF')||isempty(params.VF),varargout={[],[],[],[],[],[],[]};return;end
if ~isempty(params.spm_file)&&isfield(params,'SPM')&&isfield(params.SPM,'SPM')&&isfield(params.SPM.SPM,'Sess'),
    sessions=zeros(length(params.VF),1);for n1=1:length(params.SPM.SPM.Sess), sessions(params.SPM.SPM.Sess(n1).row)=n1;end;if any(sessions==0), sessions=sessions+1; end
else,
    sessions=ones(length(params.VF),1);
end
if ~isfield(params,'disregard_zeros'), params.disregard_zeros=1; end
ROIdata=nan+zeros(length(params.VF),size(params.rois,1));
ROIdat=ROIdata;
ROIbasis={};ROIvoxels={};ROIfiles={};ROIselect={};ROItrans={};
XYZMM={};XYZWW={};XYZNN={};XYZnames={};ROIA={};ROIB={};idxcl={};
rrx={}; g={};
rr=1;
iM={};isequalM=[];XYZ1={}; for i=1:length(params.VF), isequalM(i)=isequal(params.VF(i).mat,params.VF(1).mat); if i==1||~isequalM(i), iM{i}=inv(params.VF(i).mat); else; iM{i}=iM{1}; end; end
refinfo=[];
NaNrep=[];

for r=1:size(params.rois,1)
    roi_path = deblank(params.rois(r,:));
    [roi_path_dir,roi_path_name,roi_path_ext,roi_path_num]=spm_fileparts(roi_path);
    
    % Read in coordinates into ROImm
    % -------------------
    if ~isfield(params,'roi_threshold'),params.roi_threshold=0;end
    switch(roi_path_ext),
        case '.tal',
            [XYZMM{r},XYZWW{r},XYZNN{r},XYZnames{r},ROIA{r},ROIB{r}]=rex_image(roi_path,params.level,'text',params.select_clusters,params.selected_clusters,params.mindist,params.maxpeak,params.dims(min(r,length(params.dims))),params.roi_threshold);
        case {'.img','.nii'}
            [XYZMM{r},XYZWW{r},XYZNN{r},XYZnames{r},ROIA{r},ROIB{r}]=rex_image(roi_path,params.level,'image',params.select_clusters,params.selected_clusters,params.mindist,params.maxpeak,params.dims(min(r,length(params.dims))),params.roi_threshold);
        otherwise,
            error(['Warning! unrecognized tile format ',roi_path_ext]);
    end
    if isfield(params,'fsanatomical')&&~isempty(params.fsanatomical)&&~conn_surf_dimscheck(size(ROIB{r})),
        error('Surface extraction requires standard fsaverage-space ROIs');
    end
    
    for nclusters=1:length(XYZMM{r}),
        g{r}{nclusters}=zeros(2,max(sessions));
        %if rr>size(ROIdata,2), ROIdata=cat(2,ROIdata,nan+zeros(length(params.VF),1)); end
        %if rr>size(ROIdat,2),  ROIdat =cat(2,ROIdat ,nan+zeros(length(params.VF),1)); end
        XYZmm=XYZMM{r}{nclusters};
        XYZww=XYZWW{r}{nclusters};
        XYZnn=XYZNN{r}(nclusters);
        ROInames{rr}=[roi_path_name];
        if iscell(XYZnames{r})&&length(XYZnames{r})>=nclusters, ROInames{rr}=[ROInames{rr},'.',XYZnames{r}{nclusters}];
        elseif length(XYZMM{r})>1, ROInames{rr}=[ROInames{rr},'.cluster',num2str(XYZnn,'%03d')];
        elseif ~isempty(roi_path_num), ROInames{rr}=[ROInames{rr},'.',regexprep(roi_path_num,'\D','')]; 
        end
        if strcmpi(params.summary_measure,'eigenvariate'),rrx{r}{nclusters}=rr-1+(1:params.dims(min(r,length(params.dims)))); tempx='.eig'; %min(params.dims(min(r,length(params.dims))),min(length(params.VF),size(XYZmm,2))));tempx='.eig';
        elseif strcmpi(params.level,'voxels')||strcmpi(params.level,'subsetvoxels'),rrx{r}{nclusters}=rr-1+(1:size(XYZmm,2));tempx='.voxel';
        else rrx{r}{nclusters}=rr; 
        end
        if length(rrx{r}{nclusters})>1, 
            namesx=cell(1,length(rrx{r}{nclusters})); 
            if strcmpi(params.level,'subsetvoxels'), for i=1:length(rrx{r}{nclusters}), namesx{i}=XYZmm(:,i); end 
            elseif ~strcmp(params.output_type,'none'),for i=1:length(rrx{r}{nclusters}), namesx{i}=[ROInames{rr},tempx,num2str(i,'%05d')]; end
            end
        else namesx={ROInames{rr}}; 
        end
        txt{end+1}=[num2str(size(XYZmm,2)), ' voxels in ROI ',ROInames{rr}];
        if ~silence,disp(txt{end});end
        
        if ~isempty(params.conjunction_mask),
            for nconj=1:length(params.VM),
                c_iM=inv(params.VM(nconj).mat);
                c_XYZ = c_iM(1:3,:)*[XYZmm; ones(1,size(XYZmm,2))];
                m=spm_get_data(params.VM(nconj),c_XYZ);
                XYZmm=XYZmm(:,m>0);
                XYZww=XYZww(:,m>0);
            end
            txt{end+1}=[num2str(size(XYZmm,2)), ' voxels in ROI ',ROInames{rr},' after conjunction'];
            if ~silence,disp(txt{end});end
        end
        eXYZmm{r}{nclusters}=[XYZmm; ones(1,size(XYZmm,2))];
        if numel(iM)>0, XYZ1{r}{nclusters} = iM{1}*eXYZmm{r}{nclusters}; end
        
        ROIfiles{r}{nclusters}=fullfile(pwd,[ROInames{rr},'.rex']);
        ROIvoxels{r}{nclusters}=XYZmm';
        XYZMM{r}{nclusters}=XYZmm;
        XYZWW{r}{nclusters}=XYZww;
        XYZNN{r}(nclusters)=XYZnn;
        if isfield(params,'fsanatomical')&&~isempty(params.fsanatomical), idxcl{r}{nclusters}=find(ROIB{r}(:)==nclusters); end
        % indexes of ROIdata to indexes of ROIbasis/ROIvoxels transformation
        switch(lower(params.level)),
            case {'rois','clusters','peaks'},
                if strcmpi(params.summary_measure,'eigenvariate'),
                    for n1=1:length(rrx{r}{nclusters}), ROItrans{rrx{r}{nclusters}(n1)}={r,nclusters,n1,':'}; end
                else,
                    ROItrans{rrx{r}{nclusters}}={r,nclusters,1,':'};
                end
            case {'voxels','subsetvoxels'}
                for n1=1:min(1e2,length(rrx{r}{nclusters})), ROItrans{rrx{r}{nclusters}(n1)}={r,nclusters,n1,n1}; end
        end
        if strcmpi(params.level,'subsetvoxels')||~strcmp(params.output_type,'none'), for i=1:length(rrx{r}{nclusters}), ROInames{rrx{r}{nclusters}(i)}=namesx{i}; end; end
        rr=rr+length(rrx{r}{nclusters});
    end
    ROIselect{r}=XYZNN{r};
end
ROIdata=nan+zeros(length(params.VF),rr-1);
ROIdat=ROIdata;

warndisp=1;
if ~isempty(params.spm_file), cwd=pwd;[filepath,nill,nill]=fileparts(params.spm_file);if isempty(filepath),filepath='.';end;cd(filepath); end

if strcmpi(params.summary_measure,'eigenvariate'), % first-step: compute covariance structure
    dataAll={};dataMean={};
    for r=1:size(params.rois,1)
        for nclusters=1:length(XYZMM{r}),
            %if strcmpi(params.scaling,'roi'),g=zeros(2,max(sessions));end;
            
            XYZmm=XYZMM{r}{nclusters};
            XYZww=XYZWW{r}{nclusters};
            XYZnn=XYZNN{r}(nclusters);

            tdata=zeros(length(params.VF),length(params.VF));
            tdatamean=zeros(1,size(XYZmm,2));
            dataM=zeros(length(params.VF),1);
            %dataN=0;
            if ~silence, hft=waitbar(0,['Precomputing covariance structure']); set(hft,'color','w'); end
            for n1=1:1e3:size(XYZmm,2),
                idx=n1:min(size(XYZmm,2),n1-1+1e3);
                temp1=zeros(length(params.VF),length(idx));
                if isfield(params,'fsanatomical')&&~isempty(params.fsanatomical)
                    for i=1:length(params.VF),
                        [tdata,nill,nill,refinfo]=conn_surf_extract(params.VF(i),[],params.fsanatomical,0,false,false,refinfo,idxcl{r}{nclusters}(idx));
                        temp1(i,:)=tdata;
                        %temp1(i,:)=tdata(idxcl{r}{nclusters}(idx));
                    end
                else
                    for i=1:length(params.VF),
                        if isequalM(i), XYZ=XYZ1{r}{nclusters}(:,idx);
                        else XYZ = iM{i}*eXYZmm{r}{nclusters}(:,idx);
                        end
                        temp1(i,:) = spm_sample_vol(params.VF(i),XYZ(1,:),XYZ(2,:),XYZ(3,:),0);
                    end
                end
                idxnan=find(isnan(temp1));
                if ~isempty(idxnan),
                    tdatamean(idx)=sum(~isnan(temp1),1);
                    %dataN=dataN+sum(tdatamean(idx)>0);
                    temp1(idxnan)=0;
                    tdatamean(idx)=sum(temp1,1)./max(eps,tdatamean(idx));
                    [idxnani,idxnanj]=ind2sub(size(temp1),idxnan);
                    temp1(idxnan)=tdatamean(idx(idxnanj));
                else tdatamean(idx)=mean(temp1,1); end %dataN=dataN+length(idx); end
                if ~silence, waitbar(n1/size(XYZmm,2),hft); end
                temp2=temp1-repmat(mean(temp1,1),[size(temp1,1),1]);
                tdata=tdata+temp2*temp2';
                dataM=dataM+sum(temp2,2);
            end
            %             tdata=tdata/dataN;
            %             dataM=dataM/dataN;
            %             tdata=tdata-dataM*dataM';
            if ~silence, close(hft); end
            cov0=ones(size(tdata,1),1);
            if isfield(params,'pca')&&~params.pca, dataM=[]; end
            if isfield(params,'covariates')&&~isempty(params.covariates),
                cov1=[dataM,detrend(params.covariates,'constant')];
            else
                cov1=dataM;
            end
            proj=eye(size(tdata,1))-[cov1,0*cov0]*pinv([cov1,cov0]); % removes covariates keeping scale unchanged
            tdata=proj*tdata*proj';
            if isfield(params,'pca')&&~params.pca, tempall=params.dims(min(r,length(params.dims)));
            else tempall=params.dims(min(r,length(params.dims)))-1; 
            end
            temp=min(size(tdata,2),tempall);
            try
                [q1,q2]=svd((tdata+tdata')/2);
            catch
                [q1,q2]=svds((tdata+tdata')/2,temp);
            end
            if temp<tempall, q1(end,tempall)=0; q2(tempall,tempall)=0; end
            dataAll{r}{nclusters}=q1(:,1:tempall)*diag(sqrt(diag(q2(1:tempall,1:tempall))));
            dataMean{r}{nclusters}=tdatamean;
            ROIbasis{r}{nclusters}=zeros(size(XYZmm,2),tempall);
        end
    end
elseif strcmpi(params.level,'voxels')||strcmpi(params.level,'subsetvoxels'),
    dataAll={};
    for r=1:size(params.rois,1)
        for nclusters=1:length(XYZMM{r}),
            dataAll{r}{nclusters}=zeros(length(params.VF),size(XYZmm,2));
        end
    end
end

if isfield(params,'fsanatomical')&&~isempty(params.fsanatomical)
    allidxcl={}; this={};
    nn=0;
    for r=1:size(params.rois,1)
        for nclusters=1:length(XYZMM{r}),
            this{r}{nclusters}=nn+(1:numel(idxcl{r}{nclusters}));
            allidxcl{end+1}=idxcl{r}{nclusters};
            nn=nn+numel(idxcl{r}{nclusters});
        end
    end
    allidxcl=cat(1,allidxcl{:});
else
    allxyz1={}; allxyz2={}; this={};
    nn=0;
    if ~isempty(XYZ1)
        for r=1:size(params.rois,1)
            for nclusters=1:length(XYZMM{r}),
                this{r}{nclusters}=nn+(1:size(XYZ1{r}{nclusters},2));
                allxyz1{end+1}=XYZ1{r}{nclusters};
                allxyz2{end+1}=eXYZmm{r}{nclusters};
                nn=nn+size(XYZ1{r}{nclusters},2);
            end
        end
    end
    allxyz1=cat(2,allxyz1{:});
    allxyz2=cat(2,allxyz2{:});
end
cnd01=~(strcmpi(params.summary_measure,'eigenvariate')||strcmpi(params.summary_measure,'weighted mean')||strcmpi(params.summary_measure,'weighted sum'));
cnd02=strcmpi(params.level,'voxels')||strcmpi(params.level,'subsetvoxels');
for i = 1:length(params.VF)
    if isfield(params,'fsanatomical')&&~isempty(params.fsanatomical)
        [data,nill,nill,refinfo]=conn_surf_extract(params.VF(i),[],params.fsanatomical,0,false,false,refinfo,allidxcl);%,idxcl{r}{nclusters});
        dall=data;
        %d=data;
    else
        % Convert to XYZmm to pixel coordinates in XYZ
        %iM=inv(params.VF(i).mat);
        dall=[];
        if isequalM(i),
            if ~isempty(allxyz1), dall = spm_sample_vol(params.VF(i),allxyz1(1,:),allxyz1(2,:),allxyz1(3,:),0); end %XYZ1{r}{nclusters}(1,:),XYZ1{r}{nclusters}(2,:),XYZ1{r}{nclusters}(3,:),0);
        else
            if ~isempty(allxyz2), 
                XYZ = iM{i}*allxyz2;
                dall = spm_sample_vol(params.VF(i),XYZ(1,:),XYZ(2,:),XYZ(3,:),0);
            end
        end
        % resample data at voxel in ROI
        %d = spm_get_data(params.VF(i),XYZ,0);
    end
    % mask with NaNrep
    if numel(NaNrep)<i
        if isfield(params.VF(i),'dim')&&length(params.VF(i).dim)>3,NaNrep(i) = spm_type(params.VF(i).dim(4),'nanrep');
        elseif isfield(params.VF(i),'dt'), NaNrep(i) = spm_type(params.VF(i).dt(1),'nanrep');
        else, NaNrep(i)=0; end
    end
    rr=1;
    for r=1:size(params.rois,1)
        for nclusters=1:length(XYZMM{r}),
            %XYZmm=XYZMM{r}{nclusters};
            XYZww=XYZWW{r}{nclusters};
            %XYZnn=XYZNN{r}(nclusters);
            d=dall(this{r}{nclusters});
            
            if cnd01, %~(strcmpi(params.summary_measure,'eigenvariate')||strcmpi(params.summary_measure,'weighted mean')||strcmpi(params.summary_measure,'weighted sum')),
                if NaNrep(i)==0&&params.disregard_zeros, d2 = d(d~=0&~isnan(d));
                else d2 = d(~isnan(d));
                end
                if isempty(d2),
                    if warndisp&&~isempty(d), fprintf('warning: no valid data for ROI %s in %s (scan # %d/%d)\n',ROInames{rr},params.VF(i).fname,i,length(params.VF)); warndisp=0; end
                    d2=nan;
                end
            end
            if cnd02,
                dataAll{r}{nclusters}(i,:)=d(:)';ROIdat(i,rr)=mean(d2);
            else
                switch(lower(params.summary_measure)),
                    case 'mean',
                        ROIdat(i,rr) = sum(d2)/numel(d2);
                    case 'eigenvariate',
                        d3=d;if NaNrep(i)==0&&(~isfield(params,'disregard_zeros')||params.disregard_zeros), d3(~d3)=dataMean{r}{nclusters}(~d3); end;d3(isnan(d3))=dataMean{r}{nclusters}(isnan(d3));
                        ROIbasis{r}{nclusters}=ROIbasis{r}{nclusters}+d3(:)*dataAll{r}{nclusters}(i,:);
                        ROIdat(i,rr)=mean(d3);
                        %data(i,:)=d(:)';ROIdat(i,rr)=mean(d2);
                        %if step==1, data(i,:)=d(:)';
                        %elseif step==2, temp=weight.*d(:); temp(isnan(temp))=0; ROIdat(i,rr)=sum(temp); end
                    case 'weighted mean',
                        temp=XYZww(:).*d(:);
                        temp=temp/max(eps,sum(abs(XYZww(~isnan(temp)))));
                        temp(isnan(temp))=0;
                        ROIdat(i,rr)=sum(temp);
                    case 'median',
                        ROIdat(i,rr) = median(d2);
                    case 'sum',
                        ROIdat(i,rr) = sum(d2);
                    case 'weighted sum',
                        temp=~(isnan(XYZww)|isnan(d));
                        ROIdat(i,rr)=XYZww(temp)*d(temp)'/numel(d);
                    case 'size',
                        ROIdat(i,rr) = numel(d2);
                    case 'count',
                        ROIdat(i,rr) = sum(d2>0);
                    case 'max',
                        ROIdat(i,rr) = max(d2);
                    case 'min',
                        ROIdat(i,rr) = min(d2);
                end
            end
            if strcmpi(params.scaling,'global')
                if r==1&&nclusters==1, %&& step==1 ,
                    % Computes global scaling
                    g{r}{nclusters}(:,sessions(i))=g{r}{nclusters}(:,sessions(i))+[spm_global(params.VF(i));1];
                else g{r}{nclusters}=g{1}{1};
                end
            end
            if strcmpi(params.scaling,'roi'),% && ~(strcmpi(params.summary_measure,'eigenvariate')&&step==1),
                % Computes within-roi scaling
                g{r}{nclusters}(:,sessions(i))=g{r}{nclusters}(:,sessions(i))+[ROIdat(i,rr);1];
            end
            if ~silence && ~isempty(handles) && (rand<5/length(params.VF) ||i==length(params.VF)),% && ~(strcmpi(params.summary_measure,'eigenvariate')&&step==1),
                figure(handles(1));subplot(212);
                if size(ROIdat,1)>1, h=plot(ROIdat(:,max(1,rr-10):rr),'-'); for n1=1:length(h),set(h(n1),'color',ones(1,3)*(1-n1/length(h)));end;axis tight;
                else, bar(ROIdat'); end
                set(gca,'units','norm','position',[.2,.2,.6,.2],'xcolor','c','ycolor','c');xlabel('volumes/scans');ylabel('raw data');
                drawnow;
            end
            rr=rr+length(rrx{r}{nclusters});
        end
    end
    if ~silence&&length(params.VF)>1,
        if i==1, hf=waitbar((i/length(params.VF)),'Extracting data');set(hf,'color','w');
        elseif i==length(params.VF), if ishandle(hf), close(hf); end
        elseif (rand<100/length(params.VF)||i==length(params.VF)), waitbar((i/length(params.VF)),hf);
        end
    end
end
if ~isempty(params.spm_file), cd(cwd);end

rr=1;
for r=1:size(params.rois,1)
    roi_path = deblank(params.rois(r,:));
    [roi_path_dir,roi_path_name,roi_path_ext,roi_path_num]=spm_fileparts(roi_path);
    for nclusters=1:length(XYZMM{r}),
        %XYZmm=XYZMM{r}{nclusters};
        XYZww=XYZWW{r}{nclusters};
        %XYZnn=XYZNN{r}(nclusters);
        
        if strcmpi(params.summary_measure,'eigenvariate'),%step==1&
            ROIbasis{r}{nclusters}=ROIbasis{r}{nclusters}*diag(1./max(eps,sqrt(sum(ROIbasis{r}{nclusters}.^2,1))));
            temp=sign(sum(ROIbasis{r}{nclusters},1))./max(eps,sum(abs(ROIbasis{r}{nclusters}),1));
            ROIbasis{r}{nclusters}=ROIbasis{r}{nclusters}*diag(temp);
            dataAll{r}{nclusters}=dataAll{r}{nclusters}*diag(temp);
            %                 for n1=1:size(data,2),data(isnan(data(:,n1)),n1)=mean(data(~isnan(data(:,n1)),n1),1); end;
            %                 idxvalid=find(~any(isnan(data),1));
            %                 sdata=size(data,2);
            %                 weight=zeros(sdata,1);
            %                 data=data(:,idxvalid);
            %                 %[temp,nill,nill]=svd(data(:,idxvalid)',0);weight(idxvalid)=temp(:,1); weight=weight/sum(weight); step=step+1;
            %                 if size(data,1)<length(idxvalid), [q1,q2,q3]=svd(data',0);
            %                 else, [q3,q2,q1]=svd(data,0); end
            %                 temp=min(size(q3,2),params.dims(min(r,length(params.dims))));
            %                 ROIbasis{r}{nclusters}=zeros(sdata,temp);
            %                 data=q3(:,1:temp)*diag(diag(q2(1:temp,1:temp))'.*sign(sum(q1(:,1:temp),1))./max(eps,sum(abs(q1(:,1:temp)),1)));
            %                 ROIbasis{r}{nclusters}(idxvalid,:)=q1(:,1:temp)*diag(sign(sum(q1(:,1:temp),1))./max(eps,sum(abs(q1(:,1:temp)),1)));
        else, ROIbasis{r}{nclusters}=XYZww(:);
        end
        if strcmpi(params.summary_measure,'eigenvariate'),
            if isfield(params,'pca')&&~params.pca, dataAll{r}{nclusters}=dataAll{r}{nclusters}(:,1:numel(rrx{r}{nclusters})); 
            else dataAll{r}{nclusters}=cat(2,ROIdat(:,rr),dataAll{r}{nclusters});
                ROIbasis{r}{nclusters}=cat(2,ones(size(ROIbasis{r}{nclusters},1),1),ROIbasis{r}{nclusters});
                dataAll{r}{nclusters}=dataAll{r}{nclusters}(:,1:numel(rrx{r}{nclusters})); 
            end
        end
        if strcmpi(params.level,'voxels')||strcmpi(params.level,'subsetvoxels')||strcmpi(params.summary_measure,'eigenvariate'),ROIdat(:,rrx{r}{nclusters})=dataAll{r}{nclusters}; end
        
        % scaling
        for n1=1:max(sessions),
            idx=find(sessions==n1);
            if ~isempty(idx),
                switch(lower(params.scaling)),
                    case {'global','roi'},  ROIdata(idx,rrx{r}{nclusters})=ROIdat(idx,rrx{r}{nclusters})/abs(sum(g{r}{nclusters}(1,n1))/sum(g{r}{nclusters}(2,n1)))*100;
                    otherwise,              ROIdata(idx,rrx{r}{nclusters})=ROIdat(idx,rrx{r}{nclusters});
                end
            end
        end
        
        % work out output arguments
        % write output files if requested
        % -------------------------
        if strcmpi(params.output_type,'save')||strcmpi(params.output_type,'savefiles')
            if ~isempty(strmatch('data.txt',params.output_files,'exact')),
                name_dat=fullfile(params.output_folder,[ROInames{rr},'.rex.data.txt']);
                fid = fopen(name_dat,'w');
                if fid == -1, error(['Unable to create new file - please check permissions in current directory.']);end
                fprintf(fid,[repmat(['%4.4f '],[1,length(rrx{r}{nclusters})]),'\n'], ROIdata(:,rrx{r}{nclusters})');
                fclose(fid);
                txt{end+1}=['OUTPUT DATA FILE: ',char(name_dat)];
            end
            if ~isempty(strmatch('data.mat',params.output_files,'exact')),
                name_dat=fullfile(params.output_folder,[ROInames{rr},'.rex.data.mat']);
                R=ROIdata(:,rrx{r}{nclusters});
                save(name_dat,'R');
                txt{end+1}=['OUTPUT DATA FILE: ',char(name_dat)];
            end
            if ~isempty(strmatch('roi.txt',params.output_files,'exact')),
                name_dat=fullfile(params.output_folder,[ROInames{rr},'.rex.roi.tal']);
                fid = fopen(name_dat,'w');
                if fid == -1, error(['Unable to create new file - please check permissions in current directory.']);end
                fprintf(fid,'%3.0f %3.0f %3.0f\n',XYZMM{r}{nclusters});
                fclose(fid);
                txt{end+1}=['OUTPUT ROI FILE : ',char(name_dat)];
            end
            txt{end+1}=['LOCATION: ',params.output_folder];
            txt{end+1}=' ';
            if ~isempty(strmatch('roi#.img',params.output_files,'exact')),
                name_dat=fullfile(params.output_folder,[ROInames{rr},'.rex.roi.img']);
                ROIa=struct('fname',name_dat,'mat',ROIA{r}.mat,'dim',ROIA{r}.dim,'dt', [spm_type('uint8') spm_platform('bigend')]);
                spm_write_vol(ROIa,ROIB{r}==nclusters);
                txt{end+1}=['OUTPUT ROI FILE : ',char(name_dat)];
                txt{end+1}=['LOCATION: ',params.output_folder];
                txt{end+1}=' ';
            end
        end
        rr=rr+length(rrx{r}{nclusters});
    end
    if (strcmpi(params.output_type,'save')||strcmpi(params.output_type,'savefiles'))&&~isempty(strmatch('roi.img',params.output_files,'exact')),
        name_dat=fullfile(params.output_folder,[roi_path_name,'.rex.roi.img']);
        ROIa=struct('fname',name_dat,'mat',ROIA{r}.mat,'dim',ROIA{r}.dim);
        %ROIa.fname=name_dat;
        maxa=max(ROIB{r}(:));
        if maxa<=spm_type('uint8','maxval'),ROIa.dt=[spm_type('uint8') spm_platform('bigend')];
        elseif maxa<=spm_type('int16','maxval'),ROIa.dt=[spm_type('int16') spm_platform('bigend')];
        elseif maxa<=spm_type('int32','maxval'),ROIa.dt=[spm_type('int32') spm_platform('bigend')];
        else, ROIa.dt=[spm_type('float64') spm_platform('bigend')];end
        spm_write_vol(ROIa,ROIB{r});
        tROInames=cell(1,length(XYZMM{r}));
        for nclusters=1:length(XYZMM{r}),
            tROInames{nclusters}=roi_path_name;
            if iscell(XYZnames{r})&&length(XYZnames{r})>=nclusters, tROInames{nclusters}=[tROInames{nclusters},'.',XYZnames{r}{nclusters}];
            elseif length(XYZMM{r})>1, tROInames{nclusters}=[tROInames{nclusters},'.cluster',num2str(XYZNN{r}(nclusters),'%03d')]; end
        end
        name_dat=fullfile(params.output_folder,[roi_path_name,'.rex.roi.txt']);
        h=fopen(name_dat,'wt');
        for n1=1:length(tROInames),fprintf(h,'%s\n',tROInames{n1});end
        fclose(h);
        txt{end+1}=['OUTPUT ROI FILE : ',char(name_dat)];
        txt{end+1}=['LOCATION: ',params.output_folder];
        txt{end+1}=' ';
    end
end

if ~silence,
    params.ROIdata=ROIdata;params.ROInames=ROInames;params.ROIinfo.basis=ROIbasis;params.ROIinfo.voxels=ROIvoxels;params.ROIinfo.files=ROIfiles;params.ROIinfo.select=ROIselect;params.ROIinfo.trans=ROItrans;
    msgbox(txt,'REX output');
    rex_display(params);
end
if ~silence,disp(strvcat(txt{:}));end
varargout={ROIdata,ROInames,ROIbasis,ROIvoxels,ROIfiles,ROIselect,ROItrans};
return;



% READS ROI FILES
function [XYZMM,XYZWW,XYZidx,XYZnames,a,B]=rex_image(roi_path,level,type,select,selected,mindist,maxpeak,dims,threshold)
[roi_path_dir,roi_path_name,roi_path_ext,roi_path_num]=spm_fileparts(roi_path);
if isempty(roi_path_num), roi_path_num=[];
else roi_path_num=str2num(regexprep(roi_path_num,'\D',''));
end
switch(lower(type)),
    case 'text',
        XYZmm = spm_load(roi_path)';
        if size(XYZmm,1)~=3, error('The .tal mask file should have 3 columns (x,y,z locations in mm).');end
        XYZww=ones(1,size(XYZmm,2));
        res=2;
        a.mat=[res*[1,0,0,-1;0,1,0,-1;0,0,1,-1];[0,0,0,1]];
        xyz=pinv(a.mat)*[XYZmm;ones(1,size(XYZmm,2))];
        xyz=round(xyz(1:3,:));
        b=zeros((max(xyz,[],2)-min(xyz,[],2)+1)');
        a.dim=size(b);
        if numel(a.dim)<3, a.dim=[a.dim ones(1,3-numel(a.dim))]; end
        a.mat(:,4)=[min(XYZmm,[],2)-diag(a.mat(1:3,1:3));1];
        xyz=xyz-repmat(min(xyz,[],2),[1,size(xyz,2)])+1;
        idxvoxels=sub2ind(size(b),xyz(1,:),xyz(2,:),xyz(3,:));
        b(idxvoxels)=1;
        C=[];x_rep=0;
        XYZnames=[];
    case 'image',
        a=spm_vol(roi_path);
        if isempty(a), error('Unable to open %s',roi_path); end
        try, roi_path_tot=a.private.dat.dim(4); 
        catch, roi_path_tot=1;
        end
        if roi_path_tot==1, roi_path_num=[]; end
        [gridx,gridy,gridz]=ndgrid(1:a.dim(1),1:a.dim(2),1:a.dim(3));
        xyz=[gridx(:),gridy(:),gridz(:)]';%,ones(numel(gridx),1)]'; 
        b=reshape(spm_get_data(a,xyz),a.dim);
        %b=spm_read_vols(a);
        idxvoxels=find(abs(b)>threshold&~isnan(b));
        XYZww=b(idxvoxels)';
        xyz=xyz(:,idxvoxels);
%         [xt,yt,zt]=ind2sub(a.dim,idxvoxels);
%         xyz=[xt,yt,zt]';
        [ub,nill,iub]=unique(b(idxvoxels));
        if isempty(roi_path_num)&&length(ub)>1&&(~isempty(dir(fullfile(roi_path_dir,[roi_path_name,'.txt'])))||~isempty(dir(fullfile(roi_path_dir,[roi_path_name,'.csv'])))||~isempty(dir(fullfile(roi_path_dir,[roi_path_name,'.xls'])))),%&&all(abs(ub-round(ub))<1e-1),
            x_rep=1;
        elseif isempty(roi_path_num)&&length(ub)>1&&all(ub==round(ub))&&all(ub>=0)
            x_rep=1;
        else C=[];x_rep=0;end;
        try
            if ~isempty(roi_path_num)&&~isempty(dir(fullfile(roi_path_dir,[roi_path_name,'.txt']))),
                XYZnames=textread(fullfile(roi_path_dir,[roi_path_name,'.txt']),'%s','delimiter','\n'); % sorted list of labels .txt format (ROI_LABEL)
                if numel(XYZnames)~=roi_path_tot, fprintf('Warning: file %s format not recognized\n number of lines in .txt labels file = %d, number of volumes in nifti image file = %d\n',fullfile(roi_path_dir,[roi_path_name,'.txt']),length(XYZnames),roi_path_tot); end
                XYZnames=XYZnames(roi_path_num);
                C=ones(1,numel(idxvoxels));
            elseif x_rep && ~isempty(dir(fullfile(roi_path_dir,[roi_path_name,'.txt']))),
                XYZnames=textread(fullfile(roi_path_dir,[roi_path_name,'.txt']),'%s','delimiter','\n'); % sorted list of labels .txt format (ROI_LABEL)
                if length(XYZnames)~=max(round(ub)),
                    [id,PU]=textread(fullfile(roi_path_dir,[roi_path_name,'.txt']),'%s%s%*[^\n]','delimiter',' \t'); % FreeSurfer *LUT.txt or equivalent format (ROI_NUMBER ROI_LABEL)
                    id0=str2double(id);
                    idxnull=find(isnan(id0));
                    if ~numel(idxnull)||numel(strmatch('#',id(idxnull)))==numel(idxnull)
                        idxvalid=find(~isnan(id0));
                        id=id0(idxvalid);
                        PU=PU(idxvalid);
                        b=round(b);ub=round(ub);%XYZww=round(XYZww);C=XYZww';
                        XYZnames=cell(1,numel(ub));
                        for nub=1:numel(ub),
                            nid1=find(id==ub(nub),1);
                            if ~isempty(nid1), XYZnames{nub}=deblank(PU{nid1});
                            else XYZnames{nub}=['undefined-',num2str(ub(nub))];end
                        end
                        b(idxvoxels)=iub;ub=(1:numel(ub))';XYZww=b(idxvoxels)';C=XYZww';
                    else
                        fprintf('Warning: file %s format not recognized\n number of lines in .txt labels file = %d, maximum ROI index in nifti image file = %d (this is not a [ROI_LABEL] format .txt file)\n number of lines not starting with a number = %d, number of commented lines = %d (this is not a [ROI_NUMBER ROI_LABEL] or FreeSurfer format .txt file)\n',fullfile(roi_path_dir,[roi_path_name,'.txt']),length(XYZnames),max(round(ub)),numel(idxnull),numel(strmatch('#',id(idxnull))));
                        XYZnames=[];
                        C=[];x_rep=0;
                    end
                else
                    b=round(b);ub=round(ub);XYZww=round(XYZww);C=XYZww';
                end
            elseif x_rep && (~isempty(dir(fullfile(roi_path_dir,[roi_path_name,'.csv'])))||~isempty(dir(fullfile(roi_path_dir,[roi_path_name,'.xls'])))), 
                if ~isempty(dir(fullfile(roi_path_dir,[roi_path_name,'.csv'])))
                    try
                        [PU,id,nill]=textread(fullfile(roi_path_dir,[roi_path_name,'.csv']),'%s%d%d','delimiter',',','headerlines',1); % ROI_LABEL,ROI_NUMBER = SLT format (label,ID,... .csv/.xls) 
                    catch
                        [id,PU]=textread(fullfile(roi_path_dir,[roi_path_name,'.csv']),'%d%s','delimiter',',','headerlines',1); % ROI_NUMBER,ROI_LABEL
                    end
                else
                    [idxpairs,PU]=xlsread(fullfile(roi_path_dir,[roi_path_name,'.xls'])); % ROI_NUMBER,ROI_LABEL
                    if size(PU,1)==size(idxpairs,1), PU=PU(:,1);id=idxpairs(:,1);
                    elseif size(PU,1)==size(idxpairs,1)+1, PU=PU(2:end,1);id=idxpairs(:,1);
                    else disp(['file ',fullfile(roi_path_dir,[roi_path_name,'.xls']),' format not recognized']); error(''); end
                end
                b=round(b);ub=round(ub);%XYZww=round(XYZww);C=XYZww';
                anyid32000=any(ub>32000);
                if anyid32000, anyid32prefix={'Right','Left'}; else anyid32prefix={'',''}; end
                XYZnames=cell(1,numel(ub));
                for nub=1:numel(ub),
                    nid1=find(id==ub(nub),1);
                    if ~isempty(nid1), XYZnames{nub}=[anyid32prefix{1},deblank(PU{nid1})];
                    elseif anyid32000, nid2=find(id==ub(nub)-32000,1);if ~isempty(nid2), XYZnames{nub}=[anyid32prefix{2},deblank(PU{nid2})];else XYZnames{nub}='';end
                    else XYZnames{nub}=''; end
                end
                b(idxvoxels)=iub;ub=(1:numel(ub))';XYZww=b(idxvoxels)';C=XYZww';
            else
                if x_rep
                    b=round(b);ub=round(ub);XYZww=round(XYZww);C=XYZww';
                end
                XYZnames=[];
            end
            if iscell(XYZnames)&&~isempty(XYZnames), % resolves repeated ROI names
                [u_XYZnames,nill,j_XYZnames]=unique(XYZnames);
                if numel(u_XYZnames)<numel(XYZnames)
                    for n1=1:numel(u_XYZnames),
                        idx=find(j_XYZnames==n1);
                        if numel(idx)>1
                            XYZnames(idx)=arrayfun(@(n)[XYZnames{idx(n)},num2str(n)],1:numel(idx),'uni',0);
                        end
                    end
                end
            end
        catch
            fprintf('Warning: potential problem interpreting ROI-label file %s. Assuming non-labeled ROI file',fullfile(roi_path_dir,[roi_path_name,'.txt']));
            C=[];x_rep=0;XYZnames={};
        end
    otherwise
        error('unsupported type %s',type);
end
if isempty(xyz), XYZMM={};XYZWW={};XYZidx=[];XYZnames={}; a=[]; B=[]; return; end
if isempty(C), C=spm_clusters(max(1,round(xyz)));end; % C: cluster per voxel;
c=hist(C,1:max(C)); % c: #voxels per clusters
txt=[];xyzpeak={};
XYZidx=find(c>0);
idxn=[];idx2={};for n1=1:length(XYZidx),idx2{n1}=find(C(:)==(XYZidx(n1))); idxn(n1)=length(idx2{n1}); end
if ~x_rep, [nill,sidxn]=sort(idxn(:));sidxn=flipud(sidxn); else, sidxn=(1:length(idxn))'; end
xyzpeak=cell(1,length(XYZidx));
%clusters=cell(1,length(XYZidx));
k=zeros(1,length(XYZidx));
for n1=1:length(XYZidx),
    k(n1)=idxn(sidxn(n1));
    %clusters{n1}=idxvoxels(idx2{sidxn(n1)});
    temp=XYZww(idx2{sidxn(n1)});idxtemp=find(temp==max(temp));xyzpeak{n1}=mean(xyz(:,idx2{sidxn(n1)}(idxtemp)),2)';
end
if isempty(XYZnames),
    for n1=1:length(XYZidx),
        txt=strvcat(txt,[...
            ['( ',sprintf('%+03.0f ',(a.mat(1:3,:)*[xyzpeak{n1}(1:3)';1])'),') '],...
            [sprintf('%6d voxels',k(n1))]]);
    end
else
    for n1=1:length(XYZidx),
        txt=strvcat(txt,[...
            [XYZnames{XYZidx(sidxn(n1))},'  ( ',sprintf('%+03.0f ',(a.mat(1:3,:)*[xyzpeak{n1}(1:3)';1])'),') '],...
            [sprintf('%6d voxels',k(n1))]]);
    end
end
if ~select, 
    if isempty(selected), s=1:size(txt,1);
    else s=intersect(1:size(txt,1),selected); end
elseif length(XYZidx)>1, 
    [s,v] = listdlg('PromptString',['Select cluster(s) in ',roi_path_name],...
    'SelectionMode','multiple',...
    'ListString',txt,...
    'InitialValue',1:size(txt,1),...
    'ListSize',[300,300]);
else, s=1; end
switch(lower(level)),
    case {'rois','voxels','subsetvoxels'},
        B=abs(b)>threshold;
        sidxn=sidxn(s);
        idxin=cat(1,idx2{sidxn});
        if strcmpi(level,'subsetvoxels'),idxin=idxin(round(linspace(1,length(idxin),dims)));end
        XYZWW={XYZww(:,idxin)};
        XYZMM={a.mat(1:3,:)*[xyz(:,idxin);ones(1,length(idxin))]};
        if x_rep, XYZidx=XYZidx(sidxn); else, XYZidx=s; end
        if ~isempty(XYZnames)&&length(s)==1, XYZnames={XYZnames{XYZidx}}; else, XYZnames=[]; end
        if strcmpi(level,'voxels')||strcmpi(level,'subsetvoxels'),B(shiftdim(idxvoxels(idxin)))=(1:length(idxin))';end
    case {'clusters','peaks'},
        B=zeros(size(b));
        sidxn=sidxn(s);
        for n1=1:length(s),
            idxin=cat(1,idx2{sidxn(n1)});
            XYZWW{n1}=XYZww(:,idxin);
            XYZMM{n1}=a.mat(1:3,:)*[xyz(:,idxin);ones(1,length(idxin))];
            B(idxvoxels(idx2{sidxn(n1)}))=n1;
        end
        %if ~isempty(XYZnames), XYZnames={XYZnames{sidxn}}; else, XYZnames=[]; end
        if x_rep, XYZidx=XYZidx(sidxn); else, XYZidx=s; end
        if ~isempty(XYZnames), XYZnames={XYZnames{XYZidx}}; else, XYZnames=[]; end
        if strcmpi(level,'peaks'),
            B=zeros(size(b));
            n0=1;
            for n1=1:length(s),
                peaks=0;
                if length(unique(XYZWW{n1}))>1,
                    idxvox=idx2{sidxn(n1)};
                    idxpeak=1:length(idxvox);
                    sb=[size(b,1);size(b,2);size(b,3)];
                    for n2a=-1:1,for n2b=-1:1,for n2c=-1:1,
                                offset=n2a+sb(1)*n2b+sb(1)*sb(2)*n2c;
                                idxpeak=idxpeak(all(xyz(:,idxvox(idxpeak))>1,1));
                                idxpeak=idxpeak(all(xyz(:,idxvox(idxpeak))<repmat(sb,[1,length(idxpeak)]),1));
                                idxpeak=idxpeak(b(idxvoxels(idxvox(idxpeak)))>=b(idxvoxels(idxvox(idxpeak))+offset));
                                idxpeak=idxpeak(b(idxvoxels(idxvox(idxpeak))+offset)>0);
                                if isempty(idxpeak), break; end
                            end;end;end;
                    if length(idxpeak)>1,
                        [ww,idx]=sort(-XYZWW{n1}(:,idxpeak));
                        idxmax=idx(1);
                        for n2=2:length(idx),
                            if min(sqrt(sum(abs(XYZMM{n1}(:,idxpeak(idx(n2)))*ones(1,length(idxmax))-XYZMM{n1}(:,idxpeak(idxmax))).^2,1)))>mindist,
                                idxmax=[idxmax,idx(n2)];
                                if length(idxmax)>=maxpeak, break; end
                            end
                        end
                        idxmax=idxpeak(idxmax);
                        if length(idxmax)>1,
                            d=zeros([length(idxmax),size(XYZMM{n1},2)]);
                            for n2=1:length(idxmax),d(n2,:)=sqrt(sum(abs(XYZMM{n1}(:,idxmax(n2))*ones(1,size(XYZMM{n1},2))-XYZMM{n1}).^2,1));end
                            [nill,idxc]=min(d,[],1);
                            for n2=1:length(idxmax),
                                idxd=find(idxc==n2);
                                if ~isempty(idxd),
                                    B(idxvoxels(idx2{sidxn(n1)}(idxd)))=n0;
                                    XYZMMnew{n0}=XYZMM{n1}(:,idxd);
                                    XYZWWnew{n0}=XYZWW{n1}(:,idxd);
                                    XYZidxnew(n0)=n0;%XYZidx(n1);
                                    if ~isempty(XYZnames), XYZnamesnew{n0}=[XYZnames{n1},'.',char('a'-1+n2)]; end
                                    n0=n0+1;
                                end
                            end
                            peaks=1;
                        end
                    end
                end
                if ~peaks,
                    B(idxvoxels(idx2{sidxn(n1)}))=n0;
                    XYZMMnew{n0}=XYZMM{n1};
                    XYZWWnew{n0}=XYZWW{n1};
                    XYZidxnew(n0)=n0;%XYZidx(n1);
                    if ~isempty(XYZnames), XYZnamesnew{n0}=XYZnames{n1}; end
                    n0=n0+1;
                end
            end
            XYZMM=XYZMMnew;
            XYZWW=XYZWWnew;
            XYZidx=XYZidxnew;
            if ~isempty(XYZnames), XYZnames=XYZnamesnew; end
        end
end
%[XYZMM,XYZWW,XYZidx,XYZnames]

% ESTIMATES GENERAL LINEAR MODEL IN SPM
function [beta,ResMS]=rex_modelestimate(xX,Y)
[nScan nBeta] = size(xX.X);
KWY   = spm_filter(xX.K,xX.W*Y);
beta  = xX.pKX*KWY;                  %-Parameter estimates
res   = spm_sp('r',xX.xKXs,KWY);     %-Residuals
ResSS = sum(res.^2);                 %-Residual SSQ
ResMS=ResSS/xX.trRV;

% ESTIMATES CONTRAST IN SPM
function [cbeta,CI,T,p,P,dof]=rex_test(xX,Y,c,fig,effnames,roinames,s,ROIinfo)
try
    [beta,ResMS]=rex_modelestimate(xX,Y);
    cbeta=c'*beta;
    SE=sqrt(diag(c'*xX.Bcov*c)*ResMS);
    dof=xX.erdf;
    T=cbeta./SE;
    p=nan+zeros(size(T));idxvalidT=find(~isnan(T));p(idxvalidT)=1-spm_Tcdf(T(idxvalidT),dof);
catch
    [cbeta,T,p,dof]=conn_glm(xX.X,reshape(Y,size(xX.X,1),[],size(Y,2)),c,[],'AA');
    cbeta=reshape(cbeta,[],size(cbeta,3));
    T=reshape(T,[],size(T,3));
    p=reshape(p,[],size(p,3));
    SE=cbeta./T;
end
CI=spm_invTcdf(.95,dof)*SE;
if 1, %size(cbeta,1)>1, % two-sided
    p=2*min(p,1-p); 
end 
P=fdr(p,2);
[nill,idxROIs]=sort(p(:));
if nargin>3,
    roinames=regexprep(roinames,'^results\.ROIs\.','');
    hfig=figure('units','norm','position',[.41,.1,.55,.8],'name','REX results','numbertitle','off','color','w');
    subplot(411);
    if size(cbeta,1)>1,
        dx=size(cbeta,2)/(numel(cbeta)+.5*size(cbeta,2));
        xx=1*repmat((1:size(cbeta,2)),[size(cbeta,1),1])+repmat((-(size(cbeta,1)-1)/2:(size(cbeta,1)-1)/2)'*dx,[1,size(cbeta,2)]);
    else
        dx=size(cbeta,1)/(numel(cbeta)+.5*size(cbeta,1));
        xx=1*repmat((1:size(cbeta,1))',[1,size(cbeta,2)])+repmat((-(size(cbeta,2)-1)/2:(size(cbeta,2)-1)/2)*dx,[size(cbeta,1),1]);
    end
    color=get(gca,'colororder');
    color(all(~color,2),:)=[];%xxd=.4/size(cbeta,2)/2;
    for n1=1:numel(xx),
        if size(cbeta,1)>1, color0=color(1+rem(rem(n1-1,size(cbeta,1)),size(color,1)),:);
        else  color0=color(1+rem(ceil(n1/size(cbeta,1))-1,size(color,1)),:);
        end
        h=patch(xx(n1)+dx*[-1,-1,1,1]/2,cbeta(n1)*[0,1,1,0],'k','facecolor',1-(1-color0)/2,'edgecolor','none'); 
        set(h,'buttondownfcn',{@rex_results_gui,'plot',n1});
        if P(n1)<=.05, set(h,'facecolor',color0); end
        h=line(xx(n1)+[1,-1,0,0,1,-1]*dx/8,cbeta(n1)+CI(n1)*[-1,-1,-1,1,1,1],[1,1,1,1,1,1],'linewidth',2,'color',1-(1-color0)/2); 
        if P(n1)<=.05, set(h,'color','k'); 
        elseif p(n1)<=.05, set(h,'color',1-(1-color0)/1); 
        end
    end
    hold on; plot([.5,size(cbeta,1)+.5],[0,0],'k-');hold off; hh=gca;
    set(hh,'units','norm','position',[.15 .6 .7 .3]);
    if ~iscell(effnames)||numel(effnames)~=size(cbeta,1), 
        if isfield(xX,'Xnames')&&numel(xX.Xnames)*numel(effnames)==size(cbeta,1)&&isequal(c,eye(numel(xX.Xnames))), effnames=repmat(effnames(:)',size(cbeta,1)/numel(effnames),1); for n1=1:size(effnames,1), effnames(n1,:)=regexprep(effnames(n1,:),'.*',[xX.Xnames{n1},' $0']); end
        elseif rem(size(cbeta,1),numel(effnames))==0, effnames=repmat(effnames(:)',size(cbeta,1)/numel(effnames),1); for n1=1:size(effnames,1), effnames(n1,:)=regexprep(effnames(n1,:),'.*',['contrast',num2str(n1),' $0']); end
        elseif isfield(xX,'name')&&numel(xX.name)==size(cbeta,1)&&isequal(c,eye(size(cbeta,1))), effnames=xX.name;
        else effnames=arrayfun(@(n)['measure ',num2str(n)],1:size(cbeta,1),'uni',0);
        end
    end
    if size(cbeta,1)>1
        ylabel('Effect sizes'); 
        %set(hh,'xaxislocation','top','xtick',1:size(cbeta,2),'xticklabel',roinames,'xlim',[min(xx(:))-dx,max(xx(:))+dx],'ylim',[min(0,min(cbeta(:)-CI(:)))-1e-4,max(0,max(cbeta(:)+CI(:)))+1e-4]*[1.1,-.1;-.1,1.1],'xcolor','c','ycolor','c');
        set(hh,'xaxislocation','top','xtick',[],'xlim',[min(xx(:))-dx,max(xx(:))+dx],'ylim',[min(0,min(cbeta(:)-CI(:)))-1e-4,max(0,max(cbeta(:)+CI(:)))+1e-4]*[1.1,-.1;-.1,1.1],'xcolor','w','ycolor','c');
        h=text(1:size(cbeta,2),zeros(1,size(cbeta,2))+get(hh,'ylim')*[-.05;1.05],roinames);
        if numel(roinames)<=2, set(h,'horizontalalignment','center','color','k','interpreter','none','fontsize',10);
        else set(h,'horizontalalignment','left','rotation',10,'color','k','interpreter','none','fontsize',10);
        end
        for n1=1:numel(xx),
            color0=color(1+rem(rem(n1-1,size(cbeta,1)),size(color,1)),:);
            h=text(xx(n1),min(get(hh,'ylim'))-abs(diff(get(hh,'ylim')))*.05,effnames{1+rem(n1-1,size(cbeta,1))});
            set(h,'rotation',-45,'fontsize',10,'color',1-(1-color0)/1,'interpreter','none','buttondownfcn',{@rex_results_gui,'plot',n1});
        end
    else
        ylabel('Effect sizes'); 
        %set(hh,'xaxislocation','top','xtick',1:size(cbeta,1),'xticklabel',effnames,'xlim',[min(xx(:))-dx,max(xx(:))+dx],'ylim',[min(0,min(cbeta(:)-CI(:)))-1e-4,max(0,max(cbeta(:)+CI(:)))+1e-4]*[1.1,-.1;-.1,1.1],'xcolor','c','ycolor','c');
        set(hh,'xaxislocation','top','xtick',[],'xlim',[min(xx(:))-dx,max(xx(:))+dx],'ylim',[min(0,min(cbeta(:)-CI(:)))-1e-4,max(0,max(cbeta(:)+CI(:)))+1e-4]*[1.1,-.1;-.1,1.1],'xcolor','w','ycolor','c');
        h=text(1:size(cbeta,1),zeros(1,size(cbeta,1))+get(hh,'ylim')*[-.05;1.05],effnames);
        if numel(effnames)<=2, set(h,'horizontalalignment','center','color','k','interpreter','none','fontsize',10);
        else set(h,'horizontalalignment','left','rotation',10,'color','k','interpreter','none','fontsize',10);
        end
        %for n1=1:numel(xx),color0=color(1+rem(ceil(n1/size(cbeta,1))-1,size(color,1)),:);h=text(xx(n1),min(get(hh,'ylim'))-abs(diff(get(hh,'ylim')))*.05,roinames{ceil(n1/size(cbeta,1))}); set(h,'rotation',-90,'fontsize',8,'color',1-(1-color0)/2,'interpreter','none','buttondownfcn',{@rex_results_gui,'plot',n1}); if P(n1)<=.05, set(h,'color',color0); end; end
        for n1=1:size(xx,1):numel(xx),
            color0=color(1+rem(ceil(n1/size(cbeta,1))-1,size(color,1)),:);
            h=text(xx(n1),min(get(hh,'ylim'))-abs(diff(get(hh,'ylim')))*.05,roinames{ceil(n1/size(cbeta,1))});
            set(h,'rotation',-45,'fontsize',10,'color',1-(1-color0)/1,'interpreter','none','buttondownfcn',{@rex_results_gui,'plot',n1});
        end %if P(n1)<=.05, set(h,'color',color0); end; end
    end
    for n1=1:numel(xx),htick(n1)=line([xx(n1),xx(n1)],get(hh,'ylim'),[1,1]);set(htick(n1),'linestyle',':','color','k','visible','off');end 
    uicontrol('style','text','units','norm','position',[.05,.40,.9,.025],'string',sprintf('%-64s%10s%10s%12s%12s','ROI','beta','T','p-unc','p-FDR'),'backgroundcolor','w','foregroundcolor','b','horizontalalignment','left','fontname','monospaced','fontsize',8);
    txt={};
    for n1=1:numel(cbeta),
        tmproinames=roinames{ceil(n1/size(cbeta,1))};
        if size(cbeta,1)>1, 
            if size(cbeta,1)==numel(effnames), tmproinames=[tmproinames,' ',effnames{1+rem(n1-1,size(cbeta,1))}];
            else tmproinames=['m',num2str(1+rem(n1-1,size(cbeta,1))),'.',tmproinames]; 
            end
        end
        if length(tmproinames)>64,tmproinames=[tmproinames(1:61),'...'];end; 
        txt{n1}=[[sprintf('%-64s',tmproinames)],[sprintf('%10.2f',cbeta(n1))],[sprintf('%10.2f',T(n1))],[sprintf('%12f',p(n1))],[sprintf('%12f',P(n1))]]; 
    end
    txt=char(txt(idxROIs));
    txt=strvcat(txt,' ');
    hax=axes('units','norm','position',[.70,.0,.25,.25],'visible','off');
    hl=uicontrol('style','listbox','units','norm','position',[.05,.25,.9,.15],'string',txt,'backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','fontname','monospaced','fontsize',8,'callback',{@rex_results_gui,'list'});
    axes('units','norm','position',[.1,.1,.55,.125]);
    for n1=1:size(Y,2), hplot2(n1)=plot(Y(:,n1),'k.-','color',.5*[1,1,1],'markeredgecolor',0*[1,1,1]); hold on; end; hold off; 
    set(gca,'xlim',[.5,size(Y,1)+.5],'ylim',[min(Y(:))-1e-2,max(Y(:))+1e-2]);
    set(gca,'xcolor','c','ycolor','c');xlabel('volumes/scans');ylabel('data');
    set(hfig,'userdata',struct('hplot',htick,'hplot2',hplot2,'haxes',hax,'hlist',hl,'s',s,'ROIinfo',ROIinfo,'block',size(cbeta,1),'idxROIs',idxROIs));
    rex_results_gui(hfig,[],'init');
end

function rex_results_gui(varargin);
if strcmp(varargin{3},'init'), dataobj=get(varargin{1},'userdata'); else, dataobj=get(gcbf,'userdata'); end
switch(varargin{3}),
    case {'list','init'}
        idx=get(dataobj.hlist,'value');
        if isfield(dataobj,'idxROIs')&&idx<=numel(dataobj.idxROIs), idx=dataobj.idxROIs(idx); end
    case 'plot',
        idx=varargin{4};
        if isfield(dataobj,'idxROIs')&&any(idx==dataobj.idxROIs), 
            set(dataobj.hlist,'value',find(dataobj.idxROIs==idx,1));
        else
            set(dataobj.hlist,'value',idx);
        end
end
set(dataobj.hplot,'visible','off');
set(dataobj.hplot2,'visible','off');
if all(idx<=length(dataobj.hplot)&idx>0),
    set(dataobj.hplot(idx),'visible','on');
    set(dataobj.hplot2(ceil(idx/dataobj.block)),'visible','on');
    idx=dataobj.s(ceil(idx/dataobj.block));
    Z=dataobj.ROIinfo.basis{dataobj.ROIinfo.trans{idx}{1}}{dataobj.ROIinfo.trans{idx}{2}}(dataobj.ROIinfo.trans{idx}{4},dataobj.ROIinfo.trans{idx}{3});
    XYZ=dataobj.ROIinfo.voxels{dataobj.ROIinfo.trans{idx}{1}}{dataobj.ROIinfo.trans{idx}{2}}(dataobj.ROIinfo.trans{idx}{4},:);
    
    mip=load('MIP.mat');if isfield(mip,'mask_all'), mip=1+mip.mask_all; else mip=1+mip.mip96; end
    if length(unique(Z))==1, Z=2+zeros(size(Z));
    else, Z=2+Z/max(abs(Z)); end
    d=spm_project(Z',round(XYZ'),[2,2,2,size(mip)]);
    idx=find(d~=0);mip(idx)=round(34.5+31.5*(d(idx)-2));
    axes(dataobj.haxes);
    image(rot90(mip));axis equal;axis tight;axis off;colormap([1*ones(1,3);.8*ones(1,3);jet(64)]);
    set(gcbf,'currentobject',dataobj.hlist);
    %M=[2,0,0,-92;0,2,0,-128;0,0,2,-74;0,0,0,1];
    %axes(dataobj.haxes);
    %spm_mip([Z',0],[XYZ',zeros(3,1)],M,{'mm' 'mm' 'mm'});axis equal;
else,
    axes(dataobj.haxes);
    cla;
end


function [V,filenames] = rex_vol(filenames,spm_ver)
filenames2=[];filename_path=[];
for n1=1:size(filenames,1),
    [filenames_path,filenames_name,filenames_ext,filenames_num]=spm_fileparts(deblank(filenames(n1,:)));
    filename=fullfile(filenames_path,[filenames_name,filenames_ext]);
    if isempty(dir(filename)),
        if spm_ver<=2,     filename=spm_get(1,'image',['Select file ',filenames_name,filenames_ext,filenames_num]);
        else,              filename=spm_select(1,'image',['Select file ',filenames_name,filenames_ext,filenames_num],{},filename_path); end
    else filename=deblank(filenames(n1,:)); end
    filenames2=strvcat(filenames2,filename);
end
V=spm_vol(filenames2);

% spm_graph function in SPM8 modified to handle ROI data
function [Y,y,beta,Bcov] = spm_graph(y,beta,ResMS,SPM,Fgraph)

%-Plot
%==========================================================================

% find out what to plot
%--------------------------------------------------------------------------
Cplot = {   'Contrast estimates and 90% C.I.',...
            'Fitted responses',...
            'Event-related responses',...
            'Parametric responses',...
            'Volterra Kernels'};


% ensure options are appropriate
%--------------------------------------------------------------------------
try
    Sess  = SPM.Sess;
catch
    Cplot = Cplot(1:2);
end
%Cplot  = Cplot{spm_input('Plot',-1,'m',Cplot)};
Cplot  = Cplot{spm_input('Plot','!+1','m',Cplot)};

switch Cplot

    % select contrast if
    %----------------------------------------------------------------------
    case {'Contrast estimates and 90% C.I.','Fitted responses'}

        % determine which contrast
        %------------------------------------------------------------------
        Ic    = spm_input('Which contrast?','!+1','m',{SPM.xCon.name});
        TITLE = {Cplot SPM.xCon(Ic).name};
        %if xSPM.STAT == 'P'
        %    TITLE = {Cplot SPM.xCon(Ic).name '(conditional estimates)'};
        %end


        % select session and trial if
        %------------------------------------------------------------------
    case {'Event-related responses','Parametric responses','Volterra Kernels'}

        % get session
        %------------------------------------------------------------------
        s     = length(Sess);
        if  s > 1
            s = spm_input('which session','+1','n1',1,s);
        end

        % effect names
        %------------------------------------------------------------------
        switch Cplot
            case 'Volterra Kernels'
                u = length(Sess(s).Fc);
            otherwise
                u = length(Sess(s).U);
        end
        Uname = {};
        for i = 1:u
            Uname{i} = Sess(s).Fc(i).name;
        end

        % get effect
        %------------------------------------------------------------------
        str   = sprintf('which effect');
        u     = spm_input(str,'+1','m',Uname);

        % bin size
        %------------------------------------------------------------------
        dt    = SPM.xBF.dt;

end

spm('pointer','watch');

%-Extract filtered and whitened data from files
%==========================================================================
try
    %y = spm_get_data(SPM.xY.VY,XYZ);
    y = spm_filter(SPM.xX.K,SPM.xX.W*y);
catch
    % data has been moved or renamed
    %------------------------------------------------------------------
    y = [];
    spm('alert!',{'Original data have been moved or renamed',...
        'Recomendation: please update SPM.xY.P'},...
        mfilename,0);
end
XYZstr = '';%sprintf(' at [%g, %g, %g]',xyz);


%-Compute residuals
%-----------------------------------------------------------------------
if isempty(y)

    % make R = NaN so it will not be plotted
    %----------------------------------------------------------------------
    R   = NaN*ones(size(SPM.xX.X,1),1);

else
    % residuals (non-whitened)
    %----------------------------------------------------------------------
    R   = spm_sp('r',SPM.xX.xKXs,y);

end

%-Get parameter and hyperparameter estimates
%==========================================================================
%if xSPM.STAT ~= 'P'

    %-Parameter estimates:   beta = xX.pKX*xX.K*y;
    %-Residual mean square: ResMS = sum(R.^2)/xX.trRV
    %----------------------------------------------------------------------
    %beta  = spm_get_data(SPM.Vbeta, XYZ);
    %ResMS = spm_get_data(SPM.VResMS,XYZ);
    Bcov  = ResMS*SPM.xX.Bcov;

% else
%     % or conditional estimates with
%     % Cov(b|y) through Taylor approximation
%     %----------------------------------------------------------------------
%     beta  = spm_get_data(SPM.VCbeta, XYZ);
% 
%     if isfield(SPM.PPM,'VB');
%         % Get approximate posterior covariance at ic
%         % using Taylor-series approximation
% 
%         % Get posterior SD beta's
%         Nk=size(SPM.xX.X,2);
%         for k=1:Nk,
%             sd_beta(k,:) = spm_get_data(SPM.VPsd(k),XYZ);
%         end
% 
%         % Get AR coefficients
%         nsess=length(SPM.Sess);
%         for ss=1:nsess,
%             for p=1:SPM.PPM.AR_P
%                 Sess(ss).a(p,:) = spm_get_data(SPM.PPM.Sess(ss).VAR(p),XYZ);
%             end
%             % Get noise SD
%             Sess(ss).lambda = spm_get_data(SPM.PPM.Sess(ss).VHp,XYZ);
%         end
% 
%         % Which block are we in ?
%         % this needs updating s.t xSPM contains labels of selected voxels
%         v = find((SPM.xVol.XYZ(1,:)==XYZ(1))&(SPM.xVol.XYZ(2,:)==XYZ(2))&(SPM.xVol.XYZ(3,:)==XYZ(3)));
%         block_index = SPM.xVol.labels(v);
%         Bcov=zeros(Nk,Nk);
%         for ss=1:nsess,
%             % Reconstuct approximation to voxel wise correlation matrix
%             post_R=SPM.PPM.Sess(ss).block(block_index).mean.R;
%             if SPM.PPM.AR_P > 0
%                 dh=Sess(ss).a(:,1)'-SPM.PPM.Sess(ss).block(block_index).mean.a;
%             else
%                 dh=[];
%             end
%             dh=[dh Sess(ss).lambda(1)-SPM.PPM.Sess(ss).block(block_index).mean.lambda];
%             for i=1:length(dh),
%                 post_R=post_R+SPM.PPM.Sess(ss).block(block_index).mean.dR(:,:,i)*dh(i);
%             end
%             % Get indexes of regressors specific to this session
%             scol=SPM.Sess(ss).col;
%             mean_col_index=SPM.Sess(nsess).col(end)+ss;
%             scol=[scol mean_col_index];
% 
%             % Reconstuct approximation to voxel wise covariance matrix
%             Bcov(scol,scol) = Bcov(scol,scol) + (sd_beta(scol,1)*sd_beta(scol,1)').*post_R;
%         end
% 
%     else
%         Bcov  = SPM.PPM.Cby;
%         for j = 1:length(SPM.PPM.l)
% 
%             l    = spm_get_data(SPM.VHp(j),XYZ);
%             Bcov = Bcov + SPM.PPM.dC{j}*(l - SPM.PPM.l(j));
%         end
%     end
% end
CI    = 1.6449;                 % = spm_invNcdf(1 - 0.05);

spm('pointer','arrow');

%-Colour specifications and index;
%--------------------------------------------------------------------------
Col   = [0 0 0; .8 .8 .8; 1 .5 .5];

switch Cplot

    % plot parameter estimates
    %----------------------------------------------------------------------
    case 'Contrast estimates and 90% C.I.'

        % compute contrast of parameter estimates and 90% C.I.
        %------------------------------------------------------------------
        cbeta = SPM.xCon(Ic).c'*beta;
        SE    = sqrt(diag(SPM.xCon(Ic).c'*Bcov*SPM.xCon(Ic).c));
        CI    = CI*SE;

        contrast.contrast      = cbeta;
        contrast.standarderror = SE;
        contrast.interval      = 2*CI;
        assignin('base','contrast',contrast)

        % bar chart
        %------------------------------------------------------------------
        figure(Fgraph)
        subplot(2,1,2)
        cla
        hold on

        % estimates
        %------------------------------------------------------------------
        h     = bar(cbeta);
        set(h,'FaceColor',Col(2,:))

        % standard error
        %------------------------------------------------------------------
        for j = 1:length(cbeta)
            line([j j],([CI(j) 0 - CI(j)] + cbeta(j)),...
                'LineWidth',6,'Color',Col(3,:))
        end

        title(TITLE,'FontSize',12)
        xlabel('contrast')
        ylabel(['contrast estimate',XYZstr])
        set(gca,'XLim',[0.4 (length(cbeta) + 0.6)])
        hold off

        % set Y to empty so outputs are assigned
        %------------------------------------------------------------------
        Y = [];

        % all fitted effects or selected effects
        %------------------------------------------------------------------
    case 'Fitted responses'

        % predicted or adjusted response
        %------------------------------------------------------------------
        str   = 'predicted or adjusted response?';
        if spm_input(str,'!+1','b',{'predicted','adjusted'},[1 0]);

            % fitted (predicted) data (Y = X1*beta)
            %--------------------------------------------------------------
            Y = SPM.xX.X*SPM.xCon(Ic).c*pinv(SPM.xCon(Ic).c)*beta;
        else

            % fitted (corrected)  data (Y = X1o*beta)
            %--------------------------------------------------------------
            Y = spm_FcUtil('Yc',SPM.xCon(Ic),SPM.xX.xKXs,beta);

        end

        % adjusted data
        %------------------------------------------------------------------
        y     = Y + R;

        % get ordinates
        %------------------------------------------------------------------
        Xplot = {'an explanatory variable',...
                 'scan or time',...
                 'a user specified ordinate'};
        Cx    = spm_input('plot against','!+1','m',Xplot);

        % an explanatory variable
        %------------------------------------------------------------------
        if     Cx == 1

            str  = 'Which explanatory variable?';
            i    = spm_input(str,'!+1','m',SPM.xX.name);
            x    = SPM.xX.xKXs.X(:,i);
            XLAB = SPM.xX.name{i};

            % scan or time
            %--------------------------------------------------------------
        elseif Cx == 2

            if isfield(SPM.xY,'RT')
                x    = SPM.xY.RT*[1:size(Y,1)]';
                XLAB = 'time {seconds}';
            else
                x    = [1:size(Y,1)]';
                XLAB = 'scan number';
            end

            % user specified
            %--------------------------------------------------------------
        elseif Cx == 3

            x    = spm_input('enter ordinate','!+1','e','',size(Y,1));
            XLAB = 'ordinate';

        end

        % plot
        %------------------------------------------------------------------
        figure(Fgraph)
        subplot(2,1,2)
        cla
        hold on
        [p q] = sort(x);
        if all(diff(x(q)))
            plot(x(q),Y(q),'LineWidth',4,'Color',Col(2,:));
            plot(x(q),y(q),':','Color',Col(1,:));
            plot(x(q),y(q),'.','MarkerSize',8, 'Color',Col(3,:));

        else
            plot(x(q),Y(q),'.','MarkerSize',16,'Color',Col(1,:));
            plot(x(q),y(q),'.','MarkerSize',8, 'Color',Col(2,:));
            xlim = get(gca,'XLim');
            xlim = [-1 1]*diff(xlim)/4 + xlim;
            set(gca,'XLim',xlim)

        end
        title(TITLE,'FontSize',12)
        xlabel(XLAB)
        ylabel(['response',XYZstr])
        legend('fitted','plus error')
        hold off

        % modeling evoked responses based on Sess
        %------------------------------------------------------------------
    case 'Event-related responses'

        % get plot type
        %--------------------------------------------------------------
        Rplot   = { 'fitted response and PSTH',...
            'fitted response and 90% C.I.',...
            'fitted response and adjusted data'};

        if isempty(y)
            TITLE = Rplot{2};
        else
            TITLE = Rplot{spm_input('plot in terms of','+1','m',Rplot)};
        end

        % plot
        %------------------------------------------------------------------
        switch TITLE
            case 'fitted response and PSTH'


                % build a simple FIR model subpartition (X); bin size = TR
                %----------------------------------------------------------
                BIN         = SPM.xY.RT;
                %BIN         = max(2,BIN);
                xBF         = SPM.xBF;
                U           = Sess(s).U(u);
                U.u         = U.u(:,1);
                xBF.name    = 'Finite Impulse Response';
                xBF.order   = round(32/BIN);
                xBF.length  = xBF.order*BIN;
                xBF         = spm_get_bf(xBF);
                BIN         = xBF.length/xBF.order;
                X           = spm_Volterra(U,xBF.bf,1);
                k           = SPM.nscan(s);
                X           = X([0:(k - 1)]*SPM.xBF.T + SPM.xBF.T0 + 32,:);

                % place X in SPM.xX.X
                %----------------------------------------------------------
                jX          = Sess(s).row;
                iX          = Sess(s).col(Sess(s).Fc(u).i);
                iX0         = [1:size(SPM.xX.X,2)];
                iX0(iX)     = [];
                X           = [X SPM.xX.X(jX,iX0)];
                X           = SPM.xX.W(jX,jX)*X;
                X           = [X SPM.xX.K(s).X0];

                % Re-estimate to get PSTH and CI
                %----------------------------------------------------------
                j           = xBF.order;
                xX          = spm_sp('Set',X);
                pX          = spm_sp('x-',xX);
                PSTH        = pX*y(jX);
                res         = spm_sp('r',xX,y(jX));
                df          = size(X,1) - size(X,2);
                bcov        = pX*pX'*sum(res.^2)/df;
                PSTH        = PSTH(1:j)/dt;
                PST         = [1:j]*BIN - BIN/2;
                PCI         = CI*sqrt(diag(bcov(1:j,(1:j))))/dt;
        end



        % basis functions and parameters
        %------------------------------------------------------------------
        X     = SPM.xBF.bf/dt;
        x     = ([1:size(X,1)] - 1)*dt;
        j     = Sess(s).col(Sess(s).Fc(u).i(1:size(X,2)));
        B     = beta(j);

        % fitted responses with standard error
        %------------------------------------------------------------------
        Y     = X*B;
        CI    = CI*sqrt(diag(X*Bcov(j,j)*X'));

        % peristimulus times and adjusted data (y = Y + R)
        %------------------------------------------------------------------
        pst   = Sess(s).U(u).pst;
        bin   = round(pst/dt);
        q     = find((bin >= 0) & (bin < size(X,1)));
        y     = R(Sess(s).row(:));
        pst   = pst(q);
        y     = y(q) + Y(bin(q) + 1);



        % plot
        %------------------------------------------------------------------
        figure(Fgraph)
        subplot(2,1,2)
        hold on
        switch TITLE

            case 'fitted response and PSTH'
                %----------------------------------------------------------
                errorbar(PST,PSTH,PCI)
                plot(PST,PSTH,'LineWidth',4,'Color',Col(2,:))
                plot(x,Y,'-.','Color',Col(3,:))

            case 'fitted response and 90% C.I.'
                %----------------------------------------------------------
                plot(x,Y,'Color',Col(2,:),'LineWidth',4)
                plot(x,Y + CI,'-.',x,Y - CI,'-.','Color',Col(1,:))

            case 'fitted response and adjusted data'
                %----------------------------------------------------------
                plot(x,Y,'Color',Col(2,:),'LineWidth',4)
                plot(pst,y,'.','Color',Col(3,:))

        end


        % label
        %------------------------------------------------------------------
        [i j] = max(Y);
        text(ceil(1.1*x(j)),i,Sess(s).Fc(u).name,'FontSize',8);
        title(TITLE,'FontSize',12)
        xlabel('peristimulus time {secs}')
        ylabel(['response',XYZstr])
        hold off


        % modeling evoked responses based on Sess
        %------------------------------------------------------------------
    case 'Parametric responses'


        % return gracefully if no parameters
        %------------------------------------------------------------------
        if ~Sess(s).U(u).P(1).h, return, end

        % basis functions
        %------------------------------------------------------------------
        bf    = SPM.xBF.bf;
        pst   = ([1:size(bf,1)] - 1)*dt;

        % orthogonalised expansion of parameteric variable
        %------------------------------------------------------------------
        str   = 'which parameter';
        p     = spm_input(str,'+1','m',{Sess(s).U(u).P.name});
        P     = Sess(s).U(u).P(p).P;
        q     = [];
        for i = 0:Sess(s).U(u).P(p).h;
            q = [q spm_en(P).^i];
        end
        q     = spm_orth(q);


        % parameter estimates for this effect
        %------------------------------------------------------------------
        B     = beta(Sess(s).Fc(u).i);

        % reconstruct trial-specific responses
        %------------------------------------------------------------------
        Y     = zeros(size(bf,1),size(q,1));
        uj    = Sess(s).U(u).P(p).i;
        for i = 1:size(P,1)
            U      = sparse(1,uj,q(i,:),1,size(Sess(s).U(u).u,2));
            X      = kron(U,bf);
            Y(:,i) = X*B;
        end
        [P j] = sort(P);
        Y     = Y(:,j);

        % plot
        %------------------------------------------------------------------
        figure(Fgraph)
        subplot(2,2,3)
        surf(pst,P,Y')
        shading flat
        title(Sess(s).U(u).name{1},'FontSize',12)
        xlabel('PST {secs}')
        ylabel(Sess(s).U(u).P(p).name)
        zlabel(['responses',XYZstr])
        axis square

        % plot
        %------------------------------------------------------------------
        subplot(2,2,4)
        [j i] = max(mean(Y,2));
        plot(P,Y(i,:),'LineWidth',4,'Color',Col(2,:))
        str   = sprintf('response at %0.1fs',i*dt);
        title(str,'FontSize',12)
        xlabel(Sess(s).U(u).P(p).name)
        axis square
        grid on


        % modeling evoked responses based on Sess
        %------------------------------------------------------------------
    case 'Volterra Kernels'

        % Parameter estimates and basis functions
        %------------------------------------------------------------------
        bf    = SPM.xBF.bf/dt;
        pst   = ([1:size(bf,1)] - 1)*dt;

        % second order kernel
        %------------------------------------------------------------------
        if u > length(Sess(s).U)

            % Parameter estimates and kernel
            %--------------------------------------------------------------
            B     = beta(Sess(s).Fc(u).i);
            i     = 1;
            Y     = 0;
            for p = 1:size(bf,2)
                for q = 1:size(bf,2)
                    Y = Y + B(i)*bf(:,p)*bf(:,q)';
                    i = i + 1;
                end
            end

            % plot
            %--------------------------------------------------------------
            figure(Fgraph)
            subplot(2,2,3)
            imagesc(pst,pst,Y)
            axis xy
            axis image

            title('2nd order Kernel','FontSize',12);
            xlabel('peristimulus time {secs}')
            ylabel('peristimulus time {secs}')

            subplot(2,2,4)
            plot(pst,Y)
            axis square
            grid on

            title(Sess(s).Fc(u).name,'FontSize',12);
            xlabel('peristimulus time {secs}')


            % first  order kernel
            %--------------------------------------------------------------
        else
            B     = beta(Sess(s).Fc(u).i(1:size(bf,2)));
            Y     = bf*B;

            % plot
            %--------------------------------------------------------------
            figure(Fgraph)
            subplot(2,1,2)
            plot(pst,Y)
            grid on
            axis square

            title({'1st order Volterra Kernel' Sess(s).Fc(u).name},...
                'FontSize',12);
            xlabel('peristimulus time {secs}')
            ylabel(['impulse response',XYZstr])
        end

end


% Turn hold button off - this will alert the user to press it again
%--------------------------------------------------------------------------
%try
%    set(get(gcbo,'Userdata'),'Value',0);
%catch
%end


%-call Plot UI
%--------------------------------------------------------------------------
%spm_results_ui('PlotUi',gca)

return;




function rex_display(params);
s=1:length(params.ROInames);
hfig=figure('units','norm','position',[.41,.4,.55,.5],'name','REX display','numbertitle','off','color','w');
subplot(211);
for n1=1:size(params.ROIdata,2), hplot(n1)=plot(params.ROIdata(:,n1),'k.-','color',.5*[1,1,1],'markeredgecolor',0*[1,1,1]); hold on; end; hold off; 
set(gca,'xlim',[.5,size(params.ROIdata,1)+.5],'ylim',[min(params.ROIdata(:))-1e-2,max(params.ROIdata(:))+1e-2]);
set(gca,'xcolor','c','ycolor','c');xlabel('volumes/scans');ylabel('data');
uicontrol('style','text','units','norm','position',[.05,.475,.4,.025],'string',sprintf('%-32s','ROI'),'backgroundcolor','w','foregroundcolor','b','horizontalalignment','left','fontname','monospaced','fontsize',8);
txt=[];for n1=1:length(params.ROInames),txt=strvcat(txt,[[sprintf('%-32s',params.ROInames{n1})]]); end;txt=strvcat(txt,' ');
hax=axes('units','norm','position',[.6,.0,.3,.5],'visible','off');
hl=uicontrol('style','listbox','units','norm','position',[.05,.05,.4,.4],'string',txt,'backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','fontname','monospaced','fontsize',8,'callback',{@rex_display_gui,'list'});
set(hfig,'userdata',struct('hplot',hplot,'haxes',hax,'hlist',hl,'s',s,'ROIinfo',params.ROIinfo));
rex_display_gui(hfig,[],'init');

function rex_display_gui(varargin);
if strcmp(varargin{3},'init'), dataobj=get(varargin{1},'userdata'); else, dataobj=get(gcbf,'userdata'); end
switch(varargin{3}),
    case {'list','init'}
        idx=get(dataobj.hlist,'value');
    case 'plot',
        idx=varargin{4};
        set(dataobj.hlist,'value',idx);
end
set(dataobj.hplot,'visible','off');
if all(idx<=length(dataobj.s)&idx>0),
    set(dataobj.hplot(idx),'visible','on');
    idx=dataobj.s(idx);
    Z=dataobj.ROIinfo.basis{dataobj.ROIinfo.trans{idx}{1}}{dataobj.ROIinfo.trans{idx}{2}}(dataobj.ROIinfo.trans{idx}{4},dataobj.ROIinfo.trans{idx}{3});
    XYZ=dataobj.ROIinfo.voxels{dataobj.ROIinfo.trans{idx}{1}}{dataobj.ROIinfo.trans{idx}{2}}(dataobj.ROIinfo.trans{idx}{4},:);
    
    mip=load('MIP.mat');if isfield(mip,'mask_all'), mip=1+mip.mask_all; else mip=1+mip.mip96; end
    if length(unique(Z))==1, Z=2+zeros(size(Z));
    else, Z=2+Z/max(abs(Z)); end
    d=spm_project(Z',round(XYZ'),[2,2,2,size(mip)]);
    idx=find(d~=0);mip(idx)=round(34.5+31.5*(d(idx)-2));
    axes(dataobj.haxes);
    image(rot90(mip));axis equal;axis tight;axis off;colormap([1*ones(1,3);.8*ones(1,3);jet(64)]);
    set(gcbf,'currentobject',dataobj.hlist);
    %M=[2,0,0,-92;0,2,0,-128;0,0,2,-74;0,0,0,1];axes(dataobj.haxes);spm_mip([Z',0],[XYZ',zeros(3,1)],M,{'mm' 'mm' 'mm'});axis equal;
else,
    axes(dataobj.haxes);
    cla;
end

function q=fdr(p,dim,thr)
% CONN_FDR False discovery rate
% Q=CONN_FDR(P); returns vector Q of estimated false discovery rates (set-level q-values) from 
% a vector P of multiple-test false positive levels (uncorrected p-values)
% Q=CONN_FDR(P,dim); where P is a matrix computes the fdr along the dimension dim of P
%

if nargin<2||isempty(dim), 
    if sum(size(p)>1)==1,dim=find(size(p)>1);
    else, dim=1; end
end
nd=length(size(p)); 
if dim~=1, p=permute(p,[dim,1:dim-1,dim+1:nd]); end

sp=size(p);
q=nan(sp);
N0=sp(1);
N2=prod(sp(2:end));
if nargin>2
    [sp,idx]=sort(p,1);
    spvalid=~isnan(sp);
    N1=sum(spvalid,1);
    i=sp<=conn_bsxfun(@rdivide,thr*(1:N0)',N1);
    sp(~i)=-inf;
    q=conn_bsxfun(@le,p,max(sp,[],1));
else
    [sp,idx]=sort(p,1);
    spvalid=~isnan(sp);
    N1=sum(spvalid,1);
    for n2=find(N1(:)'>0),
        n1=N1(n2);
        qt=min(1,n1*sp(spvalid(:,n2),n2)./(1:n1)');
        min1=nan;
        for n=n1:-1:1,
            min1=min(min1,qt(n));
            q(idx(n,n2),n2)=min1;
        end
    end
end
if dim~=1, q=ipermute(q,[dim,1:dim-1,dim+1:nd]); end

function filesout=expandframe(filesin)
% expands all frames in 4d nifti file

singlefile=false;
if ~iscell(filesin), 
    if isstruct(filesin) % special-case, passing spm_vol structure
        filesout=cellfun(@(a,b)[a,',',b],{filesin.fname},cellfun(@(x)num2str(x(1)),{filesin.n},'uni',0),'uni',0);
        return
    end
    filesin=cellstr(filesin); % passing single string
    singlefile=true;
end

filesout={};
for n=1:numel(filesin)
    filename=filesin{n};
    if ~isempty(regexp(filename,',\d+$','once'))||isempty(regexp(filename,'\.img$|\.nii$','once'))
        filesout=cat(1,filesout, {filename});
    else
        ni = nifti(filename);
        dm = [ni.dat.dim 1 1 1 1];
        if dm(4)>1
            filesout=cat(1,filesout, arrayfun(@(x)[filename,',',num2str(x)],(1:dm(4))','uni',0) );
        else
            filesout=cat(1,filesout, {filename});
        end
    end
end

if singlefile
    filesout=char(filesout);
end






    