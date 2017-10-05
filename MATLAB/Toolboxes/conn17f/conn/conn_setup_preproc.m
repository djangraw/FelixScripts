function [ok,matlabbatch,outputfiles,job_id]=conn_setup_preproc(STEPS,varargin)
% CONN_SETUP_PREPROC
% Runs individual preprocessing steps
%
% conn_setup_preproc(steps)
% runs preprocessing pipeline (default_*) or one/multiple individual preprocessing steps (structural_* and functional_*). Valid step names are (enter as cell array to run multiple sequential steps):
%   PIPELINES:
%     default_mni                           : default MNI-space preprocessing pipeline
%     default_mniphase                      : same as default_mni but with vdm/fieldmap information
%     default_ss                            : default subject-space preprocessing pipeline
%     default_ssphase                       : same as default_ss but with vdm/fieldmap information
%     default_ssnl                          : same as default_ss but with non-linear coregistration
%   INDIVIDUAL STRUCTURAL STEPS:
%     structural_center                     : centers structural data to origin (0,0,0) coordinates
%     structural_manualorient               : applies user-defined affine transformation to structural data
%     structural_manualspatialdef           : applies user-defined spatial deformation to structural data
%     structural_normalize                  : structural normalization to MNI space
%     structural_segment                    : structural segmentation (Gray/White/CSF tissue classes)
%     structural_segment&normalize          : structural unified normalization and segmentation 
%   INDIVIDUAL FUNCTIONAL (or combined functional/structural) STEPS:
%     functional_art                        : functional identification of outlier scans (from motion displacement and global signal changes)
%     functional_center                     : centers functional data to origin (0,0,0) coordinates
%     functional_coregister_affine          : functional affine coregistration to structural volumes
%     functional_coregister_nonlinear       : functional non-linear coregistration to structural volumes
%     functional_manualorient               : applies user-defined affine transformation to functional data
%     functional_manualspatialdef           : applies user-defined spatial deformation to functional data
%     functional_motionmask                 : creates functional motion masks (mean BOLD signal spatial derivatives wrt motion parameters)
%     functional_normalize_direct           : functional direct normalization
%     functional_normalize_indirect         : functional indirect normalization (coregister to structural; normalize structural; apply same transformation to functionals)
%     functional_realign                    : functional realignment
%     functional_realign_noreslice          : functional realignment without reslicing (applies transformation to source header files)
%     functional_realign&unwarp             : functional realignment & unwarp (motion-by-inhomogeneity interactions)
%     functional_realign&unwarp&fieldmap    : functional realignemnt & unwarp & inhomogeneity correction (from vdm/fieldmap files)
%     functional_removescans                : removes user-defined number of initial scans from functional data
%     functional_segment                    : functional segmentation (Gray/White/CSF tissue classes)
%     functional_segment&normalize_direct   : functional direct unified normalization and segmentation
%     functional_segment&normalize_indirect : functional indirect unified normalization and segmentation (coregister to structural; normalize and segment structural; apply same transformation to functionals)
%     functional_slicetime                  : functional slice-timing correction
%     functional_smooth                     : functional spatial smoothing
%
% conn_setup_preproc(steps,'param1_name',param1_value,'param2_name',param2_value,...)
% defines additional non-default values for parameters specific to individual steps
%      fwhm            : (functional_smooth) Smoothing factor (mm) [8]
%      coregtomean     : (functional_coregister/segment/normalize) 0: use first volume; 1: use mean volume (computed during realignment); 2: use user-defined source volume (see Setup.coregsource_functionals field) [1]
%      sliceorder      : (functional_slicetime) acquisition order (vector of indexes; 1=first slice in image; note: use cell array for subject-specific vectors)
%                       alternatively sliceorder may also be defined as one of the following strings: 'ascending','descending','interleaved (middle-top)','interleaved (bottom-up)','interleaved (top-down)','interleaved (Siemens)','BIDS'
%                       alternatively sliceorder may also be defined as a vector containing the acquisition time in milliseconds for each slice (e.g. for multi-band sequences)
%      ta              : (functional_slicetime) acquisition time (TA) in seconds (used to determine slice times when sliceorder is defined by a vector of slice indexes; note: use vector for subject-specific values). Defaults to (1-1/nslices)*TR where nslices is the number of slices
%      art_thresholds  : (functional_art) ART thresholds for identifying outlier scans
%                                            art_thresholds(1): threshold value for global-signal (z-value; default 5)
%                                            art_thresholds(2): threshold value for subject-motion (mm; default .9)
%                        additional options: art_thresholds(3): 1/0 global-signal threshold based on scan-to-scan changes in global-BOLD measure (default 1)
%                                            art_thresholds(4): 1/0 subject-motion threshold based on scan-to-scan changes in subject-motion measure (default 1)
%                                            art_thresholds(5): 1/0 subject-motion threhsold based on composite-movement measure (default 1)
%                                            art_thresholds(6): 1/0 force interactive mode (ART gui) (default 0)
%                                            art_thresholds(7): [only when art_threshold(5)=0] subject-motion threshold based on rotation measure
%                                            art_thresholds(8): N number of initial scans to be flagged for removal (default 0)
%                            note: when art_threshold(5)=0, art_threshold(2) defines the threshold based on the translation measure, and art_threhsold(7) defines the threshold based on the rotation measure; otherwise art_threshold(2) defines the (single) threshold based on the composite-motion measure
%                            note: the default art_thresholds(1:2) [5 .9] values correspond to the "intermediate" (97th percentile) settings, to use the "conservative" (95th percentile) settings use [3 .5], to use the "liberal" (99th percentile) settings use [9 2] values instead
%                            note: art needs subject-motion files to estimate possible outliers. If a 'realignment' first-level covariate exists it will load the subject-motion parameters from that first-level covariate; otherwise it will look for a rp_*.txt file (SPM format) in the same folder as the functional data
%                                  subject-motion files can be in any of the following formats: a) *.txt file (SPM format; three translation parameters in mm followed by pitch/roll/yaw in radians); b) *.par (FSL format; three Euler angles in radians followed by translation parameters in mm); c) *.siemens.txt (Siemens MotionDetectionParameter.txt format); d) *.deg.txt (same as SPM format but rotations in degrees instead of radians)
%      removescans     : (functional_removescans) number of initial scans to remove
%      reorient        : (functional/structural_manualorient) 3x3 or 4x4 transformation matrix or filename containing corresponding matrix
%      respatialdef    : (functional/structural_manualspatialdef) nifti deformation file (e.g. y_*.nii or *seg_sn.mat files)
%      voxelsize_anat  : (normalization) target voxel size for resliced anatomical volumes (mm) [1]
%      voxelsize_func  : (normalization) target voxel size for resliced functional volumes (mm) [2]
%      boundingbox     : (normalization) target bounding box for resliced volumes (mm) [-90,-126,-72;90,90,108]
%      interp          : (normalization) target voxel interpolation method (0:nearest neighbor; 1:trilinear; 2 or higher:n-order spline) [4]
%      template_anat   : (structural_normalize SPM8 only) anatomical template file for approximate coregistration [spm/template/T1.nii]
%      template_func   : (functional_normalize SPM8 only) functional template file for normalization [spm/template/EPI.nii]
%      affreg          : (normalization) affine registration before normalization ['mni']
%      tpm_template    : (structural_segment, structural_segment&normalize in SPM8, and any segment/normalize option in SPM12) tissue probability map [spm/tpm/TPM.nii]
%      tpm_ngaus       : (structural_segment, structural_segment&normalize in SPM8&SPM12) number of gaussians for each tissue probability map
%
% conn_setup_preproc('steps')
% returns the full list of valid preprocessing step names
%




global CONN_x CONN_gui;
PREFERSPM8OVERSPM12=false;
if isdeployed, spmver12=true;
else spmver12=str2double(regexp(spm('ver'),'SPM(\d+)','tokens','once'))>=12;
end
if isfield(CONN_gui,'font_offset'),font_offset=CONN_gui.font_offset; else font_offset=0; end
if ~nargin, STEPS=''; varargin={'multiplesteps',1}; end
options=varargin;
steps={'default_mni','default_mniphase','default_ss','default_ssphase','default_ssnl',...
    'structural_manualorient','structural_center','structural_segment',...
    'structural_normalize','structural_segment&normalize',...
    'structural_manualspatialdef', ...
    'functional_removescans','functional_manualorient','functional_center',...
    'functional_slicetime','functional_realign','functional_realign&unwarp',...
    'functional_realign&unwarp&fieldmap','functional_art','functional_coregister_affine',...
    'functional_segment',...
    'functional_manualspatialdef',...
    'functional_smooth','functional_motionmask',...
    'functional_segment&normalize_indirect','functional_normalize_indirect', ...
    'functional_segment&normalize_direct','functional_normalize_direct', ...
    'functional_realign_noreslice', ...
    'functional_coregister_nonlinear'  ...
    };
%'functional_normalize','functional_segment&normalize',...
steps_names={'<HTML><b>default preprocessing pipeline</b> for volume-based analyses (direct normalization to MNI-space)</HTML>','<HTML><b>preprocessing pipeline</b> for volume-based analyses (indirect normalization to MNI-space) when FieldMaps are available</HTML>','<HTML><b>preprocessing pipeline</b> for surface-based analyses (in subject-space)</HTML>','<HTML><b>preprocessing pipeline</b> for surface-based analyses (in subject-space) when FieldMaps are available</HTML>','<HTML><b>preprocessing pipeline</b> for surface-based analyses (in subject-space) using nonlinear coregistration</HTML>',...
    'structural Manual transformation (rotation/flip/translation/affine of structural volumes)','structural Center to (0,0,0) coordinates (translation)','structural Segmentation (Gray/White/CSF tissue estimation)',...
    'structural Normalization (MNI space normalization)','structural Segmentation & Normalization (simultaneous Gray/White/CSF segmentation and MNI normalization)',...
    'structural Manual deformation (non-linear transformation of structural volumes)', ...
    'functional Removal of initial scans (disregard initial functional scans)','functional Manual transformation (rotation/flip/translation/affine of functional volumes)','functional Center to (0,0,0) coordinates (translation)',...
    'functional Slice-timing correction','functional Realignment (subject motion estimation and correction)','functional Realignment & unwarp (subject motion estimation and correction)',...
    'functional Realignment & unwarp & phase correction (subject motion estimation and correction)','functional Outlier detection (ART-based identification of outlier scans for scrubbing)','functional Direct Coregistration to structural (rigid body transformation)',...
    'functional Segmentation (Gray/White/CSF segmentation)',...
    'functional Manual deformation (non-linear transformation of functional volumes)',...
    'functional Smoothing (spatial convolution with Gaussian kernel)','functional Motion-mask estimation (BOLD signal derivative wrt movement parameters)',...
    'functional Indirect Segmentation & Normalization (coregister functional/structural; structural segmentation & normalization; apply same deformation field to functional)', ...
    'functional Indirect Normalization (coregister functional/structural; structural normalization; apply same deformation field to functional)',...
    'functional Direct Segmentation & Normalization (simultaneous Gray/White/CSF segmentation and MNI normalization)',...
    'functional Direct Normalization (MNI space normalization)', ...
    'functional Realignment without reslicing (subject motion estimation and correction)', ...
    'functional Indirect Coregistration to structural (non-linear transformation)' ...
    };
%'functional Normalization (MNI space normalization)','functional Segmentation & Normalization (simultaneous Gray/White/CSF segmentation and MNI normalization)',...
steps_descr={{'INPUT: structural&functional volumes','OUTPUT (all in MNI-space): skull-stripped normalized structural volume, Gray/White/CSF normalized masks, realigned slice-time corrected normalized smoothed functional volumes, subject movement ''realignment'' and ''scrubbing'' 1st-level covariate'},{'INPUT: structural&functional&VDM volumes','OUTPUT (all in MNI-space): skull-stripped normalized structural volume, Gray/White/CSF normalized masks, realigned&unwarp slice-time corrected normalized smoothed functional volumes, subject movement ''realignment'' and ''scrubbing'' 1st-level covariate'},{'INPUT: structural&functional volumes','OUTPUT (all in subject-space): skull-stripped structural volume, Gray/White/CSF masks, realigned slice-time corrected coregistered functional volumes, subject movement ''realignment'' and ''scrubbing'' 1st-level covariate'},{'INPUT: structural&functional&VDM volumes','OUTPUT (all in subject-space): skull-stripped structural volume, Gray/White/CSF masks, realigned&unwarp slice-time corrected coregistered functional volumes, subject movement ''realignment'' and ''scrubbing'' 1st-level covariate'},{'INPUT: structural&functional volumes','OUTPUT (all in subject-space): skull-stripped structural volume, Gray/White/CSF masks, realigned slice-time corrected coregistered functional volumes, subject movement ''realignment'' and ''scrubbing'' 1st-level covariate'},...
    {'INPUT: structural volume','OUTPUT: structural volume (same files re-oriented, not resliced)'}, {'INPUT: structural volume','OUTPUT: structural volume (same files translated, not resliced)'}, {'INPUT: structural volume','OUTPUT: skull-stripped structural volume, Gray/White/CSF masks (in same space as structural)'},...
    {'INPUT: structural volume; optional coregistered functional volumes','OUTPUT: skull-stripped normalized structural volume; optional normalized functional volumes (all in MNI space)'},{'INPUT: structural volume; optional coregistered functional volumes','OUTPUT: skull-stripped normalized structural volume, normalized Gray/White/CSF masks; optional normalized functional volumes (all in MNI space)'},...
    {'INPUT: structural volume; user-defined spatial deformation file (e.g. y_#.nii file)','OUTPUT: resampled structural volumes'}, ...
    {'INPUT: functional volumes','OUTPUT: subset of functional volumes; cropped first-level covariates (if already defined)'},{'INPUT: functional volumes','OUTPUT: functional volumes (same files re-oriented, not resliced)'},{'INPUT: functional volumes','OUTPUT: functional volumes (same files translated, not resliced)'}, ...
    {'INPUT: functional volumes','OUTPUT: slice-timing corrected functional volumes'},{'INPUT: functional volumes','OUTPUT: realigned functional volumes, mean functional image, subject movement ''realignment'' 1st-level covariate'},{'INPUT: functional volumes','OUTPUT: realigned&unwarp functional volumes, mean functional image, subject movement ''realignment'' 1st-level covariate'},...
    {'INPUT: functional volumes & VDM maps','OUTPUT: realigned&unwarp functional volumes, mean functional image, subject movement ''realignment'' 1st-level covariate'},{'INPUT: functional volumes, realignment parameters','OUTPUT: outlier scans 1st-level covariate, mean functional image, QA 2nd-level covariates'},{'INPUT: structural and mean functional volume (or first functional)','OUTPUT: functional volumes (all functional volumes are coregistered but not resliced)'},...
    {'INPUT: mean functional volume (or first functional)','OUTPUT: Gray/White/CSF masks (in same space as functional volume)'},...
    {'INPUT: functional volumes; user-defined spatial deformation file (e.g. y_#.nii file)','OUTPUT: resampled functional volumes'},...
    {'INPUT: functional volumes','OUTPUT: smoothed functional volumes'},{'INPUT: functional volumes','OUTPUT: motion masks'},...
    {'INPUT: structural volume; functional volumes','OUTPUT: skull-stripped normalized structural volume, normalized Gray/White/CSF masks; normalized functional volumes (all in MNI space)'},...
    {'INPUT: structural volume; functional volumes','OUTPUT: skull-stripped normalized structural volume, normalized functional volumes (all in MNI space)'},...
    {'INPUT: mean functional volume (or first functional)','OUTPUT: normalized functional volumes, normalized Gray/White/CSF masks'},...
    {'INPUT: mean functional volume (or first functional)','OUTPUT: normalized functional volumes'}, ...
    {'INPUT: functional volumes','OUTPUT: realigned functional volumes (same files re-oriented, not resliced), mean functional image, subject movement ''realignment'' 1st-level covariate'}, ...
    {'INPUT: structural and mean functional volume (or first functional)','OUTPUT: functional volumes coregistered to structural (direct normalization to MNI space + inverse deformation field transformation); Gray/White/CSF masks (in same space as functional volume)'} ...
    };
%{'INPUT: mean functional volume (or first functional)','OUTPUT: normalized functional volumes'},{'INPUT: mean functional volume (or first functional)','OUTPUT: normalized functional volumes, normalized Gray/White/CSF masks '},...
steps_index=num2cell(1:numel(steps));
steps_defaultpipelines={...
    {'functional_realign&unwarp','functional_center','functional_slicetime','functional_art','functional_segment&normalize_direct','structural_center','structural_segment&normalize','functional_smooth'},...
    {'functional_realign&unwarp&fieldmap','functional_center','functional_slicetime','functional_art','structural_center','functional_segment&normalize_indirect','functional_smooth'},...
    {'functional_realign&unwarp','functional_slicetime','functional_art','functional_coregister_affine','structural_segment'},...
    {'functional_realign&unwarp&fieldmap','functional_slicetime','functional_art','functional_coregister_affine','structural_segment'},...
    {'functional_realign&unwarp','functional_slicetime','functional_art','functional_coregister_nonlinear'}...
    };
for n=1:numel(steps_defaultpipelines),
    [ok,idx]=ismember(steps_defaultpipelines{n},steps);
    if ~all(ok), error('preprocessing step names have changed'); end
    steps_index{n}=idx(:)';
end
if nargin>0&&ischar(STEPS)&&strcmp(STEPS,'steps'), ok=steps; return; end
steps_pipelines=cellfun('length',steps_index)>1;
dogui=false;
subjects=1:CONN_x.Setup.nsubjects;
sessions=1:max(CONN_x.Setup.nsessions);
doimport=true;
typeselect='';
multiplesteps=iscell(STEPS)&numel(STEPS)>1;
voxelsize_anat=2;
voxelsize_func=2;
boundingbox=[-90,-126,-72;90,90,108]; % default bounding-box
interp=[];
fwhm=[];
sliceorder=[];
sliceorder_select=[];
ta=[];
unwarp=[];
removescans=[];
reorient=[];
respatialdef=[];
coregtomean=1;
coregsource={};
applytofunctional=false;
tpm_template=[];
affreg=[];
tpm_ngaus=[];
art_thresholds=[];
art_useconservative=1;
art_global_thresholds=[9 5 3];
art_motion_thresholds=[2 .9 .5];
art_global_threshold=art_global_thresholds(1+art_useconservative); % default art scan-to-scan global signal z-value thresholds
art_motion_threshold=art_motion_thresholds(1+art_useconservative); % default art scan-to-scan composite motion mm thresholds
art_use_diff_motion=1;
art_use_diff_global=1;
art_use_norms=1;
art_force_interactive=0;
art_drop_flag=0;
art_gui_display=true;
parallel_profile=[];
parallel_N=0;
functional_template=fullfile(fileparts(which('spm')),'templates','EPI.nii');
if isempty(dir(functional_template)), functional_template=fullfile(fileparts(which('spm')),'toolbox','OldNorm','EPI.nii'); end
structural_template=fullfile(fileparts(which('spm')),'templates','T1.nii');
if isempty(dir(structural_template)), structural_template=fullfile(fileparts(which('spm')),'toolbox','OldNorm','T1.nii'); end
selectedstep=1;
if ~isempty(STEPS)&&(ischar(STEPS)||(iscell(STEPS)&&numel(STEPS)==1))
    STEPS=char(STEPS);
    switch(lower(STEPS))
        case 'default_mni',      STEPS=steps(steps_index{1}); selectedstep=1;
        case 'default_mniphase', STEPS=steps(steps_index{2}); selectedstep=2; %applytofunctional=true;
        case 'default_ss',       STEPS=steps(steps_index{3}); selectedstep=3;
        case 'default_ssphase',  STEPS=steps(steps_index{4}); selectedstep=4;
        case 'default_ssnl',     STEPS=steps(steps_index{5}); selectedstep=5;
        otherwise, 
            lSTEPS=regexprep(lower(STEPS),'^run_|^update_|^interactive_','');
            if ismember(lSTEPS,steps), STEPS=cellstr(STEPS);
            elseif conn_existfile(STEPS), load(STEPS,'STEPS','coregtomean'); if isempty(coregtomean), coregtomean=1; end
            else error('STEP name %s is not a valid preprocessing step or an existing preprocessing-pipeline file');
            end
    end
end
ok=0;
for n1=1:2:numel(options)-1,
    switch(lower(options{n1}))
        case 'select',
            typeselect=lower(char(options{n1+1}));
        case 'multiplesteps',
            multiplesteps=options{n1+1};
        case 'fwhm',
            fwhm=options{n1+1};
        case 'sliceorder',
            sliceorder=options{n1+1};
            if iscell(sliceorder), sliceorder=[sliceorder{:}]; end
        case 'ta',
            ta=options{n1+1};
        case 'unwarp',
            unwarp=options{n1+1}; % note: deprecated over CONN_x.Setup.unwarp_functional field
        case 'removescans',
            removescans=options{n1+1};
        case 'applytofunctional',
            applytofunctional=options{n1+1};
        case 'coregtomean',
            coregtomean=options{n1+1};
        case 'coregsource', % note: deprecated over CONN_x.Setup.coregsource_functional field
            coregsource=options{n1+1};
        case 'reorient',
            reorient=options{n1+1};
        case 'respatialdef',
            respatialdef=options{n1+1};
        case 'art_thresholds',
            art_thresholds=options{n1+1};
        case 'subjects',
            subjects=options{n1+1};
        case 'sessions',
            sessions=options{n1+1};
        case 'voxelsize',
            voxelsize_anat=options{n1+1};
            voxelsize_func=options{n1+1};
        case 'voxelsize_anat',
            voxelsize_anat=options{n1+1};
        case 'voxelsize_func',
            voxelsize_func=options{n1+1};
        case 'boundingbox',
            boundingbox=options{n1+1};
        case 'interp'
            interp=options{n1+1};
        case 'doimport',
            doimport=options{n1+1};
        case 'dogui',
            dogui=options{n1+1};
        case {'functional_template','template_functional','template_func'}
            functional_template=char(options{n1+1});
        case {'structural_template','template_structural','template_anat'}
            structural_template=char(options{n1+1});
        case 'usespm8methods',
            PREFERSPM8OVERSPM12=options{n1+1};
        case 'affreg'
            affreg=char(options{n1+1});
        case 'tpm_template',
            tpm_template=options{n1+1};
        case 'tpm_ngaus',
            tpm_ngaus=options{n1+1};
        case 'parallel_profile'
            parallel_profile=char(options{n1+1});
        case 'parallel_N'
            parallel_N=options{n1+1};
        otherwise
            error(['unrecognized option ',options{n1}]);
    end
end
if isfield(CONN_x,'pobj')&&isstruct(CONN_x.pobj)&&isfield(CONN_x.pobj,'subjects'), subjects=CONN_x.pobj.subjects; end % this field overwrites user-defined options

if ~nargin||isempty(STEPS)||dogui,
    dogui=true;
    if ~isempty(typeselect)
        switch(typeselect)
            case 'structural', idx=find(cellfun('length',regexp(steps_names,'^structural')));
            case 'functional', idx=find(cellfun('length',regexp(steps_names,'^functional')));
            otherwise,         idx=1:numel(steps);
        end
        steps=steps(idx);
        steps_names=steps_names(idx);
        steps_descr=steps_descr(idx);
        steps_pipelines=steps_pipelines(idx);
    end
    [nill,steps_order]=sort(steps_names);
    steps_order=[sort(steps_order(steps_pipelines(steps_order))) steps_order(~steps_pipelines(steps_order))];
    scalefig=1+multiplesteps;
    dlg.steps=steps;
    dlg.steps_names=steps_names;
    dlg.steps_descr=steps_descr;
    dlg.steps_index=steps_index;
    dlg.steps_order=steps_order;
    dlg.fig=figure('units','norm','position',[.2,.3,.5+.2*(1|multiplesteps),.6],'menubar','none','numbertitle','off','name','SPM data preprocessing step','color',1*[1 1 1]);
    if multiplesteps,
        %uicontrol('style','frame','units','norm','position',[.025,.6,.95,.375],'backgroundcolor',1*[1 1 1],'foregroundcolor',.75*[1 1 1],'fontsize',9+font_offset);
        uicontrol('style','frame','units','norm','position',[.025,.025,.95,.55],'backgroundcolor',1*[1 1 1],'foregroundcolor',.75*[1 1 1],'fontsize',9+font_offset);
    end
    ht=uicontrol('style','text','units','norm','position',[.1,.9,.8,.05],'backgroundcolor',1*[1 1 1],'foregroundcolor','k','horizontalalignment','left','string','Select individual preprocessing step:','fontweight','bold','fontsize',9+font_offset);
    dlg.m0=uicontrol('style','popupmenu','units','norm','position',[.1,.85,.8,.05],'string',steps_names(steps_order),'value',find(ismember(steps_order,selectedstep)),'backgroundcolor',1*[1 1 1],'foregroundcolor','k','tooltipstring','Select a data preprocessing step','callback',@(varargin)conn_setup_preproc_update,'fontsize',9+font_offset);
    if multiplesteps, set(ht,'string','List of all available preprocessing steps:'); set(dlg.m0,'tooltipstring','Select a data preprocessing step or pipeline and click ''Add'' to add it to your data preprocessing pipeline'); end 
    dlg.m6=uicontrol('style','text','units','norm','position',[.1,.725,.8,.1],'max',2,'string',steps_descr{selectedstep},'backgroundcolor',1*[1 1 1],'enable','inactive','horizontalalignment','left','fontsize',9+font_offset);
    dlg.m4=uicontrol('style','checkbox','units','norm','position',[.1,.65,.8,.05],'value',~coregtomean,'string','First functional volume as reference','backgroundcolor',1*[1 1 1],'tooltipstring','<HTML>Uses firts functional volume as reference in coregistration/normalization step <br/> - if unchecked coregistration/normalization uses mean-volume as reference instead<br/> - note: mean volume is created during realignment</HTML>','visible','off','fontsize',9+font_offset);
    %dlg.m3=uicontrol('style','checkbox','units','norm','position',[.1,.5,.8/scalefig,.05],'value',applytofunctional,'string','Apply structural deformation field to functional data as well','backgroundcolor',1*[1 1 1],'tooltipstring','Apply structural deformation field computed during structural normalization/segmentation step to coregistered functional data as well','visible','off','fontsize',9+font_offset);
    dlg.m2=uicontrol('style','popupmenu','units','norm','position',[.1,.35,.8,.05],'value',1,'string',{'Run process and import results to CONN project','Run process only (do not import results)','Interactive SPM batch editor only (do not run process)'}','backgroundcolor',1*[1 1 1],'fontsize',9+font_offset);
    dlg.m1=uicontrol('style','checkbox','units','norm','position',[.1,.12,.2,.05],'value',1,'string','Process all subjects','backgroundcolor',1*[1 1 1],'tooltipstring','Apply this preprocessing to all subjects in your curent CONN project','callback',@(varargin)conn_setup_preproc_update,'fontsize',9+font_offset);
    dlg.m5=uicontrol('style','listbox','units','norm','position',[.3,.12,.2,.07],'max',2,'string',arrayfun(@(n)sprintf('Subject%d',n),1:CONN_x.Setup.nsubjects,'uni',0),'backgroundcolor',1*[1 1 1],'tooltipstring','Select subjects','visible','off','fontsize',9+font_offset);
    dlg.m1b=uicontrol('style','checkbox','units','norm','position',[.1,.07,.2,.05],'value',1,'string','Process all sessions','backgroundcolor',1*[1 1 1],'tooltipstring','Apply this preprocessing to all sessions in your curent CONN project','callback',@(varargin)conn_setup_preproc_update,'fontsize',9+font_offset);
    dlg.m5b=uicontrol('style','listbox','units','norm','position',[.3,.05,.2,.07],'max',2,'string',arrayfun(@(n)sprintf('Session%d',n),1:max(CONN_x.Setup.nsessions),'uni',0),'backgroundcolor',1*[1 1 1],'tooltipstring','Select sessions','visible','off','fontsize',9+font_offset);
    [tstr,tidx]=conn_jobmanager('profiles');
    tnull=find(strcmp('Null profile',conn_jobmanager('profiles')));
    tlocal=find(strcmp('Background process (Unix,Mac)',tstr),1);
    tvalid=setdiff(1:numel(tstr),tnull);
    tstr=cellfun(@(x)sprintf('distributed processing (run on %s)',x),tstr,'uni',0);
    if 1, tvalid=tidx; if isunix&&~isempty(tlocal)&&~ismember(tlocal,tvalid), tvalid=[tvalid(:)' tlocal]; end
    elseif 1, tvalid=tidx; % show only default scheduler
    else tstr{tidx}=sprintf('<HTML><b>%s</b></HTML>',tstr{tidx});
    end
    dlg.m9=uicontrol('style','popupmenu','units','norm','position',[.55,.12,.40,.05],'string',[{'local processing (run on this computer)' 'queue/script it (save as scripts to be run later)'} tstr(tvalid)],'value',1,'backgroundcolor',1*[1 1 1],'fontsize',8+CONN_gui.font_offset);
    if multiplesteps, dlg.m11=uicontrol('style','pushbutton','units','norm','position',[.55,.04,.2,.07],'string','Start','tooltipstring','Accept changes and run data preprocessing pipeline','callback','set(gcbf,''userdata'',0); uiresume(gcbf)','fontsize',9+font_offset);
    else              dlg.m11=uicontrol('style','pushbutton','units','norm','position',[.55,.04,.2,.07],'string','Start','tooltipstring','Accept changes and run data preprocessing step','callback','set(gcbf,''userdata'',0); uiresume(gcbf)','fontsize',9+font_offset);
    end
    dlg.m12=uicontrol('style','pushbutton','units','norm','position',[.75,.04,.2,.07],'string','Cancel','callback','delete(gcbf)','fontsize',9+font_offset);
    if multiplesteps
        set(dlg.m2,'visible','off');%'string',{'Run process and import results to CONN project'});
        %set(dlg.m3,'position',get(dlg.m3,'position')-[0 .075 0 0]);
        %set(dlg.m4,'position',get(dlg.m4,'position')-[0 .075 0 0]);
        set(dlg.fig,'name','SPM data preprocessing pipeline');
        uicontrol('style','text','units','norm','position',[.1,.5,.8,.06],'backgroundcolor',1*[1 1 1],'foregroundcolor','k','horizontalalignment','left','string','Data preprocessing pipeline','fontweight','bold','fontsize',11+font_offset);
        dlg.m7=uicontrol('style','listbox','units','norm','position',[.1,.2,.73,.3],'max',2,'string',{},'backgroundcolor',1*[1 1 1],'tooltipstring','Define series of preprocessing steps','fontsize',9+font_offset,'callback','dlg=get(gcbo,''userdata''); str=get(gcbo,''string''); val=get(gcbo,''value''); if numel(val)==1, idx=find(strcmp(dlg.steps_names(dlg.steps_order),str{val})); if numel(idx)==1, set(dlg.m0,''value'',idx); feval(get(dlg.m0,''callback'')); end; end');
        dlg.m8a=uicontrol('style','pushbutton','units','norm','position',[.84,.455,.11,.05],'string','Add','fontweight','bold','tooltipstring','Adds data preprocessing step (above) to this list','callback','dlg=get(gcbo,''userdata''); ival=dlg.steps_order(get(dlg.m0,''value'')); val=dlg.steps_index{ival}; set(dlg.m7,''string'',cat(1,get(dlg.m7,''string''),dlg.steps_names(val)'')); feval(get(dlg.m0,''callback''));','fontsize',9+font_offset);
        dlg.m8b=uicontrol('style','pushbutton','units','norm','position',[.84,.405,.11,.05],'string','Remove','tooltipstring','Removes selected preprocessing step from this list','callback','dlg=get(gcbo,''userdata''); str=get(dlg.m7,''string''); str=str(setdiff(1:numel(str),get(dlg.m7,''value''))); set(dlg.m7,''string'',str,''value'',[]); feval(get(dlg.m0,''callback'')); ','fontsize',9+font_offset);
        dlg.m8c=uicontrol('style','pushbutton','units','norm','position',[.84,.355,.11,.05],'string','Move up','tooltipstring','Moves selected preprocessing step up in this list','callback','dlg=get(gcbo,''userdata''); str=get(dlg.m7,''string''); val=get(dlg.m7,''value''); idx=1:numel(str); idx(val)=min(idx(val))-1.5; [nill,idx]=sort(idx); str=str(idx); set(dlg.m7,''string'',str,''value'',find(rem(nill,1)~=0));','fontsize',9+font_offset);
        dlg.m8d=uicontrol('style','pushbutton','units','norm','position',[.84,.305,.11,.05],'string','Move down','tooltipstring','Moves selected preprocessing step down this list','callback','dlg=get(gcbo,''userdata''); str=get(dlg.m7,''string''); val=get(dlg.m7,''value''); idx=1:numel(str); idx(val)=max(idx(val))+1.5; [nill,idx]=sort(idx); str=str(idx); set(dlg.m7,''string'',str,''value'',find(rem(nill,1)~=0));','fontsize',9+font_offset);
        dlg.m8e=uicontrol('style','pushbutton','units','norm','position',[.84,.255,.11,.05],'string','Save','tooltipstring','Saves this data preprocessing pipeline list for future use','callback',@conn_setup_preproc_save,'fontsize',9+font_offset);
        dlg.m8f=uicontrol('style','pushbutton','units','norm','position',[.84,.205,.11,.05],'string','Load','tooltipstring','Loads data preprocessing pipeline list from file','callback',@conn_setup_preproc_load,'fontsize',9+font_offset);
        set([dlg.m7 dlg.m8a dlg.m8b dlg.m8c dlg.m8d dlg.m8e dlg.m8f],'userdata',dlg);
    else dlg.m7=[];
    end
    set([dlg.m0 dlg.m1 dlg.m1b],'userdata',dlg);
    if ~isempty(STEPS)
        [tok,idx]=ismember(STEPS,steps);
        set(dlg.m7,'string',steps_names(idx(tok>0))');
    end
    conn_setup_preproc_update(dlg.m0);
    if multiplesteps, conn_setup_preproc_load(dlg.m8f); end
    uiwait(dlg.fig);
    
    if ~ishandle(dlg.fig), return; end
    pressedok=get(dlg.fig,'userdata');
    if isempty(pressedok), return; end
    if multiplesteps
        STEPS=get(dlg.m7,'string');
        [tok,idx]=ismember(STEPS,steps_names);
        STEPS=steps(idx(tok>0));
    else
        STEPS=steps(dlg.steps_order(get(dlg.m0,'value')));
    end
    %STEP_name=steps_names{get(dlg.m0,'value')};
    %if any(ismember(STEPS,{'structural_segment&normalize','structural_normalize'})), applytofunctional=get(dlg.m3,'value'); end
    if any(ismember(STEPS,{'functional_coregister','functional_coregister_affine','functional_normalize','functional_normalize_direct','functional_segment','functional_segment&normalize','functional_segment&normalize_direct','functional_coregister_nonlinear'})), coregtomean=~get(dlg.m4,'value'); end
    if ~get(dlg.m1,'value'), subjects=get(dlg.m5,'value'); end
    if ~get(dlg.m1b,'value'), sessions=get(dlg.m5b,'value'); end
    dorun=get(dlg.m2,'value');
    doparallel=get(dlg.m9,'value');
    if multiplesteps, conn_setup_preproc_save(dlg.m8f); end
    delete(dlg.fig);
    switch(dorun)
        case 1, STEPS=cellfun(@(x)['run_',x],STEPS,'uni',0); doimport=true;
        case 2, STEPS=cellfun(@(x)['run_',x],STEPS,'uni',0); doimport=false;
        case 3, STEPS=cellfun(@(x)['interactive_',x],STEPS,'uni',0); doimport=false;
        case 4, STEPS=cellfun(@(x)['update_',x],STEPS,'uni',0); doimport=true;
    end
    if doparallel>1
        if doparallel==2, parallel_profile=find(strcmp('Null profile',conn_jobmanager('profiles')));
        else parallel_profile=tvalid(doparallel-2);
            if conn_jobmanager('ispending')
                answ=conn_questdlg({'There are previous pending jobs associated with this project','This job cannot be submitted until all pending jobs finish',' ','Would you like to queue this job for later?','(pending jobs can be seen at Tools.Cluster/HPC.View pending jobs'},'Warning','Queue','Cancel','Queue');
                if isempty(answ)||strcmp(answ,'Cancel'), ok=false; end
                parallel_profile=find(strcmp('Null profile',conn_jobmanager('profiles'))); 
            end
        end
        answer=inputdlg('Number of parallel jobs?','',1,{num2str(numel(subjects))});
        if isempty(answer)||isempty(str2num(answer{1})), return; end
        parallel_N=str2num(answer{1});
    end
end

lSTEPS=regexprep(lower(STEPS),'^run_|^update_|^interactive_','');
sliceorder_select_options={'ascending','descending','interleaved (middle-top)','interleaved (bottom-up)','interleaved (top-down)','interleaved (Siemens)','BIDS'};
if any(ismember('functional_slicetime',lSTEPS))
    if ischar(sliceorder),
        [slok,sliceorder_select]=ismember(sliceorder,sliceorder_select_options);
        if ~slok, disp(sprintf('Warning: incorrect sliceorder name %s',sliceorder)); sliceorder_select=[]; end
        sliceorder=[];
    end
    if isempty(sliceorder)&&isempty(sliceorder_select)
        [sliceorder_select,tok] = listdlg('PromptString','Select slice order:','ListSize',[200 200],'SelectionMode','single','ListString',[sliceorder_select_options,{'manually define','do not know (skip slice timing correction)'}]);
        if isempty(sliceorder_select), return; end
        if sliceorder_select==numel(sliceorder_select_options)+1
            sliceorder=inputdlg(['Slice order? (enter slice indexes from z=1 -first slice in image- to z=? -last slice- in the order they were acquired). Alternatively enter acquisition time of each slice in milliseconds (e.g. for multiband sequences). Press Cancel to enter this information at a later point (e.g. separately for each subject)'],'conn_setup_preproc',1,{' '});
            if ~isempty(sliceorder), sliceorder=str2num(sliceorder{1});
            else sliceorder=[];
            end
        elseif sliceorder_select==numel(sliceorder_select_options)+2
            STEPS=STEPS(~ismember(lSTEPS,'functional_slicetime'));
        end
    end
end

if any(ismember('functional_removescans',lSTEPS))
    if isempty(removescans)
        removescans=inputdlg('Enter number of initial scans to remove','conn_setup_preproc',1,{num2str(0)});
        if isempty(removescans), return; end
        removescans=str2num(removescans{1});
    end
end

if any(ismember({'structural_manualorient','functional_manualorient'},lSTEPS))
    if isempty(reorient)
        ntimes=sum(ismember(lSTEPS,{'structural_manualorient','functional_manualorient'}));
        reorient={};
        opts={'translation to 0/0/0 coordinates',nan;
            '90-degree rotation around x-axis (x/y/z to x/-z/y)',[1 0 0;0 0 1;0 -1 0];
            '90-degree rotation around x-axis (x/y/z to x/z/-y)',[1 0 0;0 0 -1;0 1 0];
            '90-degree rotation around y-axis (x/y/z to -z/y/x)',[0 0 1;0 1 0;-1 0 0];
            '90-degree rotation around y-axis (x/y/z to z/y/-x)',[0 0 -1;0 1 0;1 0 0];
            '90-degree rotation around z-axis (x/y/z to y/-x/z)',[0 -1 0;1 0 0;0 0 1];
            '90-degree rotation around z-axis (x/y/z to -y/x/z)',[0 1 0;-1 0 0;0 0 1];
            '180-degree rotation around x-axis (x/y/z to x/-y/-z)',[1 0 0;0 -1 0;0 0 -1];
            '180-degree rotation around y-axis (x/y/z to -x/y/-z)',[-1 0 0;0 1 0;0 0 -1];
            '180-degree rotation around z-axis (x/y/z to -x/-y/z)',[-1 0 0;0 -1 0;0 0 1];
            'clockwise rotation around x-axis (arbitrary angle)',@(a)[1 0 0;0 cos(a) sin(a);0 -sin(a) cos(a)];
            'clockwise rotation around y-axis (arbitrary angle)',@(a)[cos(a) 0 sin(a);0 1 0;-sin(a) 0 cos(a)];
            'clockwise rotation around z-axis (arbitrary angle)',@(a)[cos(a) sin(a) 0;-sin(a) cos(a) 0;0 0 1];
            'non-rigid reflection along x-axis (x/y/z/ to -x/y/z)', [-1 0 0;0 1 0;0 0 1];
            'non-rigid reflection along y-axis (x/y/z/ to x/-y/z)', [1 0 0;0 -1 0;0 0 1];
            'non-rigid reflection along z-axis (x/y/z/ to x/y/-z)', [1 0 0;0 1 0;0 0 -1];
            'arbitrary affine transformation matrix (manually define 4x4 matrix)', 1;
            'arbitrary affine transformation matrix (load 4x4 matrix from file)', 2};
        for ntime=1:ntimes
            if ntimes>1 [treorient,tok] = listdlg('PromptString',sprintf('Select re-orientation transformation for STEP %d/%d:',ntime,ntimes),'ListSize',[300 200],'SelectionMode','single','ListString',opts(:,1));
            else [treorient,tok] = listdlg('PromptString','Select re-orientation transformation:','ListSize',[300 200],'SelectionMode','single','ListString',opts(:,1));
            end
            if isempty(treorient), return; end
            reorient{ntime}=opts{treorient,2};
            if isequal(reorient{ntime},1)
                answ=inputdlg('Enter affine transformation matrix (4x4 values)','conn_setup_preproc',1,{mat2str(eye(4))});
                if isempty(answ), return; end
                answ=str2num(answ{1});
                reorient{ntime}=answ;
            elseif isequal(reorient{ntime},2)
                [tfilename1,tfilename2]=uigetfile('*.mat','Select file',pwd);
                if ~ischar(tfilename1), return; end
                filename=fullfile(tfilename2,tfilename1);
                reorient{ntime}=filename;
            elseif isequal(reorient{ntime},3)
                [tfilename1,tfilename2]=uigetfile('*.nii','Select file',pwd);
                if ~ischar(tfilename1), return; end
                filename=fullfile(tfilename2,tfilename1);
                reorient{ntime}=filename;
            elseif isa(reorient{ntime},'function_handle'),
                answ=inputdlg('Angular rotation (in degrees)','conn_setup_preproc',1,{num2str(90)});
                if isempty(answ), return; end
                answ=str2num(answ{1});
                reorient{ntime}=reorient{ntime}(answ/180*pi);
            end
        end
    end
end

if any(ismember('functional_art',lSTEPS))
    if isempty(art_thresholds)
        thfig=figure('units','norm','position',[.4,.4,.3,.4],'color',1*[1 1 1],'name','Functional outlier detection settings','numbertitle','off','menubar','none');
        ht0=uicontrol('style','popupmenu','units','norm','position',[.05,.8,.9,.1],'string',{'Use liberal settings (99th percentiles in normative sample)','Use intermediate settings (97th percentiles in normative sample)','Use conservative settings (95th percentiles in normative sample)','Edit settings','Edit settings interactively (ART gui)'},'value',1+art_useconservative,'backgroundcolor',1*[1 1 1]);
        ht1a=uicontrol('style','text','units','norm','position',[.05,.7,.9,.05],'string','Global-signal z-value threshold','backgroundcolor',1*[1 1 1]);
        ht1=uicontrol('style','edit','units','norm','position',[.05,.6,.9,.1],'string',num2str(art_global_threshold));
        ht2a=uicontrol('style','text','units','norm','position',[.05,.5,.9,.05],'string','Subject-motion mm threshold','backgroundcolor',1*[1 1 1]);
        ht2=uicontrol('style','edit','units','norm','position',[.05,.4,.9,.1],'string',num2str(art_motion_threshold));
        ht3a=uicontrol('style','checkbox','units','norm','position',[.05,.3,.4,.05],'string','Use diff global','value',art_use_diff_global,'backgroundcolor',1*[1 1 1],'tooltipstring','Global-signal threshold based on scan-to-scan changes in global BOLD signal');
        ht3b=uicontrol('style','checkbox','units','norm','position',[.05,.25,.4,.05],'string','Use abs global','value',~art_use_diff_global,'backgroundcolor',1*[1 1 1],'tooltipstring','Global-signal threshold based on absolute global BOLD signal values');
        ht3c=uicontrol('style','checkbox','units','norm','position',[.05,.20,.4,.05],'string','Drop first scan(s)','value',art_drop_flag>0,'backgroundcolor',1*[1 1 1],'userdata',art_drop_flag,'tooltipstring','Flags first scan(s) in each session for removal');
        ht4a=uicontrol('style','checkbox','units','norm','position',[.55,.3,.4,.05],'string','Use diff motion','value',art_use_diff_motion,'backgroundcolor',1*[1 1 1],'tooltipstring','Subject-motion threshold based on scan-to-scan changes in motion parameters');
        ht4b=uicontrol('style','checkbox','units','norm','position',[.55,.25,.4,.05],'string','Use abs motion','value',~art_use_diff_motion,'backgroundcolor',1*[1 1 1],'tooltipstring','Subject-motion threshold based on absolute motion parameter values');
        ht5=uicontrol('style','checkbox','units','norm','position',[.55,.2,.9,.05],'string','Use comp motion','value',art_use_norms,'backgroundcolor',1*[1 1 1],'tooltipstring','Subject-motion threshold based on composite motion measure');
        uicontrol('style','pushbutton','string','OK','units','norm','position',[.1,.01,.38,.10],'callback','uiresume');
        uicontrol('style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.10],'callback','delete(gcbf)');
        set([ht1a ht1 ht2a ht2 ht3a ht4a ht3b ht3c ht4b ht5],'enable','off');
        set(ht0,'callback','h=get(gcbo,''userdata''); switch get(gcbo,''value''), case 1, set(h.handles,''enable'',''off''); set(h.handles(2),''string'',num2str(h.default{1}(1))); set(h.handles(4),''string'',num2str(h.default{2}(1))); set(h.handles([5:6 10]),''value'',1); set(h.handles([7 9]),''value'',0); case 2, set(h.handles,''enable'',''off''); set(h.handles(2),''string'',num2str(h.default{1}(2))); set(h.handles(4),''string'',num2str(h.default{2}(2))); set(h.handles([5:6 10]),''value'',1); set(h.handles([7 9]),''value'',0); case 3, set(h.handles,''enable'',''off''); set(h.handles(2),''string'',num2str(h.default{1}(3))); set(h.handles(4),''string'',num2str(h.default{2}(3))); set(h.handles([5:6 10]),''value'',1); set(h.handles([7 9]),''value'',0); case 4, set(h.handles,''enable'',''on''); case 5, set(h.handles,''enable'',''off''); end;','userdata',struct('handles',[ht1a ht1 ht2a ht2 ht3a ht4a ht3b ht3c ht4b ht5],'default',{{art_global_thresholds, art_motion_thresholds}}));
        %@(varargin)set([ht1a ht1 ht2a ht2 ht3a ht4a ht3b ht4b ht5],'enable',subsref({'on','off'},struct('type','{}','subs',{{1+(get(gcbo,'value')~=3)}}))));
        set(ht5,'callback','h=get(gcbo,''userdata''); temp=str2num(get(h.handles(4),''string'')); if get(gcbo,''value''), set(h.handles(3),''string'',''Subject-motion mm threshold''); temp=temp(1); else, set(h.handles(3),''string'',''Subject-motion translation/rotation thresholds [mm, rad]''); if numel(temp)<2, temp=[temp .02]; end; end; set(h.handles(4),''string'',mat2str(temp));','userdata',struct('handles',[ht1a ht1 ht2a ht2 ht3a ht4a ht3b ht3c ht4b ht5],'default',{{art_global_thresholds, art_motion_thresholds}}));
        set(ht3a,'callback',@(varargin)set(ht3b,'value',~get(gcbo,'value')));
        set(ht3b,'callback',@(varargin)set(ht3a,'value',~get(gcbo,'value')));
        set(ht3c,'callback','v=get(gcbo,''value''); if v, v=str2double(inputdlg({''Number of initial scans to remove''},'''',1,{num2str(get(gcbo,''userdata''))})); if isempty(v), v=0; end; end; set(gcbo,''value'',v>0); if v>0, set(gcbo,''userdata'',v); end');
        set(ht4a,'callback',@(varargin)set(ht4b,'value',~get(gcbo,'value')));
        set(ht4b,'callback',@(varargin)set(ht4a,'value',~get(gcbo,'value')));
        uiwait(thfig);
        if ~ishandle(thfig), return; end
        art_global_threshold=str2num(get(ht1,'string'));
        temp=str2num(get(ht2,'string'));
        art_motion_threshold=temp;
        art_use_diff_global=get(ht3a,'value');
        art_use_diff_motion=get(ht4a,'value');
        art_use_norms=get(ht5,'value');
        if get(ht3c,'value'), art_drop_flag=get(ht3c,'userdata'); else art_drop_flag=0; end
        art_force_interactive=get(ht0,'value')==5;
        delete(thfig);
        drawnow;
        if numel(art_motion_threshold)<2, art_thresholds=[art_global_threshold(1) art_motion_threshold(1) art_use_diff_global(1) art_use_diff_motion(1) art_use_norms(1) art_force_interactive(1) nan art_drop_flag(1)];
        else art_thresholds=[art_global_threshold(1) art_motion_threshold(1) art_use_diff_global(1) art_use_diff_motion(1) art_use_norms(1) art_force_interactive(1) art_motion_threshold(2) art_drop_flag(1)];
        end
        %answ=inputdlg({'Enter scan-to-scan global signal z-value threshold','Enter scan-to-scan composite motion mm threshold'},'conn_setup_preproc',1,{num2str(art_global_threshold),num2str(art_motion_threshold)});
        %if isempty(answ), return; end
        %art_global_threshold=str2num(answ{1});
        %art_motion_threshold=str2num(answ{2});
    else
        art_global_threshold=art_thresholds(1);
        art_motion_threshold=art_thresholds(2);
        if numel(art_thresholds)>=3, art_use_diff_global=art_thresholds(3); end
        if numel(art_thresholds)>=4, art_use_diff_motion=art_thresholds(4); end
        if numel(art_thresholds)>=5, art_use_norms=art_thresholds(5); end
        if numel(art_thresholds)>=6, art_force_interactive=art_thresholds(6); end
        if numel(art_thresholds)>=7&&~isnan(art_thresholds(7)), art_motion_threshold(2)=art_thresholds(7); end
        if numel(art_thresholds)>=8, art_drop_flag=art_thresholds(8); end
    end
end

if any(ismember({'structural_manualspatialdef','functional_manualspatialdef'},lSTEPS))
    if isempty(respatialdef)
        DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
        ntimes=sum(ismember(lSTEPS,{'structural_manualspatialdef','functional_manualspatialdef'}));
        respatialdef={};
        for ntime=1:ntimes
            if DOSPM12, [tfilename1,tfilename2]=uigetfile('*.nii','Select file');
            else [tfilename1,tfilename2]=uigetfile('*.mat','Select file');
            end
            if ~ischar(tfilename1), return; end
            filename=fullfile(tfilename2,tfilename1);
            respatialdef{ntime}=filename;
        end
    end
end

if dogui&&any(ismember(lSTEPS,{'structural_normalize','structural_segment&normalize','structural_segment','functional_normalize','functional_segment&normalize','functional_segment','functional_segment&normalize_direct','functional_segment&normalize_indirect','functional_normalize_indirect','functional_normalize_direct','structural_manualspatialdef','functional_manualspatialdef'}))
    DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
    thfig=figure('units','norm','position',[.4,.4,.3,.2],'color',1*[1 1 1],'name','Segment/Normalize/Resample settings','numbertitle','off','menubar','none');
    if DOSPM12||any(ismember(lSTEPS,{'structural_segment','structural_segment&normalize','functional_segment','functional_segment&normalize'}))
        ht3=uicontrol('style','checkbox','units','norm','position',[.1,.75,.8,.1],'string','Use default Tissue Probability Maps','value',1,'backgroundcolor',1*[1 1 1],'tooltipstring','defines TPM file used by normalization/segmentation routine');
        ht4=[];ht5=[];
    else
        ht3=[];
        ht4=uicontrol('style','checkbox','units','norm','position',[.1,.85,.8,.1],'string','Use default structural template','value',1,'backgroundcolor',1*[1 1 1]);
        ht5=uicontrol('style','checkbox','units','norm','position',[.1,.75,.8,.1],'string','Use default functional template','value',1,'backgroundcolor',1*[1 1 1]);
    end
    ht1a=uicontrol('style','text','units','norm','position',[.1,.55,.6,.1],'string','Structurals target resolution (in mm)','horizontalalignment','left','backgroundcolor',1*[1 1 1]);
    ht1=uicontrol('style','edit','units','norm','position',[.7,.55,.2,.1],'string',num2str(voxelsize_anat),'tooltipstring','defines voxel-size of volumes created when resampling the structural volumes to the desired target space (e.g. MNI)');
    ht2a=uicontrol('style','text','units','norm','position',[.1,.45,.6,.1],'string','Functionals target resolution (in mm)','horizontalalignment','left','backgroundcolor',1*[1 1 1]);
    ht2=uicontrol('style','edit','units','norm','position',[.7,.45,.2,.1],'string',num2str(voxelsize_func),'tooltipstring','defines voxel-size of volumes created when resampling the functional volumes to the desired target space (e.g. MNI)');
    ht0a=uicontrol('style','text','units','norm','position',[.1,.35,.6,.1],'string','Bounding box (in mm)','horizontalalignment','left','backgroundcolor',1*[1 1 1]);
    ht0=uicontrol('style','edit','units','norm','position',[.7,.35,.2,.1],'string',mat2str(boundingbox),'tooltipstring','<HTML>defines bounding box of resampled volumes<br/> - enter a 2x3 matrix with minimum xyz values in the top row and maximum xyz values in the bottom row</HTML>');
    uicontrol('style','pushbutton','string','OK','units','norm','position',[.1,.01,.38,.15],'callback','uiresume');
    uicontrol('style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.15],'callback','delete(gcbf)');
    if ~any(ismember(lSTEPS,{'structural_normalize','structural_segment&normalize','structural_segment','functional_segment&normalize_indirect','functional_normalize_indirect','structural_manualspatialdef'})), set([ht1a ht1 ht4],'enable','off'); end
    if ~any(ismember(lSTEPS,{'functional_normalize','functional_segment&normalize','functional_segment','functional_segment&normalize_direct','functional_normalize_direct','functional_manualspatialdef'})), set([ht2a ht2 ht5],'enable','off'); end
    if all(ismember(lSTEPS,{'structural_manualspatialdef','functional_manualspatialdef'})), set([ht3 ht4 ht5],'visible','off'); set(thfig,'name','Resample settings'); end
    set(ht3,'userdata',[],'callback','if ~get(gcbo,''value''), [t1,t0]=uigetfile(''*.nii;*.img'',''Select TPM file''); if ischar(t1), set(gco,''userdata'',fullfile(t0,t1)); else set(gcbo,''value'',1); end; end');
    set(ht4,'userdata',[],'callback','if ~get(gcbo,''value''), [t1,t0]=uigetfile(''*.nii;*.img'',''Select template file''); if ischar(t1), set(gco,''userdata'',fullfile(t0,t1)); else set(gcbo,''value'',1); end; end');
    set(ht5,'userdata',[],'callback','if ~get(gcbo,''value''), [t1,t0]=uigetfile(''*.nii;*.img'',''Select template file''); if ischar(t1), set(gco,''userdata'',fullfile(t0,t1)); else set(gcbo,''value'',1); end; end');
    uiwait(thfig);
    if ~ishandle(thfig), return; end
    temp=str2num(get(ht1,'string')); if ~isempty(temp), voxelsize_anat=temp; end
    temp=str2num(get(ht2,'string')); if ~isempty(temp), voxelsize_func=temp; end
    temp=str2num(get(ht0,'string')); if ~isempty(temp), boundingbox=temp; end
    if ~isempty(ht3), val=get(ht3,'value'); if ~val, tpm_template=get(ht3,'userdata'); end; end
    if ~isempty(ht4), val=get(ht4,'value'); if ~val, structural_template=get(ht4,'userdata'); end; end
    if ~isempty(ht5), val=get(ht5,'value'); if ~val, functional_template=get(ht5,'userdata'); end; end
    delete(thfig);
    drawnow;
end

if any(ismember('functional_smooth',lSTEPS))
    if isempty(fwhm)
        fwhm=inputdlg('Enter smoothing kernel FWHM (in mm)','conn_setup_preproc',1,{num2str(8)});
        if isempty(fwhm), return; end
        fwhm=str2num(fwhm{1});
    end
end

% loginfo=struct('subjects',subjects,'steps',STEPS,...
%     'fwhm',fwhm,'sliceorder',sliceorder,'ta',ta,'unwarp',unwarp,'removescans',removescans,'applytofunctional',applytofunctional,...
%     'coregtomean',coregtomean,'reorient',reorient,'art_thresholds',art_thresholds,'voxelsize',voxelsize,'boundingbox',boundingbox,...
%     'doimport',doimport,'dogui',0,'functional_template',functional_template,'structural_template',structural_template,...
%     'tpm_template',tpm_template,'tpm_ngaus',tpm_ngaus);
if parallel_N>0,
    if ~isempty(parallel_profile), conn_jobmanager('setprofile',parallel_profile); end
    conn save;
    if isempty(sliceorder)&&~isempty(sliceorder_select), sliceorder=sliceorder_select_options{sliceorder_select}; end
    info=conn_jobmanager('submit','setup_preprocessing',subjects,parallel_N,[],...
        STEPS,...
        'sessions',sessions,'fwhm',fwhm,'sliceorder',sliceorder,'ta',ta,'unwarp',unwarp,'removescans',removescans,'applytofunctional',applytofunctional,...
        'coregtomean',coregtomean,'coregsource',coregsource,'reorient',reorient,'respatialdef',respatialdef,'art_thresholds',art_thresholds,'voxelsize_anat',voxelsize_anat,'voxelsize_func',voxelsize_func,'boundingbox',boundingbox,'interp',interp,...
        'doimport',doimport,'dogui',0,'functional_template',functional_template,'structural_template',structural_template,...
        'affreg',affreg,'tpm_template',tpm_template,'tpm_ngaus',tpm_ngaus);
    if isequal(parallel_profile,find(strcmp('Null profile',conn_jobmanager('profiles')))),
        ok=1;
    else
        [nill,finished]=conn_jobmanager('waitfor',info);
        if finished==2, ok=1+doimport;
        else ok=3;
        end
    end
    return;
else
    if ~isfield(CONN_x,'SetupPreproc')||~isfield(CONN_x.SetupPreproc,'log'), CONN_x.SetupPreproc.log={}; end
    CONN_x.SetupPreproc.log{end+1}={'timestamp',datestr(now),...
        STEPS,...
        'sessions',sessions,'fwhm',fwhm,'sliceorder',sliceorder,'sliceorder_select',sliceorder_select,'ta',ta,'unwarp',unwarp,'removescans',removescans,'applytofunctional',applytofunctional,...
        'coregtomean',coregtomean,'coregsource',coregsource,'reorient',reorient,'respatialdef',respatialdef,'art_thresholds',art_thresholds,'voxelsize_anat',voxelsize_anat,'voxelsize_func',voxelsize_func,'boundingbox',boundingbox,'interp',interp,...
        'doimport',doimport,'dogui',0,'functional_template',functional_template,'structural_template',structural_template,...
        'affreg',affreg,'tpm_template',tpm_template,'tpm_ngaus',tpm_ngaus};
end
job_id={};

for iSTEP=1:numel(STEPS)
    matlabbatch={};
    outputfiles={};
    STEP=STEPS{iSTEP};
    idx=find(strcmpi(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),steps));
    if ~isempty(idx), STEP_name=steps_names{idx(1)};
    else STEP_name='process';
    end
    ok=0;
    
    hmsg=[];
    if dogui, hmsg=conn_msgbox({['Preparing ',STEP_name],'Please wait...'},'');
    else disp(['Preparing ',STEP_name,'. Please wait...']);
    end
    switch(regexprep(lower(STEP),'^run_|^update_|^interactive_',''))
        case 'functional_removescans'
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                %matlabbatch{end+1}.removescans.data={};
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess,
                    if ismember(nses,sessions)
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        if numel(temp)==1,
                            temp=cellstr(conn_expandframe(temp{1}));
                        end
                        %matlabbatch{end}.removescans.data{end+1}=temp;
                        outputfiles{isubject}{nses}{1}=char(temp(max(0,removescans)+1:end+min(0,removescans)));
                        
                        nl1covariates=length(CONN_x.Setup.l1covariates.names)-1;
                        for nl1covariate=1:nl1covariates,
                            try
                                covfilename=CONN_x.Setup.l1covariates.files{nsubject}{nl1covariate}{nses}{1};
                                switch(covfilename),
                                    case '[raw values]',
                                        data=CONN_x.Setup.l1covariates.files{nsubject}{nl1covariate}{nses}{3};
                                    otherwise,
                                        data=load(covfilename);
                                        if isstruct(data), tempnames=fieldnames(data); data=data.(tempnames{1}); end
                                end
                                if size(data,1)==numel(temp)
                                    data=data(max(0,removescans)+1:end+min(0,removescans),:);
                                    outputfiles{isubject}{nses}{1+nl1covariate}=data;
                                end
                            end
                        end
                    end
                end
            end
            
        case 'functional_manualorient'
        case 'structural_manualorient'
        case 'functional_center'
        case 'structural_center'

        case 'functional_manualspatialdef'
            if iscell(respatialdef), trespatialdef=respatialdef{1}; respatialdef=respatialdef(2:end);
            else trespatialdef=respatialdef;
            end
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12
                matlabbatch{end+1}.spm.spatial.normalise.write.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.woptions.vox=voxelsize_func.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.woptions.interp=interp; end
            else
                matlabbatch{end+1}.spm.spatial.normalise.write.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.roptions.vox=voxelsize_func.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.roptions.interp=interp; end
            end
            jsubject=0;
            for isubject=1:numel(subjects), % normalize write
                nsubject=subjects(isubject);
                nsess=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject))); 
                for nses=nsess(:)'
                    jsubject=jsubject+1;
                    if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).def={trespatialdef};
                    else        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).matname={trespatialdef};
                    end
                    matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample={};
                    if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                    if coregtomean, % keeps mean image in same space in case it is required later
                        [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                        if ~isempty(xtemp),
                            xtemp={xtemp};
                            matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,xtemp);
                        end
                    end
                    matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,temp);
                    outputfiles{isubject}{nses}{1}=char(conn_prepend('w',temp));
                end
            end
            if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
                        
        case 'structural_manualspatialdef'
            if iscell(respatialdef), trespatialdef=respatialdef{1}; respatialdef=respatialdef(2:end);
            else trespatialdef=respatialdef;
            end
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12
                matlabbatch{end+1}.spm.spatial.normalise.write.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.woptions.vox=voxelsize_anat.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.woptions.interp=interp; end
            else
                matlabbatch{end+1}.spm.spatial.normalise.write.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.roptions.vox=voxelsize_anat.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.roptions.interp=interp; end
            end
            jsubject=0;
            for isubject=1:numel(subjects), % normalize write
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess_struct=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject))); 
                else nsess_struct=1; 
                end
                for nses=nsess_struct(:)'
                    outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                    if ismember(nses,sessions)
                        jsubject=jsubject+1;
                        if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).def={trespatialdef};
                        else        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).matname={trespatialdef};
                        end
                        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=outputfiles{isubject}{nses}(1);
                    end
                    outputfiles{isubject}{nses}{1}=conn_prepend('w',outputfiles{isubject}{nses}{1});
                end
            end
            if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
           
        case 'structural_segment'
            if ~PREFERSPM8OVERSPM12&&spmver12 %SPM12
                matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
                jsubject=0;
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        if ismember(nses,sessions)
                            jsubject=jsubject+1;
                            matlabbatch{end}.spm.spatial.preproc.channel.vols{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{2}=conn_prepend('c1',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii'); % note: fix SPM12 issue converting .img to .nii
                            outputfiles{isubject}{nses}{3}=conn_prepend('c2',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                            outputfiles{isubject}{nses}{4}=conn_prepend('c3',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                        end
                    end
                end
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    if numel(tpm_ngaus)<numel(temp), tpm_ngaus=[tpm_ngaus(:)' 4+zeros(1,numel(temp)-numel(tpm_ngaus))]; end
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(min(n,numel(tpm_ngaus))),'native',[1 0],'warped',[0 0]);
                    end
                end
                if ~isempty(affreg), matlabbatch{end}.spm.spatial.preproc.warp.affreg=affreg; end
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
                if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
            else % SPM8
                matlabbatch{end+1}.spm.spatial.preproc.data={};
                jsubject=0;
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        if ismember(nses,sessions)
                            jsubject=jsubject+1;
                            matlabbatch{end}.spm.spatial.preproc.data{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{2}=conn_prepend('c1',CONN_x.Setup.structural{nsubject}{nses}{1});
                            outputfiles{isubject}{nses}{3}=conn_prepend('c2',CONN_x.Setup.structural{nsubject}{nses}{1});
                            outputfiles{isubject}{nses}{4}=conn_prepend('c3',CONN_x.Setup.structural{nsubject}{nses}{1});
                        end
                    end
                end
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox; %
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
                if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
            end
            jsubject=0;
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    if ismember(nses,sessions)
                        jsubject=jsubject+1;
                        matlabbatch{end+1}.spm.util.imcalc.expression='(i2+i3+i4).*i1';
                        matlabbatch{end}.spm.util.imcalc.input=reshape(outputfiles{isubject}{nses}(1:4),[],1);
                        matlabbatch{end}.spm.util.imcalc.output=conn_prepend('c0',CONN_x.Setup.structural{nsubject}{nses}{1});
                        matlabbatch{end}.spm.util.imcalc.options.dtype=spm_type('float32');
                        outputfiles{isubject}{nses}{1}=conn_prepend('c0',CONN_x.Setup.structural{nsubject}{nses}{1});
                    end
                end
            end
            
        case {'structural_normalize','functional_normalize_indirect'}
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if strcmp(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),'functional_normalize_indirect') 
                jsubject=0;
                for isubject=1:numel(subjects), % coregister
                    nsubject=subjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess_struct=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)));
                    else nsess_struct=1;
                    end
                    for nses_struct=nsess_struct(:)'
                        if CONN_x.Setup.structural_sessionspecific, nsess_func=nses_struct;
                        else nsess_func=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)));
                        end
                        if ~isempty(nsess_func)
                            jsubject=jsubject+1;
                            if ismember(nses_struct,sessions), reffile=CONN_x.Setup.structural{nsubject}{nses_struct}{1};
                            else
                                if DOSPM12, [matfile,nill,reffile]=conn_setup_preproc_meanimage(CONN_x.Setup.structural{nsubject}{nses_struct}{1},'norm_spm12');
                                else [matfile,nill,reffile]=conn_setup_preproc_meanimage(CONN_x.Setup.structural{nsubject}{nses_struct}{1},'norm_spm8');
                                end
                            end
                            if isempty(CONN_x.Setup.functional{nsubject}{nsess_func(1)}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,1); end
                            temp=cellstr(CONN_x.Setup.functional{nsubject}{nsess_func(1)}{1});
                            if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                            if coregtomean==2
                                if ~isempty(coregsource)&&iscell(coregsource)&&numel(coregsource)>=isubject
                                    xtemp={coregsource{isubject}};
                                elseif numel(CONN_x.Setup.coregsource_functional)>=nsubject
                                    xtemp=CONN_x.Setup.coregsource_functional{nsubject}(1);
                                else error('missing coregsource info');
                                end
                            elseif coregtomean,
                                [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                if isempty(xtemp),  errmsg=['Error preparing files for coregistration. Mean functional file not found (err',failed,')']; disp(errmsg); error(errmsg); end
                                xtemp={xtemp};
                            else xtemp=ttemp(1);
                            end
                            matlabbatch{end+1}.spm.spatial.coreg.estimate.source=xtemp;
                            matlabbatch{end}.spm.spatial.coreg.estimate.ref={reffile};
                            if coregtomean, matlabbatch{end}.spm.spatial.coreg.estimate.other=xtemp;
                            else matlabbatch{end}.spm.spatial.coreg.estimate.other={};
                            end
                            for nsestrue=nsess_func(:)'
                                if isempty(CONN_x.Setup.functional{nsubject}{nsestrue}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nsestrue); end
                                temp=cellstr(CONN_x.Setup.functional{nsubject}{nsestrue}{1});
                                if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                                matlabbatch{end}.spm.spatial.coreg.estimate.other=cat(1,matlabbatch{end}.spm.spatial.coreg.estimate.other,ttemp);
                            end
                        end
                    end
                end
                if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
            end
            if DOSPM12
                %note: structural_template disregarded (using tissue probability maps instead)
                matlabbatch{end+1}.spm.spatial.normalise.estwrite.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.vox=voxelsize_anat.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.interp=interp; end
                if ~isempty(tpm_template), matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.tpm=reshape(cellstr(tpm_template),[],1); end
                if ~isempty(affreg), matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.affreg=affreg; end
            else
                %note: tissue probability maps disregarded (using structural template instead)
                matlabbatch{end+1}.spm.spatial.normalise.estwrite.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.estwrite.roptions.vox=voxelsize_anat.*[1 1 1];
                matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.template={structural_template};
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.interp=interp; end
            end
            jsubject=0;
            for isubject=1:numel(subjects), % structural normalize
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    if ismember(nses,sessions)
                        jsubject=jsubject+1;
                        if DOSPM12, matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).vol={CONN_x.Setup.structural{nsubject}{nses}{1}};
                        else        matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).source={CONN_x.Setup.structural{nsubject}{nses}{1}};
                        end
                        matlabbatch{end}.spm.spatial.normalise.estwrite.subj(jsubject).resample={CONN_x.Setup.structural{nsubject}{nses}{1}};
                        if DOSPM12, 
                            outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{5}=conn_prepend('y_',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                        else
                            outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{5}=conn_prepend('',CONN_x.Setup.structural{nsubject}{nses}{1},'_seg_sn.mat');
                        end
                    else
                        if DOSPM12, [outputfiles{isubject}{nses}{5},nill,outputfiles{isubject}{nses}{1}]=conn_setup_preproc_meanimage(CONN_x.Setup.structural{nsubject}{nses}{1},'norm_spm12');
                        else [outputfiles{isubject}{nses}{5},nill,outputfiles{isubject}{nses}{1}]=conn_setup_preproc_meanimage(CONN_x.Setup.structural{nsubject}{nses}{1},'norm_spm8');
                        end
                    end
                end
            end
            if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
            if DOSPM12
                matlabbatch{end+1}.spm.spatial.normalise.write.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.woptions.vox=voxelsize_anat.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.woptions.interp=interp; end
            else
                matlabbatch{end+1}.spm.spatial.normalise.write.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.roptions.vox=voxelsize_anat.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.roptions.interp=interp; end
            end
            doapplyfunctional=applytofunctional||strcmp(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),'functional_normalize_indirect');
            jsubject=0;
            for isubject=1:numel(subjects), % normalize write
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess_struct=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject))); 
                else nsess_struct=1; 
                end
                for nses=nsess_struct(:)'
                    if CONN_x.Setup.structural_sessionspecific, nsess_func=nses;
                    else nsess_func=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)));
                    end
                    if ismember(nses,sessions)||(doapplyfunctional&&any(ismember(nsess_func,sessions)))
                        jsubject=jsubject+1;
                        if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).def=outputfiles{isubject}{nses}(5);
                        else        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).matname=outputfiles{isubject}{nses}(5);
                        end
                        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample={};
                        if ismember(nses,sessions)
                            matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=outputfiles{isubject}{nses}(1);
                        end
                        outputfiles{isubject}{nses}=outputfiles{isubject}{nses}(1);
                        if doapplyfunctional
                            for nsestrue=nsess_func(:)'
                                if ismember(nsestrue,sessions)
                                    if isempty(CONN_x.Setup.functional{nsubject}{nsestrue}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nsestrue); end
                                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nsestrue}{1});
                                    if coregtomean, % keeps mean image in same space in case it is required later
                                        [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                        if ~isempty(xtemp),
                                            xtemp={xtemp};
                                            matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,xtemp);
                                        end
                                    end
                                    matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,temp);
                                    outputfiles{isubject}{nsestrue}{2}=char(conn_prepend('w',temp));
                                end
                            end
                        end
                    end
                    outputfiles{isubject}{nses}{1}=conn_prepend('w',outputfiles{isubject}{nses}{1});
                end
            end
            if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
            
        case {'structural_segment&normalize','functional_segment&normalize_indirect'}
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if strcmp(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),'functional_segment&normalize_indirect') 
                jsubject=0;
                for isubject=1:numel(subjects), % coregister
                    nsubject=subjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess_struct=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)));
                    else nsess_struct=1;
                    end
                    for nses_struct=nsess_struct(:)' %note: any structural targets for in-sessions functionals
                        if CONN_x.Setup.structural_sessionspecific, nsess_func=nses_struct;
                        else nsess_func=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)));
                        end
                        if ~isempty(nsess_func)
                            jsubject=jsubject+1;
                            if ismember(nses_struct,sessions), reffile=CONN_x.Setup.structural{nsubject}{nses_struct}{1};
                            else
                                if DOSPM12, [matfile,nill,reffile]=conn_setup_preproc_meanimage(CONN_x.Setup.structural{nsubject}{nses_struct}{1},'norm_spm12');
                                else [matfile,nill,reffile]=conn_setup_preproc_meanimage(CONN_x.Setup.structural{nsubject}{nses_struct}{1},'norm_spm8');
                                end
                            end
                            if isempty(CONN_x.Setup.functional{nsubject}{nsess_func(1)}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,1); end
                            temp=cellstr(CONN_x.Setup.functional{nsubject}{nsess_func(1)}{1});
                            if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                            if coregtomean==2
                                if ~isempty(coregsource)&&iscell(coregsource)&&numel(coregsource)>=isubject
                                    xtemp={coregsource{isubject}};
                                elseif numel(CONN_x.Setup.coregsource_functional)>=nsubject
                                    xtemp=CONN_x.Setup.coregsource_functional{nsubject}(1);
                                else error('missing coregsource info');
                                end
                            elseif coregtomean,
                                [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                if isempty(xtemp),  errmsg=['Error preparing files for coregistration. Mean functional file not found (err',failed,')']; disp(errmsg); error(errmsg); end
                                xtemp={xtemp};
                            else xtemp=ttemp(1);
                            end
                            matlabbatch{end+1}.spm.spatial.coreg.estimate.source=xtemp;
                            matlabbatch{end}.spm.spatial.coreg.estimate.ref={reffile};
                            if coregtomean, matlabbatch{end}.spm.spatial.coreg.estimate.other=xtemp;
                            else matlabbatch{end}.spm.spatial.coreg.estimate.other={};
                            end
                            for nsestrue=nsess_func(:)'
                                if isempty(CONN_x.Setup.functional{nsubject}{nsestrue}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nsestrue); end
                                temp=cellstr(CONN_x.Setup.functional{nsubject}{nsestrue}{1});
                                if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                                matlabbatch{end}.spm.spatial.coreg.estimate.other=cat(1,matlabbatch{end}.spm.spatial.coreg.estimate.other,ttemp);
                            end
                        end
                    end
                end
                if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
            end
            if DOSPM12, matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
            else  matlabbatch{end+1}.spm.spatial.preproc.data={};
            end
            jsubject=0;
            for isubject=1:numel(subjects), % structural segment&normalize
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess % all structurals (in-sessions or not)
                    if ismember(nses,sessions)
                        jsubject=jsubject+1;
                        if DOSPM12, 
                            matlabbatch{end}.spm.spatial.preproc.channel.vols{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{5}=conn_prepend('y_',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');  % note: fix SPM12 issue converting .img to .nii
                        else
                            matlabbatch{end}.spm.spatial.preproc.data{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                            outputfiles{isubject}{nses}{5}=conn_prepend('',CONN_x.Setup.structural{nsubject}{nses}{1},'_seg_sn.mat');
                        end
                    else
                        if DOSPM12, [outputfiles{isubject}{nses}{5},nill,outputfiles{isubject}{nses}{1}]=conn_setup_preproc_meanimage(CONN_x.Setup.structural{nsubject}{nses}{1},'norm_spm12');
                        else [outputfiles{isubject}{nses}{5},nill,outputfiles{isubject}{nses}{1}]=conn_setup_preproc_meanimage(CONN_x.Setup.structural{nsubject}{nses}{1},'norm_spm8');
                        end
                    end
                    if DOSPM12, 
                        outputfiles{isubject}{nses}{2}=conn_prepend('c1',outputfiles{isubject}{nses}{1},'.nii'); % note: fix SPM12 issue converting .img to .nii
                        outputfiles{isubject}{nses}{3}=conn_prepend('c2',outputfiles{isubject}{nses}{1},'.nii');
                        outputfiles{isubject}{nses}{4}=conn_prepend('c3',outputfiles{isubject}{nses}{1},'.nii');
                    else
                        outputfiles{isubject}{nses}{2}=conn_prepend('c1',outputfiles{isubject}{nses}{1});
                        outputfiles{isubject}{nses}{3}=conn_prepend('c2',outputfiles{isubject}{nses}{1});
                        outputfiles{isubject}{nses}{4}=conn_prepend('c3',outputfiles{isubject}{nses}{1});
                    end
                end
            end
            if DOSPM12
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(n),'native',[1 0],'warped',[0 0]);
                    end
                end
                if ~isempty(affreg), matlabbatch{end}.spm.spatial.preproc.warp.affreg=affreg; end
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
                matlabbatch{end+1}.spm.spatial.normalise.write.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.woptions.vox=voxelsize_anat.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.woptions.interp=interp; end
            else
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
                if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
                matlabbatch{end+1}.spm.spatial.normalise.write.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.roptions.vox=voxelsize_anat.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.roptions.interp=interp; end
            end
            doapplyfunctional=applytofunctional||strcmp(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),'functional_segment&normalize_indirect');
            jsubject=0;
            for isubject=1:numel(subjects), % normalize write
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess_struct=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject))); 
                else nsess_struct=1; 
                end
                for nses=nsess_struct(:)' %note: any structural targets for in-sessions functionals
                    if CONN_x.Setup.structural_sessionspecific, nsess_func=nses;
                    else nsess_func=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)));
                    end
                    if ismember(nses,sessions)||(doapplyfunctional&&any(ismember(nsess_func,sessions)))
                        jsubject=jsubject+1;
                        if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).def=outputfiles{isubject}{nses}(5);
                        else        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).matname=outputfiles{isubject}{nses}(5);
                        end
                        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample={};
                        if ismember(nses,sessions)
                            matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=outputfiles{isubject}{nses}(1:4)';
                        end
                        outputfiles{isubject}{nses}=outputfiles{isubject}{nses}(1:4);
                        if doapplyfunctional
                            for nsestrue=nsess_func(:)'
                                if ismember(nsestrue,sessions)
                                    if isempty(CONN_x.Setup.functional{nsubject}{nsestrue}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nsestrue); end
                                    temp=cellstr(CONN_x.Setup.functional{nsubject}{nsestrue}{1});
                                    if coregtomean, % keeps mean image in same space in case it is required later
                                        [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                        if ~isempty(xtemp),
                                            xtemp={xtemp};
                                            matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,xtemp);
                                        end
                                    end
                                    matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,temp);
                                    outputfiles{isubject}{nsestrue}{5}=char(conn_prepend('w',temp));
                                end
                            end
                        end
                    end
                end
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    outputfiles{isubject}{nses}{1}=conn_prepend('w',outputfiles{isubject}{nses}{1});
                    outputfiles{isubject}{nses}{2}=conn_prepend('w',outputfiles{isubject}{nses}{2});
                    outputfiles{isubject}{nses}{3}=conn_prepend('w',outputfiles{isubject}{nses}{3});
                    outputfiles{isubject}{nses}{4}=conn_prepend('w',outputfiles{isubject}{nses}{4});
                end
            end
            if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
            jsubject=0;
            for isubject=1:numel(subjects), % imcalc
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    if ismember(nses,sessions)
                        jsubject=jsubject+1;
                        matlabbatch{end+1}.spm.util.imcalc.expression='(i2+i3+i4).*i1';
                        matlabbatch{end}.spm.util.imcalc.input=reshape(outputfiles{isubject}{nses}(1:4),[],1);
                        matlabbatch{end}.spm.util.imcalc.output=conn_prepend('wc0',CONN_x.Setup.structural{nsubject}{nses}{1});
                        matlabbatch{end}.spm.util.imcalc.options.dtype=spm_type('float32');
                    end
                    outputfiles{isubject}{nses}{1}=conn_prepend('wc0',conn_prepend(-1,outputfiles{isubject}{nses}{1}));
                end
            end
            
        case {'functional_coregister_nonlinear'}
            % functional segment&normalize
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12, matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
            else matlabbatch{end+1}.spm.spatial.preproc.data={};
            end
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if isempty(CONN_x.Setup.functional{nsubject}{sessions(1)}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,1); end
                temp=cellstr(CONN_x.Setup.functional{nsubject}{sessions(1)}{1});
                if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                if coregtomean==2
                    if ~isempty(coregsource)&&iscell(coregsource)&&numel(coregsource)>=isubject
                        xtemp={coregsource{isubject}};
                    elseif numel(CONN_x.Setup.coregsource_functional)>=nsubject
                        xtemp=CONN_x.Setup.coregsource_functional{nsubject}(1);
                    else error('missing coregsource info');
                    end
                elseif coregtomean,
                    [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                    if isempty(xtemp),  errmsg=['Error preparing files for normalization. Mean functional file not found (err',failed,')']; disp(errmsg); error(errmsg); end
                    xtemp={xtemp};
                else xtemp=ttemp(1);
                end
                if DOSPM12,
                    matlabbatch{end}.spm.spatial.preproc.channel.vols{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('y_',xtemp{1},'.nii');
                else
                    matlabbatch{end}.spm.spatial.preproc.data{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('',xtemp{1},'_seg_sn.mat');
                end
            end
            if DOSPM12,
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(n),'native',[1 0],'warped',[1 0]);
                    end
                end
                if ~isempty(affreg), matlabbatch{end}.spm.spatial.preproc.warp.affreg=affreg; end
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
                matlabbatch{end+1}.spm.spatial.normalise.write.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.woptions.vox=voxelsize_func.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.woptions.interp=interp; end
            else
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
                matlabbatch{end+1}.spm.spatial.normalise.write.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.roptions.vox=voxelsize_func.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.roptions.interp=interp; end
            end
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).def=outputfiles{isubject}(2);
                else        matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).matname=outputfiles{isubject}(2);
                end
                matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).resample=outputfiles{isubject}(1);
                
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                outputfiles{isubject}=repmat({},1,nsess);
                for nses=1:nsess
                    if ismember(nses,sessions)
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                        matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).resample,ttemp);
                        outputfiles{isubject}{nses}{7}=char(conn_prepend('w',temp));
                    end
                end
            end            
            
            % structural segment/normalize
            if DOSPM12, matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
            else  matlabbatch{end+1}.spm.spatial.preproc.data={};
            end
            jsubject=0;
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    if ismember(nses,sessions)
                        jsubject=jsubject+1;
                        if DOSPM12, matlabbatch{end}.spm.spatial.preproc.channel.vols{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        else matlabbatch{end}.spm.spatial.preproc.data{jsubject}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        end
                    end
                    if DOSPM12
                        outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{2}=conn_prepend('c1',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii'); % note: fix SPM12 issue converting .img to .nii
                        outputfiles{isubject}{nses}{3}=conn_prepend('c2',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                        outputfiles{isubject}{nses}{4}=conn_prepend('c3',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                        outputfiles{isubject}{nses}{5}=conn_prepend('y_',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                        outputfiles{isubject}{nses}{6}=conn_prepend('iy_',CONN_x.Setup.structural{nsubject}{nses}{1},'.nii');
                    else
                        outputfiles{isubject}{nses}{1}=CONN_x.Setup.structural{nsubject}{nses}{1};
                        outputfiles{isubject}{nses}{2}=conn_prepend('c1',CONN_x.Setup.structural{nsubject}{nses}{1});
                        outputfiles{isubject}{nses}{3}=conn_prepend('c2',CONN_x.Setup.structural{nsubject}{nses}{1});
                        outputfiles{isubject}{nses}{4}=conn_prepend('c3',CONN_x.Setup.structural{nsubject}{nses}{1});
                        outputfiles{isubject}{nses}{5}=conn_prepend('',CONN_x.Setup.structural{nsubject}{nses}{1},'_seg_sn.mat');
                        outputfiles{isubject}{nses}{6}=conn_prepend('',CONN_x.Setup.structural{nsubject}{nses}{1},'_seg_inv_sn.mat');
                    end
                end
            end
            if DOSPM12
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(n),'native',[1 0],'warped',[0 0]);
                    end
                end
                if ~isempty(affreg), matlabbatch{end}.spm.spatial.preproc.warp.affreg=affreg; end
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
                matlabbatch{end+1}.spm.spatial.normalise.write.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.woptions.vox=voxelsize_anat.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.woptions.interp=interp; end
            else
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox; %
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
                if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
                matlabbatch{end+1}.spm.spatial.normalise.write.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.roptions.vox=voxelsize_anat.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.roptions.interp=interp; end
            end
            jsubject=0;
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    if CONN_x.Setup.structural_sessionspecific, nsesstrue=nses;
                    else nsesstrue=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    end
                    if ismember(nses,sessions)||any(ismember(nsesstrue,sessions))
                        if ismember(nses,sessions), 
                            jsubject=jsubject+1; % write struct normed (optional)
                            if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).def=outputfiles{isubject}{nses}(5);
                            else        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).matname=outputfiles{isubject}{nses}(5);
                            end
                            matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=outputfiles{isubject}{nses}(1:4)'; 
                        end
                        if any(ismember(nsesstrue,sessions))
                            jsubject=jsubject+1; % write func inv normed
                            if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).def=outputfiles{isubject}{nses}(6);
                            else        matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).matname=outputfiles{isubject}{nses}(6);
                            end
                            matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample={};%outputfiles{isubject}{nses}(1:4)';
                            %outputfiles{isubject}{nses}=outputfiles{isubject}{nses}(1:4);
                            for nsestrue=nsesstrue
                                if ismember(nsestrue,sessions)
                                    temp=cellstr(outputfiles{isubject}{nsestrue}{7});
                                    %if isempty(CONN_x.Setup.functional{nsubject}{nsestrue}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nsestrue); end
                                    %temp=cellstr(CONN_x.Setup.functional{nsubject}{nsestrue}{1});
                                    if coregtomean, % keeps mean image in same space in case it is required later
                                        [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                        if ~isempty(xtemp),
                                            xtemp={xtemp};
                                            matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,xtemp);
                                        end
                                    end
                                    matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(jsubject).resample,temp);
                                    outputfiles{isubject}{nsestrue}{7}=char(conn_prepend('w',temp));
                                end
                            end
                        end
                    end
                    %outputfiles{isubject}{nses}{1}=conn_prepend('w',outputfiles{isubject}{nses}{1});
                    %outputfiles{isubject}{nses}{2}=conn_prepend('w',outputfiles{isubject}{nses}{2});
                    %outputfiles{isubject}{nses}{3}=conn_prepend('w',outputfiles{isubject}{nses}{3});
                    %outputfiles{isubject}{nses}{4}=conn_prepend('w',outputfiles{isubject}{nses}{4});
                end
            end
            if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
            jsubject=0;
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                for nses=1:nsess
                    if ismember(nses,sessions)
                        jsubject=jsubject+1;
                        matlabbatch{end+1}.spm.util.imcalc.expression='(i2+i3+i4).*i1';
                        matlabbatch{end}.spm.util.imcalc.input=reshape(conn_prepend('w',outputfiles{isubject}{nses}(1:4)),[],1);
                        matlabbatch{end}.spm.util.imcalc.output=conn_prepend('wc0',CONN_x.Setup.structural{nsubject}{nses}{1});
                        matlabbatch{end}.spm.util.imcalc.options.dtype=spm_type('float32');
                        jsubject=jsubject+1;
                        matlabbatch{end+1}.spm.util.imcalc.expression='(i2+i3+i4).*i1';
                        matlabbatch{end}.spm.util.imcalc.input=reshape(outputfiles{isubject}{nses}(1:4),[],1);
                        matlabbatch{end}.spm.util.imcalc.output=conn_prepend('c0',CONN_x.Setup.structural{nsubject}{nses}{1});
                        matlabbatch{end}.spm.util.imcalc.options.dtype=spm_type('float32');
                    end
                    outputfiles{isubject}{nses}{1}=conn_prepend('c0',CONN_x.Setup.structural{nsubject}{nses}{1});
                end
            end
            
        case 'functional_slicetime'
            sliceorder_all=sliceorder;
            if ~iscell(sliceorder_all),sliceorder_all={sliceorder_all}; end
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if isubject<=numel(sliceorder_all), sliceorder=sliceorder_all{min(numel(sliceorder_all),isubject)}; end
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    if ismember(nses,sessions)
                        matlabbatch{end+1}.spm.temporal.st.scans={};
                        nslice=CONN_x.Setup.functional{nsubject}{nses}{3}(1).dim(3);
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        if numel(temp)==1,
                            temp=cellstr(conn_expandframe(temp{1}));
                        end
                        matlabbatch{end}.spm.temporal.st.scans{end+1}=temp;
                    
                        matlabbatch{end}.spm.temporal.st.tr=CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubject));
                        matlabbatch{end}.spm.temporal.st.nslices=nslice;
                        if isempty(ta), matlabbatch{end}.spm.temporal.st.ta=CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubject))*(1-1/nslice);
                        else matlabbatch{end}.spm.temporal.st.ta=ta(min(numel(ta),nsubject));
                        end
                        while (numel(unique(sliceorder))~=nslice||max(sliceorder)~=nslice||min(sliceorder)~=1) && (numel(sliceorder)~=nslice||any(sliceorder<0|sliceorder>CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubject))*1000))
                            if isempty(sliceorder_select)
                                if ~isempty(sliceorder),
                                    conn_msgbox({['Subject ',num2str(nsubject),' Session ',num2str(nses), ' Incorrectly defined slice order vector'],[num2str(nslice),' slices']},'',2);
                                    sliceorder_select=[];
                                end
                                if isempty(sliceorder_select)
                                    [sliceorder_select,tok] = listdlg('PromptString',['Select slice order (subject ',num2str(nsubject),' session ',num2str(nses),'):'],'SelectionMode','single','ListString',[sliceorder_select_options,{'manually define'}]);
                                end
                                if isempty(sliceorder_select), return; end
                            end
                            switch(sliceorder_select)
                                case 1, sliceorder=1:nslice;        % ascending
                                case 2, sliceorder=nslice:-1:1;     % descending
                                case 3, sliceorder=round((nslice-(1:nslice))/2 + (rem((nslice-(1:nslice)),2) * (nslice - 1)/2)) + 1; % interleaved (middle-top)
                                case 4, sliceorder=[1:2:nslice 2:2:nslice]; % interleaved (bottom-up)
                                case 5, sliceorder=[nslice:-2:1, nslice-1:-2:1]; % interleaved (top-down)
                                case 6, sliceorder=[fliplr(nslice:-2:1) fliplr(nslice-1:-2:1)]; % interleaved (Siemens)
                                case 7, % BIDS
                                    [xtemp,failed]=conn_setup_preproc_meanimage(matlabbatch{end}.spm.temporal.st.scans{1}{1},'json');
                                    if ~isempty(xtemp),
                                        str=spm_jsonread(xtemp);
                                        if isfield(str,'SliceTiming'), sliceorder=1000*str.SliceTiming;
                                        else fprintf('ERROR: SliceTiming field not found in json file %s (new user-input required)\n',xtemp);
                                        end
                                    else fprintf('ERROR: No json file found associated with %s (new user-input required)\n',matlabbatch{end}.spm.temporal.st.scans{1});
                                    end
                                case 8, % manually define
                                    sliceorder=1:nslice;
                                    sliceorder=inputdlg(['Slice order? (enter slice indexes from z=1 -first slice in image- to z=',num2str(nslice),' -last slice- in the order they were acquired). Alternatively enter acquisition time of each slice in milliseconds (e.g. for multiband sequences)'],'conn_setup_preproc',1,{sprintf('%d ',sliceorder)});
                                    if isempty(sliceorder), return;
                                    else sliceorder=str2num(regexprep(sliceorder{1},'[a-zA-Z]+',num2str(nslice)));
                                    end
                            end
                            if (numel(unique(sliceorder))~=nslice||max(sliceorder)~=nslice||min(sliceorder)~=1) && (numel(sliceorder)~=nslice||any(sliceorder<0|sliceorder>CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubject))*1000)), sliceorder_select=[]; end
                        end
                        matlabbatch{end}.spm.temporal.st.so=sliceorder;
                        if (numel(unique(sliceorder))~=nslice||max(sliceorder)~=nslice||min(sliceorder)~=1), matlabbatch{end}.spm.temporal.st.refslice=mean(sliceorder); % slice timing (ms)
                        else matlabbatch{end}.spm.temporal.st.refslice=sliceorder(floor(nslice/2)); % slice order
                        end
                        if isempty(matlabbatch{end}.spm.temporal.st.scans), matlabbatch=matlabbatch(1:end-1); end
                        if ~isempty(sliceorder_select)&&all(sliceorder_select<8), sliceorder=[]; end
                    end
                    outputfiles{isubject}{nses}=char(conn_prepend('a',cellstr(CONN_x.Setup.functional{nsubject}{nses}{1})));
                end
            end
            
        case 'functional_realign_noreslice'
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                matlabbatch{end+1}.spm.spatial.realign.estwrite.data={};
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    if ismember(nses,sessions)
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        temp1=temp{1};
                        matlabbatch{end}.spm.spatial.realign.estwrite.data{end+1}=temp;
                        outputfiles{isubject}{nses}{1}=char(temp);
                        outputfiles{isubject}{nses}{2}=conn_prepend('rp_',temp1,'.txt');
                    end
                end
                matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm=0;
                matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which=[0,1];
                if isempty(matlabbatch{end}.spm.spatial.realign.estwrite.data), matlabbatch=matlabbatch(1:end-1); end
            end
            
        case 'functional_realign'
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                matlabbatch{end+1}.spm.spatial.realign.estwrite.data={};
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    if ismember(nses,sessions)
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        temp1=temp{1};
                        matlabbatch{end}.spm.spatial.realign.estwrite.data{end+1}=temp;
                        outputfiles{isubject}{nses}{1}=char(conn_prepend('r',temp));
                        outputfiles{isubject}{nses}{2}=conn_prepend('rp_',temp1,'.txt');
                    end
                end
                matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm=0;
                matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which=[2,1];
                if isempty(matlabbatch{end}.spm.spatial.realign.estwrite.data), matlabbatch=matlabbatch(1:end-1); end
            end
            
        case 'functional_realign&unwarp'
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                matlabbatch{end+1}.spm.spatial.realignunwarp.eoptions.rtm=0;
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                jses=0;
                for nses=1:nsess
                    if ismember(nses,sessions)
                        jses=jses+1;
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                        matlabbatch{end}.spm.spatial.realignunwarp.data(jses).scans=ttemp;
                        outputfiles{isubject}{nses}{1}=char(conn_prepend('u',temp));
                        outputfiles{isubject}{nses}{2}=conn_prepend('rp_',temp{1},'.txt');
                    end
                end
                if ~jses, matlabbatch=matlabbatch(1:end-1); end
            end
            
        case {'functional_realign&unwarp&fieldmap','functional_realign&unwarp&phasemap'}
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                matlabbatch{end+1}.spm.spatial.realignunwarp.eoptions.rtm=0;
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                jses=0;
                for nses=1:nsess
                    if ismember(nses,sessions)
                        jses=jses+1;
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                        if ~isempty(unwarp)&&iscell(unwarp)&&numel(unwarp)>=isubject&&numel(unwarp{isubject})>=nses
                            tmfile=unwarp{isubject}{nses};
                        elseif numel(CONN_x.Setup.unwarp_functional)>=nsubject&&numel(CONN_x.Setup.unwarp_functional{nsubject})>=nses
                            tmfile=CONN_x.Setup.unwarp_functional{nsubject}{nses}{1};
                        else
                            tmfile=conn_prepend('vdm',ttemp{1});
                            if ~conn_existfile(tmfile)
                                tmfile=dir(fullfile(fileparts(ttemp{1}),'vdm*'));
                                if numel(tmfile)==1, tmfile=fullfile(fileparts(ttemp{1}),tmfile(1).name); else tmfile=''; end
                            end
                        end
                        if isempty(tmfile), tmfile=spm_select(1,'^vdm.*',['SUBJECT ',num2str(nsubject),'SESSION ',num2str(nses),' Phase Map volume (vdm*)'],{tmfile},fileparts(ttemp{1})); end
                        if isempty(tmfile),return;end
                        matlabbatch{end}.spm.spatial.realignunwarp.data(jses).scans=ttemp;
                        matlabbatch{end}.spm.spatial.realignunwarp.data(jses).pmscan={tmfile};
                        outputfiles{isubject}{nses}{1}=char(conn_prepend('u',temp));
                        outputfiles{isubject}{nses}{2}=conn_prepend('rp_',temp{1},'.txt');
                    end
                end
                if ~jses, matlabbatch=matlabbatch(1:end-1); end
            end
            
        case 'functional_art'
            icov=find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'realignment'));
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                matlabbatch{end+1}.art.P={};
                matlabbatch{end}.art.M={};
                matlabbatch{end}.art.global_threshold=art_global_threshold;
                matlabbatch{end}.art.motion_threshold=art_motion_threshold;
                matlabbatch{end}.art.use_diff_motion=art_use_diff_motion;
                matlabbatch{end}.art.use_diff_global=art_use_diff_global;
                matlabbatch{end}.art.use_norms=art_use_norms;
                matlabbatch{end}.art.drop_flag=art_drop_flag;
                matlabbatch{end}.art.gui_display=art_gui_display;
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    if ismember(nses,sessions)
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        temp1=temp{1};
                        matlabbatch{end}.art.P{end+1}=char(temp);
                        if isempty(icov),
                            for remov=0:10,if conn_existfile(conn_prepend('rp_',conn_prepend(-remov,temp1),'.txt')); break; end; end
                            if remov==10, errmsg=['Error preparing files for ART processing. No ''realignment'' covariate; alternative realignment parameters file ',conn_prepend('rp_',temp1,'.txt'),' not found']; disp(errmsg); error(errmsg); end
                            matlabbatch{end}.art.M{end+1}=conn_prepend('rp_',conn_prepend(-remov,temp1),'.txt');
                            matlabbatch{end}.art.motion_file_type=0;
                        else
                            matlabbatch{end}.art.M{end+1}=CONN_x.Setup.l1covariates.files{nsubject}{icov}{nses}{1};
                            [nill,fname,fext]=fileparts(matlabbatch{end}.art.M{end});
                            matlabbatch{end}.art.motion_file_type=0;
                            if isequal(lower(fext),'.par'), matlabbatch{end}.art.motion_file_type=1;
                            elseif isequal(lower(fext),'.txt')&&~isempty(regexp(lower(fname),'\.siemens$')), matlabbatch{end}.art.motion_file_type=2;
                            elseif isequal(lower(fext),'.txt')&&~isempty(regexp(lower(fname),'\.deg$')), matlabbatch{end}.art.motion_file_type=3;
                            end
                        end
                        outputfiles{isubject}{nses}{1}=conn_prepend('art_regression_outliers_',temp1,'.mat');
                        outputfiles{isubject}{nses}{2}=conn_prepend('art_regression_timeseries_',temp1,'.mat');
                        if nses==sessions(1), matlabbatch{end}.art.output_dir=fileparts(temp1); end
                    end
                end
                if isempty(matlabbatch{end}.art.P), matlabbatch=matlabbatch(1:end-1); end
            end
            
        case {'functional_coregister','functional_coregister_affine'}
            jsubject=0;
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if CONN_x.Setup.structural_sessionspecific, nsess_struct=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject))); 
                else nsess_struct=1; 
                end
                for nses_struct=nsess_struct(:)'
                    if CONN_x.Setup.structural_sessionspecific, nsess_func=nses_struct;
                    else nsess_func=intersect(sessions,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject))); 
                    end
                    if ~isempty(nsess_func)
                        jsubject=jsubject+1;
                        if isempty(CONN_x.Setup.functional{nsubject}{nsess_func(1)}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,1); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nsess_func(1)}{1});
                        if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                        if coregtomean==2
                            if ~isempty(coregsource)&&iscell(coregsource)&&numel(coregsource)>=isubject
                                xtemp={coregsource{isubject}};
                            elseif numel(CONN_x.Setup.coregsource_functional)>=nsubject
                                xtemp=CONN_x.Setup.coregsource_functional{nsubject}(1);
                            else error('missing coregsource info');
                            end
                        elseif coregtomean,
                            [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                            if isempty(xtemp),  errmsg=['Error preparing files for coregistration. Mean functional file not found (err',failed,')']; disp(errmsg); error(errmsg); end
                            xtemp={xtemp};
                        else xtemp=ttemp(1);
                        end
                        matlabbatch{end+1}.spm.spatial.coreg.estimate.source=xtemp;
                        matlabbatch{end}.spm.spatial.coreg.estimate.ref=CONN_x.Setup.structural{nsubject}{nses_struct}(1);
                        if coregtomean, matlabbatch{end}.spm.spatial.coreg.estimate.other=xtemp;
                        else matlabbatch{end}.spm.spatial.coreg.estimate.other={};
                        end
                        for nsestrue=nsess_func(:)'
                            if isempty(CONN_x.Setup.functional{nsubject}{nsestrue}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nsestrue); end
                            temp=cellstr(CONN_x.Setup.functional{nsubject}{nsestrue}{1});
                            if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                            matlabbatch{end}.spm.spatial.coreg.estimate.other=cat(1,matlabbatch{end}.spm.spatial.coreg.estimate.other,ttemp);
                        end
                    end
                end
            end
            if ~jsubject, matlabbatch=matlabbatch(1:end-1); end
            
        case 'functional_segment'
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12, matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
            else matlabbatch{end+1}.spm.spatial.preproc.data={};
            end
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if isempty(CONN_x.Setup.functional{nsubject}{sessions(1)}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,1); end
                temp=cellstr(CONN_x.Setup.functional{nsubject}{sessions(1)}{1});
                if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                if coregtomean==2
                    if ~isempty(coregsource)&&iscell(coregsource)&&numel(coregsource)>=isubject
                        xtemp={coregsource{isubject}};
                    elseif numel(CONN_x.Setup.coregsource_functional)>=nsubject
                        xtemp=CONN_x.Setup.coregsource_functional{nsubject}(1);
                    else error('missing coregsource info');
                    end
                elseif coregtomean,
                    [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                    if isempty(xtemp),  errmsg=['Error preparing files for normalization. Mean functional file not found (err',failed,')']; disp(errmsg); error(errmsg); end
                    xtemp={xtemp};
                else xtemp=ttemp(1);
                end
                if DOSPM12,
                    matlabbatch{end}.spm.spatial.preproc.channel.vols{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('c1',xtemp{1},'.nii'); % note: fix SPM12 issue converting .img to .nii
                    outputfiles{isubject}{3}=conn_prepend('c2',xtemp{1},'.nii');
                    outputfiles{isubject}{4}=conn_prepend('c3',xtemp{1},'.nii');
                else
                    matlabbatch{end}.spm.spatial.preproc.data{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('c1',xtemp{1});
                    outputfiles{isubject}{3}=conn_prepend('c2',xtemp{1});
                    outputfiles{isubject}{4}=conn_prepend('c3',xtemp{1});
                end
            end
            if DOSPM12,
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(n),'native',[1 0],'warped',[0 0]);
                    end
                end
                if ~isempty(affreg), matlabbatch{end}.spm.spatial.preproc.warp.affreg=affreg; end
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
            else
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox; %
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
            end
            
        case {'functional_normalize','functional_normalize_direct'}
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12
                %note: functional_template disregarded (using tissue probability maps instead)
                matlabbatch{end+1}.spm.spatial.normalise.estwrite.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.vox=voxelsize_func.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.interp=interp; end
                if ~isempty(tpm_template), matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.tpm=reshape(cellstr(tpm_template),[],1); end
                if ~isempty(affreg), matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.affreg=affreg; end
            else
                %note: tissue probability maps disregarded (using functional_template instead)
                matlabbatch{end+1}.spm.spatial.normalise.estwrite.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.estwrite.roptions.vox=voxelsize_func.*[1 1 1];
                matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.template={functional_template};
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.interp=interp; end
            end
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if isempty(CONN_x.Setup.functional{nsubject}{sessions(1)}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,1); end
                temp=cellstr(CONN_x.Setup.functional{nsubject}{sessions(1)}{1});
                if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                if coregtomean==2
                    if ~isempty(coregsource)&&iscell(coregsource)&&numel(coregsource)>=isubject
                        xtemp={coregsource{isubject}};
                    elseif numel(CONN_x.Setup.coregsource_functional)>=nsubject
                        xtemp=CONN_x.Setup.coregsource_functional{nsubject}(1);
                    else error('missing coregsource info');
                    end
                elseif coregtomean,
                    [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                    if isempty(xtemp),  errmsg=['Error preparing files for normalization. Mean functional file not found (err',failed,')']; disp(errmsg); error(errmsg); end
                    xtemp={xtemp};
                else xtemp=ttemp(1);
                end
                if DOSPM12, matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).vol=xtemp;
                else        matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).source=xtemp;
                end
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                if coregtomean, matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).resample=xtemp;
                else matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).resample={};
                end
                for nses=1:nsess
                    if ismember(nses,sessions)
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                        matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.estwrite.subj(isubject).resample,ttemp);
                        outputfiles{isubject}{nses}=char(conn_prepend('w',temp));
                    end
                end
            end
            
        case {'functional_segment&normalize','functional_segment&normalize_direct'}
            DOSPM12=~PREFERSPM8OVERSPM12&spmver12; %SPM12/SPM8
            if DOSPM12, matlabbatch{end+1}.spm.spatial.preproc.channel.vols={};
            else matlabbatch{end+1}.spm.spatial.preproc.data={};
            end
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if isempty(CONN_x.Setup.functional{nsubject}{sessions(1)}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,1); end
                temp=cellstr(CONN_x.Setup.functional{nsubject}{sessions(1)}{1});
                if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                if coregtomean==2
                    if ~isempty(coregsource)&&iscell(coregsource)&&numel(coregsource)>=isubject
                        xtemp={coregsource{isubject}};
                    elseif numel(CONN_x.Setup.coregsource_functional)>=nsubject
                        xtemp=CONN_x.Setup.coregsource_functional{nsubject}(1);
                    else error('missing coregsource info');
                    end
                elseif coregtomean,
                    [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                    if isempty(xtemp),  errmsg=['Error preparing files for normalization. Mean functional file not found (err',failed,')']; disp(errmsg); error(errmsg); end
                    xtemp={xtemp};
                else xtemp=ttemp(1);
                end
                if DOSPM12,
                    matlabbatch{end}.spm.spatial.preproc.channel.vols{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('c1',xtemp{1},'.nii'); % note: fix SPM12 issue converting .img to .nii
                    outputfiles{isubject}{3}=conn_prepend('c2',xtemp{1},'.nii');
                    outputfiles{isubject}{4}=conn_prepend('c3',xtemp{1},'.nii');
                    outputfiles{isubject}{5}=conn_prepend('y_',xtemp{1},'.nii');
                else
                    matlabbatch{end}.spm.spatial.preproc.data{isubject}=xtemp{1};
                    outputfiles{isubject}{1}=xtemp{1};
                    outputfiles{isubject}{2}=conn_prepend('c1',xtemp{1});
                    outputfiles{isubject}{3}=conn_prepend('c2',xtemp{1});
                    outputfiles{isubject}{4}=conn_prepend('c3',xtemp{1});
                    outputfiles{isubject}{5}=conn_prepend('',xtemp{1},'_seg_sn.mat');
                end
            end
            if DOSPM12,
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[1 1 2 3 4 2]; end % grey/white/CSF/bone/soft/air
                    for n=1:numel(temp)
                        matlabbatch{end}.spm.spatial.preproc.tissue(n)=struct('tpm',{temp(n)},'ngaus',tpm_ngaus(n),'native',[1 0],'warped',[1 0]);
                    end
                end
                if ~isempty(affreg), matlabbatch{end}.spm.spatial.preproc.warp.affreg=affreg; end
                matlabbatch{end}.spm.spatial.preproc.channel.vols=reshape(matlabbatch{end}.spm.spatial.preproc.channel.vols,[],1);
                matlabbatch{end}.spm.spatial.preproc.warp.write=[1 1];
                matlabbatch{end+1}.spm.spatial.normalise.write.woptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.woptions.vox=voxelsize_func.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.woptions.interp=interp; end
            else
                if ~isempty(tpm_template),
                    temp=cellstr(conn_expandframe(tpm_template));
                    if isempty(tpm_ngaus), tpm_ngaus=[2 2 2 4]; end % grey/white/CSF (+other implicit)
                    matlabbatch{end}.spm.spatial.preproc.opts.tpm=temp;
                    matlabbatch{end}.spm.spatial.preproc.opts.ngaus=ngaus(1:numel(temp)+1);
                end
                matlabbatch{end}.spm.spatial.preproc.roptions.bb=boundingbox; %
                matlabbatch{end}.spm.spatial.preproc.output.GM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.WM=[0,0,1];
                matlabbatch{end}.spm.spatial.preproc.output.CSF=[0,0,1];
                matlabbatch{end+1}.spm.spatial.normalise.write.roptions.bb=boundingbox;
                matlabbatch{end}.spm.spatial.normalise.write.roptions.vox=voxelsize_func.*[1 1 1];
                if ~isempty(interp), matlabbatch{end}.spm.spatial.normalise.write.roptions.interp=interp; end
            end
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                if DOSPM12, matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).def=outputfiles{isubject}(5);
                else        matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).matname=outputfiles{isubject}(5);
                end
                matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).resample=outputfiles{isubject}(1:4)';
                outputfiles{isubject}=outputfiles{isubject}(1:4);
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    if ismember(nses,sessions)
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        if numel(temp)==1, ttemp=cellstr(conn_expandframe(temp{1})); else ttemp=temp; end
                        matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).resample=cat(1,matlabbatch{end}.spm.spatial.normalise.write.subj(isubject).resample,ttemp);
                        outputfiles{isubject}{4+nses}=char(conn_prepend('w',temp));
                    end
                end
                outputfiles{isubject}{1}=conn_prepend('w',outputfiles{isubject}{1});
                outputfiles{isubject}{2}=conn_prepend('w',outputfiles{isubject}{2});
                outputfiles{isubject}{3}=conn_prepend('w',outputfiles{isubject}{3});
                outputfiles{isubject}{4}=conn_prepend('w',outputfiles{isubject}{4});
            end
            
        case 'functional_smooth'
            if size(fwhm,1)>1&&~iscell(fwhm), fwhm=num2cell(fwhm,2); end
            if iscell(fwhm), this_fwhm=fwhm{1}; fwhm=fwhm(2:end); 
            else this_fwhm=fwhm; 
            end
            if isempty(this_fwhm)
                this_fwhm=inputdlg('Enter smoothing FWHM (in mm)','conn_setup_preproc',1,{num2str(8)});
                if isempty(this_fwhm), return; end
                this_fwhm=str2num(this_fwhm{1});
            end
            matlabbatch{end+1}.spm.spatial.smooth.fwhm=[1 1 1].*this_fwhm;
            matlabbatch{end}.spm.spatial.smooth.data={};
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    if ismember(nses,sessions)
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        matlabbatch{end}.spm.spatial.smooth.data=cat(1,matlabbatch{end}.spm.spatial.smooth.data,temp);
                        outputfiles{isubject}{nses}=char(conn_prepend('s',temp));
                    end
                end
            end
            
        case 'functional_motionmask'
            for isubject=1:numel(subjects),
                nsubject=subjects(isubject);
                nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                for nses=1:nsess
                    if ismember(nses,sessions)
                        if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                        temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                        outputfiles{isubject}{nses}=temp;
                    end
                end
            end
            
        otherwise
            error(['unrecognized option ',STEP]);
    end
    
    if dogui&&ishandle(hmsg), delete(hmsg); end
    hmsg=[];
    if strncmp(lower(STEP),'interactive_',numel('interactive_'))
        doimport=false;
        if any(strcmpi(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),{'functional_art'}))
            for n=1:numel(matlabbatch)
                conn_art('sess_file',matlabbatch{n}.art);
            end
        elseif any(strcmpi(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),{'functional_removescans','functional_manualorient','structural_manualorient','functional_center','structural_center','functional_motionmask'}))
        elseif ~isempty(matlabbatch)
            try
                spm_jobman('initcfg');
                job_id=spm_jobman('interactive',matlabbatch);
                % outputs=cfg_util('getAllOutputs', job_id)
            catch
                ok=-1;
            end
        end
    else %if strncmp(lower(STEP),'run_',numel('run_'))
        if dogui, hmsg=conn_msgbox({['Performing ',STEP_name],'Please wait...'},'');
        else disp(['Performing ',STEP_name,'. Please wait...']);
        end
        if any(strcmpi(regexprep(lower(STEP),'^run_|^interactive_',''),{'functional_art'}))
            for n=1:numel(matlabbatch)
                if art_force_interactive, h=conn_art('sess_file',matlabbatch{n}.art);
                else h=conn_art('sess_file',matlabbatch{n}.art,'visible','off');
                end
                if strcmp(get(h,'name'),'art'), %close(h);
                elseif strcmp(get(gcf,'name'),'art'), h=gcf;%close(gcf);
                else h=findobj(0,'name','art'); %close(h);
                end
                if art_force_interactive, uiwait(h);
                else
                    try
                        if isfield(matlabbatch{n}.art,'output_dir')
                            conn_print(h,fullfile(matlabbatch{n}.art.output_dir,'art_screenshot.jpg'),'-nogui');
                        end
                        close(h);
                    end
                end
            end
        elseif any(strcmpi(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),{'functional_motionmask'}))
            for isubject=1:numel(outputfiles),
                for nses=1:numel(outputfiles{isubject})
                    if ismember(nses,sessions)
                        outputfiles{isubject}{nses}=conn_computeMaskMovement(outputfiles{isubject}{nses});
                    end
                end
            end
        elseif any(strcmpi(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),{'functional_removescans','functional_manualorient','structural_manualorient','structural_manualorient','functional_center','structural_center'}))
        elseif strncmp(lower(STEP),'update_',numel('update_'))
        elseif ~isempty(matlabbatch)
            spm_jobman('initcfg');
            debugskip=false;
            if ~debugskip
                warning('off','MATLAB:RandStream:ActivatingLegacyGenerators');
                job_id=spm_jobman('run',matlabbatch);
                warning('on','MATLAB:RandStream:ActivatingLegacyGenerators');
            end
        end
        if dogui&&ishandle(hmsg), delete(hmsg);
        else disp(['Done ',STEP_name]);
        end
        ok=1;
    end
    if ishandle(hmsg), delete(hmsg); end
    
    if ok>=0&&doimport
        if dogui, hmsg=conn_msgbox({'Importing results to CONN project','Please wait...'},'');
        else disp(['Importing results to CONN project. Please wait...']);
        end
        switch(regexprep(lower(STEP),'^run_|^update_|^interactive_',''))
            case 'functional_removescans'
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    for nses=1:numel(outputfiles{isubject})
                        if ismember(nses,sessions)
                            [CONN_x.Setup.functional{nsubject}{nses},V]=conn_file(outputfiles{isubject}{nses}{1});
                            CONN_x.Setup.nscans{nsubject}{nses}=numel(V);
                            for nl1covariate=1:numel(outputfiles{isubject}{nses})-1
                                if ~isempty(outputfiles{isubject}{nses}{1+nl1covariate})
                                    CONN_x.Setup.l1covariates.files{nsubject}{nl1covariate}{nses}={'[raw values]',[],outputfiles{isubject}{nses}{1+nl1covariate}};
                                end
                            end
                        end
                    end
                end
                
            case 'functional_manualorient'
                if iscell(reorient), treorient=reorient{1}; reorient=reorient(2:end);
                else treorient=reorient;
                end
                if ischar(treorient)
                    R=load(treorient,'-mat');
                    fR=fieldnames(R);
                    treorient=R.(fR{1});
                end
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    translation=[];
                    for nses=1:nsess
                        if ismember(nses,sessions)
                            if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                            temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                            if numel(temp)==1,
                                temp=cellstr(conn_expandframe(temp{1}));
                            end
                            if coregtomean, % keeps mean image in same space in case it is required later
                                [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                if ~isempty(xtemp), temp=[{xtemp};temp]; end
                            end
                            M=cell(1,numel(temp));
                            for n=1:numel(temp)
                                M{n}=spm_get_space(temp{n});
                                if isnan(treorient)
                                    if isempty(translation)
                                        translation=-M{n}(1:3,1:3)*CONN_x.Setup.functional{nsubject}{nses}{3}(1).dim'/2 - M{n}(1:3,4);
                                        try, R=eye(4);R(1:3,4)=translation; save(conn_prepend('centering_',temp{n},'.mat'),'R','-mat'); R=inv(R); save(conn_prepend('icentering_',temp{n},'.mat'),'R','-mat'); end
                                    end
                                    M{n}(1:3,4)=M{n}(1:3,4)+translation;
                                else
                                    if size(treorient,1)==4, R=treorient;
                                    else R=[treorient zeros(3,1); zeros(1,3) 1];
                                    end
                                    M{n}=R*M{n};
                                    if n==1, try, save(conn_prepend('reorient_',temp{n},'.mat'),'R','-mat'); R=inv(R); save(conn_prepend('ireorient_',temp{n},'.mat'),'R','-mat'); end; end
                                end
                            end
                            for n=1:numel(temp)
                                spm_get_space(temp{n},M{n});
                            end
                            [CONN_x.Setup.functional{nsubject}{nses},V]=conn_file(CONN_x.Setup.functional{nsubject}{nses}{1});
                        end
                    end
                end
                
            case 'structural_manualorient'
                SAVETODIFFERENTFILE=true;
                if iscell(reorient), treorient=reorient{1}; reorient=reorient(2:end);
                else treorient=reorient;
                end
                if ischar(treorient)
                    R=load(treorient,'-mat');
                    fR=fieldnames(R);
                    treorient=R.(fR{1});
                end
                jsubject=0;
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        if ismember(nses,sessions)
                            jsubject=jsubject+1;
                            temp=CONN_x.Setup.structural{nsubject}{nses}{1};
                            M=spm_get_space(temp);
                            if isnan(treorient)
                                translation=-M(1:3,1:3)*CONN_x.Setup.structural{nsubject}{nses}{3}(1).dim'/2 - M(1:3,4);
                                M(1:3,4)=M(1:3,4)+translation;
                                try, R=eye(4);R(1:3,4)=translation; save(conn_prepend('centering_',temp,'.mat'),'R','-mat'); R=inv(R); save(conn_prepend('icentering_',temp,'.mat'),'R','-mat'); end
                            else
                                if size(treorient,1)==4, R=treorient;
                                else R=[treorient zeros(3,1); zeros(1,3) 1];
                                end
                                M=R*M;
                                try, save(conn_prepend('reorient_',temp,'.mat'),'R','-mat'); R=inv(R); save(conn_prepend('ireorient_',temp,'.mat'),'R','-mat'); end
                            end
                            if SAVETODIFFERENTFILE
                                a=spm_vol(temp);
                                b=spm_read_vols(a);
                                temp=conn_prepend('c',temp);
                                a.fname=regexprep(temp,',\d+$','');
                                spm_write_vol(a,b);
                            end
                            spm_get_space(temp,M);
                            [CONN_x.Setup.structural{nsubject}{nses},V]=conn_file(temp);
                        end
                    end
                    if ~CONN_x.Setup.structural_sessionspecific, CONN_x.Setup.structural{nsubject}(2:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)))=CONN_x.Setup.structural{nsubject}(1); end
                end
                
            case {'functional_manualspatialdef'}
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses}{1});
                    end
                end
                
            case {'structural_manualspatialdef'}
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        if CONN_x.Setup.structural_sessionspecific, nses_struct=nses;
                        else nses_struct=1;
                        end
                        CONN_x.Setup.structural{nsubject}{nses}=conn_file(outputfiles{isubject}{nses_struct}{1});
                    end
                end
                
            case 'functional_center'
                treorient=nan;
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    translation=[];
                    for nses=1:nsess
                        if ismember(nses,sessions)
                            if isempty(CONN_x.Setup.functional{nsubject}{nses}{1}), error('Functional data not yet defined for subject %d session %d',nsubject,nses); end
                            temp=cellstr(CONN_x.Setup.functional{nsubject}{nses}{1});
                            if numel(temp)==1,
                                temp=cellstr(conn_expandframe(temp{1}));
                            end
                            if coregtomean, % keeps mean image in same space in case it is required later
                                [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                if ~isempty(xtemp), temp=[{xtemp};temp]; end
                            end
                            M=cell(1,numel(temp));
                            for n=1:numel(temp)
                                M{n}=spm_get_space(temp{n});
                                if isempty(translation)
                                    translation=-M{n}(1:3,1:3)*CONN_x.Setup.functional{nsubject}{nses}{3}(1).dim'/2 - M{n}(1:3,4);
                                    fprintf('Functional centering translation x/y/z = %s (Subject %d)\n',mat2str(translation'),nsubject);
                                    try, R=eye(4);R(1:3,4)=translation; save(conn_prepend('centering_',temp{n},'.mat'),'R','-mat'); R=inv(R); save(conn_prepend('icentering_',temp{n},'.mat'),'R','-mat'); end
                                end
                                M{n}(1:3,4)=M{n}(1:3,4)+translation;
                            end
                            for n=1:numel(temp)
                                spm_get_space(temp{n},M{n});
                            end
                            [CONN_x.Setup.functional{nsubject}{nses},V]=conn_file(CONN_x.Setup.functional{nsubject}{nses}{1});
                        end
                    end
                end
                
            case 'structural_center'
                SAVETODIFFERENTFILE=true;
                treorient=nan;
                jsubject=0;
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    if CONN_x.Setup.structural_sessionspecific, nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)); else nsess=1; end
                    for nses=1:nsess
                        if ismember(nses,sessions)
                            jsubject=jsubject+1;
                            temp=CONN_x.Setup.structural{nsubject}{nses}{1};
                            M=spm_get_space(temp);
                            translation=-M(1:3,1:3)*CONN_x.Setup.structural{nsubject}{nses}{3}(1).dim'/2 - M(1:3,4);
                            M(1:3,4)=M(1:3,4)+translation;
                            fprintf('Structural centering translation x/y/z = %s (Subject %d)\n',mat2str(translation'),nsubject);
                            try, R=eye(4);R(1:3,4)=translation; save(conn_prepend('centering_',temp,'.mat'),'R','-mat'); R=inv(R); save(conn_prepend('icentering_',temp,'.mat'),'R','-mat'); end
                            %M(1:3,4)=-M(1:3,1:3)*CONN_x.Setup.structural{nsubject}{nses}{3}(1).dim'/2;
                            if SAVETODIFFERENTFILE
                                a=spm_vol(temp);
                                b=spm_read_vols(a);
                                temp=conn_prepend('c',temp);
                                a.fname=regexprep(temp,',\d+$','');
                                spm_write_vol(a,b);
                            end
                            spm_get_space(temp,M);
                            [CONN_x.Setup.structural{nsubject}{nses},V]=conn_file(temp);
                        end
                    end
                    if ~CONN_x.Setup.structural_sessionspecific, CONN_x.Setup.structural{nsubject}(2:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)))=CONN_x.Setup.structural{nsubject}(1); end
                end
                
            case 'structural_segment'
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        if CONN_x.Setup.structural_sessionspecific, nses_struct=nses;
                        else nses_struct=1;
                        end
                        CONN_x.Setup.structural{nsubject}{nses}=conn_file(outputfiles{isubject}{nses_struct}{1});
                        CONN_x.Setup.rois.files{nsubject}{1}{nses}=conn_file(outputfiles{isubject}{nses_struct}{2});
                        CONN_x.Setup.rois.files{nsubject}{2}{nses}=conn_file(outputfiles{isubject}{nses_struct}{3});
                        CONN_x.Setup.rois.files{nsubject}{3}{nses}=conn_file(outputfiles{isubject}{nses_struct}{4});
                    end
                end
                
            case {'structural_segment&normalize','functional_segment&normalize_indirect'}
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        if CONN_x.Setup.structural_sessionspecific, nses_struct=nses;
                        else nses_struct=1;
                        end
                        CONN_x.Setup.structural{nsubject}{nses}=conn_file(outputfiles{isubject}{nses_struct}{1});
                        CONN_x.Setup.rois.files{nsubject}{1}{nses}=conn_file(outputfiles{isubject}{nses_struct}{2});
                        CONN_x.Setup.rois.files{nsubject}{2}{nses}=conn_file(outputfiles{isubject}{nses_struct}{3});
                        CONN_x.Setup.rois.files{nsubject}{3}{nses}=conn_file(outputfiles{isubject}{nses_struct}{4});
                        if applytofunctional||strcmp(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),'functional_segment&normalize_indirect'),
                            CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses}{5});
                        end
                    end
                end
                
            case 'functional_coregister_nonlinear'
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        if CONN_x.Setup.structural_sessionspecific, nses_struct=nses;
                        else nses_struct=1;
                        end
                        %CONN_x.Setup.structural{nsubject}{nses}=conn_file(outputfiles{isubject}{nses_struct}{1});
                        CONN_x.Setup.rois.files{nsubject}{1}{nses}=conn_file(outputfiles{isubject}{nses_struct}{2});
                        CONN_x.Setup.rois.files{nsubject}{2}{nses}=conn_file(outputfiles{isubject}{nses_struct}{3});
                        CONN_x.Setup.rois.files{nsubject}{3}{nses}=conn_file(outputfiles{isubject}{nses_struct}{4});
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses}{7});
                    end
                end
                
            case {'structural_normalize','functional_normalize_indirect'}
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        if CONN_x.Setup.structural_sessionspecific, nses_struct=nses;
                        else nses_struct=1;
                        end
                        CONN_x.Setup.structural{nsubject}{nses}=conn_file(outputfiles{isubject}{nses_struct}{1});
                        if applytofunctional||strcmp(regexprep(lower(STEP),'^run_|^update_|^interactive_',''),'functional_normalize_indirect'),
                            CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses}{5});
                        end
                    end
                end
                
            case 'functional_segment'
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        CONN_x.Setup.rois.files{nsubject}{1}{nses}=conn_file(outputfiles{isubject}{2});
                        CONN_x.Setup.rois.files{nsubject}{2}{nses}=conn_file(outputfiles{isubject}{3});
                        CONN_x.Setup.rois.files{nsubject}{3}{nses}=conn_file(outputfiles{isubject}{4});
                    end
                end
                
            case {'functional_segment&normalize','functional_segment&normalize_direct'}
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        CONN_x.Setup.rois.files{nsubject}{1}{nses}=conn_file(outputfiles{isubject}{2});
                        CONN_x.Setup.rois.files{nsubject}{2}{nses}=conn_file(outputfiles{isubject}{3});
                        CONN_x.Setup.rois.files{nsubject}{3}{nses}=conn_file(outputfiles{isubject}{4});
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{4+nses});
                    end
                end
                
            case {'functional_slicetime','functional_normalize','functional_normalize_direct','functional_smooth'}
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses});
                    end
                end
                
            case 'functional_art'
                icov=find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'QA_timeseries'));
                if isempty(icov),
                    icov=numel(CONN_x.Setup.l1covariates.names);
                    CONN_x.Setup.l1covariates.names{icov}='QA_timeseries';
                    CONN_x.Setup.l1covariates.names{icov+1}=' ';
                end
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        CONN_x.Setup.l1covariates.files{nsubject}{icov}{nses}=conn_file(outputfiles{isubject}{nses}{2});
                    end
                end
                icov0=icov;
                icov=find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'scrubbing'));
                if isempty(icov),
                    icov=numel(CONN_x.Setup.l1covariates.names);
                    CONN_x.Setup.l1covariates.names{icov}='scrubbing';
                    CONN_x.Setup.l1covariates.names{icov+1}=' ';
                end
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        CONN_x.Setup.l1covariates.files{nsubject}{icov}{nses}=conn_file(outputfiles{isubject}{nses}{1});
                    end
                end
                y1=zeros(CONN_x.Setup.nsubjects,1);y2=zeros(CONN_x.Setup.nsubjects,1);y3=nan(CONN_x.Setup.nsubjects,1);y4=zeros(CONN_x.Setup.nsubjects,1);y5=nan(CONN_x.Setup.nsubjects,1);y6=zeros(CONN_x.Setup.nsubjects,1);yok=true;
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject));
                    for nses=1:nsess
                        try
                            temp=load(CONN_x.Setup.l1covariates.files{nsubject}{icov}{nses}{1});
                            y1(nsubject)=y1(nsubject)+sum(~any(temp.R~=0,2),1);
                            y2(nsubject)=y2(nsubject)+sum(sum(temp.R~=0));
                            try, 
                                temp=load(CONN_x.Setup.l1covariates.files{nsubject}{icov0}{nses}{1});
                            catch
                                temp=load(regexprep(CONN_x.Setup.l1covariates.files{nsubject}{icov}{nses}{1},'art_regression_outliers_(and_movement_)?','art_regression_timeseries_'));
                            end
                            y3(nsubject)=max(y3(nsubject), max(abs(temp.R(:,end)),[],1) );
                            y4(nsubject)=y4(nsubject)+mean(abs(temp.R(:,end)),1);
                            y5(nsubject)=max(y5(nsubject), max(abs(temp.R(:,end-1)),[],1) );
                            y6(nsubject)=y6(nsubject)+mean(abs(temp.R(:,end-1)),1);
                        catch
                            yok=false;
                        end
                    end
                    y4(nsubject)=y4(nsubject)/nsess;
                    y6(nsubject)=y6(nsubject)/nsess;
                end
                if yok, 
                    str_global=sprintf(' (outliers threshold = %s)',mat2str(art_global_threshold));
                    str_motion=sprintf(' (outliers threshold = %s)',mat2str(art_motion_threshold));
                    conn_importl2covariate({'QA_ValidScans','QA_InvalidScans','QA_MaxMotion','QA_MeanMotion','QA_MaxGlobal','QA_MeanGlobal'},{y1,y2,y3,y4,y5,y6},0,subjects,{'CONN Quality Assurance: Number of valid (non-outlier) scans','CONN Quality Assurance: Number of outlier scans',['CONN Quality Assurance: Largest motion observed',str_motion],['CONN Quality Assurance: Average motion observed',str_motion],['CONN Quality Assurance: Largest global BOLD signal z-score changes observed',str_global],['CONN Quality Assurance: Average global BOLD signal z-score changes observed',str_global]}); 
                end
                
            case {'functional_realign','functional_realign&unwarp','functional_realign&unwarp&fieldmap','functional_realign&unwarp&phasemap','functional_realign_noreslice'}
                icov=find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'realignment'));
                if isempty(icov),
                    icov=numel(CONN_x.Setup.l1covariates.names);
                    CONN_x.Setup.l1covariates.names{icov}='realignment';
                    CONN_x.Setup.l1covariates.names{icov+1}=' ';
                end
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(outputfiles{isubject}{nses}{1});
                        CONN_x.Setup.l1covariates.files{nsubject}{icov}{nses}=conn_file(outputfiles{isubject}{nses}{2});
                    end
                end
                
            case {'functional_coregister','functional_coregister_affine'} % info written to same files header
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        CONN_x.Setup.functional{nsubject}{nses}=conn_file(CONN_x.Setup.functional{nsubject}{nses}{1});
                    end
                end
                
            case 'functional_motionmask'
                iroi=find(strcmp(CONN_x.Setup.rois.names(1:end-1),'MotionMask'),1);
                if isempty(iroi),
                    iroi=numel(CONN_x.Setup.rois.names);
                    CONN_x.Setup.rois.names{iroi}='MotionMask';
                    CONN_x.Setup.rois.dimensions{iroi}=0;
                    CONN_x.Setup.rois.mask(iroi)=0;
                    CONN_x.Setup.rois.subjectspecific(iroi)=1;
                    CONN_x.Setup.rois.sessionspecific(iroi)=1;
                    CONN_x.Setup.rois.multiplelabels(iroi)=0;
                    CONN_x.Setup.rois.regresscovariates(iroi)=0;
                    CONN_x.Setup.rois.unsmoothedvolumes(iroi)=0;
                    CONN_x.Setup.rois.names{iroi+1}=' ';
                end
                for isubject=1:numel(subjects),
                    nsubject=subjects(isubject);
                    nsess=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsubject)),sessions);
                    for nses=nsess(:)'
                        CONN_x.Setup.rois.files{nsubject}{iroi}{nses}=conn_file(outputfiles{isubject}{nses});
                    end
                end
        end
        if dogui&&ishandle(hmsg), delete(hmsg); end
        ok=2;
        if isfield(CONN_x,'filename')&&~isempty(CONN_x.filename), conn save; end
    end
    
    if ok<0, return; end
end
if ~dogui, disp('Done'); end
end


function conn_setup_preproc_update(hdl)
if ~nargin, hdl=gcbo; end
dlg=get(hdl,'userdata');
val=get(dlg.m0,'value');
val2=dlg.steps_order(val);
str=get(dlg.m0,'string');
%if any(ismember(cat(1,str(val),get(dlg.m7,'string')),{'structural Segmentation & Normalization','structural Normalization'})),
%    if any(ismember(str(val),{'structural Segmentation & Normalization','structural Normalization'})),
%        set(dlg.m3,'visible','on');
%    else set(dlg.m3,'visible','off');
%    end
%if any(ismember(cat(1,str(val),get(dlg.m7,'string')),{'functional Coregistration to structural','functional Normalization','functional Segmentation & Normalization','functional Segmentation'})),
%if any(ismember(str(val),{'functional Coregistration to structural','functional Normalization','functional Segmentation & Normalization','functional Segmentation'})),
if any(cellfun('length',regexp(str(val),'^functional Coregistration to structural|^functional Direct Coregistration to structural|^functional Normalization|^functional Direct Normalization|^functional Segmentation & Normalization|^functional Direct Segmentation & Normalization|^functional Segmentation|^functional Indirect Coregistration'))),
    set(dlg.m4,'visible','on');
else set(dlg.m4,'visible','off');
end;
set(dlg.m6,'string',dlg.steps_descr{val2});
if get(dlg.m1,'value'), set(dlg.m5,'visible','off');
else set(dlg.m5,'visible','on');
end
if get(dlg.m1b,'value'), set(dlg.m5b,'visible','off');
else set(dlg.m5b,'visible','on');
end
if ~isempty(dlg.m7)&&isempty(get(dlg.m7,'string')), set(dlg.m11,'enable','off'); else set(dlg.m11,'enable','on'); end
end

function conn_setup_preproc_save(hdl,varargin)
global CONN_x;
if ~nargin, hdl=gcbo; end
dlg=get(hdl,'userdata');
STEPS=get(dlg.m7,'string');
[tok,idx]=ismember(STEPS,dlg.steps_names);
STEPS=dlg.steps(idx(tok>0));
coregtomean=1;
if any(ismember(STEPS,{'functional_coregister','functional_coregister_affine','functional_normalize','functional_normalize_direct','functional_segment','functional_segment&normalize','functional_segment&normalize_direct','functional_coregister_nonlinear'})), coregtomean=~get(dlg.m4,'value'); end
if nargin==1
    CONN_x.SetupPreproc.steps=STEPS;
    CONN_x.SetupPreproc.coregtomean=coregtomean;
elseif nargin==2&&ischar(varargin{1})&&conn_existfile(varargin{1})
    filename=varargin{1};
    save(filename,'STEPS','coregtomean');
    fprintf('Data preprocessing pipeline saved to %s\n',filename);
else
    [outputpathfilename, outputpathpathname]=uiputfile('*.mat','Save data preprocessing pipeline',fullfile(fileparts(which('conn')),'utils','preprocessingpipelines'));
    if ~ischar(outputpathfilename), return; end
    filename=fullfile(outputpathpathname,outputpathfilename);
    save(filename,'STEPS','coregtomean');
    fprintf('Data preprocessing pipeline saved to %s\n',filename);
end
end

function conn_setup_preproc_load(hdl,varargin)
global CONN_x
if ~nargin, hdl=gcbo; end
dlg=get(hdl,'userdata');
if nargin==1
    if ~isfield(CONN_x,'SetupPreproc')||~isfield(CONN_x.SetupPreproc,'steps')||~isfield(CONN_x.SetupPreproc,'coregtomean'), return; end
    STEPS=CONN_x.SetupPreproc.steps;
    coregtomean=CONN_x.SetupPreproc.coregtomean;
    filename='';
elseif nargin==2&&ischar(varargin{1})&&conn_existfile(varargin{1})
    filename=varargin{1};
    load(filename,'STEPS','coregtomean');
else
    [outputpathfilename,outputpathpathname]=uigetfile('*.mat','Select file',fullfile(fileparts(which('conn')),'utils','preprocessingpipelines'));
    if ~ischar(outputpathfilename), return; end
    filename=fullfile(outputpathpathname,outputpathfilename);
    load(filename,'STEPS','coregtomean');
end

if ~exist('STEPS','var'), conn_msgbox(sprintf('Problem loading file %s. Incorrect format',filename),'',2);
else
    [tok,idx]=ismember(STEPS,dlg.steps);
    if ~all(tok), disp('Warning: some preprocessing steps do not have valid names'); end
    steps=dlg.steps(idx(tok>0));
    set(dlg.m7,'string',dlg.steps_names(idx(tok>0)));
    if exist('coregtomean','var'), 
        if isempty(coregtomean), coregtomean=1; end
        set(dlg.m4,'value',~coregtomean); 
    end
    if isempty(steps), set(dlg.m7,'value',[]);
    else
        set(dlg.m7,'value',1);
        tidx=find(strcmp(dlg.steps(dlg.steps_order),steps{1}));
        if numel(tidx)==1, set(dlg.m0,'value',tidx); conn_setup_preproc_update(dlg.m0); end
    end
end
end




