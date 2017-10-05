function varargout=conn(varargin)
% CONN functional connectivity toolbox
% Developed by 
%  The Gabrieli Lab at MIT
%  McGovern Institute for Brain Research
%
% From Matlab command-line (or system prompt in standalone installations) typing:
%
% conn    
%   launches conn GUI 
%
% conn batch filename
%   executes batch file (.m or .mat file)
%   see also CONN_BATCH
%
% http://www.nitrc.org/projects/conn
% alfnie@gmail.com
%

connver='17.f';
dodebug=false;

global CONN_h CONN_x CONN_gui;
if dodebug, dbstop if caught error; end
me=[]; 
try 
if nargin<1,
    connversion={'CONN functional connectivity toolbox',' (',connver,') '};
    hfig=findobj('tag',connversion{1});
    if ~isempty(hfig),figure(hfig); return;end
    try, warning('off','MATLAB:hg:patch:RGBColorDataNotSupported'); 
         warning('off','MATLAB:load:variableNotFound');
         warning('off','MATLAB:DELETE:FileNotFound');
    end
    conn_backgroundcolor=.14*[1 1 1];                  % backgroundcolor
    conn_backgroundcolorA=.17*[1 1 1];
    if ismac, CONN_gui.uicontrol_border=2;            % crops borders GUI elements
    else      CONN_gui.uicontrol_border=2;
    end
    CONN_gui.uicontrol_borderpopup=22;
    CONN_gui.doemphasis1=false;                       % removes border-cropping when hovering over each element
    CONN_gui.doemphasis2=true;                        % changes fontcolor when hovering over each element
    CONN_gui.doemphasis3=false;                       % changes fontbackground when hovering over each element
    CONN_gui.isresizing=false;
    
    conn_font_offset=0;                               % font size offset
    conn_font_init=true;
    conn_background=[];
    conn_tooltips=true;                               % enable tool-tips when hovering over each element
    conn_domacGUIbugfix=ismac;                        % troubleshoot popupmenu behavior 
    conn_dounixGUIbugfix=true;
    conn_checkupdates=false;

    try
        filename=conn_fullfile('~/conn_font_default.dat');
        if conn_existfile(filename),
        elseif isdeployed, filename=fullfile(matlabroot,'conn_font_default.dat');
        else filename=fullfile(fileparts(which(mfilename)),'conn_font_default.dat');
        end
        if conn_existfile(filename), load('-mat',filename,'conn_font_offset','conn_backgroundcolor','conn_backgroundcolorA','conn_background','conn_tooltips','conn_domacGUIbugfix','conn_dounixGUIbugfix','conn_checkupdates'); conn_font_init=false; %fprintf('gui settings loaded from %s\n',filename);
        end
    end
    CONN_gui.font_offset=conn_font_offset; 
    CONN_gui.tooltips=conn_tooltips;
    CONN_gui.domacGUIbugfix=conn_domacGUIbugfix;
    CONN_gui.dounixGUIbugfix=conn_dounixGUIbugfix;
    CONN_gui.isunix=isunix&&~ismac;
    CONN_gui.ismac=ismac;
    CONN_gui.ispc=ispc;
    CONN_gui.checkupdates=conn_checkupdates;
    CONN_gui.background=conn_background;
    CONN_gui.backgroundcolor=conn_backgroundcolor; 
    if isempty(conn_backgroundcolorA)
        CONN_gui.backgroundcolorA=CONN_gui.backgroundcolor;
    else CONN_gui.backgroundcolorA=conn_backgroundcolorA;
    end
    CONN_gui.backgroundcolorE=max(0,min(1, .5*CONN_gui.backgroundcolor+.5*[2 2 6]/6));
    CONN_gui.fontcolorA=[.10 .10 .10]+.8*(mean(CONN_gui.backgroundcolorA)<.5);
    CONN_gui.fontcolorB=[.4 .4 .4]+.2*(mean(CONN_gui.backgroundcolorA)<.5);
    CONN_gui.status=0;
    CONN_gui.warnloadbookmark={};
    if ismac, CONN_gui.rightclick='ctrl'; else CONN_gui.rightclick='right'; end
	CONN_h=struct;
    cmap=.25+.75*((6*gray(128) + 2*hot(128))/8); if mean(CONN_gui.backgroundcolor)>.5,cmap=flipud(cmap); end
    jetmap=jet(128); %[linspace(.1,1,64)',zeros(64,2)];jetmap=[flipud(fliplr(jetmap));jetmap];
    CONN_h.screen.colormap=max(0,min(1, diag((1-linspace(1,0,256)'.^50))*[cmap;jetmap]+(linspace(1,0,256)'.^50)*CONN_gui.backgroundcolor ));
    CONN_h.screen.colormapA=max(0,min(1, diag((1-linspace(1,0,256)'.^50))*[cmap;jetmap]+(linspace(1,0,256)'.^50)*CONN_gui.backgroundcolorA ));
    h0=get(0,'screensize'); h0=h0(1,3:4)-h0(1,1:2)+1; h0=h0/max(1,max(abs(h0))/2000);
    %if any(h0(3:4)<[1200 700]), fprintf('Increase resolution size for optimal viewing\n(screen resolution %dx%d; minimum recommended %dx%d\n)',h0(3),h0(4),1200,700); end
    minheight=500;
    tname=strcat(connversion{:});
    if isdeployed, tname=strcat(tname,' (standalone)'); end
	CONN_h.screen.hfig=figure('units','pixels','position',[0*72+1,h0(2)-max(minheight,.5*h0(1))-48,h0(1)-0*72-1,max(minheight,.5*h0(1))],'color',CONN_gui.backgroundcolor,'doublebuffer','on','tag',connversion{1},'name',tname,'numbertitle','off','menubar','none','resize','on','colormap',CONN_h.screen.colormap,'closerequestfcn',@conn_closerequestfcn,'deletefcn',@conn_deletefcn,'resizefcn',@conn_resizefcn,'interruptible','off');
    try, if isequal(datestr(now,'mmdd'),'0401'), conn_guibackground('setfiledefault',[],'True color'); end; end
    conn_menuframe;
    ht=conn_menu('text0c',[.3 .7 .4 .2],'','CONN'); set(ht,'fontunits','norm','fontsize',.5,'horizontalalignment','center','color',[0 0 0]+(mean(CONN_gui.backgroundcolor)<.5));
    imicon=imread(fullfile(fileparts(which(mfilename)),'conn_icon.jpg')); ha=axes('units','norm','position',[.425 .3 .15 .4]);him=image(conn_bsxfun(@plus,shiftdim([.1 .1 .1],-1),conn_bsxfun(@times,.5*shiftdim(1-[.1 .1 .1],-1),double(imicon)/255)),'parent',ha);axis(ha,'equal','off');
    conn_menu_plotmatrix('',CONN_h.screen.hfig,[20 1 10],[.425 .2 .15 .1]);
    hax=axes('units','norm','position',[0 0 1 1]);
    h=text(0,-2,'Initializing. Please wait','fontunits','norm','fontsize',1/60,'horizontalalignment','center','verticalalignment','bottom','color',.75*[1 1 1]);
    set(gca,'units','norm','position',[0 0 1 1],'xlim',[-2 2],'ylim',[-2.5 2]); axis off;
    if conn_font_init,
        drawnow;
        set(h,'fontunits','points');
        tfontsize=get(h,'fontsize');
        conn_font_offset=max(-4,round(tfontsize)-8);
        %fprintf('Font size change %dpts to %dpts (%f %s)\n',8+CONN_gui.font_offset,8+conn_font_offset,tfontsize,mat2str([get(0,'screensize') get(gca,'position')]));
        CONN_gui.font_offset=conn_font_offset;
    end
    drawnow;
    set(0,{'defaultuicontrolfontsize','defaulttextfontsize','defaultaxesfontsize'},repmat({8+CONN_gui.font_offset},1,3));
    if iscell(CONN_gui.background), conn_guibackground settrans; end
    conn init;
    conn importrois;
    CONN_x.gui=1;
    if CONN_gui.checkupdates&&~isdeployed, if conn_update([],[],true); return; end; end
	conn_menumanager on;
	CONN_h.menus.m_setup_02sub=conn_menumanager([], 'n',8,...
									'string',{'Basic','Structural','Functional','ROIs','Conditions','Covariates 1st-level','Covariates 2nd-level','Options'},...%,'Preprocessing','QA plots'},...
									'help',{'Defines basic acquisition information','Defines structural/anatomical data source files','Defines functional data source files','Defines regions of interest','Defines experiment conditions (e.g. rest, task, or longitudinal conditions)','Defines 1st level (within subject) variables (a timeseries for each subject/session; e.g. subject movement parameters)','Defines 2nd level (between subjects) variables (one value per subject; e.g. group membership)','Defines processing options'},...%,'Define and apply a sequence of preprocessing steps to the structural/functional volumes defined above (e.g. realignment, slice-timing correction, normalization, etc.)','Quality Assurance plots: creates/manages plots showing accuracy of coregistration/normalization/denoising'},...
									'position',[.235+0.5*.665/4-.135/2,.955-8*.045,.135,8*.045],...%'position',[.00,.42-.06,.095,7*.06],...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_setupgo',1},{@conn,'gui_setupgo',2},{@conn,'gui_setupgo',3},{@conn,'gui_setupgo',4},{@conn,'gui_setupgo',5},{@conn,'gui_setupgo',6},{@conn,'gui_setupgo',7},{@conn,'gui_setupgo',8}} ); %,{@conn,'gui_setup_preproc','multiplesteps',1},{@conn,'gui_setup_qadisplay'}} );
	CONN_h.menus.m_analyses_03sub=conn_menumanager([], 'n',4,...
									'string',{'All analyses',{'ROI-to-ROI','Seed-to-Voxel'},{'Voxel-to-Voxel','ICA networks'},'dyn-ICA circuits'},...
									'help',{'Display all current analyses','Define/explore ROI-to-ROI and Seed-to-Voxel first-level analyses','Define/explore voxel-to-voxel and ICA first-level analyses','Define Dynamic ICA first-level analyses'},...
                                    'order','vertical',...
									'position',[.235+2.5*.665/4-.135/2,.955-6*.045,.135,6*.045],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
                                    'roll',1,...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_analysesgo',[]},{@conn,'gui_analysesgo',1},{@conn,'gui_analysesgo',2},{@conn,'gui_analysesgo',3}} );
	CONN_h.menus.m_results_03sub=conn_menumanager([], 'n',6,...
									'string',{'All analyses','ROI-to-ROI','Seed-to-Voxel','Voxel-to-Voxel','ICA networks','dyn-ICA circuits'},...
									'help',{'Display all current analyses and bookmarks','Define/explore ROI-to-ROI second-level analyses','Define/explore seed-to-voxel second-level analyses','Define/explore voxel-to-voxel second-level analyses','Define/explore ICA second-level analyses','Define/explore dynamic ICA second-level analyses'},...
                                    'order','vertical',...
									'position',[.235+3.5*.665/4-.135/2,.955-6*.045,.135,6*.045],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
                                    'roll',1,...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_resultsgo',[]},{@conn,'gui_resultsgo',1},{@conn,'gui_resultsgo',2},{@conn,'gui_resultsgo',3},{@conn,'gui_resultsgo',4},{@conn,'gui_resultsgo',5}} ); 
	CONN_h.menus.m0=conn_menumanager([],	'n',4,...
									'string',{'Setup','Denoising','first-level Analyses','second-level Results'},...
									'help',{'Step 1/4: Define/Edit experiment setup','Step 2/4: Define/Edit denoising options','Step 3/4: Define/Edit first-level analysis options','Step 4/4: Define/Edit second-level analyses'},...
                                    'order','horizontal',...
									'state',[1,0,0,0],...
                                    'toggle',1,...
									'position',[.235,.955,.665,.045],...
                                    'bordertype','square',...
									'fontsize',8,...
                                    'dfont',4,...
									'callback',{CONN_h.menus.m_setup_02sub,{@conn,'gui_preproc'},CONN_h.menus.m_analyses_03sub,CONN_h.menus.m_results_03sub},...
									'callback2',{{@conn,'gui_setup'},{},{@conn,'gui_analyses'},{@conn,'gui_results'}} );
	CONN_h.menus.m_setup_07e=conn_menumanager([],	'n',5,...
									'string',{'Preprocessing steps','Setup/Denoising/1st-level analyses','Second-level results','Batch script', 'Matlab command'},...
									'help',{'Run one or several preprocessing steps (e.g. realignment/normalization/etc.) (same as Preprocessing button in Setup tab)','Run one or several processing steps (e.g. Setup/Denoising/First-level) (same as Done button in Setup/Denoising/First-level tabs)','Compute second-level results for all sources (same as Results Explorer button in Second-level results tab for each individual seed/source)','Run batch script (.m or .mat file)','Run individual Matlab commands'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.095,.955-3.5*.045-5*.045,.20,5*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_setup_preproc','multiplesteps',1},{@conn,'run_process',[]},{@conn,'gui_results_done'},{@conn,'run',[]},{@conn,'run_cmd',[]}} );
	CONN_h.menus.m_setup_07f=conn_menumanager([],	'n',3,...
									'string',{'Settings','Pending jobs','History'},...
									'help',{'Configuration settings in distributed cluster or multi-processor environments','Displays pending or queued jobs','Displays all past or pending jobs'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.095,.955-1.5*.045-3*.045,.129,3*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'parallel_settings'},{@conn_jobmanager}, {@conn_jobmanager, 'all'}} );
	CONN_h.menus.m_setup_07a=conn_menumanager([],	'n',6,...
									'string',{'GUI settings','Cluster / HPC','QA plots','Run','Screenshot','Calculator'},...%,'QA plots'},...
									'help',{'Change GUI display options','Parallelization options for distributed clusters and High Performance Computing environments','Quality Assurance plots: creates/manages plots showing accuracy of coregistration/normalization/denoising','Run SPM preprocessing steps, CONN processing steps, batch script, or Matlab commands','Saves a screenshot of the GUI','Explore second-level covariates'},...%,'Quality Assurance plots: creates/manages plots showing accuracy of coregistration/normalization/denoising'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.045,.955-6*.045,.129,6*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_settings'},CONN_h.menus.m_setup_07f,{@conn,'gui_setup_qadisplay'},CONN_h.menus.m_setup_07e,{@conn_print},{@conn,'gui_calculator'}} ); %,{@conn,'gui_setup_qadisplay'}} );
	CONN_h.menus.m_setup_07c=conn_menumanager([],	'n',3,...
									'string',{'CONN Manual','Info: Batch Processing', 'Info: Cluster Computing'},...
									'help',{'Open CONN toolbox manual','See batch processing help','See Cluster/HPC computing help'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.14,.955-2.5*.045-3*.045,.15,3*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_help','doc'},{@conn,'gui_help','help','conn_batch.m'},{@conn,'gui_help','help','conn_grid.m'}} );
	CONN_h.menus.m_setup_07d=conn_menumanager([],	'n',7,...
									'string',{'Support','FAQ','Tutorials','CONN site','NITRC site','SPM site','Registration'},...
									'help',{'Search/ask for help at CONN support forum site (browse www.nitrc.org/forum/forum.php?forum_id=1144)','Browse www.alfnie.com/software/conn','Browse www.conn-toolbox.org/tutorials','Browse www.conn-toolbox.org','Browse www.nitrc.org/projects/conn','Browse www.fil.ion.ucl.ac.uk/spm','Register CONN toolbox software'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.14,.955-4.5*.045-7*.045,.099,7*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_help','url','http://www.nitrc.org/forum/forum.php?forum_id=1144'},{@conn,'gui_help','url','http://www.alfnie.com/software/conn'},{@conn,'gui_help','url','http://www.conn-toolbox.org/tutorials'},{@conn,'gui_help','url','http://www.conn-toolbox.org'},{@conn,'gui_help','url','http://www.nitrc.org/projects/conn'},{@conn,'gui_help','url','http://www.fil.ion.ucl.ac.uk/spm'},{@conn_register,'forceregister'}} );
	CONN_h.menus.m_setup_07g=conn_menumanager([],	'n',2,...
									'string',{'Information','Sample data'},...
									'help',{'Check information about latest CONN workshops','Download and process sample dataset',},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.14,.955-3.5*.045-2*.045,.099,2*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_workshop'},{@conn_batch_workshop_nyudataset}} );
	CONN_h.menus.m_setup_07b=conn_menumanager([],	'n',5,...
									'string',{'Search','Updates','Documentation','Workshops','Web resources'},...
									'help',{'Search on a database of support questions','Check for software updates','Documentation','Workshops', 'Web resources',''},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.09,.955-5*.045,.129,5*.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn_msghelp},{@conn_update,connver},CONN_h.menus.m_setup_07c,CONN_h.menus.m_setup_07g,CONN_h.menus.m_setup_07d} );
	CONN_h.menus.m_setup_01a=conn_menumanager([], 'n',8,...
									'string',{'Open','New (blank)','New (wizard)','Save','Save As','Close','Import','Merge'},...
									'help',{'Loads existing experiment information','Starts a new empty experiment','Starts a new empty experiment and loads/preprocesses your data using a simplified step-by-step wizard','Saves current experiment information','Saves current experiment to a different file','Closes current experiment without saving','Imports experiment information from SPM.mat files','Merge other experiment files with the current experiment'},...
                                    'order','vertical',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.0,.955-8*.045,.129,8*.045],...%[.09,.88-6*.05,.08,6*.05],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_setup_load'},{@conn,'gui_setup_new'},{@conn,'gui_setup_wizard'},{@conn,'gui_setup_save'},{@conn,'gui_setup_saveas'},{@conn,'gui_setup_close'},{@conn,'gui_setup_import'},{@conn,'gui_setup_merge'}} );
	CONN_h.menus.m_setup_01b=conn_menumanager([], 'n',2,...
									'string',{'New','Open'},...
									'help',{'Starts a new empty experiment / CONN project','Loads existing experiment information / CONN project'},...
                                    'order','horizontal',...
                                    'toggle',0,...
                                    'roll',1,...
									'position',[.425,.73,2*.075,1*.06],...
									'fontsize',12,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_setup_new'},{@conn,'gui_setup_load'}} );
	CONN_h.menus.m_setup_06=conn_menumanager([],	'n',3,...
									'string',{'Project','Tools','Help'},...
									'help',{'','',''},...
                                    'order','horizontal',...
                                    'toggle',0,...
									'position',[.0,.955,3*.045,.045],...
									'fontsize',8,...
                                    'bordertype','square',...
									'callback',{CONN_h.menus.m_setup_01a,CONN_h.menus.m_setup_07a,CONN_h.menus.m_setup_07b} );
% 	CONN_h.menus.m_setup_01=conn_menumanager([], 'n',1,...
% 									'string',{'Project'},...
% 									'help',{''},...
%                                     'order','vertical',...
%                                     'toggle',0,...
% 									'position',[.0,.95,.045,.05],...
% 									'fontsize',8,...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_setup_01a} );
	CONN_h.menus.m_setup_01d=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Saves changes to Setup step and runs associated processing pipeline (e.g. importing voxel- and ROI-level timeseries) before proceeding to next step (Denoising)'},...
									'position',[0.02,0.01,.10,1*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_setup_finish'}} );
	CONN_h.menus.m_setup_01e=conn_menumanager([], 'n',2,...
									'string',{'Preprocessing','QA plots'},...
									'help',{'Define and apply a sequence of preprocessing steps to structural/functional volumes defined above (e.g. realignment, slice-timing correction, normalization, etc.)','Quality Assurance plots: creates/manages plots showing accuracy of coregistration/normalization/denoising'},...
									'position',[.02,.09,.10,2*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_setup_preproc','multiplesteps',1},{@conn,'gui_setup_qadisplay'}} );
% 	CONN_h.menus.m_setup_03=conn_menumanager([], 'n',2,...
% 									'string',{'1st level','2nd level'},...
% 									'help',{'Defines 1st level (within subject) variables (a timeseries for each subject/session; e.g. subject movement parameters)','Defines 2nd level (between subjects) variables (one value per subject; e.g. group membership)'},...
%                                     'toggle',1,...
% 									'position',[.11,.31,.08,2*.06],...
% 									'fontsize',8,...
%                                     'bordertype','square',...
% 									'callback',{{@conn,'gui_setup_covariates'},{@conn,'gui_setup_covariates'}} );
	CONN_h.menus.m_setup_02=conn_menumanager([], 'n',8,...
									'string',{'Basic','Structural','Functional','ROIs','Conditions','Covariates 1st-level','Covariates 2nd-level','Options'},...
									'help',{'Defines basic acquisition information','Defines structural/anatomical data source files','Defines functional data source files','Defines regions of interest','Defines experiment conditions (e.g. rest, task, or longitudinal conditions)','Defines 1st level (within subject) variables (a timeseries for each subject/session; e.g. subject movement parameters)','Defines 2nd level (between subjects) variables (one value per subject; e.g. group membership)','Defines processing options'},...
									'state',[1,0,0,0,0,0,0,0],...
									'value',1,...
                                    'toggle',1,...
									'position',[.005,.85-8*.06,.13,8*.06],...%'position',[.00,.42-.06,.095,7*.06],...
									'fontsize',8,...
                                    'dfont',2,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'},{@conn,'gui_setup'}} );
	CONN_h.menus.m_setup_04=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Imports SPM.mat files and updates Setup information for each subject'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_setup_importdone'}} );
	CONN_h.menus.m_setup_05=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'When finished press ''Done'' to merge CONN_* files'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_setup_mergedone'}} );
% 	CONN_h.menus.m_preproc_01=conn_menumanager([], 'n',1,...
% 									'string',{'<'},...
% 									'help',{''},...
%                                     'toggle',0,...
% 									'position',[.19,.61,.02,.08],...
%                                     'bordertype','square',...
% 									'backgroundcolor',CONN_gui.backgroundcolorA,...
% 									'callback',{{@conn,'gui_preproc',0}} );
	CONN_h.menus.m_preproc_02=conn_menumanager([], 'n',2,...
									'string',{'QA plots','Done'},...
                                    'help',{'Quality Assurance plots: compute and display histograms of voxel-to-voxel connectivity values for all subjects/sessions (QA_DENOISE)','Saves changes to Denoising step and runs associated processing pipeline before proceeding to next step (First-level Analyses)'},...
									'position',[0.01,0.01,.10,2*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_preproc_qa'},{@conn,'gui_preproc_done'}} );
% 	CONN_h.menus.m_analyses_01=conn_menumanager([], 'n',1,...
% 									'string',{'<'},...
% 									'help',{''},...
%                                     'toggle',0,...
% 									'position',[.31,.40,.02,.08],...
%                                     'bordertype','square',...
% 									'backgroundcolor',CONN_gui.backgroundcolorA,...
% 									'callback',{{@conn,'gui_analyses',0}} );
% 	CONN_h.menus.m_analyses_01b=conn_menumanager([], 'n',1,...
% 									'string',{'<'},...
% 									'help',{''},...
%                                     'toggle',0,...
% 									'position',[.44,.32,.02,.08],...
%                                     'bordertype','square',...
% 									'backgroundcolor',CONN_gui.backgroundcolorA,...
% 									'callback',{{@conn,'gui_analyses',0}} );
	CONN_h.menus.m_analyses_02=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Saves changes to current First-level analysis step and runs associated processing pipeline before proceeding to next step (Second-level Results)'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_analyses_done'}} );
	CONN_h.menus.m_analyses_03=conn_menumanager([], 'n',3,...
									'string',{{'ROI-to-ROI','Seed-to-Voxel'},{'Voxel-to-Voxel','ICA networks'},'dyn-ICA circuits'},...
									'help',{'Define/explore ROI-to-ROI and Seed-to-Voxel first-level analyses','Define/explore voxel-to-voxel and ICA first-level analyses','Define options for Dynamic ICA first-level analyses'},...
                                    'order','vertical',...
									'position',[.005,.85-5*.06,.11,5*.06],...%[.0,.68,.07,3*.05],...
									'state',[1,0,0],...
									'value',1,...
                                    'toggle',1,...
									'fontsize',8,...
                                    'dfont',2,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_analyses'},{@conn,'gui_analyses'},{@conn,'gui_analyses'}} );
	CONN_h.menus.m_analyses_04=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Saves changes to First-level Voxel-to-Voxel analysis step and runs associated processing pipeline before proceeding to next step (Second-level results)'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_analyses_done_vv'}} );
	CONN_h.menus.m_analyses_05=conn_menumanager([], 'n',1,...
									'string',{'Done'},...
									'help',{'Saves changes to First-level dyn-ICA analysis step and runs associated processing pipeline before proceeding to next step (Second-level results)'},...
									'position',[0.01,0.01,.10,.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_analyses_done_dyn'}} );
	CONN_h.menus.m_results_03a=conn_menumanager([], 'n',3,...
									'string',{'Spatial components','Temporal components','Summary'},...
									'help',{'Define/explore second-level analyses of dyn-ICA spatial components (circuits)','Define/explore second-level analyses of dyn_ICA temporal components (connectivity-modulation timeseries)','Summary display of dyn-ICA analyses'},...
                                    'order','vertical',...
									'position',[.005,.85-5.5*.06-3*.06,.11,3*.06],...
									'state',[1,0,0],...
									'value',1,...
                                    'toggle',1,...
									'fontsize',8,...
                                    'dfont',2,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_results_dyn'},{@conn,'gui_results_dyn'},{@conn,'gui_results_dyn'}} );
	CONN_h.menus.m_results_03b=conn_menumanager([], 'n',3,...
									'string',{'Spatial components','Temporal components','Summary'},...
									'help',{'Define/explore second-level analyses of ICA spatial components (networks)','Define/explore second-level analyses of ICA temporal components (network timeseries)','Summary display of Independent Component analyses'},...
                                    'order','vertical',...
									'position',[.005,.85-5.5*.06-3*.06,.11,3*.06],...
									'state',[1,0,0],...
									'value',1,...
                                    'toggle',1,...
									'fontsize',8,...
                                    'dfont',2,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_results_ica'},{@conn,'gui_results_ica'},{@conn,'gui_results_ica'}} );
	CONN_h.menus.m_results_03=conn_menumanager([], 'n',5,...
									'string',{'ROI-to-ROI','Seed-to-Voxel','Voxel-to-Voxel','ICA networks','dyn-ICA circuits'},...
									'help',{'Define/explore ROI-to-ROI second-level analyses','Define/explore seed-to-voxel second-level analyses','Define/explore voxel-to-voxel second-level analyses','Define/explore ICA second-level analyses','Define/explore dynamic ICA second-level analyses'},...
                                    'order','vertical',...
									'position',[.005,.85-5*.06,.11,5*.06],...%[.0,.68,.07,3*.05],...
									'state',[1,0,0,0,0],...
									'value',1,...
                                    'toggle',1,...
									'fontsize',8,...
                                    'dfont',2,...
                                    'bordertype','square',...
									'callback',{{@conn,'gui_results'},{@conn,'gui_results'},{@conn,'gui_results'},{@conn,'gui_results'},{@conn,'gui_results'}} );
% 									'callback',{{@conn,'gui_results'},{@conn,'gui_results'},{@conn,'gui_results'},CONN_h.menus.m_results_03a},...
%                                     'callback2',{{},{},{},{@conn,'gui_results'}} );
	CONN_h.menus.m_results_04=conn_menumanager([], 'n',2,...
									'string',{'Graph theory','Results explorer'},...
									'help',{'Graphic display of graph-theory second-level results (for selected between-subjects and between-conditions contrast)','Graphic display of ROI-to-ROI second-level results (selected between-subjects and between-conditions contrast for each source ROI)'},...
                                    'order','vertical',...
									'position',[.005,.01,1*.11,2*.05],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_results_graphtheory'},{@conn,'gui_results_roiview'}} );
% 	CONN_h.menus.m_results_04=conn_menumanager([], 'n',1,...
% 									'string',{'Tools'},...
% 									'help',{''},...
%                                     'order','vertical',...
% 									'position',[0.01,0.01,.10,.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_results_04a} );
	CONN_h.menus.m_results_05=conn_menumanager([], 'n',1,...
									'string',{'Results explorer'},... %'Results for all sources'},...
									'help',{'Whole-brain display of seed-to-voxel second-level results (for selected between-subjects/conditions/sources contrasts)'},...%,'Performs seed-to-voxel analyses for each source/seed included in the ''Sources'' list (for selected between-subjects and between-conditions contrasts)'},...
                                    'order','vertical',...
									'position',[.005,.01,1*.11,1*.05],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_results_wholebrain'}} ); %,{@conn,'gui_results_done'}} );
% 	CONN_h.menus.m_results_05=conn_menumanager([], 'n',1,...
% 									'string',{'Tools'},...
% 									'help',{''},...
%                                     'order','vertical',...
% 									'position',[0.01,0.01,.10,.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_results_05a} );
% 	CONN_h.menus.m_results_05=conn_menumanager([], 'n',3,...
% 									'string',{'Seed-to-Voxel explorer','Compute results for all sources','Search additional sources'},...
% 									'help',{'Whole-brain display of seed-to-voxel second-level results (for selected between-subjects/conditions/sources contrasts)','Performs seed-to-voxel analyses for each source/seed included in the ''Sources'' list (for selected between-subject and between-conditions contrasts)','Performs seed-to-voxel analyses using all voxels as potential seeds (returns FWE-corrected seed-level statistics and adds significant seeds as additional sources)'},...
%                                     'order','vertical',...
% 									'position',[.01,.06,1*.10,3*.05],...%[.0,.68,.07,3*.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','round',...
% 									'callback',{{@conn,'gui_results_wholebrain'},{@conn,'gui_results_done'},{@conn,'gui_results_searchseed'}} );
% 	CONN_h.menus.m_results_05b=conn_menumanager([], 'n',1,...
% 									'string',{'Tools'},...
% 									'help',{''},...
%                                     'order','vertical',...
% 									'position',[0.01,0.01,.10,.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_results_05c} );
	CONN_h.menus.m_results_06=conn_menumanager([], 'n',1,...
									'string',{'Results explorer'},...%,'Compute results for all measures'},...
									'help',{'Whole-brain display of voxel-to-voxel measure second-level results (for selected between-subjects/conditions/measures contrasts)'},...%,'Performs group analyses for all measures'},...
                                    'order','vertical',...
									'position',[.005,.01,1*.11,1*.05],...%[.0,.68,.07,3*.05],...
                                    'toggle',0,...
									'fontsize',8,...
                                    'fontangle','normal',...
                                    'bordertype','round',...
									'callback',{{@conn,'gui_results_wholebrain_vv'}});%,{@conn,'gui_results_done_vv'}} );
% 	CONN_h.menus.m_results_06=conn_menumanager([], 'n',1,...
% 									'string',{'Tools'},...
% 									'help',{''},...
%                                     'order','vertical',...
% 									'position',[0.01,0.01,.10,.05],...
%                                     'toggle',0,...
% 									'fontsize',8,...
%                                     'fontangle','normal',...
%                                     'bordertype','square',...
% 									'callback',{CONN_h.menus.m_results_06a} );

    try
        javaMethodEDT('setInitialDelay',javax.swing.ToolTipManager.sharedInstance,500); % tooltipstring timer-on 0.5s
        javaMethodEDT('setDismissDelay',javax.swing.ToolTipManager.sharedInstance,30000); % tooltipstring timer-off 30s
        javaMethodEDT('setReshowDelay',javax.swing.ToolTipManager.sharedInstance,0); % tooltipstring timer-continue 0s
        javax.swing.UIManager.put('ToolTip.background',javax.swing.plaf.ColorUIResource(238/255,238/255,238/255)); % background color tooltipstring
        if ismac&&CONN_gui.domacGUIbugfix==1, 
            CONN_gui.originalCOMB=javax.swing.UIManager.get('ComboBoxUI');
            javax.swing.UIManager.put('ComboBoxUI','javax.swing.plaf.metal.MetalComboBoxUI');  % fix popup menu colors in mac; alternatives 'com.jgoodies.looks.plastic.PlasticComboBoxUI'
            CONN_gui.uicontrol_borderpopup=58;
        end
        if isunix&&~ismac&&conn_dounixGUIbugfix, %(||ismac&&CONN_gui.domacGUIbugfix), 
            CONN_gui.originalLAF=javax.swing.UIManager.getLookAndFeel;
            CONN_gui.originalBORD=javax.swing.UIManager.get('ToggleButton.border');
            javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel'); % alternatives javax.swing.plaf.nimbus.NimbusLookAndFeel com.jgoodies.looks.plastic.PlasticLookAndFeel
            javax.swing.UIManager.put('ToggleButton.border',javax.swing.BorderFactory.createEmptyBorder); % fix menu buttons border in unix
        end
    end
    conn gui_setup;
    conn_register;

else
    if ~isempty(regexp(char(varargin{1}),'\.mat$')); % conn projectfile.mat ... syntax
        conn('load',varargin{1});
        conn(varargin{2:end});
        return;
    end
	switch(lower(varargin{1})),
        case 'init',
            filename=fullfile(fileparts(which(mfilename)),'utils','surf','mask.volume.brainmask.nii');
            try
                infomask=conn_file(filename);
            catch
                if isempty(which('spm')), dodebug=true; error('INSTALLATION PROBLEM. Please re-install SPM and try again');
                elseif isempty(which('conn_existfile')), dodebug=true; error('INSTALLATION PROBLEM. Please re-install CONN and try again');
                elseif conn_existfile(filename), dodebug=true; error('INSTALLATION PROBLEM. Please re-install SPM and CONN and try again');
                else dodebug=true; error('INSTALLATION PROBLEM. Please re-install CONN and try again');
                end
            end
            CONN_x=struct('name',[],'filename','','gui',1,'state',0,'ver',connver,'lastver',connver,'isready',[0 0 0 0],...
                'opt',struct('fmt1','%03d'),...
                'pobj',conn_projectmanager('null'),...
                'folders',struct('rois',fullfile(fileparts(which(mfilename)),'rois'),'data',[],'bids',[],'preprocessing',[],'qa',[],'firstlevel',[],'firstlevel_vv',[],'firstlevel_dyn',[],'secondlevel',[]),...
                'Setup',struct(...
                 'RT',2,'nsubjects',1,'nsessions',1,'fwhm',12,'reorient',eye(4),'normalized',1,...
                 'functional',{{}},...
                 'structural',{{}},...
                 'structural_sessionspecific',0,...
                 'spm',{{}},...
                 'nscans',{{}},....
                 'rois',         struct('names',{{}},'files',{{}},'dimensions',{{}},'mask',[],'subjectspecific',[],'sessionspecific',[],'multiplelabels',[],'regresscovariates',[],'unsmoothedvolumes',[]),...
                 'conditions',   struct('names',{{}},'values',{{}},'param',[],'filter',{{}},'allnames',{{}},'missingdata',0),...
                 'l1covariates', struct('names',{{}},'files',{{}}),...
                 'l2covariates', struct('names',{{}},'values',{{}},'descrip',{{}}),...
                 'acquisitiontype',1,...
                 'steps',[1,1,1,1],...
                 'spatialresolution',1,...
                 'analysismask',1,...
                 'analysisunits',1,...
                 'secondlevelanalyses',1,...
                 'explicitmask',{infomask},...
                 'roifunctional',struct('roiextract',2,'roiextract_functional',{{}},'roiextract_rule',{{}}),...
                 'unwarp_functional',{{}},...
                 'coregsource_functional',{{}},...
                 'erosion',     struct('binary_threshold',[.5 .5 .5],'erosion_steps',[0,1,1],'erosion_neighb',[1 1 1]),...
                 'outputfiles',[0,0,0,0,0,0],...
                 'surfacesmoothing',10),...
                'Preproc',struct(...
                 'variables',   struct('names',{{}},'types',{{}},'power',{{}},'deriv',{{}},'dimensions',{{}}),...
                 'confounds',	struct('names',{{}},'types',{{}},'power',{{}},'deriv',{{}},'dimensions',{{}}),...
                 'filter',[0.008,0.09],...
                 'despiking',0,...
                 'regbp',1,...
                 'detrending',1),...
                'Analyses',struct(...
                 'name','ANALYSIS_01',...
                 'sourcenames',{{}},...
                 'variables', struct('names',{{}},'types',{{}},'deriv',{{}},'fbands',{{}},'dimensions',{{}}),...
                 'regressors',	struct('names',{{}},'types',{{}},'deriv',{{}},'fbands',{{}},'dimensions',{{}}),...
                 'type',3,...
                 'measure',1,...
                 'modulation',0,...
                 'conditions',[],...
                 'weight',2),...
                'Analysis',1,...
                'dynAnalyses',struct(...
                 'name','DYN_01',...
                 'regressors', struct('names',{{}}),...
                 'variables', struct('names',{{}}),...
                 'Ncomponents',20,...
                 'condition',[],...
                 'analyses',3,...
                 'window',30,...
                 'output',[1 1 0]),...
                'dynAnalysis',1,...
                'vvAnalyses',struct(...
                 'name','V2V_01',...
                 'measurenames',{{}},...
                 'variables',  conn_v2v('measures'),...
                 'regressors', conn_v2v('empty'),...
                 'measures',{{}},...
                 'mask',[]),...
                'vvAnalysis',1,...
                'Results',struct(...
                  'foldername','',...
                  'xX',[],...
                  'saved',struct('names',{{}},'labels',{{}},'nsubjecteffects',{{}},'csubjecteffects',{{}},'nconditions',{{}},'cconditions',{{}}) ));
            
            CONN_x.Setup.functional{1}{1}={[],[],[]};
            CONN_x.Setup.nscans{1}{1}=0;
            CONN_x.Setup.spm{1}={[],[],[]};
            CONN_x.Setup.conditions.values{1}{1}{1}={0,inf};
            CONN_x.Setup.conditions.names={'rest',' '};
            CONN_x.Setup.l1covariates.files{1}{1}{1}={[],[],[]};
            CONN_x.Setup.l1covariates.names={' '};
            CONN_x.Setup.l2covariates.values{1}{1}=1;
            CONN_x.Setup.l2covariates.names={'AllSubjects',' '};
            CONN_x.Setup.l2covariates.descrip={''};
            CONN_x.Setup.rois.files{1}{1}{1}={[],[],[]};%{filename,str,icon};
            CONN_x.Setup.rois.files{1}{2}{1}={[],[],[]};%{filename,str,icon};
            CONN_x.Setup.rois.files{1}{3}{1}={[],[],[]};%{filename,str,icon};
            CONN_x.Setup.rois.names={'Grey Matter','White Matter','CSF',' '};
            CONN_x.Setup.rois.dimensions={1,16,16};
            CONN_x.Setup.rois.mask=[0,0,0];
            CONN_x.Setup.rois.subjectspecific=[1 1 1];
            CONN_x.Setup.rois.sessionspecific=[0 0 0];
            CONN_x.Setup.rois.multiplelabels=[0,0,0];
            CONN_x.Setup.rois.regresscovariates=[0,1,1];
            CONN_x.Setup.rois.unsmoothedvolumes=[1,1,1];
            filename=fullfile(fileparts(which('conn')),'utils','surf','referenceT1.nii');
            [V,str,icon]=conn_getinfo(filename);
            CONN_x.Setup.structural{1}{1}={filename,str,icon};
            filename=fullfile(fileparts(which('conn')),'utils','surf','referenceT1_trans.nii');
            [V,str,icon]=conn_getinfo(filename);
            CONN_gui.refs.canonical=struct('filename',filename,'V',V,'data',spm_read_vols(V));
            [x,y,z]=ndgrid(1:CONN_gui.refs.canonical.V.dim(1),1:CONN_gui.refs.canonical.V.dim(2),1:CONN_gui.refs.canonical.V.dim(3));
            CONN_gui.refs.canonical.xyz=CONN_gui.refs.canonical.V.mat*[x(:),y(:),z(:),ones(numel(z),1)]';
            filename=fullfile(fileparts(which('conn')),'rois','atlas.nii');
            [filename_path,filename_name,filename_ext]=fileparts(filename);
            V=spm_vol(filename);
            CONN_gui.refs.rois=struct('filename',filename,'filenameshort',filename_name,'V',V,'data',spm_read_vols(V),'labels',{textread(fullfile(filename_path,[filename_name,'.txt']),'%s','delimiter','\n')});
            CONN_gui.refs.surf.spherereduced=conn_surf_sphere(5);
            [CONN_gui.refs.surf.spheredefault,CONN_gui.refs.surf.default2reduced]=conn_surf_sphere(8,CONN_gui.refs.surf.spherereduced.vertices);
            CONN_gui.refs.surf.defaultsize=[42 83 47*2];%conn_surf_dims(8).*[1 1 2];
            CONN_gui.refs.surf.reducedsize=[42 61 2];   %conn_surf_dims(5); CONN_gui.refs.surf.reducedsize=[prod(CONN_gui.refs.surf.reducedsize(1:2)),CONN_gui.refs.surf.reducedsize(3),2];
            CONN_gui.refs.surf.default=conn_surf_readsurf;
            CONN_gui.refs.surf.defaultreduced=CONN_gui.refs.surf.default;
            CONN_gui.refs.surf.defaultreduced(1).vertices=CONN_gui.refs.surf.defaultreduced(1).vertices(CONN_gui.refs.surf.default2reduced,:);
            CONN_gui.refs.surf.defaultreduced(1).faces=CONN_gui.refs.surf.spherereduced.faces;
            CONN_gui.refs.surf.defaultreduced(2).vertices=CONN_gui.refs.surf.defaultreduced(2).vertices(CONN_gui.refs.surf.default2reduced,:);
            CONN_gui.refs.surf.defaultreduced(2).faces=CONN_gui.refs.surf.spherereduced.faces;
            if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
            CONN_gui.parse_html={'<HTML><FONT color=rgb(100,100,100)>','</FONT></HTML>'};
            %CONN_gui.parse_html={'',''};
            
        case {'close','forceclose'}
            connversion={'CONN functional connectivity toolbox',' (',connver,') '};
            hfig=findobj('tag',connversion{1});
            if ~isempty(hfig)&&ishandle(hfig),
                if strcmp(lower(varargin{1}),'forceclose'), CONN_gui.status=1; delete(hfig); 
                else close(hfig);
                end
                CONN_x.gui=0;
                %CONN_x=[];
                %CONN_gui=[];
                CONN_h=[];
                return;
            end
            
        case 'importrois',
            if ~isfield(CONN_x.folders,'rois'), CONN_x.folders.rois=fullfile(fileparts(which(mfilename)),'rois'); end
            path=CONN_x.folders.rois;
            names=cat(1,dir(fullfile(path,'*.nii')),dir(fullfile(path,'*.img')),dir(fullfile(path,'*.tal')));
            names={names(:).name};
            names=names(setdiff(1:numel(names),strmatch('._',names)));
            n0=length(CONN_x.Setup.rois.names)-1;
            for n1=1:length(names),
                [nill,name,nameext]=spm_fileparts(names{n1});
                filename=fullfile(path,names{n1});
                [V,str,icon,filename]=conn_getinfo(filename);
                CONN_x.Setup.rois.names{n0+n1}=name; CONN_x.Setup.rois.names{n0+n1+1}=' ';
                for nsub=1:CONN_x.Setup.nsubjects, 
                    for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                        CONN_x.Setup.rois.files{nsub}{n0+n1}{nses}={filename,str,icon};
                    end
                end
                CONN_x.Setup.rois.dimensions{n0+n1}=1;
                CONN_x.Setup.rois.mask(n0+n1)=0;
                CONN_x.Setup.rois.subjectspecific(n0+n1)=0;
                CONN_x.Setup.rois.sessionspecific(n0+n1)=0;
                CONN_x.Setup.rois.multiplelabels(n0+n1)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',filename,'.txt')))|~isempty(dir(conn_prepend('',filename,'.csv')))|~isempty(dir(conn_prepend('',filename,'.xls'))));
                CONN_x.Setup.rois.regresscovariates(n0+n1)=double(CONN_x.Setup.rois.dimensions{n0+n1}>1);
                CONN_x.Setup.rois.unsmoothedvolumes(n0+n1)=1;
            end
            
        case 'load',
            if nargin>1,filename=varargin{2}; 
            else filename=CONN_x.filename; end
            if nargin>2,fromgui=varargin{3}; 
            else fromgui=false; end
            if isempty(filename)||~ischar(filename),
                disp('warning: invalid filename, project NOT loaded');
            else
                folderchanged={};
                [basefilename,pobj]=conn_projectmanager('extendedname',filename);
                localfilename=conn_projectmanager('projectfile',basefilename,pobj);
				try 
                    if ~pobj.isextended||conn_existfile(localfilename), errstr=localfilename; load(localfilename,'CONN_x','-mat'); 
                    else errstr=basefilename; load(basefilename,'CONN_x','-mat'); 
                    end
                    folderchanged{1}=fileparts(CONN_x.filename);
                    folderchanged{2}=fileparts(errstr);
                catch %#ok<*CTCH>
                    error(['Failed to load file ',errstr,'.']); 
                    return; 
                end
                if fromgui, CONN_x.gui=1; end
                if ~pobj.isextended&&isfield(CONN_x,'pobj'), % note: fix when attempting to load an extended project directly (e.g. conn load conn_test.#.dmat) instead of indirectly (e.g. conn load conn_test.mat?id=#)
                    pobj=CONN_x.pobj;
                    [basefilename,localfilename]=conn_projectmanager('parentfile',basefilename,pobj);
                end
                if pobj.holdsdata, CONN_x.filename=conn_fullfile(localfilename);
                else CONN_x.filename=conn_fullfile(basefilename);
                end
                CONN_x.pobj=pobj;
                if pobj.holdsdata, conn_updatefolders; end
                conn_projectmanager('updateproject',fromgui);
                if fromgui,
                	CONN_x.gui=1;
                    try
                        if numel(folderchanged)==2&&~isempty(folderchanged{1})&&~isempty(folderchanged{2})&&~isequal(folderchanged{:}), 
                            conn_updatefilepaths('add', folderchanged{:}); 
                            conn_updatefilepaths;
                            conn_updatefilepaths('hold','off');
                        else
                            conn_updatefilepaths;
                        end
                    end
                    if isfield(CONN_x,'lastver')&&~isempty(CONN_x.lastver)&&~conn('checkver',CONN_x.lastver)
                        answ=conn_questdlg({'WARNING!!!',sprintf('This CONN project has been saved using a more recent version of CONN (%s)',CONN_x.lastver),sprintf('Proceeding to load this project using CONN %s may cause serious compatibility problems',connver)},'','Proceed','Cancel','Cancel');
                        if isequal(answ,'Cancel')
                            conn init;
                            conn importrois;
                            conn gui_setup
                            return;
                        end
                    end
                end
                CONN_x.lastver=connver; 
                CONN_x.isready(1)=1;
            end
			
		case 'save',
            if nargin>1, filename=varargin{2}; 
            else filename=CONN_x.filename; end
            if isempty(filename)||~ischar(filename),
                error('invalid filename, project NOT saved');
            else
                saveas=~isequal(filename,CONN_x.filename);
                CONN_x.filename=conn_fullfile(filename);
                if CONN_x.pobj.holdsdata, 
                    localfilename=CONN_x.filename;
                    conn_updatefolders;
                else
                    localfilename=conn_projectmanager('projectfile');
                end
                try
                    save(localfilename,'CONN_x');
                catch
                    error(['Failed to save file ',localfilename,'. Check file name and/or folder permissions']);
                end
                CONN_x.isready(1)=1;
                if ~saveas&&CONN_x.pobj.holdsdata,
                    try
                        conn_projectmanager cleanproject;
                    catch
                        disp('ERROR: CONN was not able to delete the following files. Please delete them');
                        disp('manually before proceeding.');
                        disp(char(CONN_x.pobj.importedfiles));
                        error('Failed to delete temporal project files. Check file name and/or folder permissions');
                    end
                end
                if ~saveas
                    if isfield(CONN_x,'Analyses')
                        for ianalysis=1:numel(CONN_x.Analyses)
                            if isfield(CONN_x.Analyses(ianalysis),'name')&&isfield(CONN_x.Analyses(ianalysis),'sourcenames')
                                filesourcenames=fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(ianalysis).name,'_list_sources.mat');
                                filesourcenames=conn_projectmanager('projectfile',filesourcenames,CONN_x.pobj,'.mat');
                                sourcenames=CONN_x.Analyses(ianalysis).sourcenames;
                                save(filesourcenames,'sourcenames');
                            end
                        end
                    end
                    if isfield(CONN_x,'vvAnalyses')
                        for ianalysis=1:numel(CONN_x.vvAnalyses)
                            if isfield(CONN_x.vvAnalyses(ianalysis),'name')&&isfield(CONN_x.vvAnalyses(ianalysis),'measurenames')
                                filemeasurenames=fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses(ianalysis).name,'_list_measures.mat');
                                filemeasurenames=conn_projectmanager('projectfile',filemeasurenames,CONN_x.pobj,'.mat');
                                measurenames=CONN_x.vvAnalyses(ianalysis).measurenames;
                                save(filemeasurenames,'measurenames');
                            end
                        end
                    end
                    if isfield(CONN_x.Setup.conditions,'allnames')
                        fileconditionnames=fullfile(CONN_x.folders.preprocessing,'_list_conditions.mat');
                        fileconditionnames=conn_projectmanager('projectfile',fileconditionnames,CONN_x.pobj,'.mat');
                        allnames=CONN_x.Setup.conditions.allnames;
                        save(fileconditionnames,'allnames');
                    end
                end
            end

        case 'ver'
            varargout={connver};
            
        case 'checkver',
            ver2=varargin{2};
            if nargin>=3&&~isempty(varargin{3}), ver1=varargin{3}; else ver1=connver; end
            v1=str2num(regexp(ver1,'^\d+','match','once'));
            r1=char(regexp(ver1,'^\d+\.(.+)$','tokens','once'));
            v2=str2num(regexp(ver2,'^\d+','match','once'));
            r2=char(regexp(ver2,'^\d+\.(.+)$','tokens','once'));
            [nill,idx]=sort({r2,r1});
            varargout={v1>v2 | (v1==v2&idx(1)==1)};
            
        case 'background_image'
            if nargin>1
                filename=varargin{2};
            else
                filename=spm_select(1,'\.img$|\.nii$',['Select background anatomical image'],{},fileparts(CONN_gui.refs.canonical.filename));
                if isempty(filename), return; end
            end
            [V,str,icon,filename]=conn_getinfo(filename);
            CONN_gui.refs.canonical=struct('filename',filename,'V',V,'data',spm_read_vols(V));
            [x,y,z]=ndgrid(1:CONN_gui.refs.canonical.V.dim(1),1:CONN_gui.refs.canonical.V.dim(2),1:CONN_gui.refs.canonical.V.dim(3));
            CONN_gui.refs.canonical.xyz=CONN_gui.refs.canonical.V.mat*[x(:),y(:),z(:),ones(numel(z),1)]';
            
        case 'background_rois'
            if nargin>1
                filename=varargin{2};
            else
                filename=spm_select(1,'\.img$|\.nii$',['Select background ROI atlas'],{CONN_gui.refs.rois.filename},fileparts(CONN_gui.refs.rois.filename));
                if isempty(filename), return; end
            end
            [filename_path,filename_name,filename_ext]=fileparts(filename);
            V=spm_vol(filename);
            CONN_gui.refs.rois=struct('filename',filename,'filenameshort',filename_name,'V',V,'data',spm_read_vols(V),'labels',{textread(fullfile(filename_path,[filename_name,'.txt']),'%s','delimiter','\n')});
            clear conn_vproject;

        case 'gui_unlockall'
            if nargin>1, CONN_x.isready(1:min(numel(CONN_x.isready),numel(varargin{2})))=varargin{2}(1:min(numel(CONN_x.isready),numel(varargin{2})));
            else CONN_x.isready(:)=1;
            end
            conn gui_setup;
            
        case 'gui_analyses_cleanup'
            ok=arrayfun(@(n)exist(fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(n).name),'dir'),1:numel(CONN_x.Analyses))>0;
            if ~any(ok), ok(1)=true; end
            CONN_x.Analyses=CONN_x.Analyses(ok); 
            CONN_x.Analysis=1;
            ok=arrayfun(@(n)exist(fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses(n).name),'dir'),1:numel(CONN_x.vvAnalyses))>0;
            if ~any(ok), ok(1)=true; end
            CONN_x.vvAnalyses=CONN_x.vvAnalyses(ok); 
            CONN_x.vvAnalysis=1;
            ok=arrayfun(@(n)exist(fullfile(CONN_x.folders.firstlevel_dyn,CONN_x.dynAnalyses(n).name),'dir'),1:numel(CONN_x.dynAnalyses))>0;
            if ~any(ok), ok(1)=true; end
            CONN_x.dynAnalyses=CONN_x.dynAnalyses(ok); 
            CONN_x.dynAnalysis=1;
            conn('gui_analysesgo',[]);
               
        case 'gui_calculator'
            conn_menumanager clf;
            conn_menuframe;
            tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;conn_menumanager(CONN_h.menus.m0,'state',tstate);
            conn_menu('frame2border',[.0,.955,1,.045],'');
            conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
            conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
            conn_calculator;
            
        case 'gui_setup_preproc'
            if nargin>1
                ok=conn_setup_preproc('',varargin{2:end});
            else
                ok=conn_setup_preproc;
            end
            if ok==2
                conn gui_setup; 
                conn_msgbox({'Preprocessing finished correctly; Output files imported.'},'',true);
                %conn save; 
            elseif ok==1
                conn_msgbox({'Preprocessing finished correctly'},'',true);
            elseif ok<0
                conn_msgbox({'Some error occurred when running SPM batch.','Please see Matlab command window for full report'},'',2);
            end
            return;
            
        case 'gui_help',
            switch(lower(varargin{2}))
                case 'url'
                    disp(varargin{3});
                    web(varargin{3},'-browser');
                case 'doc'
                    try
                        if nargin<3
                            name=dir(fullfile(fileparts(which(mfilename)),'CONN_fMRI_Functional_connectivity_toolbox_manual*.pdf'));
                            if ~isempty(name)
                                fname=fullfile(fileparts(which(mfilename)),name(1).name);
                                open(fname);
                            end
                        else
                            fname=varargin{3};
                            open(fname);
                        end
                    catch
                        url='http://www.conn-toolbox.org/resources/manuals';
                        if isequal('Visit',conn_questdlg({sprintf('Unable to display file %s',fname),'Would you like to visit CONN documentation site?',sprintf('(%s)',url)},'Error','Visit','Cancel','Visit')), web(url,'-browser'); end
                    end
                case 'help'
                    if iscell(varargin{3}), str=varargin{3};
                    else
                        if isdeployed,
                            str=fileread(regexprep(which(varargin{3}),'\.m$','.help.txt'));
                            str=regexp(str,'\n([^\n]*)','tokens'); str=[str{:}];
                            %str=fileread(which(varargin{3}));
                            %str=regexp(str,'\n\%+([^\n]*)','tokens'); str=[str{:}];
                            str=regexprep(str,char(13),'');
                            str(find(strcmp(str,'$'),1):end)=[];
                            str(cellfun(@isempty,str))=[];
                        else
                            str=help(varargin{3});
                            str=regexp(str,'\n','split');
                        end
                    end
                    str=regexprep(str,'(<HTML>)?(\s*)(.*)\%\!(</HTML>)?','<HTML><pre>$2<b>$3</b></pre></HTML>');
                    dlg.fig=figure('units','norm','position',[.2,.1,.6,.8],'menubar','none','numbertitle','off','name','help','color','w');
                    dlg.box=uicontrol(dlg.fig,'units','norm','position',[0 0 1 1],'style','listbox','max',1,'str',str,'backgroundcolor','w','horizontalalignment','left','fontname','monospaced');
                    uiwait(dlg.fig,1);
            end
            
        case 'gui_workshop',
            place='Boston MGH/HST';
            dates={'April 30 2018','May 4 2018','April 30 - May 4 2018'};
            passed=false;
            try, dates(1:2)=cellfun(@datenum,dates(1:2),'uni',0); end
            if now>=dates{1}
                if now>dates{2}, str=['The previous 5-day CONN workshop has been held in ',place,' ',dates{3}];
                else str=['The CONN workshop is being held RIGHT NOW in ',place,' ',dates{3}]; passed=true;
                end
            else str=['The next 5-day CONN workshop will be held in ',place,' ',dates{3},sprintf(' (%d days from today)',floor(dates{1}-now))];
            end
            if passed, 
                url='www.conn-toolbox.org';
                answ=conn_questdlg({'CONN workshops are organized annually. They offer intensive hands-on training on CONN usage and functional connectivity analyses',' ',str,['Visit ',url,' for more up to date information']},'','Visit','Cancel','Visit');
            else
                url='www.conn-toolbox.org/workshops';
                answ=conn_questdlg({'CONN workshops are organized annually. They offer intensive hands-on training on CONN usage and functional connectivity analyses',' ',str,['Visit ',url,' for additional information and registration']},'','Visit','Cancel','Visit');
            end
            if isequal(answ,'Visit')
                conn('gui_help','url',['http://',url]);
            end
            
        case 'gui_settings',
            dlg.fig=figure('units','norm','position',[.3,.1,.4,.4],'menubar','none','numbertitle','off','name','GUI settings','color','w');
            %uicontrol('style','frame','unit','norm','position',[.05,.5,.9,.45],'backgroundcolor','w','foregroundcolor',[.5 .5 .5]);
            uicontrol('style','text','units','norm','position',[.1,.86,.45,.075],'backgroundcolor','w','foregroundcolor','k','horizontalalignment','right','string','GUI font size (pts):');
            dlg.m1=uicontrol('style','edit','units','norm','position',[.6,.86,.1,.075],'string',num2str(8+CONN_gui.font_offset),'tooltipstring','Changes the default font size used in the CONN toolbox GUI');
            dlg.m4A=uicontrol('style','pushbutton','units','norm','position',[.65,.775,.05,.075],'string',' ','backgroundcolor',min(1,CONN_gui.backgroundcolorA),'tooltipstring','Changes the frame color used in the CONN toolbox GUI','callback','color=get(gcbo,''backgroundcolor'');if numel(color)~=3, color=uisetcolor; else color=uisetcolor(color); end; if numel(color)==3, set(gcbo,''backgroundcolor'',color); set(gcbf,''userdata'',1); uiresume(gcbf); end');
            dlg.m4=uicontrol('style','pushbutton','units','norm','position',[.6,.775,.05,.075],'string',' ','backgroundcolor',min(1,CONN_gui.backgroundcolor),'tooltipstring','Changes the background color used in the CONN toolbox GUI','callback','h=get(gcbo,''userdata''); color=get(gcbo,''backgroundcolor'');if numel(color)~=3, color=uisetcolor; else color=uisetcolor(color); end; if numel(color)==3, set(gcbo,''backgroundcolor'',color); colorA=color;set(h,''backgroundcolor'',colorA); set(gcbf,''userdata'',1); uiresume(gcbf); end','userdata',dlg.m4A);
            dlg.m5=uicontrol('style','checkbox','units','norm','position',[.1,.70,.4,.075],'string','Enable tooltips','backgroundcolor','w','tooltipstring','Display help information over each clickable/editable field in the GUI','value',CONN_gui.tooltips);
            %dlg.m6=uicontrol('style','checkbox','units','norm','position',[.1,.625,.8,.075],'string','Troubleshot: use alternative popupmenu type','backgroundcolor','w','tooltipstring','Fixes lightText-on-lightBackground popup menus issue on Mac OS when using dark backgrounds','value',CONN_gui.domacGUIbugfix>0);
            %dlg.m8=uicontrol('style','checkbox','units','norm','position',[.1,.55,.8,.075],'string','Troubleshot: use alternative pushbutton type','backgroundcolor','w','tooltipstring','Fixes fuzzy text on push-buttons','value',CONN_gui.dounixGUIbugfix>0);
            dlg.m7=uicontrol('style','checkbox','units','norm','position',[.1,.625,.4,.075],'string','Automatic updates','backgroundcolor','w','tooltipstring','Checks NITRC site for CONN toolbox updates each time CONN is started and offers to download/install if updates are available','value',CONN_gui.checkupdates);
            uicontrol('style','pushbutton','units','norm','position',[.75,.86,.05,.055],'string','-','backgroundcolor','w','tooltipstring','Decrease font size','callback','hdl=get(gcbo,''userdata''); fontsize=str2num(get(hdl,''string'')); fontsize=max(0,fontsize-1); if numel(fontsize)==1, set(hdl,''string'',num2str(fontsize)); end','userdata',dlg.m1);
            uicontrol('style','pushbutton','units','norm','position',[.80,.86,.05,.055],'string','+','backgroundcolor','w','tooltipstring','Increase font size','callback','hdl=get(gcbo,''userdata''); fontsize=str2num(get(hdl,''string'')); fontsize=fontsize+1; if numel(fontsize)==1, set(hdl,''string'',num2str(fontsize)); end','userdata',dlg.m1);
            uicontrol('style','pushbutton','units','norm','position',[.75,.785,.05,.055],'string','-','backgroundcolor','w','tooltipstring','Decrease brightness','callback','for hdl=get(gcbo,''userdata''), color=get(hdl,''backgroundcolor''); color=max(0,color*.9); if numel(color)==3, set(hdl,''backgroundcolor'',color); end; end','userdata',[dlg.m4 dlg.m4A]);
            uicontrol('style','pushbutton','units','norm','position',[.80,.785,.05,.055],'string','+','backgroundcolor','w','tooltipstring','Increase brightness','callback','for hdl=get(gcbo,''userdata''), color=get(hdl,''backgroundcolor''); color=min(1,color/.9); if numel(color)==3, set(hdl,''backgroundcolor'',color); end; end','userdata',[dlg.m4 dlg.m4A]);
%             hc1=uicontextmenu; 
%               uimenu(hc1,'label','Set GUI background image from file','callback','conn_guibackground setfile'); 
%               uimenu(hc1,'label','Set GUI background image from screenshot','callback','conn_guibackground cleartrans'); 
%               uimenu(hc1,'label','Remove GUI background image','callback','conn_guibackground clear'); 
%               set(dlg.m4,'uicontextmenu',hc1);
            uicontrol('style','popupmenu','units','norm','position',[.1,.775,.45,.075],'backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','string',{'<HTML><i>Select GUI background color/image</i></HTML>','Light text on dark background theme','Dark text on light background theme','Random background image','Screenshot background image','User-defined background image'},'userdata',[dlg.m4 dlg.m4A],'callback',...
                'h=get(gcbo,''userdata''); switch(get(gcbo,''value'')), case 1, conn_guibackground clear; color=uisetcolor; if numel(color)==3, set(h(1),''backgroundcolor'',color); colorA=color;set(h(2),''backgroundcolor'',colorA); end; case 2, conn_guibackground clear; color=.14*[1 1 1]; set(h(1),''backgroundcolor'',color); colorA=.17*[1 1 1];set(h(2),''backgroundcolor'',colorA); case 3, conn_guibackground clear; color=.9*[1 1 1]; set(h(1),''backgroundcolor'',color); colorA=.95*[1 1 1];set(h(2),''backgroundcolor'',colorA); case 4, answ=conn_guibackground(''setfiledefault''); case 5, answ=conn_guibackground(''cleartrans''); case 6, answ=conn_guibackground(''setfile''); end; set(gcbf,''userdata'',1); uiresume(gcbf);',...
                'tooltipstring','Changes the default theme colors in the CONN toolbox GUI');
            uicontrol('style','frame','unit','norm','position',[.05,.15,.9,.25],'backgroundcolor','w','foregroundcolor',[.5 .5 .5]);
            %uicontrol('style','text','unit','norm','position',[.07,.91,.3,.08],'string','Appearance','backgroundcolor','w','foregroundcolor',[.5 .5 .5]);
            uicontrol('style','text','unit','norm','position',[.07,.355,.6,.08],'string','GUI reference-brain (for second-level result displays)','backgroundcolor','w','foregroundcolor',[.5 .5 .5]);
            %uicontrol('style','text','units','norm','position',[.1,.375,.8,.075],'backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','string','GUI reference-brain (for second-level result displays):');
            dlg.m2=uicontrol('style','pushbutton','units','norm','position',[.1,.275,.8,.1],'string','Background anatomical image','tooltipstring',CONN_gui.refs.canonical.filename,'callback','filename=spm_select(1,''\.img$|\.nii$'',''Select image'',{get(gcbo,''tooltipstring'')},fileparts(get(gcbo,''tooltipstring'')));if ~isempty(filename), set(gcbo,''tooltipstring'',filename); end;');
            dlg.m3=uicontrol('style','pushbutton','units','norm','position',[.1,.175,.8,.1],'string','Background reference atlas','tooltipstring',CONN_gui.refs.rois.filename,'callback','filename=spm_select(1,''\.img$|\.nii$'',''Select image'',{get(gcbo,''tooltipstring'')},fileparts(get(gcbo,''tooltipstring'')));if ~isempty(filename), set(gcbo,''tooltipstring'',filename); end;');
            dlg.m11=uicontrol('style','pushbutton','units','norm','position',[.35,.025,.2,.1],'string','Save','tooltipstring','Accept changes','callback','set(gcbf,''userdata'',0); uiresume(gcbf)');
            dlg.m12=uicontrol('style','pushbutton','units','norm','position',[.55,.025,.2,.1],'string','Exit','callback','delete(gcbf)');
            dlg.m13=uicontrol('style','pushbutton','units','norm','position',[.75,.025,.2,.1],'string','Apply','tooltipstring','Apply changes','callback','set(gcbf,''userdata'',1); uiresume(gcbf)');
            while 1
                set(dlg.fig,'handlevisibility','on','hittest','on','userdata',[]);
                uiwait(dlg.fig);
                if ~ishandle(dlg.fig), break; end
                ok=get(dlg.fig,'userdata');
                if isempty(ok), break; end
                set(dlg.fig,'handlevisibility','off','hittest','off');
                if iscell(CONN_gui.background), 
                    set(dlg.fig,'visible','off'); pause(.1);
                    answ=conn_guibackground('settrans'); 
                    set(dlg.fig,'visible','on');
                end
                answ=get(dlg.m1,'string');
                if ~isempty(answ)&&~isempty(str2num(answ)),
                    CONN_gui.font_offset=max(4,str2num(answ))-8;
                    set(0,{'defaultuicontrolfontsize','defaulttextfontsize','defaultaxesfontsize'},repmat({8+CONN_gui.font_offset},1,3));
                end
                CONN_gui.tooltips=get(dlg.m5,'value');
                %CONN_gui.domacGUIbugfix=get(dlg.m6,'value');
                %CONN_gui.dounixGUIbugfix=get(dlg.m8,'value');
                CONN_gui.checkupdates=get(dlg.m7,'value');
                answ=get(dlg.m4,'backgroundcolor');
                answA=get(dlg.m4A,'backgroundcolor');
                CONN_gui.backgroundcolor=answ;%/2;
                CONN_gui.backgroundcolorA=answA;
                CONN_gui.backgroundcolorE=max(0,min(1, .5*CONN_gui.backgroundcolor+.5*[2 2 6]/6));
                %CONN_gui.backgroundcolorA=max(0,min(1,CONN_gui.backgroundcolor*(1.1+0.9*(mean(CONN_gui.backgroundcolor)<.5))));
                %CONN_gui.backgroundcolorA=.75*CONN_gui.backgroundcolorA+.25*mean(CONN_gui.backgroundcolorA);
                CONN_gui.fontcolorA=[.10 .10 .10]+.8*(mean(CONN_gui.backgroundcolorA)<.5);
                CONN_gui.fontcolorB=[.4 .4 .4]+.2*(mean(CONN_gui.backgroundcolorA)<.5);
                cmap=.25+.75*(6*gray(128) + 2*(hot(128)))/8; if mean(CONN_gui.backgroundcolor)>.5,cmap=flipud(cmap); end
                jetmap=jet(128); %[linspace(.1,1,64)',zeros(64,2)];jetmap=[flipud(fliplr(jetmap));jetmap];
                CONN_h.screen.colormap=max(0,min(1, diag((1-linspace(1,0,256)'.^50))*[cmap;jetmap]+(linspace(1,0,256)'.^50)*CONN_gui.backgroundcolor ));
                CONN_h.screen.colormapA=max(0,min(1, diag((1-linspace(1,0,256)'.^50))*[cmap;jetmap]+(linspace(1,0,256)'.^50)*CONN_gui.backgroundcolorA ));
                set(CONN_h.screen.hfig,'color',CONN_gui.backgroundcolor,'colormap',CONN_h.screen.colormap);
                conn_menumanager updatebackgroundcolor;
                filename=get(dlg.m2,'tooltipstring');
                if ~strcmp(filename,CONN_gui.refs.canonical.filename)
                    if isempty(dir(filename))
                        filename=spm_select(1,'\.img$|\.nii$',['Select background anatomical image'],{CONN_gui.refs.canonical.filename},fileparts(CONN_gui.refs.canonical.filename));
                    end
                    if ~isempty(filename),
                        [V,str,icon,filename]=conn_getinfo(filename);
                        CONN_gui.refs.canonical=struct('filename',filename,'V',V,'data',spm_read_vols(V));
                        [x,y,z]=ndgrid(1:CONN_gui.refs.canonical.V.dim(1),1:CONN_gui.refs.canonical.V.dim(2),1:CONN_gui.refs.canonical.V.dim(3));
                        CONN_gui.refs.canonical.xyz=CONN_gui.refs.canonical.V.mat*[x(:),y(:),z(:),ones(numel(z),1)]';
                    end
                end
                filename=get(dlg.m3,'tooltipstring');
                if ~strcmp(filename,CONN_gui.refs.rois.filename)
                    if isempty(dir(filename))
                        filename=spm_select(1,'image',['Select background reference atlas'],{CONN_gui.refs.rois.filename},fileparts(CONN_gui.refs.rois.filename));
                    end
                    if ~isempty(dir(filename))
                        [filename_path,filename_name,filename_ext]=fileparts(filename);
                        V=spm_vol(filename);
                        if numel(V)>1, [nill,data]=max(spm_read_vols(V),[],4);
                        else data=spm_read_vols(V);
                        end
                        CONN_gui.refs.rois=struct('filename',filename,'filenameshort',filename_name,'V',V,'data',data,'labels',{textread(fullfile(filename_path,[filename_name,'.txt']),'%s','delimiter','\n')});
                        clear conn_vproject;
                    end
                end
                tstate=conn_menumanager(CONN_h.menus.m0,'state');
                if any(tstate)
                    switch(find(tstate))
                        case 1, conn gui_setup;
                        case 2, conn gui_preproc;
                        case 3, conn('gui_analysesgo',[]);
                        case 4, conn('gui_resultsgo',[]);
                        otherwise, conn gui_setup;
                    end
                else conn gui_setup;
                end
                if ~ok, break; 
                elseif ishandle(dlg.fig), figure(dlg.fig); 
                end
            end
            if ishandle(dlg.fig), 
                delete(dlg.fig); 
                conn_font_offset=CONN_gui.font_offset;
                conn_backgroundcolor=CONN_gui.backgroundcolor;
                conn_backgroundcolorA=CONN_gui.backgroundcolorA;
                conn_background=CONN_gui.background;
                conn_tooltips=CONN_gui.tooltips;
                conn_domacGUIbugfix=CONN_gui.domacGUIbugfix;
                conn_dounixGUIbugfix=CONN_gui.dounixGUIbugfix;
                conn_checkupdates=CONN_gui.checkupdates;
                answ=conn_questdlg('Save these graphic settings for all users or current user only?','','All','Current','None','Current');
                if ~(isempty(answ)||strcmp(answ,'None')), 
                    if strcmp(answ,'All'),
                        if isdeployed, filename=fullfile(matlabroot,'conn_font_default.dat');
                        else filename=fullfile(fileparts(which(mfilename)),'conn_font_default.dat');
                        end
                    else
                        filename=conn_fullfile('~/conn_font_default.dat');
                    end
                    try, 
                        save(filename,'conn_font_offset','conn_backgroundcolor','conn_backgroundcolorA','conn_background','conn_tooltips','conn_domacGUIbugfix','conn_dounixGUIbugfix','conn_checkupdates','-mat');
                        fprintf('Graphic settings saved to file %s\n',filename);
                    catch
                        fprintf('unable to save file %s\n',filename);
                        try, 
                            save(fullfile(pwd,filename),'conn_font_offset','conn_backgroundcolor','conn_backgroundcolorA','conn_background','conn_tooltips','conn_domacGUIbugfix','conn_dounixGUIbugfix','conn_checkupdates','-mat'); 
                            fprintf('Graphic settings saved to file %s\n',fullfile(pwd,filename));
                        end
                    end
                end
            end
            
        case 'parallel_settings'
            conn_jobmanager('settings');
            
        case 'set'
            for n=2:2:nargin
                str=regexp(varargin{n},'\.','split');
                if n==nargin, varargout={getfield(CONN_x,str{:})};
                else CONN_x=setfield(CONN_x,str{:},varargin{n+1});
                end
            end
            
        case 'get'
            str=regexp(varargin{2},'\.','split');
            varargout={getfield(CONN_x,str{:})};
            
        case 'guiset'
            for n=2:2:nargin
                str=regexp(varargin{n},'\.','split');
                if n==nargin, varargout={getfield(CONN_gui,str{:})};
                else CONN_gui=setfield(CONN_gui,str{:},varargin{n+1});
                end
            end
            
        case 'guiget'
            str=regexp(varargin{2},'\.','split');
            varargout={getfield(CONN_gui,str{:})};
            
        case 'modalfig',
            if ~isfield(CONN_gui,'modalfig'), CONN_gui.modalfig=[]; end
            if numel(varargin)>1, CONN_gui.modalfig=[CONN_gui.modalfig varargin{2}(:)']; end
            if numel(CONN_gui.modalfig)>10, CONN_gui.modalfig=CONN_gui.modalfig(end-10+1:end); end
            varargout={CONN_gui.modalfig};
            
        case 'run_cmd',
            if nargin>1&&~isempty(varargin{2}), str=varargin{2};
            else
                answ=inputdlg({'Enter Matlab command: (evaluated in the base Matlab workspace)'},'',1,{''},struct('Resize','on'));
                if numel(answ)~=1||isempty(answ{1}),return; end
                str=answ{1};
            end
            hmsg=conn_msgbox('Evaluating command... please wait','');
            conn_batch(str);
            if ishandle(hmsg), delete(hmsg); end
            
        case 'run',
            if nargin>1&&~isempty(varargin{2}), filename=varargin{2};
            else
                [tfilename,tpathname]=uigetfile({'*.m','Matlab batch script (*.m)'; '*.mat','Matlab batch structure (*.mat)'; '*',  'All Files (*)'},'Select batch file');
                if ~ischar(tfilename)||isempty(tfilename), return; end
                filename=fullfile(tpathname,tfilename);
            end
            hmsg=conn_msgbox('Running batch script... please wait','');
            conn_batch(filename);
            if ishandle(hmsg), delete(hmsg); end
			
        case 'run_process'
			if isempty(CONN_x.filename), conn gui_setup_save; end
            if conn_questdlgrun('Choose processing steps',[],CONN_x.Setup.steps(1:3),false,[],true,1:5,true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                psteps={'setup','denoising_gui','analyses_gui_seedandroi','analyses_gui_vv','analyses_gui_dyn'};
                psteps=sprintf('%s;',psteps{CONN_x.gui.processes{1}});
                if CONN_x.gui.parallel~=0, 
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    if isfield(CONN_x.gui,'subjects'), subjects=CONN_x.gui.subjects; else subjects=[]; end
                    conn save;
                    conn_jobmanager('submit',psteps,subjects,[],CONN_x.gui,CONN_x.gui.processes{2:end});
                else conn_process(psteps,CONN_x.gui.processes{2:end});
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                conn gui_setup;
            end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
        case 'gui_setupgo',
            state=varargin{2};
            if ~isfield(CONN_h,'menus')||~isfield(CONN_h.menus,'m_setup_02'), CONN_h.menus.m_setup_02=conn_menumanager([],'displayed',false); end
            tstate=conn_menumanager(CONN_h.menus.m_setup_02,'state'); tstate(:)=0;tstate(state)=1; conn_menumanager(CONN_h.menus.m_setup_02,'state',tstate);
            [varargout{1:nargout}]=conn('gui_setup',varargin{3:end});
            
        case 'gui_setup',
            CONN_x.gui=1;
			state=find(conn_menumanager(CONN_h.menus.m_setup_02,'state'));
            if nargin<2,
                conn_menumanager clf;
                conn_menuframe;
                CONN_x.isready(1)=~isempty(CONN_x.filename);
                if ~CONN_x.isready(1), 
                    tstate=conn_menumanager(CONN_h.menus.m_setup_07a,'enable'); tstate(3:end)=0; conn_menumanager(CONN_h.menus.m_setup_07a,'enable',tstate); 
                    tstate=conn_menumanager(CONN_h.menus.m_setup_07f,'enable'); tstate(2:end)=0; conn_menumanager(CONN_h.menus.m_setup_07f,'enable',tstate); 
                    tstate=conn_menumanager(CONN_h.menus.m_setup_01a,'enable'); tstate(4:end)=0; conn_menumanager(CONN_h.menus.m_setup_01a,'enable',tstate); 
                    
                else 
                    tstate=conn_menumanager(CONN_h.menus.m_setup_07a,'enable'); tstate(3:end)=1; conn_menumanager(CONN_h.menus.m_setup_07a,'enable',tstate); 
                    tstate=conn_menumanager(CONN_h.menus.m_setup_07f,'enable'); tstate(2:end)=1; conn_menumanager(CONN_h.menus.m_setup_07f,'enable',tstate); 
                    tstate=conn_menumanager(CONN_h.menus.m_setup_01a,'enable'); tstate(4:end)=1; conn_menumanager(CONN_h.menus.m_setup_01a,'enable',tstate); 
                end
                %conn_menu('frame2border',[.0,.0,.135,1],'');
                %axes('units','norm','position',[.10,.36,.002,.42]); image(shiftdim(1-CONN_gui.backgroundcolorA,-1)); axis off;
				tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(1)=CONN_x.isready(1); conn_menumanager(CONN_h.menus.m0,'state',tstate); 
                %conn_menu('frame',[.015-.001,.5-.05-.001,.07+.002,7*.05+.002],'');
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
				conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                conn_menu('nullstr',{'No data','selected'});
                if ~CONN_x.isready(1), 
                    imicon=imread(fullfile(fileparts(which(mfilename)),'conn_icon.jpg')); ha=axes('units','norm','position',[.425 .3 .15 .4]);him=image(conn_bsxfun(@plus,shiftdim([.1 .1 .1],-1),conn_bsxfun(@times,.5*shiftdim(1-[.1 .1 .1],-1),double(imicon)/255)),'parent',ha);axis(ha,'equal','off');
                    conn_menumanager(CONN_h.menus.m_setup_01b,'on',1);
                    return; 
                end
                %conn_menu('frame2border',[.0,.0,.135,.94]);
                %conn_menu('frame2border',[.005,.79-8*.06,.13,8*.06]);
				conn_menumanager([CONN_h.menus.m_setup_02,CONN_h.menus.m_setup_01d,CONN_h.menus.m_setup_01e],'on',1);
                %drawnow;
            end
            if isempty(state), return; end
            boffset=[0 0 0 0];
            switch(state),
                case 1, %basic
                    boffset=[.15 -.05 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.19,.36,.27,.44],'Basic information');
						CONN_h.menus.m_setup_00{1}=conn_menu('edit',boffset+[.2,.7,.25,.04],'Number of subjects',num2str(CONN_x.Setup.nsubjects),'Number of subjects in this experiment','conn(''gui_setup'',1);');
						CONN_h.menus.m_setup_00{2}=conn_menu('edit',boffset+[.2,.6,.25,.04],'Number of sessions',num2str(CONN_x.Setup.nsessions,'%1.0f '),'<HTML>Number of scanning sessions or runs per subject <br/> - enter a single number if the same number of scanning sessions were acquired for each subject, or a different number per subject otherwise (e.g. 2 2 3)</HTML>','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('edit',boffset+[.2,.5,.25,.04],'Repetition Time (seconds)',mat2str(CONN_x.Setup.RT),'<HTML>Sampling period of fMRI data, also known as TR (time between two consecutive whole volume acquisitions<br/> - enter a single number if the same TR was used for each subject, or a different number per subject otherwise</HTML>','conn(''gui_setup'',3);');
                        analysistypes={'Continuous','Sparse'};
                        CONN_h.menus.m_setup_00{4}=conn_menu('popup',boffset+[.2,.4,.25,.04],'Acquisition type',analysistypes,'<HTML>Type of acquisition sequence<br/> - selecting <i>sparse acquisition</i> skips hrf-convolution when computing task-related effects</HTML>','conn(''gui_setup'',4);');
                        set(CONN_h.menus.m_setup_00{4},'value',1+(CONN_x.Setup.acquisitiontype~=1));
                    else
                        switch(varargin{2}),
                            case 1, 
								value0=CONN_x.Setup.nsubjects; 
								txt=get(CONN_h.menus.m_setup_00{1},'string'); value=str2num(txt); if ~isempty(value)&&length(value)==1, CONN_x.Setup.nsubjects=value; end; 
								if CONN_x.Setup.nsubjects~=value0, CONN_x.Setup.nsubjects=conn_merge(value0,CONN_x.Setup.nsubjects); end
								set(CONN_h.menus.m_setup_00{1},'string',num2str(CONN_x.Setup.nsubjects)); 
                                set(CONN_h.menus.m_setup_00{2},'string',num2str(CONN_x.Setup.nsessions,'%1.0f '))
                                set(CONN_h.menus.m_setup_00{3},'string',mat2str(CONN_x.Setup.RT));
                                if CONN_x.Setup.nsubjects~=value0, conn gui_setup_save; end
                                if CONN_x.Setup.nsubjects<value0&&any(cellfun('length',{CONN_x.Analyses.sourcenames})>0), conn_process prepare_results_roi; end; 
                            case 2, txt=get(CONN_h.menus.m_setup_00{2},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); catch, value=[]; end; end;if ~isempty(value)&&(length(value)==1||length(value)==CONN_x.Setup.nsubjects), CONN_x.Setup.nsessions=value; end; set(CONN_h.menus.m_setup_00{2},'string',num2str(CONN_x.Setup.nsessions,'%1.0f ')); 
							case 3, txt=get(CONN_h.menus.m_setup_00{3},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); catch, value=[]; end; end;if ~isempty(value)&&(length(value)==1||length(value)==CONN_x.Setup.nsubjects), CONN_x.Setup.RT=value; end; set(CONN_h.menus.m_setup_00{3},'string',mat2str(CONN_x.Setup.RT)); 
                            case 4, value=get(CONN_h.menus.m_setup_00{4},'value'); CONN_x.Setup.acquisitiontype=value;
                        end
                    end
                case 3, %functional
                    boffset=[.02 .06 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.19,.20,.50,.56],'Functional data');
                        conn_menu('frame',boffset+[.19,.03,.50,.08],'Secondary datasets');
                        %global tmp;
						%tmp=conn_menu('text',boffset+[.20,.75,.40,.04],'','Functional data for voxel-level analyses:');
                        %set(tmp,'horizontalalignment','left','fontangle','normal','fontweight','normal','foregroundcolor',CONN_gui.fontcolorA);
                        conn_menu('nullstr',{'No functional','data selected'});
                        tmp=conn_menu('popupblue',boffset+[.56,.77,.129,.04],'',{'(dataset 0)'},'Primary functional dataset','');
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.30,.075,.32],'Subjects','','Select subject(s)','conn(''gui_setup'',1);');
						CONN_h.menus.m_setup_00{2}=conn_menu('listbox',boffset+[.275,.30,.075,.32],'Sessions','','Select session','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('filesearchlocal',[],'Select functional data files','*.img; *.nii; *.gz; *-1.dcm','',{@conn,'gui_setup',3},'conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{4}=conn_menu('pushbutton',boffset+[.40,.65,.24,.09],'','','','conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.36,.35,.31,.30],'','','',[],@conn_callbackdisplay_functionalclick);
                        conn_menu('nullstr',' ');
						CONN_h.menus.m_setup_00{8}=conn_menu('image',boffset+[.44,.24,.19,.05],'voxel BOLD timeseries');
                        %set([CONN_h.menus.m_setup_00{4}],'visible','off'); conn_menumanager('onregion',[CONN_h.menus.m_setup_00{4}],1,boffset+[.35,.25,.34,.55]);
                        ht=uicontrol('style','frame','units','norm','position',boffset+[.35,.66,.34,.09],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA);
                        set(ht,'visible','on'); conn_menumanager('onregion',ht,-1,boffset+[.35,.25,.34,.55]);
                        %ht=uicontrol('style','frame','units','norm','position',[.78,.06,.20,.84],'foregroundcolor',CONN_gui.backgroundcolor,'backgroundcolor',CONN_gui.backgroundcolor);
                        %set(ht,'visible','on'); conn_menumanager('onregion',ht,-1,boffset+[.19,0,.81,1]);
						%CONN_h.menus.m_setup_00{12}=conn_menu('image',boffset+[.39,.26,.25,.05],'Experiment data  (scans/sessions)','','',@conn_callbackdisplay_conditiondesign);
                        CONN_h.menus.m_setup_00{12}=conn_menu('image',boffset+[.39,.34,.25,.01],'','','',@conn_callbackdisplay_conditiondesign);
                        %conn_menu('nullstr',{'No functional','data selected'});
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup',boffset+[.20,.20,.25,.05],'',{'<HTML><i> - functional tools:</i></HTML>','Slice viewer','Slice viewer with anatomical overlay','Slice viewer with MNI boundaries (QA_NORM)','Display functional/anatomical coregistration (SPM)','Display functional/MNI coregistration (SPM)','Display single-slice for all subjects (montage)','Display single-slice for all timepoints (movie)', 'Apply individual preprocessing step','Move dataset-N to dataset-0','Reassign all functional files simultaneously'},'<HTML> - <i>slice viewer</i> displays functional dataset slices<br/> - <i>slice viewer with anatomical overlay</i>displays mean functional overlaid with same-subject structural volume<br/> - <i>slice viewer with MNI boundaries</i> displays mean functional volume slices overlaid with 25% boundaries of grey matter tissue probability map in MNI space<br/> - <i>display registration</i> checks the coregistration of the selected subject functional/anatomical files <br/> - <i>preprocessing</i> runs individual preprocessing step on functional volumes (e.g. realignment, slice-timing correction, etc.)<br/> - <i>display single-slice for all subjects</i> creates a summary display showing the same slice across all subjects (slice coordinates in world-space)<br/> - <i>move dataset-N to dataset-0</i> reassigns dataset-0 functional volumes to match the current dataset of functional volumes defined in dataset-N<br/> - <i>reassign all functional files simultaneously</i> reassigns dataset-0 functional volumes using a user-generated search/replace filename rule</HTML>','conn(''gui_setup'',14);');
                        nset=1;
                        newdelete={'<HTML><i>new</i></HTML>','<HTML><i>delete</i></HTML>'}; if numel(CONN_x.Setup.roifunctional)==1, newdelete=newdelete(1); end
                        CONN_h.menus.m_setup_00{7}=conn_menu('popupblue',boffset+[.56,.12,.129,.04],'',[arrayfun(@(n)sprintf('(dataset %d)',n),1:numel(CONN_x.Setup.roifunctional),'uni',0),newdelete],'<HTML>Edit/add secondary datasets</HTML>','conn(''gui_setup'',7);');
                        analysistypes={'Same files','Other: same filenames without leading ''s'' (SPM convention for unsmoothed volumes)','Other: manually define other filename conventions','Other: manually defined dataset of functional files'};
                        if CONN_x.Setup.roifunctional(nset).roiextract<=3, analysistypes=analysistypes(1:3); end
                        CONN_h.menus.m_setup_00{6}=conn_menu('popup',boffset+[.20,.04,.48,.05],'',analysistypes,'<HTML>Define contents of secondary dataset:<br/> - Select <i>same files</i> to define a new dataset with the same files as those in <i>dataset 0</i> above<br/> - Select <i>other</i> to define a new dataset with different files from those in <i>dataset 0</i> (e.g. from intermediate or alternative preprocessing pipelines; <br/>note: secondary datasets may be further associated with individual ROIs, see <i>Setup.ROIs</i> tab)</HTML>','conn(''gui_setup'',6);');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','pushbutton','units','norm','position',boffset+[.37,.20,.15,.04],'string','Check registration','tooltipstring','Check coregistration of functional and structural files for selected subject(s)/session(s)','callback','conn(''gui_setup'',14);','fontsize',8+CONN_gui.font_offset);
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','popupmenu','units','norm','position',boffset+[.37,.16,.15,.04],'string',{'<HTML><i> - options:</i></HTML>','check registration','preprocessing steps'},'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'fontsize',8+CONN_gui.font_offset,'callback','conn(''gui_setup'',14);','tooltipstring','Functional volumes additional options');
						%CONN_h.menus.m_setup_00{11}=conn_menu('checkbox',boffset+[.38,.205,.02,.04],'spatially-normalized images','','','conn(''gui_setup'',11);');
						set(CONN_h.menus.m_setup_00{3}.files,'max',2);
						set(CONN_h.menus.m_setup_00{1},'max',2);
						set(CONN_h.menus.m_setup_00{1},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')]);
                        nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')),'max',2);
                        %if ~isfield(CONN_x.Setup,'normalized'), CONN_x.Setup.normalized=1; end
						set(CONN_h.menus.m_setup_00{6},'value',CONN_x.Setup.roifunctional(nset).roiextract);
                        %hc1=uicontextmenu;uimenu(hc1,'Label','go to source folder','callback','conn(''gui_setup'',4);');set(CONN_h.menus.m_setup_00{4},'uicontextmenu',hc1);
                        %set([CONN_h.menus.m_setup_00{11}],'visible','on','foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'value',CONN_x.Setup.normalized);
                    else
                        switch(varargin{2}),
                            case 1, value=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
                                set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')));
                                %nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value)); 
                                %set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')));
                            case 2,
                            case 3,
								set(CONN_h.screen.hfig,'pointer','watch');
                                nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                                nsessall=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                                nfields=sum(sum(conn_bsxfun(@le,nsessall(:),nsessmax(:)')));
								filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                                txt=''; bak1=CONN_x.Setup.functional;bak2=CONN_x.Setup.nscans;
                                localcopy=isequal(get(CONN_h.menus.m_setup_00{3}.localcopy,'value'),2);
								if size(filename,1)==nfields, 
                                    firstallsubjects=false;
                                    if numel(nsessall)>1&&numel(nsubs)>1
                                        opts={sprintf('First all subjects for session %d, followed by all subjects for session %d, etc.',nsessall(1),nsessall(2)),...
                                         sprintf('First all sessions for subject %d, followed by all sessions for subject %d, etc.',nsubs(1),nsubs(2))};
                                        answ=conn_questdlg('',sprintf('Order of files (%d files, %d subjects, %d sessions)',size(filename,1),numel(nsubs),numel(nsessall)),opts{[1,2,2]});
                                        if isempty(answ), return; end
                                        firstallsubjects=strcmp(answ,opts{1});
                                    end
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    n0=0;
                                    if firstallsubjects
                                        for nses=nsessall,
                                            for n1=1:length(nsubs),
                                                if nses<=nsessmax(n1)
                                                    nsub=nsubs(n1);
                                                    n0=n0+1;
                                                    if localcopy, [nill,nill,V]=conn_importvol2bids(deblank(filename(n0,:)),nsub,nses,'func');
                                                    else [CONN_x.Setup.functional{nsub}{nses},V]=conn_file(deblank(filename(n0,:)));
                                                    end
                                                    CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
                                                end
                                            end
                                        end
                                    else
                                        for n1=1:length(nsubs),
                                            nsub=nsubs(n1);
                                            for nses=intersect(nsessall,1:nsessmax(n1))
                                                n0=n0+1;
                                                if localcopy, [nill,nill,V]=conn_importvol2bids(deblank(filename(n0,:)),nsub,nses,'func');
                                                else [CONN_x.Setup.functional{nsub}{nses},V]=conn_file(deblank(filename(n0,:)));
                                                end
                                                CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
                                            end
                                        end
                                    end
                                    txt=sprintf('%d files assigned to %d subjects/sessions\n',size(filename,1),nfields);
                                    if ishandle(hmsg), delete(hmsg); end
								elseif nfields==1,
                                    hmsg=conn_msgbox('Loading files... please wait','');
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        for nses=intersect(nsessall,1:nsessmax(n1))
                                            if localcopy, [nill,nill,V]=conn_importvol2bids(deblank(filename),nsub,nses,'func');
                                            else [CONN_x.Setup.functional{nsub}{nses},V]=conn_file(deblank(filename));
                                            end
                                            CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
                                        end
                                    end
                                    txt=sprintf('%d files assigned to %d subjects/sessions\n',size(filename,1),nfields);
                                    if ishandle(hmsg), delete(hmsg); end
								else 
									conn_msgbox(sprintf('mismatched number of files (%d files; %d subjects/sessions)',size(filename,1),nfields),'',2);
                                end
                                if ~isempty(txt)&&strcmp(conn_questdlg(txt,'','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.functional=bak1; CONN_x.Setup.nscans=bak2; end
								set(CONN_h.screen.hfig,'pointer','arrow');
                            case 4,
                                nsubs=get(CONN_h.menus.m_setup_00{1},'value');nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                if ~isempty(CONN_x.Setup.functional{nsubs(1)}{nsess(1)}{1})
                                    tempstr=cellstr(CONN_x.Setup.functional{nsubs(1)}{nsess(1)}{1});
                                    [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                                    tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                                    set(CONN_h.menus.m_setup_00{3}.selectfile,'string',unique(tempstr_name));
                                    set(CONN_h.menus.m_setup_00{3}.folder,'string',fileparts(tempstr{1}));
                                    conn_filesearchtool(CONN_h.menus.m_setup_00{3}.folder,[],'folder',true);
                                end
                            case 6,
                                nset=get(CONN_h.menus.m_setup_00{7},'value');
                                roiextract=get(CONN_h.menus.m_setup_00{6},'value');
                                if roiextract==3, 
                                    nsubs=get(CONN_h.menus.m_setup_00{1},'value');nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                    filename=CONN_x.Setup.functional{nsubs(1)}{nsess(1)}{1};
                                    rule=conn_rulebasedfilename(filename,0,CONN_x.Setup.roifunctional(nset).roiextract_rule,CONN_x.Setup.functional);
                                    if ~isequal(rule,0)
                                        CONN_x.Setup.roifunctional(nset).roiextract=roiextract;
                                        CONN_x.Setup.roifunctional(nset).roiextract_rule=rule;
                                    end
                                else
                                    CONN_x.Setup.roifunctional(nset).roiextract=roiextract;
                                end
                            case 7,
                                nset=get(CONN_h.menus.m_setup_00{7},'value');
                                if nset==numel(CONN_x.Setup.roifunctional)+1, %add
                                    CONN_x.Setup.roifunctional(nset)=CONN_x.Setup.roifunctional(nset-1);
                                elseif nset==numel(CONN_x.Setup.roifunctional)+2, %remove
                                    str=arrayfun(@(n)sprintf('dataset %d',n),1:numel(CONN_x.Setup.roifunctional),'uni',0);
                                    nset=listdlg('name',['Removing set'],'PromptString','Select set(s) to remove','ListString',str,'SelectionMode','multiple','ListSize',[200 200]);
                                    if ~isempty(nset)
                                        if numel(nset)==numel(CONN_x.Setup.roifunctional), conn_msgbox({'At least one set must remain',' ','Set deletion canceled'},'',2);
                                        else CONN_x.Setup.roifunctional=CONN_x.Setup.roifunctional(setdiff(1:numel(CONN_x.Setup.roifunctional),nset));
                                        end
                                    end
                                    nset=1;
                                end
                                newdelete={'<HTML><i>new</i></HTML>','<HTML><i>delete</i></HTML>'}; if numel(CONN_x.Setup.roifunctional)==1, newdelete=newdelete(1); end
                                set(CONN_h.menus.m_setup_00{7},'string',[arrayfun(@(n)sprintf('(dataset %d)',n),1:numel(CONN_x.Setup.roifunctional),'uni',0),newdelete],'value',nset);
                            case 14,
                                if numel(varargin)>=3, val=varargin{3};
                                else val=get(CONN_h.menus.m_setup_00{14},'value');
                                end
                                fh=[];
                                switch(val)
                                    case {2,3,4}, % slice viewer
                                        if numel(varargin)>=4, nsubs=varargin{4};
                                        else nsubs=get(CONN_h.menus.m_setup_00{1},'value'); set(CONN_h.menus.m_setup_00{14},'value',1);
                                        end
                                        if numel(varargin)>=5, nsess=varargin{5};
                                        else nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                        end
                                        if numel(varargin)>=6, nsets=varargin{6};
                                        else
                                            nsets=listdlg('liststring',arrayfun(@(n)sprintf('dataset %d',n),0:numel(CONN_x.Setup.roifunctional),'uni',0),'selectionmode','single','initialvalue',1,'promptstring',{'Select functional dataset for display'},'ListSize',[300 200]);
                                            if isempty(nsets), return; end
                                            nsets=nsets-1;
                                        end
                                        if ~CONN_x.Setup.structural_sessionspecific, nsesstemp=1; 
                                        else nsesstemp=nsess;
                                        end
                                        fhset={};
                                        for nset=nsets
                                            Vsource=CONN_x.Setup.functional{nsubs}{nsess}{1};
                                            if nset
                                                try
                                                    if CONN_x.Setup.roifunctional(nset).roiextract==4
                                                        VsourceUnsmoothed=cellstr(CONN_x.Setup.roifunctional(nset).roiextract_functional{nsubs}{nsess}{1});
                                                    else
                                                        Vsource1=cellstr(Vsource);
                                                        VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roifunctional(nset).roiextract,CONN_x.Setup.roifunctional(nset).roiextract_rule);
                                                    end
                                                    existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                    if ~all(existunsmoothed),
                                                        fprintf('warning: set-%d data for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nset,nsubs,nsess);
                                                    else
                                                        Vsource=char(VsourceUnsmoothed);
                                                    end
                                                catch
                                                    fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nsubs,nsess);
                                                end
                                            end
                                            temp=cellstr(Vsource);
                                            if isempty(temp), conn_msgbox(sprintf('Functional data not defined for subject %d session %d',nsubs,nsess),'Error',2); return; end
                                            [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                            if ~isempty(xtemp), temp1=xtemp;
                                            else
                                                if numel(temp)==1,
                                                    temp1=cellstr(conn_expandframe(temp{1}));
                                                    temp1=temp1{1};
                                                else temp1=temp{1};
                                                end
                                            end
                                            if ~isempty(temp)&&~isempty(temp1)
                                                if val==2, fh=conn_slice_display([],char(temp),[],[],sprintf('dataset %d',nset));
                                                elseif val==3, fh=conn_slice_display(temp1,CONN_x.Setup.structural{nsubs(1)}{nsesstemp(1)}{1},[],[],sprintf('dataset %d',nset));
                                                    fh('colormap','jet'); fh('act_transparency',.5);fh('black_transparency','off');
                                                else fh=conn_slice_display(fullfile(fileparts(which(mfilename)),'utils','surf','referenceGM.nii'),temp1,[],.25,sprintf('dataset %d',nset));
                                                    fh('colormap',.85*[1 1 0;1 1 0]);fh('contour_transparency',1);fh('act_transparency',0);fh('background',[0 0 0]);
                                                end
                                                fhset=[fhset {fh}];
                                            end
                                        end
                                        varargout={fhset};
                                        return;
                                    case {5,6}, % check coregistration
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nsubs=get(CONN_h.menus.m_setup_00{1},'value');nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                        if val==5, files={};filenames={};
                                        else
                                            functional_template=fullfile(fileparts(which('spm')),'templates','EPI.nii');
                                            if isempty(dir(functional_template)), functional_template=fullfile(fileparts(which('spm')),'toolbox','OldNorm','EPI.nii'); end
                                            files={spm_vol(functional_template)}; filenames={functional_template};
                                        end
                                        for nsub=nsubs(:)',
%                                             try
                                                for nses=nsess(:)',
                                                    if val==5
                                                        if CONN_x.Setup.structural_sessionspecific,
                                                            files{end+1}=CONN_x.Setup.structural{nsub}{nses}{3}(1);
                                                            filenames{end+1}=CONN_x.Setup.structural{nsub}{nses}{1};
                                                        else
                                                            files{end+1}=CONN_x.Setup.structural{nsub}{1}{3}(1);
                                                            filenames{end+1}=CONN_x.Setup.structural{nsub}{1}{1};
                                                        end
                                                    end
                                                    for nset=0:numel(CONN_x.Setup.roifunctional)
                                                        Vsource=CONN_x.Setup.functional{nsub}{nses}{1};
                                                        if nset
                                                            try
                                                                if CONN_x.Setup.roifunctional(nset).roiextract==4
                                                                    VsourceUnsmoothed=cellstr(CONN_x.Setup.roifunctional(nset).roiextract_functional{nsub}{nses}{1});
                                                                else
                                                                    Vsource1=cellstr(Vsource);
                                                                    VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roifunctional(nset).roiextract,CONN_x.Setup.roifunctional(nset).roiextract_rule);
                                                                end
                                                                existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                                if ~all(existunsmoothed),
                                                                    fprintf('warning: set-%d data for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nset,nsub,nses);
                                                                else
                                                                    Vsource=char(VsourceUnsmoothed);
                                                                end
                                                            catch
                                                                fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nsub,nses);
                                                            end
                                                        end
                                                        temp=cellstr(Vsource);
                                                        if numel(temp)==1,
                                                            temp=cellstr(conn_expandframe(temp{1}));
                                                        end
                                                        files{end+1}=spm_vol(temp{1});
                                                        filenames{end+1}=temp{1};
                                                    end
                                                end
%                                             catch
%                                                 error('No functional data entered for subject %d session %d',nsub,nses);
%                                             end
                                        end
                                        [nill,idx]=unique(filenames);
                                        spm_check_registration([files{sort(idx)}]);
                                        return;
                                    case 7, % single slice display
                                        if numel(varargin)>=4, nsubs=varargin{4};
                                        else nsubs=1:CONN_x.Setup.nsubjects; 
                                            set(CONN_h.menus.m_setup_00{14},'value',1);
                                        end
                                        if numel(varargin)>=5, txyz=varargin{5}; dim=[1 1];
                                        else
                                            set(CONN_h.menus.m_setup_00{14},'value',1);
                                            data=get(CONN_h.menus.m_setup_00{5}.h2,'userdata');
                                            dim=data.buttondown.matdim.dim(1:2);
                                            zslice=data.n;
                                            [tx,ty]=ndgrid(1:dim(1),1:dim(2));
                                            txyz=data.buttondown.matdim.mat*[tx(:) ty(:) zslice+zeros(numel(tx),1) ones(numel(tx),1)]';
                                        end
                                        if numel(varargin)>=6, nsets=varargin{6};
                                        else nsets=0;
                                            nsets=listdlg('liststring',arrayfun(@(n)sprintf('dataset %d',n),0:numel(CONN_x.Setup.roifunctional),'uni',0),'selectionmode','single','initialvalue',1,'promptstring',{'Select functional dataset for display'},'ListSize',[300 200]);
                                            if isempty(nsets), return; end
                                            nsets=nsets-1;
                                        end
                                        dispdata={};displabel={};
                                        hmsg=conn_msgbox('Loading data... please wait','');
                                        for nsub=nsubs(:)'
                                            for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub))
                                                Vsource=CONN_x.Setup.functional{nsub}{nses}{1};
                                                if isempty(Vsource), 
                                                    fprintf('Subject %d session %d data not found\n',nsub,nses);
                                                    dispdata{end+1}=nan(dim([2 1]));
                                                    displabel{end+1}=sprintf('Subject %d session %d',nsub,nses);
                                                else
                                                    for nset=nsets(:)'
                                                        if nset
                                                            try
                                                                if CONN_x.Setup.roifunctional(nset).roiextract==4
                                                                    VsourceUnsmoothed=cellstr(CONN_x.Setup.roifunctional(nset).roiextract_functional{nsub}{nses}{1});
                                                                else
                                                                    Vsource1=cellstr(Vsource);
                                                                    VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roifunctional(nset).roiextract,CONN_x.Setup.roifunctional(nset).roiextract_rule);
                                                                end
                                                                existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                                if ~all(existunsmoothed),
                                                                    fprintf('warning: set-%d data for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nset,nsub,nses);
                                                                else
                                                                    Vsource=char(VsourceUnsmoothed);
                                                                end
                                                            catch
                                                                fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nsub,nses);
                                                            end
                                                        end
                                                        temp=cellstr(Vsource);
                                                        if numel(temp)==1,
                                                            temp=cellstr(conn_expandframe(temp{1}));
                                                        end
                                                        nvols=unique([1 numel(temp)]);
                                                        for nvol=nvols(:)'
                                                            files=spm_vol(temp{nvol});
                                                            if numel(txyz)<=1
                                                                dim=files(1).dim(1:2);
                                                                [tx,ty]=ndgrid(1:dim(1),1:dim(2));
                                                                if numel(txyz)==1, zslice=txyz;
                                                                else zslice=round(files(1).dim(3)/2);
                                                                end
                                                                txyz=files(1).mat*[tx(:) ty(:) zslice+zeros(numel(tx),1) ones(numel(tx),1)]';
                                                            end
                                                            dispdata{end+1}=fliplr(flipud(reshape(spm_get_data(files,pinv(files.mat)*txyz),dim(1:2))'));
                                                            displabel{end+1}=sprintf('Subject %d session %d volume %d dataset %d',nsub,nses,nvol,nset);
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        fh=conn_montage_display(cat(4,dispdata{:}),displabel);
                                        fh('colormap','gray'); fh('colormap','darker');
                                        if ishandle(hmsg), delete(hmsg); end
                                        varargout={fh};
                                        return;
                                    case 8, % single-slice all timepoints
                                        if numel(varargin)>=4, nsubs=varargin{4};
                                        else nsubs=get(CONN_h.menus.m_setup_00{1},'value'); 
                                            set(CONN_h.menus.m_setup_00{14},'value',1);
                                        end
                                        if numel(varargin)>=5, nsess=varargin{5};
                                        else nsess=get(CONN_h.menus.m_setup_00{2},'value'); 
                                        end
                                        if isempty(nsess), nsess=1:max(CONN_x.Setup.nsessions); end
                                        if numel(varargin)>=6, txyz=varargin{6}; dim=[1 1];
                                        else
                                            set(CONN_h.menus.m_setup_00{14},'value',1);
                                            data=get(CONN_h.menus.m_setup_00{5}.h2,'userdata');
                                            dim=data.buttondown.matdim.dim(1:2);
                                            zslice=data.n;
                                            [tx,ty]=ndgrid(1:dim(1),1:dim(2));
                                            txyz=data.buttondown.matdim.mat*[tx(:) ty(:) zslice+zeros(numel(tx),1) ones(numel(tx),1)]';
                                        end
                                        if numel(varargin)>=7, nsets=varargin{7};
                                        else nsets=0;
                                            nsets=listdlg('liststring',arrayfun(@(n)sprintf('dataset %d',n),0:numel(CONN_x.Setup.roifunctional),'uni',0),'selectionmode','single','initialvalue',1,'promptstring',{'Select functional dataset for display'},'ListSize',[300 200]);
                                            if isempty(nsets), return; end
                                            nsets=nsets-1;
                                        end
                                        if numel(varargin)>=8, autoplay=varargin{8};
                                        else autoplay=true;
                                        end
                                        dispdata={};displabel={};
                                        hmsg=conn_msgbox('Loading data... please wait','');
                                        for nsub=nsubs(:)'
                                            for nses=reshape(intersect(nsess,1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub))),1,[])
                                                Vsource=CONN_x.Setup.functional{nsub}{nses}{1};
                                                if isempty(Vsource), 
                                                    fprintf('Subject %d session %d data not found\n',nsub,nses);
                                                    dispdata{end+1}=nan(dim([2 1]));
                                                    displabel{end+1}=sprintf('Subject %d session %d',nsub,nses);
                                                else
                                                    for nset=nsets(:)'
                                                        if nset
                                                            try
                                                                if CONN_x.Setup.roifunctional(nset).roiextract==4
                                                                    VsourceUnsmoothed=cellstr(CONN_x.Setup.roifunctional(nset).roiextract_functional{nsub}{nses}{1});
                                                                else
                                                                    Vsource1=cellstr(Vsource);
                                                                    VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roifunctional(nset).roiextract,CONN_x.Setup.roifunctional(nset).roiextract_rule);
                                                                end
                                                                existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                                if ~all(existunsmoothed),
                                                                    fprintf('warning: set-%d data for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nset,nsub,nses);
                                                                else
                                                                    Vsource=char(VsourceUnsmoothed);
                                                                end
                                                            catch
                                                                fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nsub,nses);
                                                            end
                                                        end
                                                        files=spm_vol(Vsource);
                                                        for nvol=1:numel(files)
                                                            if numel(txyz)<=1
                                                                dim=files(1).dim(1:2);
                                                                [tx,ty]=ndgrid(1:dim(1),1:dim(2));
                                                                if numel(txyz)==1, zslice=txyz;
                                                                else zslice=round(files(1).dim(3)/2);
                                                                end
                                                                txyz=files(1).mat*[tx(:) ty(:) zslice+zeros(numel(tx),1) ones(numel(tx),1)]';
                                                            end
                                                            dispdata{end+1}=fliplr(flipud(reshape(spm_get_data(files(nvol),pinv(files(nvol).mat)*txyz),dim(1:2))'));
                                                            displabel{end+1}=sprintf('Subject %d session %d volume %d dataset %d',nsub,nses,nvol,nset);
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        fh=conn_montage_display(cat(4,dispdata{:}),displabel,'movie');
                                        fh('colormap','gray'); fh('colormap','darker');
                                        if ishandle(hmsg), delete(hmsg); end
                                        if autoplay, fh('start');
                                        else fh('style','moviereplay');
                                        end
                                        varargout={fh};
                                        return;
                                    case 9, % apply individual preprocessing step
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        conn('gui_setup_preproc','select','functional');
                                        return;
                                    case 10, % move set-N to set-0
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nalt=listdlg('liststring',arrayfun(@(n)sprintf('dataset %d',n),1:numel(CONN_x.Setup.roifunctional),'uni',0),'selectionmode','single','initialvalue',1,'promptstring',{'Select set number:','(set-0 functional data will be reassigned to the current','functional volumes specified in the selected set)'},'ListSize',[300 200]);
                                        if isempty(nalt), return; end
                                        hmsg=conn_msgbox('Loading files... please wait','');
                                        err=false;
                                        bak1=CONN_x.Setup.functional; bak2=CONN_x.Setup.nscans;
                                        for nsub=1:CONN_x.Setup.nsubjects
                                            for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub))
                                                Vsource=CONN_x.Setup.functional{nsub}{nses}{1};
                                                if CONN_x.Setup.roifunctional(nalt).roiextract==4
                                                    VsourceUnsmoothed=cellstr(CONN_x.Setup.roifunctional(nalt).roiextract_functional{nsub}{nses}{1});
                                                else
                                                    Vsource1=cellstr(Vsource);
                                                    VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roifunctional(nalt).roiextract,CONN_x.Setup.roifunctional(nalt).roiextract_rule);
                                                end
                                                existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                if ~all(existunsmoothed),
                                                    fprintf('warning: set-%d data for subject %d session %d not found.\n',nalt,nsub,nses);
                                                    err=true; 
                                                    break;
                                                else
                                                    [CONN_x.Setup.functional{nsub}{nses},V]=conn_file(char(VsourceUnsmoothed));
                                                    CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
                                                end
                                            end
                                            if err, break; end
                                        end
                                        if ishandle(hmsg), delete(hmsg); end
                                        if err||strcmp(conn_questdlg('Set-0 functional volumes successfully reassigned','','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.functional=bak1; CONN_x.Setup.nscans=bak2; end
                                        if err, conn_msgbox({sprintf('Error: set-%d data for subject %d session %d not found.\n',nalt,nsub,nses),'Operation canceled'},'',2); end
                                    case 11,
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        conn_rulebasedfilename functional;
                                    otherwise
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        return;
                                end
%                             case 11,
%                                 normalized=get(CONN_h.menus.m_setup_00{11},'value');
%                                 if ~normalized, warndlg('Warning: Second-level voxel-level analyses not available for un-normalized data'); end
%                                 CONN_x.Setup.normalized=normalized;
                        end
                    end
                    nset=get(CONN_h.menus.m_setup_00{7},'value');
                    set(CONN_h.menus.m_setup_00{6},'value',CONN_x.Setup.roifunctional(nset).roiextract);
                    nsubs=get(CONN_h.menus.m_setup_00{1},'value');nsess=get(CONN_h.menus.m_setup_00{2},'value');
                    for nsub=1:CONN_x.Setup.nsubjects
                        if length(CONN_x.Setup.functional)<nsub, CONN_x.Setup.functional{nsub}={}; end
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            if length(CONN_x.Setup.functional{nsub})<nses, CONN_x.Setup.functional{nsub}{nses}={}; end
                            if length(CONN_x.Setup.functional{nsub}{nses})<3, CONN_x.Setup.functional{nsub}{nses}{3}=[]; end
                        end
					end
					ok=1; ko=[];
                    for nsub=nsubs(:)'
                        for nses=intersect(1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub)),nsess(:)')
                            if isempty(ko), ko=CONN_x.Setup.functional{nsub}{nses}{1};
                            else  if ~all(size(ko)==size(CONN_x.Setup.functional{nsub}{nses}{1})) || ~all(all(ko==CONN_x.Setup.functional{nsub}{nses}{1})), ok=0; end; end
                        end
                    end
                    if isempty(nses)||isempty(nsubs)||numel(CONN_x.Setup.functional{nsub})<nses||isempty(CONN_x.Setup.functional{nsub}{nses}{1})
                        conn_menu('updateimage',CONN_h.menus.m_setup_00{5},[]);
                        conn_menu('updateimage',CONN_h.menus.m_setup_00{8},[]);
                        set(CONN_h.menus.m_setup_00{4},'string','','tooltipstring','');
                        set(CONN_h.menus.m_setup_00{14},'visible','off'); 
                        CONN_h.menus.m_setup.functional=[];
                        CONN_h.menus.m_setup.functional_vol=[];
                    elseif ok
                        conn_menu('updateimage',CONN_h.menus.m_setup_00{5},CONN_x.Setup.functional{nsub}{nses}{3});
                        conn_menu('updateimage',CONN_h.menus.m_setup_00{8},[]);
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
                        tempstr=cellstr(CONN_x.Setup.functional{nsub}{nses}{1});
                        if numel(tempstr)>1, tempstr=tempstr([1 end]); end
                        set(CONN_h.menus.m_setup_00{4},'string',conn_cell2html(CONN_x.Setup.functional{nsub}{nses}{2}),'tooltipstring',conn_cell2html(tempstr));
                        CONN_h.menus.m_setup.functional=CONN_x.Setup.functional{nsub}{nses};
                        CONN_h.menus.m_setup.functional_vol=[];
                    else
                        conn_menu('updateimage',CONN_h.menus.m_setup_00{5},[]);
                        conn_menu('updateimage',CONN_h.menus.m_setup_00{8},[]);
                        set(CONN_h.menus.m_setup_00{4},'string','Multiple files','tooltipstring','');
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
                        CONN_h.menus.m_setup.functional=[];
                        CONN_h.menus.m_setup.functional_vol=[];
                    end
					ok=1; ko=[];
                    for nsub=1:CONN_x.Setup.nsubjects
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            if isempty(CONN_x.Setup.functional{nsub}{nses}{1}), ok=0; ko=[nsub nses]; break; end
                        end
                        if ~ok, break; end
                    end
                    conn_menumanager('helpstring','');
                    if ~ok, conn_menumanager('helpstring',sprintf('WARNING: incomplete information (enter functional file(s) for subject %d session %d)',ko(1),ko(2))); end
                    try
                        maxn=0;
                        for nsub=1:CONN_x.Setup.nsubjects
                            n=0;
                            for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                                if numel(CONN_x.Setup.nscans)>=nsub&&numel(CONN_x.Setup.nscans{nsub})>=nses&&~isempty(CONN_x.Setup.nscans{nsub}{nses}), n=n+CONN_x.Setup.nscans{nsub}{nses}; end
                            end
                            maxn=max(n,maxn);
                        end
                        %x=[];xlscn=[];xlses=[];xlsub=[];xlcon=[];xlval=[];
                        x=nan(maxn,0);xlscn=x;xlses=x;xlsub=x;xlcon=x;xlval=x;
                        for nsub=nsubs(:)',
                            tx=[];txlscn=[];txlses=[];txlsub=[];txlcon=[];txlval=[];
                            for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                    if numel(CONN_x.Setup.nscans)>=nsub&&numel(CONN_x.Setup.nscans{nsub})>=nses&&~isempty(CONN_x.Setup.nscans{nsub}{nses}),
                                        temp=1-exp(-(0:CONN_x.Setup.nscans{nsub}{nses}-1)');
                                    else temp=nan(100,1);
                                    end
                                    %temp=repmat(temp,1,1+CONN_x.Setup.nsubjects/numel(nsubs)*ismember(nsub,nsubs));
                                    temp2=conn_bsxfun(@rdivide,temp,max(1e-4,max(abs(temp))));
                                    tx=[tx; 129*(ismember(nses,nsess)&ismember(nsub,nsubs))+64*temp2];
                                    txlscn=[txlscn; repmat(size(temp,1),size(temp,1),size(temp,2))];
                                    txlses=[txlses; repmat(nses,size(temp))];
                                    txlsub=[txlsub; repmat(nsub,size(temp))];
                                    %txlcon=[txlcon; repmat(ncondition,size(temp))];
                                    txlval=[txlval; temp];
                                end
                            end
                            xlscn=[[xlscn; nan(max(0,size(tx,1)-size(x,1)),size(xlscn,2))] [txlscn; nan(max(0,size(x,1)-size(tx,1)),1)]];
                            xlses=[[xlses; nan(max(0,size(tx,1)-size(x,1)),size(xlses,2))] [txlses; nan(max(0,size(x,1)-size(tx,1)),1)]];
                            xlsub=[[xlsub; nan(max(0,size(tx,1)-size(x,1)),size(xlsub,2))] [txlsub; nan(max(0,size(x,1)-size(tx,1)),1)]];
                            %xlcon=[[xlcon; nan(max(0,size(tx,1)-size(x,1)),size(x,2))] [txlcon; nan(max(0,size(x,1)-size(tx,1)),1)]];
                            xlval=[[xlval; nan(max(0,size(tx,1)-size(x,1)),size(xlval,2))] [txlval; nan(max(0,size(x,1)-size(tx,1)),1)]];
                            x=[[x; nan(max(0,size(tx,1)-size(x,1)),size(x,2))] [tx; nan(max(0,size(x,1)-size(tx,1)),1)]];
                        end
                        x(isnan(x))=0;
                        conn_menu('updatematrix',CONN_h.menus.m_setup_00{12},ind2rgb(max(1,min(256,round(x)')),[gray(128);hot(128)]));
                        CONN_h.menus.m_setup_11e={xlscn xlses xlsub xlcon xlval};
                    catch
                       conn_menu('updatematrix',CONN_h.menus.m_setup_00{12},[]);
                       CONN_h.menus.m_setup_11e={};
                    end
                case 2, %structural
                    boffset=[.05 .06 0 -.01];
                    if nargin<2,
                        conn_menu('frame',boffset+[.19,.15,.41,.57],'Structural data');
                        conn_menu('nullstr',{'No structural','data selected'});
						CONN_h.menus.m_setup_00{13}=conn_menu('popup',boffset+[.200,.63,.15,.05],'',{'Session-invariant structurals','Session-specific structurals'},'<HTML>(only applies to experiments with multiple sessions/runs) <br/> - Select session-invariant if the structural data does not change across sessions (enter one structural volume per subject) <br/> - Select session-specific if the structural data may change across sessions (enter one structural volume per session; e.g. longitudinal studies)</HTML>','conn(''gui_setup'',13);');
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.25,.075,.33],'Subjects','','Select subject(s)','conn(''gui_setup'',1);');
						[CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{15}]=conn_menu('listbox',boffset+[.275,.25,.075,.33],'Sessions','','Select session','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('filesearchlocal',[],'Select structural data files','*.img; *.nii; *.mgh; *.mgz; *.gz; *-1.dcm','',{@conn,'gui_setup',3},'conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{4}=conn_menu('pushbutton', boffset+[.35,.57,.24,.10],'','','','conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.37,.26,.20,.31]);
                        CONN_h.menus.m_setup_00{6}=conn_menu('popup',boffset+[.41,.21,.18,.045],'',{'Display structural volume','Display structural surface'},'select display view (surface view only available for freesurfer-generated files)','conn(''gui_setup'',6);');
                        set([CONN_h.menus.m_setup_00{6}],'visible','off'); conn_menumanager('onregion',[CONN_h.menus.m_setup_00{6}],1,boffset+[.35,.18,.28,.70]);
                        ht=uicontrol('style','frame','units','norm','position',boffset+[.35,.56,.24,.10],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA);
                        set(ht,'visible','on'); conn_menumanager('onregion',ht,-1,boffset+[.35,.20,.28,.70]);
                        %ht=uicontrol('style','frame','units','norm','position',[.78,.06,.20,.84],'foregroundcolor',CONN_gui.backgroundcolor,'backgroundcolor',CONN_gui.backgroundcolor);
                        %set(ht,'visible','on'); conn_menumanager('onregion',ht,-1,boffset+[.19,0,.81,1]);
                        %CONN_h.menus.m_setup_00{6}=uicontrol('style','popupmenu','units','norm','position',boffset+[.31,.20,.13,.04],'string',{'Structural volume','Structural surface'},'value',2,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor','w','fontsize',8+CONN_gui.font_offset,'callback','conn(''gui_setup'',6);','tooltipstring','select display view (surface view only available for freesurfer-generated files)');
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup',boffset+[.20,.15,.25,.05],'',{'<HTML><i> - structural tools:</i></HTML>','Slice viewer','Slice viewer with MNI boundaries (QA_NORM)','Display anatomical/MNI coregistration (SPM)','Display single-slice for all subjects (montage)','Apply individual preprocessing step','Reassign all structural files simultaneously'},'<HTML> - <i>slice viewer</i> displays strucutral volume slices <br/> - <i>slice viewer with MNI boundaries</i> displays strucutral volume slices overlaid with 25% boundaries of grey matter tissue probability map in MNI space<br/> - <i>display registration</i> checks the coregistration between the selected subject anatomical files and an MNI T1 template<br/> - <i>preprocessing</i> runs individual preprocessing step on structural volumes (e.g. normalization, segmentation, etc.)<br/> - <i>display single-slice for all subjects</i> creates a summary display showing the same slice across all subjects (slice coordinates in world-space)<br/> - <i>reassign all structural files simultaneously</i> reassigns structural volumes using a user-generated search/replace filename rule</HTML>','conn(''gui_setup'',14);');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','popupmenu','units','norm','position',boffset+[.31,.15,.13,.04],'string',{'<HTML><i> - options:</i></HTML>','preprocessing steps'},'fontsize',8+CONN_gui.font_offset,'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'callback','conn(''gui_setup'',14);','tooltipstring','Structural volumes additional options');
						%CONN_h.menus.m_setup_00{11}=conn_menu('checkbox',[.31,.205,.02,.04],'spatially-normalized images','','','conn(''gui_setup'',11);');
						set(CONN_h.menus.m_setup_00{1},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2);
						set(CONN_h.menus.m_setup_00{3}.files,'max',2);
                        nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')),'max',2);
                        set(CONN_h.menus.m_setup_00{13},'value', 1+CONN_x.Setup.structural_sessionspecific);
                        if all(CONN_x.Setup.nsessions==1), set(CONN_h.menus.m_setup_00{13},'foregroundcolor',[.5 .5 .5]); end
                        %if all(CONN_x.Setup.nsessions==1), set(CONN_h.menus.m_setup_00{13},'visible','off'); end
                        %hc1=uicontextmenu;uimenu(hc1,'Label','go to source folder','callback','conn(''gui_setup'',4);');set(CONN_h.menus.m_setup_00{4},'uicontextmenu',hc1);
                        %if ~isfield(CONN_x.Setup,'normalized'), CONN_x.Setup.normalized=1; end
                        %set([CONN_h.menus.m_setup_00{11}],'visible','on','foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'value',CONN_x.Setup.normalized);
						%for nsub=1:CONN_x.Setup.nsubjects, 
						%	if length(CONN_x.Setup.structural)<nsub || isempty(CONN_x.Setup.structural{nsub}), 
						%		conn('gui_setup',3,fullfile(fileparts(which('spm')),'canonical','avg152T1.nii'),nsub); 
						%	end; 
						%end
                    else
                        switch(varargin{2}),
                            case 1, 
                                value=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
                                set(CONN_h.menus.m_setup_00{2},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')));
                            case 3,
                                if nargin<4, nsubs=get(CONN_h.menus.m_setup_00{1},'value'); else  nsubs=varargin{4}; end
                                nsessall=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                                if ~CONN_x.Setup.structural_sessionspecific, nsessall=1:max(nsessmax); end
								filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                                nfields=sum(sum(conn_bsxfun(@le,nsessall(:),nsessmax(:)')));
                                txt=''; bak1=CONN_x.Setup.rois.files;bak2=CONN_x.Setup.structural;
                                localcopy=isequal(get(CONN_h.menus.m_setup_00{3}.localcopy,'value'),2);
								if ~CONN_x.Setup.structural_sessionspecific&&size(filename,1)==numel(nsubs),
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    askimport=[];
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            if localcopy, conn_importvol2bids(deblank(filename(n1,:)),nsub,[1,nses],'anat');
                                            else CONN_x.Setup.structural{nsub}{nses}=conn_file(deblank(filename(n1,:)));
                                            end
                                            if conn_importaseg(fileparts(CONN_x.Setup.structural{nsub}{nses}{1}),[],true)
                                                if isempty(askimport)
                                                    answ=conn_questdlg('Freesurfer aseg.mgz segmentation files found. Do you want to import Grey/White/CSF masks from these files?','','Yes','No','Yes');
                                                    if strcmp(answ,'Yes'), askimport=true;
                                                    else askimport=false;
                                                    end
                                                end
                                                if askimport
                                                    filenames=conn_importaseg(fileparts(CONN_x.Setup.structural{nsub}{nses}{1}));
                                                    for nseg=1:3
                                                        CONN_x.Setup.rois.files{nsub}{nseg}{nses}=conn_file(filenames{nseg});
                                                    end
                                                end
                                            end
                                        end
									end
                                    txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    set(CONN_h.menus.m_setup_00{6},'value',2);
                                    if ishandle(hmsg), delete(hmsg); end
                                elseif CONN_x.Setup.structural_sessionspecific&&size(filename,1)==nfields,
                                    firstallsubjects=false;
                                    if numel(nsessall)>1&&numel(nsubs)>1
                                        opts={sprintf('First all subjects for session %d, followed by all subjects for session %d, etc.',nsessall(1),nsessall(2)),...
                                         sprintf('First all sessions for subject %d, followed by all sessions for subject %d, etc.',nsubs(1),nsubs(2))};
                                        answ=conn_questdlg('',sprintf('Order of files (%d files, %d subjects, %d sessions)',size(filename,1),numel(nsubs),numel(nsessall)),opts{[1,2,2]});
                                        if isempty(answ), return; end
                                        firstallsubjects=strcmp(answ,opts{1});
                                    end
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    askimport=[];
                                    n0=1;
                                    if firstallsubjects
                                        for nses=nsessall(:)',
                                            for n1=1:length(nsubs),
                                                nsub=nsubs(n1);
                                                if nses<=nsessmax(n1)
                                                    if localcopy, conn_importvol2bids(deblank(filename(n1,:)),nsub,nses,'anat');
                                                    else CONN_x.Setup.structural{nsub}{nses}=conn_file(deblank(filename(n0,:)));
                                                    end
                                                    %V=conn_file(deblank(filename(n0,:)));
                                                    if conn_importaseg(fileparts(CONN_x.Setup.structural{nsub}{nses}{1}),[],true)
                                                        if isempty(askimport)
                                                            answ=conn_questdlg('Freesurfer aseg.mgz segmentation files found. Do you want to import Grey/White/CSF masks from these files?','','Yes','No','Yes');
                                                            if strcmp(answ,'Yes'), askimport=true;
                                                            else askimport=false;
                                                            end
                                                        end
                                                        if askimport
                                                            filenames=conn_importaseg(fileparts(CONN_x.Setup.structural{nsub}{nses}{1}));
                                                            for nseg=1:3
                                                                CONN_x.Setup.rois.files{nsub}{nseg}{nses}=conn_file(filenames{nseg});
                                                            end
                                                        end
                                                    end
                                                    %CONN_x.Setup.structural{nsub}{nses}=V;
                                                    %[V,str,icon]=conn_getinfo(deblank(filename(n1,:)));
                                                    %CONN_x.Setup.structural{nsub}={deblank(filename(n1,:)),str,icon};
                                                    n0=n0+1;
                                                end
                                            end
                                        end
                                    else
                                        for n1=1:length(nsubs),
                                            nsub=nsubs(n1);
                                            nsess=intersect(nsessall,1:nsessmax(n1));
                                            for n2=1:length(nsess)
                                                nses=nsess(n2);
                                                if localcopy, conn_importvol2bids(deblank(filename(n1,:)),nsub,nses,'anat');
                                                else CONN_x.Setup.structural{nsub}{nses}=conn_file(deblank(filename(n0,:)));
                                                end
                                                %V=conn_file(deblank(filename(n0,:)));
                                                if conn_importaseg(fileparts(CONN_x.Setup.structural{nsub}{nses}{1}),[],true)
                                                    if isempty(askimport)
                                                        answ=conn_questdlg('Freesurfer aseg.mgz segmentation files found. Do you want to import Grey/White/CSF masks from these files?','','Yes','No','Yes');
                                                        if strcmp(answ,'Yes'), askimport=true;
                                                        else askimport=false;
                                                        end
                                                    end
                                                    if askimport
                                                        filenames=conn_importaseg(fileparts(CONN_x.Setup.structural{nsub}{nses}{1}));
                                                        for nseg=1:3
                                                            CONN_x.Setup.rois.files{nsub}{nseg}{nses}=conn_file(filenames{nseg});
                                                        end
                                                    end
                                                end
                                                %CONN_x.Setup.structural{nsub}{nses}=V;
                                                %[V,str,icon]=conn_getinfo(deblank(filename(n1,:)));
                                                %CONN_x.Setup.structural{nsub}={deblank(filename(n1,:)),str,icon};
                                                n0=n0+1;
                                            end
                                        end
                                    end
                                    txt=sprintf('%d files assigned to %d subjects/sessions\n',size(filename,1),nfields);
                                    set(CONN_h.menus.m_setup_00{6},'value',2);
                                    if ishandle(hmsg), delete(hmsg); end
								elseif size(filename,1)==1,
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    nsessall=get(CONN_h.menus.m_setup_00{2},'value');
                                    nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                                    if ~CONN_x.Setup.structural_sessionspecific, nsessall=1:max(nsessmax); end
                                    if ~localcopy, V=conn_file(deblank(filename)); end
                                    for n1=1:length(nsubs),
                                        nsub=nsubs(n1);
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            if localcopy, conn_importvol2bids(deblank(filename),nsub,nses,'anat');
                                            else CONN_x.Setup.structural{nsub}{nses}=V;
                                            end
                                        end
                                    end
									%[V,str,icon]=conn_getinfo(deblank(filename));
									%for nsub=nsubs(:)',CONN_x.Setup.structural{nsub}={deblank(filename),str,icon};end
                                    txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    set(CONN_h.menus.m_setup_00{6},'value',2);
                                    if ishandle(hmsg), delete(hmsg); end
								else 
                                    if CONN_x.Setup.structural_sessionspecific, conn_msgbox(sprintf('mismatched number of files (%d files; %d subjects/sessions)',size(filename,1),nfields),'',2);
                                    else conn_msgbox(sprintf('mismatched number of files (%d files; %d subjects)',size(filename,1),length(nsubs)),'',2);
                                    end
                                end
                                if ~isempty(txt)&&strcmp(conn_questdlg(txt,'','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.rois.files=bak1;CONN_x.Setup.structural=bak2; end
                            case 4,
                                nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                                nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                if ~CONN_x.Setup.structural_sessionspecific, nsess=1; end
                                if ~isempty(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1})
                                    tempstr=cellstr(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1});
                                    [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                                    tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                                    set(CONN_h.menus.m_setup_00{3}.selectfile,'string',unique(tempstr_name));
                                    set(CONN_h.menus.m_setup_00{3}.folder,'string',fileparts(tempstr{1}));
                                    conn_filesearchtool(CONN_h.menus.m_setup_00{3}.folder,[],'folder',true);
                                end
                            case 6,
                                if nargin<4, nsubs=get(CONN_h.menus.m_setup_00{1},'value'); else  nsubs=varargin{4}; end
                                nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                value=get(CONN_h.menus.m_setup_00{6},'value');
                                if ~CONN_x.Setup.structural_sessionspecific, nsess=1; end
                                if value==2&&~conn_checkFSfiles(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{3})
                                    conn_checkFSfiles(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{3},true);
                                    conn_msgbox({'CONN requires Freesurfer-generated subject-specific cortical surfaces for surface-based analyses',' ','No Freesurfer files found (see Matlab command window for details)','Only volume-based analyses available'},'',2);
                                end
%                             case 11,
%                                 normalized=get(CONN_h.menus.m_setup_00{11},'value');
%                                 if ~normalized, warndlg('Warning: Second-level analyses not available for un-normalized data'); end
%                                 CONN_x.Setup.normalized=normalized;
                            case 13,
                                CONN_x.Setup.structural_sessionspecific=get(CONN_h.menus.m_setup_00{13},'value')-1;
                            case 14,
                                if numel(varargin)>=3, val=varargin{3};
                                else val=get(CONN_h.menus.m_setup_00{14},'value');
                                end
                                fh=[];
                                switch(val)
                                    case {2,3}, % slice viewer
                                        if numel(varargin)>=4, nsubs=varargin{4};
                                        else  nsubs=get(CONN_h.menus.m_setup_00{1},'value');set(CONN_h.menus.m_setup_00{14},'value',1);
                                        end
                                        if numel(varargin)>=5, nsess=varargin{5};
                                        else nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                        end
                                        if ~CONN_x.Setup.structural_sessionspecific, nsess=1; end
                                        if ~isempty(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1})
                                            if val==2, fh=conn_slice_display([],CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1});
                                            else fh=conn_slice_display(fullfile(fileparts(which(mfilename)),'utils','surf','referenceGM.nii'),CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1},[],.25);
                                                fh('colormap',.85*[1 1 0;1 1 0]);fh('contour_transparency',1);fh('act_transparency',0);fh('background',[0 0 0]);
                                            end
                                        end
                                        varargout={fh};
                                        return;
                                    case 4, % checkregistration
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                                        nsess=get(CONN_h.menus.m_setup_00{2},'value');
                                        sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                        if ~sessionspecific, nsess=1; end
                                        structural_template=fullfile(fileparts(which('spm')),'templates','T1.nii');
                                        if isempty(dir(structural_template)), structural_template=fullfile(fileparts(which('spm')),'toolbox','OldNorm','T1.nii'); end
                                        files={spm_vol(structural_template)};filenames={structural_template};
                                        for n1=1:numel(nsubs)
                                            nsub=nsubs(n1);
                                            nsesst=intersect(nsess,1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)));
                                            for n2=1:length(nsesst)
                                                nses=nsesst(n2);
                                                files{end+1}=CONN_x.Setup.structural{nsub}{nses}{3}(1);
                                                filenames{end+1}=CONN_x.Setup.structural{nsub}{nses}{1};
                                            end
                                        end
                                        [nill,idx]=unique(filenames);
                                        spm_check_registration([files{sort(idx)}]);
                                    case 6, % apply individual preprocessing step
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        conn('gui_setup_preproc','select','structural');
                                    case 5, % single-slice display
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        data=get(CONN_h.menus.m_setup_00{5}.h2,'userdata');
                                        [tx,ty]=ndgrid(1:data.buttondown.matdim.dim(1),1:data.buttondown.matdim.dim(2));
                                        txyz=data.buttondown.matdim.mat*[tx(:) ty(:) data.n+zeros(numel(tx),1) ones(numel(tx),1)]';
                                        dispdata={};displabel={};
                                        hmsg=conn_msgbox('Loading data... please wait','');
                                        sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                        for nsub=1:CONN_x.Setup.nsubjects
                                            if ~sessionspecific, nsess=1; else nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)); end
                                            for nses=1:nsess
                                                Vsource=CONN_x.Setup.structural{nsub}{nses}{1};
                                                if isempty(Vsource), 
                                                    fprintf('Subject %d session %d data not found\n',nsub,nses);
                                                    dispdata{end+1}=nan(data.buttondown.matdim.dim([2 1]));
                                                else
                                                    files=spm_vol(Vsource);
                                                    dispdata{end+1}=fliplr(flipud(reshape(spm_get_data(files,pinv(files.mat)*txyz),data.buttondown.matdim.dim(1:2))'));
                                                end
                                                if ~sessionspecific, displabel{end+1}=sprintf('Subject %d',nsub);
                                                else displabel{end+1}=sprintf('Subject %d session %d',nsub,nses);
                                                end
                                            end
                                        end
                                        fh=conn_montage_display(cat(4,dispdata{:}),displabel);
                                        fh('colormap','gray'); 
                                        if ishandle(hmsg), delete(hmsg); end
                                        varargout={fh};
                                        return;
                                    case 7,
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        conn_rulebasedfilename structural;
                                    otherwise,
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        return;
                                end
                        end
                    end
                    nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                    nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                    nsess=get(CONN_h.menus.m_setup_00{2},'value');
                    if ~CONN_x.Setup.structural_sessionspecific, nsess=1; end
                    volsurf=get(CONN_h.menus.m_setup_00{6},'value');
                    if ~CONN_x.Setup.structural_sessionspecific, set([CONN_h.menus.m_setup_00{2}, CONN_h.menus.m_setup_00{15}],'visible','off');
                    else set([CONN_h.menus.m_setup_00{2}, CONN_h.menus.m_setup_00{15}],'visible','on');
                    end

                    for nsub=1:CONN_x.Setup.nsubjects
                        if length(CONN_x.Setup.structural)<nsub, CONN_x.Setup.structural{nsub}={}; end
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            if length(CONN_x.Setup.structural{nsub})<nses, CONN_x.Setup.structural{nsub}{nses}={}; end
                            if length(CONN_x.Setup.structural{nsub}{nses})<3, CONN_x.Setup.structural{nsub}{nses}{3}=[]; end
                        end
                    end
					ok=1; ko=[];
                    for n1=1:length(nsubs),
                        nsub=nsubs(n1);
                        for nses=intersect(nsess(:)',1:nsessmax(n1))
                            if isempty(ko), ko=CONN_x.Setup.structural{nsub}{nses}{1};
                            else  if ~all(size(ko)==size(CONN_x.Setup.structural{nsub}{nses}{1})) || ~all(all(ko==CONN_x.Setup.structural{nsub}{nses}{1})), ok=0; end; end
                        end
                    end
                    if isempty(nses)||isempty(nsubs)||numel(CONN_x.Setup.structural{nsub})<nses||isempty(CONN_x.Setup.structural{nsub}{nses}{1})
						conn_menu('updateimage',CONN_h.menus.m_setup_00{5},[]);
                        set(CONN_h.menus.m_setup_00{14},'visible','off'); 
						set(CONN_h.menus.m_setup_00{4},'string','','tooltipstring','');
                    elseif ok,
                        vol=CONN_x.Setup.structural{nsub}{nses}{3};
                        if conn_checkFSfiles(CONN_x.Setup.structural{nsub}{nses}{3}), 
                            if volsurf>1, vol.checkSurface=true; end
                        else set(CONN_h.menus.m_setup_00{6},'value',1);
                        end
						conn_menu('updateimage',CONN_h.menus.m_setup_00{5},vol);
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
                        tempstr=cellstr(CONN_x.Setup.structural{nsub}{nses}{1});
 						set(CONN_h.menus.m_setup_00{4},'string',conn_cell2html(CONN_x.Setup.structural{nsub}{nses}{2}),'tooltipstring',conn_cell2html(tempstr));
					else  
						conn_menu('updateimage',CONN_h.menus.m_setup_00{5},[]);
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
						set(CONN_h.menus.m_setup_00{4},'string','multiple files','tooltipstring','');
					end
                    if isempty(nsubs)||~(nsubs(1)<=numel(CONN_x.Setup.structural)&&nsess(1)<=numel(CONN_x.Setup.structural{nsubs(1)})&&isstruct(CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{3})), set([CONN_h.menus.m_setup_00{6},CONN_h.menus.m_setup_00{14}],'visible','off'); end
					ok=1; ko=[];
                    for nsub=1:CONN_x.Setup.nsubjects
                        nsessall=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub));
                        if ~CONN_x.Setup.structural_sessionspecific, nsessall=1; end
                        for nses=nsessall
                            if isempty(CONN_x.Setup.structural{nsub}{nses}{1}), ok=0; ko=[nsub nses]; break; end
                        end
                        if ~ok, break; end
                    end
                    conn_menumanager('helpstring','');
                    if ~ok, conn_menumanager('helpstring',sprintf('WARNING: incomplete information (enter structural file for subject %d session %d)',ko(1),ko(2))); end
                case 4, %ROIs
                    boffset=[.06 .15 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.13,.03,.55,.64],'ROI data');
                        conn_menu('nullstr',{'No ROI','file selected'});
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.140,.13,.075,.46],'ROIs','',['<HTML>Select ROI <br/> - click after the last item to add a new ROI <br/> - ',CONN_gui.rightclick,'-click for additional options</HTML>'],'conn(''gui_setup'',1);','conn(''gui_setup'',8);');
						[CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{19}]=conn_menu('listbox',boffset+[.215,.13,.075,.46],'Subjects','','Select subject(s)','conn(''gui_setup'',2);');
						[CONN_h.menus.m_setup_00{16},CONN_h.menus.m_setup_00{15}]=conn_menu('listbox',boffset+[.29,.13,.075,.46],'Sessions','','Select session','conn(''gui_setup'',16);');
						CONN_h.menus.m_setup_00{3}=conn_menu('filesearch',[],'Select ROI definition files','*.img; *.nii; *.tal; *.mgh; *.mgz; *.annot; *.gz; *-1.dcm','',{@conn,'gui_setup',3},'conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{4}=conn_menu('pushbutton', boffset+[.38,.47,.25,.08],'','','','conn(''gui_setup'',4);');
                        CONN_h.menus.general.names={};CONN_h.menus.general.names2={};
						CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.37,.19,.29,.28],'','','',@conn_callbackdisplay_general);
                        %set([CONN_h.menus.m_setup_00{4}],'visible','off'); conn_menumanager('onregion',[CONN_h.menus.m_setup_00{4}],1,boffset+[.36,.02,.31,.69]);
                        ht=uicontrol('style','frame','units','norm','position',boffset+[.36,.47,.29,.08],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA);
                        set(ht,'visible','on'); conn_menumanager('onregion',ht,-1,boffset+[.36,.02,.31,.69]);
                        %ht=uicontrol('style','frame','units','norm','position',[.78,.06,.20,.84],'foregroundcolor',CONN_gui.backgroundcolor,'backgroundcolor',CONN_gui.backgroundcolor);
                        %set(ht,'visible','on'); conn_menumanager('onregion',ht,-1,boffset+[.19,0,.81,1]);
						CONN_h.menus.m_setup_00{6}=conn_menu('edit',boffset+[.40,.56,.08,.04],'ROI name','','ROI name','conn(''gui_setup'',6);');
                        fields={'Extract average timeseries','Extract PCA decomposition','Extract weighted sum timeseries'};
						CONN_h.menus.m_setup_00{7}=conn_menu('popup',boffset+[.51,.595,.16,.03],'',fields,'<HTML>Measure characterizing the ROI activation <br/> - use <i>average</i> to extract the mean BOLD timeseries within the ROI voxels <br/> - use <i>PCA</i> to extract one or several PCA components in addition to the average timeseries within the ROI voxels (e.g. for aCompCor) <br/> - use <i>weighted sum</i> to extract a weighted sum timeries within the ROI voxels (voxels are weighted by ROI mask values) (e.g. for dual-regression or probabilistic ROI definitions)</HTML>','conn(''gui_setup'',7);');
                        str=arrayfun(@(n)sprintf('from functional dataset %d',n),0:max(numel(CONN_x.Setup.roifunctional),max(CONN_x.Setup.rois.unsmoothedvolumes)),'uni',0);
						CONN_h.menus.m_setup_00{13}=conn_menu('popup',boffset+[.512,.56,.16,.03],'',str,'<HTML>source of functional data for ROI timeseries extraction<br/> - Select <b>dataset 1 or above</b> to extract ROI BOLD timeseries from any of the secondary datasets in <i>Setup.Functional</i> (default behavior; e.g. unsmoothed volumes)<br/> - Select <b>dataset 0</b> to extract ROI BOLD timeseries from the primary dataset (e.g. smoothed volumes)</HTML>','conn(''gui_setup'',13);');
						%CONN_h.menus.m_setup_00{7}=conn_menu('edit',boffset+[.49,.71,.06,.04],'Dimensions','','<HTML>number of dimensions characterizing the ROI activation <br/> - use <b>1</b> to extract only the mean BOLD timeseries within the ROI <br/> - use <b>2</b> or above to extract one or several PCA components as well</HTML>','conn(''gui_setup'',7);');
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup',boffset+[.14,.03,.25,.05],'',{'<HTML><i> - ROI tools:</i></HTML>','Slice viewer','Slice viewer with functional overlay (QA_REG)','Slice viewer with structural overlay (QA_REG)','Slice viewer with MNI reference template overlay (QA_REG)','Slice viewer with MNI boundaries (QA_NORM)','3d-volume viewer','3d-surface-projection viewer','Display ROI/functional coregistration (SPM)','Display ROI/anatomical coregistration (SPM)','Display single-slice for all subjects (montage)','Display ROI labels','Create new ROI from MNI coordinates','Add ICA network-ROIs','Reassign all ROI files simultaneously'},'<HTML> - <i>slice viewer</i> displays ROI slices<br/> - <i>slice viewer with functional/structural overlay</i> displays ROI contours overlaid with mean functional or same-subject anatomical volume<br/> - <i>slice viewer with MNI reference template overlay</i> displays ROI contours overlaid with reference MNI-space structural template<br/> - <i>slice viewer with MNI boundaries</i> displays ROI slices overlaid with 25% boundaries of grey matter tissue probability map in MNI space<br/>  - <i>3d viewer</i> displays ROI file on the volume or projected to the cortical surface<br/> - <i>display registration</i> checks the coregistration of the selected subject ROI and anatomical/functional files<br/> - <i>display single-slice for all subjects</i> creates a summary display showing the same slice across all subjects (slice coordinates in world-space) for the selected ROI<br/> - <i>display ROI labels</i> displays ROI labels for ROI atlas files and allows editing the associated labels file<br/> - <i>create new ROI from MNI coordinates</i> creates a new spherical-ROI file from a set of user-defined MNI coordinates<br/>  - <i>Add ICA network-ROIs</i> adds ICA networks (spatial components from group-ICA analysis results) as a new ROI atlas<br/> - <i>reassign all ROI files simultaneously</i> reassigns files associated with the selected ROI using a user-generated search/replace filename rule</HTML>','conn(''gui_setup'',14);');
						%conn_menu('frame',boffset+[.38,.03,.30,.12]);
                        CONN_h.menus.m_setup_00{10}=conn_menu('checkbox',boffset+[.40,.115,.02,.03],'Atlas file','','<HTML>ROI file contains multiple ROI definitions (atlas file)<br/>Atlas files combine an image file describing multiple ROIs locations and one text file describing ROI labels<br/>There are two types of atlas files that CONN can interpret:<br/><b>3d nifti/analyze volume</b><br/> - Image file should contain N integer values, from 1 to N, identifying the different ROI locations<br/> - Text file should have the same base filename and a .txt extension, and it should contain a list with the N ROI labels (one per line) <br/> - Alternatively, if the ROI numbers in the image file are not sequential, the associated labels file can be defined as: <br/> a) a .txt file with two space-separated columns (ROI number ROI label) and N rows; b) a .csv file with two comma-separated <br/>columns and one header row (ROI number,ROI label); or c) a FreeSurfer-format *LUT.txt file (e.g. FreeSurferColorLUT.txt)<br/><b>4d nifti volume</b><br/> - Each of the N volumes of the 4d-image file contains a single ROI mask<br/> - Text file should have the same base filename and a .txt extension, and it should contain a list with the N ROI labels (one per line)</HTML>','conn(''gui_setup'',10);');
						CONN_h.menus.m_setup_00{18}=conn_menu('checkbox',boffset+[.40,.080,.02,.03],'Subject-specific ROI','','Use subject-specific ROI files (one file per subject)','conn(''gui_setup'',18);');
						[CONN_h.menus.m_setup_00{11},CONN_h.menus.m_setup_00{17}]=conn_menu('checkbox',boffset+[.40,.045,.02,.03],'Session-specific ROI','','Use sesion-specific ROI files (one file per session)','conn(''gui_setup'',11);');
						CONN_h.menus.m_setup_00{9}=conn_menu('checkbox',boffset+[.52,.115,.02,.03],'Mask with Grey Matter','','extract only from grey matter voxels (intersect this ROI with each subject''s grey matter mask)','conn(''gui_setup'',9);');
						[CONN_h.menus.m_setup_00{12},CONN_h.menus.m_setup_00{20}]=conn_menu('checkbox',boffset+[.52,.080,.02,.03],'Regress-out covariates','','<HTML>regress out covariates before performing PCA decomposition of BOLD signal within ROI<br/> - this field only applies when extracting more than 1 dimension (<i>extract PCA decomposition</i> option) from an ROI</HTML>','conn(''gui_setup'',12);');
                        CONN_h.menus.m_setup_00{21}=conn_menu('pushbutton', boffset+[.525,.045,.10,.03],'','Erosion settings','<HTML>thresholding and erosion settings for tissue probability maps (Grey/White/CSF masks)<br/> - note: erosion helps minimize potential partial-volume effects when extracting signals from noise ROIs</HTML>','conn(''gui_setup'',21);');
						%CONN_h.menus.m_setup_00{13}=conn_menu('checkbox',boffset+[.50,.045,.02,.03],'Use ROI source data','','<HTML>source of functional data for ROI timeseries extraction<br/> - when checked CONN extracts ROI BOLD timeseries from the funcional volumes defined in the field "<i>Setup.Functional.Functional data for <b>ROI</b>-level analyses: </i>" (default behavior; e.g. unsmoothed volumes)<br/> - when unchecked CONN extracts ROI BOLD timeseries from the functional volumes defined in the field "<i>Setup.Functional.Functional data for <b>voxel</b>-level analyses: </i>" (non-default behavior; e.g. smoothed volumes)</HTML>','conn(''gui_setup'',13);');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','popupmenu','units','norm','position',boffset+[.37,.08,.15,.04],'string',{'<HTML><i> - options:</i></HTML>','check registration'},'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'fontsize',8+CONN_gui.font_offset,'callback','conn(''gui_setup'',14);','tooltipstring','ROIs additional options');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','pushbutton','units','norm','position',boffset+[.37,.08,.15,.04],'string','Check registration','tooltipstring','Check coregistration of ROI and structural files for selected subject(s)/roi(s)','callback','conn(''gui_setup'',14);','fontsize',8+CONN_gui.font_offset);
						set(CONN_h.menus.m_setup_00{2},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'value',1,'max',2);
						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.rois.names,'max',1);
						set(CONN_h.menus.m_setup_00{6},'visible','off');
						set(CONN_h.menus.m_setup_00{3}.files,'max',2);
                        set([CONN_h.menus.m_setup_00{9},CONN_h.menus.m_setup_00{10}],'value',0,'visible','off');
                        nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{16},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{2},'value')),'max',2);
                        set(CONN_h.menus.m_setup_00{11},'value', CONN_x.Setup.structural_sessionspecific);
                        if all(CONN_x.Setup.nsessions==1), set(CONN_h.menus.m_setup_00{17},'foregroundcolor',[.5 .5 .5]); end
                        set(CONN_h.menus.m_setup_00{18},'value', 1);
                        %if ~isfield(CONN_x.Setup,'normalized'), CONN_x.Setup.normalized=1; end
                        %set([CONN_h.menus.m_setup_00{11}],'value',CONN_x.Setup.normalized);
                        hc1=uicontextmenu;uimenu(hc1,'Label','remove selected ROIs','callback','conn(''gui_setup'',8);');set(CONN_h.menus.m_setup_00{1},'uicontextmenu',hc1);
                        CONN_h.menus.m_setup_00{23}=uicontrol('style','frame','units','norm','position',boffset+[.38,.03,.30,.12],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA);
                        set(CONN_h.menus.m_setup_00{23},'visible','on'); conn_menumanager('onregion',CONN_h.menus.m_setup_00{23},-1,boffset+[.36,.02,.31,.69]);
                        %if all(CONN_x.Setup.nsessions==1), set([CONN_h.menus.m_setup_00{11},CONN_h.menus.m_setup_00{17}],'visible','off'); end
                        %hc1=uicontextmenu;uimenu(hc1,'Label','go to source folder','callback','conn(''gui_setup'',4);');set(CONN_h.menus.m_setup_00{4},'uicontextmenu',hc1);
                    else
                        switch(varargin{2}),
                            case 1, 
                            case 2, 
                                value=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
                                set(CONN_h.menus.m_setup_00{16},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{16},'value')));
                            case 3,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nsubs=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsessall=get(CONN_h.menus.m_setup_00{16},'value'); 
                                if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                else subjectspecific=1;
                                end
                                if ~subjectspecific, nsubs=1:CONN_x.Setup.nsubjects; end
                                nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                                if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                end
                                if ~sessionspecific, nsessall=1:max(nsessmax); end
								filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                                nfields0=sum(conn_bsxfun(@le,nsessall(:),nsessmax(:)'),1);
                                nfields=sum(nfields0,2);
                                txt=''; bak1=CONN_x.Setup.rois;
								if ~sessionspecific&&~subjectspecific&&size(filename,1)==1,
                                    hmsg=conn_msgbox('Loading files... please wait','');
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        V=conn_file(deblank(filename(1,:)));
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            CONN_x.Setup.rois.files{nsub}{nrois}{nses}=V;
                                        end
                                        filename1=CONN_x.Setup.rois.files{nsub}{nrois}{1}{1};
                                        [nill,nill,nameext]=spm_fileparts(filename1);%deblank(filename(n1,:)));
									end
                                    CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                    txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    if ishandle(hmsg), delete(hmsg); end
                                elseif ~sessionspecific&&subjectspecific&&size(filename,1)==length(nsubs),
                                    hmsg=conn_msgbox('Loading files... please wait','');
									for n1=1:length(nsubs),
										nsub=nsubs(n1);
                                        V=conn_file(deblank(filename(n1,:)));
                                        nsess=intersect(nsessall,1:nsessmax(n1));
                                        for n2=1:length(nsess)
                                            nses=nsess(n2);
                                            CONN_x.Setup.rois.files{nsub}{nrois}{nses}=V;
                                        end
                                        filename1=CONN_x.Setup.rois.files{nsub}{nrois}{1}{1};
                                        [nill,nill,nameext]=spm_fileparts(filename1);%deblank(filename(n1,:)));
									end
                                    CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                    txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    if ishandle(hmsg), delete(hmsg); end
                                elseif sessionspecific&&~subjectspecific&&all(size(filename,1)==nfields0),
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    nsess=intersect(nsessall,1:nsessmax(1));
                                    for n2=1:length(nsess)
                                        nses=nsess(n2);
                                        V=conn_file(deblank(filename(n2,:)));
                                        for n1=1:length(nsubs),
                                            nsub=nsubs(n1);
                                            CONN_x.Setup.rois.files{nsub}{nrois}{nses}=V;
                                        end
                                        filename1=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1};
                                        [nill,nill,nameext]=spm_fileparts(filename1);%deblank(filename(n1,:)));
									end
                                    CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                    txt=sprintf('%d files assigned to %d sessions\n',size(filename,1),length(nsess));
                                    if ishandle(hmsg), delete(hmsg); end
                                elseif subjectspecific&&sessionspecific&&size(filename,1)==nfields,
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    firstallsubjects=false;
                                    if numel(nsessall)>1&&numel(nsubs)>1
                                        opts={sprintf('First all subjects for session %d, followed by all subjects for session %d, etc.',nsessall(1),nsessall(2)),...
                                         sprintf('First all sessions for subject %d, followed by all sessions for subject %d, etc.',nsubs(1),nsubs(2))};
                                        answ=conn_questdlg('',sprintf('Order of files (%d files, %d subjects, %d sessions)',size(filename,1),numel(nsubs),numel(nsessall)),opts{[1,2,2]});
                                        if isempty(answ), return; end
                                        firstallsubjects=strcmp(answ,opts{1});
                                    end
                                    n0=0;
                                    if firstallsubjects
                                        for nses=nsessall,
                                            for n1=1:length(nsubs),
                                                if nses<=nsessmax(n1)
                                                    nsub=nsubs(n1);
                                                    n0=n0+1;
                                                    tfilename=deblank(filename(n0,:));
                                                    CONN_x.Setup.rois.files{nsub}{nrois}{nses}=conn_file(tfilename);
                                                    filename1=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1};
                                                    [nill,nill,nameext]=spm_fileparts(filename1);%deblank(filename(n1,:)));
                                                end
                                            end
                                        end
                                    else
                                        for n1=1:length(nsubs),
                                            nsub=nsubs(n1);
                                            for nses=intersect(nsessall,1:nsessmax(n1))
                                                n0=n0+1;
                                                tfilename=deblank(filename(n0,:));
                                                CONN_x.Setup.rois.files{nsub}{nrois}{nses}=conn_file(tfilename);
                                                filename1=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1};
                                                [nill,nill,nameext]=spm_fileparts(filename1);%deblank(filename(n1,:)));
                                            end
                                        end
                                    end                                    
                                    CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                    txt=sprintf('%d files assigned to %d subjects/sessions\n',size(filename,1),nfields);
                                    if ishandle(hmsg), delete(hmsg); end
								elseif size(filename,1)==1 || ~subjectspecific&&~sessionspecific,
                                    if size(filename,1)>1,
                                        answ=conn_questdlg(sprintf('import these %d files as %d new ROIs?',size(filename,1),size(filename,1)),'','Yes','No','Yes');
                                        if ~strcmp(answ,'Yes'), return; end
                                    end
                                    hmsg=conn_msgbox('Loading files... please wait','');
                                    if size(filename,1)>1, nroisall=[]; 
                                    else nroisall=nrois;
                                    end
                                    for n0=1:size(filename,1)
                                        if numel(nroisall)>=n0, nrois=nroisall(n0);
                                        else nrois=numel(CONN_x.Setup.rois.names);
                                        end
                                        temp=conn_file(deblank(filename(n0,:)));
                                        filename1=temp{1};
                                        [nill,namename,nameext]=spm_fileparts(filename1);%filename));
                                        if isempty(deblank(CONN_x.Setup.rois.names{nrois})), 
                                            if any(strcmp(namename,CONN_x.Setup.rois.names)), 
                                                answ=conn_questdlg(sprintf('ROI %s already exist',namename),'','Overwrite','Cancel','Overwrite');
                                                if ~strcmp(answ,'Overwrite'), CONN_x.Setup.rois=bak1; if ishandle(hmsg), delete(hmsg); end; return; end
                                                nrois=find(strcmp(namename,CONN_x.Setup.rois.names),1);
                                            end
                                            CONN_x.Setup.rois.names{nrois}=namename; 
                                        end
                                        for n1=1:length(nsubs),
                                            nsub=nsubs(n1);
                                            nsess=intersect(nsessall,1:nsessmax(n1));
                                            for n2=1:length(nsess)
                                                nses=nsess(n2);
                                                CONN_x.Setup.rois.files{nsub}{nrois}{nses}=temp;
                                            end
                                        end
                                        CONN_x.Setup.rois.multiplelabels(nrois)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',deblank(filename1),'.txt')))|~isempty(dir(conn_prepend('',deblank(filename1),'.csv')))|~isempty(dir(conn_prepend('',deblank(filename1),'.xls'))));
                                        if ~isfield(CONN_x.Setup.rois,'dimensions') || length(CONN_x.Setup.rois.dimensions)<nrois, CONN_x.Setup.rois.dimensions{nrois}=1; end
                                        if ~isfield(CONN_x.Setup.rois,'mask') || length(CONN_x.Setup.rois.mask)<nrois, CONN_x.Setup.rois.mask(nrois)=0; end
                                        if ~isfield(CONN_x.Setup.rois,'subjectspecific') || length(CONN_x.Setup.rois.subjectspecific)<nrois, CONN_x.Setup.rois.subjectspecific(nrois)=0; end
                                        if ~isfield(CONN_x.Setup.rois,'sessionspecific') || length(CONN_x.Setup.rois.sessionspecific)<nrois, CONN_x.Setup.rois.sessionspecific(nrois)=0; end
                                        if ~isfield(CONN_x.Setup.rois,'multiplelabels') || length(CONN_x.Setup.rois.multiplelabels)<nrois, CONN_x.Setup.rois.multiplelabels(nrois)=0; end
                                        if ~isfield(CONN_x.Setup.rois,'regresscovariates') || length(CONN_x.Setup.rois.regresscovariates)<nrois, CONN_x.Setup.rois.regresscovariates(nrois)=double(CONN_x.Setup.rois.dimensions{nrois}>1); end
                                        if ~isfield(CONN_x.Setup.rois,'unsmoothedvolumes') || length(CONN_x.Setup.rois.unsmoothedvolumes)<nrois, CONN_x.Setup.rois.unsmoothedvolumes(nrois)=1; end
                                        if nrois==length(CONN_x.Setup.rois.names), CONN_x.Setup.rois.names{nrois+1}=' '; end
                                    end
                                    set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.rois.names,'value',max(1,min(length(CONN_x.Setup.rois.names),nrois)));
                                    if isempty(nroisall), txt=sprintf('%d files assigned to %d new rois\n',size(filename,1),size(filename,1));
                                    else txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                                    end
                                    if ishandle(hmsg), delete(hmsg); end
                                else
                                    if sessionspecific, conn_msgbox(sprintf('mismatched number of files (%d files; %d subjects/sessions)',size(filename,1),nfields),'',2);
                                    else conn_msgbox(sprintf('mismatched number of files (%d files; %d subjects)',size(filename,1),length(nsubs)),'',2);
                                    end
								end
                                if ~isempty(txt)&&strcmp(conn_questdlg(txt,'','Ok','Undo','Ok'),'Undo'), 
                                    CONN_x.Setup.rois=bak1;
                                    set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.rois.names,'value',max(1,min(length(CONN_x.Setup.rois.names),max(nrois))));
                                end
                            case 4,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nsubs=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsess=get(CONN_h.menus.m_setup_00{16},'value');
                                if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                else subjectspecific=1;
                                end
                                if ~subjectspecific, nsubs=1; end
                                if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                end
                                if ~sessionspecific, nsess=1; end
                                if ~isempty(CONN_x.Setup.rois.files{nsubs(1)}{nrois(1)}{nsess(1)}{1})
                                    tempstr=cellstr(CONN_x.Setup.rois.files{nsubs(1)}{nrois(1)}{nsess(1)}{1});
                                    [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                                    tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                                    set(CONN_h.menus.m_setup_00{3}.selectfile,'string',unique(tempstr_name));
                                    set(CONN_h.menus.m_setup_00{3}.folder,'string',fileparts(tempstr{1}));
                                    conn_filesearchtool(CONN_h.menus.m_setup_00{3}.folder,[],'folder',true);
                                end
							case 6,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
								names=get(CONN_h.menus.m_setup_00{1},'string');
								name=fliplr(deblank(fliplr(deblank(get(CONN_h.menus.m_setup_00{6},'string')))));
								if nrois<=3||~isempty(strmatch(name,names,'exact')),name=CONN_x.Setup.rois.names{nrois}; end
                                names{nrois}=name;
                                CONN_x.Setup.rois.names{nrois}=name;
                                if nrois==length(CONN_x.Setup.rois.names)&&~strcmp(CONN_x.Setup.rois.names{nrois},' '), CONN_x.Setup.rois.names{nrois+1}=' '; names{nrois+1}=' '; end
                                set(CONN_h.menus.m_setup_00{1},'string',names);
                            case 7,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
								names=get(CONN_h.menus.m_setup_00{1},'string');
                                switch (get(CONN_h.menus.m_setup_00{7},'value'))
                                    case 1, CONN_x.Setup.rois.dimensions{nrois}=1;
                                    case 2, 
                                        answ={num2str(max(1,CONN_x.Setup.rois.dimensions{nrois}))};
                                        answ=inputdlg('Number of PCA components','',1,answ);
                                        if numel(answ)==1&&numel(str2num(answ{1}))==1, CONN_x.Setup.rois.dimensions{nrois}=max(0,round(str2num(answ{1}))); end
                                    case 3, CONN_x.Setup.rois.dimensions{nrois}=0;
                                end
								%dims=abs(round(str2num(get(CONN_h.menus.m_setup_00{7},'string'))));
								%if length(dims)==1,CONN_x.Setup.rois.dimensions{nrois}=dims;end
                            case 8,
                                nrois0=length(CONN_x.Setup.rois.names);
								nrois1=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nrois=setdiff(nrois1,[1:3,nrois0]);
                                nrois=setdiff(1:nrois0,nrois);
                                CONN_x.Setup.rois.names={CONN_x.Setup.rois.names{nrois}};
                                nrois=setdiff(nrois,nrois0);
                                CONN_x.Setup.rois.dimensions={CONN_x.Setup.rois.dimensions{nrois}};
                                CONN_x.Setup.rois.mask=CONN_x.Setup.rois.mask(nrois);
                                CONN_x.Setup.rois.subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                CONN_x.Setup.rois.sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                CONN_x.Setup.rois.multiplelabels=CONN_x.Setup.rois.multiplelabels(nrois);
                                CONN_x.Setup.rois.regresscovariates=CONN_x.Setup.rois.regresscovariates(nrois);
                                CONN_x.Setup.rois.unsmoothedvolumes=CONN_x.Setup.rois.unsmoothedvolumes(nrois);
                                for n1=1:length(CONN_x.Setup.rois.files), CONN_x.Setup.rois.files{n1}={CONN_x.Setup.rois.files{n1}{nrois}}; end
        						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.rois.names,'value',max(1,min(length(CONN_x.Setup.rois.names)-1,max(nrois1))));
                                for n1=1:3,if any(nrois1==n1), 
                                        for nsub=1:CONN_x.Setup.nsubjects, for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.rois.files{nsub}{n1}{nses}={[],[],[]}; end; end
                                    end; end
                            case 9,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                if nrois>3,
                                    value=get(CONN_h.menus.m_setup_00{9},'value');
                                    CONN_x.Setup.rois.mask(nrois)=value;
                                else set(CONN_h.menus.m_setup_00{9},'value',0);end
                            case 10,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                if nrois>3,
                                    value=get(CONN_h.menus.m_setup_00{10},'value');
                                    CONN_x.Setup.rois.multiplelabels(nrois)=value;
                                else set(CONN_h.menus.m_setup_00{10},'value',0);
                                end
                            case 11,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                if nrois>3
                                    value=get(CONN_h.menus.m_setup_00{11},'value');
                                    CONN_x.Setup.rois.sessionspecific(nrois)=value;
                                else set(CONN_h.menus.m_setup_00{11},'value',CONN_x.Setup.structural_sessionspecific);
                                end
%                             case 11,
%                                 normalized=get(CONN_h.menus.m_setup_00{11},'value');
%                                 if ~normalized, warndlg('Warning: Second-level analyses not available for un-normalized data'); end
%                                 CONN_x.Setup.normalized=normalized;
                            case 12
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                value=get(CONN_h.menus.m_setup_00{12},'value');
                                CONN_x.Setup.rois.regresscovariates(nrois)=value;
                            case 13
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                value=get(CONN_h.menus.m_setup_00{13},'value')-1;
                                CONN_x.Setup.rois.unsmoothedvolumes(nrois)=value;
                            case 14,
                                if numel(varargin)>=3, val=varargin{3};
                                else val=get(CONN_h.menus.m_setup_00{14},'value');
                                end
                                fh=[];
                                switch(val) 
                                    case {2,3,4,5,6},
                                        if numel(varargin)>=4, nrois=varargin{4};
                                        else  nrois=get(CONN_h.menus.m_setup_00{1},'value');set(CONN_h.menus.m_setup_00{14},'value',1);
                                        end
                                        erois=nrois<0;nrois=abs(nrois);
                                        if numel(varargin)>=5, nsubs=varargin{5};
                                        else  nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                                        end
                                        if numel(varargin)>=6, nsess=varargin{6};
                                        else  nsess=get(CONN_h.menus.m_setup_00{16},'value');
                                        end
                                        if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                        else subjectspecific=1;
                                        end
                                        if ~subjectspecific, nsubstemp=1; 
                                        else nsubstemp=nsubs;
                                        end
                                        if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                        else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                        end
                                        if ~sessionspecific, nsesstemp=1; 
                                        else nsesstemp=nsess; 
                                        end
                                        if numel(varargin)<6, nsess=nsesstemp; end
                                        unsmoothedvolumes=CONN_x.Setup.rois.unsmoothedvolumes(nrois);
                                        roifile=CONN_x.Setup.rois.files{nsubstemp(1)}{nrois}{nsesstemp(1)}{1};
                                        if erois, roifile=conn_prepend('e',roifile); end
                                        if val==2, fh=conn_slice_display([],roifile);
                                        elseif val==5, % MNI overlay
                                            if nrois<=3, 
                                                THR=CONN_x.Setup.erosion.binary_threshold(nrois);
                                                fh=conn_slice_display(roifile,[],[],THR);
                                                fh('act_transparency',.5);fh('background',[1 1 1]);fh('contour_transparency',1);
                                            else fh=conn_slice_display(roifile,[]);
                                                fh('act_transparency',.5);fh('contour_transparency',1);
                                            end
                                        elseif val==3 % functional overlay
                                            Vsource=CONN_x.Setup.functional{nsubs(1)}{nsess(1)}{1};
                                            if unsmoothedvolumes
                                                nset=unsmoothedvolumes;
                                                try
                                                    if CONN_x.Setup.roifunctional(nset).roiextract==4
                                                        VsourceUnsmoothed=cellstr(CONN_x.Setup.roifunctional(nset).roiextract_functional{nsubs(1)}{nsess(1)}{1});
                                                    else
                                                        Vsource1=cellstr(Vsource);
                                                        VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roifunctional(nset).roiextract,CONN_x.Setup.roifunctional(nset).roiextract_rule);
                                                    end
                                                    existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                    if ~all(existunsmoothed),
                                                        fprintf('warning: set-%d data for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nset,nsubs(1),nsess(1));
                                                    else
                                                        Vsource=char(VsourceUnsmoothed);
                                                    end
                                                catch
                                                    fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nsubs(1),nsess(1));
                                                end
                                            else nset=0;
                                            end
                                            temp=cellstr(Vsource);
                                            if isempty(temp), conn_msgbox(sprintf('Functional data not defined for subject %d session %d',nsubs(1),nsess(1)),'Error',2); return; end
                                            [xtemp,failed]=conn_setup_preproc_meanimage(temp{1});
                                            if ~isempty(xtemp), temp1=xtemp;
                                            else
                                                if numel(temp)==1,
                                                    temp1=cellstr(conn_expandframe(temp{1}));
                                                    temp1=temp1{1};
                                                else temp1=temp{1};
                                                end
                                            end
                                            %if numel(temp)==1,
                                            %    temp=cellstr(conn_expandframe(temp{1}));
                                            %end
                                            if nrois<=3, 
                                                THR=CONN_x.Setup.erosion.binary_threshold(nrois);
                                                fh=conn_slice_display(roifile,temp1,[],THR,sprintf('dataset %d',nset));
                                                fh('colormap',.85*[1 1 0;1 1 0]);fh('contour_transparency',1);fh('act_transparency',0);fh('background',[0 0 0]);
                                            else fh=conn_slice_display(roifile,temp1,[],[],sprintf('dataset %d',nset));
                                                %fh('act_transparency',.5);fh('background',[0 0 0]);
                                                fh('colormap',.85*[1 1 0;1 1 0]);fh('contour_transparency',1);fh('act_transparency',.5);fh('background',[0 0 0]);
                                            end
                                        elseif val==4, % structural overlay
                                            if nrois<=3, 
                                                THR=CONN_x.Setup.erosion.binary_threshold(nrois);
                                                fh=conn_slice_display(roifile,CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1},[],THR);
                                                fh('colormap',.85*[1 1 0;1 1 0]);fh('contour_transparency',1);fh('act_transparency',0);fh('background',[0 0 0]);
                                            else fh=conn_slice_display(roifile,CONN_x.Setup.structural{nsubs(1)}{nsess(1)}{1});
                                                %fh('act_transparency',.5);fh('background',[0 0 0]);
                                                fh('colormap',.85*[1 1 0;1 1 0]);fh('contour_transparency',1);fh('act_transparency',.5);fh('background',[0 0 0]);
                                            end
                                        elseif val==6, % MNI boundaries
                                            if nrois==1, tref=fullfile(fileparts(which(mfilename)),'utils','surf','referenceGM.nii');
                                            elseif nrois==2, tref=fullfile(fileparts(which(mfilename)),'utils','surf','referenceWM.nii');
                                            elseif nrois==3, tref=fullfile(fileparts(which(mfilename)),'utils','surf','referenceCSF.nii');
                                            else tref=fullfile(fileparts(which(mfilename)),'utils','surf','referenceGM.nii');
                                            end
                                            fh=conn_slice_display(tref,roifile,[],.25);
                                            fh('colormap',.85*[1 1 0;1 1 0]);fh('contour_transparency',1);fh('act_transparency',0);fh('background',[0 0 0]);
                                        end
                                        varargout={fh};
                                        return;
                                    case {7,8}, % 3d view
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nrois=get(CONN_h.menus.m_setup_00{1},'value');
                                        nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                                        nsess=get(CONN_h.menus.m_setup_00{16},'value');
                                        if val==7, conn_mesh_display('',{'',CONN_x.Setup.rois.files{nsubs(1)}{nrois}{nsess(1)}{1}},[],[],[],.2);
                                        else conn_mesh_display(CONN_x.Setup.rois.files{nsubs(1)}{nrois}{nsess(1)}{1});
                                        end
                                        return;
                                    case {9,10}, % check registration anatomical
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nrois=get(CONN_h.menus.m_setup_00{1},'value');
                                        nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                                        nsess=get(CONN_h.menus.m_setup_00{16},'value');
                                        if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                        else subjectspecific=1;
                                        end
                                        if ~subjectspecific, nsubs=1; end
                                        if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                        else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                        end
                                        if ~sessionspecific, nsess=1; end
                                        unsmoothedvolumes=CONN_x.Setup.rois.unsmoothedvolumes(nrois);
                                        files={};filenames={};
                                        for n1=1:numel(nsubs)
                                            nsub=nsubs(n1);
                                            nsesst=intersect(nsess,1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)));
                                            for n2=1:length(nsesst)
                                                nses=nsesst(n2);
                                                if val==10
                                                    if CONN_x.Setup.structural_sessionspecific,
                                                        files{end+1}=CONN_x.Setup.structural{nsub}{nses}{3}(1);
                                                        filenames{end+1}=CONN_x.Setup.structural{nsub}{nses}{1};
                                                    else
                                                        files{end+1}=CONN_x.Setup.structural{nsub}{1}{3}(1);
                                                        filenames{end+1}=CONN_x.Setup.structural{nsub}{1}{1};
                                                    end
                                                else
                                                    Vsource=CONN_x.Setup.functional{nsub}{nses}{1};
                                                    if unsmoothedvolumes
                                                        nset=unsmoothedvolumes;
                                                        try
                                                            if CONN_x.Setup.roifunctional(nset).roiextract==4
                                                                VsourceUnsmoothed=cellstr(CONN_x.Setup.roifunctional(nset).roiextract_functional{nsub}{nses}{1});
                                                            else
                                                                Vsource1=cellstr(Vsource);
                                                                VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roifunctional(nset).roiextract,CONN_x.Setup.roifunctional(nset).roiextract_rule);
                                                            end
                                                            existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                            if ~all(existunsmoothed),
                                                                fprintf('warning: set-%d data for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nset,nsub,nses);
                                                            else
                                                                Vsource=char(VsourceUnsmoothed);
                                                            end
                                                        catch
                                                            fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nsub,nses);
                                                        end
                                                    end
                                                    temp=cellstr(Vsource);
                                                    if numel(temp)==1,
                                                        temp=cellstr(conn_expandframe(temp{1}));
                                                    end
                                                    files{end+1}=spm_vol(temp{1});
                                                    filenames{end+1}=temp{1};
                                                end
                                                for nroi=nrois(:)',
                                                    filename=CONN_x.Setup.rois.files{nsub}{nroi}{nses}{1};
                                                    %[V,str,icon,filename]=conn_getinfo(filename);
                                                    %CONN_x.Setup.rois.files{nsub}{nroi}{nses}={filename,str,icon};
                                                    CONN_x.Setup.rois.files{nsub}{nroi}{nses}=conn_file(filename);
                                                    files{end+1}=CONN_x.Setup.rois.files{nsub}{nroi}{nses}{3}(1);
                                                    filenames{end+1}=CONN_x.Setup.rois.files{nsub}{nroi}{nses}{1};
                                                end
                                            end
                                        end
                                        [nill,idx]=unique(filenames);
                                        spm_check_registration([files{sort(idx)}]);
                                        return;
                                    case 11, % display single-slice
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nrois=get(CONN_h.menus.m_setup_00{1},'value');
                                        data=get(CONN_h.menus.m_setup_00{5}.h2,'userdata');
                                        [tx,ty]=ndgrid(1:data.buttondown.matdim.dim(1),1:data.buttondown.matdim.dim(2));
                                        txyz=data.buttondown.matdim.mat*[tx(:) ty(:) data.n+zeros(numel(tx),1) ones(numel(tx),1)]';
                                        dispdata={};displabel={};
                                        hmsg=conn_msgbox('Loading data... please wait','');
                                        if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                        else subjectspecific=1;
                                        end
                                        if ~subjectspecific, nsubs=1; else nsubs=CONN_x.Setup.nsubjects; end
                                        if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                        else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                        end
                                        for nsub=1:nsubs
                                            if ~sessionspecific, nsess=1; else nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)); end
                                            for nses=1:nsess
                                                Vsource=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1};
                                                if isempty(Vsource), 
                                                    fprintf('Subject %d session %d data not found\n',nsub,nses);
                                                    dispdata{end+1}=nan(data.buttondown.matdim.dim([2 1]));
                                                    if ~sessionspecific, displabel{end+1}=sprintf('Subject %d',nsub);
                                                    else displabel{end+1}=sprintf('Subject %d session %d',nsub,nses);
                                                    end
                                                else
                                                    files=spm_vol(Vsource);
                                                    nvols=unique([1 numel(files)]); % only first and last volumes
                                                    %nvols=unique(round(linspace(1,numel(files),32))); % not more than 32 volumes
                                                    for nvol=nvols(:)'
                                                        dispdata{end+1}=fliplr(flipud(reshape(spm_get_data(files(nvol),pinv(files(nvol).mat)*txyz),data.buttondown.matdim.dim(1:2))'));
                                                        if ~sessionspecific, displabel{end+1}=sprintf('Subject %d volume %d',nsub,nvol);
                                                        else displabel{end+1}=sprintf('Subject %d session %d volume %d',nsub,nses,nvol);
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        fh=conn_montage_display(cat(4,dispdata{:}),displabel);
                                        if ishandle(hmsg), delete(hmsg); end
                                        varargout={fh};
                                        return;
                                    case 12, % check ROI names
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nrois=get(CONN_h.menus.m_setup_00{1},'value');
                                        nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                                        nsess=get(CONN_h.menus.m_setup_00{16},'value');
                                        if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                                        else subjectspecific=1;
                                        end
                                        if ~subjectspecific, nsubs=1; end
                                        if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                                        else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                                        end
                                        if ~sessionspecific, nsess=1; end
                                        try
                                            filename=CONN_x.Setup.rois.files{nsubs(1)}{nrois}{nsess(1)}{1};
                                            [nill,nill,nameext]=spm_fileparts(deblank(filename));
                                        catch
                                            filename='';
                                            nameext='';
                                        end
                                        if ~isempty(filename)&&(strcmp(nameext,'.img')||strcmp(nameext,'.nii')),
                                            if CONN_x.Setup.rois.multiplelabels(nrois), level='clusters'; 
                                            else, 
                                                level='rois'; 
                                                %conn_msgbox({'This is a single-ROI file','Check ''Multiple ROIs'' if this file defines multiple ROIs (atlas file)'},'',true);
                                                %return;
                                            end
                                            if CONN_x.Setup.rois.multiplelabels(nrois), 
                                                ht=conn_msgbox('Checking ROI labels. Please wait...');
                                                [nill,roinames]=conn_rex(filename,filename,'level',level,'disregard_zeros',0);
                                                if ishandle(ht), delete(ht); end
                                                if numel(roinames)>5, roinames2={roinames{1:3}, '...', roinames{end}}; else roinames2=roinames; end
                                                [nill,Vmaskfilename]=fileparts(filename);
                                                for n1=1:numel(roinames2)
                                                    if ~isempty(strmatch(Vmaskfilename,roinames2{n1})), roinames2{n1}=[CONN_x.Setup.rois.names{nrois},roinames2{n1}(numel(Vmaskfilename)+1:end)]; end
                                                end
                                                answ=conn_questdlg({sprintf('ROI file contains %d individual ROIs with labels:',numel(roinames)),' ',roinames2{:},' ','Do you want to edit the labels file now?'},'','Yes','No','Yes');
                                                if strcmp(answ,'Yes')
                                                    files={}; for nsub=nsubs(:)', for nses=intersect(nsess,1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))), files{end+1}=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}; end; end
                                                    [nill,idx]=unique(files);
                                                    files=files(sort(idx));
                                                    files=cellfun(@conn_definelabels,files,'uni',0);
                                                    if isdeployed, fprintf('Functionality not available in standalone release. Please manually edit the file %s\n',files{:});
                                                    else edit(files{:});
                                                    end
                                                end
                                            else
                                                roinames2=CONN_x.Setup.rois.names(nrois);
                                                conn_msgbox({'This is a single-ROI file with label:',' ',roinames2{:}},'',true);
                                            end
                                        end
                                        return;
                                    case 13, % new ROI from MNI coordinates
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        answ={'0 0 0','10',fullfile(pwd,'newroi.nii'),'2'};
                                        answ=inputdlg({'MNI coordinates (mm)','ROI spherical radius (mm)','ROI-file name','ROI-file resolution (mm)'},'',1,answ);
                                        if numel(answ)==4,
                                            xyz=str2num(answ{1}); if isempty(xyz), return; end
                                            rad=str2num(answ{2}); if isempty(rad), return; end
                                            res=str2num(answ{4}); if isempty(res), return; end
                                            fname=answ{3};
                                            [nill,fname_name]=fileparts(fname);
                                            if isempty(fname_name), fname_name='newroi'; end
                                            [filename,isext]=conn_createmniroi(fname,xyz,rad,res);
                                            nrois=numel(CONN_x.Setup.rois.names);
                                            if any(strcmp(CONN_x.Setup.rois.names,fname_name))
                                                nrois=find(strcmp(CONN_x.Setup.rois.names,fname_name),1);
                                                set(CONN_h.menus.m_setup_00{1},'value',nrois);
                                            else
                                                CONN_x.Setup.rois.names{nrois}=fname_name;
                                                CONN_x.Setup.rois.names{nrois+1}=' ';
                                                set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.rois.names(1:nrois+1),'value',nrois);
                                                CONN_x.Setup.rois.dimensions{nrois}=1;
                                            end
                                            CONN_x.Setup.rois.multiplelabels(nrois)=(isext>1);
                                            CONN_x.Setup.rois.subjectspecific(nrois)=0;
                                            CONN_x.Setup.rois.sessionspecific(nrois)=0;
                                            V=conn_file(filename);
                                            for nsub=1:CONN_x.Setup.nsubjects,
                                                for nses=1:CONN_x.Setup.nsessions(min(nsub,numel(CONN_x.Setup.nsessions)))
                                                    CONN_x.Setup.rois.files{nsub}{nrois}{nses}=V;
                                                end
                                            end
                                        else return;
                                        end
                                    case 14, % adds ICA ROIs
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        ICAPCA='ICA';
                                        if numel(CONN_x.vvAnalyses)>1
                                            idata=listdlg('liststring',{CONN_x.vvAnalyses.name},'selectionmode','single','initialvalue',1,'promptstring','Select analysis:','ListSize',[300 200]);
                                            if isempty(idata), return; end
                                            filename=fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses(idata).name,['ICA.ROIs.nii']);
                                        else filename=fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses.name,['ICA.ROIs.nii']);
                                        end
                                        if isempty(dir(filename)), ICAPCA='PCA'; filename=regexprep(filename,'ICA\.ROIs\.nii$','PCA.ROIs.nii'); end
                                        if isempty(dir(filename)), conn_msgbox({'ICA results not found',' ','Please complete first group-ICA anayses (from first-level analysis voxel-to-voxel/ICA tab)'},'',2); 
                                        else
                                            nrois=numel(CONN_x.Setup.rois.names);
                                            if any(strcmp(CONN_x.Setup.rois.names,['group-',ICAPCA]))
                                                nrois=find(strcmp(CONN_x.Setup.rois.names,['group-',ICAPCA]),1);
                                                set(CONN_h.menus.m_setup_00{1},'value',nrois);
                                            else
                                                CONN_x.Setup.rois.names{nrois}=['group-',ICAPCA];
                                                CONN_x.Setup.rois.names{nrois+1}=' ';
                                                set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.rois.names(1:nrois+1),'value',nrois);
                                            end
                                            CONN_x.Setup.rois.dimensions{nrois}=0; 
                                            CONN_x.Setup.rois.multiplelabels(nrois)=1;
                                            CONN_x.Setup.rois.subjectspecific(nrois)=0; 
                                            CONN_x.Setup.rois.sessionspecific(nrois)=0; 
                                            V=conn_file(filename);
                                            for nsub=1:CONN_x.Setup.nsubjects,
                                                for nses=1:CONN_x.Setup.nsessions(min(nsub,numel(CONN_x.Setup.nsessions)))
                                                    CONN_x.Setup.rois.files{nsub}{nrois}{nses}=V;
                                                end
                                            end
                                        end
                                    case 15, % reassign
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nrois=get(CONN_h.menus.m_setup_00{1},'value');
                                        conn_rulebasedfilename(sprintf('roi%d',nrois(1)));
                                end
                            case 16,
                            case 18,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                if nrois>3
                                    value=get(CONN_h.menus.m_setup_00{18},'value');
                                    CONN_x.Setup.rois.subjectspecific(nrois)=value;
                                else set(CONN_h.menus.m_setup_00{18},'value',1);
                                end
                            case 21,
								nrois=get(CONN_h.menus.m_setup_00{1},'value'); 
                                if nrois<=3
                                    THR=CONN_x.Setup.erosion.binary_threshold(nrois);
                                    THRTYPE=CONN_x.Setup.erosion.binary_threshold_type(nrois);
                                    ERODE=CONN_x.Setup.erosion.erosion_steps(nrois);
                                    ERODETYPE=1+(rem(CONN_x.Setup.erosion.erosion_steps(nrois),1)>0);
                                    NEIGHB=CONN_x.Setup.erosion.erosion_neighb(nrois);
                                    thfig=dialog('units','norm','position',[.3,.3,.3,.3],'windowstyle','normal','name',sprintf('%s erosion settings',CONN_x.Setup.rois.names{nrois}),'color','w','resize','on','userdata',false);
                                    ht1a=uicontrol(thfig,'style','text','units','norm','position',[.1,.85,.8,.08],'string','Binarization threshold:','horizontalalignment','left','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
                                    ht1=uicontrol(thfig,'style','edit','units','norm','position',[.1,.75,.2,.08],'string',num2str(THR),'horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','tooltipstring','<HTML>Defines binarization threshold <br/> - Original volumes are binarized by considering only suprathrehsold voxels with values above this threshold<br/> - e.g. use .5 to keep only voxels with >50% posterior probability from tissue probability maps</HTML>');
                                    ht1b=uicontrol(thfig,'style','popupmenu','units','norm','position',[.35,.75,.55,.08],'string',{'absolute value','percentile'},'value',THRTYPE,'horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','tooltipstring','<HTML>Threshold type<br/> - Switches between absolute and percentile binary thresholding operations</HTML>');
                                    ht2a=uicontrol(thfig,'style','text','units','norm','position',[.1,.6,.8,.08],'string','Erosion level:','horizontalalignment','left','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
                                    ht2=uicontrol(thfig,'style','edit','units','norm','position',[.1,.5,.2,.08],'string',num2str(ERODE),'horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'backgroundcolor','w');
                                    ht2b=uicontrol(thfig,'style','popupmenu','units','norm','position',[.35,.5,.55,.08],'string',{'absolute value','percentile'},'value',ERODETYPE,'horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','tooltipstring','<HTML>Erosion type<br/> - Switches between fixed erosion kernel size (absolute) and fixed proportion of voxels post-erosion (percentile)</HTML>');
                                    ht3a=uicontrol(thfig,'style','text','units','norm','position',[.1,.35,.8,.08],'string','Erosion neighborhood:','horizontalalignment','left','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
                                    ht3=uicontrol(thfig,'style','edit','units','norm','position',[.1,.25,.8,.08],'string',num2str(NEIGHB),'horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','tooltipstring','<HTML>Defines erosion kernel neighborhood<br/> - A value of M defines that a voxel will be eroded if there are more than M zeros within the (2*N+1)^3-neighborhood of each voxel <br/> - e.g. use N=1,M=0 for a 26-neighborhood erosion; N=1,M=8 for 18-neighborhood erosion</HTML>');
                                    uicontrol(thfig,'style','pushbutton','string','Ok','units','norm','position',[.1,.01,.38,.15],'callback','set(gcbf,''userdata'',true); uiresume','fontsize',8+CONN_gui.font_offset);
                                    uicontrol(thfig,'style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.15],'callback','delete(gcbf)','fontsize',8+CONN_gui.font_offset);
                                    ht1b_tooltip={'<HTML>Defines binarization threshold <br/> - Original volumes are binarized by considering only suprathrehsold voxels with values above this threshold<br/> - e.g. use .5 to keep only voxels with >50% posterior probability from tissue probability maps</HTML>', '<HTML>Defines binarization threshold <br/> - Original volumes are binarized by considering only voxels above the given percentile value<br/> - e.g. use .5 to keep only voxels with posterior probability values above the median</HTML>'};
                                    ht2b_tooltip={'<HTML>Defines erosion kernel size <br/> - A value of N defines an erosion kernel with (2*N+1)^3 voxels <br/> - use 0 for no erosion <br/> - e.g. use 1 for a cubic 27-voxel kernel</HTML>','<HTML>Defines proportion of voxels kept (after erosion)<br/> - Kernel size will be adapted to keep approximately the chosen proportion of voxels : # voxels after erosion / # of voxels before erosion (after binarization threshold)<br/> - e.g. use 0.2 to keep approximately 20% of suprathreshold voxels after erosion (i.e. erode approximately 80% of voxels in original mask)</HTML>'};
                                    set([ht1 ht1b ht2 ht2b],'callback','uiresume');
                                    ok=true;
                                    while ok
                                        ok=ishandle(thfig);
                                        if ok,
                                            done=get(thfig,'userdata');
                                            if ~done
                                                val=get(ht1b,'value');
                                                set(ht1,'tooltipstring',ht1b_tooltip{val});
                                                if val==1, 
                                                else       set(ht1,'string',num2str(max(0,min(1,str2num(get(ht1,'string'))))));
                                                end
                                                val=get(ht2b,'value');
                                                set(ht2,'tooltipstring',ht2b_tooltip{val});
                                                if val==1, set(ht2,'string',num2str(round(str2num(get(ht2,'string'))))); set([ht3 ht3a],'visible','on');
                                                else       set(ht2,'string',num2str(max(.001,min(.999,str2num(get(ht2,'string')))))); set([ht3 ht3a],'visible','off');
                                                end
                                            else
                                                THR=str2num(get(ht1,'string'));
                                                THRTYPE=get(ht1b,'value');
                                                ERODE=str2num(get(ht2,'string'));
                                                NEIGHB=str2num(get(ht3,'string'));
                                                if numel(THR)==1, CONN_x.Setup.erosion.binary_threshold(nrois)=THR; CONN_x.Setup.erosion.binary_threshold_type(nrois)=THRTYPE; end
                                                if numel(ERODE)==1, CONN_x.Setup.erosion.erosion_steps(nrois)=ERODE; end
                                                if numel(NEIGHB)==1, CONN_x.Setup.erosion.erosion_neighb(nrois)=NEIGHB; end
                                                delete(thfig);
                                                answ=questdlg({'Do you wish to create thresholded/eroded masks now?'},'','Yes','Later','Yes');
                                                if ~isempty(answ)&&strcmp(answ,'Yes'),
                                                    nroisall=listdlg('liststring',CONN_x.Setup.rois.names(1:3),'selectionmode','multiple','initialvalue',nrois,'promptstring',{'Compute thresholded/eroded masks'},'ListSize',[200 100]);
                                                    if isempty(nroisall), return; end
                                                    nsubsall=listdlg('liststring',arrayfun(@(x)sprintf('Subject %d',x),1:CONN_x.Setup.nsubjects,'uni',0),'selectionmode','multiple','initialvalue',1:CONN_x.Setup.nsubjects,'promptstring',{'Select subjects'},'ListSize',[200 100]);
                                                    if isempty(nsubsall), return; end
                                                    hmsg=conn_msgbox('Updating masks... please wait','');
                                                    conn_maskserode(nsubsall,nroisall);
                                                    if ishandle(hmsg), delete(hmsg); end
                                                end
                                                ok=false;
                                            end
                                        end
                                        if ok, uiwait(thfig); end
                                    end
                                end
                                
                        end
                    end
					names=get(CONN_h.menus.m_setup_00{1},'string');
					nrois=get(CONN_h.menus.m_setup_00{1},'value');
                    if isempty(nrois), nrois=1; set(CONN_h.menus.m_setup_00{1},'value',1); end
                    nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                    nsess=get(CONN_h.menus.m_setup_00{16},'value');
					if ~isfield(CONN_x.Setup.rois,'dimensions') || length(CONN_x.Setup.rois.dimensions)<nrois, CONN_x.Setup.rois.dimensions{nrois}=1; end
					if ~isfield(CONN_x.Setup.rois,'mask') || length(CONN_x.Setup.rois.mask)<nrois, CONN_x.Setup.rois.mask(nrois)=0; end
					if ~isfield(CONN_x.Setup.rois,'subjectspecific') || length(CONN_x.Setup.rois.subjectspecific)<nrois, CONN_x.Setup.rois.subjectspecific(nrois)=0; end
					if ~isfield(CONN_x.Setup.rois,'sessionspecific') || length(CONN_x.Setup.rois.sessionspecific)<nrois, CONN_x.Setup.rois.sessionspecific(nrois)=0; end
					if ~isfield(CONN_x.Setup.rois,'multiplelabels') || length(CONN_x.Setup.rois.multiplelabels)<nrois, CONN_x.Setup.rois.multiplelabels(nrois)=0; end
					if ~isfield(CONN_x.Setup.rois,'regresscovariates') || length(CONN_x.Setup.rois.regresscovariates)<nrois, CONN_x.Setup.rois.regresscovariates(nrois)=double(CONN_x.Setup.rois.dimensions{nrois}>1); end
					if ~isfield(CONN_x.Setup.rois,'unsmoothedvolumes') || length(CONN_x.Setup.rois.unsmoothedvolumes)<nrois, CONN_x.Setup.rois.unsmoothedvolumes(nrois)=1; end
                    if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
                    else subjectspecific=1;
                    end
                    if ~subjectspecific, nsubs=1; end
                    if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
                    else sessionspecific=CONN_x.Setup.structural_sessionspecific;
                    end
                    if ~sessionspecific, nsess=1; end
                    nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                    for nsub=1:CONN_x.Setup.nsubjects
						if length(CONN_x.Setup.rois.files)<nsub, CONN_x.Setup.rois.files{nsub}={}; end
						if length(CONN_x.Setup.rois.files{nsub})<nrois, CONN_x.Setup.rois.files{nsub}{nrois}={}; end
                        for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub))
                            if length(CONN_x.Setup.rois.files{nsub}{nrois})<nses, CONN_x.Setup.rois.files{nsub}{nrois}{nses}={}; end
                            if length(CONN_x.Setup.rois.files{nsub}{nrois}{nses})<3, CONN_x.Setup.rois.files{nsub}{nrois}{nses}{3}=[]; end
                        end
                    end
					ok=1; ko=[];
                    for nsub=1:CONN_x.Setup.nsubjects
                        nsessall=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub));
                        if ~sessionspecific, nsessall=1; end
                        for nses=nsessall
                            if isempty(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}), ok=0; ko=[nsub nses]; break; end
                        end
                        if ~ok, break; end
                    end
                    conn_menumanager('helpstring','');
                    if ~ok, conn_menumanager('helpstring',sprintf('WARNING: incomplete information (enter ROI file for subject %d session %d)',ko(1),ko(2))); end
                    if ~sessionspecific, set([CONN_h.menus.m_setup_00{16}, CONN_h.menus.m_setup_00{15}],'visible','off');
                    else set([CONN_h.menus.m_setup_00{16}, CONN_h.menus.m_setup_00{15}],'visible','on');
                    end
                    if ~subjectspecific, set([CONN_h.menus.m_setup_00{2}, CONN_h.menus.m_setup_00{19}],'visible','off');
                    else set([CONN_h.menus.m_setup_00{2}, CONN_h.menus.m_setup_00{19}],'visible','on');
                    end
                    if ismember(nrois,[1,2,3]), set(CONN_h.menus.m_setup_00{21},'visible','on');
                    else set(CONN_h.menus.m_setup_00{21},'visible','off');
                    end
					if strcmp(names{nrois},' '), set(CONN_h.menus.m_setup_00{6},'string','enter ROI name here'); uicontrol(CONN_h.menus.m_setup_00{6}); conn_menumanager('helpstring','WARNING: incomplete information (enter valid ROI name)');
                    else set(CONN_h.menus.m_setup_00{6},'string',deblank(names{nrois}));
                    end
					set(CONN_h.menus.m_setup_00{7},'value',1*(CONN_x.Setup.rois.dimensions{nrois}==1)+2*(CONN_x.Setup.rois.dimensions{nrois}>1)+3*(CONN_x.Setup.rois.dimensions{nrois}==0));
					set(CONN_h.menus.m_setup_00{9},'value',CONN_x.Setup.rois.mask(nrois));
                    set(CONN_h.menus.m_setup_00{11},'value',sessionspecific);
                    set(CONN_h.menus.m_setup_00{18},'value',subjectspecific);
					set(CONN_h.menus.m_setup_00{10},'value',CONN_x.Setup.rois.multiplelabels(nrois));
					set(CONN_h.menus.m_setup_00{12},'value',CONN_x.Setup.rois.regresscovariates(nrois));
					set(CONN_h.menus.m_setup_00{13},'value',CONN_x.Setup.rois.unsmoothedvolumes(nrois)+1);
                    if CONN_x.Setup.rois.dimensions{nrois}<=1, set(CONN_h.menus.m_setup_00{20},'foregroundcolor',[.5 .5 .5]); else  set(CONN_h.menus.m_setup_00{20},'foregroundcolor',CONN_gui.fontcolorB); end
                    %if nrois<=3, set([CONN_h.menus.m_setup_00{6},CONN_h.menus.m_setup_00{9},CONN_h.menus.m_setup_00{10}],'visible','off');
                    %else  set(CONN_h.menus.m_setup_00{6},'visible','on','backgroundcolor','w','foregroundcolor','k'); set([CONN_h.menus.m_setup_00{9},CONN_h.menus.m_setup_00{10}],'visible','on'); end
                    set(CONN_h.menus.m_setup_00{6},'visible','on'); set([CONN_h.menus.m_setup_00{9},CONN_h.menus.m_setup_00{10}],'visible','on');
					ok=1; ko=[];
                    for n1=1:numel(nsubs)
                        nsub=nsubs(n1);
                        tnsess=intersect(nsess,1:nsessmax(n1));
                        for n2=1:length(tnsess)
                            nses=tnsess(n2);
                            if isempty(ko), ko=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1};
                            else  if ~all(size(ko)==size(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1})) || ~all(all(ko==CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1})), ok=0; end; end
                        end
                    end
                    if ~isempty(nsubs)&&~isempty(nrois)&&~isempty(nsess)&&nrois(1)<=numel(CONN_x.Setup.rois.files{nsubs(1)})&&nsess(1)<=numel(CONN_x.Setup.rois.files{nsubs(1)}{nrois(1)})&&isstruct(CONN_x.Setup.rois.files{nsubs(1)}{nrois(1)}{nsess(1)}{3}), set(CONN_h.menus.m_setup_00{14},'visible','on'); else set(CONN_h.menus.m_setup_00{14},'visible','off'); end
                    if isempty(nses)||isempty(nsubs)||isempty(nrois)||numel(CONN_x.Setup.rois.files{nsub}{nrois})<nses||isempty(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}),
						conn_menu('update',CONN_h.menus.m_setup_00{5},[]);
						set(CONN_h.menus.m_setup_00{4},'string','','tooltipstring','');
                    elseif ok,
                        if nrois<=3&&conn_existfile(conn_prepend('e',CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1})), vol=[CONN_x.Setup.rois.files{nsub}{nrois}{nses}{3} spm_vol(conn_prepend('e',CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}))];
                            CONN_h.menus.general.names=reshape({'Original volume','Thresholded/eroded volume'},[1,1,2]);
                        else vol=CONN_x.Setup.rois.files{nsub}{nrois}{nses}{3};
                            CONN_h.menus.general.names={};
                        end
						conn_menu('update',CONN_h.menus.m_setup_00{5},vol);
                        tempstr=cellstr(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1});
						set(CONN_h.menus.m_setup_00{4},'string',conn_cell2html(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{2}),'tooltipstring',conn_cell2html(tempstr));
					else  
						conn_menu('update',CONN_h.menus.m_setup_00{5},[]);
						set(CONN_h.menus.m_setup_00{4},'string','multiple files','tooltipstring','');
					end
                case 5, %conditions
                    boffset=[.03 .02 0 0];
                    if nargin<2,
                        conn_menu('nullstr',{'Display not','available'});
                        conn_menu('frame',boffset+[.19,.14,.62,.68],'Experiment conditions (within-subject effects)');
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.25,.075,.49],'Conditions','',['<HTML>Select condition <br/> - click after the last item to add a new condition <br/> - ',CONN_gui.rightclick,'-click for additional options</HTML>'],'conn(''gui_setup'',1);','conn(''gui_setup'',8);');
						CONN_h.menus.m_setup_00{2}=conn_menu('listbox',boffset+[.275,.25,.075,.49],'Subjects','','Select subject(s)','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('listbox',boffset+[.350,.25,.075,.49],'Sessions','','Select session(s)','conn(''gui_setup'',3);');
						CONN_h.menus.m_setup_00{6}=conn_menu('edit',boffset+[.48,.71,.08,.04],'Condition name','','Condition name','conn(''gui_setup'',6);');
                        str={'entire session','not present','specify blocks/events','---'};
						CONN_h.menus.m_setup_00{13}=conn_menu('popup',boffset+[.58,.71,.16,.04],'Interval',str,'<HTML>Defines condition interval for the selected subject(s) and session(s) <br/> - select <i>entire session</i> to indicate that this condition is present during the entire session (e.g. in <b>pure resting state design</b>)<br/> - select <i>not present</i> if the condition is not present in this session (e.g. in <b>pre- post- or repeated-measures resting state designs</b> the <i>pre</i> condition may be present <br/>only in <i>session1</i> while the <i>post</i> condition may be present only in <i>session2</i>) <br/> - select <i>specify blocks/events</i> to indicate that the condition is only present during portions of this session (e.g. in <b>block or event-related designs</b>) </HTML>','conn(''gui_setup'',13);');
						CONN_h.menus.m_setup_00{4}=[];[CONN_h.menus.m_setup_00{4}(1) CONN_h.menus.m_setup_00{4}(2)]=conn_menu('edit',boffset+[.58,.63,.08,.04],'Onset',[],'<HTML>onset time(s) marking the beginning of each block/event (in seconds) <b>for the selected condition(s)/subject(s)/session(s)</b><br/> - set <i>onset</i> to <b>0</b> and <i>duration</i> to <b>inf</b> to indicate that this condition is present during the entire session (e.g. resting state)<br/> - set <i>onset</i> and <i>duration</i> to <b>[]</b> (empty brackets) if the condition is not present in this session (e.g. pre- post- designs) <br/> - enter a series of block onsets if the condition is only present during a portion of this session (e.g. block designs)</HTML>','conn(''gui_setup'',4);');
						CONN_h.menus.m_setup_00{5}=[];[CONN_h.menus.m_setup_00{5}(1) CONN_h.menus.m_setup_00{5}(2)]=conn_menu('edit',boffset+[.66,.63,.08,.04],'Duration',[],'<HTML>duration(s) of condition blocks/events (in seconds) <b>for the selected condition(s)/subject(s)/session(s)</b><br/> - set <i>onset</i> to <b>0</b> and <i>duration</i> to <b>inf</b> to indicate that this condition is present during the entire session (e.g. resting state)<br/> - set <i>onset</i> and <i>duration</i> to <b>[]</b> (empty brackets) if the condition is not present in this session (e.g. pre- post- designs) <br/> - enter a series of block/event durations if the condition is only present during a portion of this session (e.g. block designs) <br/> or a single value if all blocks/events have the same duration</HTML>','conn(''gui_setup'',5);');
						CONN_h.menus.m_setup_00{12}=conn_menu('image',boffset+[.48,.42,.26,.15],'Experiment Design   (scans/sessions by conditions)','','',@conn_callbackdisplay_conditiondesign,@conn_callbackdisplay_conditiondesignclick);
						tmp=conn_menu('text',boffset+[.48,.30,.20,.04],'','Optional fields:');
                        set(tmp,'horizontalalignment','left','fontangle','normal','fontweight','normal','foregroundcolor',CONN_gui.fontcolorA);
                        analysistypes=[{'condition blocks/events'},cellfun(@(x)['condition blocks * covariate ''',x,''''],CONN_x.Setup.l1covariates.names(1:end-1),'uni',0)];
                        CONN_h.menus.m_setup_00{7}=conn_menu('popup',boffset+[.49,.22,.19,.05],'Task modulation factor',analysistypes,sprintf('optional condition-specific temporal modulation factor:\n  - for First-level analyses using a weighted GLM model (standard functional connectivity) this field has no effect\n  - for First-level analyses using a gPPI task-modulation model this field defines the condition-specific task-interaction factor\n (defaults to simple task effects; hrf-convolved condition blocks)'),'conn(''gui_setup'',7);');
                        CONN_h.menus.m_setup_00{10}=conn_menu('popup',boffset+[.49,.14,.19,.05],'Time-frequency decomposition',{'no decomposition','fixed band-pass filter','frequency decomposition (filter bank)','temporal decomposition (sliding-window)'},'<HTML>optional condition-specific frequency filter or time/frequency decompositions:<br/> - select <i>fixed band-pass filter</i> to define a condition-specific band-pass filter for the current condition (in addition to the filter specified during <i>Denoising</i> which applies to all conditions equally) <br/> - when selecting frequency- or temporal- decompositions, several new conditions will be automatically created during the Denoising step<br/> by partitioning the current condition in the frequency or temporal domains, respectively</HTML>','conn(''gui_setup'',10);');
                        CONN_h.menus.m_setup_00{11}=conn_menu('popup',boffset+[.68,.22,.12,.05],'Missing conditions',{'No missing data','Allow missing data'},'<HTML>Treatment of potential missing-conditions across some subjects: (this option applies to <b>all conditions)</b><br/> - If one condition is defined as <i>not present</i> (or its <i>onset</i> and <i>duration</i> fields are left empty) on <i>all</i> sessions of a given subject, that subject/condition''s condition-specific connectivity <br/> can not be computed. CONN treats this as ''missing data'' and the subject(s) with one missing condition will be automatically disregarded in all second-level analyses involving this condition <br/> - Select ''<i>No missing data</i>'' if no missing data should be expected. CONN will warn the user if a condition has been set as <i>not present</i> (or it has missing  <i>onset/duration</i> fields) in <i>all</i> of the sessions <br/> of any given subject (this check helps avoid accidentally entering incomplete condition information). <br/> - Select ''<i>Allow missing data</i>'' if missing data should be expected, and CONN will skip the above check (e.g. allowing attrition in longitudinal analyses)</HTML>','conn(''gui_setup'',11);');
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup',boffset+[.20,.14,.20,.05],'',{'<HTML><i> - condition tools:</i></HTML>','Merge selected conditions','Copy selected condition to covariates list','Move selected condition to covariates list','Import condition info from text file(s)'},'<HTML> - <i>merge conditions</i> combines all onsets/durations from multiple conditions into a single new condition<br/> - <i>copy to covariate list</i> creates a new first-level covariate containing the hrf-convolved condition effects<br/>  - <i>move to covariate list</i> deletes this condition and creates instead a new first-level covariate containing the hrf-convolved <br/> condition effects (e.g. for Fair et al. resting state analyses of task-related data)<br/> - <i>Import condition</i> imports condition names and onsets/durations values (for all subjects/sessions) from a text file<br/> Text file may be in CONN-legacy or BIDS format (see <i>help conn_importcondition</i> for file-format information</i>)</HTML>','conn(''gui_setup'',14);');
						set(CONN_h.menus.m_setup_00{3},'max',2);
						set(CONN_h.menus.m_setup_00{2},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2,'value',1:CONN_x.Setup.nsubjects);
						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names,'max',2);
                        nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{3},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{3},'value')));
                        hc1=uicontextmenu;uimenu(hc1,'Label','remove selected condition(s)','callback','conn(''gui_setup'',8);');
                        uimenu(hc1,'Label','replicate selected condition as a new condition','callback','conn(''gui_setup'',9,''replicate'');');
                        %uimenu(hc1,'Label','move selected condition to covariates list (for Fair et al. resting state analyses of task-related data)','callback','conn(''gui_setup'',9,''move'');');
                        %uimenu(hc1,'Label','copy selected condition to covariates list','callback','conn(''gui_setup'',9,''copy'');');
                        set(CONN_h.menus.m_setup_00{1},'uicontextmenu',hc1);
                        CONN_h.menus.m_setup_00{23}=uicontrol('style','frame','units','norm','position',boffset+[.45,.14,.35,.21],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA);
                        set(CONN_h.menus.m_setup_00{23},'visible','on'); conn_menumanager('onregion',CONN_h.menus.m_setup_00{23},-1,boffset+[.45,.14,.35,.41]);
                    else
                        switch(varargin{2}),
                            case 2, value=get(CONN_h.menus.m_setup_00{2},'value'); 
                                nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
                                set(CONN_h.menus.m_setup_00{3},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{3},'value')));
                            case 13,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								nsubs=get(CONN_h.menus.m_setup_00{2},'value');
								nsess=get(CONN_h.menus.m_setup_00{3},'value');
                                value=get(CONN_h.menus.m_setup_00{13},'value'); 
                                switch(value)
                                    case 1,
                                        for nsub=nsubs(:)', for nses=nsess(:)', for ncondition=nconditions(:)'
                                                    if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1}=0; CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=inf; end
                                                end; end; end
                                    case 2, 
                                        for nsub=nsubs(:)', for nses=nsess(:)', for ncondition=nconditions(:)'
                                                    if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1}=[]; CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=[]; end
                                                end; end; end
                                    case 3,
                                        for nsub=nsubs(:)', for nses=nsess(:)', for ncondition=nconditions(:)'
                                                    if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), 
                                                        if isequal(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2},[]), CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=zeros(0,1); end
                                                        if isinf(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}), CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=1e100; end
                                                    end
                                                end; end; end
                                end
							case 4,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								nsubs=get(CONN_h.menus.m_setup_00{2},'value');
								nsess=get(CONN_h.menus.m_setup_00{3},'value');
                                strvalue=get(CONN_h.menus.m_setup_00{4}(1),'string');
								value=str2num(strvalue);
                                if isempty(value), try value=evalin('base',strvalue); catch, value=[]; end; end
								if isempty(strvalue)||strcmp(strvalue,'[]')||~isempty(value),
									for nsub=nsubs(:)', for nses=nsess(:)', for ncondition=nconditions(:)'
											if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1}=value; end
									end; end; end
								end
							case 5,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								nsubs=get(CONN_h.menus.m_setup_00{2},'value');
								nsess=get(CONN_h.menus.m_setup_00{3},'value');
                                strvalue=get(CONN_h.menus.m_setup_00{5}(1),'string');
								value=str2num(strvalue);
                                if isempty(value), try value=evalin('base',strvalue); catch, value=[]; end; end
								if isempty(strvalue)||strcmp(strvalue,'[]')||~isempty(value),
									for nsub=nsubs(:)', for nses=nsess(:)', for ncondition=nconditions(:)'
											if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=value; end
									end; end; end
								end
							case 6,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								names=get(CONN_h.menus.m_setup_00{1},'string');
								name=fliplr(deblank(fliplr(deblank(get(CONN_h.menus.m_setup_00{6},'string')))));
								if ~isempty(deblank(name))&&isempty(strmatch(name,names,'exact')),
                                    [nill,isnew]=conn_conditionnames(name);
                                    if ~isnew
                                        answ=conn_questdlg({'This condition name has been used before and run through at least some of the processing steps.','Using this name will associate this condition with those already-processed data.','Do you want to proceed?'},'','Yes','No','No');
                                        isnew=isequal(answ,'Yes');
                                    end
                                    if isnew
                                        names{nconditions}=name;
                                        CONN_x.Setup.conditions.names{nconditions}=name;
                                        if nconditions==length(CONN_x.Setup.conditions.names),
                                            CONN_x.Setup.conditions.names{nconditions+1}=' ';
                                            names{nconditions+1}=' ';
                                            if length(CONN_x.Setup.conditions.param)<nconditions, CONN_x.Setup.conditions.param=[CONN_x.Setup.conditions.param, zeros(1,nconditions-length(CONN_x.Setup.conditions.param))]; end
                                            if length(CONN_x.Setup.conditions.filter)<nconditions, CONN_x.Setup.conditions.filter=[CONN_x.Setup.conditions.filter, cell(1,nconditions-length(CONN_x.Setup.conditions.filter))]; end
                                            for nsub=1:CONN_x.Setup.nsubjects,
                                                if length(CONN_x.Setup.conditions.values)<nsub, CONN_x.Setup.conditions.values{nsub}={}; end
                                                if length(CONN_x.Setup.conditions.values{nsub})<nconditions, CONN_x.Setup.conditions.values{nsub}{nconditions}={}; end
                                                for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                                    if length(CONN_x.Setup.conditions.values{nsub}{nconditions})<nses, CONN_x.Setup.conditions.values{nsub}{nconditions}{nses}={[]}; end
                                                    if length(CONN_x.Setup.conditions.values{nsub}{nconditions}{nses})<2, CONN_x.Setup.conditions.values{nsub}{nconditions}{nses}{2}=[]; end
                                                end
                                            end
                                        end
                                        set(CONN_h.menus.m_setup_00{1},'string',names);
                                    end
								end
							case 7,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								value=get(CONN_h.menus.m_setup_00{7},'value')-1;
                                CONN_x.Setup.conditions.param(nconditions)=value;
                            case 8,
								nconditions1=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nconditions0=length(CONN_x.Setup.conditions.names);
                                nconditions=setdiff(nconditions1,[nconditions0]);
                                %oldnames=CONN_x.Setup.conditions.names(nconditions);
                                %for n1=1:numel(oldnames), conn_conditionnames(oldnames{n1},'delete'); end 
                                nconditions=setdiff(1:nconditions0,nconditions);
                                CONN_x.Setup.conditions.names=CONN_x.Setup.conditions.names(nconditions);
                                nconditions=setdiff(nconditions,nconditions0);
                                for n1=1:length(CONN_x.Setup.conditions.values), CONN_x.Setup.conditions.values{n1}={CONN_x.Setup.conditions.values{n1}{nconditions}}; end
                                CONN_x.Setup.conditions.param=CONN_x.Setup.conditions.param(nconditions);
                                CONN_x.Setup.conditions.filter=CONN_x.Setup.conditions.filter(nconditions);
        						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names,'value',max(1,min(length(CONN_x.Setup.conditions.names)-1,max(nconditions1))));
                            case {9,14},
                                if varargin{2}==14
                                    tlvalue=get(CONN_h.menus.m_setup_00{14},'value');
                                    set(CONN_h.menus.m_setup_00{14},'value',1);
                                end
                                if varargin{2}==14&&tlvalue==5, 
                                    conn_importcondition;
                                    set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names);
                                else
                                    nconditions=get(CONN_h.menus.m_setup_00{1},'value');
                                    nconditions0=length(CONN_x.Setup.conditions.names);
                                    nconditions=setdiff(nconditions,[nconditions0]);
                                    if ~isempty(nconditions)
                                        if varargin{2}==14&&tlvalue==2, % merge
                                            if ~isempty(nconditions)
                                                CONN_x.Setup.conditions.names{nconditions0+1}=' ';
                                                if any(strcmp(CONN_x.Setup.conditions.names,'(merged)')), CONN_x.Setup.conditions.names{nconditions0}=strcat(CONN_x.Setup.conditions.names{nconditions});
                                                else CONN_x.Setup.conditions.names{nconditions0}='(merged)';
                                                end
                                                for n1sub=1:length(CONN_x.Setup.conditions.values), 
                                                    for n1ses=1:length(CONN_x.Setup.conditions.values{n1sub}{nconditions(1)}),
                                                        CONN_x.Setup.conditions.values{n1sub}{nconditions0}{n1ses}={[],[]};
                                                        for n2=1:numel(nconditions)
                                                            t1=CONN_x.Setup.conditions.values{n1sub}{nconditions(n2)}{n1ses}{1};
                                                            t2=CONN_x.Setup.conditions.values{n1sub}{nconditions(n2)}{n1ses}{2};
                                                            if numel(t2)==1, t2=t2+zeros(size(t1)); end
                                                            CONN_x.Setup.conditions.values{n1sub}{nconditions0}{n1ses}{1}=[CONN_x.Setup.conditions.values{n1sub}{nconditions0}{n1ses}{1},t1(:)'];
                                                            CONN_x.Setup.conditions.values{n1sub}{nconditions0}{n1ses}{2}=[CONN_x.Setup.conditions.values{n1sub}{nconditions0}{n1ses}{2},t2(:)'];
                                                        end
                                                        [CONN_x.Setup.conditions.values{n1sub}{nconditions0}{n1ses}{1},idx]=sort(CONN_x.Setup.conditions.values{n1sub}{nconditions0}{n1ses}{1});
                                                        CONN_x.Setup.conditions.values{n1sub}{nconditions0}{n1ses}{2}=CONN_x.Setup.conditions.values{n1sub}{nconditions0}{n1ses}{2}(idx);
                                                    end
                                                end
                                                CONN_x.Setup.conditions.param(nconditions0)=CONN_x.Setup.conditions.param(nconditions(1));
                                                CONN_x.Setup.conditions.filter{nconditions0}=CONN_x.Setup.conditions.filter{nconditions(1)};
                                                nconditions=nconditions0;
                                            end
                                        elseif nargin>=3&&isequal(varargin{3},'replicate')
                                            name=arrayfun(@(n)[CONN_x.Setup.conditions.names{n},' (copy)'],nconditions,'uni',0);
                                            CONN_x.Setup.conditions.names(nconditions0-1+(1:numel(nconditions)))=name;
                                            CONN_x.Setup.conditions.names{nconditions0-1+numel(nconditions)+1}=' ';
                                            nconditionsnew=[1:nconditions0-1 nconditions];
                                            for n1=1:length(CONN_x.Setup.conditions.values), CONN_x.Setup.conditions.values{n1}=CONN_x.Setup.conditions.values{n1}(nconditionsnew); end
                                            CONN_x.Setup.conditions.param=CONN_x.Setup.conditions.param(nconditionsnew);
                                            CONN_x.Setup.conditions.filter=CONN_x.Setup.conditions.filter(nconditionsnew);
                                        else
                                            if (varargin{2}==14&&tlvalue==3)||(nargin>=3&&isequal(varargin{3},'copy')), conn_convertcondition2covariate('-DONOTREMOVE',nconditions);
                                            elseif isequal(conn_questdlg({['This step will delete the selected conditions ',sprintf('%s ',CONN_x.Setup.conditions.names{nconditions})],'Do you want to proceed?'},'','Yes','No','Yes'),'Yes'), conn_convertcondition2covariate(nconditions); 
                                            end
                                        end
                                        set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names,'value',max(1,min(length(CONN_x.Setup.conditions.names)-1,max(nconditions))));
                                    end
                                end
                            case 10,
								nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
								value=get(CONN_h.menus.m_setup_00{10},'value');
                                switch(value)
                                    case 1, 
                                        [CONN_x.Setup.conditions.filter{nconditions}]=deal([]);
                                    case 2,
                                        if numel(CONN_x.Setup.conditions.filter{nconditions(1)})==2, answ={mat2str(CONN_x.Setup.conditions.filter{nconditions(1)})}; 
                                        else answ={'[.01 .10]'};
                                        end
                                        answ=inputdlg('Band-pass filter (Hz)','',1,answ);
                                        if numel(answ)==1&&numel(str2num(answ{1}))==2,
                                            [CONN_x.Setup.conditions.filter{nconditions}]=str2num(answ{1});
                                        end
                                    case 3,
                                        if numel(CONN_x.Setup.conditions.filter{nconditions(1)})==1, answ={num2str(CONN_x.Setup.conditions.filter{nconditions(1)})}; 
                                        else answ={'4'};
                                        end
                                        answ=inputdlg('Number of frequency bands','',1,answ);
                                        if numel(answ)==1,
                                            answ=str2num(answ{1});
                                            if numel(answ)==1&&answ>1, 
                                                [CONN_x.Setup.conditions.filter{nconditions}]=deal(answ); 
                                                answ=questdlg({'This will create additional conditions (one per frequency band)','Do you wish to create these conditions now?'},'','Yes','Later','Yes');
                                                if ~isempty(answ)&&strcmp(answ,'Yes'),conn_process('setup_conditionsdecomposition'); conn('gui_setup'); end
                                            end
                                        end
                                    case 4,
                                        if numel(CONN_x.Setup.conditions.filter{nconditions(1)})>2, answ={mat2str(CONN_x.Setup.conditions.filter{nconditions(1)}(2:end)),num2str(CONN_x.Setup.conditions.filter{nconditions(1)}(1))}; 
                                        else
                                            try
                                                maxscans=0;
                                                for nsub=1:CONN_x.Setup.nsubjects, 
                                                    for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                                        maxscans=max(maxscans,CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub))*CONN_x.Setup.nscans{nsub}{nses});
                                                    end
                                                end
                                                answ={mat2str(0:25:maxscans-100),'100'};
                                            catch
                                                answ={mat2str(0:25:200),'100'};
                                            end
                                        end
                                        answ=inputdlg({'Sliding-window onsets (in seconds relative to condition onset)','Sliding-window length (in seconds)'},'',1,answ);
                                        if numel(answ)==2,
                                            answ={str2num(answ{1}) str2num(answ{2})};
                                            if numel(answ)==2&&numel(answ{1})>1&&numel(answ{2})==1, 
                                                [CONN_x.Setup.conditions.filter{nconditions}]=deal([answ{2} answ{1}(:)']); 
                                                answ=conn_questdlg({'This will create additional conditions (one per sliding-window onset)','Do you wish to create these conditions now?'},'','Yes','Later','Yes');
                                                if ~isempty(answ)&&strcmp(answ,'Yes'),conn_process('setup_conditionsdecomposition'); conn('gui_setup'); end
                                            end
                                        end
                                end
                            case 11,
                                CONN_x.Setup.conditions.missingdata=get(CONN_h.menus.m_setup_00{11},'value')>1;
                        end
                    end
					names=get(CONN_h.menus.m_setup_00{1},'string');
					nconditions=get(CONN_h.menus.m_setup_00{1},'value'); 
                    if isempty(nconditions), nconditions=1; set(CONN_h.menus.m_setup_00{1},'value',1);  end
                    nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                    nsess=get(CONN_h.menus.m_setup_00{3},'value');
					if numel(nconditions)~=1, 
                        set([CONN_h.menus.m_setup_00{6} CONN_h.menus.m_setup_00{7} CONN_h.menus.m_setup_00{10}],'visible','off');
                    else
                        set([CONN_h.menus.m_setup_00{6} CONN_h.menus.m_setup_00{7} CONN_h.menus.m_setup_00{10}],'visible','on');
                        conn_menumanager('helpstring','');
                        if strcmp(names{nconditions},' '), set(CONN_h.menus.m_setup_00{6},'string','enter condition name here'); uicontrol(CONN_h.menus.m_setup_00{6}); conn_menumanager('helpstring','WARNING: incomplete information (enter valid condition name)');
                        else set(CONN_h.menus.m_setup_00{6},'string',deblank(names{nconditions}));
                        end
                    end
                    ok=[1,1]; ko={[],[]}; init=false;
                    if ~isempty(CONN_x.Setup.conditions.names{end})&&~strcmp(CONN_x.Setup.conditions.names{end},' '), CONN_x.Setup.conditions.names{end+1}=' '; set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.conditions.names); end
                    if length(CONN_x.Setup.conditions.param)<nconditions, CONN_x.Setup.conditions.param=[CONN_x.Setup.conditions.param, zeros(1,nconditions-length(CONN_x.Setup.conditions.param))]; end
                    if length(CONN_x.Setup.conditions.filter)<nconditions, CONN_x.Setup.conditions.filter=[CONN_x.Setup.conditions.filter, cell(1,nconditions-length(CONN_x.Setup.conditions.filter))]; end
                    for nsub=1:CONN_x.Setup.nsubjects,
                        if length(CONN_x.Setup.conditions.values)<nsub, CONN_x.Setup.conditions.values{nsub}={}; end
                        for ncondition=1:numel(CONN_x.Setup.conditions.names)-1
                            if length(CONN_x.Setup.conditions.values{nsub})<ncondition, CONN_x.Setup.conditions.values{nsub}{ncondition}={}; end
                            for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub)),
                                if length(CONN_x.Setup.conditions.values{nsub}{ncondition})<nses, CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}={[]}; end
                                if length(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses})<2, CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=[]; end
                            end
                        end
                    end
                    for nsub=nsubs(:)',
                        if length(CONN_x.Setup.conditions.values)<nsub, CONN_x.Setup.conditions.values{nsub}={}; end
                        for ncondition=nconditions(:)'
                            if length(CONN_x.Setup.conditions.values{nsub})<ncondition, CONN_x.Setup.conditions.values{nsub}{ncondition}={}; end
                        end
                        for ncondition=nconditions(:)'
                            for nses=nsess(:)',
                                if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                    if length(CONN_x.Setup.conditions.values{nsub}{ncondition})<nses, CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}={[]}; end
                                    if length(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses})<2, CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2}=[]; end
                                    if ~init, ko=CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}; init=true;
                                    else
                                        if ~all(size(ko{1})==size(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1})) || ~all(all(ko{1}==CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{1})), ok(1)=0; end;
                                        if ~all(size(ko{2})==size(CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2})) || ~all(all(ko{2}==CONN_x.Setup.conditions.values{nsub}{ncondition}{nses}{2})), ok(2)=0; end;
                                    end
                                end
                            end
                        end
                    end
                    if ok(1)&&ok(2)
                        if isequal(ko{1},0)&&isequal(ko{2},inf), set(CONN_h.menus.m_setup_00{13},'value',1); set([CONN_h.menus.m_setup_00{4} CONN_h.menus.m_setup_00{5}],'visible','off');
                        elseif isequal(ko{1},[])&&isequal(ko{2},[]), set(CONN_h.menus.m_setup_00{13},'value',2); set([CONN_h.menus.m_setup_00{4} CONN_h.menus.m_setup_00{5}],'visible','off');
                        else set(CONN_h.menus.m_setup_00{13},'value',3); set([CONN_h.menus.m_setup_00{4} CONN_h.menus.m_setup_00{5}],'visible','on');
                        end
                        set(CONN_h.menus.m_setup_00{13},'visible','on');
                    else set(CONN_h.menus.m_setup_00{13},'value',4,'visible','on');set([CONN_h.menus.m_setup_00{4} CONN_h.menus.m_setup_00{5}],'visible','on');
                    end
                    if ok(1), set(CONN_h.menus.m_setup_00{4}(1),'string',mat2str(ko{1})); else  set(CONN_h.menus.m_setup_00{4}(1),'string','MULTIPLE VALUES'); end
                    if ok(2), if isempty(ko{2}), ko{2}=[]; end; if ko{2}>=1e100, ko{2}=inf; end; set(CONN_h.menus.m_setup_00{5}(1),'string',mat2str(ko{2})); else  set(CONN_h.menus.m_setup_00{5}(1),'string','MULTIPLE VALUES'); end
                    if numel(nconditions)>=1, 
                        set(CONN_h.menus.m_setup_00{7},'value',CONN_x.Setup.conditions.param(nconditions(1))+1,'visible','on');
                        if numel(CONN_x.Setup.conditions.filter{nconditions(1)})==2, set(CONN_h.menus.m_setup_00{10},'value',2,'visible','on');
                        elseif numel(CONN_x.Setup.conditions.filter{nconditions(1)})==1, set(CONN_h.menus.m_setup_00{10},'value',3,'visible','on');
                        elseif numel(CONN_x.Setup.conditions.filter{nconditions(1)})>2, set(CONN_h.menus.m_setup_00{10},'value',4,'visible','on');
                        else set(CONN_h.menus.m_setup_00{10},'value',1,'visible','on');
                        end
                    else set([CONN_h.menus.m_setup_00{7},CONN_h.menus.m_setup_00{10}],'visible','off');
                    end
                    set(CONN_h.menus.m_setup_00{11},'value',1+(CONN_x.Setup.conditions.missingdata)); 
                    if numel(nsubs)>0,
                        tnsubs=nsubs(1);
                        out=conn_convertcondition2covariate('-DONOTAPPLYSUBJECTS',tnsubs,1:numel(CONN_x.Setup.conditions.names)-1);
                        x=[];xlscn=[];xlses=[];xlsub=[];xlcon=[];xlval=[];
                        for ncondition=1:numel(CONN_x.Setup.conditions.names)-1,
                            for nsub=tnsubs(:)',
                                tx=[];txlscn=[];txlses=[];txlsub=[];txlcon=[];txlval=[];
                                for nses=1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), 
                                    if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)),
                                        temp=max(0,out{nsub}{ncondition}{nses});
                                        temp2=conn_bsxfun(@rdivide,temp,max(1e-4,max(abs(temp))));
                                        tx=[tx; 129*(ismember(nses,nsess)&ismember(ncondition,nconditions))+64*temp2];
                                        txlscn=[txlscn; repmat((1:size(temp,1))',1,size(temp,2))];
                                        txlses=[txlses; repmat(nses,size(temp))];
                                        txlsub=[txlsub; repmat(nsub,size(temp))];
                                        txlcon=[txlcon; repmat(ncondition,size(temp))];
                                        txlval=[txlval; temp];
                                    end
                                end
                                xlscn=[[xlscn; nan(max(0,size(tx,1)-size(x,1)),size(x,2))] [txlscn; nan(max(0,size(x,1)-size(tx,1)),1)]];
                                xlses=[[xlses; nan(max(0,size(tx,1)-size(x,1)),size(x,2))] [txlses; nan(max(0,size(x,1)-size(tx,1)),1)]];
                                xlsub=[[xlsub; nan(max(0,size(tx,1)-size(x,1)),size(x,2))] [txlsub; nan(max(0,size(x,1)-size(tx,1)),1)]];
                                xlcon=[[xlcon; nan(max(0,size(tx,1)-size(x,1)),size(x,2))] [txlcon; nan(max(0,size(x,1)-size(tx,1)),1)]];
                                xlval=[[xlval; nan(max(0,size(tx,1)-size(x,1)),size(x,2))] [txlval; nan(max(0,size(x,1)-size(tx,1)),1)]];
                                x=[[x; nan(max(0,size(tx,1)-size(x,1)),size(x,2))] [tx; nan(max(0,size(x,1)-size(tx,1)),1)]];
                            end
                        end
                        x(isnan(x))=0;
                        conn_menu('updatematrix',CONN_h.menus.m_setup_00{12},ind2rgb(max(1,min(256,round(x)')),[gray(128);.05+.95*hot(128)]));
                        CONN_h.menus.m_setup_11e={xlscn xlses xlsub xlcon xlval};
                    else
                       conn_menu('updatematrix',CONN_h.menus.m_setup_00{12},[]);
                       CONN_h.menus.m_setup_11e={};
                    end
                    
				case 6, % covariates first-level
                    boffset=[.03 .02 0 0];
					if nargin<2,
						conn_menu('frame',boffset+[.19,.19,.48,.63],'First-level covariates (within-subject effects)');
                        conn_menu('nullstr',{'No covariate','file selected'});
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.28,.075,.46],'Covariates','',['<HTML>Select first-level covariate <br/> - click after the last item to add a new covariate <br/> - ',CONN_gui.rightclick,'-click for additional options</HTML>'],'conn(''gui_setup'',1);','conn(''gui_setup'',8);');
						CONN_h.menus.m_setup_00{2}=conn_menu('listbox',boffset+[.275,.28,.075,.46],'Subjects','','Select subject(s)','conn(''gui_setup'',2);');
						CONN_h.menus.m_setup_00{3}=conn_menu('listbox',boffset+[.350,.28,.075,.46],'Sessions','','Select session(s)','conn(''gui_setup'',3);');
						CONN_h.menus.m_setup_00{4}=conn_menu('filesearch',[],'Select covariate files','*.mat; *.txt; *.par','',{@conn,'gui_setup',4},'conn(''gui_setup'',5);');
						CONN_h.menus.m_setup_00{5}=conn_menu('pushbutton', boffset+[.45,.56,.20,.09],'','','','conn(''gui_setup'',5);');
						CONN_h.menus.m_setup_00{6}=conn_menu('image',boffset+[.455,.25,.20,.30]);
                        %set([CONN_h.menus.m_setup_00{5}],'visible','off'); conn_menumanager('onregion',[CONN_h.menus.m_setup_00{5}],1,boffset+[.435,.25,.23,.41]);
                        ht=uicontrol('style','frame','units','norm','position',boffset+[.435,.56,.23,.09],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA);
                        set(ht,'visible','on'); conn_menumanager('onregion',ht,-1,boffset+[.435,.25,.23,.41]);
                        %ht=uicontrol('style','frame','units','norm','position',[.78,.06,.20,.84],'foregroundcolor',CONN_gui.backgroundcolor,'backgroundcolor',CONN_gui.backgroundcolor);
                        %set(ht,'visible','on'); conn_menumanager('onregion',ht,-1,boffset+[.19,0,.81,1]);
						CONN_h.menus.m_setup_00{7}=conn_menu('edit',boffset+[.455,.71,.14,.04],'Covariate name','','First-level covariate name','conn(''gui_setup'',7);');
                        CONN_h.menus.m_setup_00{14}=conn_menu('popup',boffset+[.20,.19,.2,.05],'',{'<HTML><i> - covariate tools:</i></HTML>','Display covariate & single-slice functional (movie)','Compute summary measures','Reassign all covariate files simultaneously'},'<HTML> - <i>display covariate</i> displays covariate values together with corresponding single-slice BOLD volumes <br/> <HTML> - <i>compute summary measures</i> creates second-level covariates (subject-level measures) by aggregating the selected first-level covariate across scans&sessions<br/> - <i>reassign all covariate files simultaneously</i> reassigns files associated with the selected covariate using a user-generated search/replace filename rule</HTML>','conn(''gui_setup'',14);');
                        %CONN_h.menus.m_setup_00{14}=uicontrol('style','popupmenu','units','norm','position',boffset+[.455,.18,.14,.04],'string',{'<HTML><i> - options:</i></HTML>','subject-level aggreagate'},'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'fontsize',8+CONN_gui.font_offset,'callback','conn(''gui_setup'',14);','tooltipstring','First-level covariates additional options');
                        %CONN_h.menus.m_setup_00{9}=uicontrol('style','pushbutton','units','norm','position',boffset+[.455,.18,.14,.04],'string','subject-level aggregate','tooltipstring','Compute subject-level aggregated measures and create associated 2nd-level covariates','callback','conn(''gui_setup'',9);','fontsize',8+CONN_gui.font_offset);
						set(CONN_h.menus.m_setup_00{4}.files,'max',2);
						set(CONN_h.menus.m_setup_00{3},'max',2);
						set(CONN_h.menus.m_setup_00{2},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2);
						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.l1covariates.names,'max',1);
						nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_setup_00{3},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{3},'value')));
                        hc1=uicontextmenu;uimenu(hc1,'Label','remove selected covariate','callback','conn(''gui_setup'',8);');set(CONN_h.menus.m_setup_00{1},'uicontextmenu',hc1);
                        %hc1=uicontextmenu;uimenu(hc1,'Label','go to source folder','callback','conn(''gui_setup'',5);');set(CONN_h.menus.m_setup_00{5},'uicontextmenu',hc1);
					else
						switch(varargin{2}),
							case 2, value=get(CONN_h.menus.m_setup_00{2},'value'); 
								nsess=max(CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),value))); 
								set(CONN_h.menus.m_setup_00{3},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_setup_00{3},'value')));
							case 4,
								nl1covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
								nsubs=get(CONN_h.menus.m_setup_00{2},'value');
                                nsessall=get(CONN_h.menus.m_setup_00{3},'value'); 
                                nsessmax=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs));
                                nfields=sum(sum(conn_bsxfun(@le,nsessall(:),nsessmax(:)')));
								filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                                txt=''; bak1=CONN_x.Setup.l1covariates.files;
								if size(filename,1)==nfields,
                                    firstallsubjects=false;
                                    if numel(nsessall)>1&&numel(nsubs)>1
                                        opts={sprintf('First all subjects for session %d, followed by all subjects for session %d, etc.',nsessall(1),nsessall(2)),...
                                         sprintf('First all sessions for subject %d, followed by all sessions for subject %d, etc.',nsubs(1),nsubs(2))};
                                        answ=conn_questdlg('',sprintf('Order of files (%d files, %d subjects, %d sessions)',size(filename,1),numel(nsubs),numel(nsessall)),opts{[1,2,2]});
                                        if isempty(answ), return; end
                                        firstallsubjects=strcmp(answ,opts{1});
                                    end
                                    n0=0;
                                    if firstallsubjects
                                        for nses=nsessall,
                                            for n1=1:length(nsubs),
                                                if nses<=nsessmax(n1)
                                                    nsub=nsubs(n1);
                                                    n0=n0+1;
                                                    CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}=conn_file(deblank(filename(n0,:)));
                                                end
                                            end
                                        end
                                    else
                                        for n1=1:length(nsubs),
                                            nsub=nsubs(n1);
                                            for nses=intersect(nsessall,1:nsessmax(n1))
                                                n0=n0+1;
                                                CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}=conn_file(deblank(filename(n0,:)));
                                            end
                                        end
                                    end       
                                    txt=sprintf('%d files assigned to %d sessions x %d subjects\n',size(filename,1),length(nsessall),length(nsubs));
								elseif size(filename,1)==1,
                                    [V,str,icon,filename]=conn_getinfo(filename);
                                    for nsub=nsubs(:)', for nses=nsessall(:)',
                                            if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}={filename,str,icon}; end;
                                        end; end
                                    txt=sprintf('%d files assigned to %d sessions x %d subjects\n',size(filename,1),length(nsessall),length(nsubs));
								else 
									conn_msgbox(sprintf('mismatched number of files (%d files; %d sessions*subjects)',size(filename,1),numel(nfields)),'',2);
                                end
                                if ~isempty(txt)&&strcmp(conn_questdlg(txt,'','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.l1covariates.files=bak1;end
                            case 5,
								nl1covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
								nsubs=get(CONN_h.menus.m_setup_00{2},'value');
								nsess=get(CONN_h.menus.m_setup_00{3},'value');
                                if ~isempty(CONN_x.Setup.l1covariates.files{nsubs(1)}{nl1covariates(1)}{nsess(1)}{1})
                                    tempstr=cellstr(CONN_x.Setup.l1covariates.files{nsubs(1)}{nl1covariates(1)}{nsess(1)}{1});
                                    [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                                    tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                                    set(CONN_h.menus.m_setup_00{4}.selectfile,'string',unique(tempstr_name));
                                    set(CONN_h.menus.m_setup_00{4}.folder,'string',fileparts(tempstr{1}));
                                    conn_filesearchtool(CONN_h.menus.m_setup_00{4}.folder,[],'folder',true);
                                end
							case 7,
								nl1covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
								names=get(CONN_h.menus.m_setup_00{1},'string');
								name=fliplr(deblank(fliplr(deblank(get(CONN_h.menus.m_setup_00{7},'string')))));
								if isempty(strmatch(name,names,'exact')),
									names{nl1covariates}=name;
									CONN_x.Setup.l1covariates.names{nl1covariates}=name;
									if nl1covariates==length(CONN_x.Setup.l1covariates.names), CONN_x.Setup.l1covariates.names{nl1covariates+1}=' '; names{nl1covariates+1}=' '; end
									set(CONN_h.menus.m_setup_00{1},'string',names);
								end
                            case 8,
								nl1covariates1=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nl1covariates0=length(CONN_x.Setup.l1covariates.names);
                                nl1covariates=setdiff(nl1covariates1,[nl1covariates0]);
                                nl1covariates=setdiff(1:nl1covariates0,nl1covariates);
                                CONN_x.Setup.l1covariates.names={CONN_x.Setup.l1covariates.names{nl1covariates}};
                                nl1covariates=setdiff(nl1covariates,nl1covariates0);
                                for n1=1:length(CONN_x.Setup.l1covariates.files), CONN_x.Setup.l1covariates.files{n1}={CONN_x.Setup.l1covariates.files{n1}{nl1covariates}}; end
        						set(CONN_h.menus.m_setup_00{1},'string',CONN_x.Setup.l1covariates.names,'value',max(1,min(length(CONN_x.Setup.l1covariates.names)-1,max(nl1covariates1))));
                            case 14,
                                if numel(varargin)>=3, val=varargin{3};
                                else val=get(CONN_h.menus.m_setup_00{14},'value');
                                end
                                fh=[];
                                switch(val)
                                    case 2, % single-slice all timepoints
                                        if numel(varargin)>=4, nl1covariates=varargin{4};
                                        else nl1covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
                                            set(CONN_h.menus.m_setup_00{14},'value',1);
                                        end
                                        artts=isequal(nl1covariates,0);
                                        if artts, nl1covariates=[find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'scrubbing'),1) find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'QA_timeseries'),1)]; end
                                        if numel(varargin)>=5, nsubs=varargin{5};
                                        else nsubs=get(CONN_h.menus.m_setup_00{2},'value'); 
                                        end
                                        if numel(varargin)>=6, nsess=varargin{6};
                                        else nsess=get(CONN_h.menus.m_setup_00{3},'value'); 
                                        end
                                        if isempty(nsess), nsess=1:max(CONN_x.Setup.nsessions); end
                                        if numel(varargin)>=7, txyz=varargin{7}; dim=[1 1];
                                        else txyz=[]; dim=[1 1];
%                                             data=get(CONN_h.menus.m_setup_00{5}.h2,'userdata');
%                                             dim=data.buttondown.matdim.dim(1:2);
%                                             zslice=data.n;
%                                             [tx,ty]=ndgrid(1:dim(1),1:dim(2));
%                                             txyz=data.buttondown.matdim.mat*[tx(:) ty(:) zslice+zeros(numel(tx),1) ones(numel(tx),1)]';
                                        end
                                        if numel(varargin)>=8, nsets=varargin{8};
                                        else nsets=0;
                                            nsets=listdlg('liststring',arrayfun(@(n)sprintf('dataset %d',n),0:numel(CONN_x.Setup.roifunctional),'uni',0),'selectionmode','single','initialvalue',1,'promptstring',{'Select functional dataset for display'},'ListSize',[300 200]);
                                            if isempty(nsets), return; end
                                            nsets=nsets-1;
                                        end
                                        if numel(varargin)>=9, autoplay=varargin{9};
                                        else autoplay=true;
                                        end
                                        dispdata={};displabel={};covdata={};
                                        hmsg=conn_msgbox('Loading data... please wait','');
                                        for nsub=nsubs(:)'
                                            for nses=reshape(intersect(nsess,1:CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub))),1,[])
                                                Vsource=CONN_x.Setup.functional{nsub}{nses}{1};
                                                if isempty(Vsource), 
                                                    fprintf('Subject %d session %d data not found\n',nsub,nses);
                                                    dispdata{end+1}=nan(dim([2 1]));
                                                    displabel{end+1}=sprintf('Subject %d session %d',nsub,nses);
                                                else
                                                    for nset=nsets(:)'
                                                        if nset
                                                            try
                                                                if CONN_x.Setup.roifunctional(nset).roiextract==4
                                                                    VsourceUnsmoothed=cellstr(CONN_x.Setup.roifunctional(nset).roiextract_functional{nsub}{nses}{1});
                                                                else
                                                                    Vsource1=cellstr(Vsource);
                                                                    VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,CONN_x.Setup.roifunctional(nset).roiextract,CONN_x.Setup.roifunctional(nset).roiextract_rule);
                                                                end
                                                                existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                                                                if ~all(existunsmoothed),
                                                                    fprintf('warning: set-%d data for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nset,nsub,nses);
                                                                else
                                                                    Vsource=char(VsourceUnsmoothed);
                                                                end
                                                            catch
                                                                fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nsub,nses);
                                                            end
                                                        end
                                                        files=spm_vol(Vsource);
                                                        for nvol=1:numel(files)
                                                            if numel(txyz)<=1
                                                                dim=files(1).dim(1:2);
                                                                [tx,ty]=ndgrid(1:dim(1),1:dim(2));
                                                                if numel(txyz)==1, zslice=txyz;
                                                                else zslice=round(files(1).dim(3)/2);
                                                                end
                                                                txyz=files(1).mat*[tx(:) ty(:) zslice+zeros(numel(tx),1) ones(numel(tx),1)]';
                                                            end
                                                            dispdata{end+1}=fliplr(flipud(reshape(spm_get_data(files(nvol),pinv(files(nvol).mat)*txyz),dim(1:2))'));
                                                            displabel{end+1}=sprintf('Subject %d session %d volume %d dataset %d',nsub,nses,nvol,nset);
                                                        end
                                                        tdata=CONN_x.Setup.l1covariates.files{nsub}{nl1covariates(1)}{nses}{3};
                                                        if artts, 
                                                            tdata=sum(tdata,2);
                                                            if numel(nl1covariates)>1, tdata=cat(2,CONN_x.Setup.l1covariates.files{nsub}{nl1covariates(end)}{nses}{3},tdata);
                                                            else
                                                                [tnamepath,tnamename,tnameext]=fileparts(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1});
                                                                tname=fullfile(tnamepath,[regexprep(tnamename,'art_regression_outliers_(and_movement_)?','art_regression_timeseries_') tnameext]);
                                                                if conn_existfile(tname)
                                                                    tdata2=conn_file(tname);
                                                                    if ~isempty(tdata2), tdata=cat(2, abs(tdata2{3}),tdata); end
                                                                end
                                                            end
                                                        else 
                                                        end
                                                        if size(tdata,1)~=numel(files), 
                                                            fprintf('warning: unexpected number of samples in subject %d session %d covariate (expected %d, observed %d)\n',nsub,nses,numel(files),size(tdata,1));
                                                        else
                                                            covdata{end+1}=tdata;
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        ccovdata=[];
                                        for n=1:numel(covdata),
                                            if isempty(ccovdata), ccovdata=covdata{n};
                                            elseif size(ccovdata,2)<size(covdata{n},2), ccovdata=[ccovdata,zeros(size(ccovdata,1), size(covdata{n},2)-size(ccovdata,2)); covdata{n}];
                                            elseif size(ccovdata,2)>size(covdata{n},2), ccovdata=[ccovdata; covdata{n} zeros(size(covdata{n},1), size(ccovdata,2)-size(covdata{n},2))];
                                            else ccovdata=[ccovdata; covdata{n}];
                                            end
                                        end
                                        if artts, ccovdata_name={'GS changes','Movement','Outliers'};
                                        else ccovdata_name=CONN_x.Setup.l1covariates.names(nl1covariates);
                                        end
                                        fh=conn_montage_display(cat(4,dispdata{:}),displabel,'movie',ccovdata,ccovdata_name);
                                        fh('colormap','gray'); fh('colormap','darker');
                                        if ishandle(hmsg), delete(hmsg); end
                                        if autoplay, fh('start');
                                        else fh('style','moviereplay');
                                        end
                                        varargout={fh};
                                        return;
                                    case 3, % subject-level aggreagate
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nl1covariates=get(CONN_h.menus.m_setup_00{1},'value');
                                        conn_convertl12l2covariate(nl1covariates);
                                        return;
                                    case 4, % reassign
                                        set(CONN_h.menus.m_setup_00{14},'value',1);
                                        nl1covariates=get(CONN_h.menus.m_setup_00{1},'value');
                                        conn_rulebasedfilename(sprintf('l1covariate%d',nl1covariates(1)));
                                end
						end
					end
					names=get(CONN_h.menus.m_setup_00{1},'string');
					nl1covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
                    if isempty(nl1covariates), nl1covariates=1; set(CONN_h.menus.m_setup_00{1},'value',1);  end
					nsubs=get(CONN_h.menus.m_setup_00{2},'value');
					nsess=get(CONN_h.menus.m_setup_00{3},'value');
					for nsub=1:CONN_x.Setup.nsubjects,
						if length(CONN_x.Setup.l1covariates.files)<nsub, CONN_x.Setup.l1covariates.files{nsub}={}; end
						if length(CONN_x.Setup.l1covariates.files{nsub})<nl1covariates, CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}={}; end
						for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub)),
							if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), 
								if length(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates})<nses, CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}={}; end
								if length(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses})<3, CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{3}=[]; end
							end
						end
                    end
					ok=1; ko=[];
					for nsub=nsubs(:)',
						for nses=nsess(:)',
							if nses<=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)), 
								if isempty(ko), ko=CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1}; 
								elseif ~all(size(ko)==size(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1})) || ~all(all(ko==CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1})), ok=0; end; 
							end
						end
                    end
                    if isempty(nses)||isempty(nsubs)||numel(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates})<nses||isempty(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1})
						conn_menu('update',CONN_h.menus.m_setup_00{6},[]);
						set(CONN_h.menus.m_setup_00{5},'string','','tooltipstring','');
                        set(CONN_h.menus.m_setup_00{14},'visible','off'); 
                    elseif ok,
						conn_menu('updateplotstack',CONN_h.menus.m_setup_00{6},CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{3});
                        tempstr=cellstr(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1});
                        if isequal(tempstr,{'[raw values]'}), set(CONN_h.menus.m_setup_00{5},'string',conn_cell2html([{sprintf('[1 file] x [size %d %d]',size(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{3},1),size(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{3},2))},tempstr]),'tooltipstring',conn_cell2html(tempstr));
                        else set(CONN_h.menus.m_setup_00{5},'string',conn_cell2html(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{2}),'tooltipstring',conn_cell2html(tempstr));
                        end
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
					else  
						conn_menu('update',CONN_h.menus.m_setup_00{6},[]);
						set(CONN_h.menus.m_setup_00{5},'string','multiple files','tooltipstring','');
                        set(CONN_h.menus.m_setup_00{14},'visible','on'); 
                    end
					ok=1; ko=[];
                    for nsub=1:CONN_x.Setup.nsubjects
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            if isempty(CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}{1}), ok=0; ko=[nsub nses]; break; end
                        end
                        if ~ok, break; end
                    end
                    conn_menumanager('helpstring','');
                    if ~ok, conn_menumanager('helpstring',sprintf('WARNING: incomplete information (enter covariate file for subject %d session %d)',ko(1),ko(2))); end
                    if strcmp(names{nl1covariates},' '), set(CONN_h.menus.m_setup_00{7},'string','enter covariate name here'); uicontrol(CONN_h.menus.m_setup_00{7}); conn_menumanager('helpstring','WARNING: incomplete information (enter valid covariate name)');
                    else set(CONN_h.menus.m_setup_00{7},'string',deblank(names{nl1covariates}));
                    end
                    
                case 7, % covariates second-level
                    boffset=[.03 .02 0 0];
					if nargin<2,
						conn_menu('frame',boffset+[.19,.15,.48,.67],'Second-level covariates (between-subject effects)');
						CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.200,.25,.175,.49],'Covariates','',['<HTML>Select second-level covariate <br/> - click after the last item to add a new covariate <br/> - ',CONN_gui.rightclick,'-click for additional options</HTML>'],'conn(''gui_setup'',1);','conn(''gui_setup'',8);');
						CONN_h.menus.m_setup_00{3}=conn_menu('edit',boffset+[.43,.71,.22,.04],'Covariate name','','Second-level covariate name','conn(''gui_setup'',3);');
						[CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{4}]=conn_menu('edit0',boffset+[.43,.46,.22,.19],'Values',[],'<HTML>values of this covariate for each subject <br/> - enter one value per subject <br/> - for multiple covariates enter one row of values per covariate (separated by '';'') <br/> - you may also enter functions of other covariates (e.g. AllSubjects - Males)<br/> - other valid syntax include any valid Matlab command or variable name evaluated in the base workspace (e.g. rand)<br/> - note: changes to second-level covariates do not require re-running <i>Setup</i> and subsequent steps<br/> (they are directly available in the <i>second-level Results</i> tab)</HTML>','conn(''gui_setup'',2);');
                        CONN_h.menus.m_setup_00{11}=conn_menu('popup',boffset+[.20,.15,.20,.05],'',{'<HTML><i> - covariate tools:</i></HTML>','Orthogonalize selected covariate(s)','Import covariate data from file','Export covariate data to file'},'<HTML><i> - Orthogonalize</i> makes the selected covariate(s) orthogonal to other covariate(s) (e.g. for centering or when interested in the unique variance associated with this effect) <br/> - <i>Import</i> loads selected covariate values from a file (Text, Spreadsheet, or Matlab format)<br/> - <i>Export</i> saves selected covariate values to a file (Text, Spreadsheet, or Matlab format)</HTML>','conn(''gui_setup'',10+get(gcbo,''value''));');
                        %CONN_h.menus.m_setup_00{11}=conn_menu('pushbutton',boffset+[.4,.24,.05,.045],'','import','imports values from file','conn(''gui_setup'',11);');
                        %CONN_h.menus.m_setup_00{12}=conn_menu('pushbutton',boffset+[.45,.24,.05,.045],'','export','exports values to file','conn(''gui_setup'',12);');
                        %set([CONN_h.menus.m_setup_00{11},CONN_h.menus.m_setup_00{12}],'visible','off');%,'fontweight','bold');
                        %conn_menumanager('onregion',[CONN_h.menus.m_setup_00{11},CONN_h.menus.m_setup_00{12}],1,boffset+[.4,.24,.3,.41]);
                        CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.43,.29,.22,.15],'');
                        set(CONN_h.menus.m_setup_00{5}.h4,'marker','.');
						CONN_h.menus.m_setup_00{22}=conn_menu('edit',boffset+[.43,.18,.22,.04],'Description','','(optional) Second-level covariate description/comments','conn(''gui_setup'',22);');
                        set(CONN_h.menus.m_setup_00{2},'max',2,'userdata',CONN_h.menus.m_setup_00{4},'keypressfcn','if isequal(get(gcbf,''currentcharacter''),13), uicontrol(get(gcbo,''userdata'')); uicontrol(gcbo); end');
                        %CONN_h.menus.m_setup_00{9}=uicontrol('style','pushbutton','units','norm','position',boffset+[.4,.45,.2,.04],'string','Orthogonalize covariate','tooltipstring','Make this covariate orthogonal to other covariate(s) (e.g. for centering or when interested in the unique variance associated with this effect)','callback','conn(''gui_setup'',9);','fontsize',8+CONN_gui.font_offset);
						set(CONN_h.menus.m_setup_00{1},'string',conn_strexpand(CONN_x.Setup.l2covariates.names,CONN_x.Setup.l2covariates.descrip),'max',2);
                        hc1=uicontextmenu;
                        uimenu(hc1,'Label','remove selected covariate(s)','callback','conn(''gui_setup'',8);');
                        uimenu(hc1,'Label','move selected covariate(s) up','callback','conn(''gui_setup'',9,''up'');');
                        uimenu(hc1,'Label','move selected covariate(s) down','callback','conn(''gui_setup'',9,''down'');');
                        uimenu(hc1,'Label','move selected covariate(s) to the top','callback','conn(''gui_setup'',9,''top'');');
                        uimenu(hc1,'Label','move selected covariate(s) to the bottom','callback','conn(''gui_setup'',9,''bottom'');');
                        uimenu(hc1,'Label','move secondary covariates to the bottom','callback','conn(''gui_setup'',9,''secondary'');');
                        uimenu(hc1,'Label','sort covariates alphabetically','callback','conn(''gui_setup'',9,''sort'');');
                        %uimenu(hc1,'Label','orthogonalize selected covariate','callback','conn(''gui_setup'',9);');
                        set(CONN_h.menus.m_setup_00{1},'uicontextmenu',hc1);
                    else
                        set(CONN_h.menus.m_setup_00{11},'value',1);
						switch(varargin{2}),
							case {2,13},
								nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
                                tnewname={}; tnewdesc={};
                                if varargin{2}==13
                                    if numel(nl2covariates)==1, nl2covariates=numel(CONN_x.Setup.l2covariates.names); end
                                    [tfilename,tpathname]=uigetfile({'*.txt','text files (*.txt)'; '*.csv','CSV-files (*.csv)'; '*.mat','MAT-files (*.mat)'; '*',  'All Files (*)'},'Select data file');
                                    if ~ischar(tfilename)||isempty(tfilename), return; end
                                    tfilename=fullfile(tpathname,tfilename);
                                    [nill,tfilenam,tfileext]=fileparts(tfilename);
                                    tnewname={tfilenam};
                                    tnewdesc={sprintf('data imported from %s',tfilename)};
                                    switch(tfileext)
                                        case '.mat'
                                            tdata=load(tfilename,'-mat');
                                            tnames=fieldnames(tdata);
                                            if numel(tnames)==1, idata=1;
                                            else
                                                idata=find(strcmp(tnames,'data'));
                                                jdata=find(strcmp(tnames,'names'));
                                                kdata=find(strcmp(tnames,'descrip'));
                                                if numel(idata)~=1||numel(jdata)~=1||numel(kdata)~=1
                                                    idata=listdlg('liststring',tnames,'selectionmode','single','initialvalue',1,'promptstring','Select variable of interest:','ListSize',[300 200]);
                                                end
                                            end
                                            if isempty(idata), return; end
                                            tstring=tdata.(tnames{idata});
                                            if ~isempty(jdata), tnewname=tdata.(tnames{jdata}); end
                                            if ~isempty(kdata), tnewdesc=tdata.(tnames{kdata}); end
                                        otherwise,
                                            tstring=char(textread(tfilename,'%s','delimiter','\n','bufsize',4096*128));
                                            if size(tstring,1)>1&&isequal(find(cellfun('length',regexprep(cellstr(tstring),'[\d\.\,\-\s]',''))),1),
                                                if strcmp(tfileext,'.txt'), tnewname=regexp(deblank(tstring(1,:)),'\s+','split'); 
                                                else                        tnewname=regexp(deblank(tstring(1,:)),'\,+','split'); 
                                                end
                                                tstring=tstring(2:end,:);
                                            end
                                    end
                                else
                                    tstring=get(CONN_h.menus.m_setup_00{2},'string');
                                    tstring=cellstr(tstring);tstring=sprintf('%s;',tstring{:});
                                end
                                if ischar(tstring), value=str2num(tstring); else value=tstring; end
                                if isempty(value), 
                                    ok=0;
                                    for n1=1:3,
                                        try
                                            switch(n1)
                                                case 1, value=evalin('base',tstring);
                                                case 2,
                                                    x=cell2mat(cellfun(@double,cat(1,CONN_x.Setup.l2covariates.values{:}),'uni',0));
                                                    tnames=CONN_x.Setup.l2covariates.names(1:end-1);
                                                    [nill,idx]=sort(-cellfun('length',tnames));
                                                    for n1=idx(:)',
                                                        for n2=fliplr(strfind(tstring,tnames{n1}))
                                                            tstring=[tstring(1:n2-1) '(' mat2str(x(:,n1)') ')' tstring(n2+numel(tnames{n1}):end)];
                                                        end
                                                    end
                                                    value=evalin('base',tstring);
                                                case 3,
                                                    tstring=regexprep(tstring,'([^\.])(\*)|([^\.])(/)|([^\.])(\^)','$1.$2');
                                                    value=evalin('base',tstring);
                                            end
                                            ok=1;
                                        end
                                        if ok, break; end
                                    end
                                    if ~ok, 
                                        value=[]; 
                                        tstring0=get(CONN_h.menus.m_setup_00{2},'string');
                                        tstring0=cellstr(tstring0);tstring0=sprintf('%s;',tstring0{:});
                                        if isequal(tstring0,tstring), conn_msgbox(['Unable to interpret string ',tstring0(:)'],'',2); 
                                        else conn_msgbox({['Unable to interpret string ',tstring0],['Closest attempt (Matlab string) ',tstring]},'',2); 
                                        end
                                    end
                                end
                                value=double(value);
                                if size(value,2)==1&&size(value,1)==CONN_x.Setup.nsubjects&&numel(nl2covariates)==1, value=value.'; end
                                if size(value,2)~=CONN_x.Setup.nsubjects&&size(value,1)==CONN_x.Setup.nsubjects, value=value.'; end
								if (size(value,2)==CONN_x.Setup.nsubjects && (size(value,1)>1&&numel(nl2covariates)==1)),
                                    if numel(tnewname)~=size(value,1)
                                        if isempty(tnewname), tnewname=CONN_x.Setup.l2covariates.names(nl2covariates); end
                                        answ=conn_questdlg({sprintf('Entered array for multiple covariates (%d)',size(value,1)),sprintf('Do you want to expand selected covariate (%s) into multiple ones (%s to %s)?',tnewname{1},sprintf('%s_%d',tnewname{1},1),sprintf('%s_%d',tnewname{1},size(value,1)))},'','Yes','No','Yes');
                                        if ~isequal(answ,'Yes'), return; end
                                        tnewname=arrayfun(@(n)sprintf('%s_%d',tnewname{1},n),1:size(value,1),'uni',0);
                                    end
                                    nl2covariates0=nl2covariates;
                                    nl2covariates0_name=CONN_x.Setup.l2covariates.names{nl2covariates0};
                                    if nl2covariates0==numel(CONN_x.Setup.l2covariates.names)||(nl2covariates0==numel(CONN_x.Setup.l2covariates.names)-1&&isequal(CONN_x.Setup.l2covariates.names{nl2covariates0+1},' ')),
                                        nl2covariates=nl2covariates0+(0:size(value,1)-1);
                                    else
                                        nl2covariates=numel(CONN_x.Setup.l2covariates.names)+(0:size(value,1)-1);
                                    end
                                    for il2covariates=1:numel(nl2covariates)
                                        CONN_x.Setup.l2covariates.names{nl2covariates(il2covariates)}=tnewname{il2covariates}; %sprintf('%s_%d',nl2covariates0_name,il2covariates);
                                        if numel(tnewdesc)==numel(tnewname), CONN_x.Setup.l2covariates.descrip{nl2covariates(il2covariates)}=tnewdesc{il2covariates};
                                        else CONN_x.Setup.l2covariates.descrip{nl2covariates(il2covariates)}='';
                                        end
                                    end
                                    CONN_x.Setup.l2covariates.names{nl2covariates(end)+1}=' ';
                                    for nsub=1:CONN_x.Setup.nsubjects,
                                        for il2covariates=1:numel(nl2covariates)
                                            CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariates)}=value(min(size(value,1),il2covariates),min(size(value,2),nsub));
                                        end
                                    end
                                    set(CONN_h.menus.m_setup_00{1},'string',conn_strexpand(CONN_x.Setup.l2covariates.names,CONN_x.Setup.l2covariates.descrip),'value',nl2covariates);
                                elseif numel(value)==1 || (size(value,2)==CONN_x.Setup.nsubjects && (size(value,1)==1||size(value,1)==numel(nl2covariates))),
                                    for inl2covariates=nl2covariates(:)'
                                        if length(CONN_x.Setup.l2covariates.descrip)<inl2covariates, CONN_x.Setup.l2covariates.descrip{inl2covariates}=''; end
                                    end
									for nsub=1:CONN_x.Setup.nsubjects,
                                        for il2covariates=1:numel(nl2covariates)
                                            CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariates)}=value(min(size(value,1),il2covariates),min(size(value,2),nsub));
                                            if numel(nl2covariates)==1&&numel(tnewname)==1&&isempty(deblank(CONN_x.Setup.l2covariates.names{nl2covariates(il2covariates)})), 
                                                CONN_x.Setup.l2covariates.names{nl2covariates(il2covariates)}=tnewname{il2covariates}; %sprintf('%s_%d',nl2covariates0_name,il2covariates);
                                                if numel(tnewdesc)==numel(tnewname), CONN_x.Setup.l2covariates.descrip{nl2covariates(il2covariates)}=tnewdesc{il2covariates};
                                                else CONN_x.Setup.l2covariates.descrip{nl2covariates(il2covariates)}='';
                                                end
                                            end
                                            if nl2covariates(il2covariates)==numel(CONN_x.Setup.l2covariates.names), CONN_x.Setup.l2covariates.names{nl2covariates(il2covariates)+1}=' '; end
                                        end
                                    end
                                    set(CONN_h.menus.m_setup_00{1},'string',conn_strexpand(CONN_x.Setup.l2covariates.names,CONN_x.Setup.l2covariates.descrip),'value',nl2covariates);
                                elseif ~isempty(value), conn_msgbox(sprintf('Incorrect input string size (expected array size = [%dx%d]; entered array size = [%dx%d])',numel(nl2covariates),CONN_x.Setup.nsubjects,size(value,1),size(value,2)),'',2);
								end
							case 3,
								nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
								name=fliplr(deblank(fliplr(deblank(get(CONN_h.menus.m_setup_00{3},'string')))));
								if numel(nl2covariates)==1&&isempty(strmatch(name,CONN_x.Setup.l2covariates.names,'exact')),
									CONN_x.Setup.l2covariates.names{nl2covariates}=name;
									if nl2covariates==length(CONN_x.Setup.l2covariates.names), CONN_x.Setup.l2covariates.names{nl2covariates+1}=' '; end 
									set(CONN_h.menus.m_setup_00{1},'string',conn_strexpand(CONN_x.Setup.l2covariates.names,CONN_x.Setup.l2covariates.descrip));
								end
							case 22,
								nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
								name=fliplr(deblank(fliplr(deblank(get(CONN_h.menus.m_setup_00{22},'string')))));
                                if isempty(name)||any(name~='-')
                                    CONN_x.Setup.l2covariates.descrip(nl2covariates)=repmat({name},1,numel(nl2covariates));
                                    set(CONN_h.menus.m_setup_00{1},'string',conn_strexpand(CONN_x.Setup.l2covariates.names,CONN_x.Setup.l2covariates.descrip));
                                end
                            case 8,
								nl2covariates1=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nl2covariates0=length(CONN_x.Setup.l2covariates.names);
                                nl2covariates=setdiff(nl2covariates1,[nl2covariates0]);
                                nl2covariates=setdiff(1:nl2covariates0,nl2covariates);
                                CONN_x.Setup.l2covariates.names=CONN_x.Setup.l2covariates.names(nl2covariates);
                                nl2covariates=setdiff(nl2covariates,nl2covariates0);
                                CONN_x.Setup.l2covariates.descrip=CONN_x.Setup.l2covariates.descrip(nl2covariates);
                                for n1=1:length(CONN_x.Setup.l2covariates.values), CONN_x.Setup.l2covariates.values{n1}={CONN_x.Setup.l2covariates.values{n1}{nl2covariates}}; end
        						set(CONN_h.menus.m_setup_00{1},'string',conn_strexpand(CONN_x.Setup.l2covariates.names,CONN_x.Setup.l2covariates.descrip),'value',unique(max(1,min(length(CONN_x.Setup.l2covariates.names)-1,max(nl2covariates1)))));
                            case 9,
								nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
                                nl2covariates(nl2covariates>=numel(CONN_x.Setup.l2covariates.names))=[];
                                if isempty(nl2covariates), return; end
                                switch(varargin{3})
                                    case 'sort', [nill,inl2covariates]=sort(regexprep(CONN_x.Setup.l2covariates.names(1:end-1),'^_','~'));
                                    case 'up',   inl2covariates=1:numel(CONN_x.Setup.l2covariates.names)-1; inl2covariates(nl2covariates)=min(inl2covariates(nl2covariates))-1.5; [nill,inl2covariates]=sort(inl2covariates); 
                                    case 'down', inl2covariates=1:numel(CONN_x.Setup.l2covariates.names)-1; inl2covariates(nl2covariates)=max(inl2covariates(nl2covariates))+1.5; [nill,inl2covariates]=sort(inl2covariates); 
                                    case 'top',  inl2covariates=1:numel(CONN_x.Setup.l2covariates.names)-1; inl2covariates(nl2covariates)=(1:numel(nl2covariates))-numel(nl2covariates); [nill,inl2covariates]=sort(inl2covariates); 
                                    case 'bottom',  inl2covariates=1:numel(CONN_x.Setup.l2covariates.names)-1; inl2covariates(nl2covariates)=numel(inl2covariates)+(1:numel(nl2covariates)); [nill,inl2covariates]=sort(inl2covariates); 
                                    case 'secondary', [nill,inl2covariates]=sort(cellfun('length',regexp(CONN_x.Setup.l2covariates.names(1:end-1),'^_')));
                                end
                                CONN_x.Setup.l2covariates.names(1:numel(inl2covariates))=CONN_x.Setup.l2covariates.names(inl2covariates);
                                for n1=1:length(CONN_x.Setup.l2covariates.values), CONN_x.Setup.l2covariates.values{n1}=CONN_x.Setup.l2covariates.values{n1}(inl2covariates); end
                                CONN_x.Setup.l2covariates.descrip(1:numel(inl2covariates))=CONN_x.Setup.l2covariates.descrip(inl2covariates);
                                nl2covariates=unique(max(1,min(length(CONN_x.Setup.l2covariates.names)-1,find(ismember(inl2covariates,nl2covariates)))));
        						set(CONN_h.menus.m_setup_00{1},'string',conn_strexpand(CONN_x.Setup.l2covariates.names,CONN_x.Setup.l2covariates.descrip),'value',nl2covariates);
                            case 11,
                            case 12,
								nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
                                X=zeros(CONN_x.Setup.nsubjects,length(CONN_x.Setup.l2covariates.names)-1);
                                for nsub=1:CONN_x.Setup.nsubjects,
                                    for ncovariate=1:length(CONN_x.Setup.l2covariates.names)-1;
                                        X(nsub,ncovariate)=CONN_x.Setup.l2covariates.values{nsub}{ncovariate};
                                    end
                                end

                                nl2covariates_other=setdiff(1:length(CONN_x.Setup.l2covariates.names)-1,nl2covariates);
                                nl2covariates_subjects=1:CONN_x.Setup.nsubjects;
                                if ~isempty(nl2covariates_other)
                                %if numel(nl2covariates_other)>1
                                    thfig=dialog('units','norm','position',[.3,.3,.3,.3],'windowstyle','normal','name',['Orthogonalize covariate ',sprintf('%s ',CONN_x.Setup.l2covariates.names{nl2covariates})],'color','w','resize','on');
                                    uicontrol(thfig,'style','text','units','norm','position',[.1,.9,.8,.08],'string','Select orthogonal factors:','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
                                    ht1=uicontrol(thfig,'style','listbox','units','norm','position',[.1,.55,.8,.30],'max',2,'string',CONN_x.Setup.l2covariates.names(nl2covariates_other),'value',1:numel(nl2covariates_other),'fontsize',8+CONN_gui.font_offset);
                                    ht2=uicontrol(thfig,'style','checkbox','units','norm','position',[.1,.45,.8,.10],'value',0,'string','Apply only to non-zero values of covariate','backgroundcolor','w','fontsize',8+CONN_gui.font_offset);
                                    uicontrol(thfig,'style','text','units','norm','position',[.1,.35,.8,.08],'string','New values of covariate:','backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
                                    ht3=uicontrol(thfig,'style','edit','units','norm','position',[.1,.25,.8,.08],'string','','backgroundcolor',.9*[1 1 1],'fontsize',8+CONN_gui.font_offset);
                                    uicontrol(thfig,'style','pushbutton','string','Ok','units','norm','position',[.1,.01,.38,.10],'callback','uiresume','fontsize',8+CONN_gui.font_offset);
                                    uicontrol(thfig,'style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.10],'callback','delete(gcbf)','fontsize',8+CONN_gui.font_offset);
                                    set([ht1 ht2],'callback',@conn_orthogonalizemenuupdate);
                                    conn_orthogonalizemenuupdate;
                                    uiwait(thfig);
                                    ok=ishandle(thfig);
                                    if ok, 
                                        nl2covariates_other=nl2covariates_other(get(ht1,'value'));
                                        if get(ht2,'value'), nl2covariates_subjects=find(any(X(:,nl2covariates)~=0,2)&~any(isnan(X(:,nl2covariates)),2)&~any(isnan(X(:,nl2covariates_other)),2)); 
                                        else nl2covariates_subjects=find(~any(isnan(X(:,nl2covariates)),2)&~any(isnan(X(:,nl2covariates_other)),2)); 
                                        end
                                        delete(thfig);
                                    else nl2covariates_other=[];
                                    end
                                end
                                if ~isempty(nl2covariates_other)
                                    X(nl2covariates_subjects,nl2covariates)=X(nl2covariates_subjects,nl2covariates)-X(nl2covariates_subjects,nl2covariates_other)*(X(nl2covariates_subjects,nl2covariates_other)\X(nl2covariates_subjects,nl2covariates));
                                    for nsub=1:CONN_x.Setup.nsubjects,
                                        for ncovariate=nl2covariates(:)'
                                            CONN_x.Setup.l2covariates.values{nsub}{ncovariate}=X(nsub,ncovariate);
                                        end
                                    end
                                end
                            case 14
                                [tfilename,tpathname]=uiputfile({'*.txt','text files (*.txt)'; '*.csv','CSV-files (*.csv)'; '*.mat','MAT-files (*.mat)'; '*',  'All Files (*)'},'Output data to file:');
                                if ~ischar(tfilename)||isempty(tfilename), return; end
                                tfilename=fullfile(tpathname,tfilename);
                                [nill,nill,tfileext]=fileparts(tfilename);
                                nl2covariates=get(CONN_h.menus.m_setup_00{1},'value');
                                nl2covariates(nl2covariates==numel(CONN_x.Setup.l2covariates.names))=[];
                                tt=[];
                                for il2covariate=1:numel(nl2covariates),
                                    if length(CONN_x.Setup.l2covariates.descrip)<nl2covariates(il2covariate), CONN_x.Setup.l2covariates.descrip{nl2covariates(il2covariate)}=''; end
                                    t=[];
                                    for nsub=1:CONN_x.Setup.nsubjects,
                                        if length(CONN_x.Setup.l2covariates.values)<nsub, CONN_x.Setup.l2covariates.values{nsub}={}; end
                                        if length(CONN_x.Setup.l2covariates.values{nsub})<nl2covariates(il2covariate), CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariate)}=0; end
                                        t=cat(2,t,CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariate)});
                                    end
                                    tt=cat(1,tt,t);
                                end
                                names=CONN_x.Setup.l2covariates.names(nl2covariates);
                                descrip=CONN_x.Setup.l2covariates.descrip(nl2covariates);
                                switch(tfileext)
                                    case '.mat'
                                        data=tt.';
                                        save(tfilename,'data','names','descrip');
                                    otherwise,
                                        if strcmp(tfileext,'.txt'), names=regexprep(names,'\s',''); 
                                        else                        names=regexprep(names,'\,',''); 
                                        end
                                        fh=fopen(tfilename,'wt');
                                        for n1=1:numel(names),
                                            if isempty(names{n1}), names{n1}='-'; end
                                            fprintf(fh,'%s',names{n1}); 
                                            if n1<numel(names)&&strcmp(tfileext,'.csv'), fprintf(fh,','); elseif n1<numel(names), fprintf(fh,' '); else fprintf(fh,'\n'); end
                                        end
                                        for n2=1:size(tt,2),
                                            for n1=1:size(tt,1),
                                                fprintf(fh,'%f',tt(n1,n2));
                                                if n1<size(tt,1)&&strcmp(tfileext,'.csv'), fprintf(fh,','); elseif n1<size(tt,1), fprintf(fh,' '); else fprintf(fh,'\n'); end
                                            end
                                        end
                                        fclose(fh);
                                end
                                conn_msgbox({'Data saved to file',tfilename},'',true);
                                return;
                        end
					end
					names=CONN_x.Setup.l2covariates.names; %get(CONN_h.menus.m_setup_00{1},'string');
					nl2covariates=get(CONN_h.menus.m_setup_00{1},'value'); 
                    tt=[];
                    for il2covariate=1:numel(nl2covariates),
                        if length(CONN_x.Setup.l2covariates.descrip)<nl2covariates(il2covariate), CONN_x.Setup.l2covariates.descrip{nl2covariates(il2covariate)}=''; end
                        t=[];
                        for nsub=1:CONN_x.Setup.nsubjects,
                            if length(CONN_x.Setup.l2covariates.values)<nsub, CONN_x.Setup.l2covariates.values{nsub}={}; end
                            if length(CONN_x.Setup.l2covariates.values{nsub})<nl2covariates(il2covariate), CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariate)}=0; end
                            t=cat(2,t,CONN_x.Setup.l2covariates.values{nsub}{nl2covariates(il2covariate)});
                        end
                        tt=cat(1,tt,t);
                    end
                    if numel(nl2covariates)==1
                        set(CONN_h.menus.m_setup_00{3},'visible','on');
                        conn_menumanager('helpstring','');
                        if strcmp(names{nl2covariates},' '), set(CONN_h.menus.m_setup_00{3},'string','enter covariate name here'); uicontrol(CONN_h.menus.m_setup_00{3}); conn_menumanager('helpstring','WARNING: incomplete information (enter valid covariate name)');
                        else set(CONN_h.menus.m_setup_00{3},'string',deblank(names{nl2covariates}));
                        end
                        tstr=CONN_x.Setup.l2covariates.descrip{nl2covariates};
                        if isempty(tstr), tstr='--'; end
                        set(CONN_h.menus.m_setup_00{22},'string',tstr,'visible','on');
                    else
                        set([CONN_h.menus.m_setup_00{3} CONN_h.menus.m_setup_00{22}],'visible','off')
                    end
                    set(CONN_h.menus.m_setup_00{2},'string',mat2str(tt,max([0,ceil(log10(max(1e-10,abs(tt(:)'))))])+6));
                    set(CONN_h.menus.m_setup_00{11},'value',1);
                    conn_menu('updateplotsingle',CONN_h.menus.m_setup_00{5},tt');
                    %if size(tt,1)>1, conn_menu('updateplotsingle',CONN_h.menus.m_setup_00{5},tt');
                    %else conn_menu('update',CONN_h.menus.m_setup_00{5},tt');
                    %end
                    %k=t; for n=0:6, if abs(round(k)-k)<1e-6, break; end; k=k*10; end;
                    %set(CONN_h.menus.m_setup_00{2},'string',num2str(t,['%0.',num2str(n),'f ']));
                    %if numel(CONN_x.Setup.l2covariates.names)<=1+numel(nl2covariates), set(CONN_h.menus.m_setup_00{9},'visible','off'); else set(CONN_h.menus.m_setup_00{9},'visible','on'); end
                    
                case 8, % options
                    boffset=[.05 -.025 0 0];
                    if nargin<2,
                        conn_menu('frame',boffset+[.19,.20,.57,.65],'Processing options');
                        analysistypes={'ROI-to-ROI','Seed-to-Voxel','Voxel-to-Voxel','Dynamic Circuits'};
                        CONN_h.menus.m_setup_00{1}=conn_menu('checkbox0',boffset+[.2,.75,.25,.04],'Enabled analyses',analysistypes,{'Enable ROI-to-ROI analyses','Enable Seed-to-Voxel analyses','Enable Voxel-to-Voxel analyses','Enable dynamic connectivity analyses'},'conn(''gui_setup'',1);');
                        values=CONN_x.Setup.steps;
                        for n1=1:numel(values),set(CONN_h.menus.m_setup_00{1}(n1),'value',values(n1)>0);end
                        analysistypes={'Volume: same as mask (default 2mm voxels)','Volume: same as structurals','Volume: same as functionals','Surface: same as template (Freesurfer fsaverage)'};
                        CONN_h.menus.m_setup_00{2}=conn_menu('popup',boffset+[.2,.5,.25,.05],'Analysis space (voxel-level)',analysistypes,'<HTML>Choose analysis space <br/> - for <i>volume-based</i> analyses this option defines the dimensionality (bounding box) and spatial resolution (voxel size) of the analyses <br/> - select <i>surface-based</i> for analyses on the cortical surface (this requires selecting FreeSurfer-generated structural files in Setup->Structurals)</HTML>','conn(''gui_setup'',2);');
                        set(CONN_h.menus.m_setup_00{2},'value',CONN_x.Setup.spatialresolution);
                        analysistypes={'Explicit mask ','Implicit mask (subject-specific)'};
                        [nill,tfilename,tfilename_ext]=fileparts(CONN_x.Setup.explicitmask{1});
                        analysistypes{1}=[analysistypes{1},'(',tfilename,tfilename_ext,')'];
                        CONN_h.menus.m_setup_00{3}=conn_menu('popup',boffset+[.2,.4,.25,.05],'Analysis mask (voxel-level)',analysistypes,'<HTML>Choose analysis mask for voxel-based analyses <br/> - select <i>explicit mask</i> for user-defined analysis mask (defaults to MNI-space brainmask for volume-based analyses or fsaverage cortical mask for surface-based analyses) <br/> - select <i>implicit mask</i> to use subject-specific brainmasks derived from global BOLD signal amplitude</HTML>','conn(''gui_setup'',3);');
                        analysistypes={'Parametric and non-parametric analyses','Only parametric statistics, univariate models (RFT/SPM)','Only non-parametric statistics, multivariate models (permutation tests)'};
                        CONN_h.menus.m_setup_00{6}=conn_menu('popup',boffset+[.2,.3,.35,.05],'Second-level analyses (voxel-level)',analysistypes,'<HTML>Choose type of second-level voxel-level analyses<br/> <i> - parametric statistics, univariate model</i> uses parametric distributions (Random Field Theory) for cluster-level statistics, assumes<br/>similar between-conditions or between-sources covariance across voxels (equal up to scaling factor; estimated using SPM''s ReML) and <br/> similar spatial covariance across voxels (equal up to scaling factor; estimated using SPM''s residual smoothness estimation) . The analysis <br/>results can be exported to SPM software<br/> - <i>non-parametric statistics, multivariate model</i> uses non-parametric analyses (residual permutation/randomization tests) for cluster level <br/>statistics, and multivariate between-conditions or between-sources covariance estimation (multivariate analyses separately for each voxel).<br/> This provides additional control in cases where the assumptions of RFT might not be met, but the statistics will take longer to compute and<br/> the results cannot be exported to SPM software<br/> - <i>Parametric and non-parametric analyses</i> will perform both types of analyses (in the second-level <i>results explorer</i> window switch between the <i>parametric</i> and <i>non-parametric</i> options<br/> to explore both results</HTML>','conn(''gui_setup'',6);');
                        analysistypes={'PSC (percent signal change)','Raw'};
                        CONN_h.menus.m_setup_00{5}=conn_menu('popup',boffset+[.2,.2,.25,.05],'BOLD signal units',analysistypes,'Choose BOLD signal units for analyses','conn(''gui_setup'',5);');
                        %set(CONN_h.menus.m_setup_00{11},'value',CONN_x.Setup.crop);
                        set(CONN_h.menus.m_setup_00{3},'value',CONN_x.Setup.analysismask);
                        set(CONN_h.menus.m_setup_00{5},'value',CONN_x.Setup.analysisunits);
                        set(CONN_h.menus.m_setup_00{6},'value',CONN_x.Setup.secondlevelanalyses);
                        analysistypes={'Create confound effects beta-maps','Create confound-corrected time-series','Create first-level seed-to-voxel r-maps','Create first-level seed-to-voxel p-maps','Create first-level seed-to-voxel FDR-p maps','Create ROI-extraction REX files'};
                        CONN_h.menus.m_setup_00{4}=conn_menu('checkbox0',boffset+[.5,.75,.25,.04],'Optional output files',analysistypes,'Choose optional output files to be generated during the analyses','conn(''gui_setup'',4);');
                        for n1=1:numel(analysistypes),set(CONN_h.menus.m_setup_00{4}(n1),'value',CONN_x.Setup.outputfiles(n1));end
                    else
                        switch(varargin{2}),
                            case 1, 
                                for n1=1:4,value=get(CONN_h.menus.m_setup_00{1}(n1),'value');CONN_x.Setup.steps(n1)=value; end
                            case 2, 
                                value=get(CONN_h.menus.m_setup_00{2},'value'); CONN_x.Setup.spatialresolution=value;
                                if CONN_x.Setup.spatialresolution==4
                                    answ=inputdlg({'BOLD signal surface-based smoothing level (number of diffusion steps)'},'Surface-based analysis options',1,{num2str(CONN_x.Setup.surfacesmoothing)});
                                    if ~isempty(answ)
                                        if ~isempty(str2num(answ{1}))
                                            CONN_x.Setup.surfacesmoothing=max(0,str2num(answ{1}));
                                        end
                                    end
                                end
							case 3, value=get(CONN_h.menus.m_setup_00{3},'value'); CONN_x.Setup.analysismask=value;
                                if value==1
                                    [tfilename,tpathname]=uigetfile('*.nii; *.img','Select explicit mask',CONN_x.Setup.explicitmask{1});
                                    if ischar(tfilename),
                                        CONN_x.Setup.explicitmask=conn_file(fullfile(tpathname,tfilename)); 
                                        analysistypes={'Explicit mask ','Implicit mask (subject-specific)'};
                                        [nill,tfilename,tfilename_ext]=fileparts(CONN_x.Setup.explicitmask{1});
                                        analysistypes{1}=[analysistypes{1},'(',tfilename,tfilename_ext,')'];
                                        set(CONN_h.menus.m_setup_00{3},'string',analysistypes);
                                    end
                                end
                            case 4, for n1=1:numel(CONN_h.menus.m_setup_00{4}),value=get(CONN_h.menus.m_setup_00{4}(n1),'value');CONN_x.Setup.outputfiles(n1)=value; end
							case 5, value=get(CONN_h.menus.m_setup_00{5},'value'); CONN_x.Setup.analysisunits=value;
							case 6, value=get(CONN_h.menus.m_setup_00{6},'value'); CONN_x.Setup.secondlevelanalyses=value;
                        end
                    end
                    if ~any(CONN_x.Setup.steps(1:2)), CONN_x.Setup.steps(4)=0; end
                    if any(CONN_x.Setup.steps([2,3])), set([CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{3},CONN_h.menus.m_setup_00{4},CONN_h.menus.m_setup_00{6}],'visible','on'); else set([CONN_h.menus.m_setup_00{2},CONN_h.menus.m_setup_00{3},CONN_h.menus.m_setup_00{4}(1:end-1),CONN_h.menus.m_setup_00{6}],'visible','off'); end
                    if any(CONN_x.Setup.steps(2)), set(CONN_h.menus.m_setup_00{4}(3:5),'visible','on'); else set(CONN_h.menus.m_setup_00{4}(3:5),'visible','off'); end
                    if any(CONN_x.Setup.steps(1)), set(CONN_h.menus.m_setup_00{4}(6),'visible','on'); else set(CONN_h.menus.m_setup_00{4}(6),'visible','off'); end
                    if any(CONN_x.Setup.steps([1,2])), set([CONN_h.menus.m_setup_00{1}(4)],'visible','on'); else set([CONN_h.menus.m_setup_00{1}(4)],'visible','off'); end
                    if any(CONN_x.Setup.steps), set([CONN_h.menus.m_setup_00{5}],'visible','on'); else set([CONN_h.menus.m_setup_00{5}],'visible','off'); end
                    if CONN_x.Setup.spatialresolution==4, set(CONN_h.menus.m_setup_00{6},'visible','off'); end
                    
			end
% 		case 'gui_setup_covariates',
% 			state=conn_menumanager(CONN_h.menus.m_setup_02,'state');state=0*state;state(6)=1;conn_menumanager(CONN_h.menus.m_setup_02,'state',state,'on',1);	
% 			state=find(conn_menumanager(CONN_h.menus.m_setup_03,'state'));
%             if nargin<2,
%                 conn_menumanager clf;
%                 conn_menuframe;
% 				conn_menumanager([CONN_h.menus.m_setup_02,CONN_h.menus.m_setup_01d,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
%             end
% 			if isempty(state) return; end
%             boffset=[0 0 0 0];
% 			switch(state),
% 				case 1, % first-level covariates
% 
%                     
% 				case 2, %Covariates (L2)
% 			end

		case 'gui_setup_load',
            [filename,pathname]=uigetfile({'*.mat','conn-project files (conn_*.mat)';'*','All Files (*)'},'Loads CONN project','conn_*.mat');
            %[filename,pathname]=uigetfile({'conn_*.mat','conn-project files (conn_*.mat)'},'Loads CONN project');
			if ischar(filename),
				filename=fullfile(pathname,filename);
                ht=conn_msgbox('Loading project file. Please wait...');
                fprintf('Loading project file. Please wait...');
                conn('load',filename,true);
                fprintf(' Done\n');
                if ishandle(ht), delete(ht); end
% 				try, load(filename,'CONN_x'); CONN_x.filename=filename; catch, waitfor(errordlg(['Failed to load file ',filename,'.'],mfilename)); return; end
%                 try, conn_updatefilepaths; end
%                 CONN_x.filename=filename;
%                 conn_updatefolders;
			end
            conn gui_setup;
			
		case {'gui_setup_save','gui_setup_saveas','gui_setup_saveas_nowarning'},
            saveas=false;
            if strcmp(varargin{1},'gui_setup_saveas')
                answ=conn_questdlg({'Warning: Using ''save as'' will create a copy of the current project with all','of the current project definitions but NONE of the analyses performed until now.','Do you wish to continue?'}, 'conn','Stop','Continue','Continue');
                if ~strcmp(answ,'Continue'), return; end
                saveas=true;
            end
            if nargin<2||isempty(varargin{2}), strmsg='Save CONN project'; else strmsg=varargin{2}; end
			if strcmp(varargin{1},'gui_setup_saveas') || strcmp(varargin{1},'gui_setup_saveas_nowarning') || isempty(CONN_x.filename) || ~ischar(CONN_x.filename), if isempty(CONN_x.filename)||~ischar(CONN_x.filename), filename='conn_project01.mat'; else  filename=CONN_x.filename; end; [filename,pathname]=uiputfile('conn_*.mat',strmsg,filename); saveas=true;
			else pathname='';filename=CONN_x.filename; end
			if ischar(filename), 
                if saveas, CONN_x.isready=[1 0 0 0]; end
                set(CONN_h.screen.hfig,'pointer','watch');
				filename=fullfile(pathname,filename);
                fprintf('Saving file. Please wait...');
                conn('save',filename);
                fprintf(' Done\n');
				set(CONN_h.screen.hfig,'pointer','arrow');
            end
            if saveas, conn gui_setup; end

        case 'gui_setup_close'
            if ~CONN_x.isready(1), Answ='Proceed';
            else Answ=conn_questdlg({'Proceeding will close the current project and loose any unsaved progress','Do you want to proceed with closing this project?'},'Close project','Proceed','Cancel','Proceed');
            end
            if strcmp(Answ,'Proceed'),
                conn init;
                conn importrois;
                conn gui_setup
            end
            
        case 'gui_setup_new',
            if ~CONN_x.isready(1), Answ='Proceed';
            else Answ=conn_questdlg({'Proceeding will close the current project and loose any unsaved progress','Do you want to proceed with creating a new project?'},'New project','Proceed','Cancel','Proceed');
            end
            if strcmp(Answ,'Proceed')
                conn init;
                conn importrois;
                %conn gui_setup;
                conn('gui_setup_save','Enter new CONN project filename:');
            end
            
        case 'gui_setup_wizard'
            if ~CONN_x.isready(1), Answ='Proceed';
            else Answ=conn_questdlg({'Proceeding will close the current project and loose any unsaved progress','Do you want to proceed with creating a new project?'},'New project','Proceed','Cancel','Proceed');
            end
            if strcmp(Answ,'Proceed')
                conn_setup_wizard;
                conn gui_setup;
            end
            %Answ=questdlg({'New project creation (note: proceeding will close the current project and loose any unsaved progress)',' ','Do you want to use a wizard to select and preprocess your new project data now (e.g. realignment/normalization/smoothing)?',' ','Choosing ''no'' will still allow you to preprocess your data at a later time (select your data on the main CONN gui Functional/Structural tabs, and then preprocess it if required using the ''Preprocessing'' button)'},'New project','Yes','No','Cancel','No');
%             if strcmp(Answ,'Yes'),
%                 conn_setup_wizard;
%                 conn gui_setup;
%             elseif strcmp(Answ,'No')
%                 conn init;
%                 conn importrois;
%                 conn gui_setup;
%                 conn save;
%             end
            
        case 'gui_setup_qadisplay',
            conn_qaplotsexplore;
        case 'gui_preproc_qa'
            conn_qaplotsexplore('initdenoise');
		case {'displayvolume','display_volume','gui_display'},
            boffset=[0 0 0 0];
            if nargin<2 || ischar(varargin{2})
                conn_menumanager clf;
                conn_menuframe;
                tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;conn_menumanager(CONN_h.menus.m0,'state',tstate);
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
				
				conn_menu('frame',boffset+[.05,.10,.15,.7],'Display volumes');
				CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.06,.20,.12,.55],'Volumes','',['<HTML>Enter volumes for display in this list<br/> - click after the last item to add a new volume <br/> - ',CONN_gui.rightclick,'-click for additional options</HTML>'],'conn(''gui_display'',1);','conn(''gui_display'',8);');
				CONN_h.menus.m_setup_00{2}=conn_menu('checkbox',boffset+[.06,.11,.02,.03],'Structural overlay','','<HTML>Shows thresholded data over reference structural background','conn(''gui_display'',2);');
                CONN_h.menus.m_setup_00{3}=conn_menu('filesearch',[],'Select files','*.img; *.nii; *.mgh; *.mgz; *.annot; *.gz; *-1.dcm','',{@conn,'gui_display',3},'conn(''gui_display'',4);');
				CONN_h.menus.m_setup_00{5}=conn_menu('image2',boffset+[.25,.10,.50,.8]);
                set(CONN_h.menus.m_setup_00{3}.files,'max',2);
                if ~isfield(CONN_x.Setup,'display'), CONN_x.Setup.display={}; end
                hc1=uicontextmenu;
                uimenu(hc1,'Label','remove selected volume(s)','callback','conn(''gui_display'',8);');
                uimenu(hc1,'Label','move selected volume(s) up','callback','conn(''gui_display'',9,''up'');');
                uimenu(hc1,'Label','move selected volume(s) down','callback','conn(''gui_display'',9,''down'');');
                uimenu(hc1,'Label','move selected volume(s) to the top','callback','conn(''gui_display'',9,''top'');');
                uimenu(hc1,'Label','move selected volume(s) to the bottom','callback','conn(''gui_setup'',9,''bottom'');');
                set(CONN_h.menus.m_setup_00{1},'uicontextmenu',hc1);
                if nargin>=2, CONN_x.Setup.display={}; for n1=2:nargin, CONN_x.Setup.display{n1-1}=conn_file(varargin{n1}); end; end
                str={};
                for n1=1:numel(CONN_x.Setup.display)
                    filename=CONN_x.Setup.display{n1}{1};
                    str{end+1}=sprintf('%s',filename');
                end
                str{end+1}=' ';
                set(CONN_h.menus.m_setup_00{1},'string',str,'max',2);
                if ~isfield(CONN_h.menus,'m_setup')||~isfield(CONN_h.menus.m_setup,'displayB')||nargin>=2, 
                    CONN_h.menus.m_setup.displayB={}; 
                    hmsg=conn_msgbox('Loading files... please wait','');
                    for nvols=1:numel(CONN_x.Setup.display)
                        filenames=CONN_x.Setup.display{nvols}{1};
                        temp=[];
                        for n1=1:size(filenames,1)
                            filename=fliplr(deblank(fliplr(deblank(filenames(n1,:)))));
                            v=spm_vol(filename);
                            if nvols==1
                                [x,y,z]=ndgrid(1:v(1).dim(1),1:v(1).dim(2),1:v(1).dim(3));
                                CONN_h.menus.m_setup.displayBxyz=v(1).mat*[x(:) y(:) z(:) ones(numel(x),1)]';
                                CONN_h.menus.m_setup.displayBdim=v(1).dim(1:3);
                                CONN_h.menus.m_setup.displayBmat=v(1).mat;
                                CONN_h.menus.m_setup.displayBref=reshape(spm_get_data(CONN_gui.refs.canonical.V,pinv(CONN_gui.refs.canonical.V.mat)*CONN_h.menus.m_setup.displayBxyz),CONN_h.menus.m_setup.displayBdim);
                            end
                            for n2=1:numel(v),
                                temp=cat(4,temp,reshape(spm_get_data(v(n2),pinv(v(n2).mat)*CONN_h.menus.m_setup.displayBxyz),CONN_h.menus.m_setup.displayBdim));
                            end
                        end
                        CONN_h.menus.m_setup.displayB{nvols}=temp;
                    end
                    if ishandle(hmsg), delete(hmsg); end
                end
                if ~isfield(CONN_h.menus.m_setup,'displayBxyz'), CONN_h.menus.m_setup.displayBxyz=[]; end
                if ~isfield(CONN_h.menus.m_setup,'displayBdim'), CONN_h.menus.m_setup.displayBdim=[]; end
			else
				switch(varargin{2}),
					case 1, return;
                    case 2,
					case 3,
						if nargin<4, nvols=get(CONN_h.menus.m_setup_00{1},'value'); else  nvols=varargin{4}; end
                        if isempty(nvols), return; end
                        filenames=cellstr(varargin{3});
                        if numel(nvols)==1&&numel(filenames)>1, 
                            if nvols<numel(CONN_x.Setup.display), 
                                CONN_x.Setup.display(nvols+numel(filenames):end+numel(filenames)-1)=CONN_x.Setup.display(nvols+1:end);
                                CONN_h.menus.m_setup.displayB(nvols+numel(filenames):end+numel(filenames)-1)=CONN_h.menus.m_setup.displayB(nvols+1:end);
                            end
                            nvols=nvols+(0:numel(filenames)-1);
                        elseif numel(filenames)~=numel(nvols), conn_msgbox(sprintf('mismatched number of files (%d files; %d volumes in list)',numel(filenames),length(nvols)),'',2);
                        end
                        hmsg=conn_msgbox('Loading files... please wait','');
                        for n1=1:numel(filenames)
                            filename=fliplr(deblank(fliplr(deblank(filenames{n1}))));
                            [CONN_x.Setup.display{nvols(n1)},v]=conn_file(filename);
                            temp=[];
                            if nvols(n1)==1
                                [x,y,z]=ndgrid(1:v(1).dim(1),1:v(1).dim(2),1:v(1).dim(3));
                                CONN_h.menus.m_setup.displayBxyz=v(1).mat*[x(:) y(:) z(:) ones(numel(x),1)]';
                                CONN_h.menus.m_setup.displayBdim=v(1).dim(1:3);
                                CONN_h.menus.m_setup.displayBmat=v(1).mat;
                                CONN_h.menus.m_setup.displayBref=reshape(spm_get_data(CONN_gui.refs.canonical.V,pinv(CONN_gui.refs.canonical.V.mat)*CONN_h.menus.m_setup.displayBxyz),CONN_h.menus.m_setup.displayBdim);
                            end
                            for n2=1:numel(v),
                                temp=cat(4,temp,reshape(spm_get_data(v(n2),pinv(v(n2).mat)*CONN_h.menus.m_setup.displayBxyz),CONN_h.menus.m_setup.displayBdim));
                            end
                            CONN_h.menus.m_setup.displayB{nvols(n1)}=temp/max(abs(temp(:)));
                        end
                        if ishandle(hmsg), delete(hmsg); end
                        str={};
                        for n1=1:numel(CONN_x.Setup.display)
                            filename=CONN_x.Setup.display{n1}{1};
                            str{end+1}=sprintf('%s',filename');
                        end
                        str{end+1}=' ';
                        set(CONN_h.menus.m_setup_00{1},'string',str);
                    case 4,
                        nvols=get(CONN_h.menus.m_setup_00{1},'value');
                        if ~isempty(CONN_x.Setup.display{nvols(1)}{1})
                            tempstr=cellstr(CONN_x.Setup.display{nvols(1)}{1});
                            [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                            tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                            set(CONN_h.menus.m_setup_00{3}.selectfile,'string',unique(tempstr_name));
                            set(CONN_h.menus.m_setup_00{3}.folder,'string',fileparts(tempstr{1}));
                            conn_filesearchtool(CONN_h.menus.m_setup_00{3}.folder,[],'folder',true);
                        end
                    case 8,
                        nvols=get(CONN_h.menus.m_setup_00{1},'value');
                        idx=setdiff(1:numel(CONN_x.Setup.display),nvols);
                        CONN_h.menus.m_setup.displayB=CONN_h.menus.m_setup.displayB(idx);
                        CONN_x.Setup.display=CONN_x.Setup.display(idx);
                        str={};
                        for n1=1:numel(CONN_x.Setup.display)
                            filename=CONN_x.Setup.display{n1}{1};
                            str{end+1}=sprintf('%s',filename');
                        end
                        str{end+1}=' ';
                        set(CONN_h.menus.m_setup_00{1},'string',str,'value',unique(max(1,min(numel(str),nvols))));
                    case 9,
                        nvols=get(CONN_h.menus.m_setup_00{1},'value');
                        nvols(nvols>numel(CONN_x.Setup.display))=[];
                        if isempty(nvols), return; end
                        switch(varargin{3})
                            case 'up',   invols=1:numel(CONN_x.Setup.display); invols(nvols)=min(invols(nvols))-1.5; [nill,invols]=sort(invols);
                            case 'down', invols=1:numel(CONN_x.Setup.display); invols(nvols)=max(invols(nvols))+1.5; [nill,invols]=sort(invols);
                            case 'top',  invols=1:numel(CONN_x.Setup.display); invols(nvols)=(1:numel(nvols))-numel(nvols); [nill,invols]=sort(invols);
                            case 'bottom',  invols=1:numel(CONN_x.Setup.display); invols(nvols)=numel(invols)+(1:numel(nvols)); [nill,invols]=sort(invols);
                        end
                        CONN_x.Setup.display(1:numel(invols))=CONN_x.Setup.display(invols);
                        CONN_h.menus.m_setup.displayB(1:numel(invols))=CONN_h.menus.m_setup.displayB(invols);
                        nvols=unique(max(1,min(length(CONN_x.Setup.display),find(ismember(invols,nvols)))));
                        str={};
                        for n1=1:numel(CONN_x.Setup.display)
                            filename=CONN_x.Setup.display{n1}{1};
                            str{end+1}=sprintf('%s',filename');
                        end
                        str{end+1}=' ';
                        set(CONN_h.menus.m_setup_00{1},'string',str,'value',unique(max(1,min(numel(str),nvols))));
				end
            end
            temp2=permute(cat(4,CONN_h.menus.m_setup.displayB{:}),[2,1,3,4]);
            if isempty(temp2), conn_menu('update',CONN_h.menus.m_setup_00{5},[]);
            elseif get(CONN_h.menus.m_setup_00{2},'value') 
                conn_menu('update',CONN_h.menus.m_setup_00{5},{permute(CONN_h.menus.m_setup.displayBref,[2,1,3]),temp2,abs(temp2)},{struct('mat',CONN_h.menus.m_setup.displayBmat,'dim',CONN_h.menus.m_setup.displayBdim),[]});
            else
                conn_menu('update',CONN_h.menus.m_setup_00{5},temp2,{struct('mat',CONN_h.menus.m_setup.displayBmat,'dim',CONN_h.menus.m_setup.displayBdim),[]});
            end
				
		case 'gui_setup_import',
            boffset=[0 0 0 0];
			if nargin<2
                conn_menumanager clf;
                conn_menuframe;
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
				conn_menumanager([CONN_h.menus.m_setup_04,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
				
				conn_menu('frame',boffset+[.19,.13,.295,.67],'Import Setup from SPM');
				CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.2,.15,.075,.5],'Subjects','','Select each subject and enter one SPM.mat file (one file per subject) or multiple SPM.mat files (one file per session)','conn(''gui_setup_import'',1);');
				CONN_h.menus.m_setup_00{2}=conn_menu('edit',boffset+[.2,.7,.2,.04],'Number of subjects',num2str(CONN_x.Setup.nsubjects),'Number of subjects in this experiment','conn(''gui_setup_import'',2);');
				CONN_h.menus.m_setup_00{3}=conn_menu('filesearch',[],'Select SPM.mat files','SPM.mat','',{@conn,'gui_setup_import',3},'conn(''gui_setup_import'',4);');
				CONN_h.menus.m_setup_00{4}=conn_menu('pushbutton', boffset+[.275,.46,.2,.19],'Files','','','conn(''gui_setup_import'',4)');
				CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.285,.15,.17,.3]);
				set(CONN_h.menus.m_setup_00{1},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2);
                set(CONN_h.menus.m_setup_00{3}.files,'max',2);
			else
				switch(varargin{2}),
					case 1, 
					case 2,
						value0=CONN_x.Setup.nsubjects; 
						txt=get(CONN_h.menus.m_setup_00{2},'string'); value=str2num(txt); if ~isempty(value)&&length(value)==1, CONN_x.Setup.nsubjects=value; end; 
						if CONN_x.Setup.nsubjects~=value0, CONN_x.Setup.nsubjects=conn_merge(value0,CONN_x.Setup.nsubjects); end
						set(CONN_h.menus.m_setup_00{2},'string',num2str(CONN_x.Setup.nsubjects)); 
						set(CONN_h.menus.m_setup_00{1},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')],'max',2,'value',unique(min(CONN_x.Setup.nsubjects,get(CONN_h.menus.m_setup_00{1},'value'))));
					case 3,
						if nargin<4, nsubs=get(CONN_h.menus.m_setup_00{1},'value'); else  nsubs=varargin{4}; end
						filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
                        txt=''; bak1=CONN_x.Setup.spm;
                        if size(filename,1)==length(nsubs)
                            for nsub=1:length(nsubs)
                                CONN_x.Setup.spm{nsubs(nsub)}=conn_file(deblank(filename(nsub,:)));
                            end
                            txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                        elseif length(nsubs)==1
                            CONN_x.Setup.spm{nsubs}=conn_file(filename);
                            txt=sprintf('%d files assigned to %d subjects\n',size(filename,1),length(nsubs));
                        else
                            conn_msgbox(sprintf('mismatched number of files (%d files; %d subjects)',size(filename,1),length(nsubs)),'',2);
                        end
                        if ~isempty(txt)&&strcmp(conn_questdlg(txt,'','Ok','Undo','Ok'),'Undo'), CONN_x.Setup.spm=bak1;end
                    case 4,
                        nsubs=get(CONN_h.menus.m_setup_00{1},'value');
                        if ~isempty(CONN_x.Setup.spm{nsubs(1)}{1})
                            tempstr=cellstr(CONN_x.Setup.spm{nsubs(1)}{1});
                            [nill,tempstr_name,tempstr_ext]=cellfun(@spm_fileparts,tempstr,'uni',0);
                            tempstr_name=cellfun(@(a,b)[a b],tempstr_name,tempstr_ext,'uni',0);
                            set(CONN_h.menus.m_setup_00{3}.selectfile,'string',unique(tempstr_name));
                            set(CONN_h.menus.m_setup_00{3}.folder,'string',fileparts(tempstr{1}));
                            conn_filesearchtool(CONN_h.menus.m_setup_00{3}.folder,[],'folder',true);
                        end
				end
			end
			nsubs=get(CONN_h.menus.m_setup_00{1},'value');
			conn_menu('updatematrix',CONN_h.menus.m_setup_00{5},CONN_x.Setup.spm{nsubs(1)}{3});
			set(CONN_h.menus.m_setup_00{4},'string',conn_cell2html(CONN_x.Setup.spm{nsubs(1)}{2}));
				
        case 'gui_setup_importdone',
			conn_importspm;
			conn gui_setup;
			%conn_menumanager clf;
			%axes('units','norm','position',[0,.935,1,.005]); image(shiftdim(1-CONN_gui.backgroundcolorA,-1)); axis off;
			%conn_menumanager([CONN_h.menus.m_setup_02,CONN_h.menus.m_setup_01d,CONN_h.menus.m0],'on',1);
			
		case 'gui_setup_merge',
            boffset=[0 0 0 0];
			if nargin<2
                conn_menumanager clf;
                conn_menuframe;
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
				conn_menumanager([CONN_h.menus.m_setup_05,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                
                CONN_x.Setup.merge.nprojs=1;
                CONN_x.Setup.merge.files={{[],[],[]}};
                CONN_x.Setup.merge.type=1;
                conn_menu('frame',boffset+[.19,.13,.37,.67],'Merge multiple CONN projects');
                CONN_h.menus.m_setup_00{1}=conn_menu('listbox',boffset+[.2,.15,.15,.45],'Projects','','','conn(''gui_setup_merge'',1);');
				CONN_h.menus.m_setup_00{2}=conn_menu('edit',boffset+[.2,.7,.15,.04],'Number of projects',num2str(1),'Number of projects to merge','conn(''gui_setup_merge'',2);');
                CONN_h.menus.m_setup_00{6}=conn_menu('popup',boffset+[.2,.65,.15,.04],'',{'Add to current project','Create new project'},'<HTML> Selecting <i>Add to current project</i> will add all of the subjects in the selected projects to the current project <br/> Selecting <i>Create new project</i> will disregard the current project and combine all of the subjects in the selected projects as a new project instead</HTML>','conn(''gui_setup_merge'',6);');
				CONN_h.menus.m_setup_00{3}=conn_menu('filesearch',[],'Select conn_*.mat project files','conn_*.mat','',{@conn,'gui_setup_merge',3});
 				CONN_h.menus.m_setup_00{4}=conn_menu('text', boffset+[.35,.46,.2,.19],'Files');
				CONN_h.menus.m_setup_00{5}=conn_menu('image',boffset+[.36,.15,.17,.3]);
				set(CONN_h.menus.m_setup_00{1},'string',[repmat('Project ',[CONN_x.Setup.merge.nprojs,1]),num2str((1:CONN_x.Setup.merge.nprojs)')],'max',1);
			else
				switch(varargin{2}),
					case 1, 
					case 2,
						value0=CONN_x.Setup.merge.nprojs; 
						txt=get(CONN_h.menus.m_setup_00{2},'string'); value=str2num(txt); 
                        if ~isempty(value)&&length(value)==1, CONN_x.Setup.merge.nprojs=value; end; 
                        for n0=value0+1:CONN_x.Setup.merge.nprojs,CONN_x.Setup.merge.files{n0}={[],[],[]};end
                        CONN_x.Setup.merge.files={CONN_x.Setup.merge.files{1:CONN_x.Setup.merge.nprojs}};
						set(CONN_h.menus.m_setup_00{2},'string',num2str(CONN_x.Setup.merge.nprojs)); 
						set(CONN_h.menus.m_setup_00{1},'string',[repmat('Project ',[CONN_x.Setup.merge.nprojs,1]),num2str((1:CONN_x.Setup.merge.nprojs)')],'max',1,'value',min(CONN_x.Setup.merge.nprojs,get(CONN_h.menus.m_setup_00{1},'value')));
					case 3,
						if nargin<4, nprojs=get(CONN_h.menus.m_setup_00{1},'value'); else  nprojs=varargin{4}; end
						filename=fliplr(deblank(fliplr(deblank(varargin{3}))));
						[V,str,icon,filename]=conn_getinfo(filename);
						CONN_x.Setup.merge.files{nprojs}={filename,str,icon};
                    case 6,
                        CONN_x.Setup.merge.type=get(CONN_h.menus.m_setup_00{6},'value');
				end
			end
			nprojs=get(CONN_h.menus.m_setup_00{1},'value');
			conn_menu('update',CONN_h.menus.m_setup_00{5},CONN_x.Setup.merge.files{nprojs}{3});
			set(CONN_h.menus.m_setup_00{4},'string',CONN_x.Setup.merge.files{nprojs}{2});
				
		case 'gui_setup_mergedone',
            filenames=[];for n1=1:CONN_x.Setup.merge.nprojs,filenames=strvcat(filenames,CONN_x.Setup.merge.files{n1}{1});end
            hm=conn_msgbox('Merging projects... please wait','');
            switch(CONN_x.Setup.merge.type)
                case 1, 
                    value0=CONN_x.Setup.nsubjects;
                    value=conn_merge(filenames);
                case 2, 
                    answ=conn_questdlg({'Proceeding will close the current project and loose any unsaved progress','Do you want to:'},'Warning','Continue','Cancel','Continue');
                    if ~strcmp(answ,'Continue'), if ishandle(hm), close(hm); end; return; end
                    filename='conn_project01.mat'; [filename,pathname]=uiputfile('conn_*.mat','New project name',filename);
                    if ~ischar(filename)||isempty(filename), if ishandle(hm), close(hm); end; return; end
                    filename=fullfile(pathname,filename);
                    conn('load',deblank(filenames(1,:)));
                    conn('save',filename);
                    value0=CONN_x.Setup.nsubjects;
                    value=conn_merge(filenames,[],true,true);
            end
            if value~=value0,
                CONN_x.Setup.nsubjects=value;
                if ishandle(hm), close(hm); end
                conn gui_setup;
                try, conn_process('postmerge'); end
                conn gui_setup_save;
            else 
                if ishandle(hm), close(hm); end
                hm=conn_msgbox('There were problems importing the new subject data. Check the command line for further information','',true);
            end
			%conn_menumanager clf;
			%axes('units','norm','position',[0,.935,1,.005]); image(shiftdim(1-CONN_gui.backgroundcolorA,-1)); axis off;
			%conn_menumanager([CONN_h.menus.m_setup_02,CONN_h.menus.m_setup_01d,CONN_h.menus.m0],'on',1);
			
		case 'gui_setup_finish',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            if conn_questdlgrun('Ready to run Setup pipeline',[],CONN_x.Setup.steps(1:3),false,[],true,[],true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                if CONN_x.gui.parallel~=0, 
                    ispending=isequal(CONN_x.gui.parallel,find(strcmp('Null profile',conn_jobmanager('profiles'))));
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    if isfield(CONN_x.gui,'subjects'), subjects=CONN_x.gui.subjects; else subjects=[]; end
                    conn save;
                    conn_jobmanager('submit','setup',subjects,[],CONN_x.gui);
                else conn_process('setup'); ispending=false;
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                if ~conn_projectmanager('ispending')&&~ispending, conn gui_preproc; end
            end
			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
		case 'gui_preproc',
            CONN_x.gui=1;
			model=0;
            boffset=[.00 .05 0 0];
            if nargin<2,
                conn_menumanager clf;
                conn_menuframe;
				tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(2)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate); 
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
				conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
				if isempty(CONN_x.Preproc.variables.names), conn_msgbox({'Not ready to start Denoising step',' ','Please complete the Setup step first','(fill any required information and press "Done" in the Setup tab)'},'',2); return; end; %conn gui_setup; return; end
                conn_menu('nullstr',' '); %{'No data','to display'});

				%conn_menu('frame',boffset+[.04,.27,.37,.53],'DENOISING OPTIONS');
				%conn_menu('frame',boffset+[.04,.06,.37,.205]);
				conn_menu('frame',boffset+[.04,.10,.39,.70],'Denoising settings');
				[nill,CONN_h.menus.m_preproc_00{7}]=conn_menu('text',boffset+[.05,.70,.26,.05],'Linear regression of confounding effects:');
                set(CONN_h.menus.m_preproc_00{7},'horizontalalignment','left');
				CONN_h.menus.m_preproc_00{2}=conn_menu('listbox',boffset+[.07,.50,.165,.20],'Confounds','','<HTML>List of potential confounding effects (e.g. physiological/movement). <br/> - Linear regression will be used to remove these effects from the BOLD signal <br/> - Select effects in the <i>all effects</i> list and click <b> &lt </b> to add new effects to this list <br/> - Select effects in this list and click <b> &gt </b> to remove them from this list <br/> - By default this list includes White matter and CSF BOLD timeseries (CompCor), all first-level covariates <br/> (e.g. motion-correction and scrubbing), and all main task effects (for task designs) </HTML>','conn(''gui_preproc'',2);');
				CONN_h.menus.m_preproc_00{1}=conn_menu('listbox',boffset+[.27,.50,.125,.20],'all effects','','List of all effects','conn(''gui_preproc'',1);');
                CONN_h.menus.m_preproc_00{10}=conn_menu('pushbutton',boffset+[.245,.50,.025,.20],'','<','move elements between ''Confounds'' and ''all effects'' lists', 'conn(''gui_preproc'',0);');
				CONN_h.menus.m_preproc_00{6}=conn_menu('edit',boffset+[.27,.39,.15,.04],'Confound dimensions','','<HTML>Number of components/timeseries of selected effect to be included in regression model (<i>inf</i> to include all available dimensions)</HTML>','conn(''gui_preproc'',6);');
				CONN_h.menus.m_preproc_00{4}=conn_menu('popup',boffset+[.27,.35,.15,.04],'',{'no temporal expansion','add 1st-order derivatives','add 2nd-order derivatives'},'<HTML>Temporal/Taylor expansion of regressor timeseries<br/> - Include temporal derivates up to n-th order of selected effect<br/> - [x] for no expansion<br/> - [x, dx/dt] for first-order derivatives<br/> - [x, dx/dt, d2x/dt2] for second-order derivatives </HTML>','conn(''gui_preproc'',4);');
				CONN_h.menus.m_preproc_00{8}=conn_menu('popup',boffset+[.27,.31,.15,.04],'',{'no polynomial expansion','add quadratic effects','add cubic effects'},'<HTML>Polynomial expansion of regressor timeseries<br/> - Include powers up to n-th order of selected effect<br/> - [x] for no expansion<br/> - [x, x^2] for quadratic effects<br/> - [x, x^2, x^3] for cubic effects</HTML>','conn(''gui_preproc'',8);');
				CONN_h.menus.m_preproc_00{9}=conn_menu('checkbox',boffset+[.27,.28,.02,.03],'Filtered','','<HTML>Band-pass filter regressors timeseries before entering them into linear regression model <br/> - filtering a confound regressor allows to model and remove potential confound-by-frequency interactions<br/> - note: this option only applies when using <i>RegBP</i> (when using <i>simult</i> this options is disregarded and all regressors are automatically filtered)</HTML>','conn(''gui_preproc'',9);');
				CONN_h.menus.m_preproc_00{5}=conn_menu('edit',boffset+[.05,.15,.16,.05],'Band-pass filter (Hz):',mat2str(CONN_x.Preproc.filter),'BOLD signal Band-Pass filter threshold. Two values (in Hz): high-pass and low-pass thresholds, respectively','conn(''gui_preproc'',5);');
                CONN_h.menus.m_preproc_00{20}=conn_menu('popup',boffset+[.05,.10,.17,.05],'',{'After regression (RegBP)','Simultaneous (simult)'},'<HTML>Order of band-pass filtering step<br/> - <i>RegBP</i>: regression followed by band-pass filtering<br/> - <i>Simult</i>: simultaneous regression&band-pass filtering steps<br/>note: <i>simult</i> allows to model confound-by-frequency interactions. It is implemented as a RegBP procedure with pre-filtering <br/>of all regressors/confounds. See the regressor-specific ''filtered'' field if you need control over individual regressors/confounds</HTML>','conn(''gui_preproc'',20);');
				CONN_h.menus.m_preproc_00{18}=conn_menu('popup',boffset+[.27,.15,.15,.05],'Additional steps:',{'No detrending','Linear detrending','Quadratic detrending','Cubic detrending'},'<HTML>BOLD signal session-specific detrending<br/> - when selected detrending is implemented by automatically adding the associated linear/gradratic/cubic regressors to the confounding effects model</HTML>','conn(''gui_preproc'',18);');
				CONN_h.menus.m_preproc_00{19}=conn_menu('popup',boffset+[.27,.10,.15,.05],'',{'No despiking','Despiking before regression','Despiking after regression'},'BOLD signal despiking with a hyperbolic tangent squashing function (before or after confound removal regression)','conn(''gui_preproc'',19);');
                CONN_h.menus.m_preproc_00{22}=[...%uicontrol('style','frame','units','norm','position',boffset+[.30,.47,.13,.30],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA),...
                                               uicontrol('style','frame','units','norm','position',boffset+[.05,.23,.38,.26],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA)];
                CONN_h.menus.m_preproc_00{21}=uicontrol('style','frame','units','norm','position',boffset+[.235,.50,.15,.25],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA);
                %CONN_h.menus.m_preproc_00{21}=conn_menu('popup',boffset+[.22,.07,.15,.05],'',{'No dynamic estimation','Estimate dynamic effects'},'Estimates temporal components characterizing potential dynamic functional connectivity effects','conn(''gui_setup'',21);');
				CONN_h.menus.m_preproc_00{3}=conn_menu('image',boffset+[.07,.27,.17,.16],'Confound timeseries');
                
				conn_menu('frame2',boffset+[.48,.03,.49,.79],'Preview effect of Denoising');
				CONN_h.menus.m_preproc_00{11}=conn_menu('listbox2',boffset+[.80,.55,.08,.19],'Subjects','','Select subject to display','conn(''gui_preproc'',11);');
				CONN_h.menus.m_preproc_00{12}=conn_menu('listbox2',boffset+[.88,.55,.08,.19],'Sessions','','Select session to display','conn(''gui_preproc'',12);');
				%CONN_h.menus.m_preproc_00{13}=conn_menu('listbox',boffset+[.59,.45,.075,.3],'Confounds','','Select confound to display','conn(''gui_preproc'',13);');
				[CONN_h.menus.m_preproc_00{16},CONN_h.menus.m_preproc_00{17}]=conn_menu('hist',boffset+[.50,.59,.175,.16],'');
                %CONN_h.menus.m_preproc_00{21}=uicontrol('style','text','units','norm','position',boffset+[.48,.47,.215,.04],'string','voxel-to-voxel r','backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorB,'fontsize',8+CONN_gui.font_offset);
				[CONN_h.menus.m_preproc_00{23},CONN_h.menus.m_preproc_00{24}]=conn_menu('scatter',boffset+[.50,.36,.175,.205]);
                CONN_h.menus.m_preproc_00{25}=uicontrol('style','text','units','norm','position',boffset+[.48,.31,.215,.04],'string','voxel-to-voxel connectivity (r)','backgroundcolor',CONN_gui.backgroundcolor,'foregroundcolor',CONN_gui.fontcolorB,'fontsize',8+CONN_gui.font_offset);
                uicontrol('style','text','units','norm','position',boffset+[.50+.18,.19,.08,.04],'string','original','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolor,'foregroundcolor',.75/2*[1,1,1],'horizontalalignment','left'); 
                uicontrol('style','text','units','norm','position',boffset+[.50+.18,.12,.08,.04],'string','after denoising','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolor,'foregroundcolor',1/2*[1,1,0],'horizontalalignment','left'); 
                uicontrol('style','text','units','norm','position',boffset+[.50+.18,.06,.08,.04],'string','GS original','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolor,'foregroundcolor',.75/2*[1,1,1],'horizontalalignment','left'); 
                uicontrol('style','text','units','norm','position',boffset+[.50+.18,.03,.08,.04],'string','GS after denoising','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolor,'foregroundcolor',1/2*[1,1,0],'horizontalalignment','left'); 
                
                set(CONN_h.menus.m_preproc_00{23}.h2,'markersize',1);set(CONN_h.menus.m_preproc_00{23}.h1,'ydir','reverse','yaxislocation','right','xtick',-1:.5:1,'xticklabel',[]);ylabel(CONN_h.menus.m_preproc_00{23}.h1,'voxel-to-voxel distance (mm)','fontsize',8+CONN_gui.font_offset);
                %CONN_h.menus.m_preproc_00{25}=uicontrol('style','text','units','norm','position',boffset+[.73,.03,.185,.04],'string','voxel-to-voxel dist (mm)','backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorB,'fontsize',8+CONN_gui.font_offset);
                %CONN_h.menus.m_preproc_00{21}=uicontrol('style','text','units','norm','position',boffset+[.47,.08,.225,.04],'string','voxel-to-voxel r','backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorB,'fontsize',8+CONN_gui.font_offset);
                ht=conn_menu('text2',boffset+[.48,.74,.215,.04],'','Distribution of connectivity values (r)');
                set(ht,'foregroundcolor',CONN_gui.fontcolorA);
                %CONN_h.menus.m_preproc_00{33}=conn_menu('pushbuttonblue2',boffset+[.48,.72,.215,.04],'','Distribution of connectivity values (r)','<HTML>compute and display histograms of voxel-to-voxel connectivity values for all subjects/sessions (QA_DENOISE)<br/> - note: QA_DENOISE plots will be added to you most recent Quality Assurance set <br/> - use<i> Setup.QA plots</i> to display previously generated plot(s) </HTML>','conn(''gui_preproc'',33);');
                %hc1=uicontextmenu;uimenu(hc1,'Label','Show Histogram for all subjects/sessions','callback',@conn_displaydenoisinghistogram);set([CONN_h.menus.m_preproc_00{16}.h1, CONN_h.menus.m_preproc_00{16}.h3, CONN_h.menus.m_preproc_00{16}.h4, CONN_h.menus.m_preproc_00{16}.h5],'uicontextmenu',hc1);
                %set([CONN_h.menus.m_preproc_00{33}],'visible','off');%,'fontweight','bold');
                %conn_menumanager('onregion',[CONN_h.menus.m_preproc_00{33}],1,boffset+[.44,.45,.275,.40]);
                conn_menumanager('onregion',[CONN_h.menus.m_preproc_00{21}],-1,boffset+[.05,.45,.38,.30]);
                
				pos=[.82,.19,.12,.28];
				if any(CONN_x.Setup.steps([2,3])),
                    conn_menu('text0',boffset+[pos(1)+.01 pos(2)+pos(4)+.02 pos(3) .04],'','BOLD % variance explained by');
                    CONN_h.menus.m_preproc_00{13}=conn_menu('popup2',boffset+[pos(1)+.01,pos(2)+pos(4)-.01,pos(3),.04],'',{' TOTAL'},'Select confound to display','conn(''gui_preproc'',13);');
                    uicontrol('style','text','units','norm','position',boffset+[pos(1)-.01,pos(2)-1*.060,.070,.045],'string','threshold','fontname','default','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolor,'foregroundcolor',CONN_gui.fontcolorA); 
                    CONN_h.menus.m_preproc_00{15}=conn_menu('slider',boffset+[pos(1)+pos(3),pos(2),.015,pos(4)],'','','z-slice','conn(''gui_preproc'',15);');
                    try, addlistener(CONN_h.menus.m_preproc_00{15}, 'ContinuousValueChange',@(varargin)conn('gui_preproc',15)); end
                    set(CONN_h.menus.m_preproc_00{15},'visible','off');
                    CONN_h.menus.m_preproc_00{44}=conn_menu('pushbutton2',boffset+[pos(1)+pos(3)-.03,pos(2)-.060,.06,.045],'','display','slice timeseries display: shows BOLD timeseries in the selected slice (movie), optionally with selected confounding effect timeseries ','conn(''gui_preproc'',44);');
                    set(CONN_h.menus.m_preproc_00{44},'visible','off');%,'fontweight','bold');
                    conn_menumanager('onregion',[CONN_h.menus.m_preproc_00{44} CONN_h.menus.m_preproc_00{15}],1,boffset+pos+[0 -.10 .015 +.10]);
                    %CONN_h.menus.m_preproc_00{15}=uicontrol('style','slider','units','norm','position',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'callback','conn(''gui_preproc'',15);','backgroundcolor',CONN_gui.backgroundcolorA);
                else CONN_h.menus.m_preproc_00{13}=[];
                end
                [CONN_h.menus.m_preproc_00{26},CONN_h.menus.m_preproc_00{27}]=conn_menu('image2',boffset+[.50,.10,.175,.15],'BOLD timeseries','','',@conn_callbackdisplay_denoisingtraces,@conn_callbackdisplay_denoisingtracesclick);
				CONN_h.menus.m_preproc_00{28}=conn_menu('image2',boffset+[.50,.05,.175,.05],'');
                conn_callbackdisplay_denoisingclick([]);
				CONN_h.menus.m_preproc_00{14}=conn_menu('image2',boffset+pos,'','','',[],@conn_callbackdisplay_denoisingclick);
				CONN_h.menus.m_preproc_00{29}=conn_menu('image2',boffset+pos+[.02 -.14 0 -pos(4)+.05],'voxel BOLD timeseries');

                CONN_h.menus.m_preproc_surfhires=0;
				set(CONN_h.menus.m_preproc_00{20},'value',CONN_x.Preproc.regbp);
				set(CONN_h.menus.m_preproc_00{19},'value',1+CONN_x.Preproc.despiking);
				set(CONN_h.menus.m_preproc_00{18},'value',1+CONN_x.Preproc.detrending);
				set([CONN_h.menus.m_preproc_00{1},CONN_h.menus.m_preproc_00{2}],'max',2);
                tnames=CONN_x.Preproc.variables.names;
                try, tnames=cellfun(@(name,dim,deriv,power)sprintf('%s (%d)',name,dim(1)),CONN_x.Preproc.variables.names,CONN_x.Preproc.variables.dimensions,CONN_x.Preproc.variables.deriv,CONN_x.Preproc.variables.power,'uni',0); end
                tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names)),'uni',0);
				set(CONN_h.menus.m_preproc_00{1},'string',tnames);
                tnames=CONN_x.Preproc.confounds.names;
                try, tnames=cellfun(@(name,dim,deriv,power)sprintf('%s (%d)',name,min(dim)*(power*(1+deriv))),CONN_x.Preproc.confounds.names,CONN_x.Preproc.confounds.dimensions,CONN_x.Preproc.confounds.deriv,CONN_x.Preproc.confounds.power,'uni',0); end
				set(CONN_h.menus.m_preproc_00{2},'string',tnames);
				%conn_menumanager(CONN_h.menus.m_preproc_01,'on',1);
                if 0&&~isempty(tnames),set(CONN_h.menus.m_preproc_00{1},'value',[]);set(CONN_h.menus.m_preproc_00{2},'value',1);
                else set([CONN_h.menus.m_preproc_00{1},CONN_h.menus.m_preproc_00{2}],'value',[]);
                end
				%set(CONN_h.menus.m_preproc_00{4},'visible','off');%
				%set(CONN_h.menus.m_preproc_00{6},'visible','off');%
				set([CONN_h.menus.m_preproc_00{11},CONN_h.menus.m_preproc_00{12},CONN_h.menus.m_preproc_00{13}],'max',1);
				set(CONN_h.menus.m_preproc_00{11},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')]);
				nsess=CONN_x.Setup.nsessions(1); set(CONN_h.menus.m_preproc_00{12},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_preproc_00{12},'value')));
				set(CONN_h.menus.m_preproc_00{13},'string',{' TOTAL',CONN_x.Preproc.confounds.names{:}}); 
                
				%set(CONN_h.screen.hfig,'pointer','watch');
				[path,name,ext]=fileparts(CONN_x.filename);
                filepath=CONN_x.folders.data;
                if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                    filename=fullfile(filepath,['DATA_Subject',num2str(1,'%03d'),'_Session',num2str(1,'%03d'),'.mat']);
                    if isempty(dir(filename)), conn_msgbox({'Not ready to start Denoising step',' ','Please complete the Setup step first','(fill any required information and press "Done" in the Setup tab)'},'',2); return; end %conn gui_setup; return; end
                    CONN_h.menus.m_preproc.Y=conn_vol(filename);
                    if isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface,%isequal(CONN_h.menus.m_preproc.Y.matdim.dim,conn_surf_dims(8).*[1 1 2])
                        CONN_h.menus.m_preproc.y.slice=1;
                        if CONN_h.menus.m_preproc_surfhires
                            [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_volume(CONN_h.menus.m_preproc.Y);
                        else
                            [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,1);
                            [tempdata,tempidx]=conn_get_slice(CONN_h.menus.m_preproc.Y,conn_surf_dims(8)*[0;0;1]+1);
                            CONN_h.menus.m_preproc.y.data=[CONN_h.menus.m_preproc.y.data(:,CONN_gui.refs.surf.default2reduced) tempdata(:,CONN_gui.refs.surf.default2reduced)];
                            CONN_h.menus.m_preproc.y.idx=[CONN_h.menus.m_preproc.y.idx(CONN_gui.refs.surf.default2reduced);prod(conn_surf_dims(8))+tempidx(CONN_gui.refs.surf.default2reduced)];
                        end
                        set(CONN_h.menus.m_preproc_00{15},'visible','off');
                        conn_menumanager('onregionremove',CONN_h.menus.m_preproc_00{15});
                    else
                        CONN_h.menus.m_preproc.y.slice=ceil(CONN_h.menus.m_preproc.Y.matdim.dim(3)/2);
                        [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,CONN_h.menus.m_preproc.y.slice);
                    end
                end
                CONN_h.menus.m_preproc.strlabel=sprintf('Subject %d session %d',1,1);
				filename=fullfile(filepath,['ROI_Subject',num2str(1,'%03d'),'_Session',num2str(1,'%03d'),'.mat']);
				CONN_h.menus.m_preproc.X1=load(filename);
				filename=fullfile(filepath,['COV_Subject',num2str(1,'%03d'),'_Session',num2str(1,'%03d'),'.mat']);
				CONN_h.menus.m_preproc.X2=load(filename);
                if any(CONN_x.Setup.steps([2,3]))
                    if ~(isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface)
                        try
                            CONN_h.menus.m_preproc.XS=spm_vol(deblank(CONN_x.Setup.structural{1}{1}{1}));
                        catch
                            CONN_h.menus.m_preproc.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                        end
                        xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))*(CONN_h.menus.m_preproc.y.slice-1)+(1:prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))),CONN_h.menus.m_preproc.Y.matdim.mat,CONN_h.menus.m_preproc.Y.matdim.dim);
                        CONN_h.menus.m_preproc.Xs=spm_get_data(CONN_h.menus.m_preproc.XS(1),pinv(CONN_h.menus.m_preproc.XS(1).mat)*xyz');
                        CONN_h.menus.m_preproc.Xs=permute(reshape(CONN_h.menus.m_preproc.Xs,CONN_h.menus.m_preproc.Y.matdim.dim(1:2)),[2,1,3]);
                        set(CONN_h.menus.m_preproc_00{15},'min',1,'max',CONN_h.menus.m_preproc.Y.matdim.dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_preproc.Y.matdim.dim(3)-1)),'value',CONN_h.menus.m_preproc.y.slice);
                    else
                        CONN_h.menus.m_preproc.y.slice=max(1,min(4,CONN_h.menus.m_preproc.y.slice));
                    end
                end
				conn_menumanager([CONN_h.menus.m_preproc_02],'on',1);
				model=1;
			else 
				switch(varargin{2}),
					case 0,
                        str=get(CONN_h.menus.m_preproc_00{10},'string');
						%str=conn_menumanager(CONN_h.menus.m_preproc_01,'string');
						switch(str),
							case '<',
								ncovariates=get(CONN_h.menus.m_preproc_00{1},'value'); 
								for ncovariate=ncovariates(:)',
									if isempty(strmatch(CONN_x.Preproc.variables.names{ncovariate},CONN_x.Preproc.confounds.names,'exact')), 
										CONN_x.Preproc.confounds.names{end+1}=CONN_x.Preproc.variables.names{ncovariate}; 
										CONN_x.Preproc.confounds.types{end+1}=CONN_x.Preproc.variables.types{ncovariate}; 
										CONN_x.Preproc.confounds.power{end+1}=CONN_x.Preproc.variables.power{ncovariate}; 
										CONN_x.Preproc.confounds.deriv{end+1}=CONN_x.Preproc.variables.deriv{ncovariate}; 
										CONN_x.Preproc.confounds.dimensions{end+1}=[inf CONN_x.Preproc.variables.dimensions{ncovariate}(1)]; 
										CONN_x.Preproc.confounds.filter{end+1}=CONN_x.Preproc.variables.filter{ncovariate}; 
									end
								end
                                tnames=CONN_x.Preproc.variables.names;
                                try, tnames=cellfun(@(name,dim,deriv,power)sprintf('%s (%d)',name,dim(1)),CONN_x.Preproc.variables.names,CONN_x.Preproc.variables.dimensions,CONN_x.Preproc.variables.deriv,CONN_x.Preproc.variables.power,'uni',0); end
                                tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names)),'uni',0);
                                set(CONN_h.menus.m_preproc_00{1},'string',tnames);
                                tnames=CONN_x.Preproc.confounds.names;
                                try, tnames=cellfun(@(name,dim,deriv,power)sprintf('%s (%d)',name,min(dim)*(power*(1+deriv))),CONN_x.Preproc.confounds.names,CONN_x.Preproc.confounds.dimensions,CONN_x.Preproc.confounds.deriv,CONN_x.Preproc.confounds.power,'uni',0); end
                                set(CONN_h.menus.m_preproc_00{2},'string',tnames);
								set(CONN_h.menus.m_preproc_00{13},'string',{' TOTAL',CONN_x.Preproc.confounds.names{:}}); 
							case '>',
								ncovariates=get(CONN_h.menus.m_preproc_00{2},'value'); 
								idx=setdiff(1:length(CONN_x.Preproc.confounds.names),ncovariates);
								CONN_x.Preproc.confounds.names={CONN_x.Preproc.confounds.names{idx}};
								CONN_x.Preproc.confounds.types={CONN_x.Preproc.confounds.types{idx}};
								CONN_x.Preproc.confounds.power={CONN_x.Preproc.confounds.power{idx}};
								CONN_x.Preproc.confounds.deriv={CONN_x.Preproc.confounds.deriv{idx}};
								CONN_x.Preproc.confounds.dimensions={CONN_x.Preproc.confounds.dimensions{idx}};
								CONN_x.Preproc.confounds.filter={CONN_x.Preproc.confounds.filter{idx}};
                                tnames=CONN_x.Preproc.variables.names;
                                try, tnames=cellfun(@(name,dim,deriv,power)sprintf('%s (%d)',name,dim(1)),CONN_x.Preproc.variables.names,CONN_x.Preproc.variables.dimensions,CONN_x.Preproc.variables.deriv,CONN_x.Preproc.variables.power,'uni',0); end
                                tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Preproc.variables.names,CONN_x.Preproc.confounds.names)),'uni',0);
                                set(CONN_h.menus.m_preproc_00{1},'string',tnames);
                                tnames=CONN_x.Preproc.confounds.names;
                                try, tnames=cellfun(@(name,dim,deriv,power)sprintf('%s (%d)',name,min(dim)*(power*(1+deriv))),CONN_x.Preproc.confounds.names,CONN_x.Preproc.confounds.dimensions,CONN_x.Preproc.confounds.deriv,CONN_x.Preproc.confounds.power,'uni',0); end
                                set(CONN_h.menus.m_preproc_00{2},'string',tnames,'value',min(max(ncovariates),length(tnames))); 
								set(CONN_h.menus.m_preproc_00{13},'string',{' TOTAL',CONN_x.Preproc.confounds.names{:}},'value',min(max(get(CONN_h.menus.m_preproc_00{13},'value')),length(CONN_x.Preproc.confounds.names)+1)); 
						end
						model=1;
					case 1,
                        set(CONN_h.menus.m_preproc_00{10},'string','<');
						%conn_menumanager(CONN_h.menus.m_preproc_01,'string',{'<'},'on',1);
						set(CONN_h.menus.m_preproc_00{2},'value',[]); 
                        set(CONN_h.menus.m_preproc_00{22},'visible','on');
						%set([CONN_h.menus.m_preproc_00{4},CONN_h.menus.m_preproc_00{6}],'visible','off');% 
					case 2,
                        set(CONN_h.menus.m_preproc_00{10},'string','>');
						%conn_menumanager(CONN_h.menus.m_preproc_01,'string',{'>'},'on',1);
						set(CONN_h.menus.m_preproc_00{1},'value',[]); 
                        set(CONN_h.menus.m_preproc_00{22},'visible','off');
						nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
                        if numel(nconfounds)==1
                            set(CONN_h.menus.m_preproc_00{13},'value',nconfounds+1);
                            model=2;
                        end
						%set([CONN_h.menus.m_preproc_00{4},CONN_h.menus.m_preproc_00{6}],'visible','on');% 
					case 4,
						nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
						value=get(CONN_h.menus.m_preproc_00{4},'value')-1;
						if length(value)==1, for nconfound=nconfounds(:)', CONN_x.Preproc.confounds.deriv{nconfound}=round(max(0,min(2,value))); end; end
                        tnames=CONN_x.Preproc.confounds.names;
                        try, tnames=cellfun(@(name,dim,deriv,power)sprintf('%s (%d)',name,min(dim)*(power*(1+deriv))),CONN_x.Preproc.confounds.names,CONN_x.Preproc.confounds.dimensions,CONN_x.Preproc.confounds.deriv,CONN_x.Preproc.confounds.power,'uni',0); end
                        set(CONN_h.menus.m_preproc_00{2},'string',tnames);
						model=1;
					case 5,
						value=str2num(get(CONN_h.menus.m_preproc_00{5},'string'));
						if length(value)==2 && value(2)>value(1), CONN_x.Preproc.filter=value; end
						model=1;
					case 6,
						nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
						value=str2num(get(CONN_h.menus.m_preproc_00{6},'string'));
						%if length(value)==1, for nconfound=nconfounds(:)', CONN_x.Preproc.confounds.dimensions{nconfound}(1)=round(max(1,min(CONN_x.Preproc.confounds.dimensions{nconfound}(2),value))); end; end
						if length(value)==1, for nconfound=nconfounds(:)', CONN_x.Preproc.confounds.dimensions{nconfound}(1)=round(max(0,value)); end; end
                        tnames=CONN_x.Preproc.confounds.names;
                        try, tnames=cellfun(@(name,dim,deriv,power)sprintf('%s (%d)',name,min(dim)*(power*(1+deriv))),CONN_x.Preproc.confounds.names,CONN_x.Preproc.confounds.dimensions,CONN_x.Preproc.confounds.deriv,CONN_x.Preproc.confounds.power,'uni',0); end
                        set(CONN_h.menus.m_preproc_00{2},'string',tnames);
						model=1;
					case 8,
						nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
						value=get(CONN_h.menus.m_preproc_00{8},'value');
						if length(value)==1, for nconfound=nconfounds(:)', CONN_x.Preproc.confounds.power{nconfound}=round(max(1,min(3,value))); end; end
                        tnames=CONN_x.Preproc.confounds.names;
                        try, tnames=cellfun(@(name,dim,deriv,power)sprintf('%s (%d)',name,min(dim)*(power*(1+deriv))),CONN_x.Preproc.confounds.names,CONN_x.Preproc.confounds.dimensions,CONN_x.Preproc.confounds.deriv,CONN_x.Preproc.confounds.power,'uni',0); end
                        set(CONN_h.menus.m_preproc_00{2},'string',tnames);
						model=1;
					case 9,
						nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
						value=get(CONN_h.menus.m_preproc_00{9},'value');
						if length(value)==1, for nconfound=nconfounds(:)', CONN_x.Preproc.confounds.filter{nconfound}=value; end; end
						model=1;
					case {11,12},
						nsubs=get(CONN_h.menus.m_preproc_00{11},'value');
						 if varargin{2}==11,
							 nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsubs)); 
							 set(CONN_h.menus.m_preproc_00{12},'string',[repmat('Session ',[nsess,1]),num2str((1:nsess)')],'value',min(nsess,get(CONN_h.menus.m_preproc_00{12},'value')));
						 end
						 nsess=get(CONN_h.menus.m_preproc_00{12},'value');
						 %set(CONN_h.screen.hfig,'pointer','watch');
						 [path,name,ext]=fileparts(CONN_x.filename);
%                          filepath=fullfile(path,name,'data');
                         filepath=CONN_x.folders.data;
                         if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                             filename=fullfile(filepath,['DATA_Subject',num2str(nsubs,'%03d'),'_Session',num2str(nsess,'%03d'),'.mat']);
                             CONN_h.menus.m_preproc.Y=conn_vol(filename);
                             if isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface
                                 if CONN_h.menus.m_preproc_surfhires
                                     [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_volume(CONN_h.menus.m_preproc.Y);
                                 else
                                     [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,1);
                                     [tempdata,tempidx]=conn_get_slice(CONN_h.menus.m_preproc.Y,conn_surf_dims(8)*[0;0;1]+1);
                                     CONN_h.menus.m_preproc.y.data=[CONN_h.menus.m_preproc.y.data(:,CONN_gui.refs.surf.default2reduced) tempdata(:,CONN_gui.refs.surf.default2reduced)];
                                     CONN_h.menus.m_preproc.y.idx=[CONN_h.menus.m_preproc.y.idx(CONN_gui.refs.surf.default2reduced);prod(conn_surf_dims(8))+tempidx(CONN_gui.refs.surf.default2reduced)];
                                 end
                             else
                                 [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,CONN_h.menus.m_preproc.y.slice);
                             end
                         end
                         CONN_h.menus.m_preproc.strlabel=sprintf('Subject %d session %d',nsubs,nsess);
						 filename=fullfile(filepath,['ROI_Subject',num2str(nsubs,'%03d'),'_Session',num2str(nsess,'%03d'),'.mat']);
						 CONN_h.menus.m_preproc.X1=load(filename);
						 filename=fullfile(filepath,['COV_Subject',num2str(nsubs,'%03d'),'_Session',num2str(nsess,'%03d'),'.mat']);
						 CONN_h.menus.m_preproc.X2=load(filename);
                         if any(CONN_x.Setup.steps([2,3]))&&~(isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface)
                             if ~CONN_x.Setup.structural_sessionspecific, nsesstemp=1; else nsesstemp=nsess; end
                             try
                                 CONN_h.menus.m_preproc.XS=spm_vol(deblank(CONN_x.Setup.structural{nsubs}{nsesstemp}{1}));
                             catch
                                 CONN_h.menus.m_preproc.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                             end
                             xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))*(CONN_h.menus.m_preproc.y.slice-1)+(1:prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))),CONN_h.menus.m_preproc.Y.matdim.mat,CONN_h.menus.m_preproc.Y.matdim.dim);
                             CONN_h.menus.m_preproc.Xs=spm_get_data(CONN_h.menus.m_preproc.XS(1),pinv(CONN_h.menus.m_preproc.XS(1).mat)*xyz');
                             CONN_h.menus.m_preproc.Xs=permute(reshape(CONN_h.menus.m_preproc.Xs,CONN_h.menus.m_preproc.Y.matdim.dim(1:2)),[2,1,3]);
                         end
						 model=1;
					 case 13,
						 model=2;
					 case 15,
						 nsubs=get(CONN_h.menus.m_preproc_00{11},'value');
                         CONN_h.menus.m_preproc.y.slice=round(get(CONN_h.menus.m_preproc_00{15},'value'));
                         if any(CONN_x.Setup.steps([2,3]))&&~(isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface)
                             [CONN_h.menus.m_preproc.y.data,CONN_h.menus.m_preproc.y.idx]=conn_get_slice(CONN_h.menus.m_preproc.Y,CONN_h.menus.m_preproc.y.slice);
                             xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))*(CONN_h.menus.m_preproc.y.slice-1)+(1:prod(CONN_h.menus.m_preproc.Y.matdim.dim(1:2))),CONN_h.menus.m_preproc.Y.matdim.mat,CONN_h.menus.m_preproc.Y.matdim.dim);
                             CONN_h.menus.m_preproc.Xs=spm_get_data(CONN_h.menus.m_preproc.XS(1),pinv(CONN_h.menus.m_preproc.XS(1).mat)*xyz');
                             CONN_h.menus.m_preproc.Xs=permute(reshape(CONN_h.menus.m_preproc.Xs,CONN_h.menus.m_preproc.Y.matdim.dim(1:2)),[2,1,3]);
                         end
                         model=1;
                    case 18,
						val=get(CONN_h.menus.m_preproc_00{18},'value');
						CONN_x.Preproc.detrending=val-1;
                        model=1;
                    case 19,
						val=get(CONN_h.menus.m_preproc_00{19},'value');
						CONN_x.Preproc.despiking=val-1;
                        model=1;
                    case 20,
						val=get(CONN_h.menus.m_preproc_00{20},'value');
						CONN_x.Preproc.regbp=val;
                        model=1;
                    case 33,
                        conn_qaplotsexplore('initdenoise');
                        return;
                    case 44,
                        if isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface, issurface=true; else issurface=false; end
                        if ~issurface
                            t1=zeros(CONN_h.menus.m_preproc.Y.matdim.dim(1:2));
                            t2=zeros(CONN_h.menus.m_preproc.Y.matdim.dim(1:2));
                            dispdata={};
                            displabel={};
                            covdata={};
                            showdemeaned=0;
                            mydata=mean(CONN_h.menus.m_preproc.y.data,1);
                            for n=1:size(CONN_h.menus.m_preproc.y.data,1)
                                t1(CONN_h.menus.m_preproc.y.idx)=CONN_h.menus.m_preproc.y.data(n,:)-showdemeaned*mydata;
                                t2(CONN_h.menus.m_preproc.y.idx)=CONN_h.menus.m_preproc.y.data_afterdenoising(n,:)+(1-showdemeaned)*mydata;
                                dispdata{end+1}=[fliplr(flipud(t1')) fliplr(flipud(t2'))];
                                displabel{end+1}=sprintf('scan %d       Left: before denoising    Right: after denoising',n);
                            end
                            covdata=CONN_h.menus.m_preproc.X;
                            covdata=covdata(:,find(CONN_h.menus.m_preproc.select{2}));
                            nview=get(CONN_h.menus.m_preproc_00{13},'value')-1;
                            if nview>=1&&nview<=numel(CONN_x.Preproc.confounds.names), covdata_name=CONN_x.Preproc.confounds.names(nview);
                            else covdata_name={};
                            end
                            fh=conn_montage_display(cat(4,dispdata{:}),displabel,'movie',covdata,covdata_name);
                            fh('colormap','gray'); fh('colormap','darker');
                            fh('start');
                        end
                        return
				end
			end
			nsubs=get(CONN_h.menus.m_preproc_00{11},'value');
			nconfounds=get(CONN_h.menus.m_preproc_00{2},'value');
			nview=get(CONN_h.menus.m_preproc_00{13},'value')-1;
            confounds=CONN_x.Preproc.confounds;
            nfilter=find(cellfun(@(x)max(x),CONN_x.Preproc.confounds.filter));
            if isfield(CONN_x.Preproc,'detrending')&&CONN_x.Preproc.detrending, 
                confounds.types{end+1}='detrend'; 
                if CONN_x.Preproc.detrending>=2, confounds.types{end+1}='detrend2'; end
                if CONN_x.Preproc.detrending>=3, confounds.types{end+1}='detrend3'; end
            end
			[CONN_h.menus.m_preproc.X,CONN_h.menus.m_preproc.select]=conn_designmatrix(confounds,CONN_h.menus.m_preproc.X1,CONN_h.menus.m_preproc.X2,{nconfounds,nview,nfilter});
			if ~isempty(nconfounds)&&all(nconfounds>0), 
				temp=cat(1,CONN_x.Preproc.confounds.deriv{nconfounds});
				if length(temp)==1 || ~any(diff(temp)),set(CONN_h.menus.m_preproc_00{4},'visible','on','value',1+CONN_x.Preproc.confounds.deriv{nconfounds(1)}); 
				else  set(CONN_h.menus.m_preproc_00{4},'visible','off'); end
				temp=cat(1,CONN_x.Preproc.confounds.power{nconfounds});
				if length(temp)==1 || ~any(diff(temp)),set(CONN_h.menus.m_preproc_00{8},'visible','on','value',CONN_x.Preproc.confounds.power{nconfounds(1)}); 
				else  set(CONN_h.menus.m_preproc_00{8},'visible','off'); end
				temp=cat(1,CONN_x.Preproc.confounds.dimensions{nconfounds});
				if size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_preproc_00{6},'string',num2str(CONN_x.Preproc.confounds.dimensions{nconfounds(1)}(1))); 
				else  set(CONN_h.menus.m_preproc_00{6},'string','MULTIPLE VALUES'); end
				temp=cat(1,CONN_x.Preproc.confounds.filter{nconfounds});
				if size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_preproc_00{9},'value',CONN_x.Preproc.confounds.filter{nconfounds(1)}(1)); 
				else  set(CONN_h.menus.m_preproc_00{9},'value',0); end
			end
			set(CONN_h.menus.m_preproc_00{5},'string',mat2str(CONN_x.Preproc.filter));
            if 0,%~isempty(CONN_x.Preproc.variables.names)
                if ~isfield(CONN_h.menus.m_preproc,'showdenoised')||isempty(CONN_h.menus.m_preproc.showdenoised), CONN_h.menus.m_preproc.showdenoised=1; end
                value=get(CONN_h.menus.m_preproc_00{1},'value');
                if isempty(value), value=max(1,min(numel(CONN_x.Preproc.variables.names),CONN_h.menus.m_preproc.showdenoised)); else value=value(1); end
                CONN_h.menus.m_preproc.showdenoised=value;
                xf=CONN_h.menus.m_preproc.X;
                if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
                    xf=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf);
                elseif nnz(CONN_h.menus.m_preproc.select{3})
                    xf(:,find(CONN_h.menus.m_preproc.select{3}))=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf(:,find(CONN_h.menus.m_preproc.select{3})));
                end
                [x0,idx]=conn_designmatrix(CONN_x.Preproc.variables,CONN_h.menus.m_preproc.X1,CONN_h.menus.m_preproc.X2,{value});
                x0=x0(:,idx{1}>0);
                x1=x0;
                if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==1,
                    my=repmat(median(x1,1),[size(x1,1),1]);
                    sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                    x1=my+sy.*tanh((x1-my)./max(eps,sy));
                end
                x1=x1-xf*(pinv(xf)*x1);
                if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==2,
                    my=repmat(median(x1,1),[size(x1,1),1]);
                    sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                    x1=my+sy.*tanh((x1-my)./max(eps,sy));
                end
                [x1,fy]=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,x1);
                conn_menu('update',CONN_h.menus.m_preproc_00{28},[x0 x1]);
                try, set(CONN_h.menus.m_preproc_00{28}.h4(1:size(x0,2)),'color',.75/2*[1,1,1]); set(CONN_h.menus.m_preproc_00{28}.h4(size(x0,2)+(1:size(x1,2))),'color',1/2*[1,1,0]); end
                %set(CONN_h.menus.m_preproc_00{29},'string',sprintf('Denoised timeseries %s',CONN_x.Preproc.variables.names{value}(1:min(numel(CONN_x.Preproc.variables.names{value}),32))));
            else
                %conn_menu('update',CONN_h.menus.m_preproc_00{28},[]);
                xf=CONN_h.menus.m_preproc.X;
                if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
                    xf=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf);
                elseif nnz(CONN_h.menus.m_preproc.select{3})
                    xf(:,find(CONN_h.menus.m_preproc.select{3}))=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf(:,find(CONN_h.menus.m_preproc.select{3})));
                end
            end
			if isempty(nconfounds)||isequal(nconfounds,0), 
                conn_menu('update',CONN_h.menus.m_preproc_00{3},[]); 
                set(CONN_h.menus.m_preproc_00{22},'visible','on');
            else
				xtemp=xf(:,find(CONN_h.menus.m_preproc.select{1}));
                conn_menu('updateplotstack',CONN_h.menus.m_preproc_00{3},xtemp); 
                set(CONN_h.menus.m_preproc_00{22},'visible','off');
            end
% 			if size(xf,2)<=500,
% 				offon={'off','on'};
% 				for n1=1:size(xf,2),
% 					set(CONN_h.menus.m_preproc_00{3}.h4(n1),'visible',offon{1+CONN_h.menus.m_preproc.select{1}(n1)});
% 				end
% 				xtemp=xf(:,find(CONN_h.menus.m_preproc.select{1}));
% 				if ~isempty(xtemp), set(CONN_h.menus.m_preproc_00{3}.h3,'ylim',[min(min(xtemp))-1e-4,max(max(xtemp))+1e-4]); end
%             end
			if model==1, 
                if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                    xf=CONN_h.menus.m_preproc.X;%conn_filter(CONN_x.Setup.RT,CONN_x.Preproc.filter,CONN_h.menus.m_preproc.X,'partial');
                    if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
                        xf=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf);
                    elseif nnz(CONN_h.menus.m_preproc.select{3})
                        xf(:,find(CONN_h.menus.m_preproc.select{3}))=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf(:,find(CONN_h.menus.m_preproc.select{3})));
                    end
                    yf=CONN_h.menus.m_preproc.y.data;%conn_filter(CONN_x.Setup.RT,CONN_x.Preproc.filter,CONN_h.menus.m_preproc.y.data,'partial');
                    if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==1,
                        my=repmat(median(yf,1),[size(yf,1),1]);
                        sy=repmat(4*median(abs(yf-my)),[size(yf,1),1]);
                        yf=my+sy.*tanh((yf-my)./max(eps,sy));
                    end
                    if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2, yf2=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,yf); % just to make the 'BOLD % variance' plot more meaningful in this case (percent variance within band-pass)
                    else yf2=yf-repmat(mean(yf,1),size(yf,1),1);
                    end
                    [CONN_h.menus.m_preproc.B,CONN_h.menus.m_preproc.opt]=conn_glmunivariate('estimate',xf,yf2);
                    if 1
                        B=conn_glmunivariate('estimate',xf,yf);
                        yf=yf-xf*B;
                        if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==2,
                            my=repmat(median(yf,1),[size(yf,1),1]);
                            sy=repmat(4*median(abs(yf-my)),[size(yf,1),1]);
                            yf=my+sy.*tanh((yf-my)./max(eps,sy));
                        end
                        yf=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,yf);
                        CONN_h.menus.m_preproc.y.data_afterdenoising=yf;
                    end
                    if CONN_h.menus.m_preproc.opt.dof<=0, disp(['Warning: Over-determined model (no degrees of freedom for this subject). Please consider reducing the number, dimensions, or covariates order of the confounds or disregarding this subject/session']); end
                end
                if isfield(CONN_h.menus.m_preproc.X1,'sampledata'),
                    xf=CONN_h.menus.m_preproc.X;
                    if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
                        xf=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf);
                    elseif nnz(CONN_h.menus.m_preproc.select{3})
                        xf(:,find(CONN_h.menus.m_preproc.select{3}))=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,xf(:,find(CONN_h.menus.m_preproc.select{3})));
                    end
%                     if ~any(CONN_x.Setup.steps([2,3])),%isfield(CONN_x.Setup,'doROIonly')&&CONN_x.Setup.doROIonly,
%                         CONN_h.menus.m_preproc.opt.dof=size(CONN_h.menus.m_preproc.X1.sampledata,1)-size(xf,2); 
%                     end
%                     dof=CONN_h.menus.m_preproc.opt.dof;
                    x0=CONN_h.menus.m_preproc.X1.sampledata;
                    if isfield(CONN_h.menus.m_preproc.X1,'samplexyz')&&numel(CONN_h.menus.m_preproc.X1.samplexyz)==size(x0,2), xyz=cell2mat(CONN_h.menus.m_preproc.X1.samplexyz);
                    else xyz=nan(3,size(x0,2));
                    end
                    %x0=detrend(x0);
                    x0orig=x0;
                    x0=detrend(x0,'constant');
                    maskx0=~all(abs(x0)<1e-4,1)&~any(isnan(x0),1);
                    x0=x0(:,maskx0);
                    x0orig=x0orig(:,maskx0);
                    xyz=xyz(:,maskx0);
                    if isempty(x0), 
                        disp('Warning! No temporal variation in BOLD signal within sampled grey-matter voxels');
                    end
                    x1=x0;
                    %fy=mean(abs(fft(x0)).^2,2);
                    if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==1,
                        my=repmat(median(x1,1),[size(x1,1),1]);
                        sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                        x1=my+sy.*tanh((x1-my)./max(eps,sy));
                    end
                    x1=x1-xf*(pinv(xf)*x1);
                    if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==2,
                        my=repmat(median(x1,1),[size(x1,1),1]);
                        sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                        x1=my+sy.*tanh((x1-my)./max(eps,sy));
                    end
                    [x1,fy]=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs))),CONN_x.Preproc.filter,x1);
                    fy=mean(abs(fy(1:round(size(fy,1)/2),:)).^2,2); 
                    %dof=max(0,sum(fy)^2/sum(fy.^2)-size(xf,2)); % change dof displayed to WelchSatterthwaite residual dof approximation
                    dof0=size(CONN_h.menus.m_preproc.X1.sampledata,1)-1;
                    dof1=max(0,sum(fy)^2/sum(fy.^2)); % WelchSatterthwaite residual dof approximation
                    if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2, dof2=max(0,size(CONN_h.menus.m_preproc.X1.sampledata,1)*(min(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs)))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs)))))+0-size(xf,2));
                    elseif nnz(CONN_h.menus.m_preproc.select{3}), dof2=max(0,(size(CONN_h.menus.m_preproc.X1.sampledata,1)-size(xf,2)+nnz(CONN_h.menus.m_preproc.select{3}))*(min(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs)))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs)))))+0-nnz(CONN_h.menus.m_preproc.select{3}));
                    else dof2=max(0,(size(CONN_h.menus.m_preproc.X1.sampledata,1)-size(xf,2))*(min(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs)))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsubs)))))+0);
                    end
                    z0=corrcoef(x0);z1=corrcoef(x1);d0=shiftdim(sqrt(sum(abs(conn_bsxfun(@minus, xyz,permute(xyz,[1,3,2]))).^2,1)),1);
                    maskz=z0~=1&z1~=1;
                    z0=z0(maskz);z1=z1(maskz);d0=d0(maskz);
                    [a0,b0]=hist(z0(:),linspace(-1,1,100));[a1,b1]=hist(z1(:),linspace(-1,1,100));
%                     if 0
%                         subplot(211); zt=z0; plot(d0,zt,'k.','markersize',1,'color',.5*[1 1 1]); [nill,idx]=sort(d0); idx(idx)=ceil(20*(1:numel(idx))/numel(idx)); hold on; mzt=accumarray(idx(:),zt(:),[],@mean); szt=accumarray(idx(:),zt(:),[],@std); md0=accumarray(idx(:),d0(:),[],@mean); plot(repmat(md0',2,1),[mzt+szt mzt-szt]','r:',md0,mzt,'ro','markerfacecolor','r','linewidth',3); hold off; set(gca,'color','k');
%                         subplot(212); zt=z1; plot(d0,zt,'k.','markersize',1,'color',.5*[1 1 1]); [nill,idx]=sort(d0); idx(idx)=ceil(20*(1:numel(idx))/numel(idx)); hold on; mzt=accumarray(idx(:),zt(:),[],@mean); szt=accumarray(idx(:),zt(:),[],@std); md0=accumarray(idx(:),d0(:),[],@mean); plot(repmat(md0',2,1),[mzt+szt mzt-szt]','r:',md0,mzt,'ro','markerfacecolor','r','linewidth',3); hold off; set(gca,'color','k');
%                     end
                    if isempty(z0)||isempty(z1), 
                        disp('Warning! Empty correlation data');
                        conn_menu('updatehist',CONN_h.menus.m_preproc_00{16},[]);
                        conn_menu('updatescatter',CONN_h.menus.m_preproc_00{23},[]);
                        if 1,
                            conn_menu('updatematrix',CONN_h.menus.m_preproc_00{26},[]);
                        end
                    else
                        conn_menu('updatehist',CONN_h.menus.m_preproc_00{16},{[b1(1),b1,b1(end)],[0,a1,0],[0,a0,0]});
                        set(CONN_h.menus.m_preproc_00{16}.h6,'string',sprintf('original (%.2f%c%.2f; df=%.1f)',mean(z0(:)),177,std(z0(:)),dof0)); % (df_W_S=%.1f)',dof2,dof1));
                        set(CONN_h.menus.m_preproc_00{16}.h7,'string',sprintf('after denoising (%.2f%c%.2f; df=%.1f)',mean(z1(:)),177,std(z1(:)),dof2)); % (df_W_S=%.1f)',dof2,dof1));
                        if all(isnan(d0))
                            conn_menu('updatescatter',CONN_h.menus.m_preproc_00{23},[]);
                        else
                            th0=conn_hanning(255); th0=th0/sum(th0); [nill,tidx]=sort(d0(:)); t0=convn(z0(tidx),th0,'valid'); t1=convn(z1(tidx),th0,'valid'); td0=convn(d0(tidx),th0,'valid');
                            conn_menu('updatescatter',CONN_h.menus.m_preproc_00{23},{{t0(1:50:end) t1(1:50:end) z0 z1},{td0(1:50:end) td0(1:50:end) d0 d0}});
                            %th0=conn_hanning(11); th0=th0/sum(th0); [td0,tidx]=sort(d0(:)); t0=z0(tidx);t1=z1(tidx); for tn=1:5,t0=convn(t0,th0,'valid');t1=convn(t1,th0,'valid'); td0=convn(td0,th0,'valid'); t0=t0(1:2:end);t1=t1(1:2:end);td0=td0(1:2:end); end
                            %conn_menu('updatescatter',CONN_h.menus.m_preproc_00{23},{{t0 t1 z0 z1},{td0 td0 d0 d0}});
                            set(CONN_h.menus.m_preproc_00{23}.h1,'xlim',[-1 1]);
                            %set(CONN_h.menus.m_preproc_00{21},'string',{'voxel-to-voxel r',['dof(residual) ~ ',num2str(dof,'%.1f')]});
                        end
                        if 1,
                            if size(x0,2)==size(xyz,2)&&~all(isnan(xyz(:)))
                                [nill,idx]=sort(sum(xyz.^2,1),'descend');
                                x0=x0(:,idx); x1=x1(:,idx); xyz=xyz(:,idx);
                            end
                            temp=[x0 nan(size(x0,1),20) x1]';
                            temp=.5+.5*temp/max(abs(temp(:)));
                            temp(isnan(temp))=0;
                            tempA=ind2rgb(round(1+(size(CONN_h.screen.colormap,1)/2-1)*temp),CONN_h.screen.colormap);
                            %temp=repmat(temp,[1,1,3]);
                            %temp=cat(2,temp, nan(size(temp,1),10,3), cat(1,repmat(shiftdim(.75/2*[1,1,1],-1),size(x0,2),10), nan(10,10,3), repmat(shiftdim(1/2*[1,1,0],-1),size(x1,2),10)));
                            tempB=[mean(x0orig,2) mean(x1,2)];
                            conn_menu('updatematrix',CONN_h.menus.m_preproc_00{26},tempA);
                            conn_menu('updateplotstackcenter',CONN_h.menus.m_preproc_00{28},tempB);
                            try, set(CONN_h.menus.m_preproc_00{28}.h4(1),'color',.75/2*[1,1,1]); set(CONN_h.menus.m_preproc_00{28}.h4(2),'color',1/2*[1,1,0]); end
                            CONN_h.menus.m_preproc.tracesA=temp;
                            CONN_h.menus.m_preproc.tracesB=tempB;
                            CONN_h.menus.m_preproc.tracesXYZ=[xyz nan(size(xyz,1),20) xyz]';
                        end
                    end
                else
                    conn_menu('updatehist',CONN_h.menus.m_preproc_00{16},[]);
                    conn_menu('updatescatter',CONN_h.menus.m_preproc_00{23},[]);
                    if 1,
                        conn_menu('updatematrix',CONN_h.menus.m_preproc_00{26},[]);
                    end
                end
			end
			if model,
                if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                    idx=find(CONN_h.menus.m_preproc.select{2});
                    C=eye(size(CONN_h.menus.m_preproc.X,2));
                    if isempty(idx)&&isequal(get(CONN_h.menus.m_preproc_00{13},'value')-1,0), C=C(2:end,:); 
                    else %C=pinv(CONN_h.menus.m_preproc.opt.X(:,[1,idx]))*CONN_h.menus.m_preproc.opt.X; C=C(2:end,:); % unique + shared variance
                        warning('off','MATLAB:rankDeficientMatrix');
                        C=CONN_h.menus.m_preproc.opt.X(:,[1,idx])\CONN_h.menus.m_preproc.opt.X; C=C(2:end,:); % unique + shared variance
                        warning('on','MATLAB:rankDeficientMatrix');
                        %C=C(idx,:);  % unique variance
                    end
                    if isempty(C)
                        conn_menu('update',CONN_h.menus.m_preproc_00{14},[]);
                        conn_menu('update',CONN_h.menus.m_preproc_00{29},[]);
                    else
                        [h,F,p,dof,R]=conn_glmunivariate('evaluate',CONN_h.menus.m_preproc.opt,[],C);
                        if isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface, issurface=true; else issurface=false; end
                        t1=zeros(CONN_h.menus.m_preproc.Y.matdim.dim(1:2+issurface));
                        t2=nan+zeros(CONN_h.menus.m_preproc.Y.matdim.dim(1:2+issurface));
                        t1(CONN_h.menus.m_preproc.y.idx)=abs(R);
                        t2(CONN_h.menus.m_preproc.y.idx)=abs(R);
                        if isfield(CONN_h.menus.m_preproc.Y,'issurface')&&CONN_h.menus.m_preproc.Y.issurface
                            if ~CONN_h.menus.m_preproc_surfhires
                                t1=[t1(CONN_gui.refs.surf.default2reduced) t1(numel(t1)/2+CONN_gui.refs.surf.default2reduced)];
                                t2=[t2(CONN_gui.refs.surf.default2reduced) t2(numel(t2)/2+CONN_gui.refs.surf.default2reduced)];
                                conn_menu('update',CONN_h.menus.m_preproc_00{14},{CONN_gui.refs.surf.defaultreduced,t1,t2},{CONN_h.menus.m_preproc.Y.matdim,CONN_h.menus.m_preproc.y.slice});
                                conn_menu('update',CONN_h.menus.m_preproc_00{29},[]);
                            else
                                conn_menu('update',CONN_h.menus.m_preproc_00{14},{CONN_gui.refs.surf.default,t1,t2},{CONN_h.menus.m_preproc.Y.matdim,CONN_h.menus.m_preproc.y.slice});
                                conn_menu('update',CONN_h.menus.m_preproc_00{29},[]);
                            end
                        else
                            t1=permute(t1,[2,1,3]);
                            t2=permute(t2,[2,1,3]);
                            conn_menu('update',CONN_h.menus.m_preproc_00{14},{CONN_h.menus.m_preproc.Xs,t1,t2},{CONN_h.menus.m_preproc.Y.matdim,CONN_h.menus.m_preproc.y.slice});
                            conn_callbackdisplay_denoisingclick;
                            %conn_menu('update',CONN_h.menus.m_preproc_00{29},[]);
                        end
                        %f=conn_hanning(5)/sum(conn_hanning(5)); t1=convn(convn(convn(t1,f,'same'),f','same'),shiftdim(f,-2),'same');
                        %f=conn_hanning(5)/sum(conn_hanning(5)); t2=convn(convn(convn(t2,f,'same'),f','same'),shiftdim(f,-2),'same');
                        %t(CONN_h.menus.m_preproc.Y.voxels)=sqrt(sum(abs(CONN_h.menus.m_preproc.B(find(CONN_h.menus.m_preproc.select{2}),:)).^2,1))';
                    end
                else
                    conn_menu('update',CONN_h.menus.m_preproc_00{14},[]);
                    conn_menu('update',CONN_h.menus.m_preproc_00{29},[]);
                end
            else conn_callbackdisplay_denoisingclick;
            end
			
		case 'gui_preproc_done',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            if conn_questdlgrun('Ready to run Denoising pipeline',[],CONN_x.Setup.steps(1:3),[],[],true,[],true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                if CONN_x.gui.parallel~=0, 
                    ispending=isequal(CONN_x.gui.parallel,find(strcmp('Null profile',conn_jobmanager('profiles'))));
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    if isfield(CONN_x.gui,'subjects'), subjects=CONN_x.gui.subjects; else subjects=[]; end
                    conn save;
                    conn_jobmanager('submit','denoising_gui',subjects,[],CONN_x.gui);
                else conn_process('denoising_gui'); ispending=false;
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                if ~conn_projectmanager('ispending')&&~ispending, conn('gui_analysesgo',[]); end
            end
			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
        case 'gui_analysesgo',
            state=varargin{2};
            tstate=conn_menumanager(CONN_h.menus.m_analyses_03,'state'); tstate(:)=0;tstate(state)=1; conn_menumanager(CONN_h.menus.m_analyses_03,'state',tstate); 
            conn gui_analyses;
            
		case 'gui_analyses',
            CONN_x.gui=1;
			model=0;
            if ~isfield(CONN_x,'Analysis')||~CONN_x.Analysis, CONN_x.Analysis=1; end
            ianalysis=CONN_x.Analysis;
            if ianalysis>numel(CONN_x.Analyses)||~isfield(CONN_x.Analyses(ianalysis),'name'),
                txt=inputdlg('New analysis name (alphanumeric case sensitive):','conn',1,{['ANALYSIS_',num2str(ianalysis,'%02d')]});
                if isempty(txt), return; end
                txt{1}=regexprep(txt{1},'[^\w\d_]','');
                if isempty(txt{1}), return; end
                CONN_x.Analyses(ianalysis).name=txt{1}; 
                if ianalysis==1, conn_process denoising_finish; end
            end
            if ~isfield(CONN_x,'vvAnalysis')||~CONN_x.vvAnalysis, CONN_x.vvAnalysis=1; end
            if CONN_x.vvAnalysis>numel(CONN_x.vvAnalyses)||~isfield(CONN_x.vvAnalyses(CONN_x.vvAnalysis),'name'),
                txt=inputdlg('New analysis name (alphanumeric case sensitive):','conn',1,{['V2V_',num2str(CONN_x.vvAnalysis,'%02d')]});
                if isempty(txt), return; end
                txt{1}=regexprep(txt{1},'[^\w\d_]','');
                if isempty(txt{1}), return; end
                CONN_x.vvAnalyses(CONN_x.vvAnalysis).name=txt{1}; 
                if CONN_x.vvAnalysis==1, conn_process denoising_finish; end
            end
            if ~isfield(CONN_x,'dynAnalysis')||~CONN_x.dynAnalysis, CONN_x.dynAnalysis=1; end
            if CONN_x.dynAnalysis>numel(CONN_x.dynAnalyses)||~isfield(CONN_x.dynAnalyses(CONN_x.dynAnalysis),'name'),
                txt=inputdlg('New analysis name (alphanumeric case sensitive):','conn',1,{['DYN_',num2str(CONN_x.dynAnalysis,'%02d')]});
                if isempty(txt), return; end
                txt{1}=regexprep(txt{1},'[^\w\d_]','');
                if isempty(txt{1}), return; end
                CONN_x.dynAnalyses(CONN_x.dynAnalysis).name=txt{1}; 
                if CONN_x.dynAnalysis==1, conn_process denoising_finish; end
            end
            state=find(conn_menumanager(CONN_h.menus.m_analyses_03,'state'));
            if isempty(state), 
                if nargin<2
                    conn_menumanager clf;
                    conn_menuframe;
                    tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(3)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate);
                    conn_menu('frame2border',[.0,.955,1,.045],'');
                    conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                    conn_menumanager([CONN_h.menus.m_analyses_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                    conn_menu('nullstr',{'No data','to display'});
                    
                    [nill,temp]=conn_menu('frame2noborder',[.16 .54 .23 .31],'All analyses'); set(temp,'horizontalalignment','left');
                    txt={CONN_x.Analyses(:).name};
                    if 1, CONN_h.menus.m_analyses.shownanalyses=find(cellfun(@(x)isempty(regexp(x,'^(.*\/|.*\\)?Dynamic factor .*\d+$')),txt)); 
                    else CONN_h.menus.m_analyses.shownanalyses=1:numel(txt); 
                    end
                    CONN_h.menus.m_analyses_00{1}=conn_menu('listbox2',[.165 .85-5*.06*1/3 .22 5*.06*1/3],'',{CONN_x.Analyses(CONN_h.menus.m_analyses.shownanalyses).name, '<HTML><i>new</i></HTML>'},'List of already defined first-level ROI-to-ROI or Seed-to-Voxel analyses','conn(''gui_analyses'',1);');
                    set(CONN_h.menus.m_analyses_00{1},'max',2,'value',[]);
                    CONN_h.menus.m_analyses_00{2}=conn_menu('listbox2',[.165 .85-5*.06*2/3 .22 5*.06*1/3],'',{CONN_x.vvAnalyses(:).name, '<HTML><i>new</i></HTML>'},'List of already defined first-level Voxel-to-Voxel or ICA analyses','conn(''gui_analyses'',2);');
                    set(CONN_h.menus.m_analyses_00{2},'max',2,'value',[]);
                    CONN_h.menus.m_analyses_00{3}=conn_menu('listbox2',[.165 .85-5*.06*3/3 .22 5*.06*1/3],'',{CONN_x.dynAnalyses(:).name, '<HTML><i>new</i></HTML>'},'List of already defined first-level dyn-ICA analyses','conn(''gui_analyses'',3);');
                    set(CONN_h.menus.m_analyses_00{3},'max',2,'value',[]);
                    hax=conn_menu('axes',[.115 .85-5*.06 .03 5*.06]);
                    plot([0 1 nan 0 1 nan 0 1 nan 1 1 nan 1 1 nan 1 1],[0.5/5 0.5/3 nan 2/5 1.5/3 nan 4/5 2.5/3 nan .1/3 .9/3 nan 1.1/3 1.9/3 nan 2.1/3 2.9/3],'-','color',CONN_gui.fontcolorB,'linewidth',2,'parent',hax);
                    set(hax,'xlim',[0 1],'ylim',[0 1],'visible','off');
                else
                    switch(varargin{2}),
                        case 1, value=get(CONN_h.menus.m_analyses_00{1},'value'); if ~isempty(value), CONN_x.Analysis=CONN_h.menus.m_analyses.shownanalyses(min(numel(CONN_h.menus.m_analyses.shownanalyses),value(1))); conn('gui_analysesgo',1); if value(1)>numel(CONN_h.menus.m_analyses.shownanalyses), conn('gui_analyses',20,'new'); end; end
                        case 2, value=get(CONN_h.menus.m_analyses_00{2},'value'); if ~isempty(value), CONN_x.vvAnalysis=min(numel(CONN_x.vvAnalyses),value(1)); conn('gui_analysesgo',2); if value(1)>numel(CONN_x.vvAnalyses), conn('gui_analyses',20,'new'); end; end
                        case 3, value=get(CONN_h.menus.m_analyses_00{3},'value'); if ~isempty(value), CONN_x.dynAnalysis=min(numel(CONN_x.dynAnalyses),value(1)); conn('gui_analysesgo',3); if value(1)>numel(CONN_x.dynAnalyses), conn('gui_analyses',20,'new'); end; end
                    end
                end
                return;
            end
            states={[1,2],3,4};istates=[1,1,2,3]; state=states{state};
            if ~any(CONN_x.Setup.steps(state))
                state=find(CONN_x.Setup.steps,1,'first');
                if isempty(state)||state>3, conn_msgbox('No ROI-to-ROI, seed-to-voxel, or voxel-to-voxel analyses prepared. Select these options in ''Setup->Options'' to perform additional analyses','',2); return; end %conn gui_setup; return; end
                tstate=zeros(size(conn_menumanager(CONN_h.menus.m_analyses_03,'state')));tstate(istates(state))=1;
                conn_menumanager(CONN_h.menus.m_analyses_03,'state',tstate); 
            end
            if state(1)==1, %SEED-TO-VOXEL or ROI-TO-ROI
                boffset=[.02 .03 0 0];
                if nargin<2,
                    if ~any(CONN_x.Setup.steps(state)), conn_msgbox('No seed-to-voxel or ROI-to-ROI analyses computed. Select these options in ''Setup->Options'' to perform additional analyses','',2); return; end %conn gui_setup; return; end
                    conn_menumanager clf;
                    conn_menuframe;
                    tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(3)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate);
                    conn_menu('frame2border',[.0,.955,1,.045],'');
                    %conn_menu('frame2border',[.0,.0,.115,.94]);
                    conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                    conn_menumanager([CONN_h.menus.m_analyses_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                    conn_menu('nullstr',{'No data','to display'});
                    
                    %conn_menu('frame',boffset+[.095,.24,.35,.56],'FC ANALYSIS OPTIONS');
                    %conn_menu('frame',boffset+[.095,.08,.35,.155]);
                    conn_menu('frame',boffset+[.135,.08,.395,.75],' ');%,'First-level analyses');%'FC ANALYSIS OPTIONS');
                    %conn_menu('title2',boffset+[.115,.825,.19,.04],'First-level analysis:');
                    txt=strvcat(CONN_x.Analyses(:).name,'<HTML><i>new</i></HTML>','<HTML><i>rename</i></HTML>','<HTML><i>delete</i></HTML>');
                    CONN_h.menus.m_analyses_00{20}=conn_menu('popupbigblue',boffset+[.135,.83,.395,.05],'',txt(ianalysis,:),'<HTML>Analysis name <br/> - Select existing first-level analysis name to edit its properties <br/> - select <i>new/rename/delete</i> to define a new set of first-level analyses within this project, or the rename or delete the selected analysis</HTML>','conn(''gui_analyses'',20);');
                    %CONN_h.menus.m_analyses_00{20}=conn_menu('popup2',[.005,.78,.125,.04],'Analysis name:',txt(ianalysis,:),'<HTML>Analysis name <br/> - Select existing first-level analysis name to edit its properties <br/> - select <i>new</i> to define a new set of first-level analyses within this project</HTML>','conn(''gui_analyses'',20);');
                    set(CONN_h.menus.m_analyses_00{20},'string',txt,'value',ianalysis);%,'fontsize',12+CONN_gui.font_offset);%,'fontweight','bold');
                    if ~isempty(regexp(CONN_x.Analyses(ianalysis).name,'^_','once')), return; end %non-visible analyses (manually-defined data)
                    
                    analysistypes=[{'functional connectivity (weighted GLM)','task-modulation effects (gPPI)','temporal-modulation effects (dyn-ICA)','other temporal-modulation effects'}];%,cellfun(@(x)['gPPI: interaction with covariate ''',x,''''],CONN_x.Setup.l1covariates.names(1:end-1),'uni',0)];
                    CONN_h.menus.m_analyses_00{10}=conn_menu('popup',boffset+[.145,.73,.31,.04],'Analysis type',analysistypes,['<HTML>Choose first-level model between the seed/source BOLD timeseries and each target ROI or voxel BOLD timeseries <br/>',...
                        ' - select <i><b>weighted GLM</b></i> for raw or weighted correlation/regression analyses (standard resting-state or task/condition-specific functional connectivity measures)<br/>',...
                        ' - select <i><b>gPPI</b></i> for Generalized PsychoPhysiological Interaction models (task-modulation of functional connectivity; task-effects defined in <i>Setup.Conditions</i>) <br/>',...
                        ' - select <i><b>dyn-ICA</b></i> for dynamic connectivity analyses (PPI model with modulatory effects defined in <i>First-level.dyn-ICA</i>) <br/>',...
                        ' - select <i><b>other temporal-modulation</b></i> for user-defined temporal-modulation effects (e.g. PhysioPhysiological Interactions) (PPI model with modulatory effects defined in <i>Setup.ROIs</i> or <i>Setup.Covariates1st-level</i>)</HTML>'],'conn(''gui_analyses'',10);');
                    CONN_h.menus.m_analyses_00{9}=conn_menu('popup',boffset+[.145,.69,.31,.04],'',{'ROI-to-ROI analyses only','Seed-to-Voxel analyses only','ROI-to-ROI and Seed-to-Voxel analyses'},'Choose type of connectivity analysis (seed-to-voxel and/or ROI-to-ROI)','conn(''gui_analyses'',9);');
                    connmeasures={'correlation (bivariate)','correlation (semipartial)','regression (bivariate)','regression (multivariate)'};
                    CONN_h.menus.m_analyses_00{7}=conn_menu('popup',boffset+[.145,.60,.18,.04],'Analysis options',connmeasures,'<HTML>Choose outcome measure for second level analyses <br/> - <i>bivariate</i> measures are computed separately for each pair of source&target ROIs (ROI-to-ROI analyses)<br/> or for each pair of source ROI and target voxel (seed-to-voxel analyses)<br/> - <i>semipartial</i> and <i>multivariate</i> measures are computed entering all the chosen source ROIs simultaneously <br/>into a single predictive model (separately for each target ROI/voxel) <br/> - <i>correlation</i> measures output Fisher-transformed correlation-coefficients (bivariate or semipartial) and <br/>are typically associated with measures of <i>functional</i> connectivity<br/> - <i>regression</i> measures output regression coefficients (bivariate or multivariate) and are typically associated <br/>with measures of <i>effective</i> connectivity</HTML>','conn(''gui_analyses'',7);');
                    CONN_h.menus.m_analyses_00{8}=conn_menu('popup',boffset+[.145,.56,.18,.04],'',{'no weighting','hrf weighting','hanning weighting','task/condition factor'},'<HTML>Choose method for weighting scans/samples within each condition block when computing condition-specific connectivity measures (for weighted GLM analyses only) <br/> - <b>no weighting</b> uses binary 0/1 weights identifying scans associated with each condition<br/> - <b>hrf weights</b> additionally convolves the above binary weights with a canonical hemodynamic response function<br/> - <b>hanning weights</b> uses instead a hanning window across within-condition scans/samples  as weights (focusing only on center segment within each block)<br/> - <b>task/condition factor</b> uses instead the factor timeseries defined in <i>Setup.Conditions.TaskModulationFactor</i> as weights (for other user-defined weighting)</HTML>','conn(''gui_analyses'',8);');
                    
                    %[nill,CONN_h.menus.m_analyses_00{16}]=conn_menu('text',boffset+[.125,.48,.26,.05],'Functional connectivity seeds/sources:');
                    %set(CONN_h.menus.m_analyses_00{16},'horizontalalignment','left');
                    CONN_h.menus.m_analyses_00{1}=conn_menu('listbox',boffset+[.36,.31,.155,.18],'all ROIs','','List of all seeds/ROIs','conn(''gui_analyses'',1);');
                    CONN_h.menus.m_analyses_00{2}=conn_menu('listbox',boffset+[.145,.31,.195,.18],'Seeds/Sources','','<HTML>List of seeds/ROIs to be included in this analysis  <br/> - Connectivity measures will be computed among all selected ROIs (for ROI-to-ROI analyses) and/or between the selected ROIs and all brain voxels (seed-to-voxel analyses) <br/> - Select ROIs in the <i>all ROIs</i> list and click <b> &lt </b> to add new sources to this list<br/> - Select ROIs in this list and click <b> &gt </b> to remove them from this list </HTML>','conn(''gui_analyses'',2);');
                    CONN_h.menus.m_analyses_00{30}=conn_menu('pushbutton',boffset+[.34,.31,.02,.18],'','<','move elements between ''Seeds/Sources'' and ''all ROIs'' lists', 'conn(''gui_analyses'',0);');
                    CONN_h.menus.m_analyses_00{6}=conn_menu('edit',boffset+[.38,.19,.15,.04],'Source dimensions','','Number of dimensions/components of selected source','conn(''gui_analyses'',6);');
                    CONN_h.menus.m_analyses_00{4}=conn_menu('popup',boffset+[.38,.15,.15,.04],'',{'no temporal expansion','add 1st-order derivatives','add 2nd-order derivatives'},'<HTML>Temporal/Taylor expansion of regressor timeseries<br/> - Include temporal derivates up to n-th order of selected effect<br/> - [x] for no expansion<br/> - [x, dx/dt] for first-order derivatives<br/> - [x, dx/dt, d2x/dt2] for second-order derivatives </HTML>','conn(''gui_analyses'',4);');
                    CONN_h.menus.m_analyses_00{5}=conn_menu('popup',boffset+[.38,.11,.15,.04],'',{'no frequency decomposition','frequency decomposition'},'Number of frequency bands for BOLD signal spectral decomposition of selected source (''no decomposition'' for single-band covering entire band-pass filtered data)','conn(''gui_analyses'',5);');
                    CONN_h.menus.m_analyses_00{19}=conn_menu('popup',boffset+[.22,.22,.16,.04],'',{'Source timeseries','First-level analysis design matrix'},'<HTML>Choose display type<br/> - <i>Source timeseries</i> displays the BOLD signal timeseries for the selected source/subject/session<br/> - <i>Design matrix</i> displays the scans-by-regressors first-level design matrix for the selected <br/> source/subject/session (highlighted the regressor of interest for second-level analyses)</HTML>','conn(''gui_analyses'',19);');
                    CONN_h.menus.m_analyses_00{3}=conn_menu('image',boffset+[.155,.09,.205,.12],'');%'Source timeseries');
                    CONN_h.menus.m_analyses_00{22}=[...%uicontrol('style','frame','units','norm','position',boffset+[.405,.30,.125,.33],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA),...
                        uicontrol('style','frame','units','norm','position',boffset+[.135,.08,.38,.23],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA)];
                    CONN_h.menus.m_analyses_00{23}=uicontrol('style','frame','units','norm','position',boffset+[.34,.31,.175,.24],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA);
                    conn_menumanager('onregion',CONN_h.menus.m_analyses_00{23},-1,boffset+[.145 .31 .38 .24]);
                    conn_menu('frame2',boffset+[.565,.040,.41,.8],'Preview first-level analysis results');
                    CONN_h.menus.m_analyses_00{11}=conn_menu('listbox2',boffset+[.90,.48,.075,.17],'Subjects','','Select subject to display','conn(''gui_analyses'',11);');
                    CONN_h.menus.m_analyses_00{12}=conn_menu('listbox2',boffset+[.90,.23,.075,.17],'Conditions','','Select condition to display','conn(''gui_analyses'',12);');
                    %CONN_h.menus.m_analyses_00{13}=conn_menu('listbox',boffset+[.62,.11,.075,.64],'Sources','','Select source to display','conn(''gui_analyses'',13);');
                    CONN_h.menus.m_analyses_00{13}=conn_menu('popup2',boffset+[.67,.80,.23,.04],'',{' TOTAL'},'Select seed/source to display','conn(''gui_analyses'',13);');
                    pos=[.65,.30,.20,.40];
                    if any(CONN_x.Setup.steps([2,3])),
                        uicontrol('style','text','units','norm','position',boffset+[pos(1)+pos(3)/2-.070,pos(2)-1*.06,.070,.045],'string','threshold','fontname','default','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolor,'foregroundcolor',CONN_gui.fontcolorA,'tooltipstring','only results with absolute effect sizes above this threshold value are displayed');
                        CONN_h.menus.m_analyses_00{15}=conn_menu('slider',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'','','z-slice','conn(''gui_analyses'',15);');
                        try, addlistener(CONN_h.menus.m_analyses_00{15}, 'ContinuousValueChange',@(varargin)conn('gui_analyses',15)); end
                        set(CONN_h.menus.m_analyses_00{15},'visible','off');
                        conn_menumanager('onregion',CONN_h.menus.m_analyses_00{15},1,boffset+pos+[0 0 .015 0]);
                        %CONN_h.menus.m_analyses_00{15}=uicontrol('style','slider','units','norm','position',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'callback','conn(''gui_analyses'',15);','backgroundcolor',CONN_gui.backgroundcolorA);
                    end
                    conn_callbackdisplay_firstlevelclick([]);
                    CONN_h.menus.m_analyses_00{14}=conn_menu('image2',boffset+pos,' ','','',[],@conn_callbackdisplay_firstlevelclick);
                    conn_menu('nullstr',' '); 
                    CONN_h.menus.m_analyses_00{29}=conn_menu('image2',boffset+pos+[.02 -.18 -.02 -pos(4)+.07],'voxel BOLD timeseries');
                    %conn_menu('frame',[2*.91/4,.89,.91/4,.05],'');
                    if ~isfield(CONN_x.Analyses(ianalysis).variables,'names')||isempty(CONN_x.Analyses(ianalysis).variables.names), 
                        %conn_menumanager clf;
                        %conn_menuframe;
                        %conn_menumanager([CONN_h.menus.m_analyses_02,CONN_h.menus.m_analyses_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                        conn_msgbox({'Not ready to start first-level Analysis step',' ','Please complete the Denoising step first','(fill any required information and press "Done" in the Denoising tab)'},'',2); 
                        CONN_h.menus.m_analyses.isready=false;
                        %conn gui_preproc; 
                        %return; 
                    else
                        CONN_h.menus.m_analyses.isready=true;
                    end
                    if ~isfield(CONN_x.Analyses(ianalysis),'modulation') || isempty(CONN_x.Analyses(ianalysis).modulation), CONN_x.Analyses(ianalysis).modulation=0; end
                    if ~isfield(CONN_x.Analyses(ianalysis),'measure') || isempty(CONN_x.Analyses(ianalysis).measure), CONN_x.Analyses(ianalysis).measure=1; end
                    if ~isfield(CONN_x.Analyses(ianalysis),'weight') || isempty(CONN_x.Analyses(ianalysis).weight), CONN_x.Analyses(ianalysis).weight=2; end
                    if ~isfield(CONN_x.Analyses(ianalysis),'type') || isempty(CONN_x.Analyses(ianalysis).type), CONN_x.Analyses(ianalysis).type=3; end
                    set(CONN_h.menus.m_analyses_00{7},'value',CONN_x.Analyses(ianalysis).measure);
                    if ischar(CONN_x.Analyses(ianalysis).modulation), if ~isempty(regexp(CONN_x.Analyses(ianalysis).modulation,'^(.*\/|.*\\)?Dynamic factor \d+$')), value=3; else value=4; end; else value=CONN_x.Analyses(ianalysis).modulation+1; end
                    set(CONN_h.menus.m_analyses_00{10},'value',value);
                    set(CONN_h.menus.m_analyses_00{8},'value',CONN_x.Analyses(ianalysis).weight);
                    set(CONN_h.menus.m_analyses_00{9},'value',CONN_x.Analyses(ianalysis).type);
                    set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'max',2);
                    tnames=CONN_x.Analyses(ianalysis).variables.names;
                    tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names)),'uni',0);
                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.Analyses(ianalysis).regressors.names);
                    %conn_menumanager(CONN_h.menus.m_analyses_01,'on',1);
                    if ~isempty(CONN_x.Analyses(ianalysis).regressors.names), set(CONN_h.menus.m_analyses_00{2},'value',1); set(CONN_h.menus.m_analyses_00{13},'value',2); end
                    if 0&&~isempty(tnames), set(CONN_h.menus.m_analyses_00{1},'value',[]);set(CONN_h.menus.m_analyses_00{2},'value',1);
                    else set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'value',[]);%set(CONN_h.menus.m_analyses_00{13},'value',1);
                    end
                    %set(CONN_h.menus.m_analyses_00{4},'visible','off');%
                    %set(CONN_h.menus.m_analyses_00{5},'visible','off');%
                    %set(CONN_h.menus.m_analyses_00{6},'visible','off');%
                    set([CONN_h.menus.m_analyses_00{11},CONN_h.menus.m_analyses_00{12},CONN_h.menus.m_analyses_00{13}],'max',1);
                    set(CONN_h.menus.m_analyses_00{11},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')]);
                    nconditions=length(CONN_x.Setup.conditions.names)-1;
                    set(CONN_h.menus.m_analyses_00{12},'string',{CONN_x.Setup.conditions.names{1:end-1}},'value',min(nconditions,get(CONN_h.menus.m_analyses_00{12},'value')));
                    set(CONN_h.menus.m_analyses_00{13},'string',{' TOTAL',CONN_x.Analyses(ianalysis).regressors.names{:}});
                    %set(CONN_h.screen.hfig,'pointer','watch');

                    %[path,name,ext]=fileparts(CONN_x.filename);
                    % 				filepath=fullfile(path,name,'data');
                    CONN_h.menus.m_analyses_surfhires=0;
                    icondition=[];isnewcondition=[];for ncondition=1:nconditions,[icondition(ncondition),isnewcondition(ncondition)]=conn_conditionnames(CONN_x.Setup.conditions.names{ncondition}); end
                    if any(isnewcondition), 
                        conn_msgbox({'Not ready to start first-level Analysis step',' ',sprintf('Some conditions (%s) have not been processed yet. Please re-run previous step (Denoising)',sprintf('%s ',CONN_x.Setup.conditions.names{isnewcondition>0}))},'',2); 
                        %conn gui_preproc; 
                        %return; 
                    end
                    CONN_h.menus.m_analyses.icondition=icondition;
                    if CONN_h.menus.m_analyses.isready
                        filepath=CONN_x.folders.preprocessing;
                        if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                            filename=fullfile(filepath,['DATA_Subject',num2str(1,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(1),'%03d'),'.mat']);
                            CONN_h.menus.m_analyses.Y=conn_vol(filename);
                            if isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface, %isequal(CONN_h.menus.m_analyses.Y.matdim.dim,conn_surf_dims(8).*[1 1 2])
                                CONN_h.menus.m_analyses.y.slice=1;
                                if CONN_h.menus.m_analyses_surfhires
                                    [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_volume(CONN_h.menus.m_analyses.Y);
                                else
                                    [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,1);
                                    [tempdata,tempidx]=conn_get_slice(CONN_h.menus.m_analyses.Y,conn_surf_dims(8)*[0;0;1]+1);
                                    CONN_h.menus.m_analyses.y.data=[CONN_h.menus.m_analyses.y.data(:,CONN_gui.refs.surf.default2reduced) tempdata(:,CONN_gui.refs.surf.default2reduced)];
                                    CONN_h.menus.m_analyses.y.idx=[CONN_h.menus.m_analyses.y.idx(CONN_gui.refs.surf.default2reduced);prod(conn_surf_dims(8))+tempidx(CONN_gui.refs.surf.default2reduced)];
                                end
                                set(CONN_h.menus.m_analyses_00{15},'visible','off');
                                conn_menumanager('onregionremove',CONN_h.menus.m_analyses_00{15});
                            else
                                CONN_h.menus.m_analyses.y.slice=ceil(CONN_h.menus.m_analyses.Y.matdim.dim(3)/2);
                                [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.slice);
                            end
                        end
                        filename=fullfile(filepath,['ROI_Subject',num2str(1,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(1),'%03d'),'.mat']);
                        CONN_h.menus.m_analyses.X1=load(filename);
                        %                     CONN_h.menus.m_analyses.ConditionWeights={};
                        %                     for ncondition=1:nconditions,
                        %                         for nsub=1:CONN_x.Setup.nsubjects,
                        %                             filename=fullfile(filepath,['ROI_Subject',num2str(nsub,'%03d'),'_Condition',num2str(icondition(ncondition),'%03d'),'.mat']);
                        %                             X1=load(filename,'conditionweights');
                        %                             for n1=1:numel(X1.conditionweights)
                        %                                 CONN_h.menus.m_analyses.ConditionWeights{nsub,n1}(:,ncondition)=X1.conditionweights{n1};
                        %                             end
                        %                         end
                        %                     end
                        if any(CONN_x.Setup.steps([2,3]))
                            if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                                try
                                    CONN_h.menus.m_analyses.XS=spm_vol(deblank(CONN_x.Setup.structural{1}{1}{1}));
                                catch
                                    CONN_h.menus.m_analyses.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                                end
                                xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                                CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                                CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                                set(CONN_h.menus.m_analyses_00{15},'min',1,'max',CONN_h.menus.m_analyses.Y.matdim.dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_analyses.Y.matdim.dim(3)-1)),'value',CONN_h.menus.m_analyses.y.slice);
                            else
                                CONN_h.menus.m_analyses.y.slice=max(1,min(4,CONN_h.menus.m_analyses.y.slice));
                            end
                        end
                        conn_menumanager([CONN_h.menus.m_analyses_02],'on',1);
                    end
                    model=1;
                else
                    switch(varargin{2}),
                        case 0,
                            str=get(CONN_h.menus.m_analyses_00{30},'string');
                            %str=conn_menumanager(CONN_h.menus.m_analyses_01,'string');
                            switch(str),
                                case '<',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{1},'value');
                                    for ncovariate=ncovariates(:)',
                                        if isempty(strmatch(CONN_x.Analyses(ianalysis).variables.names{ncovariate},CONN_x.Analyses(ianalysis).regressors.names,'exact')),
                                            CONN_x.Analyses(ianalysis).regressors.names{end+1}=CONN_x.Analyses(ianalysis).variables.names{ncovariate};
                                            CONN_x.Analyses(ianalysis).regressors.types{end+1}=CONN_x.Analyses(ianalysis).variables.types{ncovariate};
                                            CONN_x.Analyses(ianalysis).regressors.deriv{end+1}=CONN_x.Analyses(ianalysis).variables.deriv{ncovariate};
                                            CONN_x.Analyses(ianalysis).regressors.fbands{end+1}=CONN_x.Analyses(ianalysis).variables.fbands{ncovariate};
                                            CONN_x.Analyses(ianalysis).regressors.dimensions{end+1}=CONN_x.Analyses(ianalysis).variables.dimensions{ncovariate};
                                        end
                                    end
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.Analyses(ianalysis).regressors.names);
                                    set(CONN_h.menus.m_analyses_00{13},'string',{' TOTAL',CONN_x.Analyses(ianalysis).regressors.names{:}});
                                    tnames=CONN_x.Analyses(ianalysis).variables.names;
                                    tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names)),'uni',0);
                                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                                case '>',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{2},'value');
                                    idx=setdiff(1:length(CONN_x.Analyses(ianalysis).regressors.names),ncovariates);
                                    CONN_x.Analyses(ianalysis).regressors.names={CONN_x.Analyses(ianalysis).regressors.names{idx}};
                                    CONN_x.Analyses(ianalysis).regressors.types={CONN_x.Analyses(ianalysis).regressors.types{idx}};
                                    CONN_x.Analyses(ianalysis).regressors.deriv={CONN_x.Analyses(ianalysis).regressors.deriv{idx}};
                                    CONN_x.Analyses(ianalysis).regressors.fbands={CONN_x.Analyses(ianalysis).regressors.fbands{idx}};
                                    CONN_x.Analyses(ianalysis).regressors.dimensions={CONN_x.Analyses(ianalysis).regressors.dimensions{idx}};
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.Analyses(ianalysis).regressors.names,'value',min(max(ncovariates),length(CONN_x.Analyses(ianalysis).regressors.names)));
                                    set(CONN_h.menus.m_analyses_00{13},'string',{' TOTAL',CONN_x.Analyses(ianalysis).regressors.names{:}},'value',min(max(get(CONN_h.menus.m_analyses_00{13},'value')),length(CONN_x.Analyses(ianalysis).regressors.names)+1));
                                    tnames=CONN_x.Analyses(ianalysis).variables.names;
                                    tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.Analyses(ianalysis).variables.names,CONN_x.Analyses(ianalysis).regressors.names)),'uni',0);
                                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                            end
                            model=1;
                        case 1,
                            set(CONN_h.menus.m_analyses_00{30},'string','<');
                            %conn_menumanager(CONN_h.menus.m_analyses_01,'string',{'<'},'on',1);
                            set(CONN_h.menus.m_analyses_00{2},'value',[]);
                            set(CONN_h.menus.m_analyses_00{22},'visible','on');
                            %set([CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6}],'visible','off');%
                        case 2,
                            set(CONN_h.menus.m_analyses_00{30},'string','>');
                            %conn_menumanager(CONN_h.menus.m_analyses_01,'string',{'>'},'on',1);
                            set(CONN_h.menus.m_analyses_00{1},'value',[]);
                            set(CONN_h.menus.m_analyses_00{22},'visible','off');
                            %set([CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6}],'visible','on');%
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            if numel(nregressors)==1, 
                                set(CONN_h.menus.m_analyses_00{13},'value',nregressors+1);
                                model=2;
                            end
                        case 4,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{4},'value')-1;
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.Analyses(ianalysis).regressors.deriv{nregressor}=round(max(0,min(2,value))); end; end
                            model=1;
                        case 5,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{5},'value');
                            if ~isfield(CONN_h.menus.m_analyses.X1,'fbdata')
                                answ=conn_questdlg({'To use this feature you need to first re-run the ROI-based Denoising step.','Do you want to do this now?'},'','Yes','No','Yes');
                                if strcmp(answ,'Yes'),
                                    conn_process('preprocessing_roi');
                                    nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                                    nconditions=get(CONN_h.menus.m_analyses_00{12},'value');
                                    filepath=CONN_x.folders.preprocessing;
                                    filename=fullfile(filepath,['ROI_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                                    CONN_h.menus.m_analyses.X1=load(filename);
                                else value=1;
                                end
                            end
                            if value>1
                                answ=num2str(max([1 CONN_x.Analyses(ianalysis).regressors.fbands{:}]));
                                answ=inputdlg('Number of frequency bands','',1,{answ});
                                if numel(answ)==1,
                                    answ=str2num(answ{1});
                                    if numel(answ)==1&&answ>0, value=round(answ);
                                    end
                                end
                            end
                            for nregressor=nregressors(:)',
                                CONN_x.Analyses(ianalysis).regressors.fbands{nregressor}=max(1,min(numel(CONN_h.menus.m_analyses.X1.fbdata{1}),round(value)));
                            end
                            model=1;
                        case 6,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{6},'string'));
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.Analyses(ianalysis).regressors.dimensions{nregressor}(1)=round(max(1,min(CONN_x.Analyses(ianalysis).regressors.dimensions{nregressor}(2),value))); end; end
                            model=1;
                        case 7,
                            CONN_x.Analyses(ianalysis).measure=get(CONN_h.menus.m_analyses_00{7},'value');
                            model=1;
                        case 8,
                            CONN_x.Analyses(ianalysis).weight=get(CONN_h.menus.m_analyses_00{8},'value');
                            model=1;
                        case 9,
                            CONN_x.Analyses(ianalysis).type=get(CONN_h.menus.m_analyses_00{9},'value');
                            model=1;
                        case 10,
                            value=get(CONN_h.menus.m_analyses_00{10},'value');
                            if value==2 % gPPI
                                CONN_x.Analyses(ianalysis).modulation=1;
                                names=CONN_x.Setup.conditions.names(1:end-1);
                                cnames=CONN_x.Analyses(ianalysis).conditions;
                                if isempty(cnames), value=1:numel(names); 
                                else value=find(ismember(names,cnames)); 
                                end
                                value=listdlg('liststring',names,'selectionmode','multiple','initialvalue',value,'promptstring',{'Select TASK conditions of interest:',' ','notes:','  - Select all task conditions that you wish to simultaneously model using gPPI','  - Do not select baseline, reference, or other conditions of no interest','  - Leave emtpy or click Cancel for a standard sPPI model (single-condition PPI)'},'ListSize',[500 200]);
                                if isempty(value), cnames={''};
                                elseif isequal(value,1:numel(names)), cnames=[];
                                else cnames=names(value);
                                end
                                CONN_x.Analyses(ianalysis).conditions=cnames;
                            elseif value==3 % temporal modulation dynamic FC
                                if numel(CONN_x.dynAnalyses)>1
                                    if ischar(CONN_x.Analyses(ianalysis).modulation)
                                        [name,nill]=fileparts(CONN_x.Analyses(ianalysis).modulation);
                                        [ok,value]=ismember(name,{CONN_x.dynAnalyses.name});
                                        if ~ok, value=CONN_x.dynAnalysis; end
                                    else value=CONN_x.dynAnalysis; 
                                    end
                                    value=listdlg('liststring',{CONN_x.dynAnalyses.name},'selectionmode','single','initialvalue',value,'promptstring',{'Select dyn-ICA analysis:'},'ListSize',[300 200]);
                                    if isempty(value), return; end
                                    CONN_x.dynAnalysis=value;
                                else value=1;
                                end
                                filename=fullfile(CONN_x.folders.firstlevel_dyn,CONN_x.dynAnalyses(CONN_x.dynAnalysis).name,['dyn_Subject',num2str(1,'%03d'),'.mat']);
                                try
                                    load(filename,'names');
                                    if ischar(CONN_x.Analyses(ianalysis).modulation)
                                        [nill,name]=fileparts(CONN_x.Analyses(ianalysis).modulation);
                                        [ok,value]=ismember(name,names);
                                        if ~ok, value=1; end
                                    else value=1;
                                    end
                                    value=listdlg('liststring',names,'selectionmode','single','initialvalue',value,'promptstring','Select interaction factor','ListSize',[300 200]);
                                    if isempty(value), value=CONN_x.Analyses(ianalysis).modulation;
                                    else value=fullfile(CONN_x.dynAnalyses(CONN_x.dynAnalysis).name,names{value});
                                    end
                                catch
                                    if CONN_x.Setup.steps(4)
                                        conn_msgbox('Please run first first-level analysis dyn-ICA step to enable these analyses','',2);
                                    else
                                        conn_msgbox('Please enable ''Dynamic FC'' in Setup.Options, and then run first-level analysis dyn-ICA step to enable these analyes','',2);
                                    end
                                    value=0;
                                end
                                CONN_x.Analyses(ianalysis).modulation=value;
                            elseif value==4 % other temporal modulation
                                if ischar(CONN_x.Analyses(ianalysis).modulation)
                                    idx=find(strcmp(CONN_x.Analyses(ianalysis).modulation,CONN_h.menus.m_analyses.X1.names));
                                    if numel(idx)==1, value=idx; 
                                    elseif isempty(idx), value=1;
                                    else,
                                        idx=find(cellfun(@(x)all(isnan(x)),CONN_h.menus.m_analyses.X1.xyz));
                                        idx=idx(strcmp(CONN_x.Analyses(ianalysis).modulation,CONN_h.menus.m_analyses.X1.names(idx)));
                                        if numel(idx)==1, value=idx;
                                        else value=1;
                                        end
                                    end
                                else value=1; 
                                end
                                if ~isfield(CONN_h.menus.m_analyses,'X1'),
                                    value=0;
                                    conn_msgbox({'Temporal-modulation analyses not ready','Please run Denoising step first'},'',2);
                                else
                                    value=listdlg('liststring',CONN_h.menus.m_analyses.X1.names,'selectionmode','single','initialvalue',value,'promptstring','Select interaction factor','ListSize',[300 200]);
                                    if isempty(value), value=CONN_x.Analyses(ianalysis).modulation;
                                    else value=CONN_h.menus.m_analyses.X1.names{value};
                                    end
                                end
                                CONN_x.Analyses(ianalysis).modulation=value;
                            else
                                CONN_x.Analyses(ianalysis).modulation=value-1;
                            end
                            model=1;
                        case {11,12},
                            nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                            nconditions=get(CONN_h.menus.m_analyses_00{12},'value');
                            if ~CONN_h.menus.m_analyses.isready, return; end
                            %[path,name,ext]=fileparts(CONN_x.filename);
                            filepath=CONN_x.folders.preprocessing;
                            if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
								set(CONN_h.screen.hfig,'pointer','watch'); drawnow;
                                filename=fullfile(filepath,['DATA_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                                CONN_h.menus.m_analyses.Y=conn_vol(filename);
                                if isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface
                                    if CONN_h.menus.m_analyses_surfhires
                                        [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_volume(CONN_h.menus.m_analyses.Y);
                                    else
                                        [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,1);
                                        [tempdata,tempidx]=conn_get_slice(CONN_h.menus.m_analyses.Y,conn_surf_dims(8)*[0;0;1]+1);
                                        CONN_h.menus.m_analyses.y.data=[CONN_h.menus.m_analyses.y.data(:,CONN_gui.refs.surf.default2reduced) tempdata(:,CONN_gui.refs.surf.default2reduced)];
                                        CONN_h.menus.m_analyses.y.idx=[CONN_h.menus.m_analyses.y.idx(CONN_gui.refs.surf.default2reduced);prod(conn_surf_dims(8))+tempidx(CONN_gui.refs.surf.default2reduced)];
                                    end
                                else
                                    [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.slice);
                                end
								set(CONN_h.screen.hfig,'pointer','arrow');
                            end
                            filename=fullfile(filepath,['ROI_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                            CONN_h.menus.m_analyses.X1=load(filename);
                            %filename=fullfile(filepath,['COV_Subject',num2str(nsubs,'%03d'),'_Session',num2str(nconditions,'%03d'),'.mat']);
                            %CONN_h.menus.m_analyses.X2=load(filename);
                            if any(CONN_x.Setup.steps([2,3]))
                                if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                                    try
                                        CONN_h.menus.m_analyses.XS=spm_vol(deblank(CONN_x.Setup.structural{nsubs}{1}{1})); %note: displaying first-session structural here
                                    catch
                                        CONN_h.menus.m_analyses.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                                    end
                                    xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                                    CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                                    CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                                end
                            end
                            model=1;
                        case 13,
                            model=2;
                        case 15,
                            CONN_h.menus.m_analyses.y.slice=round(get(CONN_h.menus.m_analyses_00{15},'value'));
                            if ~CONN_h.menus.m_analyses.isready, return; end
                            if any(CONN_x.Setup.steps([2,3]))&&~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                                [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.slice);
                                xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                                CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                                CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                            end
                            model=1;
                        case 19,
                            model=2;
                        case 20,
                            if numel(varargin)>=3, tianalysis=varargin{3}; 
                            else tianalysis=get(CONN_h.menus.m_analyses_00{20},'value');
                            end
                            analysisname=char(get(CONN_h.menus.m_analyses_00{20},'string'));
                            if ischar(tianalysis)&&strcmp(tianalysis,'new'), tianalysis=size(analysisname,1)-2; end
                            if tianalysis==size(analysisname,1)-2, % new 
                                ok=0;
                                while ~ok,
                                    txt=inputdlg('New analysis name (alphanumeric case sensitive):','conn',1,{['ANALYSIS_',num2str(tianalysis,'%02d')]});
                                    if isempty(txt)||isempty(txt{1}), break; end
                                    txt{1}=regexprep(txt{1},'[^\w\d_]','');
                                    if isempty(txt{1}), break; end
                                    if ~ismember(txt{1},{CONN_x.Analyses.name CONN_x.vvAnalyses.name CONN_x.dynAnalyses.name})
                                        [ok,nill]=mkdir(CONN_x.folders.firstlevel,txt{1});
                                        if ~ok, conn_msgbox('Unable to create folder. Check folder permissions','conn',2);end
                                    else conn_msgbox('Duplicated analysis name. Please try a different name','conn',2);
                                    end
                                end
                                if ok,
                                    CONN_x.Analyses(tianalysis)=CONN_x.Analyses(ianalysis);
                                    CONN_x.Analyses(tianalysis).name=txt{1};
                                    CONN_x.Analyses(tianalysis).sourcenames={};
                                     [nill,sortidx]=sort(~cellfun(@(x)isempty(regexp(x,'^(.*\/|.*\\)?Dynamic factor .*\d+$')),{CONN_x.Analyses(:).name})); % note: resorts to keep dyn at the end of this list
                                     tianalysis=find(sortidx==tianalysis,1);
                                     CONN_x.Analyses=CONN_x.Analyses(sortidx);
                                    CONN_x.Analysis=tianalysis;
                                    conn gui_analyses;
                                    answ=conn_questdlg('Save these changes to CONN project?','','Now','Later','Now');
                                    if isequal(answ,'Now')
                                        hm=conn_msgbox('Saving project, please wait','');
                                        conn gui_setup_save;
                                        if ishandle(hm), delete(hm); end
                                    end
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',ianalysis);
                                end
                            elseif tianalysis==size(analysisname,1)-1, % rename
                                ok=0;
                                if ~isempty(CONN_x.Analyses(CONN_x.Analysis).name) % note: very-old analyses (empty analysis name) cannot be renamed
                                    while ~ok,
                                        txt=inputdlg('New analysis name (alphanumeric case sensitive):','conn',1,{CONN_x.Analyses(CONN_x.Analysis).name});
                                        if isempty(txt)||isempty(txt{1}), break; end
                                        txt{1}=regexprep(txt{1},'[^\w\d_]','');
                                        if isempty(txt{1}), break; end
                                        if ~ismember(txt{1},{CONN_x.Analyses.name CONN_x.vvAnalyses.name CONN_x.dynAnalyses.name})
                                            if isempty(CONN_x.Analyses(CONN_x.Analysis).name), [ok,nill]=mkdir(CONN_x.folders.firstlevel,txt{1});
                                            elseif ispc, [ok,nill]=system(sprintf('ren "%s" "%s"',fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(CONN_x.Analysis).name),fullfile(CONN_x.folders.firstlevel,txt{1}))); ok=isequal(ok,0);
                                            else [ok,nill]=system(sprintf('mv ''%s'' ''%s''',fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(CONN_x.Analysis).name),fullfile(CONN_x.folders.firstlevel,txt{1}))); ok=isequal(ok,0);
                                            end
                                            if ~ok, conn_msgbox('Unable to create folder. Check folder permissions','conn',2);end
                                        else conn_msgbox('Duplicated analysis name. Please try a different name','conn',2);
                                        end
                                    end
                                else conn_msgbox('Sorry, this analysis was created in an older version of CONN and it cannot be renamed','',2); 
                                end
                                if ok,
                                    CONN_x.Analyses(CONN_x.Analysis).name=txt{1}; 
                                    conn gui_analyses;
                                    answ=conn_questdlg('Save these changes to CONN project?','','Now','Later','Now');
                                    if isequal(answ,'Now')
                                        hm=conn_msgbox('Saving project, please wait','');
                                        conn gui_setup_save;
                                        if ishandle(hm), delete(hm); end
                                    end
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',ianalysis);
                                end
                            elseif tianalysis==size(analysisname,1),  % delete
                                answ=conn_questdlg({sprintf('Are you sure you want to delete analysis %s?',CONN_x.Analyses(CONN_x.Analysis).name),'This is a non-reversible operation'},'','Delete','Cancel','Cancel');
                                if isequal(answ,'Delete')
                                    CONN_x.Analyses=CONN_x.Analyses([1:CONN_x.Analysis-1,CONN_x.Analysis+1:end]);
                                    CONN_x.Analysis=min(numel(CONN_x.Analyses),CONN_x.Analysis);
                                    conn gui_analyses;
                                    answ=conn_questdlg('Save these changes to CONN project?','','Now','Later','Now');
                                    if isequal(answ,'Now')
                                        hm=conn_msgbox('Saving project, please wait','');
                                        conn gui_setup_save;
                                        if ishandle(hm), delete(hm); end
                                    end
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',ianalysis);
                                end
                            else
                                CONN_x.Analysis=tianalysis;
                                conn gui_analyses;
                                return;
                            end
                    end
                end
                nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                nview=get(CONN_h.menus.m_analyses_00{13},'value')-1;
                nconditions=get(CONN_h.menus.m_analyses_00{12},'value');
                if ischar(CONN_x.Analyses(ianalysis).modulation)||CONN_x.Analyses(ianalysis).modulation>0
                    if ~isfield(CONN_h.menus.m_analyses,'X1')||~isfield(CONN_h.menus.m_analyses.X1,'crop')||CONN_h.menus.m_analyses.X1.crop||(any(CONN_x.Setup.steps([2,3]))&&(~isfield(CONN_h.menus.m_analyses.Y,'crop')||CONN_h.menus.m_analyses.Y.crop)),
                        CONN_x.Analyses(ianalysis).modulation=0;
                        conn_msgbox({'Temporal-modulation analyses not ready for selected condition'},'',2); 
                    end
                end
                if ischar(CONN_x.Analyses(ianalysis).modulation)||CONN_x.Analyses(ianalysis).modulation>0, 
                    set(CONN_h.menus.m_analyses_00{8},'visible','off'); 
                    set(CONN_h.menus.m_analyses_00{14}.htitle,'string','Temporal Modulation');
                    %set(CONN_h.menus.m_analyses_00{10},'position',boffset+[.105,.15,.31,.04]);
%                     if CONN_x.Analyses(ianalysis).measure<3,
%                         disp('Warning: correlation measure not recommended for gPPI analyses');
%                     end
                else
                    set(CONN_h.menus.m_analyses_00{8},'visible','on'); 
                    set(CONN_h.menus.m_analyses_00{14}.htitle,'string','Connectivity (seed-to-voxel)');
                    %set(CONN_h.menus.m_analyses_00{10},'position',boffset+[.105,.15,.23,.04]);
                end
                %if CONN_x.Analyses(ianalysis).weight==1&&CONN_x.Analyses(ianalysis).modulation==1, uiwait(warndlg({'Parametric task-effect modulation requires non-constant interaction term / weights','Change ''weights'' to hrf for standard analyses'})); end
                set(CONN_h.menus.m_analyses_00{7},'value',CONN_x.Analyses(ianalysis).measure);
                if ischar(CONN_x.Analyses(ianalysis).modulation), if ~isempty(regexp(CONN_x.Analyses(ianalysis).modulation,'^(.*\/|.*\\)?Dynamic factor \d+$')), value=3; else value=4; end; else value=CONN_x.Analyses(ianalysis).modulation+1; end
                set(CONN_h.menus.m_analyses_00{10},'value',value);
                if ~isempty(nregressors)&&all(nregressors>0),
                    temp=cat(1,CONN_x.Analyses(ianalysis).regressors.deriv{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{4},'visible','on','value',1+CONN_x.Analyses(ianalysis).regressors.deriv{nregressors(1)});
                    else  set(CONN_h.menus.m_analyses_00{4},'visible','off'); end
                    temp=cat(1,CONN_x.Analyses(ianalysis).regressors.fbands{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{5},'visible','on','value',min(2,CONN_x.Analyses(ianalysis).regressors.fbands{nregressors(1)}));
                    else  set(CONN_h.menus.m_analyses_00{5},'visible','off'); end
                    temp=cat(1,CONN_x.Analyses(ianalysis).regressors.dimensions{nregressors});
                    if size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{6},'string',num2str(CONN_x.Analyses(ianalysis).regressors.dimensions{nregressors(1)}(1)));
                    else  set(CONN_h.menus.m_analyses_00{6},'string','MULTIPLE VALUES'); end
                end
                if ~CONN_h.menus.m_analyses.isready, return; end
                [CONN_h.menus.m_analyses.X,CONN_h.menus.m_analyses.select]=conn_designmatrix(CONN_x.Analyses(ianalysis).regressors,CONN_h.menus.m_analyses.X1,[],{nregressors,nview});
                if model==1,
                    xf=CONN_h.menus.m_analyses.X;
                    nX=size(xf,2);
                    wx=ones(size(xf,1),1);
                    switch(CONN_x.Analyses(ianalysis).weight),
                        case 1, wx=double(CONN_h.menus.m_analyses.X1.conditionweights{1}>0);
                        case 2, wx=CONN_h.menus.m_analyses.X1.conditionweights{1};
                        case 3, wx=CONN_h.menus.m_analyses.X1.conditionweights{2};
                        case 4, wx=CONN_h.menus.m_analyses.X1.conditionweights{3};
                    end
                    if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                        if ~(ischar(CONN_x.Analyses(ianalysis).modulation)||CONN_x.Analyses(ianalysis).modulation>0)
                            wx=max(0,wx);
                            xf=cat(2,xf(:,1),conn_wdemean(xf(:,2:end),wx));
                            xf=xf.*repmat(wx,[1,size(xf,2)]);
                            yf=CONN_h.menus.m_analyses.y.data;
                            yf=conn_wdemean(yf,wx);
                            yf=yf.*repmat(wx,[1,size(yf,2)]);
                        else
                            %xf=cat(2,xf(:,1),detrend(xf(:,2:end),'constant'));
                            yf=CONN_h.menus.m_analyses.y.data;
                            yf=detrend(yf,'constant');
                            if ~ischar(CONN_x.Analyses(ianalysis).modulation)
                                %wx=CONN_h.menus.m_analyses.X1.conditionweights{3}; %PPI
                                if isempty(CONN_x.Analyses(ianalysis).conditions), validconditions=1:length(CONN_x.Setup.conditions.names)-1;
                                else validconditions=find(ismember(CONN_x.Setup.conditions.names(1:end-1),CONN_x.Analyses(ianalysis).conditions));
                                end
                                wx=[];
                                for tncondition=[setdiff(validconditions,nconditions) nconditions],
                                    filename=fullfile(CONN_x.folders.preprocessing,['ROI_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(tncondition),'%03d'),'.mat']);
                                    X1=load(filename,'conditionweights');
                                    wx=[wx X1.conditionweights{3}(:)];
                                end
%                                 wx=CONN_h.menus.m_analyses.ConditionWeights{nsubs,3}(:,[setdiff(validconditions,nconditions) nconditions]); %gPPI
                            elseif ~isempty(regexp(CONN_x.Analyses(ianalysis).modulation,'^(.*\/|.*\\)?Dynamic factor \d+$')), 
                                [name1,name2]=fileparts(CONN_x.Analyses(ianalysis).modulation);
                                [ok,value1]=ismember(name1,{CONN_x.dynAnalyses.name}); if ~ok, if numel(CONN_x.dynAnalyses)==1, value1=1; else error('Analysis name %s not found',name1); end; end
                                filename=fullfile(CONN_x.folders.firstlevel_dyn,CONN_x.dynAnalyses(value1).name,['dyn_Subject',num2str(nsubs,'%03d'),'.mat']);
                                xmod=load(filename);
                                [ok,idx]=ismember(name2,xmod.names);
                                if ok, wx=xmod.data(:,[setdiff(1:size(xmod.data,2),idx),idx]);
                                else error('Temporal factor not found');
                                end
                                if ~isempty(wx), wx=conn_bsxfun(@times,wx,CONN_h.menus.m_analyses.X1.conditionweights{1}>0); end
                            else
                                idx=find(strcmp(CONN_x.Analyses(ianalysis).modulation,CONN_h.menus.m_analyses.X1.names));
                                if numel(idx)==1, wx=CONN_h.menus.m_analyses.X1.data{idx};
                                elseif isempty(idx), error('Covariate not found. Please re-run dyn-ICA step');
                                else, 
                                    idx=find(cellfun(@(x)all(isnan(x)),CONN_h.menus.m_analyses.X1.xyz));
                                    idx=idx(strcmp(CONN_x.Analyses(ianalysis).modulation,CONN_h.menus.m_analyses.X1.names(idx)));
                                    if numel(idx)==1, wx=CONN_h.menus.m_analyses.X1.data{idx};
                                    else error('Covariate not found');
                                    end
                                end
                                if ~isempty(wx), wx=conn_bsxfun(@times,wx,CONN_h.menus.m_analyses.X1.conditionweights{1}>0); end
                            end
                            inter=wx;
                            xf=[xf(:,1) detrend([xf(:,2:end) reshape(repmat(permute(inter,[1 3 2]),[1,size(xf,2),1]),size(xf,1),[]) reshape(conn_bsxfun(@times,xf,permute(inter,[1 3 2])),size(xf,1),[])],'constant')];
                            %xf=[xf inter conn_bsxfun(@times,xf,inter)];
                            %xf=[xf(:,1) detrend([xf(:,2:end) repmat(inter,[1,size(xf,2)]) conn_bsxfun(@times,xf,inter)],'constant')];
                        end
                        if ismember(CONN_x.Analyses(ianalysis).measure,[2 4]), [CONN_h.menus.m_analyses.B,CONN_h.menus.m_analyses.opt]=conn_glmunivariate('estimate',xf,yf); end
                        CONN_h.menus.m_analyses.Yf=yf;
                    end
                    CONN_h.menus.m_analyses.nVars=size(xf,2)/nX;
                    CONN_h.menus.m_analyses.Xf=xf;
                    CONN_h.menus.m_analyses.Wf=wx;
                    %CONN_h.menus.m_analyses.B=pinv(CONN_h.menus.m_analyses.X)*CONN_h.menus.m_analyses.Y.data;
                end
                if isempty(nregressors)||any(nregressors==0), 
                    conn_menu('update',CONN_h.menus.m_analyses_00{3},[]);
                    set(CONN_h.menus.m_analyses_00{22},'visible','on');
                else
                    set(CONN_h.menus.m_analyses_00{22},'visible','off');
                    if get(CONN_h.menus.m_analyses_00{19},'value')==1
                        xtemp=CONN_h.menus.m_analyses.X(:,find(CONN_h.menus.m_analyses.select{1}));
                        conn_menu('updateplotstack',CONN_h.menus.m_analyses_00{3},xtemp);
%                         if size(CONN_h.menus.m_analyses.X,2)<=500,
%                             offon={'off','on'};
%                             for n1=1:size(CONN_h.menus.m_analyses.X,2),
%                                 set(CONN_h.menus.m_analyses_00{3}.h4(n1),'visible',offon{1+CONN_h.menus.m_analyses.select{1}(n1)});
%                             end
%                             xtemp=CONN_h.menus.m_analyses.X(:,find(CONN_h.menus.m_analyses.select{1}));
%                             if ~isempty(xtemp), set(CONN_h.menus.m_analyses_00{3}.h3,'ylim',[min(min(xtemp))-1e-4,max(max(xtemp))+1e-4]); end
%                         end
                    else
                        if ismember(CONN_x.Analyses(ianalysis).measure,[1 3]), idx1=find(CONN_h.menus.m_analyses.select{1});
                        else idx1=2:numel(CONN_h.menus.m_analyses.select{1}); 
                        end
                        emph2=[]; idx2=[]; for n1=1:numel(idx1), idx3=idx1(n1):size(CONN_h.menus.m_analyses.Xf,2)/CONN_h.menus.m_analyses.nVars:size(CONN_h.menus.m_analyses.Xf,2); idx2=[idx2 idx3]; emph2=[emph2 zeros(1,numel(idx3)-1) CONN_h.menus.m_analyses.select{1}(idx1(n1))]; end; [idx2,idx3]=sort(idx2); emph2=emph2(idx3); temp=CONN_h.menus.m_analyses.Xf(:,idx2); temp=bsxfun(@rdivide,temp,max(.01,max(abs(temp),[],1)));
                        temp=round(128+64.5+63.5*temp);
                        temp(:,~emph2)=temp(:,~emph2)-128;
                        set(CONN_h.menus.m_analyses_00{3}.h4,'visible','off');
                        conn_menu('updatematrix',CONN_h.menus.m_analyses_00{3},ind2rgb(max(1,min(256,round(temp)')),[gray(128);hot(128)]));
                    end
                end
                
                if model,
                    if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                        t1=zeros(CONN_h.menus.m_analyses.Y.matdim.dim(1:2));
                        t2=0+zeros(CONN_h.menus.m_analyses.Y.matdim.dim(1:2));
                        idx=find(CONN_h.menus.m_analyses.select{2});
                        if ismember(CONN_x.Analyses(ianalysis).measure,[1 3])
                            idx1=conn_bsxfun(@plus,idx(:),(0:CONN_h.menus.m_analyses.nVars-1)*size(CONN_h.menus.m_analyses.Xf,2)/CONN_h.menus.m_analyses.nVars);
                            xf=CONN_h.menus.m_analyses.Xf(:,idx1);
                            yf=CONN_h.menus.m_analyses.Yf;
                            [CONN_h.menus.m_analyses.B,CONN_h.menus.m_analyses.opt]=conn_glmunivariate('estimate',xf,yf);
                            idx=1:numel(idx);
                        end
                        C=eye(size(CONN_h.menus.m_analyses.opt.X,2));
                        if ~isempty(C)
                            if ischar(CONN_x.Analyses(ianalysis).modulation)||CONN_x.Analyses(ianalysis).modulation>0 % parametric modulation
                                %                             switch(CONN_x.Analyses(ianalysis).measure),
                                %                                 case {1,3}, %bivariate
                                %                                     C=pinv((CONN_h.menus.m_analyses.opt.XX).*kron(ones(CONN_h.menus.m_analyses.nVars),eye(size(CONN_h.menus.m_analyses.opt.XX,2)/CONN_h.menus.m_analyses.nVars)))*CONN_h.menus.m_analyses.opt.XX;
                                %                                     C=C((CONN_h.menus.m_analyses.nVars-1)*size(C,1)/CONN_h.menus.m_analyses.nVars+1:end,:);
                                %                                     if ~isempty(idx), C=C(idx,:); end
                                %                                     %C=pinv(CONN_h.menus.m_analyses.opt.X(:,[1,idx]))*CONN_h.menus.m_analyses.opt.X;
                                %                                     %C=C(2:end,:); % unique + shared variance
                                %                                 case {2,4}, %partial
                                C=C((CONN_h.menus.m_analyses.nVars-1)*size(C,1)/CONN_h.menus.m_analyses.nVars+1:end,:);
                                if ~isempty(idx), C=C(idx,:); end % unique variance
                                %                             end
                            else % functional connectivity
                                if ~isempty(idx),
                                    %                                 switch(CONN_x.Analyses(ianalysis).measure),
                                    %                                     case {1,3}, %bivariate
                                    %                                         C=pinv(CONN_h.menus.m_analyses.opt.X(:,[1,idx]))*CONN_h.menus.m_analyses.opt.X;
                                    %                                         C=C(2:end,:); % unique + shared variance
                                    %                                     case {2,4}, %partial
                                    C=C(idx,:);  % unique variance
                                    %                                 end
                                end
                            end
                            [h,F,p,dof,R]=conn_glmunivariate('evaluate',CONN_h.menus.m_analyses.opt,[],C);
                            switch(CONN_x.Analyses(ianalysis).measure),
                                case {1,2}, %correlation
                                    S1=sign(R).*sqrt(abs(R)); S2=abs(S1);
                                case {3,4}, %regression
                                    S1=h; if size(S1,1)>1, S1=sqrt(sum(abs(S1).^2,1)); end; S2=abs(S1);
                            end
                            if isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface, issurface=true; else issurface=false; end
                            t1=zeros(CONN_h.menus.m_analyses.Y.matdim.dim(1:2+issurface));
                            t2=nan+zeros(CONN_h.menus.m_analyses.Y.matdim.dim(1:2+issurface));
                            t1(CONN_h.menus.m_analyses.y.idx)=S1;
                            t2(CONN_h.menus.m_analyses.y.idx)=S2;
                            if isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface
                                if ~CONN_h.menus.m_analyses_surfhires
                                    t1=[t1(CONN_gui.refs.surf.default2reduced) t1(numel(t1)/2+CONN_gui.refs.surf.default2reduced)];
                                    t2=[t2(CONN_gui.refs.surf.default2reduced) t2(numel(t2)/2+CONN_gui.refs.surf.default2reduced)];
                                    conn_menu('update',CONN_h.menus.m_analyses_00{14},{CONN_gui.refs.surf.defaultreduced,t1,t2},{CONN_h.menus.m_analyses.Y.matdim,CONN_h.menus.m_analyses.y.slice});
                                    conn_menu('update',CONN_h.menus.m_analyses_00{29},[]);
                                else
                                    conn_menu('update',CONN_h.menus.m_analyses_00{14},{CONN_gui.refs.surf.default,t1,t2},{CONN_h.menus.m_analyses.Y.matdim,CONN_h.menus.m_analyses.y.slice});
                                    conn_menu('update',CONN_h.menus.m_analyses_00{29},[]);
                                end
                            else
                                t1=permute(t1,[2,1,3]);
                                t2=permute(t2,[2,1,3]);
                                conn_menu('update',CONN_h.menus.m_analyses_00{14},{CONN_h.menus.m_analyses.Xs,t1,t2},{CONN_h.menus.m_analyses.Y.matdim,CONN_h.menus.m_analyses.y.slice});
                                conn_callbackdisplay_firstlevelclick;
                            end
                        else
                            conn_menu('update',CONN_h.menus.m_analyses_00{14},[]);
                            conn_menu('update',CONN_h.menus.m_analyses_00{29},[]);
                        end
                    else
                        conn_menu('update',CONN_h.menus.m_analyses_00{14},[]);
                        conn_menu('update',CONN_h.menus.m_analyses_00{29},[]);
                    end
                else conn_callbackdisplay_firstlevelclick;
                end
            elseif state(1)==3 % VOXEL-TO-VOXEL
                boffset=[.02 .03 0 0];
                if nargin<2,
                    if ~any(CONN_x.Setup.steps(state)), conn_msgbox('No voxel-to-voxel analyses computed. Select these options in ''Setup->Options'' to perform additional analyses','',2); return; end %conn gui_setup; return; end
                    conn_menumanager clf;
                    conn_menuframe;
                    tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(3)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate);
                    conn_menu('frame2border',[.0,.955,1,.045],'');
                    %conn_menu('frame2border',[.0,.0,.115,.94]);
                    conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                    conn_menumanager([CONN_h.menus.m_analyses_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                    %if isempty(CONN_x.vvAnalyses.regressors.names), uiwait(errordlg('Run first the Denoising step by pressing "Done" in the Denoising tab','Data not prepared for analyses')); conn gui_preproc; return; end
                    conn_menu('nullstr',{'Preview not','available'});
                    
                    conn_menu('frame',boffset+[.215,.35,.25,.38],' ');%,'First-level analyses');%'FC ANALYSIS OPTIONS');
                    if isfield(CONN_x.vvAnalyses,'name')&&~isempty(CONN_x.vvAnalyses(CONN_x.vvAnalysis).name)
                        %conn_menu('title2',boffset+[.115,.825,.19,.04],'First-level analysis:');
                        txt=strvcat(CONN_x.vvAnalyses(:).name,'<HTML><i>new</i></HTML>','<HTML><i>rename</i></HTML>','<HTML><i>delete</i></HTML>');
                        CONN_h.menus.m_analyses_00{20}=conn_menu('popupbigblue',boffset+[.215,.73,.25,.05],'',txt(CONN_x.vvAnalysis,:),'<HTML>Analysis name <br/> - Select existing first-level analysis name to edit its properties <br/> - select <i>new/rename/delete</i> to define a new set of first-level analyses within this project, or the rename or delete the selected analysis</HTML>','conn(''gui_analyses'',20);');
                        %CONN_h.menus.m_analyses_00{20}=conn_menu('popup2',[.005,.78,.125,.04],'Analysis name:',txt(CONN_x.vvAnalysis,:),'<HTML>Analysis name <br/> - Select existing first-level analysis name to edit its properties <br/> - select <i>new</i> to define a new set of first-level analyses within this project</HTML>','conn(''gui_analyses'',20);');
                        set(CONN_h.menus.m_analyses_00{20},'string',txt,'value',CONN_x.vvAnalysis);%,'fontsize',12+CONN_gui.font_offset);%,'fontweight','bold');
                    end
                    nsubs=1;
                    nconditions=1;
                    filepath=CONN_x.folders.preprocessing;
                    nconditions=length(CONN_x.Setup.conditions.names)-1;
                    icondition=[];isnewcondition=[];for ncondition=1:nconditions,[icondition(ncondition),isnewcondition(ncondition)]=conn_conditionnames(CONN_x.Setup.conditions.names{ncondition}); end
                    CONN_h.menus.m_analyses.icondition=icondition;
                    if 0,%any(CONN_x.Setup.steps(3)),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                        filename=fullfile(filepath,['vvPC_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                        if ~conn_existfile(filename), conn_msgbox({'Not ready to start first-level Analysis step',' ','Please complete the Denoising step first','(fill any required information and press "Done" in the Denoising tab)'},'',2); end; %return; end %conn gui_preproc; return; end
                        if 0
                            CONN_h.menus.m_analyses.Y=conn_vol(filename);
                            CONN_h.menus.m_analyses.y.slice=ceil(CONN_h.menus.m_analyses.Y.matdim.dim(3)/2);
                            filename=fullfile(filepath,['vvPCeig_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                            CONN_h.menus.m_analyses.y.data=load(filename,'D');
                        end
                    end
                    if any(isnewcondition), 
                        conn_msgbox({'Not ready to start first-level Analysis step',' ','Please complete the Denoising step first','(fill any required information and press "Done" in the Denoising tab)',sprintf('Some conditions (%s) have not been processed yet',sprintf('%s ',CONN_x.Setup.conditions.names{isnewcondition>0}))},'',2); 
                        CONN_h.menus.m_analyses.isready=false;
                        %conn gui_preproc; 
                        %return; 
                    else
                        CONN_h.menus.m_analyses.isready=true;
                    end
                    
                    CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables=conn_v2v('measures');
                    CONN_h.menus.m_analyses_00{16}=conn_menu('popup',boffset+[.225,.63,.21,.04],'Analysis type',CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.names,'<HTML>Select the desired analysis:<br/> - <b>group-PCA</b> performs a Principal Component Analysis decomposition of the BOLD signal across all subjects in terms of orthogonal spatial <br/>components (networks) and temporal components (shared response patterns within each network)<br/>- <b>group-ICA</b> (Calhoun et. al) performs an Independent Component Analysis decomposition of the BOLD signal across all subjects in terms of <br/>independent spatial components (networks) and temporal components (shared response patterns within each network)<br/> - <b>group-MVPA</b> estimates, for each seed-voxel, a multivariate representation of the connectivity pattern between this voxel and the entire brain<br/> - <b>IntrinsicConnectivity</b> (Intrinsic Connectivity Contrast, ICC) is a measure of <i>network centrality</i> and it computes, for each seed-voxel, the <br/>the norm (root mean square) correlation between this voxel and the entire brain<br/> - <b>LocalCorrelation</b> (Integrated Local Correlation, ILC, LCOR) is a measure of <i>local coherence</i>, and it computes, for each seed-voxel, the average <br/>correlation between this voxel and its neighbours<br/> - <b>GlobalCorrelation</b> (GCOR) is a measure of <i>network centrality</i> and it computes, for each seed-voxel, the average correlation between this voxel and the entire brain<br/> - <b>RadialCorrelationContrast</b> computes, for each seed-voxel, the spatial gradient of the local connectivity between this voxel and its neighbors<br/> - <b>RadialSimilarityContrast</b> computes, for each seed-voxel, the strength/norm of the spatial gradient in connectivity patterns between this voxel and the entire brain<br/> - <b>ALFF</b> (Amplitude of Low Frequency Fluctuations) computes, for each seed-voxel, the amplitude (root mean square) of BOLD signal fluctuations in the frequency band of interest<br/> (after <i>Denoising</i> band-pass filter)<br/> - <b>fALFF</b> (fractional Amplitude of Low Frequency Fluctuations) computes, for each voxel, the relative amplitude (root mean square ratio) of BOLD signal fluctuations in the frequency <br/>band of interest (after <i>Denoising</i> band-pass filter) compared to the entire frequency band (before filtering)</HTML>','conn(''gui_analyses'',16);');
                    %CONN_h.menus.m_analyses_00{1}=conn_menu('listbox',boffset+[.125,.25,.095,.45],'all analysis types','','<HTML>All available types of voxel-to-voxel measures/analyses:<br/> - <b>group-PCA</b> performs a Principal Component Analysis decomposition of the BOLD signal across all subjects in terms of orthogonal spatial <br/>components (networks) and temporal components (shared response patterns within each network)<br/>- <b>group-ICA</b> (Calhoun et. al) performs an Independent Component Analysis decomposition of the BOLD signal across all subjects in terms of <br/>independent spatial components (networks) and temporal components (shared response patterns within each network)<br/> - <b>group-MVPA</b> estimates, for each seed-voxel, a multivariate representation of the connectivity pattern between this voxel and the entire brain<br/> - <b>IntrinsicConnectivity</b> (Intrinsic Connectivity Contrast, ICC) is a measure of <i>network centrality</i> and it computes, for each seed-voxel, the <br/>strength/norm of the connectivity pattern between this voxel and the entire brain<br/> - <b>LocalCorrelation</b> (Integrated Local Correlation, ILC) is a measure of <i>local coherence</i>, and it computes, for each seed-voxel, the average <br/>correlation between this voxel and its neighbours<br/> - <b>GlobalCorrelation</b> is a measure of <i>network centrality</i> and it computes, for each seed-voxel, the average connectivity between this voxel and the entire brain<br/> - <b>RadialCorrelationContrast</b> computes, for each seed-voxel, the spatial gradient of the local connectivity between this voxel and its neighbors<br/> - <b>RadialSimilarityContrast</b> computes, for each seed-voxel, the strength/norm of the spatial gradient in connectivity patterns between this voxel and the entire brain</HTML>','conn(''gui_analyses'',1);');
                    %CONN_h.menus.m_analyses_00{2}=conn_menu('listbox',boffset+[.24,.25,.17,.45],'Selected analyses','','<HTML>Select the desired set of voxel-to-voxel measures/analyses to compute  <br/> - Select analyses in the <i>all analysis types</i> list and click <b> > </b> to add new analyses to this list <br/> - Select analyses in this list and click <b> &lt </b> to remove them from this list <br/></HTML>','conn(''gui_analyses'',2);');
                    %[CONN_h.menus.m_analyses_00{7}(1),CONN_h.menus.m_analyses_00{7}(2)]=conn_menu('edit',boffset+[.42,.7,.11,.04],'Label','','label of voxel-to-voxel analysis','conn(''gui_analyses'',7);');
                    [CONN_h.menus.m_analyses_00{4}(1),CONN_h.menus.m_analyses_00{4}(2)]=conn_menu('edit',boffset+[.225,.55,.15,.04],'Kernel size (mm)','','<HTML>Define local kernel size (FWHM of Gaussian kernel)</HTML>','conn(''gui_analyses'',4);');
                    measuretypes={'Local','Global'};
                    CONN_h.menus.m_analyses_00{5}=[];%[CONN_h.menus.m_analyses_00{5}(1),CONN_h.menus.m_analyses_00{5}(2)]=conn_menu('popup',boffset+[.4,.4,.11,.04],'Measure type',measuretypes,'Select type of voxel-to-voxel measure (local for analyses of local connectivity patterns; global for analyses of global connectivity patterns)','conn(''gui_analyses'',5);');
                    measuretypes={'Gaussian','Gradient','Laplacian'};
                    CONN_h.menus.m_analyses_00{6}=[];%[CONN_h.menus.m_analyses_00{6}(1),CONN_h.menus.m_analyses_00{6}(2)]=conn_menu('popup',boffset+[.4,.3,.11,.04],'Kernel shape',measuretypes,'Define integration kernel shape','conn(''gui_analyses'',6);');
                    [CONN_h.menus.m_analyses_00{9}(1),CONN_h.menus.m_analyses_00{9}(2)]=conn_menu('edit',boffset+[.225,.55,.15,.04],'Number of factors','','<HTML>Define number of group-level components to estimate. <br/> - group-PCA analyses: Number of components retained from a Principal Component decomposition of the spatiotemporal BOLD signal (temporally-concatenated across subjects)<br/> - group-ICA analyses: Number of components retained from a Independent Component decomposition of the spatiotemporal BOLD signal (FastICA, temporal-concatenation across subjects)<br/> - group-MVPA: Number of components retained from a Principal Component decomposition of the between-subjects variability in seed-to-voxel connectivity maps (separately for each voxel)<br/>After group-level components are computed, subject- and condition- specific components are estimated using dual-regression back projection</HTML>','conn(''gui_analyses'',9);');
                    [CONN_h.menus.m_analyses_00{7}(1),CONN_h.menus.m_analyses_00{7}(2)]=conn_menu('checkbox',boffset+[.225,.48,.02,.03],'Masked analyses','','<HTML>Mask voxel-to-voxel correlations<br/> - check this option for masked-ICA, masked-PCA, or masked-MVPA analyses (group-level components restricted to within-mask voxels)<br/> - uncheck this option to use no explicit masking (all voxels in analysis mask are included)','conn(''gui_analyses'',7);');
                    [CONN_h.menus.m_analyses_00{8}(1),CONN_h.menus.m_analyses_00{8}(2)]=conn_menu('edit',boffset+[.225,.38,.15,.04],'Dimensionality reduction','','<HTML>(optional) subject-level dimensionality reduction step <br/> - define number of SVD components characterizing each subject Voxel-to-Voxel correlation matrix to retain <br/> - set to <i>inf</i> for no dimensionality reduction</HTML>','conn(''gui_analyses'',8);');
                    CONN_h.menus.m_analyses_00{3}=[];[CONN_h.menus.m_analyses_00{3}(1),CONN_h.menus.m_analyses_00{3}(2)]=conn_menu('checkbox',boffset+[.225,.51,.02,.03],'Normalization','','<HTML>(optional) computes normalized z-score measures <br/> - When selecting this option the distribution of the resulting voxel-level measures for each subject and condition is Gaussian with mean 0 and variance 1 <br/> - Uncheck this option to skip normalization (compute the raw voxel-level values instead) </HTML>','conn(''gui_analyses'',3);');
                    CONN_h.menus.m_analyses_00{17}=[];[CONN_h.menus.m_analyses_00{17}(1),CONN_h.menus.m_analyses_00{17}(2)]=conn_menu('checkbox',boffset+[.225,.51,.02,.03],'Centering','','<HTML>(optional) centers MVPA components<br/> - When selecting this option the MVPA components have zero mean across all subjects/conditions (MVPA components defined using PCA of covariance in seed-to-voxel connectivity values across subjects) <br/> - Uncheck this option to skip centering (PCA decomposition uses second moment about zero instead of second moment about the mean) </HTML>','conn(''gui_analyses'',17);');
                    %set([CONN_h.menus.m_analyses_00{3}(2) CONN_h.menus.m_analyses_00{17}(2)],'position',boffset+[.245,.51,.09,.03]);
                    if 1,%(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                        [CONN_h.menus.m_analyses_00{10:15}]=deal([]);
                    else
                        CONN_h.menus.m_analyses_00{10}=conn_menu('frame2',boffset+[.55,.09,.425,.75],'Preview voxel-to-voxel analysis results');
                        CONN_h.menus.m_analyses_00{11}=conn_menu('listbox2',boffset+[.90,.53,.075,.22],'Subjects','','Select subject to display','conn(''gui_analyses'',11);');
                        CONN_h.menus.m_analyses_00{12}=conn_menu('listbox2',boffset+[.90,.23,.075,.22],'Conditions','','Select condition to display','conn(''gui_analyses'',12);');
                        CONN_h.menus.m_analyses_00{13}=conn_menu('popup2',boffset+[.69,.78,.18,.05],'',{' '},'Select measure to display','conn(''gui_analyses'',13);');
                        pos=[.56,.15,.30,.63];
                        if any(CONN_x.Setup.steps([3])),
                            uicontrol('style','text','units','norm','position',boffset+[pos(1)+pos(3)-.170,pos(2)-1*.06,.070,.04],'string','threshold','fontname','default','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolor,'foregroundcolor',CONN_gui.fontcolorA,'tooltipstring','only results with absolute effect sizes above this threshold value are displayed');
                            CONN_h.menus.m_analyses_00{15}=conn_menu('slider',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'','','z-slice','conn(''gui_analyses'',15);');
                            set(CONN_h.menus.m_analyses_00{15},'visible','off');
                            conn_menumanager('onregion',CONN_h.menus.m_analyses_00{15},1,boffset+pos+[0 0 .015 0]);
                            %CONN_h.menus.m_analyses_00{15}=uicontrol('style','slider','units','norm','position',boffset+[pos(1)+pos(3)-0*.015,pos(2),.015,pos(4)],'callback','conn(''gui_analyses'',15);','backgroundcolor',CONN_gui.backgroundcolorA);
                        end
                        CONN_h.menus.m_analyses_00{14}=conn_menu('image2',boffset+pos,'');
                    end
                    
                    [ok,idx]=ismember(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.names);
                    if any(ok), set(CONN_h.menus.m_analyses_00{16},'value',idx(find(ok))); end 
%                     %set([CONN_h.menus.m_analyses_00{1}],'max',2);
%                     set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'max',2);
%                     set(CONN_h.menus.m_analyses_00{1},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.names);
%                     set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names);
%                     conn_menumanager(CONN_h.menus.m_analyses_01,'on',1);
                    set([CONN_h.menus.m_analyses_00{11},CONN_h.menus.m_analyses_00{12},CONN_h.menus.m_analyses_00{13}],'max',1);
                    set(CONN_h.menus.m_analyses_00{11},'string',[repmat('Subject ',[CONN_x.Setup.nsubjects,1]),num2str((1:CONN_x.Setup.nsubjects)')]);
                    set(CONN_h.menus.m_analyses_00{12},'string',{CONN_x.Setup.conditions.names{1:end-1}},'value',1);
                    set(CONN_h.menus.m_analyses_00{13},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'value',1);
                    
                    if 0,%~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                        try
                            CONN_h.menus.m_analyses.XS=spm_vol(deblank(CONN_x.Setup.structural{1}{1}{1}));
                        catch
                            CONN_h.menus.m_analyses.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                        end
                        if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)&&any(CONN_x.Setup.steps([3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                            xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                            CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                            CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                            set(CONN_h.menus.m_analyses_00{15},'min',1,'max',CONN_h.menus.m_analyses.Y.matdim.dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_analyses.Y.matdim.dim(3)-1)),'value',CONN_h.menus.m_analyses.y.slice);
                            set(CONN_h.menus.m_analyses_00{14}.h10,'string','eps');
                        else
                            CONN_h.menus.m_analyses.y.slice=max(1,min(4,CONN_h.menus.m_analyses.y.slice));
                            if ~isempty(CONN_h.menus.m_analyses_00{15})
                                set(CONN_h.menus.m_analyses_00{15},'visible','off');
                                conn_menumanager('onregionremove',CONN_h.menus.m_analyses_00{15});
                            end
                        end
                    end
                    if CONN_h.menus.m_analyses.isready, conn_menumanager([CONN_h.menus.m_analyses_04],'on',1); end
                    model=1;

                else
                    switch(varargin{2}),
%                         case 0,
%                             str=conn_menumanager(CONN_h.menus.m_analyses_01,'string');
%                             switch(str{1}),
%                                 case '>',
%                                     ncovariates=get(CONN_h.menus.m_analyses_00{1},'value');
%                                     for ncovariate=ncovariates(:)',
%                                         if 1,%isempty(strmatch(CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.names{ncovariate},CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'exact'))||strcmp(CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.names{ncovariate},'other (Generalized Functional form)'),
%                                             optionsnames=fieldnames(CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables);
%                                             for n1=1:numel(optionsnames),
%                                                 CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.(optionsnames{n1}){end+1}=CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.(optionsnames{n1}){ncovariate};
%                                             end
%                                         end
%                                     end
%                                     set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{2},'value')),length(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names))));
%                                     set(CONN_h.menus.m_analyses_00{13},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{13},'value')),length(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names))));
%                                 case '<',
%                                     ncovariates=get(CONN_h.menus.m_analyses_00{2},'value');
%                                     idx=setdiff(1:length(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names),ncovariates);
%                                     optionsnames=fieldnames(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors);
%                                     for n1=1:numel(optionsnames),
%                                         CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.(optionsnames{n1})={CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.(optionsnames{n1}){idx}};
%                                     end
%                                     set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'value',max(1,min(max(ncovariates),length(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names))));
%                                     set(CONN_h.menus.m_analyses_00{13},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{13},'value')),length(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names))));
%                             end
%                             model=1;
%                         case 1,
%                             conn_menumanager(CONN_h.menus.m_analyses_01,'string',{'>'},'on',1);
%                             set(CONN_h.menus.m_analyses_00{2},'value',[]);
%                             set([CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses_00{17},CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6},CONN_h.menus.m_analyses_00{7},CONN_h.menus.m_analyses_00{8}],'visible','off');%
%                         case 2,
%                             conn_menumanager(CONN_h.menus.m_analyses_01,'string',{'<'},'on',1);
%                             set(CONN_h.menus.m_analyses_00{1},'value',[]);
%                             set([CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses_00{17},CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6},CONN_h.menus.m_analyses_00{7},CONN_h.menus.m_analyses_00{8},CONN_h.menus.m_analyses_00{9}],'visible','on');%,'backgroundcolor','k','foregroundcolor','w');%
%                             % uncomment below to link the two "measure" menus 
%                             %nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
%                             %if numel(nregressors)==1, 
%                             %    set(CONN_h.menus.m_analyses_00{13},'value',nregressors); 
%                             %    model=1;
%                             %end
                        case 16,
                            ncovariates=get(CONN_h.menus.m_analyses_00{16},'value');
                            for ncovariate=ncovariates(:)',
                                if 1,%isempty(strmatch(CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.names{ncovariate},CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'exact'))||strcmp(CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.names{ncovariate},'other (Generalized Functional form)'),
                                    optionsnames=fieldnames(CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables);
                                    for n1=1:numel(optionsnames),
                                        CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.(optionsnames{n1}){1}=CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.(optionsnames{n1}){ncovariate};
                                        %CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.(optionsnames{n1}){end+1}=CONN_x.vvAnalyses(CONN_x.vvAnalysis).variables.(optionsnames{n1}){ncovariate};
                                    end
                                end
                            end
                            set(CONN_h.menus.m_analyses_00{13},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'value',1);
                        case 3,
                            nregressors=1; %get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{3}(1),'value');
                            for nregressor=nregressors(:)', CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.norm{nregressor}=value; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 4,
                            nregressors=1; %get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{4}(1),'string'));
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.localsupport{nregressor}=value; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 5,
                            nregressors=1; %get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{5}(1),'value')-1;
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.global{nregressor}=value; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 6,
                            nregressors=1; %get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{6}(1),'value')-1;
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.deriv{nregressor}=value; if CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.deriv{nregressor}==1, CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.dimensions_out{nregressor}=3; else CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.dimensions_out{nregressor}=1; end; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 7,
                            nregressors=1; %get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{7}(1),'value');
                            if ~isempty(CONN_x.vvAnalyses(CONN_x.vvAnalysis).mask), tfilename=CONN_x.vvAnalyses(CONN_x.vvAnalysis).mask{1};
                            else tfilename='';
                            end
                            [tfilename,tpathname]=uigetfile('*.nii; *.img','Select explicit mask',tfilename);
                            if ischar(tfilename), CONN_x.vvAnalyses(CONN_x.vvAnalysis).mask=conn_file(fullfile(tpathname,tfilename));
                            else CONN_x.vvAnalyses(CONN_x.vvAnalysis).mask=[];
                            end
%                         case 7,
%                             nregressors=1; %get(CONN_h.menus.m_analyses_00{2},'value');
%                             txt=deblank(get(CONN_h.menus.m_analyses_00{7}(1),'string'));
%                             for nregressor=nregressors(:)', CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names{nregressor}=txt; end; 
%                             set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{2},'value')),length(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names))));
%                             set(CONN_h.menus.m_analyses_00{13},'string',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names,'value',max(1,min(max(get(CONN_h.menus.m_analyses_00{13},'value')),length(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names))));
                        case 8,
                            nregressors=1; %get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{8}(1),'string'));
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.dimensions_in{nregressor}=value; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 9,
                            nregressors=1; %get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{9}(1),'string'));
                            if length(value)==1, for nregressor=nregressors(:)', CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.dimensions_out{nregressor}=value; end; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case {11,12}
                            nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                            nconditions=get(CONN_h.menus.m_analyses_00{12},'value');
                            filepath=CONN_x.folders.preprocessing;
                            set(CONN_h.screen.hfig,'pointer','watch'); drawnow
                            if any(CONN_x.Setup.steps([2,3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                                filename=fullfile(filepath,['vvPC_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                                CONN_h.menus.m_analyses.Y=conn_vol(filename);
                                filename=fullfile(filepath,['vvPCeig_Subject',num2str(nsubs,'%03d'),'_Condition',num2str(CONN_h.menus.m_analyses.icondition(nconditions),'%03d'),'.mat']);
                                CONN_h.menus.m_analyses.y.data=load(filename,'D');
                            end
                            if 0,%~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                                try
                                    CONN_h.menus.m_analyses.XS=spm_vol(deblank(CONN_x.Setup.structural{nsubs}{1}{1})); %note: displaying first-session structural here
                                catch
                                    CONN_h.menus.m_analyses.XS=spm_vol(fullfile(fileparts(which('spm')),'canonical','single_subj_T1.nii'));
                                end
                            end
                            if 0,%~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)&&any(CONN_x.Setup.steps([3])),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                                xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                                CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                                CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                            else
                                CONN_h.menus.m_analyses.y.slice=max(1,min(4,CONN_h.menus.m_analyses.y.slice));
                                set(CONN_h.menus.m_analyses_00{15},'visible','off');
                                conn_menumanager('onregionremove',CONN_h.menus.m_analyses_00{15});
                            end
                            set(CONN_h.screen.hfig,'pointer','arrow');
                            model=1;
                        case 13
                            model=1;
                        case 15
                            CONN_h.menus.m_analyses.y.slice=round(get(CONN_h.menus.m_analyses_00{15},'value'));
%                             [CONN_h.menus.m_analyses.y.data,CONN_h.menus.m_analyses.y.idx]=conn_get_slice(CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.slice);
                            xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))*(CONN_h.menus.m_analyses.y.slice-1)+(1:prod(CONN_h.menus.m_analyses.Y.matdim.dim(1:2))),CONN_h.menus.m_analyses.Y.matdim.mat,CONN_h.menus.m_analyses.Y.matdim.dim);
                            CONN_h.menus.m_analyses.Xs=spm_get_data(CONN_h.menus.m_analyses.XS(1),pinv(CONN_h.menus.m_analyses.XS(1).mat)*xyz');
                            CONN_h.menus.m_analyses.Xs=permute(reshape(CONN_h.menus.m_analyses.Xs,CONN_h.menus.m_analyses.Y.matdim.dim(1:2)),[2,1,3]);
                            model=1;
                        case 17,
                            nregressors=1; %get(CONN_h.menus.m_analyses_00{2},'value');
                            value=get(CONN_h.menus.m_analyses_00{17}(1),'value');
                            for nregressor=nregressors(:)', CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.norm{nregressor}=value; end
                            nview=get(CONN_h.menus.m_analyses_00{13},'value');
                            model=any(nregressors==nview);
                        case 20,
                            if numel(varargin)>=3, tianalysis=varargin{3}; 
                            else tianalysis=get(CONN_h.menus.m_analyses_00{20},'value');
                            end
                            analysisname=char(get(CONN_h.menus.m_analyses_00{20},'string'));
                            if ischar(tianalysis)&&strcmp(tianalysis,'new'), tianalysis=size(analysisname,1)-2; end
                            if tianalysis==size(analysisname,1)-2, % new 
                                ok=0;
                                while ~ok,
                                    txt=inputdlg('New analysis name (alphanumeric case sensitive):','conn',1,{['V2V_',num2str(tianalysis,'%02d')]});
                                    if isempty(txt)||isempty(txt{1}), break; end
                                    txt{1}=regexprep(txt{1},'[^\w\d_]','');
                                    if isempty(txt{1}), break; end
                                    if ~ismember(txt{1},{CONN_x.Analyses.name CONN_x.vvAnalyses.name CONN_x.dynAnalyses.name})
                                        [ok,nill]=mkdir(CONN_x.folders.firstlevel_vv,txt{1});
                                        if ~ok, conn_msgbox('Unable to create folder. Check folder permissions','conn',2);end
                                    else conn_msgbox('Duplicated analysis name. Please try a different name','conn',2);
                                    end
                                end
                                if ok,
                                    CONN_x.vvAnalyses(tianalysis)=CONN_x.vvAnalyses(CONN_x.vvAnalysis);
                                    CONN_x.vvAnalyses(tianalysis).name=txt{1};
                                    CONN_x.vvAnalyses(tianalysis).measures={};
                                    CONN_x.vvAnalyses(tianalysis).measurenames={};
                                    CONN_x.vvAnalysis=tianalysis;
                                    conn gui_analyses;
                                    answ=conn_questdlg('Save these changes to CONN project?','','Now','Later','Now');
                                    if isequal(answ,'Now')
                                        hm=conn_msgbox('Saving project, please wait','');
                                        conn gui_setup_save;
                                        if ishandle(hm), delete(hm); end
                                    end
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',CONN_x.vvAnalysis);
                                end
                            elseif tianalysis==size(analysisname,1)-1, % rename
                                ok=0;
                                if ~isempty(CONN_x.vvAnalyses(CONN_x.vvAnalysis).name) % note: very-old analyses (empty analysis name) cannot be renamed
                                    while ~ok,
                                        txt=inputdlg('New analysis name (alphanumeric case sensitive):','conn',1,{CONN_x.vvAnalyses(CONN_x.vvAnalysis).name});
                                        if isempty(txt)||isempty(txt{1}), break; end
                                        txt{1}=regexprep(txt{1},'[^\w\d_]','');
                                        if isempty(txt{1}), break; end
                                        if ~ismember(txt{1},{CONN_x.Analyses.name CONN_x.vvAnalyses.name CONN_x.dynAnalyses.name})
                                            if isempty(CONN_x.vvAnalyses(CONN_x.vvAnalysis).name), [ok,nill]=mkdir(CONN_x.folders.firstlevel_vv,txt{1});
                                            elseif ispc, [ok,nill]=system(sprintf('ren "%s" "%s"',fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses(CONN_x.vvAnalysis).name),fullfile(CONN_x.folders.firstlevel_vv,txt{1}))); ok=isequal(ok,0);
                                            else [ok,nill]=system(sprintf('mv ''%s'' ''%s''',fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses(CONN_x.vvAnalysis).name),fullfile(CONN_x.folders.firstlevel_vv,txt{1}))); ok=isequal(ok,0);
                                            end
                                            if ~ok, conn_msgbox('Unable to create folder. Check folder permissions','conn',2);end
                                        else conn_msgbox('Duplicated analysis name. Please try a different name','conn',2);
                                        end
                                    end
                                else conn_msgbox('Sorry, this analysis was created in an older version of CONN and it cannot be renamed','',2); 
                                end
                                if ok,
                                    CONN_x.vvAnalyses(CONN_x.vvAnalysis).name=txt{1}; 
                                    conn gui_analyses;
                                    answ=conn_questdlg('Save these changes to CONN project?','','Now','Later','Now');
                                    if isequal(answ,'Now')
                                        hm=conn_msgbox('Saving project, please wait','');
                                        conn gui_setup_save;
                                        if ishandle(hm), delete(hm); end
                                    end
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',CONN_x.vvAnalysis);
                                end
                            elseif tianalysis==size(analysisname,1),  % delete
                                answ=conn_questdlg({sprintf('Are you sure you want to delete analysis %s?',CONN_x.vvAnalyses(CONN_x.vvAnalysis).name),'This is a non-reversible operation'},'','Delete','Cancel','Cancel');
                                if isequal(answ,'Delete')
                                    CONN_x.vvAnalyses=CONN_x.vvAnalyses([1:CONN_x.vvAnalysis-1,CONN_x.vvAnalysis+1:end]);
                                    CONN_x.vvAnalysis=min(numel(CONN_x.vvAnalyses),CONN_x.vvAnalysis);
                                    conn gui_analyses;
                                    answ=conn_questdlg('Save these changes to CONN project?','','Now','Later','Now');
                                    if isequal(answ,'Now')
                                        hm=conn_msgbox('Saving project, please wait','');
                                        conn gui_setup_save;
                                        if ishandle(hm), delete(hm); end
                                    end
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',CONN_x.vvAnalysis);
                                end
                            else
                                CONN_x.vvAnalysis=tianalysis;
                                conn gui_analyses;
                                return;
                            end
                    end
                end
                nsubs=get(CONN_h.menus.m_analyses_00{11},'value');
                nregressors=1; %min(get(CONN_h.menus.m_analyses_00{2},'value'),numel(get(CONN_h.menus.m_analyses_00{2},'string')));
                if numel(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names)<nregressors, nregressors=[]; end
                nview=get(CONN_h.menus.m_analyses_00{13},'value');
                nmeasure=nview;
%                 [CONN_h.menus.m_analyses.X,CONN_h.menus.m_analyses.select]=conn_designmatrix(CONN_x.Analyses(ianalysis).regressors,CONN_h.menus.m_analyses.X1,[],{nregressors,nview});
%                 if isempty(nregressors), conn_menu('update',CONN_h.menus.m_analyses_00{3},[]);
%                 else  conn_menu('update',CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses.X); end
                if ~isempty(nregressors)&&all(nregressors>0),
                    temp=cat(1,CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.localsupport{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{4}(1),'string',num2str(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.localsupport{nregressors(1)}));
                    else  set(CONN_h.menus.m_analyses_00{4}(1),'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.norm{nregressors});
                    if size(temp,1)==1 || ~any(any(diff(temp,1,1))), set([CONN_h.menus.m_analyses_00{3} CONN_h.menus.m_analyses_00{17}],'value',CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.norm{nregressors(1)},'visible','on');
                    else set([CONN_h.menus.m_analyses_00{3} CONN_h.menus.m_analyses_00{17}],'visible','off'); end
                    temp=cat(1,CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.global{nregressors});
                    if all(cell2mat(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.global(nregressors))==0),set(CONN_h.menus.m_analyses_00{4},'visible','on');
                    else set(CONN_h.menus.m_analyses_00{4},'visible','off'); end
                    if 0,%size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{5}(1),'value',1+CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.global{nregressors(1)}(1));set(CONN_h.menus.m_analyses_00{5},'visible','on');
                    else  set(CONN_h.menus.m_analyses_00{5},'visible','off'); end
                    temp=cat(1,CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.deriv{nregressors});
                    if 0,%size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{6}(1),'value',1+CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.deriv{nregressors(1)}(1));set(CONN_h.menus.m_analyses_00{6},'visible','on');
                    else  set(CONN_h.menus.m_analyses_00{6},'visible','off'); end
                    temp=strvcat(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names{nregressors});
                    %if size(temp,1)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{7}(1),'string',deblank(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names{nregressors(1)}(1,:)));
                    %else  set(CONN_h.menus.m_analyses_00{7}(1),'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.dimensions_in{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{8}(1),'string',num2str(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.dimensions_in{nregressors(1)}));
                    else  set(CONN_h.menus.m_analyses_00{8}(1),'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.dimensions_out{nregressors});
                    if length(temp)==1 || ~any(any(diff(temp,1,1))),set(CONN_h.menus.m_analyses_00{9}(1),'string',num2str(CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.dimensions_out{nregressors(1)}));
                    else  set(CONN_h.menus.m_analyses_00{9}(1),'string','MULTIPLE VALUES'); end
                    temp=cat(1,CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.measuretype{nregressors});
                    if any(ismember(temp,[2,3,4])), set([CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6}],'visible','off'); end
                    if any(temp==5), set([CONN_h.menus.m_analyses_00{4}],'visible','off'); end
                    if ~all(temp==2), set([CONN_h.menus.m_analyses_00{17}],'visible','off'); end
                    if ~all(ismember(temp,[2,3,4])), set([CONN_h.menus.m_analyses_00{7} CONN_h.menus.m_analyses_00{9}],'visible','off'); else set([CONN_h.menus.m_analyses_00{7} CONN_h.menus.m_analyses_00{9}],'visible','on'); end
                    if ~isempty(CONN_x.vvAnalyses(CONN_x.vvAnalysis).mask), set(CONN_h.menus.m_analyses_00{7}(1),'value',1); else set(CONN_h.menus.m_analyses_00{7}(1),'value',0); end
                    if any(ismember(temp,[6,7])), set(CONN_h.menus.m_analyses_00{8},'visible','off');
                    else set(CONN_h.menus.m_analyses_00{8},'visible','on');
                    end
                else
                    set([CONN_h.menus.m_analyses_00{3},CONN_h.menus.m_analyses_00{17},CONN_h.menus.m_analyses_00{4},CONN_h.menus.m_analyses_00{5},CONN_h.menus.m_analyses_00{6},CONN_h.menus.m_analyses_00{7},CONN_h.menus.m_analyses_00{8},CONN_h.menus.m_analyses_00{9}],'visible','off');%
                end
                value=get(CONN_h.menus.m_analyses_00{13},'value');if isempty(value),set(CONN_h.menus.m_analyses_00{13},'value',1); end

                if 0,%model&&any(CONN_x.Setup.steps(3))&&~isempty(nmeasure),%~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly,
                    measures=CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors;
                    if numel(measures.names)>0
                        if ~ismember(measures.measuretype{nmeasure},[2 3 4])
                            if ~(isfield(CONN_h.menus.m_analyses.Y,'issurface')&&CONN_h.menus.m_analyses.Y.issurface)
                                set(CONN_h.screen.hfig,'pointer','watch');drawnow
                                d=conn_v2v('compute_slice',measures,nmeasure,CONN_h.menus.m_analyses.Y,CONN_h.menus.m_analyses.y.data.D,CONN_h.menus.m_analyses.y.slice);
                                set(CONN_h.screen.hfig,'pointer','arrow');
                                %                         t1=zeros(CONN_h.menus.m_analyses.Y(1).dim(1:2));
                                %                         t2=0+zeros(CONN_h.menus.m_analyses.Y(1).dim(1:2));
                                t1=d;
                                t1=permute(t1,[2,1,3]);
                                t2=abs(d);
                                t2=permute(t2,[2,1,3]);
                                set(CONN_h.menus.m_analyses_00{14}.h9,'string',num2str(max(t2(:))));
                                conn_menu('update',CONN_h.menus.m_analyses_00{14},{CONN_h.menus.m_analyses.Xs,t1,t2},{CONN_h.menus.m_analyses.Y.matdim,CONN_h.menus.m_analyses.y.slice});
                                conn_menu('updatecscale',[],[],CONN_h.menus.m_analyses_00{14}.h9);
                                conn_menu('updatethr',[],[],CONN_h.menus.m_analyses_00{14}.h10);
                            else
                                conn_menu('update',CONN_h.menus.m_analyses_00{14},[]);
                                % preview not available yet... (need to optimize code below for speed in low-res case)
%                                 params=conn_v2v('compute_start',measures,nmeasure,Y1.matdim.mat,issurface);
%                                 for ndim=1:min(params.dimensions_in,Y1.size.Nt),
%                                     [y1,idxy1]=conn_get_time(Y1,ndim);
%                                     params=conn_v2v('compute_step',params,y1,D1.D(ndim),ndim,numel(idxy1));
%                                 end
%                                 d=conn_v2v('compute_end',params);
%                                 if iscell(d)
%                                     dsum=0;
%                                     for nout=1:numel(d), dsum=dsum+abs(d{nout}).^2; end
%                                     dsum=sqrt(abs(dsum));
%                                 end
                            end
                        else
                            conn_menu('update',CONN_h.menus.m_analyses_00{14},[]);
                        end
                    end
                end
            else, %DYNAMIC CONNECTIVITY
                boffset=[.14 .0 0 0];
                if nargin<2, 
                    if ~any(CONN_x.Setup.steps(state)), conn_msgbox('Dynamic connectivity analyses not enabled in Setup.Options. Please enable this option before continuing','',2); return; end %conn gui_setup; return; end
                    conn_menumanager clf;
                    conn_menuframe;
                    tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(3)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate);
                    conn_menu('frame2border',[.0,.955,1,.045],'');
                    %conn_menu('frame2border',[.0,.0,.115,.94]);
                    conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                    conn_menumanager([CONN_h.menus.m_analyses_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                    conn_menu('nullstr',{'No data','to display'});
                    
                    conn_menu('frame',boffset+[.095,.22,.38,.56],' ');%,'First-level analyses');%'DYNAMIC CONNECTIVITY ANALYSIS');
                    if isfield(CONN_x.dynAnalyses,'name')&&~isempty(CONN_x.dynAnalyses(CONN_x.dynAnalysis).name)
                        %conn_menu('title2',boffset+[.115,.775,.19,.04],'First-level analysis:');
                        txt=strvcat(CONN_x.dynAnalyses(:).name,'<HTML><i>new</i></HTML>','<HTML><i>rename</i></HTML>','<HTML><i>delete</i></HTML>');
                        CONN_h.menus.m_analyses_00{20}=conn_menu('popupbigblue',boffset+[.095,.78,.38,.05],'',txt(CONN_x.dynAnalysis,:),'<HTML>Analysis name <br/> - Select existing first-level analysis name to edit its properties <br/> - select <i>new/rename/delete</i> to define a new set of first-level analyses within this project, or the rename or delete the selected analysis</HTML>','conn(''gui_analyses'',20);');
                        %CONN_h.menus.m_analyses_00{20}=conn_menu('popup2',[.005,.78,.125,.04],'Analysis name:',txt(CONN_x.dynAnalysis,:),'<HTML>Analysis name <br/> - Select existing first-level analysis name to edit its properties <br/> - select <i>new</i> to define a new set of first-level analyses within this project</HTML>','conn(''gui_analyses'',20);');
                        set(CONN_h.menus.m_analyses_00{20},'string',txt,'value',CONN_x.dynAnalysis);%,'fontsize',12+CONN_gui.font_offset);%,'fontweight','bold');
                    end
                    CONN_h.menus.m_analyses_00{16}=conn_menu('popup',boffset+[.105,.68,.36,.04],'Analysis type','Dynamic/temporal modulation of functional connectivity','<HTML>These analyses characterize the dynamic/temporal chnages in functional connectivity observed in the data. <br/> <br/>The analyses estimate a set of components characterizing independent circuits of connections that share the same temporal modulation patterns. <br/>Components are estimated using iterative dual-regression on a gPPI model with unknown temporal-modulation "psychological" terms, followed by <br/>Independent Component Analyses (FastICA) to estimate spatially-independent circuits</HTML>');
                    %set(CONN_h.menus.m_analyses_00{16},'horizontalalignment','left');
                    CONN_h.menus.m_analyses_00{4}=[]; [CONN_h.menus.m_analyses_00{4}(1),CONN_h.menus.m_analyses_00{4}(2)]=conn_menu('edit',boffset+[.105,.59,.20,.04],'Number of factors','','<HTML>Define number of group-level components to estimate</HTML>','conn(''gui_analyses'',4);');
                    CONN_h.menus.m_analyses_00{6}=conn_menu('edit',boffset+[.105,.51,.12,.04],'Smoothing kernel','','<HTML>Temporal modulation smoothing kernel FWHM (in seconds)</HTML>','conn(''gui_analyses'',6);');
                    %CONN_h.menus.m_analyses_00{12}=conn_menu('popup',boffset+[.255,.29,.20,.04],'',{'Dynamic connectivity measures only','Dynamic factor analysis only','Dynamic connectivity and factor analyses'},'<HTML>Choose type of dynamic connectivity analysis</HTML>','conn(''gui_analyses'',12);');
                    CONN_h.menus.m_analyses_00{9}=[]; %[CONN_h.menus.m_analyses_00{9}(1),CONN_h.menus.m_analyses_00{9}(2)]=conn_menu('checkbox',boffset+[.255,.60,.02,.03],'Compute back-projections','','<HTML>Compute subject-specific projections of estimated group-level components <br/> - Subject-specific projections are computed using a gPPI ROI-to-ROI model simulataneously entering all of the estimated modulatory timeseries as psychological terms<br/> - Additional first-level ROI-to-ROI and seed-to-voxel analyses (using these or other ROIs) can be performed at a later time by selecting analysis type <i>temporal-modulation effects (dyn-ICA)</i> in </i> first-level analyses</i></HTML>','conn(''gui_analyses'',9);');
                    CONN_h.menus.m_analyses_00{10}=[]; %[CONN_h.menus.m_analyses_00{10}(1),CONN_h.menus.m_analyses_00{10}(2)]=conn_menu('checkbox',boffset+[.255,.55,.02,.03],'Compute dynamic properties','','<HTML>Computes dynamic properties of each component modulatory timeseries (average, variability, and rate of change)</HTML>','conn(''gui_analyses'',10);');
                    CONN_h.menus.m_analyses_00{11}=[]; [CONN_h.menus.m_analyses_00{11}(1),CONN_h.menus.m_analyses_00{11}(2)]=conn_menu('checkbox',boffset+[.105,.25,.02,.03],'Export modulatory timeseries','','(optional) Export the estimated modulatory timeseries as first-level covariates for additional analyses','conn(''gui_analyses'',11);');
                    %[nill,CONN_h.menus.m_analyses_00{16}]=conn_menu('text',boffset+[.105,.30,.26,.05],'ROI-to-ROI seeds/sources:');
                    %set(CONN_h.menus.m_analyses_00{16},'horizontalalignment','left');
                    CONN_h.menus.m_analyses_00{2}=conn_menu('listbox',boffset+[.105,.30,.195,.15],'Seeds/Sources','','<HTML>List of seeds/ROIs to be included in this analysis  <br/>- Select ROIs in the <i>all ROIs</i> list and click <b> &lt </b> to add new sources to this list<br/> - Select sources in this list and click <b> &gt </b> to remove them from this list </HTML>','conn(''gui_analyses'',2);');
                    CONN_h.menus.m_analyses_00{1}=conn_menu('listbox',boffset+[.32,.30,.145,.15],'all ROIs','','List of all seeds/ROIs','conn(''gui_analyses'',1);');
                    CONN_h.menus.m_analyses_00{30}=conn_menu('pushbutton',boffset+[.30,.30,.02,.15],'','<','move elements between ''Seeds/Sources'' and ''all ROIs'' lists', 'conn(''gui_analyses'',0);');
                    CONN_h.menus.m_analyses_00{23}=uicontrol('style','frame','units','norm','position',boffset+[.30,.30,.165,.20],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA);
                    conn_menumanager('onregion',CONN_h.menus.m_analyses_00{23},-1,boffset+[.105 .10 .38 .40]);
                    for n=1:3, set(CONN_h.menus.m_analyses_00{8+n},'value',CONN_x.dynAnalyses(CONN_x.dynAnalysis).output(n)); end
                     
                    if ~isfield(CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables,'names')||isempty(CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names), 
                        CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names=CONN_x.Analyses(1).variables.names;
                        CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names=CONN_x.Analyses(1).regressors.names;
                    end
                    set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'max',2);
                    tnames=CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names;
                    tnames(ismember(CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names,CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names,CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names)),'uni',0);
                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names);
                    %conn_menumanager(CONN_h.menus.m_analyses_01b,'on',1);
                    set([CONN_h.menus.m_analyses_00{1},CONN_h.menus.m_analyses_00{2}],'value',[]);
                    set(CONN_h.menus.m_analyses_00{4}(1),'string',num2str(CONN_x.dynAnalyses(CONN_x.dynAnalysis).Ncomponents));
                    CONN_x.dynAnalyses(CONN_x.dynAnalysis).condition=[];%set(CONN_h.menus.m_analyses_00{5},'value',CONN_x.dynAnalyses(CONN_x.dynAnalysis).condition);
                    CONN_x.dynAnalyses(CONN_x.dynAnalysis).output(1)=1;
                    CONN_x.dynAnalyses(CONN_x.dynAnalysis).output(2)=1;
                    set(CONN_h.menus.m_analyses_00{6},'string',mat2str(CONN_x.dynAnalyses(CONN_x.dynAnalysis).window));
                    %set(CONN_h.menus.m_analyses_00{12},'value',CONN_x.dynAnalyses(CONN_x.dynAnalysis).analyses);
                    if any(arrayfun(@(n)isempty(dir(fullfile(CONN_x.folders.preprocessing,['ROI_Subject',num2str(n,'%03d'),'_Condition',num2str(0,'%03d'),'.mat']))),1:CONN_x.Setup.nsubjects)), conn_msgbox({'Not ready to start first-level Analysis step',' ','Please complete the Denoising step first','(fill any required information and press "Done" in the Denoising tab)'},'',2); return; end %conn gui_preproc; return; end
                    conn_menumanager([CONN_h.menus.m_analyses_05],'on',1);
                else
                    switch(varargin{2}),
                        case 0,
                            str=get(CONN_h.menus.m_analyses_00{30},'string');
                            %str=conn_menumanager(CONN_h.menus.m_analyses_01b,'string');
                            switch(str),
                                case '<',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{1},'value');
                                    for ncovariate=ncovariates(:)',
                                        if isempty(strmatch(CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names{ncovariate},CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names,'exact')),
                                            CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names{end+1}=CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names{ncovariate};
                                        end
                                    end
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names);
                                    tnames=CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names;
                                    tnames(ismember(CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names,CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names,CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names)),'uni',0);
                                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                                case '>',
                                    ncovariates=get(CONN_h.menus.m_analyses_00{2},'value');
                                    idx=setdiff(1:length(CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names),ncovariates);
                                    CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names={CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names{idx}};
                                    set(CONN_h.menus.m_analyses_00{2},'string',CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names,'value',min(max(ncovariates),length(CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names)));
                                    tnames=CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names;
                                    tnames(ismember(CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names,CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names))=cellfun(@(x)[CONN_gui.parse_html{1},x,CONN_gui.parse_html{2}],tnames(ismember(CONN_x.dynAnalyses(CONN_x.dynAnalysis).variables.names,CONN_x.dynAnalyses(CONN_x.dynAnalysis).regressors.names)),'uni',0);
                                    set(CONN_h.menus.m_analyses_00{1},'string',tnames);
                            end
                            model=1;
                        case 1,
                            set(CONN_h.menus.m_analyses_00{30},'string','<');
                            %conn_menumanager(CONN_h.menus.m_analyses_01b,'string',{'<'},'on',1);
                            set(CONN_h.menus.m_analyses_00{2},'value',[]);
                        case 2,
                            set(CONN_h.menus.m_analyses_00{30},'string','>');
                            %conn_menumanager(CONN_h.menus.m_analyses_01b,'string',{'>'},'on',1);
                            set(CONN_h.menus.m_analyses_00{1},'value',[]);
                        case 4,
                            nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                            value=str2num(get(CONN_h.menus.m_analyses_00{4}(1),'string'));
                            if length(value)==1, CONN_x.dynAnalyses(CONN_x.dynAnalysis).Ncomponents=round(max(0,min(inf,value))); end
                        case 6,
                            temp=str2num(get(CONN_h.menus.m_analyses_00{6},'string'));
                            if numel(temp)==1||isempty(temp), CONN_x.dynAnalyses(CONN_x.dynAnalysis).window=temp; end
                            set(CONN_h.menus.m_analyses_00{6},'string',mat2str(CONN_x.dynAnalyses(CONN_x.dynAnalysis).window));
                        case 9,
                            val=get(CONN_h.menus.m_analyses_00{9}(1),'value');
                            CONN_x.dynAnalyses(CONN_x.dynAnalysis).output(1)=val;
                        case 10,
                            val=get(CONN_h.menus.m_analyses_00{10}(1),'value');
                            CONN_x.dynAnalyses(CONN_x.dynAnalysis).output(2)=val;
                        case 11,
                            val=get(CONN_h.menus.m_analyses_00{11}(1),'value');
                            CONN_x.dynAnalyses(CONN_x.dynAnalysis).output(3)=val;
%                         case 12,
%                             val=get(CONN_h.menus.m_analyses_00{12},'value');
%                             CONN_x.dynAnalyses(CONN_x.dynAnalysis).analyses=val;
                        case 20,
                            if numel(varargin)>=3, tianalysis=varargin{3}; 
                            else tianalysis=get(CONN_h.menus.m_analyses_00{20},'value');
                            end
                            analysisname=char(get(CONN_h.menus.m_analyses_00{20},'string'));
                            if ischar(tianalysis)&&strcmp(tianalysis,'new'), tianalysis=size(analysisname,1)-2; end
                            if tianalysis==size(analysisname,1)-2, % new 
                                ok=0;
                                while ~ok,
                                    txt=inputdlg('New analysis name (alphanumeric case sensitive):','conn',1,{['DYN_',num2str(tianalysis,'%02d')]});
                                    if isempty(txt)||isempty(txt{1}), break; end
                                    txt{1}=regexprep(txt{1},'[^\w\d_]','');
                                    if isempty(txt{1}), break; end
                                    if ~ismember(txt{1},{CONN_x.Analyses.name CONN_x.vvAnalyses.name CONN_x.dynAnalyses.name})
                                        [ok,nill]=mkdir(CONN_x.folders.firstlevel_dyn,txt{1});
                                        if ~ok, conn_msgbox('Unable to create folder. Check folder permissions','conn',2);end
                                    else conn_msgbox('Duplicated analysis name. Please try a different name','conn',2);
                                    end
                                end
                                if ok,
                                    CONN_x.dynAnalyses(tianalysis)=CONN_x.dynAnalyses(CONN_x.dynAnalysis);
                                    CONN_x.dynAnalyses(tianalysis).name=txt{1};
                                    CONN_x.dynAnalyses(tianalysis).sources={};
                                    CONN_x.dynAnalysis=tianalysis;
                                    conn gui_analyses;
                                    answ=conn_questdlg('Save these changes to CONN project?','','Now','Later','Now');
                                    if isequal(answ,'Now')
                                        hm=conn_msgbox('Saving project, please wait','');
                                        conn gui_setup_save;
                                        if ishandle(hm), delete(hm); end
                                    end
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',CONN_x.dynAnalysis);
                                end
                            elseif tianalysis==size(analysisname,1)-1, % rename
                                ok=0;
                                if ~isempty(CONN_x.dynAnalyses(CONN_x.dynAnalysis).name) % note: very-old analyses (empty analysis name) cannot be renamed
                                    while ~ok,
                                        txt=inputdlg('New analysis name (alphanumeric case sensitive):','conn',1,{CONN_x.dynAnalyses(CONN_x.dynAnalysis).name});
                                        if isempty(txt)||isempty(txt{1}), break; end
                                        txt{1}=regexprep(txt{1},'[^\w\d_]','');
                                        if isempty(txt{1}), break; end
                                        if ~ismember(txt{1},{CONN_x.Analyses.name CONN_x.vvAnalyses.name CONN_x.dynAnalyses.name})
                                            if ispc, [ok,nill]=system(sprintf('ren "%s" "%s"',fullfile(CONN_x.folders.firstlevel_dyn,CONN_x.dynAnalyses(CONN_x.dynAnalysis).name),fullfile(CONN_x.folders.firstlevel_dyn,txt{1}))); ok=isequal(ok,0);
                                            else [ok,nill]=system(sprintf('mv ''%s'' ''%s''',fullfile(CONN_x.folders.firstlevel_dyn,CONN_x.dynAnalyses(CONN_x.dynAnalysis).name),fullfile(CONN_x.folders.firstlevel_dyn,txt{1}))); ok=isequal(ok,0);
                                            end
                                            if ~ok, conn_msgbox('Unable to create folder. Check folder permissions','conn',2);end
                                        else conn_msgbox('Duplicated analysis name. Please try a different name','conn',2);
                                        end
                                    end
                                else conn_msgbox('Sorry, this analysis was created in an older version of CONN and it cannot be renamed','',2); 
                                end
                                if ok,
                                    CONN_x.dynAnalyses(CONN_x.dynAnalysis).name=txt{1}; 
                                    conn gui_analyses;
                                    answ=conn_questdlg('Save these changes to CONN project?','','Now','Later','Now');
                                    if isequal(answ,'Now')
                                        hm=conn_msgbox('Saving project, please wait','');
                                        conn gui_setup_save;
                                        if ishandle(hm), delete(hm); end
                                    end
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',CONN_x.dynAnalysis);
                                end
                            elseif tianalysis==size(analysisname,1),  % delete
                                answ=conn_questdlg({sprintf('Are you sure you want to delete analysis %s?',CONN_x.dynAnalyses(CONN_x.dynAnalysis).name),'This is a non-reversible operation'},'','Delete','Cancel','Cancel');
                                if isequal(answ,'Delete')
                                    CONN_x.dynAnalyses=CONN_x.dynAnalyses([1:CONN_x.dynAnalysis-1,CONN_x.dynAnalysis+1:end]);
                                    CONN_x.dynAnalysis=min(numel(CONN_x.dynAnalyses),CONN_x.dynAnalysis);
                                    conn gui_analyses;
                                    answ=conn_questdlg('Save these changes to CONN project?','','Now','Later','Now');
                                    if isequal(answ,'Now')
                                        hm=conn_msgbox('Saving project, please wait','');
                                        conn gui_setup_save;
                                        if ishandle(hm), delete(hm); end
                                    end
                                    return;
                                else
                                    set(CONN_h.menus.m_analyses_00{20},'value',CONN_x.dynAnalysis);
                                end
                            else
                                CONN_x.dynAnalysis=tianalysis;
                                conn gui_analyses;
                                return;
                            end
                    end
                end
                nregressors=get(CONN_h.menus.m_analyses_00{2},'value');
                set(CONN_h.menus.m_analyses_00{4}(1),'string',num2str(CONN_x.dynAnalyses(CONN_x.dynAnalysis).Ncomponents));
                %if CONN_x.dynAnalyses(CONN_x.dynAnalysis).analyses==1, set([CONN_h.menus.m_analyses_00{4} CONN_h.menus.m_analyses_00{9} CONN_h.menus.m_analyses_00{10} CONN_h.menus.m_analyses_00{11}],'visible','off');
                %else set([CONN_h.menus.m_analyses_00{4} CONN_h.menus.m_analyses_00{9} CONN_h.menus.m_analyses_00{10} CONN_h.menus.m_analyses_00{11}],'visible','on');
                %end
            end
			
		case 'gui_analyses_done',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            tsteps=CONN_x.Setup.steps(1:3);
            switch(CONN_x.Analyses(CONN_x.Analysis).type)
                case 1, tsteps=[1 0 0]; 
                case 2, tsteps=[0 1 0];
                case 3, tsteps=[1 1 0]; 
            end
            if ~ischar(CONN_x.Analyses(CONN_x.Analysis).modulation)&&CONN_x.Analyses(CONN_x.Analysis).modulation>0&&~isempty(CONN_x.Analyses(CONN_x.Analysis).conditions), condsoption=find(ismember(CONN_x.Setup.conditions.names(1:end-1),CONN_x.Analyses(CONN_x.Analysis).conditions)); %gPPI conditions
            else condsoption=true;
            end
            if conn_questdlgrun('Ready to run First-level Analysis processing pipeline',false,tsteps,condsoption,[],true,[],true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                if CONN_x.gui.parallel~=0, 
                    ispending=isequal(CONN_x.gui.parallel,find(strcmp('Null profile',conn_jobmanager('profiles'))));
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    if isfield(CONN_x.gui,'subjects'), subjects=CONN_x.gui.subjects; else subjects=[]; end
                    conn save;
                    conn_jobmanager('submit','analyses_gui_seedandroi',subjects,[],CONN_x.gui,CONN_x.Analysis);
                else conn_process('analyses_gui_seedandroi',CONN_x.Analysis); ispending=false;
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                if ~conn_projectmanager('ispending')&&~ispending, 
                    if any(CONN_x.Analyses(CONN_x.Analysis).type==[2,3]), conn gui_results_s2v; 
                    else conn gui_results_r2r;
                    end
                end
            end

		case 'gui_analyses_done_vv',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            tsteps=[0 0 1]; 
            if conn_questdlgrun('Ready to run Voxel-to-Voxel processing pipeline',false,tsteps,[],[],true,[],true);
                conn_menumanager clf;
                conn_menuframe;
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                if CONN_x.gui.parallel~=0, 
                    ispending=isequal(CONN_x.gui.parallel,find(strcmp('Null profile',conn_jobmanager('profiles'))));
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    if isfield(CONN_x.gui,'subjects'), subjects=CONN_x.gui.subjects; else subjects=[]; end
                    conn save;
                    conn_jobmanager('submit','analyses_gui_vv',subjects,[],CONN_x.gui,CONN_x.vvAnalysis);
                else conn_process('analyses_gui_vv',CONN_x.vvAnalysis); ispending=false;
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                if ~conn_projectmanager('ispending')&&~ispending, 
                    if any(ismember(conn_v2v('fieldtext',CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures,1),{'3','4'})), conn gui_results_ica_summary;
                    else conn gui_results_v2v;
                    end
                end
            end

		case 'gui_analyses_done_dyn',
			if isempty(CONN_x.filename), conn gui_setup_save; end
            tsteps=[0 0 0 1]; 
            condsoption=false;
            if CONN_x.dynAnalyses(CONN_x.dynAnalysis).output(1), condsoption=true; end; %CONN_x.dynAnalyses(CONN_x.dynAnalysis).condition; end
            if conn_questdlgrun('Ready to run Dynamic connectivity processing pipeline',false,tsteps,condsoption,[],true,[],true,0);
                conn_menumanager clf;
                conn_menuframe;
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                if CONN_x.gui.parallel~=0, 
                    ispending=isequal(CONN_x.gui.parallel,find(strcmp('Null profile',conn_jobmanager('profiles'))));
                    if CONN_x.gui.parallel>0, conn_jobmanager('options','profile',CONN_x.gui.parallel); end; 
                    if isfield(CONN_x.gui,'subjects'), subjects=CONN_x.gui.subjects; else subjects=[]; end
                    conn save;
                    conn_jobmanager('submit','analyses_gui_dyn',subjects,[],CONN_x.gui,CONN_x.dynAnalysis);
                else conn_process('analyses_gui_dyn',CONN_x.dynAnalysis); ispending=false;
                end
                CONN_x.gui=1;
                conn gui_setup_save;
                if ~conn_projectmanager('ispending')&&~ispending, conn gui_results_dyn_summary; end
            end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
        case 'gui_resultsgo'
            state=varargin{2};
            tstate=conn_menumanager(CONN_h.menus.m_results_03,'state'); tstate(:)=0;tstate(state)=1; conn_menumanager(CONN_h.menus.m_results_03,'state',tstate); 
            conn gui_results;
        case 'gui_resultsgo&select'
            option=['gui_results_',varargin{2}];
            args=varargin{3};
            fields={'nsubjecteffects','nsubjecteffectsbyname','csubjecteffects','nconditions','nconditionsbyname','cconditions'};
            switch(option)
                case 'gui_results_s2v', fields=[fields {'nsources','nsourcesbyname','csources','displayvoxels'}];
                case {'gui_results_v2v','gui_results_ica_spatial'}, fields=[fields {'nmeasures','nmeasuresbyname','cmeasures','displayvoxels'}];
                case {'gui_results_r2r','gui_results_dyn_spatial'}, fields=[fields {'nsources','nsourcesbyname','csources','inferencetype','inferencelevel','inferenceleveltype','displayrois','roiselected2','roiselected2byname'}];
            end
            for n=1:numel(fields), CONN_x.Results.xX.(fields{n})=args.(fields{n}); end
            switch(option)
                case {'gui_results_s2v','gui_results_r2r'}, CONN_x.Analysis=args.Analysis;
                case {'gui_results_v2v','gui_results_ica_spatial'}, CONN_x.vvAnalysis=args.vvAnalysis;
                case 'gui_results_dyn_spatial', CONN_x.dynAnalysis=args.dynAnalysis; CONN_x.Analysis=args.Analysis;
            end
            conn(option);
            if ~isempty(CONN_gui.warnloadbookmark), conn_msgbox(CONN_gui.warnloadbookmark,'',2); end
        case 'gui_results_bookmark',
            option=varargin{2};
            if numel(varargin)>=3&&~isempty(varargin{3}), tfilename=varargin{3};
            else tfilename=[];
            end
            tfilename=conn_bookmark('save',...
                tfilename,...
                '',...
                {'gui_resultsgo&select',option,CONN_x.Results.xX});
            if isempty(tfilename), return; end
            if ~(isfield(CONN_gui,'slice_display_skipbookmarkicons')&&CONN_gui.slice_display_skipbookmarkicons), conn_print(CONN_h.screen.hfig,conn_prepend('',tfilename,'.jpg'),'-nogui','-r50','-nopersistent'); end
            if 0, conn_msgbox(sprintf('Bookmark %s saved',tfilename),'',2);
            end
        case {'gui_results','gui_results_s2v','gui_results_r2r','gui_results_v2v','gui_results_dyn','gui_results_dyn_spatial','gui_results_dyn_temporal','gui_results_dyn_summary','gui_results_ica','gui_results_ica_spatial','gui_results_ica_temporal','gui_results_ica_summary'}
            CONN_x.gui=1;
			model=0;modelroi=0;
            boffset=[.05 .00 0 0];
            %if ~isfield(CONN_x.Setup,'normalized'), CONN_x.Setup.normalized=1; end
            if ~isfield(CONN_x,'Analysis'), CONN_x.Analysis=1; end
            ianalysis=max(1,min(numel(CONN_x.Analyses),CONN_x.Analysis));
            if ~isfield(CONN_x.Analyses(ianalysis),'name'),CONN_x.Analyses(ianalysis).name='ANALYSIS_01'; end
            if any(strcmp(lower(varargin{1}),{'gui_results_r2r','gui_results_s2v','gui_results_v2v','gui_results_dyn','gui_results_dyn_spatial','gui_results_dyn_temporal','gui_results_dyn_summary','gui_results_ica','gui_results_ica_spatial','gui_results_ica_temporal','gui_results_ica_summary'}))
                istate=find(strcmp(lower(varargin{1}),{'gui_results_r2r','gui_results_s2v','gui_results_v2v','gui_results_ica','gui_results_ica_spatial','gui_results_ica_temporal','gui_results_ica_summary','gui_results_dyn','gui_results_dyn_spatial','gui_results_dyn_temporal','gui_results_dyn_summary'}));
                jstate=[1,2,3,4,4,4,4,5,5,5,5];
                istate=jstate(istate);
                tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03,'state')));tstate(istate)=1;
                conn_menumanager(CONN_h.menus.m_results_03,'state',tstate);
            end
            stateb=0;
            state=find(conn_menumanager(CONN_h.menus.m_results_03,'state'));
            CONN_gui.warnloadbookmark={};
            if isempty(state), 
%                 conn_menumanager clf;
%                 conn_menuframe;
%                 tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(4)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate);
%                 conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m_results_03,CONN_h.menus.m0],'on',1);
%                 conn_menu('nullstr',{'No data','to display'});
%                 return; 
                
                if nargin<2
                    conn_menumanager clf;
                    conn_menuframe;
                    tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(4)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate);
                    conn_menu('frame2border',[.0,.955,1,.045],'');
                    conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                    conn_menumanager([CONN_h.menus.m_results_03,CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                    conn_menu('nullstr',' ');
                    
                    [nill,temp]=conn_menu('frame2noborder',[.16 .54 .23 .31],'All analyses'); set(temp,'horizontalalignment','left');
                    txt={CONN_x.Analyses(:).name};
                    if 1, CONN_h.menus.m_results.shownanalyses=find(cellfun(@(x)isempty(regexp(x,'^(.*\/|.*\\)?Dynamic factor .*\d+$')),txt)); 
                    else CONN_h.menus.m_results.shownanalyses=1:numel(txt); 
                    end
                    CONN_h.menus.m_results_00{1}=conn_menu('listbox2',[.165 .85-5*.06*1/3 .22 5*.06*1/3],'',{CONN_x.Analyses(CONN_h.menus.m_results.shownanalyses).name},'List of available ROI-to-ROI or Seed-to-Voxel analyses','conn(''gui_results'',1);');
                    set(CONN_h.menus.m_results_00{1},'max',2,'value',[]);
                    CONN_h.menus.m_results_00{2}=conn_menu('listbox2',[.165 .85-5*.06*2/3 .22 5*.06*1/3],'',{CONN_x.vvAnalyses(:).name},'List of available Voxel-to-Voxel or ICA analyses','conn(''gui_results'',2);');
                    set(CONN_h.menus.m_results_00{2},'max',2,'value',[]);
                    CONN_h.menus.m_results_00{3}=conn_menu('listbox2',[.165 .85-5*.06*3/3 .22 5*.06*1/3],'',{CONN_x.dynAnalyses(:).name},'List of available dyn-ICA analyses','conn(''gui_results'',3);');
                    set(CONN_h.menus.m_results_00{3},'max',2,'value',[]);
                    hax=conn_menu('axes',[.115 .85-5*.06 .03 5*.06]);
                    plot([0 1 nan 0 1 nan 0 1 nan 1 1 nan 1 1 nan 1 1],[0.5/5 0.5/3 nan 2/5 1.5/3 nan 4/5 2.5/3 nan .1/3 .9/3 nan 1.1/3 1.9/3 nan 2.1/3 2.9/3],'-','color',CONN_gui.fontcolorB,'linewidth',2,'parent',hax);
                    set(hax,'xlim',[0 1],'ylim',[0 1],'visible','off');
                    
                    if ~isfield(CONN_h.menus.m_results,'bookmark_page'), CONN_h.menus.m_results.bookmark_page=1; end
                    if ~isfield(CONN_h.menus.m_results,'bookmark_folder'), CONN_h.menus.m_results.bookmark_folder=[]; end
                    if ~isfield(CONN_h.menus.m_results,'bookmark_style'), CONN_h.menus.m_results.bookmark_style=1; end
                    Nplots=[3 2];
                    pos=[.55 .35];
                    conn_menu('frame2noborder',[pos(1)-.02,.08,pos(2)+.04,.77],' ');%'Bookmarked plots');
                    tdirs=dir(fullfile(CONN_x.folders.bookmarks,'*'));
                    tdirs=tdirs([tdirs.isdir]&~ismember({tdirs.name},{'.','..'}));
                    tdirs={tdirs.name};
                    CONN_h.menus.m_results.bookmark_allfolders=tdirs;
                    CONN_h.menus.m_results_00{8}=conn_menu('popup2big',[pos(1)-.01,.85,.26,.04],'',{'All bookmarks',tdirs{:}},'<HTML>List of all bookmarked plots or results in this project <br/> - Bookmarks are links to specific plots or 2nd-level analyses that can be used to help organize complex sets of analyses or results<br/> - To bookmark a specific plot select <i>Bookmark.Save</i> in the corresponding window (e.g. conn 3d display or slice display windows)<br/> - To bookmark a specific 2nd-level analysis select <i>Bookmark</i> in the corresponding second-level results tab (e.g. ROI-to-ROI, seed-to-voxel, etc.)<br/> - All bookmarked plots or analyses will appear in the list below. They can be organized into multiple bookmark folders. Select <i>All bookmarks</i> or <br/>another bookmark folder in this menu, then select the specific bookmark in the list below for more options</HTML>','conn(''gui_results'',8);');
                    if isempty(CONN_h.menus.m_results.bookmark_folder),set(CONN_h.menus.m_results_00{8},'value',1);
                    elseif ismember(CONN_h.menus.m_results.bookmark_folder,tdirs), set(CONN_h.menus.m_results_00{8},'value',find(strcmp(CONN_h.menus.m_results.bookmark_folder,tdirs),1)+1); 
                    else CONN_h.menus.m_results.bookmark_folder=[];
                        set(CONN_h.menus.m_results_00{8},'value',1);
                    end
                    if isempty(CONN_h.menus.m_results.bookmark_folder), files=conn_dir(fullfile(CONN_x.folders.bookmarks,'*.bookmark.jpg'));
                    else files=conn_dir(fullfile(CONN_x.folders.bookmarks,CONN_h.menus.m_results.bookmark_folder,'*.bookmark.jpg'));
                    end
                    files=cellstr(files);
                    tvalid=find(cellfun('length',files)>0);
                    if ~isempty(tvalid)
                        tvalid=tvalid(cellfun(@conn_existfile,conn_prepend('',files(tvalid),'.mat'))>0);
                        files=files(tvalid);
                        [nill,files_name]=cellfun(@fileparts,files,'uni',0);
                        [nill,files_folder]=cellfun(@fileparts,nill,'uni',0);
                        [nill,idx]=sort(cellstr(cat(2,char(files_folder),char(files_name)))); % sort ascending (oldest first)
                        files=files(idx);files_name=files_name(idx); files_folder=files_folder(idx);
                        files_descr=repmat({''},size(files));
                        tvalid=cellfun(@conn_existfile,conn_prepend('',files,'.txt'));
                        files_descr(tvalid)=cellfun(@fileread,conn_prepend('',files(tvalid),'.txt'),'uni',0);
                        files_descr=cellfun(@(a,b){a,['(',b,')']},files_descr,files_name,'uni',0);
                        [j,i]=ind2sub(fliplr(Nplots),1:prod(Nplots));
                        maxpages=ceil(numel(files)/prod(Nplots));
                        CONN_h.menus.m_results_00{9}=conn_menu('popup2',[pos(1)+pos(2)-.08,.85,.10,.04],'',{'icons view','list view'},'Select between list or icon view','conn(''gui_results'',9);');
                        set(CONN_h.menus.m_results_00{9},'value',CONN_h.menus.m_results.bookmark_style);
                        if CONN_h.menus.m_results.bookmark_style==1
                            for n=1:prod(Nplots),
                                tpos=[pos(1)+pos(2)*(j(n)-1)/Nplots(2) .85-.7*i(n)/Nplots(1) (pos(2)-.02)/Nplots(2) .65/Nplots(1)];
                                %conn_menu('frame2',pos+0*[-.02 -.01 .04 .02]);
                                CONN_h.menus.m_results_00{10+n}=conn_menu('imageonly2',tpos,'','','',[],[]);
                            end
                            CONN_h.menus.m_results_00{4}=conn_menu('pushbutton2',[pos(1),.10,.05,.04],'','Prev','','conn(''gui_results'',4);');
                            CONN_h.menus.m_results_00{5}=conn_menu('pushbutton2',[pos(1)+pos(2)-.05,.10,.05,.04],'','Next','','conn(''gui_results'',5);');
                            CONN_h.menus.m_results_00{6}=conn_menu('popup2',[pos(1)+pos(2)-.15,.10,.10,.04],'',arrayfun(@(n)sprintf('page %d/%d',n,maxpages),1:maxpages,'uni',0),'','conn(''gui_results'',6);');
                        else
                            CONN_h.menus.m_results_00{7}=conn_menu('listbox2',[pos(1) .85-.7 pos(2)+.02 .65],'','','Select a bookmark in this list to open/edit/delete it','conn(''gui_results'',7);');
                        end
                        CONN_h.menus.m_results.bookmark_Nplots=Nplots;
                        CONN_h.menus.m_results.bookmark_files=files;
                        CONN_h.menus.m_results.bookmark_files_descr=files_descr;
                        CONN_h.menus.m_results.bookmark_files_folder=files_folder;
                        %for n=1:numel(i), data=imread(files{files_idx(n)}); conn_menu('updatematrixequal',CONN_h.menus.m_results_00{10+n},data); end
                        conn('gui_results',4.5);
                    end
                else
                    switch(varargin{2}),
                        case 1, value=get(CONN_h.menus.m_results_00{1},'value'); 
                            if ~isempty(value), 
                                try
                                    CONN_x.Analysis=CONN_h.menus.m_results.shownanalyses(value(1));
                                    if ~isempty(regexp(CONN_x.Analyses(CONN_x.Analysis).name,'^(.*\/|.*\\)?Dynamic factor .*\d+$')),
                                        i=find(strncmp({CONN_x.dynAnalyses(:).name},CONN_x.Analyses(CONN_x.Analysis).name,find(ismember(CONN_x.Analyses(CONN_x.Analysis).name,'\/'),1)-1));
                                        if ~isempty(i), CONN_x.dynAnalysis=i(1); conn('gui_results_dyn_spatial'); end
                                    elseif ismember(CONN_x.Analyses(CONN_x.Analysis).type,[2,3]), conn('gui_resultsgo',2);
                                    else conn('gui_resultsgo',1);
                                    end
                                end
                            end
                        case 2, value=get(CONN_h.menus.m_results_00{2},'value'); 
                            if ~isempty(value), 
                                CONN_x.vvAnalysis=value(1); 
                                if ismember(conn_v2v('fieldtext',CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures,1),{'3','4'}), conn('gui_results_ica_summary'); 
                                else conn('gui_resultsgo',3); 
                                end
                            end
                        case 3, value=get(CONN_h.menus.m_results_00{3},'value'); if ~isempty(value), CONN_x.dynAnalysis=value(1); conn('gui_results_dyn_summary'); end
                        case {4,4.5,5,6}
                            if CONN_h.menus.m_results.bookmark_style==1
                                if varargin{2}==4, CONN_h.menus.m_results.bookmark_page=CONN_h.menus.m_results.bookmark_page-1;
                                elseif varargin{2}==5, CONN_h.menus.m_results.bookmark_page=CONN_h.menus.m_results.bookmark_page+1;
                                elseif varargin{2}==6, CONN_h.menus.m_results.bookmark_page=get(CONN_h.menus.m_results_00{6},'value');
                                end
                                maxpages=ceil(numel(CONN_h.menus.m_results.bookmark_files)/prod(CONN_h.menus.m_results.bookmark_Nplots));
                                CONN_h.menus.m_results.bookmark_page=max(1,min(maxpages, CONN_h.menus.m_results.bookmark_page));
                                files_idx=(CONN_h.menus.m_results.bookmark_page-1)*prod(CONN_h.menus.m_results.bookmark_Nplots)+(1:prod(CONN_h.menus.m_results.bookmark_Nplots));
                                files_idx=files_idx(files_idx<=numel(CONN_h.menus.m_results.bookmark_files));
                                %[i,j]=ind2sub(CONN_h.menus.m_results.bookmark_Nplots,1:numel(files_idx));
                                %j=j+round((CONN_h.menus.m_results.bookmark_Nplots(2)-max(j(:)))/2);
                                for n=1:prod(CONN_h.menus.m_results.bookmark_Nplots)
                                    if n<=numel(files_idx),
                                        data=imread(CONN_h.menus.m_results.bookmark_files{files_idx(n)});
                                        CONN_h.menus.m_results_00{10+n}.hcallback=@(varargin)CONN_h.menus.m_results.bookmark_files_descr{files_idx(n)};
                                        CONN_h.menus.m_results_00{10+n}.hcallback2=@(varargin)conn('gui_results',7,CONN_h.menus.m_results.bookmark_files{files_idx(n)});
                                        conn_menu('updatematrixequal',CONN_h.menus.m_results_00{10+n},data);
                                        %drawnow;
                                    else
                                        CONN_h.menus.m_results_00{10+n}.hcallback=[];
                                        CONN_h.menus.m_results_00{10+n}.hcallback2=[];
                                        conn_menu('update',CONN_h.menus.m_results_00{10+n},[]);
                                    end
                                end
                                set(CONN_h.menus.m_results_00{6},'value',CONN_h.menus.m_results.bookmark_page);
                                if maxpages>1, set(CONN_h.menus.m_results_00{6},'visible','on'); else set(CONN_h.menus.m_results_00{6},'visible','off'); end
                                set([CONN_h.menus.m_results_00{4} CONN_h.menus.m_results_00{5}],'visible','off');
                                if CONN_h.menus.m_results.bookmark_page>1, set(CONN_h.menus.m_results_00{4},'visible','on'); end
                                if CONN_h.menus.m_results.bookmark_page<maxpages, set(CONN_h.menus.m_results_00{5},'visible','on'); end
                            else
                                set(CONN_h.menus.m_results_00{7},'string',regexprep(cellfun(@(a,b)sprintf('%s : %s',a,sprintf('%s ',b{:})),CONN_h.menus.m_results.bookmark_files_folder,CONN_h.menus.m_results.bookmark_files_descr,'uni',0),'\n',' '));
                            end
                        case 7,
                            if numel(varargin)>=3, filename=varargin{3};
                            else
                                value=get(CONN_h.menus.m_results_00{7},'value'); 
                                filename=CONN_h.menus.m_results.bookmark_files{value};
                            end
                            [nill,name]=fileparts(filename);
                            %answ=conn_questdlg({name},'Bookmark','Open','Edit label','Delete','Cancel','Open');
                            answ=conn_questdlg({'Bookmark options:',name},'Bookmark','Open','Edit label','Delete','Cancel','Open');
                            if isempty(answ), return; end
                            switch(answ)
                                case 'Open', conn_bookmark('open',filename);
                                case 'Edit label', if conn_bookmark('edit',filename), conn gui_results; end
                                case 'Delete', 
                                    answ=conn_questdlg({sprintf('Are you sure you want to delete plot %s?',name)},'','Delete','Cancel','Delete');
                                    if isequal(answ,'Delete')
                                        try, spm_unlink(filename); end
                                        conn gui_results;
                                    end
                            end
                        case 8,
                            value=get(CONN_h.menus.m_results_00{8},'value')-1;
                            if ~value||value>numel(CONN_h.menus.m_results.bookmark_allfolders), CONN_h.menus.m_results.bookmark_folder=[];  
                            else CONN_h.menus.m_results.bookmark_folder=CONN_h.menus.m_results.bookmark_allfolders{value};
                            end
                            conn gui_results;
                        case 9,
                            value=get(CONN_h.menus.m_results_00{9},'value');
                            CONN_h.menus.m_results.bookmark_style=value;  
                            conn gui_results;
                    end
                end
                return;
            end
            if state==4||strcmp(lower(varargin{1}),'gui_results_ica')||strcmp(lower(varargin{1}),'gui_results_ica_spatial')||strcmp(lower(varargin{1}),'gui_results_ica_summary')
%                 if ~any(strcmp(conn_v2v('fieldtext',CONN_h.menus.m_results.outcomenames,1),'3')), uiwait(errordlg('No ICA factors computed. Re-run ICA analyses in ''first-level analyses->ICA'' to continue','')); return; end
                state=4;
                tstate=find(conn_menumanager(CONN_h.menus.m_results_03b,'state'));
                if strcmp(lower(varargin{1}),'gui_results_ica_spatial')
                    tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03b,'state')));tstate(1)=1;
                    conn_menumanager(CONN_h.menus.m_results_03b,'state',tstate);
                    tstate=1;
                elseif strcmp(lower(varargin{1}),'gui_results_ica_temporal')
                    tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03b,'state')));tstate(2)=1;
                    conn_menumanager(CONN_h.menus.m_results_03b,'state',tstate);
                    tstate=2;
                elseif strcmp(lower(varargin{1}),'gui_results_ica_summary')
                    tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03b,'state')));tstate(3)=1;
                    conn_menumanager(CONN_h.menus.m_results_03b,'state',tstate);
                    tstate=3;
                end
                stateb=tstate;
                %if ~isfield(CONN_x.dynAnalyses(CONN_x.dynAnalysis),'sources')||isempty(CONN_x.dynAnalyses(CONN_x.dynAnalysis).sources), uiwait(errordlg('No Dynamic FC analyses computed. Select Dynamic FC in ''Setup->Options'' and run ''first-level Analyses->Dyn FC'' step','')); return; end
                if stateb==1, state=3; end
                tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03,'state')));tstate(4)=1;
                conn_menumanager(CONN_h.menus.m_results_03,'state',tstate); 
            elseif state==5||strcmp(lower(varargin{1}),'gui_results_dyn')||strcmp(lower(varargin{1}),'gui_results_dyn_spatial')||strcmp(lower(varargin{1}),'gui_results_dyn_temporal')||strcmp(lower(varargin{1}),'gui_results_dyn_summary')
                state=5;
                tstate=find(conn_menumanager(CONN_h.menus.m_results_03a,'state'));
                if strcmp(lower(varargin{1}),'gui_results_dyn_spatial')
                    tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03a,'state')));tstate(1)=1;
                    conn_menumanager(CONN_h.menus.m_results_03a,'state',tstate);
                    tstate=1;
                elseif strcmp(lower(varargin{1}),'gui_results_dyn_temporal')
                    tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03a,'state')));tstate(2)=1;
                    conn_menumanager(CONN_h.menus.m_results_03a,'state',tstate);
                    tstate=2;
                elseif strcmp(lower(varargin{1}),'gui_results_dyn_summary')
                    tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03a,'state')));tstate(3)=1;
                    conn_menumanager(CONN_h.menus.m_results_03a,'state',tstate);
                    tstate=3;
                end
                stateb=tstate;
                %if ~isfield(CONN_x.dynAnalyses(CONN_x.dynAnalysis),'sources')||isempty(CONN_x.dynAnalyses(CONN_x.dynAnalysis).sources), conn_msgbox('No dyn-ICA analyses computed. Select Dynamic FC in ''Setup->Options'' and run ''first-level Analyses->dyn-ICA'' step','',2); return; end
                if tstate==1, 
                    txt={CONN_x.Analyses(:).name};
                    dynanalyses=cellfun(@(x)~isempty(regexp(x,'^(.*\/|.*\\)?Dynamic factor .*\d+$')),txt);
                    if ~any(dynanalyses),  conn_msgbox({'Not ready to display second-level Analyses',' ','No Dynamic factor loadings computed. Re-run Dynamic analyses in ''first-level Analyses->Dyn FC'' to continue'},'',2); return; end
                    state=1; 
                    if ianalysis>numel(dynanalyses)||~dynanalyses(ianalysis), ianalysis=find(dynanalyses,1); CONN_x.Analysis=ianalysis; end
                elseif tstate==2
                    txt=CONN_x.Setup.l2covariates.names(1:end-1);
                    dyneffects=find(cellfun(@(x)~isempty(regexp(x,'^Dynamic |^_\S* Dynamic')),txt)); 
                    if ~any(dyneffects),  conn_msgbox({'Not ready to display second-level Analyses',' ','No Dynamic temporal components computed. Re-run Dynamic analyses in ''first-level Analyses->Dyn FC'' to continue'},'',2); end
                end
                tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03,'state')));tstate(5)=1;
                conn_menumanager(CONN_h.menus.m_results_03,'state',tstate); 
%             elseif any(state==[1 2])
%                     txt={CONN_x.Analyses(:).name};
%                     dynanalyses=cellfun(@(x)~isempty(regexp(x,'^Dynamic factor .*\d+$')),txt);
%                      if ianalysis>numel(dynanalyses)||dynanalyses(ianalysis), ianalysis=find(~dynanalyses,1); CONN_x.Analysis=ianalysis; end
% %             else
% %                 if ~any(~strcmp(conn_v2v('fieldtext',CONN_h.menus.m_results.outcomenames,1),'3')), uiwait(errordlg('No voxel-to-voxel measures computed. Re-run Voxel-to-Voxel analyses in ''first-level analyses->Voxel-to-Voxel'' to continue','')); return; end
            end
%             if isempty(CONN_x.Analyses(ianalysis).type), okstate=[true,true,true,true,true]; 
%             else okstate=[any(CONN_x.Analyses(ianalysis).type==[1,3]),any(CONN_x.Analyses(ianalysis).type==[2,3]),true,true,true]; end
%             okstate=CONN_x.Setup.steps([1 2 3 3 4])&okstate;
%             if ~okstate(state)
%                 %dynanalyses=~isempty(regexp(CONN_x.Setup.l2covariates.names(ianalysis),'^Dynamic factor .*\d+$'));
%                 %state=find(okstate&[~dynanalyses ~dynanalyses dynanalyses dynanalyses],1,'first');
%                 state=find(okstate,1,'first');
%                 if isempty(state), uiwait(errordlg('No matching analysis computed. Select analysis options in ''Setup->Options'' to perform additional analyses','')); conn gui_setup; return; end
%                 tstate=zeros(size(conn_menumanager(CONN_h.menus.m_results_03,'state')));tstate(state)=1;
%                 conn_menumanager(CONN_h.menus.m_results_03,'state',tstate); 
%             end
            if nargin<2,
                %if ~any(CONN_x.Setup.steps([1,2])), uiwait(errordlg('No seed-to-voxel or ROI-to-ROI analyses computed. Select these options in ''Setup->Options'' to perform additional analyses','')); conn gui_setup; return; end
                conn_menumanager clf;
                conn_menuframe;
				tstate=conn_menumanager(CONN_h.menus.m0,'state'); tstate(:)=0;tstate(4)=1; conn_menumanager(CONN_h.menus.m0,'state',tstate); 
                conn_menu('frame2border',[.0,.955,1,.045],'');
                %conn_menu('frame2border',[.0,.0,.115,.94]);
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m_results_03,CONN_h.menus.m0],'on',1);
                conn_menu('nullstr',{'Preview not','available'});
				%conn_menumanager([CONN_h.menus.m0],'on',1);
                ok=true;
                if CONN_x.Setup.nsubjects==1&&state~=5, 
                    conn_msgbox({'Single-subject second-level analyses not supported (only population-level inferences via random-effect analyses available)','Please add more subjects before proceeding to the Results tab'},'',2); 
                    ok=false;
                end
                dp3=.05;
                switch(state)
                    case 1, if ok, conn_menumanager([CONN_h.menus.m_results_04],'on',1); end
                        if stateb, conn_menumanager(CONN_h.menus.m_results_03a,'on',1); end
                        dp1=0*.075;dp2=.27;dp3=.05;
                    case 2, if ok, conn_menumanager([CONN_h.menus.m_results_05],'on',1); end
                        dp1=0*.075;dp2=0;dp3=.05;
                    case 3, if ok, conn_menumanager([CONN_h.menus.m_results_06],'on',1); end
                        if stateb, conn_menumanager(CONN_h.menus.m_results_03b,'on',1); end
                        dp1=0*.075;dp2=0;
                    case 4, conn_menumanager(CONN_h.menus.m_results_03b,'on',1);
                    case 5, conn_menumanager(CONN_h.menus.m_results_03a,'on',1);
                end
                if state==1,
                    conn_menu('frame',boffset+[.095,.375,.45,.515],'');%'Second-level design');
                    conn_menu('frame2',boffset+[.565,.06,.375,.87],'');
                elseif state==2||state==3
                    conn_menu('frame',boffset+[.095,.375,.45,.515],'');%'Second-level design');
                    conn_menu('frame2',boffset+[.565,.06,.375,.87],'');
                end
                if state==1||state==2
                    txt={CONN_x.Analyses(:).name};
                    txt_ext={' (R2R)',' (S2V)',' (S2V & R2R)'};
                    if stateb, CONN_h.menus.m_results.shownanalyses=find(cellfun(@(x)~isempty(regexp(x,'^(.*\/|.*\\)?Dynamic factor .*\d+$'))&~isempty(strmatch(CONN_x.dynAnalyses(CONN_x.dynAnalysis).name,x)),txt)); 
                    else       CONN_h.menus.m_results.shownanalyses=find(cellfun(@(x)isempty(regexp(x,'^(.*\/|.*\\)?Dynamic factor .*\d+$')),txt)); 
                    end
                    if state==1,    CONN_h.menus.m_results.shownanalyses=CONN_h.menus.m_results.shownanalyses(ismember([CONN_x.Analyses(CONN_h.menus.m_results.shownanalyses).type],[1,3])); 
                    elseif state==2,CONN_h.menus.m_results.shownanalyses=CONN_h.menus.m_results.shownanalyses(ismember([CONN_x.Analyses(CONN_h.menus.m_results.shownanalyses).type],[2,3])); 
                    end
                    %try, txt=cellfun(@(a,b)[a b],txt,txt_ext([CONN_x.Analyses(:).type]),'uni',0); end
                    [ok1,tempanalyses]=ismember(ianalysis,CONN_h.menus.m_results.shownanalyses);
                    if ~ok1&&~isempty(CONN_h.menus.m_results.shownanalyses), ianalysis=CONN_h.menus.m_results.shownanalyses(1); CONN_x.Analysis=ianalysis; tempanalyses=1;
                    elseif ~ok1, CONN_x.Analysis=1; conn_msgbox({'Not ready to display second-level Analyses',' ','No matching analysis computed','Please complete the first-level ROI-to-ROI or seed-to-voxel step first','(fill any required information and press "Done" in the first-level analysis tab)'},'',2); return; 
                    end
                    CONN_h.menus.m_results_00{20}=conn_menu('popupbigblue',boffset+[.095,.84,.45,.05],'',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                    %CONN_h.menus.m_results_00{20}=conn_menu('popup',boffset+[.395,.80,.145,.04],'First-level analysis',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                    set(CONN_h.menus.m_results_00{20},'value',tempanalyses);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                elseif state==3||state==4
                    if state==4&&stateb==2
                        txt=CONN_x.Setup.l2covariates.names(1:end-1);
                        icaeffects=find(cellfun(@(x)~isempty(regexp(x,'^_\S+ (ICA|PCA)\d+ ')),txt));
                        if ~isempty(icaeffects)&&isfield(CONN_x.vvAnalyses,'name')&&~isempty(CONN_x.vvAnalyses(CONN_x.vvAnalysis).name)
                            icaeffects=icaeffects(strncmp([CONN_x.vvAnalyses(CONN_x.vvAnalysis).name ' '],regexprep(txt(icaeffects),'^_\S+ (ICA|PCA)\d+ ',''),numel(CONN_x.vvAnalyses(CONN_x.vvAnalysis).name)+1));
                            %if ~any(icaeffects),conn_msgbox(sprintf('No ICA temporal components computed in analysis %s',CONN_x.vvAnalyses(CONN_x.vvAnalysis).name),'',2); end
                        elseif ~any(icaeffects),conn_msgbox({'Not ready to display second-level Analyses',' ','No matching analysis computed','Please complete the first-level voxel-to-voxel step first','(fill any required information and press "Done" in the voxel-to-voxel analysis tab)'},'',2); return;
                        end
                    end
                    if isfield(CONN_x.vvAnalyses,'name')&&~isempty(CONN_x.vvAnalyses(CONN_x.vvAnalysis).name)
                        txt={CONN_x.vvAnalyses(:).name};
                        CONN_h.menus.m_results.shownanalyses=1:numel(txt);
                        if stateb, CONN_h.menus.m_results.shownanalyses=CONN_h.menus.m_results.shownanalyses(arrayfun(@(x)any(ismember(conn_v2v('fieldtext',CONN_x.vvAnalyses(x).measures,1),{'3','4'})),CONN_h.menus.m_results.shownanalyses));
                        end
                        [ok1,tempanalyses]=ismember(CONN_x.vvAnalysis,CONN_h.menus.m_results.shownanalyses);
                        if ~ok1&&~isempty(CONN_h.menus.m_results.shownanalyses), CONN_x.vvAnalysis=CONN_h.menus.m_results.shownanalyses(1); tempanalyses=1;
                        elseif ~ok1, CONN_x.vvAnalysis=1; conn_msgbox({'Not ready to display second-level Analyses',' ','No matching analysis computed','Please complete the first-level voxel-to-voxel step first','(fill any required information and press "Done" in the voxel-to-voxel analysis tab)'},'',2); return;
                        end
                        if stateb==3, CONN_h.menus.m_results_00{20}=conn_menu('popup2big',boffset+[.10,.88,.325,.04],'',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                        set(CONN_h.menus.m_results_00{20},'value',tempanalyses);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                        elseif stateb==1||stateb==0, CONN_h.menus.m_results_00{20}=conn_menu('popupbigblue',boffset+[.095,.84,.45,.05],'',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                        set(CONN_h.menus.m_results_00{20},'value',tempanalyses);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                        %else CONN_h.menus.m_results_00{20}=conn_menu('popup',boffset+[.395,.80,.145,.04],'First-level analysis',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                        end
                    end
                elseif state==5
                    if stateb==2
                        txt=CONN_x.Setup.l2covariates.names(1:end-1);
                        dyneffects=find(cellfun(@(x)~isempty(regexp(x,'^Dynamic |^_\S* Dynamic')),CONN_x.Setup.l2covariates.names));
                        if ~isempty(dyneffects)&&isfield(CONN_x.dynAnalyses,'name')&&~isempty(CONN_x.dynAnalyses(CONN_x.dynAnalysis).name)
                            dyneffects=dyneffects(cellfun(@(x)~isempty(regexp(x,[CONN_x.dynAnalyses(CONN_x.dynAnalysis).name ' @ .*$'])),txt(dyneffects)));
                        end
                        if ~any(dyneffects),conn_msgbox({'Not ready to display second-level Analyses',' ','No Dynamic temporal components computed. Re-run Dynamic FC analyses in ''first-level Analyses->Dynamic ICA'' to continue'},'',2); end
                    end
                    if isfield(CONN_x.dynAnalyses,'name')&&~isempty(CONN_x.dynAnalyses(CONN_x.dynAnalysis).name)
                        txt={CONN_x.dynAnalyses(:).name};
                        CONN_h.menus.m_results.shownanalyses=1:numel(txt);
                        [ok1,tempanalyses]=ismember(CONN_x.dynAnalysis,CONN_h.menus.m_results.shownanalyses);
                        if ~ok1&&~isempty(CONN_h.menus.m_results.shownanalyses), CONN_x.dynAnalysis=CONN_h.menus.m_results.shownanalyses(1); tempanalyses=1;
                        elseif ~ok1, CONN_x.dynAnalysis=1; conn_msgbox({'Not ready to display second-level Analyses',' ','No matching analysis computed','Please complete the first-level step first','(fill any required information and press "Done" in the dyn-ICA analysis tab)'},'',2); return;
                        end
                        if stateb==3, CONN_h.menus.m_results_00{20}=conn_menu('popup2big',boffset+[.10,.90,.425,.04],'',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                        set(CONN_h.menus.m_results_00{20},'value',tempanalyses);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                        elseif stateb==1, CONN_h.menus.m_results_00{20}=conn_menu('popup',boffset+[.395,.83,.145,.04],'',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                        set(CONN_h.menus.m_results_00{20},'value',tempanalyses);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                        %else CONN_h.menus.m_results_00{20}=conn_menu('popup',boffset+[.395,.80,.145,.04],'First-level analysis',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                        end
                    end
                end
				if (state==1||state==2) && (~isfield(CONN_x.Analyses(ianalysis),'sources')||isempty(CONN_x.Analyses(ianalysis).sources)), conn_msgbox({'Not ready to display second-level Analyses',' ','Please complete the first-level ROI-to-ROI or seed-to-voxel step first','(fill any required information and press "Done" in the first-level analysis tab)'},'',2); return; end %conn gui_analyses; return; end
				if (state==3||state==4) && (~isfield(CONN_x.vvAnalyses(CONN_x.vvAnalysis),'measures')||isempty(CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures)), conn_msgbox({'Not ready to display second-level Analyses',' ','Please complete the first-level voxel-to-voxel step first','(fill any required information and press "Done" in the first-level analysis tab)'},'',2); return; end %conn gui_analyses; return; end
				if (state==5) && (~isfield(CONN_x.dynAnalyses(CONN_x.dynAnalysis),'sources')||isempty(CONN_x.dynAnalyses(CONN_x.dynAnalysis).sources)), conn_msgbox({'Not ready to display second-level Analyses',' ','Please complete the first-level dyn-ICA step first','(fill any required information and press "Done" in the first-level analysis tab)'},'',2); return; end %conn gui_analyses; return; end
                if ~isfield(CONN_x,'Results')||~isfield(CONN_x.Results,'xX'), CONN_x.Results.xX=[]; end

                if state==4
                    if stateb==3
                        conn_icaexplore;
                        return;
                    elseif stateb==2
                        icovariates=find(cellfun(@(x)~isempty(regexp(x,'^_\S+ (ICA|PCA)\d+ ')),CONN_x.Setup.l2covariates.names));
                        if ~isempty(icovariates)&&isfield(CONN_x.vvAnalyses,'name')&&~isempty(CONN_x.vvAnalyses(CONN_x.vvAnalysis).name)
                            temp=icovariates(strncmp([CONN_x.vvAnalyses(CONN_x.vvAnalysis).name ' '],regexprep(CONN_x.Setup.l2covariates.names(icovariates),'^_\S+ (ICA|PCA)\d+ ',''),numel(CONN_x.vvAnalyses(CONN_x.vvAnalysis).name)+1));
                            if ~isempty(temp), icovariates=temp; end
                        end
                        %icovariates=find(cellfun(@(x)~isempty(regexp(x,'^_\S* ICA')),CONN_x.Setup.l2covariates.names));
                        conn_calculator(icovariates);
                        CONN_h.menus.m_results_00{20}=conn_menu('popupbigblue',boffset+[.095,.84,.55,.05],'',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                        set(CONN_h.menus.m_results_00{20},'value',tempanalyses);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                        return
                    end
                elseif state==5
                    if stateb==3
                        conn_dynexplore;
                        return;
                    elseif stateb==2
                        icovariates=find(cellfun(@(x)~isempty(regexp(x,'^Dynamic |^_\S* Dynamic'))&~isempty(regexp(x,[CONN_x.dynAnalyses(CONN_x.dynAnalysis).name ' @ .*$'])),CONN_x.Setup.l2covariates.names));
                        conn_calculator(icovariates);
                        CONN_h.menus.m_results_00{20}=conn_menu('popupbigblue',boffset+[.10,.84,.525,.05],'',txt(CONN_h.menus.m_results.shownanalyses),'select first-level analysis name','conn(''gui_results'',20);');
                        set(CONN_h.menus.m_results_00{20},'value',tempanalyses);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                        return
                    end
                else 
                    tnames=conn_contrastmanager('namesextended');
                    if numel(CONN_x.Setup.l2covariates.names)>2||numel(CONN_x.Setup.conditions.names)>2
                        CONN_h.menus.m_results_00{21}=conn_menu('popup',boffset+[.105,.38-dp1,.265,.04],'',[{'<HTML>- <i>contrast tools</i></HTML>'},tnames,{'<HTML><i>save new contrast</i></HTML>'}],'<HTML>User-defined list of saved contrasts of interest<br/> - select a previously-defined contrast to automatically fill-in the <b>between-subjects</b> and <b>between-conditions</b> effects and contrast fields above <br/> - select <i>contrast tools</i> to add new contrasts, or edit/remove existing contrasts</HTML>','conn(''gui_results'',21);');
                        set(CONN_h.menus.m_results_00{21},'value',1);%,'fontsize',9+CONN_gui.font_offset);%,'fontweight','bold');
                    else
                        CONN_h.menus.m_results_00{21}=[];
                    end
                    CONN_h.menus.m_results_00{11}=conn_menu('listbox',boffset+[.105,.58-dp1,.145,.23+dp1-dp3],'Subject effects','','<HTML>select subject effect(s) characterizing second-level analysis model<br/> - Selected subject effects form the design matrix of your second-level analysis General Linear Model (GLM)<br/> - note: new subject effects (second-level covariates) may be added at any time in the <i>Setup Covariates 2nd-level</i> tab</HTML>','conn(''gui_results'',11);');
                    CONN_h.menus.m_results_00{16}=conn_menu('edit',boffset+[.105,.49-dp1,.145,.04],'Between-subjects contrast',num2str(1),['<HTML>Define desired contrast across selected subject-effects<br/> - enter contrast vector/matrix with as many elements/columns as subject-effects selected <br/> - use the list below to see a list of standard contrasts for the selected subject-effects <br/> - enter multiple rows separated by <b>;</b> (semicolon) for OR conjunction (multivariate test) of several contrasts</HTML>'],'conn(''gui_results'',16);');
                    CONN_h.menus.m_results_00{12}=conn_menu('listbox',boffset+[.250,.58-dp1,.145,.23+dp1-dp3],'Conditions','','select condition(s) of interest','conn(''gui_results'',12);');
                    CONN_h.menus.m_results_00{19}=conn_menu('edit',boffset+[.250,.49-dp1,.145,.04],'Between-conditions contrast',num2str(1),['<HTML>Define desired contrast across selected conditions <br/> - enter contrast vector/matrix (as many elements/columns as conditions selected) <br/> - use the list below to see a list of standard contrasts for the selected conditions<br/> - enter multiple rows separated by <b>;</b> (semicolon) for OR conjunction (multivariate test) of several contrasts</HTML>'],'conn(''gui_results'',19);');
                    %connmeasures={'correlation (bivariate)','correlation (semipartial)','regression (bivariate)','regression (multivariate)'};
                    if state==3, 
                        if stateb, CONN_h.menus.m_results_00{13}=conn_menu('listbox',boffset+[.395,.58-dp1,.145,.23+dp1-dp3],'ICA networks','','select ICA network(s) of interest','conn(''gui_results'',13);');
                        else       CONN_h.menus.m_results_00{13}=conn_menu('listbox',boffset+[.395,.58-dp1,.145,.23+dp1-dp3],'Voxel-to-Voxel Measures','','select voxel-to-voxel measure(s) of interest','conn(''gui_results'',13);');
                        end
                        CONN_h.menus.m_results_00{17}=conn_menu('edit',boffset+[.395,.49-dp1,.145,.04],'Between-measures contrast',num2str(1),['<HTML>Define desired contrast across selected measures <br/> - enter contrast vector/matrix (as many elements/columns as measures selected) <br/> - use the list below to see a list of standard contrasts for the selected measures<br/> - enter multiple rows separated by <b>;</b> (semicolon) for OR conjunction (multivariate test) of several contrasts</HTML>'],'conn(''gui_results'',17);');
                    else
                        CONN_h.menus.m_results_00{13}=conn_menu('listbox',boffset+[.395,.58-dp1,.145,.23+dp1-dp3],'Seeds/Sources','','select seed/source ROI(s) of interest','conn(''gui_results'',13);');
                        CONN_h.menus.m_results_00{17}=conn_menu('edit',boffset+[.395,.49-dp1,.145,.04],'Between-sources contrast',num2str(1),['<HTML>Define desired contrast across selected sources <br/> - enter contrast vector/matrix (as many elements/columns as sources selected) <br/> - use the list below to see a list of standard contrasts for the selected sources<br/> - enter multiple rows separated by <b>;</b> (semicolon) for OR conjunction (multivariate test) of several contrasts</HTML>'],'conn(''gui_results'',17);');
                    end
                    CONN_h.menus.m_results_00{23}=conn_menu('pushbutton',boffset+[.44,.385-dp1,.1,.04],'','','<HTML>Number of subjects included in second-level model <br/> - click to display design matrix information</HTML>',@conn_displaydesign);
                    set(CONN_h.menus.m_results_00{23},'horizontalalignment','right');
                    set([CONN_h.menus.m_results_00{21}],'visible','off');%,'fontweight','bold');
                    conn_menumanager('onregion',[CONN_h.menus.m_results_00{21}],1,boffset+[.09,.286,.46,.595]);
                    if state==2||state==3,
                        pos=[.62,.37,.295,.47];
                        if ~isfield(CONN_x.Results.xX,'displayvoxels'), CONN_x.Results.xX.displayvoxels=1; end
                        CONN_h.menus.m_results_00{24}=uicontrol('style','text','units','norm','position',boffset+[pos(1)+pos(3)/2-.195,pos(2)-1*.055,.195,.04],'string','(individual contrasts) p-uncorrected <','fontname','default','fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolor,'foregroundcolor',CONN_gui.fontcolorA,'horizontalalignment','right');
                        CONN_h.menus.m_results_00{15}=conn_menu('slider',boffset+[pos(1)+pos(3)-0*.01,pos(2),.015,pos(4)],'','','z-slice','conn(''gui_results'',15);');
                        try, addlistener(CONN_h.menus.m_results_00{15}, 'ContinuousValueChange',@(varargin)conn('gui_results',15)); end
                        set(CONN_h.menus.m_results_00{15},'visible','off');
                        conn_menumanager('onregion',CONN_h.menus.m_results_00{15},1,boffset+pos+[0 0 .015 0]);
                        %CONN_h.menus.m_results_00{15}=uicontrol('style','slider','units','norm','position',boffset+[pos(1)+pos(3)-0*.01,pos(2),.015,pos(4)],'callback','conn(''gui_results'',15);','backgroundcolor',CONN_gui.backgroundcolorA);
                        strstr3={'Results preview (individual contrasts)','Results preview (full model)','Do not show analysis results preview'};%,'Results whole-brain (full model)'};
                        CONN_h.menus.m_results_00{32}=conn_menu('popup2',boffset+[pos(1)+.07,.87,.23,.045],'',strstr3,'Display options','conn(''gui_results'',32);');
                        set(CONN_h.menus.m_results_00{32},'value',CONN_x.Results.xX.displayvoxels);
                        CONN_h.menus.m_results_00{33}=[];%conn_menu('pushbuttonblue2',boffset+[.57,.08,.07,.045],'','display 3D','displays 3d view of current analysis results (full model)','conn(''gui_results'',33);');
                        CONN_h.menus.m_results_00{44}=conn_menu('pushbutton2',boffset+[pos(1)-.03,pos(2)-.31,.07,.045],'','plot subjects','displays selected slice of connectivity measures for each subject and for each between-conditions and between-sources contrast','conn(''gui_results'',44);');
                        CONN_h.menus.m_results_00{35}=conn_menu('pushbutton2',boffset+[pos(1)+.04,pos(2)-.31,.07,.045],'','plot effects','<HTML>displays between-subject contrast effect sizes<br/> - select seed(s) in <i>Seeds/Sources</i> list and select target voxel in results display - also exports values for each subject to Matlab workspace</HTML>','conn(''gui_results'',35);');
                        CONN_h.menus.m_results_00{36}=conn_menu('pushbutton2',boffset+[pos(1)+.11,pos(2)-.31,.07,.045],'','plot values','<HTML>displays connectivity values between selected seed/source and target voxel for each subject<br/> - select seed(s) in <i>Seeds/Sources</i> list and select target voxel in results display - also exports values for each subject to Matlab workspace</HTML>','conn(''gui_results'',36);');
                        CONN_h.menus.m_results_00{34}=conn_menu('pushbutton2',boffset+[pos(1)+.18,pos(2)-.31,.07,.045],'','import values','<HTML>import connectivity values between selected seed/source and target voxel for each subject as 2nd-level covariates<br/> - select seed(s) in <i>Seeds/Sources</i> list and select target voxel in results display</HTML>','conn(''gui_results'',34);');
                        CONN_h.menus.m_results_00{43}=conn_menu('pushbuttonblue2',boffset+[pos(1)+.25,pos(2)-.31,.07,.045],'','bookmark','<HTML>Bookmarks this second-level analysis results<br/> - bookmarked results can be quickly accessed from all <i>Second-level Results</i> tabs</HTML>','conn(''gui_results'',43);');
                        set([CONN_h.menus.m_results_00{33},CONN_h.menus.m_results_00{34},CONN_h.menus.m_results_00{35},CONN_h.menus.m_results_00{36},CONN_h.menus.m_results_00{44},CONN_h.menus.m_results_00{43}],'visible','off');%,'fontweight','bold');
                        %conn_callbackdisplay_secondlevelclick([]); % init clicks
                        [CONN_h.menus.m_results_00{14}]=conn_menu('imagep2',boffset+pos,'','','',@conn_callbackdisplay_dataname,@conn_callbackdisplay_secondlevelclick);
                        conn_menu('nullstr',' ');
                        CONN_h.menus.m_results_00{29}=conn_menu('image2',boffset+pos+[.08 -.17 -pos(3)+.125 -pos(4)+.05],'connectivity values'); %,'','',@conn_callbackdisplay_dataname,@conn_callbackdisplay_secondlevelclick);
                        %[CONN_h.menus.m_results_00{34}]=conn_menu('image',boffset+[.1 .1 .4 .1],'','','',@conn_callbackdisplay_dataname);
                        %if state==2, [CONN_h.menus.m_results_00{14}]=conn_menu('image2',boffset+pos,'');%['Analysis results (voxel-level)']);%,connmeasures{CONN_x.Results.measure}]);
                        %else         [CONN_h.menus.m_results_00{14}]=conn_menu('image2',boffset+pos,'');%['Connectivity measure (voxel-level)']);
                        %end
                        %CONN_h.menus.m_results_00{32}=uicontrol('style','popupmenu','units','norm','position',boffset+[.70,.77,.195,.045],'string',strstr3,'fontsize',8+CONN_gui.font_offset,'value',CONN_x.Results.xX.displayvoxels,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','Display options','callback','conn(''gui_results'',32);');
                    end
                    
                    CONN_x.Results.xX.Analysis=CONN_x.Analysis;
                    CONN_x.Results.xX.vvAnalysis=CONN_x.vvAnalysis;
                    CONN_x.Results.xX.dynAnalysis=CONN_x.dynAnalysis;
                    if state==1 % ROI-to-ROI
                        pos=[.58,.32,.34,.55];
                        CONN_h.menus.m_results_00{37}=conn_menu('slider',boffset+[pos(1)+pos(3)-0*.01,pos(2),.015,pos(4)],'','','<HTML>number of slices<br/> - ROIs are represented by a sphere and projected <br/>to the slice closest to the ROI centroid','conn(''gui_results'',37);');
                        try, addlistener(CONN_h.menus.m_results_00{37}, 'ContinuousValueChange',@(varargin)conn('gui_results',37)); end
                        set(CONN_h.menus.m_results_00{37},'visible','off');
                        if ~isfield(CONN_h.menus.m_results,'roinslices'), CONN_h.menus.m_results.roinslices=4; end
                        set(CONN_h.menus.m_results_00{37},'min',1,'max',36,'sliderstep',[1,4]/35,'value',CONN_h.menus.m_results.roinslices);
                        conn_menumanager('onregion',CONN_h.menus.m_results_00{37},1,boffset+pos+[0 0 .015 0]);
                        conn_menu('frame2',boffset+[.095,.12,.45,.17],'Analysis results');
                        [CONN_h.menus.m_results_00{18},CONN_h.menus.m_results_00{22}]=conn_menu('listbox0',boffset+[.105,.10,.435,.15],sprintf('%-50s%10s%10s%12s%12s','Targets','beta','T','p-unc','p-FDR'),'   ','browse target ROIs -or right click for more options-','conn(''gui_results'',18);');
                        set(CONN_h.menus.m_results_00{18},'max',2,'fontname','monospaced','fontsize',8+CONN_gui.font_offset);
                        set(CONN_h.menus.m_results_00{22},'fontsize',8+CONN_gui.font_offset);
                        hc1=uicontextmenu;
                        %uimenu(hc1,'Label','Select target-ROIs set','callback','conn(''gui_results'',27)');
                        uimenu(hc1,'Label','Export stats','callback',@conn_exporttable);
                        set(CONN_h.menus.m_results_00{18},'uicontextmenu',hc1);
                        %uicontrol('style','text','units','norm','position',boffset+[.105,.345,.435,.04],'string','Analysis results','backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',CONN_gui.fontcolorA,'fontangle','normal','fontweight','normal','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
                        
                        if ~isfield(CONN_x.Results.xX,'inferencetype'), CONN_x.Results.xX.inferencetype=1; end
                        if ~isfield(CONN_x.Results.xX,'inferencelevel'), CONN_x.Results.xX.inferencelevel=.05; end
                        if ~isfield(CONN_x.Results.xX,'inferenceleveltype'), CONN_x.Results.xX.inferenceleveltype=1; end
                        if ~isfield(CONN_x.Results.xX,'displayrois'), CONN_x.Results.xX.displayrois=1; end
                        strstr1={'Two-sided','One-sided (positive)','One-sided (negative)'};
                        strstr2={'p-FDR corrected < ','p-uncorrected < '};
                        strstr3={'Analysis results: Targets are all ROIs','Analysis results: Targets are source ROIs only','Analysis results: Targets are selected ROIs only'};
                        %CONN_h.menus.m_results_00{24}=uicontrol('style','text','units','norm','position',boffset+[.675,.08,.05,.045],'string','threshold','fontname','default','fontsize',8,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5));
                        CONN_h.menus.m_results_00{27}=conn_menu('popup2',boffset+[pos(1)+.07,pos(2)-.05,.12,.04],'',strstr2,'choose type of false-positive control','conn(''gui_results'',29);');
                        set(CONN_h.menus.m_results_00{27},'value',CONN_x.Results.xX.inferenceleveltype);
                        CONN_h.menus.m_results_00{30}=conn_menu('edit2',boffset+[pos(1)+.19,pos(2)-.045,.04,.04],'',num2str(CONN_x.Results.xX.inferencelevel),'enter false-positive threshold value','conn(''gui_results'',30);');
                        CONN_h.menus.m_results_00{28}=conn_menu('popup2',boffset+[pos(1)+.26,pos(2)-.05,.09,.04],'',strstr1,'choose inference directionality','conn(''gui_results'',28);');
                        set(CONN_h.menus.m_results_00{28},'value',CONN_x.Results.xX.inferencetype);
                        CONN_h.menus.m_results_00{31}=conn_menu('popup2',boffset+[.63,.87,.26,.04],'',strstr3,'choose target ROIs','conn(''gui_results'',31);');
                        set(CONN_h.menus.m_results_00{31},'value',CONN_x.Results.xX.displayrois);
                        %CONN_h.menus.m_results_00{28}=uicontrol('style','popupmenu','units','norm','position',boffset+[.81,.08,.08,.045],'string',strstr1,'fontsize',8+CONN_gui.font_offset,'value',CONN_x.Results.xX.inferencetype,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','choose inference directionality','callback','conn(''gui_results'',28);');
                        %CONN_h.menus.m_results_00{27}=uicontrol('style','popupmenu','units','norm','position',boffset+[.71,.08,.10,.045],'string',strstr2,'fontsize',8+CONN_gui.font_offset,'value',CONN_x.Results.xX.inferenceleveltype,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','choose type of false-positive control','callback','conn(''gui_results'',29);');
                        %CONN_h.menus.m_results_00{30}=uicontrol('style','edit','units','norm','position',boffset+[.66,.08,.05,.045],'string',num2str(CONN_x.Results.xX.inferencelevel),'fontsize',8+CONN_gui.font_offset,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','enter false-positive threshold value','callback','conn(''gui_results'',30);');
                        %CONN_h.menus.m_results_00{31}=uicontrol('style','popupmenu','units','norm','position',boffset+[.66,.77,.23,.045],'string',strstr3,'fontsize',8+CONN_gui.font_offset,'value',CONN_x.Results.xX.displayrois,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',[0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),'tooltipstring','choose target ROIs','callback','conn(''gui_results'',31);');
                        CONN_h.menus.m_results_00{25}=conn_menu('axes',boffset+pos);
                        %h0=CONN_gui.backgroundcolorA;
                        if 0
                            xs=mean(CONN_gui.refs.canonical.data,3)';xs=convn(xs,[1,2,1;2,-12,2;1,2,1],'same');xs=max(0,min(1,xs/max(xs(:))-.1))/4;
                            xs2=ind2rgb(round(1+(size(CONN_h.screen.colormap,1)/2-1)*xs),CONN_h.screen.colormap);
                            CONN_h.menus.m_results.xse=xs2(end:-1:1,end:-1:1,:);
                            %xs=conn_bsxfun(@times,1-xs,shiftdim(h0,-1))+conn_bsxfun(@times,xs,shiftdim((1-h0),-1));
                            %h0=CONN_gui.backgroundcolorA;xs=max(0,min(1,.5*abs(convn(mean(CONN_gui.refs.canonical.data>.5&CONN_gui.refs.canonical.data<.8,3)',[1;0;-1]*[1,0,-1],'same')))); xs=bsxfun(@plus,shiftdim(h0,-1),bsxfun(@times,xs,shiftdim((1-h0),-1)));
                        else
                            tfact=round(linspace(CONN_gui.refs.canonical.V.dim(3)-12,6,CONN_h.menus.m_results.roinslices+2)); 
                            tfact=tfact(2:end-1);
                            dtfact=min(abs(diff([1,tfact])));
                            if dtfact>=3, xs0=0; for n1=-dtfact:dtfact, xs0=xs0+(1-abs(n1)/(dtfact+1))*max(0,permute(CONN_gui.refs.canonical.data(end:-1:1,end:-1:1,max(1,min(size(CONN_gui.refs.canonical.data,3),tfact+n1))),[2,1,4,3])); end; xs0=xs0/(2*dtfact+1);
                            else xs0=permute(CONN_gui.refs.canonical.data(end:-1:1,end:-1:1,tfact),[2,1,4,3]);
                            end
                            CONN_h.menus.m_results.xseM=[-1 0 0 0;0 -1 0 0;0 0 1/mean(diff(tfact)) 0;CONN_gui.refs.canonical.V.dim(1)+1 CONN_gui.refs.canonical.V.dim(2)+1 1-tfact(1)/mean(diff(tfact)) 1]'; % note: from xyz position (voxels) in canonical volume to xyz position (matrix coordinates) in selected slices display
                            xs0=abs(xs0./max(abs(xs0(:)))).^2;
                            xs0=1+126*abs(xs0/max(abs(xs0(:))));
                            [CONN_h.menus.m_results.xse,CONN_h.menus.m_results.xsen1n2]=conn_menu_montage(CONN_h.menus.m_results_00{25},xs0);
                        end
                        hi=image(CONN_h.menus.m_results.xse,'parent',CONN_h.menus.m_results_00{25}); %set(gca,'xdir','normal','ydir','normal'); 
                        axis(CONN_h.menus.m_results_00{25},'equal','tight','off');
                        CONN_h.menus.m_results_00{38}=hi;
                        set(hi,'buttondownfcn','conn(''gui_results'',26);');
                        hold(CONN_h.menus.m_results_00{25},'on');
                        %try, [nill,hc]=contourf(xs,0:.01:.25); set(hc,'edgecolor','none'); set(gca,'clim',[0 2]); end
                        CONN_h.menus.m_results_00{26}=patch(nan,nan,'k','parent',CONN_h.menus.m_results_00{25});
                        hc1=uicontextmenu;
                        uimenu(hc1,'Label','3d view','callback','conn(''gui_results_roi3d'');');
                        uimenu(hc1,'Label','Change background anatomical image','callback','conn(''background_image'');conn gui_results;');
                        set(hi,'uicontextmenu',hc1);
                        hold(CONN_h.menus.m_results_00{25},'off');
                        conn_menu('nullstr',' ');
                        CONN_h.menus.m_results_00{29}=conn_menu('image2',boffset+pos+[.12 -.17 -pos(3)+.125 -pos(4)+.05],'connectivity values'); 
                        CONN_h.menus.m_results_00{33}=conn_menu('pushbuttonblue2',boffset+[pos(1),pos(2)-.26,.07,.045],'','display 3D','displays 3d view of current analysis results','conn(''gui_results_roi3d'');');
                        CONN_h.menus.m_results_00{35}=conn_menu('pushbutton2',boffset+[pos(1)+.07,pos(2)-.26,.07,.045],'','plot effects','<HTML>displays between-subject contrast effect sizes<br/> - select seed(s) in <i>Seeds/Sources</i> list and select target(s) in <i>Analysis results</i> list<br/> - also exports values for each subject to Matlab workspace</HTML>','conn(''gui_results'',35);');
                        CONN_h.menus.m_results_00{36}=conn_menu('pushbutton2',boffset+[pos(1)+.14,pos(2)-.26,.07,.045],'','plot values','<HTML>displays connectivity values between selected seed/source and target ROIs for each subject<br/> - select seed(s) in <i>Seeds/Sources</i> list and select target(s) in <i>Analysis results</i> list<br/> - also exports values for each subject to Matlab workspace</HTML>','conn(''gui_results'',36);');
                        CONN_h.menus.m_results_00{34}=conn_menu('pushbutton2',boffset+[pos(1)+.21,pos(2)-.26,.07,.045],'','import values','<HTML>import connectivity values between selected seed/source and target ROIs for each subject as 2nd-level covariates<br/> - select seed(s) in <i>Seeds/Sources</i> list and select target(s) in <i>Analysis results</i> list</HTML>','conn(''gui_results'',34);');
                        CONN_h.menus.m_results_00{43}=conn_menu('pushbuttonblue2',boffset+[pos(1)+.28,pos(2)-.26,.07,.045],'','bookmark','<HTML>Bookmarks this second-level analysis results<br/> - bookmarked results can be quickly accessed from all <i>Second-level Results</i> tabs</HTML>','conn(''gui_results'',43);');
                        set([CONN_h.menus.m_results_00{33},CONN_h.menus.m_results_00{34},CONN_h.menus.m_results_00{35},CONN_h.menus.m_results_00{36},CONN_h.menus.m_results_00{43}],'visible','off');%,'fontweight','bold');
                        conn_menumanager('onregion',[CONN_h.menus.m_results_00{33},CONN_h.menus.m_results_00{34},CONN_h.menus.m_results_00{35},CONN_h.menus.m_results_00{36},CONN_h.menus.m_results_00{43}],1,boffset+[.545,.05,.38,.84]);
                    end
                    
                    [path,name,ext]=fileparts(CONN_x.filename);
                    if state==1||state==2
                        filepathresults=fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(ianalysis).name);
                    else
                        filepathresults=fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses(CONN_x.vvAnalysis).name);
                    end
                    ncovariates=length(CONN_x.Setup.l2covariates.names)-1;
                    nconditions=length(CONN_x.Setup.conditions.names)-1;
                    icondition=[];isnewcondition=[];for ncondition=1:nconditions,[icondition(ncondition),isnewcondition(ncondition)]=conn_conditionnames(CONN_x.Setup.conditions.names{ncondition}); end                    
                    
                    if state==1||state==2
                        CONN_h.menus.m_results.outcomenames=CONN_x.Analyses(ianalysis).sources;
                        CONN_h.menus.m_results.shownsources=1:numel(CONN_h.menus.m_results.outcomenames);
                        if isempty(CONN_h.menus.m_results.shownsources), conn_msgbox({'Not ready to display second-level Analyses',' ','No sources found. Please re-run first-level analyses'},'',2); end
                        CONN_h.menus.m_results.outcomeisource=[];for n1=1:length(CONN_h.menus.m_results.outcomenames),
                            [CONN_h.menus.m_results.outcomeisource(n1),isnew]=conn_sourcenames(CONN_h.menus.m_results.outcomenames{n1},'-');
                            if isnew&&state==2, error('Source %s not found in global source list. Please re-run first-level analyses',CONN_h.menus.m_results.outcomenames{n1}); end
                        end
                    else
                        CONN_h.menus.m_results.outcomenames=CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures;%CONN_x.vvAnalyses(CONN_x.vvAnalysis).regressors.names;
                        CONN_h.menus.m_results.shownsources=1:numel(CONN_h.menus.m_results.outcomenames);
                        if stateb, CONN_h.menus.m_results.shownsources=find(ismember(conn_v2v('fieldtext',CONN_h.menus.m_results.outcomenames,1),{'3','4'}));
                        else       CONN_h.menus.m_results.shownsources=1:numel(CONN_h.menus.m_results.outcomenames);
                        %else       CONN_h.menus.m_results.shownsources=find(~ismember(conn_v2v('fieldtext',CONN_h.menus.m_results.outcomenames,1),{'3','4'}));
                        end
                        if isempty(CONN_h.menus.m_results.shownsources), conn_msgbox({'Not ready to display second-level Analyses',' ','No measures found. Please re-run first-level analyses'},'',2); end
                        CONN_h.menus.m_results.outcomeisource=[];for n1=1:length(CONN_h.menus.m_results.outcomenames),
                            [CONN_h.menus.m_results.outcomeisource(n1),isnew,CONN_h.menus.m_results.outcomencompsource(n1)]=conn_v2v('match_extended',CONN_h.menus.m_results.outcomenames{n1});
                            if isnew, error('Measure %s not found in global measures list. Please re-run first-level analyses',CONN_h.menus.m_results.outcomenames{n1}); end
                        end
                    end
                    
                    %                 filename=fullfile(filepathresults,['resultsROI_Condition',num2str(1,'%03d'),'.mat']);
                    %                 if isempty(dir(filename)),Ransw=conn_questdlg('First-level ROI analyses have not completed. Perform now?','warning','Yes','No','Yes');if strcmp(Ransw,'Yes'), conn_process('analyses_ROI'); end;end
                    %                 load(filename,'names','xyz');
                    set(CONN_h.menus.m_results_00{11},'max',2);set(CONN_h.menus.m_results_00{12},'max',2);set(CONN_h.menus.m_results_00{13},'max',2);
                    tnames=CONN_x.Setup.l2covariates.names(1:end-1); 
                    if ~isfield(CONN_h.menus.m_results,'showneffects_showall'), CONN_h.menus.m_results.showneffects_showall=false; end
                    if CONN_h.menus.m_results.showneffects_showall, CONN_h.menus.m_results.showneffects=1:numel(tnames); 
                    else CONN_h.menus.m_results.showneffects=find(cellfun(@(x)isempty(regexp(x,'^Dynamic |^_')),tnames)); 
                    end
                    if any(cellfun(@(x)~isempty(regexp(x,'^Dynamic |^_')),tnames))
                        hc1=uicontextmenu;
                        if CONN_h.menus.m_results.showneffects_showall, uimenu(hc1,'Label','Hide secondary variables','callback','conn(''gui_results'',39);');
                        else uimenu(hc1,'Label','Show secondary variables','callback','conn(''gui_results'',39);');
                        end
                        set(CONN_h.menus.m_results_00{11},'uicontextmenu',hc1);
                    end
                    set(CONN_h.menus.m_results_00{11},'string',conn_strexpand(CONN_x.Setup.l2covariates.names(CONN_h.menus.m_results.showneffects),CONN_x.Setup.l2covariates.descrip(CONN_h.menus.m_results.showneffects)),'value',min(numel(CONN_h.menus.m_results.showneffects),get(CONN_h.menus.m_results_00{11},'value')));
                    
                    if state==1||state==2, temptxt=CONN_h.menus.m_results.outcomenames(CONN_h.menus.m_results.shownsources);
                    else temptxt=conn_v2v('cleartext',CONN_h.menus.m_results.outcomenames(CONN_h.menus.m_results.shownsources));
                    end
                    set(CONN_h.menus.m_results_00{13},'string',temptxt,'value',1);
                    
                    modeltypes={'Random effects','Fixed effects'};
                    modeltype=1;%+(CONN_x.Setup.nsubjects==1);
                    %CONN_h.menus.m_results_00{21}=conn_menu('popup',[.10,.44-dp1,.125,.04],'Between-subjects model',modeltypes,'Select model type','conn(''gui_results'',21);');
                    %set(CONN_h.menus.m_results_00{21},'value',modeltype);
                    
                    ncovariates=1;
                    if ~isempty(CONN_h.menus.m_results.showneffects), ncovariates=CONN_h.menus.m_results.showneffects(1); end
                    if isfield(CONN_x.Results.xX,'nsubjecteffects')&&isfield(CONN_x.Results.xX,'csubjecteffects')&&size(CONN_x.Results.xX.csubjecteffects,2)==numel(CONN_x.Results.xX.nsubjecteffects),
                        try
                            [ok,icovariates]=ismember(CONN_x.Results.xX.nsubjecteffectsbyname,CONN_x.Setup.l2covariates.names(1:end-1));
                        catch
                            if isfield(CONN_x.Results.xX,'nsubjecteffectsbyname'), CONN_gui.warnloadbookmark{end+1}='warning: unable to select previous-design subject effects'; end
                            icovariates=CONN_x.Results.xX.nsubjecteffects;
                        end
                        [ok,tempcovariates]=ismember(icovariates,CONN_h.menus.m_results.showneffects);
                        if all(ok)
                            ncovariates=icovariates;
                            set(CONN_h.menus.m_results_00{11},'value',tempcovariates); %min(CONN_x.Results.xX.nsubjecteffects,numel(get(CONN_h.menus.m_results_00{11},'string'))));
                            set(CONN_h.menus.m_results_00{16},'string',mat2str(CONN_x.Results.xX.csubjecteffects));
                        else
                            CONN_gui.warnloadbookmark{end+1}='warning: unable to select previous-design subject effects';
                        end
                    end
                    if isempty(CONN_h.menus.m_results.shownsources), nsources=[]; else nsources=CONN_h.menus.m_results.shownsources(1); end
                    if state==1||state==2
                        if isfield(CONN_x.Results.xX,'nsources')&&isfield(CONN_x.Results.xX,'csources')&&size(CONN_x.Results.xX.csources,2)==numel(CONN_x.Results.xX.nsources),
                            try
                                [ok,isources]=ismember(CONN_x.Results.xX.nsourcesbyname,CONN_h.menus.m_results.outcomenames(CONN_h.menus.m_results.shownsources));
                            catch
                                if isfield(CONN_x.Results.xX,'nsourcesbyname'), CONN_gui.warnloadbookmark{end+1}='warning: unable to select previous-design sources'; end
                                [ok,isources]=ismember(CONN_x.Results.xX.nsources,CONN_h.menus.m_results.shownsources);
                            end
                            if all(ok) 
                                nsources=CONN_h.menus.m_results.shownsources(isources); %CONN_x.Results.xX.nsources;
                                set(CONN_h.menus.m_results_00{13},'value',isources);
                                set(CONN_h.menus.m_results_00{17},'string',mat2str(CONN_x.Results.xX.csources));
                            else
                                CONN_gui.warnloadbookmark{end+1}='warning: unable to select previous-design sources';
                            end
                        end
                    else
                        if isfield(CONN_x.Results.xX,'nmeasures')&&isfield(CONN_x.Results.xX,'cmeasures')&&size(CONN_x.Results.xX.cmeasures,2)==numel(CONN_x.Results.xX.nmeasures),
                            try
                                [ok,isources]=ismember(CONN_x.Results.xX.nmeasuresbyname,conn_v2v('cleartext',CONN_h.menus.m_results.outcomenames(CONN_h.menus.m_results.shownsources)));
                            catch
                                if isfield(CONN_x.Results.xX,'nmeasuresbyname'), CONN_gui.warnloadbookmark{end+1}='warning: unable to select previous-design measures'; end
                                [ok,isources]=ismember(CONN_x.Results.xX.nmeasures,CONN_h.menus.m_results.shownsources);
                            end
                            if all(ok)
                                nsources=CONN_h.menus.m_results.shownsources(isources); %CONN_x.Results.xX.nmeasures;
                                set(CONN_h.menus.m_results_00{13},'value',isources);
                                set(CONN_h.menus.m_results_00{17},'string',mat2str(CONN_x.Results.xX.cmeasures));
                            else
                                CONN_gui.warnloadbookmark{end+1}='warning: unable to select previous-design measures';
                            end
                        end
                    end
                    isvalidcondition=true(1,numel(icondition));
                    switch(state)
                        case 1, isvalidcondition=arrayfun(@(n)conn_existfile(fullfile(filepathresults,['resultsROI_Condition',num2str(n,'%03d'),'.mat'])),icondition);
                        case 2, isvalidcondition=arrayfun(@(n)conn_existfile(fullfile(filepathresults,['BETA_Subject',num2str(1,CONN_x.opt.fmt1),'_Condition',num2str(n,'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(1)),'%03d'),'.nii'])),icondition);
                        case 3, for n1=nsources(:)', isvalidcondition=isvalidcondition&arrayfun(@(n)conn_existfile(fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses(CONN_x.vvAnalysis).name,['BETA_Subject',num2str(1,'%03d'),'_Condition',num2str(n,'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(n1),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(n1),'%03d'),'.nii'])),icondition); end
                    end
                    CONN_h.menus.m_results.shownconditions=find(~isnewcondition&isvalidcondition);
                    %if isempty(CONN_h.menus.m_results.shownconditions), uiwait(errordlg('No conditions found. Please re-run first-level analyses','Data not prepared for analyses')); end
                    tnames=CONN_x.Setup.conditions.names(1:end-1);
                    set(CONN_h.menus.m_results_00{12},'string',tnames(CONN_h.menus.m_results.shownconditions),'value',min(numel(CONN_h.menus.m_results.shownconditions),get(CONN_h.menus.m_results_00{12},'value')));
                    CONN_h.menus.m_results.icondition=icondition;
                    CONN_h.menus.m_results.isnewcondition=isnewcondition;
                    modeltype=1;%if isfield(CONN_x.Results.xX,'modeltype'), modeltype=CONN_x.Results.xX.modeltype; set(CONN_h.menus.m_results_00{21},'value',min(CONN_x.Results.xX.modeltype,numel(get(CONN_h.menus.m_results_00{21},'string')))); end
                    nconditions=1;
                    if ~isempty(CONN_h.menus.m_results.shownconditions), nconditions=CONN_h.menus.m_results.shownconditions(1); end
                    if isfield(CONN_x.Results.xX,'nconditions')&&~isempty(CONN_x.Results.xX.nconditions)&&isfield(CONN_x.Results.xX,'cconditions')&&(state==1&&ischar(CONN_x.Results.xX.cconditions)||size(CONN_x.Results.xX.cconditions,2)==numel(CONN_x.Results.xX.nconditions)),
                        try
                            [ok,iconditions]=ismember(CONN_x.Results.xX.nconditionsbyname,CONN_x.Setup.conditions.names(1:end-1));
                        catch
                            if isfield(CONN_x.Results.xX,'nconditionsbyname'), CONN_gui.warnloadbookmark{end+1}='warning: unable to select previous-design conditions'; end
                            iconditions=CONN_x.Results.xX.nconditions;
                        end
                        [ok,tempconditions]=ismember(iconditions,CONN_h.menus.m_results.shownconditions);
                        if all(ok)
                            nconditions=iconditions;
                            set(CONN_h.menus.m_results_00{12},'value',tempconditions);%min(CONN_x.Results.xX.nconditions,numel(get(CONN_h.menus.m_results_00{12},'string'))));
                            set(CONN_h.menus.m_results_00{19},'string',mat2str(CONN_x.Results.xX.cconditions));
                        else
                            CONN_gui.warnloadbookmark{end+1}='warning: unable to select previous-design conditions';
                        end
                    end
                    %                 if isfield(CONN_x.Results.xX,'nsubjecteffects'), ncovariates=CONN_x.Results.xX.nsubjecteffects; set(CONN_h.menus.m_results_00{11},'value',min(CONN_x.Results.xX.nsubjecteffects,numel(get(CONN_h.menus.m_results_00{11},'string')))); end
                    %                 if isfield(CONN_x.Results.xX,'csubjecteffects'), set(CONN_h.menus.m_results_00{16},'string',num2str(CONN_x.Results.xX.csubjecteffects)); end
                    %                 if isfield(CONN_x.Results.xX,'nconditions'), nconditions=CONN_x.Results.xX.nconditions; set(CONN_h.menus.m_results_00{12},'value',min(CONN_x.Results.xX.nconditions,numel(get(CONN_h.menus.m_results_00{12},'string')))); end
                    %                 if isfield(CONN_x.Results.xX,'cconditions'), set(CONN_h.menus.m_results_00{19},'string',num2str(CONN_x.Results.xX.cconditions)); end
                    
                    %c=str2num(get(CONN_h.menus.m_results_00{17},'string'));
                    %txt=get(CONN_h.menus.m_results_00{17},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); catch, value=[]; end; end;c=value;
                    CONN_h.menus.m_results.X=zeros(CONN_x.Setup.nsubjects,length(CONN_x.Setup.l2covariates.names)-1);
                    for nsub=1:CONN_x.Setup.nsubjects,
                        for ncovariate=1:length(CONN_x.Setup.l2covariates.names)-1;
                            CONN_h.menus.m_results.X(nsub,ncovariate)=CONN_x.Setup.l2covariates.values{nsub}{ncovariate};
                        end
                    end
%                     if state==1||state==2
%                         txt=strvcat(CONN_x.Analyses(:).name);
%                         CONN_h.menus.m_results_00{20}=uicontrol('units','norm','position',[2.1*.91/4,.895,(.91-3*.91/4)*.8,.05],'style','popupmenu','string',txt,'fontsize',8+CONN_gui.font_offset,'value',ianalysis,'backgroundcolor','k','foregroundcolor','w','callback','conn(''gui_results'',20);','tooltipstring','Select first-level analysis name');
%                     end
                    
                    CONN_h.menus.m_results_surfhires=0;
                    CONN_h.menus.m_results.y.data=[];
                    CONN_h.menus.m_results.y.dataname={};
                    CONN_h.menus.m_results.y.MDok=[];
                    txt=get(CONN_h.menus.m_results_00{16},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); catch, value=[]; end; end;
                    b=value;
                    txt=get(CONN_h.menus.m_results_00{17},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); catch, value=[]; end; end;
                    c=value;
                    txt=get(CONN_h.menus.m_results_00{19},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{19},'string',mat2str(value)); catch, value=[]; end; end;
                    d=value;
                    if (state==2||state==3)&&any(CONN_x.Setup.steps([2,3]))&&CONN_x.Results.xX.displayvoxels<=2&&size(c,1)*size(d,1)<=100,%&&size(c,1)==1&&size(d,1)==1,%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
                        % loads voxel-level data
                        set(CONN_h.screen.hfig,'pointer','watch');drawnow
                        CONN_h.menus.m_results.y.MDok=conn_checkmissingdata(state,nconditions,nsources);
                        CONN_h.menus.m_results.y.data=repmat({0},size(c,1),size(d,1));
                        CONN_h.menus.m_results.y.dataname=repmat({''},size(c,1),size(d,1));
                        %if size(c,1)==1
                        %                     CONN_h.menus.m_results.se.data=0;
                        %                     CONN_h.menus.m_results.se.dof=0;
                        CONN_h.menus.m_results.Yall={};
                        CONN_h.menus.m_results.design.Y={};
                        CONN_h.menus.m_results.design.Ytitle={};
                        CONN_h.menus.m_results.design.Yweight=[];
                        names_sources=get(CONN_h.menus.m_results_00{13},'string');
                        for ncondition=1:length(nconditions),
                            for nsource=1:length(nsources),
                                filename=cell(1,CONN_x.Setup.nsubjects);
                                for nsub=1:CONN_x.Setup.nsubjects
                                    if state==1||state==2
                                        filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,CONN_x.opt.fmt1),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.nii']);
                                    else
                                        filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,'%03d'),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(nsources(nsource)),'%03d'),'.nii']);
                                    end
                                    CONN_h.menus.m_results.design.Y{nsub,nsource,ncondition}=filename{nsub};
                                end
                                if state==1||state==2
                                    CONN_h.menus.m_results.design.Ytitle{nsource,ncondition}=sprintf('%s @ %s',CONN_x.Analyses(CONN_x.Analysis).sources{nsources(nsource)},CONN_x.Setup.conditions.names{nconditions(ncondition)});
                                else
                                    CONN_h.menus.m_results.design.Ytitle{nsource,ncondition}=sprintf('%s @ %s',CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures{nsources(nsource)},CONN_x.Setup.conditions.names{nconditions(ncondition)});
                                end
                                try, CONN_h.menus.m_results.Y=spm_vol(char(filename));
                                catch,
                                    CONN_h.menus.m_results.y.data=[];
                                    conn_msgbox({'Not ready to display second-level Analyses',' ',sprintf('Condition (%s) has not been processed yet. Please re-run previous step (First-level analyses)',sprintf('%s ',CONN_x.Setup.conditions.names{nconditions(ncondition)}))},'',2);
                                    break;
                                end
                                CONN_h.menus.m_results.Yall{ncondition,nsource}=CONN_h.menus.m_results.Y;
                                if conn_surf_dimscheck(CONN_h.menus.m_results.Y(1).dim), %if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2]) % surface
                                    CONN_h.menus.m_results.y.slice=1;
                                    set(CONN_h.menus.m_results_00{15},'visible','off');
                                    conn_menumanager('onregion',[CONN_h.menus.m_results_00{33},CONN_h.menus.m_results_00{34},CONN_h.menus.m_results_00{35},CONN_h.menus.m_results_00{36},CONN_h.menus.m_results_00{43}],1,boffset+[.555,.03,.375,.90]);
                                    conn_menumanager('onregionremove',CONN_h.menus.m_results_00{15});
                                else
                                    if ~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                                    set(CONN_h.menus.m_results_00{15},'min',1,'max',CONN_h.menus.m_results.Y(1).dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_results.Y(1).dim(3)-1)),'value',CONN_h.menus.m_results.y.slice);
                                    conn_menumanager('onregion',[CONN_h.menus.m_results_00{33},CONN_h.menus.m_results_00{34},CONN_h.menus.m_results_00{35},CONN_h.menus.m_results_00{36},CONN_h.menus.m_results_00{44},CONN_h.menus.m_results_00{43}],1,boffset+[.555,.03,.375,.90]);
                                end
                                %                             filename=fullfile(filepathresults,['resultsDATA_Condition',num2str(nconditions(ncondition),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.mat']);
                                %                             CONN_h.menus.m_results.Y=conn_vol(filename);
                                if ncondition==1&&nsource==1
                                    [ndgridx,ndgridy]=ndgrid(1:CONN_h.menus.m_results.Y(1).dim(1),1:CONN_h.menus.m_results.Y(1).dim(2));
                                    CONN_h.menus.m_results.y.xyz=[ndgridx(:),ndgridy(:),ones(numel(ndgridx),2)]';
                                end
                                if conn_surf_dimscheck(CONN_h.menus.m_results.Y(1).dim), %if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2])
                                    if CONN_h.menus.m_results_surfhires
                                        temp=spm_read_vols(CONN_h.menus.m_results.Y);
                                        temp=permute(temp,[4,1,2,3]);
                                        temp=temp(:,:);
                                    else
                                        tempxyz1=CONN_h.menus.m_results.y.xyz;
                                        tempxyz1(3,:)=1;
                                        temp1=spm_get_data(CONN_h.menus.m_results.Y,tempxyz1);
                                        tempxyz2=CONN_h.menus.m_results.y.xyz;
                                        tempxyz2(3,:)=conn_surf_dims(8)*[0;0;1]+1;
                                        temp2=spm_get_data(CONN_h.menus.m_results.Y,tempxyz2);
                                        temp=[temp1(:,CONN_gui.refs.surf.default2reduced) temp2(:,CONN_gui.refs.surf.default2reduced)];
                                    end
                                else
                                    CONN_h.menus.m_results.y.xyz(3,:)=CONN_h.menus.m_results.y.slice;
                                    temp=spm_get_data(CONN_h.menus.m_results.Y,CONN_h.menus.m_results.y.xyz);
                                end
                                
                                %                             [temp,CONN_h.menus.m_results.y.idx]=conn_get_slice(CONN_h.menus.m_results.Y,CONN_h.menus.m_results.y.slice);
                                for nc1=find(c(:,nsource))',
                                    for nd1=find(d(:,ncondition))'
                                        CONN_h.menus.m_results.y.data{nc1,nd1}=CONN_h.menus.m_results.y.data{nc1,nd1}+temp*c(nc1,nsource)*d(nd1,ncondition);
                                        CONN_h.menus.m_results.y.dataname{nc1,nd1}=[CONN_h.menus.m_results.y.dataname{nc1,nd1} regexprep(sprintf(' %+g*%s@%s',c(nc1,nsource)*d(nd1,ncondition),deblank(regexprep(names_sources{find(CONN_h.menus.m_results.shownsources==nsources(nsource))},{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'})),CONN_x.Setup.conditions.names{nconditions(ncondition)}),{'\+1\*','\-1\*'},{'+','-'})];
                                    end
                                end
                                CONN_h.menus.m_results.design.Yweight(nsource,ncondition,:)=reshape(c(:,nsource)*d(:,ncondition)',1,1,[]);
                            end
                            if isempty(CONN_h.menus.m_results.y.data), break; end
                            %                         filename=fullfile(filepathresults,['seDATA_Condition',num2str(nconditions(ncondition),'%03d'),'.mat']);
                            %                         CONN_h.menus.m_results.SE=conn_vol(filename);
                            %                         [temp,nill]=conn_get_slice(CONN_h.menus.m_results.SE,CONN_h.menus.m_results.y.slice);
                            %                         CONN_h.menus.m_results.se.data=CONN_h.menus.m_results.se.data+sum(c.^2)*(d(ncondition)*temp).^2;
                            %                         CONN_h.menus.m_results.se.dof=CONN_h.menus.m_results.se.dof+CONN_h.menus.m_results.SE.DOF;
                        end
                        if iscell(CONN_h.menus.m_results.y.data), 
                            tidx=find(cellfun('length',CONN_h.menus.m_results.y.data));
                            CONN_h.menus.m_results.y.data=cat(4,CONN_h.menus.m_results.y.data{tidx}); 
                            CONN_h.menus.m_results.y.dataname=CONN_h.menus.m_results.y.dataname(tidx);
                            M=kron(d,c);
                            CONN_h.menus.m_results.y.M=M(tidx,:);
                        end
                        %                     CONN_h.menus.m_results.se.data=sqrt(CONN_h.menus.m_results.se.data);
                        CONN_h.menus.m_results.XS=CONN_gui.refs.canonical.V;
                        xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_results.Y(1).dim(1:2))*(CONN_h.menus.m_results.y.slice-1)+(1:prod(CONN_h.menus.m_results.Y(1).dim(1:2))),CONN_h.menus.m_results.Y(1).mat,CONN_h.menus.m_results.Y(1).dim);
                        txyz=pinv(CONN_h.menus.m_results.XS(1).mat)*xyz'; CONN_h.menus.m_results.Xs=spm_sample_vol(CONN_h.menus.m_results.XS(1),txyz(1,:),txyz(2,:),txyz(3,:),1);
                        CONN_h.menus.m_results.Xs=permute(reshape(CONN_h.menus.m_results.Xs,CONN_h.menus.m_results.Y(1).dim(1:2)),[2,1,3]);
                        CONN_h.menus.m_results.Xs=(CONN_h.menus.m_results.Xs/max(CONN_h.menus.m_results.Xs(:))).^3;
                        set(CONN_h.screen.hfig,'pointer','arrow');
                        if conn_surf_dimscheck(CONN_h.menus.m_results.Y(1).dim)&&~CONN_h.menus.m_results_surfhires, %if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2])&&~CONN_h.menus.m_results_surfhires, 
                            strstr3={'Results low-res preview (individual contrasts)','Results low-res preview (full model)','Do not show analysis results preview'};%,'Results whole-brain (full model)'};
                        else 
                            strstr3={'Results preview (individual contrasts)','Results preview (full model)','Do not show analysis results preview'};%,'Results whole-brain (full model)'};
                        end
                        set(CONN_h.menus.m_results_00{32},'string',strstr3,'value',CONN_x.Results.xX.displayvoxels);
                    elseif state==2||state==3
                        if state==1||state==2
                            filename=fullfile(filepathresults,['BETA_Subject',num2str(1,CONN_x.opt.fmt1),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(1)),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(1)),'%03d'),'.nii']);
                        else
                            filename=fullfile(filepathresults,['BETA_Subject',num2str(1,'%03d'),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(1)),'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(nsources(1)),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(nsources(1)),'%03d'),'.nii']);
                        end
                        CONN_h.menus.m_results.Y=spm_vol(char(filename));
                        if ~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                        [ndgridx,ndgridy]=ndgrid(1:CONN_h.menus.m_results.Y(1).dim(1),1:CONN_h.menus.m_results.Y(1).dim(2));
                        CONN_h.menus.m_results.y.xyz=[ndgridx(:),ndgridy(:),ones(numel(ndgridx),2)]';
                        CONN_h.menus.m_results.y.xyz(3,:)=CONN_h.menus.m_results.y.slice;
                        CONN_h.menus.m_results.y.data=[];
                        CONN_h.menus.m_results.y.dataname={};
                        CONN_h.menus.m_results.y.MDok=[];%conn_checkmissingdata(state,nconditions,nsources);
                        CONN_h.menus.m_results.XS=CONN_gui.refs.canonical.V;
                        xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_results.Y(1).dim(1:2))*(CONN_h.menus.m_results.y.slice-1)+(1:prod(CONN_h.menus.m_results.Y(1).dim(1:2))),CONN_h.menus.m_results.Y(1).mat,CONN_h.menus.m_results.Y(1).dim);
                        txyz=pinv(CONN_h.menus.m_results.XS(1).mat)*xyz'; CONN_h.menus.m_results.Xs=spm_sample_vol(CONN_h.menus.m_results.XS(1),txyz(1,:),txyz(2,:),txyz(3,:),1);
                        CONN_h.menus.m_results.Xs=permute(reshape(CONN_h.menus.m_results.Xs,CONN_h.menus.m_results.Y(1).dim(1:2)),[2,1,3]);
                        CONN_h.menus.m_results.Xs=(CONN_h.menus.m_results.Xs/max(CONN_h.menus.m_results.Xs(:))).^3;
                        CONN_h.menus.m_results.design.Y={};
                        CONN_h.menus.m_results.design.Ytitle={};
                        CONN_h.menus.m_results.design.Yweight=[];
                        for ncondition=1:length(nconditions),
                            for nsource=1:length(nsources),
                                filename=cell(1,CONN_x.Setup.nsubjects);
                                for nsub=1:CONN_x.Setup.nsubjects
                                    if state==1||state==2
                                        filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,CONN_x.opt.fmt1),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.nii']);
                                    else
                                        filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,'%03d'),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(nsources(nsource)),'%03d'),'.nii']);
                                    end
                                    CONN_h.menus.m_results.design.Y{nsub,nsource,ncondition}=filename{nsub};
                                end
                                if state==1||state==2
                                    CONN_h.menus.m_results.design.Ytitle{nsource,ncondition}=sprintf('%s @ %s',CONN_x.Analyses(CONN_x.Analysis).sources{nsources(nsource)},CONN_x.Setup.conditions.names{nconditions(ncondition)});
                                else
                                    CONN_h.menus.m_results.design.Ytitle{nsource,ncondition}=sprintf('%s @ %s',CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures{nsources(nsource)},CONN_x.Setup.conditions.names{nconditions(ncondition)});
                                end
                                CONN_h.menus.m_results.design.Yweight(nsource,ncondition,:)=reshape(c(:,nsource)*d(:,ncondition)',1,1,[]);
                            end
                        end
                    end
                    model=1;
                    modelroi=1;
                end
            else
                if ismember(varargin{2},[11,12,16,19])&&all(ishandle(CONN_h.menus.m_results_00{21})), set(CONN_h.menus.m_results_00{21},'value',1); end
				switch(varargin{2}),
					case 11,
						model=2;modelroi=1;
						ncovariates=get(CONN_h.menus.m_results_00{11},'value');
                        if isempty(ncovariates), ncovariates=1; set(CONN_h.menus.m_results_00{11},'value',1); end
                        ncovariates=CONN_h.menus.m_results.showneffects(ncovariates);
						if length(ncovariates)==1, set(CONN_h.menus.m_results_00{16},'string','1'); else  set(CONN_h.menus.m_results_00{16},'string',['eye(',num2str(length(ncovariates)),')']); end
					case {12,13,15,17,18,19,32}
						 isources=get(CONN_h.menus.m_results_00{13},'value');
                         nsources=CONN_h.menus.m_results.shownsources(isources);
                         if isempty(nsources), nsources=CONN_h.menus.m_results.shownsources(1); set(CONN_h.menus.m_results_00{13},'value',1); end
                         if varargin{2}==13&&state==3&&~stateb
                             isvalidcondition=true(1,numel(CONN_h.menus.m_results.icondition));
                             for n1=nsources(:)', isvalidcondition=isvalidcondition&arrayfun(@(n)conn_existfile(fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses(CONN_x.vvAnalysis).name,['BETA_Subject',num2str(1,'%03d'),'_Condition',num2str(n,'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(n1),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(n1),'%03d'),'.nii'])),CONN_h.menus.m_results.icondition); end
                             CONN_h.menus.m_results.shownconditions=find(~CONN_h.menus.m_results.isnewcondition&isvalidcondition);
                             tnames=CONN_x.Setup.conditions.names(1:end-1);
                             set(CONN_h.menus.m_results_00{12},'string',tnames(CONN_h.menus.m_results.shownconditions),'value',unique(min(numel(CONN_h.menus.m_results.shownconditions),get(CONN_h.menus.m_results_00{12},'value'))));
                         end
                         modelroi=1;
						 nconditions=get(CONN_h.menus.m_results_00{12},'value');
                         if isempty(CONN_h.menus.m_results.shownconditions), conn_msgbox({'Not ready to display second-level Analyses',' ','No conditions found. Please re-run first-level analyses'},'',2); return; end
                         if isempty(nconditions)||isequal(nconditions,0), nconditions=1; set(CONN_h.menus.m_results_00{12},'value',1); end
                         nconditions=CONN_h.menus.m_results.shownconditions(nconditions);
						 if varargin{2}==18,
                             ntarget=get(CONN_h.menus.m_results_00{18},'value');
                             ntarget=CONN_h.menus.m_results.roiresults.idx(ntarget);
                             CONN_h.menus.m_results.roiresults.lastselected=ntarget;
                             if state==2,%&&any(CONN_x.Setup.steps([2,3])),%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
                                 CONN_h.menus.m_results.y.slice=ceil(conn_convertcoordinates('tal2idx',CONN_h.menus.m_results.roiresults.xyz2{ntarget},CONN_h.menus.m_results.Y.matdim.mat,CONN_h.menus.m_results.Y.matdim.dim)/prod(CONN_h.menus.m_results.Y.matdim.dim(1:2)));
                                 if ~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                                 set(CONN_h.menus.m_results_00{15},'value',CONN_h.menus.m_results.y.slice);
                             end
                         elseif state==2||state==3
                             CONN_h.menus.m_results.y.slice=round(get(CONN_h.menus.m_results_00{15},'value')); 
                             if ~isempty(CONN_h.menus.m_results.y.data)&&isfield(CONN_h.menus.m_results,'Y')&&(~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3)), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                             set(CONN_h.menus.m_results_00{15},'value',CONN_h.menus.m_results.y.slice);
                         end
						 if varargin{2}==12,if length(nconditions)==1, set(CONN_h.menus.m_results_00{19},'string','1'); else  set(CONN_h.menus.m_results_00{19},'string',['eye(',num2str(length(nconditions)),')']);end; end
						 if varargin{2}==13,if length(nsources)==1, set(CONN_h.menus.m_results_00{17},'string','1'); else  set(CONN_h.menus.m_results_00{17},'string',['eye(',num2str(length(nsources)),')']);end; end
                         if state==1||state==2
                             filepathresults=fullfile(CONN_x.folders.firstlevel,CONN_x.Analyses(ianalysis).name);
                         else
                             filepathresults=fullfile(CONN_x.folders.firstlevel_vv,CONN_x.vvAnalyses(CONN_x.vvAnalysis).name);
                         end
						 %c=str2num(get(CONN_h.menus.m_results_00{17},'string'));
						 %d=str2num(get(CONN_h.menus.m_results_00{19},'string'));
                         txt=get(CONN_h.menus.m_results_00{16},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); catch, value=[]; end; end;
                         b=value;
                         txt=get(CONN_h.menus.m_results_00{17},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); catch, value=[]; end; end;
                         if state==1||state==2, if isempty(value)||size(value,2)~=numel(nsources), if isempty(CONN_x.Results.xX.csources)||size(CONN_x.Results.xX.csources,2)~=numel(nsources), value=eye(numel(nsources)); else value=CONN_x.Results.xX.csources; end; set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); end
                         else                   if isempty(value)||size(value,2)~=numel(nsources), if isempty(CONN_x.Results.xX.cmeasures)||size(CONN_x.Results.xX.cmeasures,2)~=numel(nsources), value=eye(numel(nsources)); else value=CONN_x.Results.xX.cmeasures; end; set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); end 
                         end
                         c=value;
                         txt=get(CONN_h.menus.m_results_00{19},'string'); 
                         if state==1&&isequal(txt,'var'), 
                             d=eye(numel(nconditions)); 
                             dvar=true;
                         else
                             value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{19},'string',mat2str(value)); catch, value=[]; end; end;
                             if isempty(value)||size(value,2)~=numel(nconditions), if isempty(CONN_x.Results.xX.cconditions)||size(CONN_x.Results.xX.cconditions,2)~=numel(nconditions), value=eye(numel(nconditions)); else value=CONN_x.Results.xX.cconditions; end; set(CONN_h.menus.m_results_00{19},'string',mat2str(value)); end
                             d=value;
                             dvar=false;
                         end
                         if varargin{2}==32, 
                             value=get(CONN_h.menus.m_results_00{32},'value'); 
                             if value==4
                                 set(CONN_h.menus.m_results_00{32},'value',CONN_x.Results.xX.displayvoxels);
                                 CONN_x.gui=struct('overwrite','No','display',1);
                                 if state==2,     conn gui_results_wholebrain;
                                 elseif state==3, conn gui_results_wholebrain_vv;
                                 end
                                 CONN_x.gui=1;
                                 return;
                             else
                                 CONN_x.Results.xX.displayvoxels=value;
                             end
                         end
                         if (state==2||state==3)&&CONN_x.Results.xX.displayvoxels<=2&&size(c,1)*size(d,1)<=100,%&&size(c,1)==1&&size(d,1)==1,%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
                             set(CONN_h.screen.hfig,'pointer','watch');drawnow
                             if varargin{2}==15, reload=false;
                             else CONN_h.menus.m_results.Yall={}; reload=true;
                             end
                             CONN_h.menus.m_results.y.xyz(3,:)=CONN_h.menus.m_results.y.slice;
                             if reload, CONN_h.menus.m_results.y.MDok=conn_checkmissingdata(state,nconditions,nsources); end
                             CONN_h.menus.m_results.y.data=repmat({0},size(c,1),size(d,1));
                             CONN_h.menus.m_results.y.dataname=repmat({''},size(c,1),size(d,1));
%                              CONN_h.menus.m_results.se.data=0;
%                              CONN_h.menus.m_results.se.dof=0;
                             if reload,
                                 CONN_h.menus.m_results.design.Y={};
                                 CONN_h.menus.m_results.design.Ytitle={};
                                 CONN_h.menus.m_results.design.Yweight=[];
                             end
                             names_sources=get(CONN_h.menus.m_results_00{13},'string');
                             for ncondition=1:length(nconditions),
                                 for nsource=1:length(nsources),
                                     if reload
                                         filename=cell(1,CONN_x.Setup.nsubjects);
                                         for nsub=1:CONN_x.Setup.nsubjects
                                             if state==1||state==2
                                                 filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,CONN_x.opt.fmt1),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.nii']);
                                             else
                                                 filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,'%03d'),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(nsources(nsource)),'%03d'),'.nii']);
                                             end
                                             CONN_h.menus.m_results.design.Y{nsub,nsource,ncondition}=filename{nsub};
                                         end
                                         if state==1||state==2
                                             CONN_h.menus.m_results.design.Ytitle{nsource,ncondition}=sprintf('%s @ %s',CONN_x.Analyses(CONN_x.Analysis).sources{nsources(nsource)},CONN_x.Setup.conditions.names{nconditions(ncondition)});
                                         else
                                             CONN_h.menus.m_results.design.Ytitle{nsource,ncondition}=sprintf('%s @ %s',CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures{nsources(nsource)},CONN_x.Setup.conditions.names{nconditions(ncondition)});
                                         end
                                         try, CONN_h.menus.m_results.Y=spm_vol(char(filename));
                                         catch,
                                             CONN_h.menus.m_results.y.data=[];
                                             conn_msgbox({'Not ready to display second-level Analyses',' ',sprintf('Condition (%s) has not been processed yet. Please re-run previous step (First-level analyses)',sprintf('%s ',CONN_x.Setup.conditions.names{ncondition}))},'',2);
                                             break;
                                         end
                                         CONN_h.menus.m_results.Yall{ncondition,nsource}=CONN_h.menus.m_results.Y;
                                     else CONN_h.menus.m_results.Y=CONN_h.menus.m_results.Yall{ncondition,nsource};
                                     end
                                     if conn_surf_dimscheck(CONN_h.menus.m_results.Y(1).dim), %if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2]) % surface
                                         CONN_h.menus.m_results.y.slice=1;
                                         set(CONN_h.menus.m_results_00{15},'visible','off');
                                         conn_menumanager('onregionremove',CONN_h.menus.m_results_00{15});
                                     else
                                         if ~isfield(CONN_h.menus.m_results.y,'slice')||CONN_h.menus.m_results.y.slice<1||CONN_h.menus.m_results.y.slice>CONN_h.menus.m_results.Y(1).dim(3), CONN_h.menus.m_results.y.slice=ceil(CONN_h.menus.m_results.Y(1).dim(3)/2); end
                                         set(CONN_h.menus.m_results_00{15},'min',1,'max',CONN_h.menus.m_results.Y(1).dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_results.Y(1).dim(3)-1)),'value',CONN_h.menus.m_results.y.slice);
                                     end
                                     
                                     if ncondition==1&&nsource==1
                                         [ndgridx,ndgridy]=ndgrid(1:CONN_h.menus.m_results.Y(1).dim(1),1:CONN_h.menus.m_results.Y(1).dim(2));
                                         CONN_h.menus.m_results.y.xyz=[ndgridx(:),ndgridy(:),ones(numel(ndgridx),2)]';
                                     end
                                     if conn_surf_dimscheck(CONN_h.menus.m_results.Y(1).dim), %if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2])
                                         if CONN_h.menus.m_results_surfhires
                                             temp=spm_read_vols(CONN_h.menus.m_results.Y);
                                             temp=permute(temp,[4,1,2,3]);
                                             temp=temp(:,:);
                                         else
                                             tempxyz1=CONN_h.menus.m_results.y.xyz;
                                             tempxyz1(3,:)=1;
                                             temp1=spm_get_data(CONN_h.menus.m_results.Y,tempxyz1);
                                             tempxyz2=CONN_h.menus.m_results.y.xyz;
                                             tempxyz2(3,:)=conn_surf_dims(8)*[0;0;1]+1;
                                             temp2=spm_get_data(CONN_h.menus.m_results.Y,tempxyz2);
                                             temp=[temp1(:,CONN_gui.refs.surf.default2reduced) temp2(:,CONN_gui.refs.surf.default2reduced)];
                                         end
                                     else
                                         CONN_h.menus.m_results.y.xyz(3,:)=CONN_h.menus.m_results.y.slice;
                                         temp=spm_get_data(CONN_h.menus.m_results.Y,CONN_h.menus.m_results.y.xyz);
                                     end
                                     for nc1=find(c(:,nsource))',
                                         for nd1=find(d(:,ncondition))'
                                             CONN_h.menus.m_results.y.data{nc1,nd1}=CONN_h.menus.m_results.y.data{nc1,nd1}+temp*c(nc1,nsource)*d(nd1,ncondition);
                                             CONN_h.menus.m_results.y.dataname{nc1,nd1}=[CONN_h.menus.m_results.y.dataname{nc1,nd1} regexprep(sprintf(' %+g*%s@%s',c(nc1,nsource)*d(nd1,ncondition),deblank(regexprep(names_sources{find(CONN_h.menus.m_results.shownsources==nsources(nsource))},{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'})),CONN_x.Setup.conditions.names{nconditions(ncondition)}),{'\+1\*','\-1\*'},{'+','-'})];
                                         end
                                     end
                                     CONN_h.menus.m_results.design.Yweight(nsource,ncondition,:)=reshape(c(:,nsource)*d(:,ncondition)',1,1,[]);
%                                      filename=fullfile(filepathresults,['resultsDATA_Condition',num2str(nconditions(ncondition),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.mat']);
%                                      CONN_h.menus.m_results.Y=conn_vol(filename);
%                                      [temp,CONN_h.menus.m_results.y.idx]=conn_get_slice(CONN_h.menus.m_results.Y,CONN_h.menus.m_results.y.slice);
%                                      CONN_h.menus.m_results.y.data=CONN_h.menus.m_results.y.data+temp*c(nsource)*d(ncondition);
                                 end
%                                  filename=fullfile(filepathresults,['seDATA_Condition',num2str(nconditions(ncondition),'%03d'),'.mat']);
%                                  CONN_h.menus.m_results.SE=conn_vol(filename);
%                                  [temp,nill]=conn_get_slice(CONN_h.menus.m_results.SE,CONN_h.menus.m_results.y.slice);
%                                  CONN_h.menus.m_results.se.data=CONN_h.menus.m_results.se.data+sum(c.^2)*(d(ncondition)*temp).^2;
%                                  CONN_h.menus.m_results.se.dof=CONN_h.menus.m_results.se.dof+CONN_h.menus.m_results.SE.DOF;
                                if isempty(CONN_h.menus.m_results.y.data), break; end
                             end
                             if iscell(CONN_h.menus.m_results.y.data), 
                                 tidx=find(cellfun('length',CONN_h.menus.m_results.y.data));
                                 CONN_h.menus.m_results.y.data=cat(4,CONN_h.menus.m_results.y.data{tidx});
                                 CONN_h.menus.m_results.y.dataname=CONN_h.menus.m_results.y.dataname(tidx);
                                 M=kron(d,c);
                                 CONN_h.menus.m_results.y.M=M(tidx,:);
                             end
%                              CONN_h.menus.m_results.se.data=sqrt(CONN_h.menus.m_results.se.data);
                             if varargin{2}==15||varargin{2}==18,
                                 xyz=conn_convertcoordinates('idx2tal',prod(CONN_h.menus.m_results.Y(1).dim(1:2))*(CONN_h.menus.m_results.y.slice-1)+(1:prod(CONN_h.menus.m_results.Y(1).dim(1:2))),CONN_h.menus.m_results.Y(1).mat,CONN_h.menus.m_results.Y(1).dim);
                                 txyz=pinv(CONN_h.menus.m_results.XS(1).mat)*xyz'; CONN_h.menus.m_results.Xs=spm_sample_vol(CONN_h.menus.m_results.XS(1),txyz(1,:),txyz(2,:),txyz(3,:),1);
                                 CONN_h.menus.m_results.Xs=permute(reshape(CONN_h.menus.m_results.Xs,CONN_h.menus.m_results.Y(1).dim(1:2)),[2,1,3]);
                                 CONN_h.menus.m_results.Xs=(CONN_h.menus.m_results.Xs/max(CONN_h.menus.m_results.Xs(:))).^3;
                                 set(CONN_h.menus.m_results_00{15},'min',1,'max',CONN_h.menus.m_results.Y(1).dim(3),'sliderstep',min(.5,[1,10]/(CONN_h.menus.m_results.Y(1).dim(3)-1)),'value',CONN_h.menus.m_results.y.slice);
                                 modelroi=0;
                             end
                             set(CONN_h.screen.hfig,'pointer','arrow');
                         elseif state==2||state==3
                             CONN_h.menus.m_results.y.data=[];
                             CONN_h.menus.m_results.design.Y={};
                             CONN_h.menus.m_results.design.Ytitle={};
                             CONN_h.menus.m_results.design.Yweight=[];
                             for ncondition=1:length(nconditions),
                                 for nsource=1:length(nsources),
                                     filename=cell(1,CONN_x.Setup.nsubjects);
                                     for nsub=1:CONN_x.Setup.nsubjects
                                         if state==1||state==2
                                             filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,CONN_x.opt.fmt1),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Source',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'.nii']);
                                         else
                                             filename{nsub}=fullfile(filepathresults,['BETA_Subject',num2str(nsub,'%03d'),'_Condition',num2str(CONN_h.menus.m_results.icondition(nconditions(ncondition)),'%03d'),'_Measure',num2str(CONN_h.menus.m_results.outcomeisource(nsources(nsource)),'%03d'),'_Component',num2str(CONN_h.menus.m_results.outcomencompsource(nsources(nsource)),'%03d'),'.nii']);
                                         end
                                         CONN_h.menus.m_results.design.Y{nsub,nsource,ncondition}=filename{nsub};
                                     end
                                     if state==1||state==2
                                         CONN_h.menus.m_results.design.Ytitle{nsource,ncondition}=sprintf('%s @ %s',CONN_x.Analyses(CONN_x.Analysis).sources{nsources(nsource)},CONN_x.Setup.conditions.names{nconditions(ncondition)});
                                     else
                                         CONN_h.menus.m_results.design.Ytitle{nsource,ncondition}=sprintf('%s @ %s',CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures{nsources(nsource)},CONN_x.Setup.conditions.names{nconditions(ncondition)});
                                     end
                                     CONN_h.menus.m_results.design.Yweight(nsource,ncondition,:)=reshape(c(:,nsource)*d(:,ncondition)',1,1,[]);
                                 end
                             end
                         end
						 model=1;
					case 16,
						ncovariates=get(CONN_h.menus.m_results_00{11},'value');
                        ncovariates=CONN_h.menus.m_results.showneffects(ncovariates);
                        txt=get(CONN_h.menus.m_results_00{16},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); catch, value=[]; end; end;
                        if isempty(value)||size(value,2)~=numel(ncovariates), value=CONN_x.Results.xX.csubjecteffects; set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); end
                        model=2;modelroi=1;
                    case 20,
                        tianalysis=get(CONN_h.menus.m_results_00{20},'value');
                        tianalysis=CONN_h.menus.m_results.shownanalyses(tianalysis);
                        if state==1||state==2, CONN_x.Analysis=tianalysis;
                        elseif state==3||state==4, CONN_x.vvAnalysis=tianalysis;
                        else CONN_x.dynAnalysis=tianalysis;
                        end
                        conn gui_results;
                        return;
                    case 43
                        answ=conn_questdlg('Bookmark options:','Bookmark','Open','Save','Cancel','Save');
                        if isequal(answ,'Save')
                            switch(state)
                                case 1,
                                    if ~stateb, conn('gui_results_bookmark','r2r');
                                    else conn('gui_results_bookmark','dyn_spatial');
                                    end
                                case 2,
                                    conn('gui_results_bookmark','s2v');
                                case 3, if ~stateb, conn('gui_results_bookmark','v2v');
                                    else conn('gui_results_bookmark','ica_spatial');
                                    end
                            end
                        elseif isequal(answ,'Open')
                            files=conn_dir(fullfile(CONN_x.folders.bookmarks,'*.bookmark.jpg'));
                            files=cellstr(files);
                            tvalid=find(cellfun('length',files)>0);
                            if ~isempty(tvalid)
                                tvalid=tvalid(cellfun(@conn_existfile,conn_prepend('',files(tvalid),'.mat'))>0);
                                files=files(tvalid);
                                [nill,files_name]=cellfun(@fileparts,files,'uni',0);
                                [nill,files_folder]=cellfun(@fileparts,nill,'uni',0);
                                [nill,idx]=sort(cellstr(cat(2,char(files_folder),char(files_name)))); % sort ascending (oldest first)
                                files=files(idx);files_name=files_name(idx); files_folder=files_folder(idx);
                                files_descr=repmat({''},size(files));
                                tvalid=cellfun(@conn_existfile,conn_prepend('',files,'.txt'));
                                files_descr(tvalid)=cellfun(@fileread,conn_prepend('',files(tvalid),'.txt'),'uni',0);
                                files_descr=cellfun(@(a,b){a,['(',b,')']},files_descr,files_name,'uni',0);

                                str=regexprep(cellfun(@(a,b)sprintf('%s : %s',a,sprintf('%s ',b{:})),files_folder,files_descr,'uni',0),'\n',' ');
                                nbook=listdlg('name','Bookmarks','PromptString','Select bookmark to open','ListString',str,'SelectionMode','single','ListSize',[600 200]);
                                if ~isempty(nbook)
                                    filename=files{nbook};
                                    conn_bookmark('open',filename);
                                end
                            end
                        end
                        return;
                    case 21
                        ncontrast=get(CONN_h.menus.m_results_00{21},'value')-1;
                        if ncontrast==numel(get(CONN_h.menus.m_results_00{21},'string'))-1,
                            ncontrast=conn_contrastmanager('guiadd');
                            tnames=conn_contrastmanager('namesextended');
                            set(CONN_h.menus.m_results_00{21},'string',[{'<HTML>- <i>contrast tools</i></HTML>'},tnames,{'<HTML><i>save new contrast</i></HTML>'}]);
                            [doexist,doexisti]=conn_contrastmanager('check');
                            if doexist, set(CONN_h.menus.m_results_00{21},'value',doexisti+1);
                            else set(CONN_h.menus.m_results_00{21},'value',1);
                            end
                        end
                        if ncontrast
                            [ok1,i1]=ismember(CONN_x.Results.saved.nsubjecteffects{ncontrast},CONN_x.Setup.l2covariates.names(1:end-1));
                            if ~all(ok1), conn_msgbox('Error. Invalid second-level covariate names','',2); ok=false;
                            else
                                [ok2,i2]=ismember(CONN_x.Results.saved.nconditions{ncontrast},CONN_x.Setup.conditions.names(1:end-1));
                                if ~all(ok2), conn_msgbox('Error. Invalid condition names','',2); ok=false;
                                else 
                                    CONN_x.Results.xX.nsubjecteffects=i1;
                                    CONN_x.Results.xX.csubjecteffects=CONN_x.Results.saved.csubjecteffects{ncontrast};
                                    CONN_x.Results.xX.nconditions=i2;
                                    CONN_x.Results.xX.cconditions=CONN_x.Results.saved.cconditions{ncontrast};
                                    if isfield(CONN_x.Results.xX,'nsubjecteffects')&&isfield(CONN_x.Results.xX,'csubjecteffects')&&size(CONN_x.Results.xX.csubjecteffects,2)==numel(CONN_x.Results.xX.nsubjecteffects)&&all(ismember(CONN_x.Results.xX.nsubjecteffects,CONN_h.menus.m_results.showneffects)),
                                        ncovariates=CONN_x.Results.xX.nsubjecteffects;
                                        [nill,tempcovariates]=ismember(ncovariates,CONN_h.menus.m_results.showneffects);
                                        set(CONN_h.menus.m_results_00{11},'value',tempcovariates); %min(CONN_x.Results.xX.nsubjecteffects,numel(get(CONN_h.menus.m_results_00{11},'string'))));
                                        set(CONN_h.menus.m_results_00{16},'string',mat2str(CONN_x.Results.xX.csubjecteffects));
                                    else disp('Warning. Unable to match subject effects from saved contrast to current analyses'); 
                                    end
                                    if isfield(CONN_x.Results.xX,'nconditions')&&~isempty(CONN_x.Results.xX.nconditions)&&isfield(CONN_x.Results.xX,'cconditions')&&size(CONN_x.Results.xX.cconditions,2)==numel(CONN_x.Results.xX.nconditions)&&all(ismember(CONN_x.Results.xX.nconditions,CONN_h.menus.m_results.shownconditions)),
                                        nconditions=CONN_x.Results.xX.nconditions;
                                        [nill,tempconditions]=ismember(nconditions,CONN_h.menus.m_results.shownconditions);
                                        set(CONN_h.menus.m_results_00{12},'value',tempconditions);%min(CONN_x.Results.xX.nconditions,numel(get(CONN_h.menus.m_results_00{12},'string'))));
                                        set(CONN_h.menus.m_results_00{19},'string',mat2str(CONN_x.Results.xX.cconditions));
                                    else disp('Warning. Unable to match condition names from saved contrast to current analyses'); 
                                    end
                                    conn('gui_results',19);
                                    return;
                                end
                                %conn gui_results;
                                %return;
                            end
                        end
%                     case 21,
% 						model=1;modelroi=1;
                    case 26,
                        if ~isempty(CONN_h.menus.m_results_00{26})&&ishandle(CONN_h.menus.m_results_00{26}(1))
                            %CONN_h.menus.m_results.roiresults.displayrois;
                            %CONN_h.menus.m_results.roiresults.displayroisnames;
                            xyz=get(get(CONN_h.menus.m_results_00{26}(1),'parent'),'currentpoint');
                            [nill,idx]=min(sum(abs(conn_bsxfun(@minus,xyz(1,1:2),CONN_h.menus.m_results.roiresults.displayrois(:,6:7))).^2,2));
                            if nill<50
                                ntarget=find(CONN_h.menus.m_results.roiresults.idx==CONN_h.menus.m_results.roiresults.displayrois(idx,8));
                                if numel(ntarget)==1&&size(get(CONN_h.menus.m_results_00{18},'string'),1)>=ntarget
                                    if strcmp(get(CONN_h.screen.hfig,'selectiontype'),'extend')
                                        ntargetold=get(CONN_h.menus.m_results_00{18},'value');
                                        if ismember(ntarget,ntargetold), set(CONN_h.menus.m_results_00{18},'value',setdiff(ntargetold,ntarget));
                                        else set(CONN_h.menus.m_results_00{18},'value',union(ntargetold,ntarget));
                                        end
                                    else set(CONN_h.menus.m_results_00{18},'value',ntarget);
                                    end
                                end
                            end
                        end
                    case 28
                        CONN_x.Results.xX.inferencetype=get(CONN_h.menus.m_results_00{28},'value');
                        modelroi=2;
                    case 29
                        CONN_x.Results.xX.inferenceleveltype=get(CONN_h.menus.m_results_00{27},'value');
                        modelroi=2;
                    case 30
                        txt=get(CONN_h.menus.m_results_00{30},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{30},'string',num2str(value)); catch, value=[]; end; end;
                        if ~isempty(value), CONN_x.Results.xX.inferencelevel=value; else set(CONN_h.menus.m_results_00{30},'string',num2str(CONN_x.Results.xX.inferencelevel)); end
                        modelroi=2;
                    case 31,
                        CONN_x.Results.xX.displayrois=get(CONN_h.menus.m_results_00{31},'value');
                        if ~isfield(CONN_x.Results.xX,'roiselected2'), CONN_x.Results.xX.roiselected2=1:numel(CONN_h.menus.m_results.roiresults.names2); end
                        if CONN_x.Results.xX.displayrois==3
                            idxresortv=1:numel(CONN_h.menus.m_results.roiresults.names2);
                            temp=regexp(CONN_h.menus.m_results.roiresults.names2,'BA\.(\d*) \(L\)','tokens'); itemp=~cellfun(@isempty,temp); idxresortv(itemp)=-2e6+cellfun(@(x)str2double(x{1}),temp(itemp));
                            temp=regexp(CONN_h.menus.m_results.roiresults.names2,'BA\.(\d*) \(R\)','tokens'); itemp=~cellfun(@isempty,temp); idxresortv(itemp)=-1e6+cellfun(@(x)str2double(x{1}),temp(itemp));
                            [nill,idxresort]=sort(idxresortv);
                            [nill,tidx]=ismember(CONN_x.Results.xX.roiselected2,idxresort);
                            answ=listdlg('Promptstring','Select target ROIs','selectionmode','multiple','liststring',CONN_h.menus.m_results.roiresults.names2(idxresort),'initialvalue',sort(tidx));
                            if ~isempty(answ)>0, 
                                CONN_x.Results.xX.roiselected2=sort(idxresort(answ)); 
                                CONN_x.Results.xX.roiselected2byname=CONN_h.menus.m_results.roiresults.names2(CONN_x.Results.xX.roiselected2);
                            end
                        end
                        modelroi=2;
                    case 33,
                        %CONN_x.gui=struct('overwrite','No','display',1);
                        CONN_x.gui=struct('display',1);
                        if state==2,     conn gui_results_wholebrain;
                        elseif state==3, conn gui_results_wholebrain_vv;
                        end
                        CONN_x.gui=1;
                        return;
                    case {34,35,36}
                         if isempty(CONN_h.menus.m_results.shownconditions), conn_msgbox({'Not ready to display second-level Analyses',' ','No conditions found. Please re-run first-level analyses'},'',2); return; end
						 nconditions=get(CONN_h.menus.m_results_00{12},'value');
                         nconditions=CONN_h.menus.m_results.shownconditions(nconditions);
						 isources=get(CONN_h.menus.m_results_00{13},'value');
                         nsources=CONN_h.menus.m_results.shownsources(isources);
                         if state==1
                             ntarget=get(CONN_h.menus.m_results_00{18},'value');
                             if isempty(ntarget), conn_msgbox('please select target ROI in "Analysis results" display first','',2); end
                             ntarget=CONN_h.menus.m_results.roiresults.idx(ntarget);
                             CONN_h.menus.m_results.roiresults.lastselected=ntarget;
                         else
                             if isfield(CONN_h.menus.m_results,'selectedcoords')&&~isempty(CONN_h.menus.m_results.selectedcoords), ntarget=CONN_h.menus.m_results.selectedcoords;
                             else ntarget=[]; conn_msgbox('please select target voxel in "Results preview" display first','',2); 
                             end
                         end
                         if isempty(ntarget)||isempty(isources), return; end
                         names_sources=get(CONN_h.menus.m_results_00{13},'string');
                         names_conditions=CONN_x.Setup.conditions.names(1:end-1);%get(CONN_h.menus.m_results_00{12},'string');
                         y={};
                         name={};
                         if state==1
                             for itarget=1:numel(ntarget)
                                 if isfield(CONN_h.menus.m_results,'showraw')&&CONN_h.menus.m_results.showraw
                                     for icondition=1:numel(nconditions)
                                         for isource=1:numel(nsources)
                                             ty=CONN_h.menus.m_results.roiresults.y(:,ntarget(itarget),isource,icondition);
                                             if isfield(CONN_h.menus.m_results.roiresults.xX,'SelectedSubjects')&&~rem(size(ty,1),nnz(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects))
                                                 ty2=nan(size(ty,1)/nnz(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects)*numel(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),size(ty,2));
                                                 ty2(repmat(logical(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),size(ty,1)/nnz(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),1),:)=ty;
                                                 ty=ty2;
                                             end
                                             y{end+1}=ty;
                                             name{end+1}=sprintf('conn between %s and %s at %s',...
                                                 regexprep(names_sources{isources(isource)},{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'}),...
                                                 regexprep(CONN_h.menus.m_results.roiresults.names2{ntarget(itarget)},{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'}),...
                                                 names_conditions{nconditions(icondition)});
                                         end
                                     end
                                 else
                                     for n1=1:size(CONN_h.menus.m_results.roiresults.c2,1)
                                         tname=sprintf('R2R target ROI %s : ',regexprep(CONN_h.menus.m_results.roiresults.names2{ntarget(itarget)},{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'}));
                                         Yweight=CONN_h.menus.m_results.roiresults.c2(n1,:);
                                         for n2=reshape(find(Yweight),1,[])
                                             [isource,icondition]=ind2sub([numel(nsources),numel(nconditions)],n2);
                                             temp=sprintf('%s @ %s',...
                                                 regexprep(names_sources{isources(isource)},{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'}),...
                                                 names_conditions{nconditions(icondition)});
                                             tname=strcat(tname,regexprep(temp,{'^(.*)',' \+1 \*',' \-1 \*'},{sprintf(' %+g * $1',Yweight(n2)),' +',' -'}));
                                         end
                                         ty=reshape(CONN_h.menus.m_results.roiresults.y(:,ntarget(itarget),:,:),size(CONN_h.menus.m_results.roiresults.y,1),[])*Yweight';
                                         if isfield(CONN_h.menus.m_results.roiresults.xX,'SelectedSubjects')&&~rem(size(ty,1),nnz(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects))
                                             ty2=nan(size(ty,1)/nnz(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects)*numel(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),size(ty,2));
                                             ty2(repmat(logical(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),size(ty,1)/nnz(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),1),:)=ty;
                                             ty=ty2;
                                         end
                                         y{end+1}=ty;
                                         name{end+1}=tname;
                                     end
                                 end
                             end
                         else
                             if ~isfield(CONN_h.menus.m_results,'selectedidx'),
                                 txyz=round(pinv(CONN_h.menus.m_results.Y(1).mat)*[ntarget(1:3,:);ones(1,size(ntarget,2))]);
                                 CONN_h.menus.m_results.selectedidx=sub2ind(CONN_h.menus.m_results.Y(1).dim(1:2),txyz(1,:),txyz(2,:));
                             end                                 
                             ty=permute(CONN_h.menus.m_results.y.data(:,CONN_h.menus.m_results.selectedidx,:),[1,3,2]);
                             ty(setdiff(1:size(ty,1), CONN_h.menus.m_results.design.subjects),:)=nan;
                             y=num2cell(ty,1);
                             txt=arrayfun(@(n)sprintf('S2V target voxel (%d,%d,%d) : ',CONN_h.menus.m_results.selectedcoords(1,n),CONN_h.menus.m_results.selectedcoords(2,n),CONN_h.menus.m_results.selectedcoords(3,n)),1:size(CONN_h.menus.m_results.selectedcoords,2),'uni',0);
                             name={};for n=1:numel(txt), name=[name, regexprep(CONN_h.menus.m_results.y.dataname,'(.*)',[txt{n} '$1'])]; end
                             %CONN_h.menus.m_results.y.M
                         end
                         if varargin{2}==34
                             if conn_importl2covariate(name,y), conn gui_results; end
                         elseif varargin{2}==36
                             hfig=figure('units','norm','position',[.2 .3 .6 .6],'color','w','name','connectivity values','numbertitle','off','menubar','none');
                             %CONN_h.menus.m_results.design.designmatrix;
                             hax=axes('units','norm','position',[.2,.4,.6,.5],'box','off');
                             color=get(hax,'colororder');
                             color(all(color==1,2),:)=[];%xxd=.4/size(cbeta,2)/2;
                             yf=[];
                             showlegend=numel(name)>1&&numel(name)<=10;
                             toggle=numel(CONN_h.menus.m_results.design.subjects)>numel(name);
                             issigned=numel(name)<=4|numel(CONN_h.menus.m_results.design.subjects)<=4;%numel(name)==1;
                             maxabs=0;
                             for ny=1:numel(y), maxabs=max(maxabs,max(max(abs(y{ny}(CONN_h.menus.m_results.design.subjects,:))))); end
                             for ny=1:numel(y)
                                 yf=y{ny}(CONN_h.menus.m_results.design.subjects,:);
                                 yf=yf/maxabs;
                                 
                                 if toggle, 
                                     if showlegend
                                         hs=conn_menu_plotmatrix(.5+zeros(size(yf,2),1));
                                         hs.vertices(:,2)=hs.vertices(:,2)+numel(y)-ny;
                                         hpatches(ny)=patch(hs,'edgecolor','none','facecolor',color(1+mod(ny-1,size(color,1)),:),'parent',hax);
                                     end
                                     hs=conn_menu_plotmatrix(yf','signed',issigned);
                                     hs.vertices(:,1)=hs.vertices(:,1)+2;
                                     hs.vertices(:,2)=hs.vertices(:,2)+numel(y)-ny;
                                 else
                                     if showlegend
                                         hs=conn_menu_plotmatrix(.5+zeros(1,size(yf,2)));
                                         hs.vertices(:,1)=hs.vertices(:,1)+ny-1;
                                         hpatches(ny)=patch(hs,'edgecolor','none','facecolor',color(1+mod(ny-1,size(color,1)),:),'parent',hax);
                                     end
                                     hs=conn_menu_plotmatrix(yf,'signed',issigned);
                                     hs.vertices(:,1)=hs.vertices(:,1)+ny-1;
                                     hs.vertices(:,2)=hs.vertices(:,2)+2;
                                 end
                                 patch(hs,'facecolor','flat','edgecolor','none','parent',hax);
                             end
                             %axis(hax,'equal');
                             if toggle
                                 set(hax,'ylim',[0 numel(name)+1],'ycolor','w','xlim',[0 numel(CONN_h.menus.m_results.design.subjects)+3],'ytick',[],'xtick',2+(1:numel(CONN_h.menus.m_results.design.subjects)),'xticklabel',arrayfun(@num2str,CONN_h.menus.m_results.design.subjects,'uni',0));
                                 xlabel(hax,'Subjects');
                                 if issigned, hold on; plot(repmat(2+[0 numel(CONN_h.menus.m_results.design.subjects)+1]',1,numel(name)),repmat(1:numel(name),2,1),'k-'); hold off; end
                                 if showlegend, hold on; plot(2+[0 0],[0 numel(name)+1],'k-'); hold off; end
                                 hold on; plot(numel(CONN_h.menus.m_results.design.subjects)+2.6+[.1 -.1 0 0 .1 -.1],1-1+[.5 .5 .5 1.5 1.5 1.5],'k-');text(numel(CONN_h.menus.m_results.design.subjects)+2.7,1+.5,mat2str(maxabs,max([0,ceil(log10(max(1e-10,abs(maxabs))))])+2),'horizontalalignment','left'); hold off;
                             else
                                 set(hax,'xlim',[0 numel(name)+1],'xcolor','w','ylim',[0 numel(CONN_h.menus.m_results.design.subjects)+3],'xtick',[],'ytick',2+(1:numel(CONN_h.menus.m_results.design.subjects)),'yticklabel',arrayfun(@num2str,CONN_h.menus.m_results.design.subjects,'uni',0));
                                 ylabel(hax,'Subjects');
                                 if issigned, hold on; plot(repmat([0 numel(name)+1]',1,numel(CONN_h.menus.m_results.design.subjects)),2+repmat(1:numel(CONN_h.menus.m_results.design.subjects),2,1),'k-'); hold off; end
                                 if showlegend, hold on; plot([0 numel(name)+1],2+[0 0],'k-'); hold off; end
                                 hold on; plot(numel(name)+0.6+[.1 -.1 0 0 .1 -.1],2+1-1+[.5 .5 .5 1.5 1.5 1.5],'k-');text(numel(name)+0.7,2+1+.5,num2str(round(maxabs*1e1)/1e1),'horizontalalignment','left'); hold off;
                                 %hold on; plot([.5 .5 .5 1.5 1.5 1.5],2+numel(CONN_h.menus.m_results.design.subjects)+.6+[.1 -.1 0 0 .1 -.1],'k-');text(1,2+numel(CONN_h.menus.m_results.design.subjects)+.6+.4,num2str(round(maxabs*1e1)/1e1),'horizontalalignment','center'); hold off;
                             end
                             if numel(name)<=1, set(hax,'units','norm','position',[.2,.15,.6,.7]); set(hfig,'name',char(name),'position',[.2 .3 .4 .3]);
                             elseif showlegend, hl=legend(hpatches,name); set(hl,'box','off','units','norm','position',[.2,.1,.6,.2]);
                             else set(hax,'units','norm','position',[.2,.15,.6,.7]); disp('Effects displayed (in order)'); disp(char(name));
                             end
                                 %CONN_h.menus.m_results.design.data
                                 %CONN_h.menus.m_results.design.subjects
                         else
                             assignin('base','Effect_values',y);
                             assignin('base','Effect_names',name);
                             disp('Exported the following effects:');
                             disp(char(name));
                             disp('Values exported to variable ''Effect_values''; Names exported to variable ''Effect_names''');
                             disp(' ');
                             
                             clear Stats_values;
                             if state==1
                                 if isfield(CONN_h.menus.m_results.roiresults.xX,'SelectedSubjects')
                                     xf=zeros(numel(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),size(CONN_h.menus.m_results.roiresults.xX.X,2));
                                     xf(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects,:)=CONN_h.menus.m_results.roiresults.xX.X; %CONN_x.Results.xX.X(:,CONN_x.Results.xX.nsubjecteffects);
                                 else
                                     xf=CONN_h.menus.m_results.roiresults.xX.X;
                                 end
                                 nsubjects=find(any(xf~=0,2)&~any(isnan(xf),2));
                                 xf=xf(nsubjects,:);
                                 tnames=CONN_h.menus.m_results.roiresults.xX.name; %CONN_x.Setup.l2covariates.names(CONN_x.Results.xX.nsubjecteffects);
                                 Cext=CONN_h.menus.m_results.roiresults.c;
                                 tnames=arrayfun(@(n)conn_longcontrastname(tnames,Cext(n,:)),1:size(Cext,1),'uni',0);
                             else
                                 xf=CONN_h.menus.m_results.design.designmatrix;
                                 nsubjects=CONN_h.menus.m_results.design.subjects;
                                 tnames=CONN_h.menus.m_results.design.designmatrix_name;
                                 Cext=CONN_h.menus.m_results.design.contrast_between;
                                 tnames=arrayfun(@(n)conn_longcontrastname(tnames,Cext(n,:)),1:size(Cext,1),'uni',0);
                             end
                             for ny=1:numel(y)
                                 yf=y{ny}(nsubjects,:);
                                 [Stats_values(ny).beta,Stats_values(ny).F,Stats_values(ny).p,Stats_values(ny).dof,Stats_values(ny).stat]=conn_glm(xf,yf,Cext,[],'collapse_none');
                             end
                             %assignin('base','Effect_stats',Stats_values);
                             %disp('Stats exported to variable ''Effect_stats''');
                             
                             hfig=figure('units','norm','position',[.2 .3 .6 .6],'color','w','name','connectivity effects','numbertitle','off','menubar','none');
                             cbeta=[Stats_values.beta];
                             CI=spm_invTcdf(1-.05,Stats_values(1).dof)*cbeta./[Stats_values.F];
                             hax=gca;
                             hpatches=conn_plotbars(cbeta,CI);
                             set(hax,'units','norm','position',[.2,.4,.6,.5],'box','off','xlim',[0 size(cbeta,1)+1]);
                             if size(cbeta,1)>=1, set(hax,'xtick',1:numel(tnames),'xticklabel',tnames);
                             else set(hax,'xtick',[]);
                             end
                             %xlabel('2nd-level GLM model regression coefficients');
                             ylabel('Effect size');
                             if numel(name)==1, set(hax,'units','norm','position',[.2,.15,.6,.7]); set(hfig,'name',char(name),'position',[.2 .3 .4 .3]);
                             elseif numel(name)<=10, hl=legend(hpatches(1,:),name); set(hl,'box','off','units','norm','position',[.2,.1,.6,.2]);
                             else set(hax,'units','norm','position',[.2,.15,.6,.7]); disp('Effects displayed (in order)'); disp(char(name));
                             end
                             zoom(hax,'on');
                         end
                         return;
                    case 37
                        val=max(1,round(get(CONN_h.menus.m_results_00{37},'value')));
                        CONN_h.menus.m_results.roinslices=val;
                        tfact=round(linspace(CONN_gui.refs.canonical.V.dim(3)-12,6,CONN_h.menus.m_results.roinslices+2));
                        tfact=tfact(2:end-1);
                        dtfact=min(abs(diff([1,tfact])));
                        if dtfact>=3, xs0=0; for n1=-dtfact:dtfact, xs0=xs0+(1-abs(n1)/(dtfact+1))*max(0,permute(CONN_gui.refs.canonical.data(end:-1:1,end:-1:1,max(1,min(size(CONN_gui.refs.canonical.data,3),tfact+n1))),[2,1,4,3])); end; xs0=xs0/(2*dtfact+1);
                        else xs0=permute(CONN_gui.refs.canonical.data(end:-1:1,end:-1:1,tfact),[2,1,4,3]);
                        end
                        CONN_h.menus.m_results.xseM=[-1 0 0 0;0 -1 0 0;0 0 1/mean(diff(tfact)) 0;CONN_gui.refs.canonical.V.dim(1)+1 CONN_gui.refs.canonical.V.dim(2)+1 1-tfact(1)/mean(diff(tfact)) 1]'; % note: from xyz position (voxels) in canonical volume to xyz position (matrix coordinates) in selected slices display
                        xs0=abs(xs0./max(abs(xs0(:)))).^2;
                        xs0=1+126*abs(xs0/max(abs(xs0(:))));
                        [CONN_h.menus.m_results.xse,CONN_h.menus.m_results.xsen1n2]=conn_menu_montage(CONN_h.menus.m_results_00{25},xs0);
                        set(CONN_h.menus.m_results_00{38},'cdata',max(1,CONN_h.menus.m_results.xse));
                        set(get(CONN_h.menus.m_results_00{38},'parent'),'xlim',[.5 size(CONN_h.menus.m_results.xse,2)+.5],'ylim',[.5 size(CONN_h.menus.m_results.xse,1)+.5]);
                    case 39
						ncovariates=get(CONN_h.menus.m_results_00{11},'value');
                        ncovariates=CONN_h.menus.m_results.showneffects(ncovariates);
                        tnames=CONN_x.Setup.l2covariates.names(1:end-1);
                        if ~isfield(CONN_h.menus.m_results,'showneffects_showall'), CONN_h.menus.m_results.showneffects_showall=false; end
                        CONN_h.menus.m_results.showneffects_showall=1-CONN_h.menus.m_results.showneffects_showall;
                        if CONN_h.menus.m_results.showneffects_showall, CONN_h.menus.m_results.showneffects=1:numel(tnames);
                        else CONN_h.menus.m_results.showneffects=find(cellfun(@(x)isempty(regexp(x,'^Dynamic |^_')),tnames));
                        end
                        set(CONN_h.menus.m_results_00{11},'string',conn_strexpand(CONN_x.Setup.l2covariates.names(CONN_h.menus.m_results.showneffects),CONN_x.Setup.l2covariates.descrip(CONN_h.menus.m_results.showneffects)));
                        [ok1,tempcovariates]=ismember(ncovariates,CONN_h.menus.m_results.showneffects);
                        if ~all(ok1), set(CONN_h.menus.m_results_00{11},'value',1);set(CONN_h.menus.m_results_00{16},'string','1');
                        else set(CONN_h.menus.m_results_00{11},'value',tempcovariates);
                        end
                        hc1=get(CONN_h.menus.m_results_00{11},'uicontextmenu');
                        if CONN_h.menus.m_results.showneffects_showall, set(get(hc1,'children'),'label','Hide secondary variables');
                        else set(get(hc1,'children'),'Label','Show secondary variables');
                        end
						model=2;modelroi=1;
                    case 44
                        if ~isempty(CONN_h.menus.m_results.y.data)&&~conn_surf_dimscheck(CONN_h.menus.m_results.Y(1).dim),
                            temp=reshape(permute(CONN_h.menus.m_results.y.data(CONN_h.menus.m_results.design.subjects,:,:,:),[2,1,3,4]),CONN_h.menus.m_results.Y(1).dim(1),CONN_h.menus.m_results.Y(1).dim(2),1,[]);
                            temp=permute(temp(end:-1:1,end:-1:1,:,:),[2,1,3,4]);
                            fh=conn_montage_display(temp,CONN_h.menus.m_results.design.data);
                            varargout={fh};
                        end
                        return
				end
			end
			ncovariates=get(CONN_h.menus.m_results_00{11},'value');
            ncovariates=CONN_h.menus.m_results.showneffects(ncovariates);
            if isempty(CONN_h.menus.m_results.shownconditions), conn_msgbox({'Not ready to display second-level Analyses',' ','No conditions found. Please re-run first-level analyses'},'',2); return; end
			nconditions=get(CONN_h.menus.m_results_00{12},'value');
            nconditions=CONN_h.menus.m_results.shownconditions(nconditions);
            if isempty(CONN_h.menus.m_results.shownsources), return; end
			isources=get(CONN_h.menus.m_results_00{13},'value');
            nsources=CONN_h.menus.m_results.shownsources(isources);
			modeltype=1;%get(CONN_h.menus.m_results_00{21},'value');
            conn_contrasthelp(CONN_h.menus.m_results_00{16},'subject effects',CONN_x.Setup.l2covariates.names(1:end-1),ncovariates,all(ismember(CONN_h.menus.m_results.X(:,ncovariates),[0 1]),1)+2*all(ismember(CONN_h.menus.m_results.X(:,ncovariates),[-1 1]),1));
            conn_contrasthelp(CONN_h.menus.m_results_00{19},'conditions',CONN_x.Setup.conditions.names(1:end-1),nconditions,[]);
            conn_contrasthelp(CONN_h.menus.m_results_00{17},'seeds/sources',get(CONN_h.menus.m_results_00{13},'string'),isources,[]);

            %set([CONN_h.menus.m_results_00{24},CONN_h.menus.m_results_00{15},CONN_h.menus.m_results_00{23}],'visible','off');
%             if (state==2||state==3)&&model==1,%&&CONN_x.Setup.normalized&&any(CONN_x.Setup.steps([2,3])),%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
%                 MDok=conn_checkmissingdata(state,nconditions,nsources);
%                 xf=CONN_h.menus.m_results.X;
%                 yf=CONN_h.menus.m_results.y.data;
%                 nsubjects=find(any(xf~=0,2)&~any(isnan(xf),2)&MDok);
%                 xf=xf(nsubjects,:);
%                 if ~isempty(yf)
%                     yf=yf(nsubjects,:);
%                     if modeltype==1, [CONN_h.menus.m_results.B,CONN_h.menus.m_results.opt]=conn_glmunivariate('estimate',xf,yf);
%                     else [CONN_h.menus.m_results.B,CONN_h.menus.m_results.opt]=conn_glmunivariate('estimatefixed',xf,yf,CONN_h.menus.m_results.se); end
%                 end
%                 CONN_h.menus.m_results.ncovariates=1:size(xf,2);
%                 CONN_x.Results.xX.X=xf;
%             elseif (state==1)&&model==1,
%                 xf=CONN_h.menus.m_results.X;
%                 nsubjects=find(any(xf~=0,2)&~any(isnan(xf),2));
%                 xf=xf(nsubjects,:);
%                 CONN_h.menus.m_results.ncovariates=1:size(xf,2);
%                 CONN_x.Results.xX.X=xf;
%             end
            if model
                idx=ncovariates;
                if 1,%~isempty(idx),
                    CONN_x.Results.xX.nsubjecteffects=ncovariates;
                    CONN_x.Results.xX.nsubjecteffectsbyname=CONN_x.Setup.l2covariates.names(ncovariates);
                    CONN_x.Results.xX.nconditions=nconditions;
                    CONN_x.Results.xX.nconditionsbyname=CONN_x.Setup.conditions.names(nconditions);
                    txt=get(CONN_h.menus.m_results_00{16},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{16},'string',mat2str(value)); catch, value=[]; end; end;
                    CONN_x.Results.xX.csubjecteffects=value;
                    txt=get(CONN_h.menus.m_results_00{17},'string'); value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{17},'string',mat2str(value)); catch, value=[]; end; end;
                    if state==1||state==2
                        CONN_x.Results.xX.nsources=nsources;
                        CONN_x.Results.xX.csources=value;
                        CONN_x.Results.xX.nsourcesbyname=CONN_h.menus.m_results.outcomenames(nsources);
                    else
                        CONN_x.Results.xX.nmeasures=nsources;
                        CONN_x.Results.xX.cmeasures=value;
                        CONN_x.Results.xX.nmeasuresbyname=conn_v2v('cleartext',CONN_h.menus.m_results.outcomenames(nsources));
                    end
                    txt=get(CONN_h.menus.m_results_00{19},'string'); 
                    if isequal(txt,'var'), value=txt; 
                    else value=str2num(txt); if isempty(value), try value=evalin('base',txt); set(CONN_h.menus.m_results_00{19},'string',mat2str(value)); catch, value=[]; end; end;
                    end
                    CONN_x.Results.xX.cconditions=value;
                    CONN_x.Results.xX.modeltype=modeltype;
                    %if state==1||state==2, CONN_h.menus.m_results.design.contrast_measures=kron(CONN_x.Results.xX.cconditions,CONN_x.Results.xX.csources);
                    %else CONN_h.menus.m_results.design.contrast_measures=kron(CONN_x.Results.xX.cconditions,CONN_x.Results.xX.cmeasures);
                    %end
                    CONN_h.menus.m_results.design.contrast_between=CONN_x.Results.xX.csubjecteffects;
                    [doexist,doexisti]=conn_contrastmanager('check');
                    if doexist, set(CONN_h.menus.m_results_00{21},'value',doexisti+1);
                    else set(CONN_h.menus.m_results_00{21},'value',1);
                    end

                    if (state==2||state==3),%&&CONN_x.Setup.normalized&&any(CONN_x.Setup.steps([2,3])),%(~isfield(CONN_x.Setup,'doROIonly')||~CONN_x.Setup.doROIonly),
                        if model==1 || length(idx)~=length(CONN_h.menus.m_results.ncovariates) || any(idx~=CONN_h.menus.m_results.ncovariates),
                            if ~isfield(CONN_h.menus.m_results.y,'MDok')||isempty(CONN_h.menus.m_results.y.MDok), CONN_h.menus.m_results.y.MDok=conn_checkmissingdata(state,nconditions,nsources); end
                            MDok=CONN_h.menus.m_results.y.MDok;
                            xf=CONN_h.menus.m_results.X(:,idx);
                            yf=CONN_h.menus.m_results.y.data;
                            %                             se=CONN_h.menus.m_results.se;
                            nsubjects=find(any(xf~=0,2)&~any(isnan(xf),2)&MDok);
                            xf=xf(nsubjects,:);
                            if ~isempty(yf)&&~isequal(yf,0)
                                yf=yf(nsubjects,:);
                                if modeltype==1, [CONN_h.menus.m_results.B,CONN_h.menus.m_results.opt]=conn_glmunivariate('estimate',xf,yf);
                                else  [CONN_h.menus.m_results.B,CONN_h.menus.m_results.opt]=conn_glmunivariate('estimatefixed',xf,yf,se); end
                            end
                            CONN_h.menus.m_results.ncovariates=idx;
                            CONN_x.Results.xX.X=xf;
                            CONN_h.menus.m_results.design.data=cell(numel(nsubjects),size(CONN_h.menus.m_results.design.Yweight,3));
                            CONN_h.menus.m_results.design.dataTitle=cell(1,size(CONN_h.menus.m_results.design.Yweight,3));
                            for n1=1:size(CONN_h.menus.m_results.design.Yweight,3)
                                Yweight=CONN_h.menus.m_results.design.Yweight(:,:,n1);
                                for n2=reshape(find(Yweight),1,[])
                                    CONN_h.menus.m_results.design.data(:,n1)=strcat(CONN_h.menus.m_results.design.data(:,n1),regexprep(CONN_h.menus.m_results.design.Y(nsubjects,n2),{'^.*[\\\/](.*)',' \+1 \*',' \-1 \*'},{sprintf(' %+g * $1',Yweight(n2)),' +',' -'}));
                                    CONN_h.menus.m_results.design.dataTitle(n1)=strcat(CONN_h.menus.m_results.design.dataTitle(n1),regexprep(CONN_h.menus.m_results.design.Ytitle(n2),{'^(.*)',' \+1 \*',' \-1 \*'},{sprintf(' %+g * $1',Yweight(n2)),' +',' -'}));
                                end
                            end
                            [nill,CONN_h.menus.m_results.design.contrast_within]=conn_mtxbase(reshape(CONN_h.menus.m_results.design.Yweight,[],size(CONN_h.menus.m_results.design.Yweight,3))');
                            CONN_h.menus.m_results.design.designmultivariateonly=0;
                            CONN_h.menus.m_results.design.designmatrix=xf;
                            CONN_h.menus.m_results.design.designmatrix_name=CONN_x.Setup.l2covariates.names(idx);
                            CONN_h.menus.m_results.design.subjects=nsubjects;
                        end
                        %if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2])&&CONN_x.Results.xX.displayvoxels==1, CONN_x.Results.xX.displayvoxels=2; set(CONN_h.menus.m_results_00{32},'value',CONN_x.Results.xX.displayvoxels); end % note: temporarily disable indiv-contrast functionality for surface-based results
                        if ~isempty(CONN_h.menus.m_results.y.data),%&&size(CONN_x.Results.xX.csubjecteffects,1)==1
                            CONN_h.menus.m_results.y.displayvoxels=CONN_x.Results.xX.displayvoxels;
                            if CONN_x.Results.xX.displayvoxels==2, 
                                [nill,base]=conn_mtxbase(CONN_h.menus.m_results.y.M);
                                yf=permute(reshape(CONN_h.menus.m_results.opt.Y,size(CONN_h.menus.m_results.opt.Y,1),[],size(CONN_h.menus.m_results.y.data,4)),[1,3,2]);
                                yf=yf(:,find(any(base,2)),:);
                                [h,F,p,dof,statsname]=conn_glm(CONN_h.menus.m_results.opt.X,yf,CONN_x.Results.xX.csubjecteffects);
                                h=reshape(permute(h,[1,3,2]),size(h,1),[]);F=reshape(permute(F,[1,3,2]),size(F,1),[]);p=reshape(permute(p,[1,3,2]),size(p,1),[]);
                                if numel(dof)==1, dof=[1,dof]; end
                            elseif modeltype==1, [h,F,p,dof,R,statsname]=conn_glmunivariate('evaluate',CONN_h.menus.m_results.opt,[],CONN_x.Results.xX.csubjecteffects);
                            else  [h,F,p,dof,R,statsname]=conn_glmunivariate('evaluatefixed',CONN_h.menus.m_results.opt,[],CONN_x.Results.xX.csubjecteffects);
                            end
                            if isequal(statsname,'T'), p=2*min(p,1-p); end
                            if CONN_x.Setup.nsubjects==1,
                                if isequal(size(p),size(h)), p(h~=0)=.5;
                                else p=.5+zeros(size(p));
                                end
                            end
%                             if state==2
%                                 switch(CONN_x.Analyses(ianalysis).measure),
%                                     case {1,2}, % correlation
%                                         S1=tanh(h); S2=p; 
%                                     otherwise, % regression
%                                         S1=h; S2=p;
%                                 end
%                             else
%                                 S1=h;
%                                 S2=p; 
%                             end
                            S1=F';
                            S2=p';
                            
                            if CONN_x.Results.xX.displayvoxels==1&&(size(S1,2)>1||size(CONN_h.menus.m_results.y.data,4)>1), set(CONN_h.menus.m_results_00{24},'string','(individual contrasts) p-uncorrected <');
                            else set(CONN_h.menus.m_results_00{24},'string','                       p-uncorrected <');
                            end
                            CONN_h.menus.m_results.y.condname={};
                            for n1=1:size(CONN_x.Results.xX.csubjecteffects,1)
                                tidx=find(CONN_x.Results.xX.csubjecteffects(n1,:));
                                CONN_h.menus.m_results.y.condname{n1}='';
                                if numel(tidx)==1&&CONN_x.Results.xX.csubjecteffects(n1,tidx)==1
                                    CONN_h.menus.m_results.y.condname{n1}=CONN_x.Setup.l2covariates.names{CONN_x.Results.xX.nsubjecteffects(tidx)};
                                else
                                    for n2=1:numel(tidx)
                                        CONN_h.menus.m_results.y.condname{n1}=[CONN_h.menus.m_results.y.condname{n1},regexprep(sprintf(' %+g*%s',CONN_x.Results.xX.csubjecteffects(n1,tidx(n2)), CONN_x.Setup.l2covariates.names{CONN_x.Results.xX.nsubjecteffects(tidx(n2))}),{'\+1\*','\-1\*'},{'+','-'})];
                                    end
                                end
                            end
                            
                            if conn_surf_dimscheck(CONN_h.menus.m_results.Y(1).dim), %if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2]),
                                if ~CONN_h.menus.m_results_surfhires
                                    t1=reshape(S1,size(CONN_gui.refs.surf.defaultreduced(1).vertices,1),2,1,[]);
                                    t2=reshape(S2,size(CONN_gui.refs.surf.defaultreduced(1).vertices,1),2,1,[]);
                                    conn_menu('update',CONN_h.menus.m_results_00{14},{CONN_gui.refs.surf.defaultreduced,t1,-t2},{CONN_h.menus.m_results.Y(1),CONN_h.menus.m_results.y.slice});
                                    conn_menu('update',CONN_h.menus.m_results_00{29},[]);
                                else
                                    t1=reshape(S1,size(CONN_gui.refs.surf.default(1).vertices,1),2,1,[]);
                                    t2=reshape(S2,size(CONN_gui.refs.surf.default(1).vertices,1),2,1,[]);
                                    conn_menu('update',CONN_h.menus.m_results_00{14},{CONN_gui.refs.surf.default,t1,-t2},{CONN_h.menus.m_results.Y(1),CONN_h.menus.m_results.y.slice});
                                    conn_menu('update',CONN_h.menus.m_results_00{29},[]);
                                end
                                set([CONN_h.menus.m_results_00{24}],'visible','on');
                            else
                                t1=reshape(S1,CONN_h.menus.m_results.Y(1).dim(1),CONN_h.menus.m_results.Y(1).dim(2),1,[]); %size(CONN_h.menus.m_results.y.data,4)*size(S1,2));
                                t2=reshape(S2,CONN_h.menus.m_results.Y(1).dim(1),CONN_h.menus.m_results.Y(1).dim(2),1,[]); %size(CONN_h.menus.m_results.y.data,4)*size(S2,2));
                                t1=permute(t1,[2,1,3,4]);
                                t2=permute(t2,[2,1,3,4]);
                                set(CONN_h.menus.m_results_00{14}.h9,'string',num2str(max(t1(:))));
                                conn_menu('update',CONN_h.menus.m_results_00{14},{CONN_h.menus.m_results.Xs,t1,-t2},{CONN_h.menus.m_results.Y(1),CONN_h.menus.m_results.y.slice});
                                %                         conn_menu('update',CONN_h.menus.m_results_00{14},{CONN_h.menus.m_results.Xs,t1,-t2},{CONN_h.menus.m_results.Y.matdim,CONN_h.menus.m_results.y.slice})
                                set([CONN_h.menus.m_results_00{24}],'visible','on');
                                conn_callbackdisplay_secondlevelclick;
                                %set([CONN_h.menus.m_results_00{15}],'visible','on');
                                hc1=uicontextmenu;uimenu(hc1,'Label','Change background anatomical image','callback','conn(''background_image'');conn gui_results;');uimenu(hc1,'Label','Change background reference rois','callback','conn(''background_rois'');');set(CONN_h.menus.m_results_00{14}.h2,'uicontextmenu',hc1);
                            end
                            
                            conn_menu('updatecscale',[],[],CONN_h.menus.m_results_00{14}.h9);
                            if conn_surf_dimscheck(CONN_h.menus.m_results.Y(1).dim)&&~CONN_h.menus.m_results_surfhires, %if isequal(CONN_h.menus.m_results.Y(1).dim,conn_surf_dims(8).*[1 1 2])&&~CONN_h.menus.m_results_surfhires, 
                                strstr3={'Results low-res preview (individual contrasts)','Results low-res preview (full model)','Do not show analysis results preview'};%,'Results whole-brain (full model)'};
                            else 
                                strstr3={'Results preview (individual contrasts)','Results preview (full model)','Do not show analysis results preview'};%,'Results whole-brain (full model)'};
                            end
                            set(CONN_h.menus.m_results_00{32},'string',strstr3,'value',CONN_x.Results.xX.displayvoxels);
                            if ~strcmp(statsname,'T'), strdof=[statsname,'(',num2str(dof(1)),',',num2str(dof(2)),')'];
                            else strdof=[statsname,'(',num2str(dof(end)),')'];
                            end
                            strwarn='design'; try, if any(dof<=0)||max(abs(1-CONN_x.Results.xX.X*(pinv(CONN_x.Results.xX.X)*ones(size(CONN_x.Results.xX.X,1),1))))>1e-6, strwarn='WARNING!'; end; end
                            set(CONN_h.menus.m_results_00{23},'string',sprintf('%s (n=%d)',strwarn,size(CONN_x.Results.xX.X,1)),'horizontalalignment','right');
                            if xor(strcmp(strwarn,'design'),isequal(get(CONN_h.menus.m_results_00{23},'backgroundcolor'),CONN_gui.backgroundcolorA)), set(CONN_h.menus.m_results_00{23},'backgroundcolor',CONN_gui.backgroundcolorA+(~strcmp(strwarn,'design'))*(-.25*CONN_gui.backgroundcolorA+.25*[1 0 0])); end
                        else
                            if CONN_x.Results.xX.displayvoxels<=2
                                set(CONN_h.menus.m_results_00{32},'string',{'preview not available - select results explorer'},'value',1);
                            end
                            conn_menu('update',CONN_h.menus.m_results_00{14},[]);
                            set([CONN_h.menus.m_results_00{24},CONN_h.menus.m_results_00{15}],'visible','off');
                            strwarn='design'; try, if any(dof<=0)||max(abs(1-CONN_x.Results.xX.X*(pinv(CONN_x.Results.xX.X)*ones(size(CONN_x.Results.xX.X,1),1))))>1e-6, strwarn='WARNING!'; end; end
                            set(CONN_h.menus.m_results_00{23},'string',sprintf('%s (n=%d)',strwarn,size(CONN_x.Results.xX.X,1)),'horizontalalignment','right');
                            if xor(strcmp(strwarn,'design'),isequal(get(CONN_h.menus.m_results_00{23},'backgroundcolor'),CONN_gui.backgroundcolorA)), set(CONN_h.menus.m_results_00{23},'backgroundcolor',CONN_gui.backgroundcolorA+(~strcmp(strwarn,'design'))*(-.25*CONN_gui.backgroundcolorA+.25*[1 0 0])); end
                            conn_menu('update',CONN_h.menus.m_results_00{29},[]);
                        end
                    end
                end
            else conn_callbackdisplay_secondlevelclick;
            end
            roierr=false;
            if modelroi&&state==1, % ROI-level
                if isfield(CONN_h.menus.m_results,'roiresults')&&isfield(CONN_h.menus.m_results.roiresults,'lastselected'), bakroiresultsidx=CONN_h.menus.m_results.roiresults.lastselected; else bakroiresultsidx=[]; end
                CONN_h.menus.m_results.roiresults=conn_process('results_ROI',CONN_x.Results.xX.nsources,CONN_x.Results.xX.csources);
                CONN_h.menus.m_results.design.contrast_within=CONN_h.menus.m_results.roiresults.c2;
                CONN_h.menus.m_results.design.contrast_between=CONN_h.menus.m_results.roiresults.c;
                CONN_h.menus.m_results.design.designmultivariateonly=1;
                CONN_h.menus.m_results.design.designmatrix=CONN_h.menus.m_results.roiresults.xX.X;
                CONN_h.menus.m_results.design.subjects=find(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects);
                CONN_h.menus.m_results.design.data=repmat(arrayfun(@(n)sprintf('subject%03d: ',n),reshape(find(CONN_h.menus.m_results.roiresults.xX.SelectedSubjects),[],1),'uni',0),[1,numel(CONN_h.menus.m_results.roiresults.orig_sources),numel(CONN_h.menus.m_results.roiresults.orig_conditions)]);
                CONN_h.menus.m_results.design.dataTitle=cell([1,numel(CONN_h.menus.m_results.roiresults.orig_sources),numel(CONN_h.menus.m_results.roiresults.orig_conditions)]);
                for n2=1:numel(CONN_h.menus.m_results.roiresults.orig_conditions)
                    for n1=1:numel(CONN_h.menus.m_results.roiresults.orig_sources)
                        CONN_h.menus.m_results.design.data(:,n1,n2)=strcat(CONN_h.menus.m_results.design.data(:,n1,n2),repmat({[CONN_h.menus.m_results.roiresults.orig_sources{n1},' @ ',CONN_h.menus.m_results.roiresults.orig_conditions{n2}]},size(CONN_h.menus.m_results.design.data,1),1));
                        CONN_h.menus.m_results.design.dataTitle(1,n1,n2)=strcat(CONN_h.menus.m_results.design.dataTitle(1,n1,n2),{[CONN_h.menus.m_results.roiresults.orig_sources{n1},' @ ',CONN_h.menus.m_results.roiresults.orig_conditions{n2}]});
                    end
                end
                CONN_h.menus.m_results.design.data=CONN_h.menus.m_results.design.data(:,:);
                CONN_h.menus.m_results.design.dataTitle=CONN_h.menus.m_results.design.dataTitle(:,:);
%                 for n1=1:size(CONN_h.menus.m_results.roiresults.c2,2)
%                     [n2i,n2j]=ndgrid(1:numel(CONN_h.menus.m_results.roiresults.orig_sources),1:numel(CONN_h.menus.m_results.roiresults.orig_conditions));
%                     for n2=reshape(find(CONN_h.menus.m_results.roiresults.c2(n1,:)),1,[])
%                         CONN_h.menus.m_results.design.data(:,n1)=strcat(CONN_h.menus.m_results.design.data(:,n1),regexprep(sprintf(' %+g * %s@%s ',CONN_h.menus.m_results.roiresults.c2(n1,n2),CONN_h.menus.m_results.roiresults.orig_sources{n2i(n2)},CONN_h.menus.m_results.roiresults.orig_conditions{n2j(n2)}),{' \+1 \*',' \-1 \*'},{' +',' -'}));
%                     end
%                 end
%                 try, CONN_h.menus.m_results.roiresults=conn_process('results_ROI',CONN_x.Results.xX.nsources,CONN_x.Results.xX.csources);
%                 catch, 
%                     roierr=true;
%                     uiwait(errordlg('Some conditions have not been processed yet. Re-run previous step (First-level analyses)','Data not prepared for analyses'));
%                 end
                if ~roierr
                    if isequal(CONN_h.menus.m_results.roiresults.statsname,'T')
                        set(CONN_h.menus.m_results_00{28},'visible','on');
                        switch CONN_x.Results.xX.inferencetype
                            case 1, CONN_h.menus.m_results.roiresults.p=2*min(CONN_h.menus.m_results.roiresults.p,1-CONN_h.menus.m_results.roiresults.p);
                            case 2,
                            case 3, CONN_h.menus.m_results.roiresults.p=1-CONN_h.menus.m_results.roiresults.p;
                        end
                    else
                        set(CONN_h.menus.m_results_00{28},'visible','off');
                    end
                    switch CONN_x.Results.xX.displayrois
                        case 1, CONN_x.Results.xX.roiselected2=1:numel(CONN_h.menus.m_results.roiresults.names2);
                        case 2, CONN_x.Results.xX.roiselected2=1:numel(CONN_h.menus.m_results.roiresults.names);
                        case 3, 
                            if isfield(CONN_x.Results.xX,'roiselected2byname')
                                [ok,tidx]=ismember(CONN_x.Results.xX.roiselected2byname,CONN_h.menus.m_results.roiresults.names2);
                                if all(ok), CONN_x.Results.xX.roiselected2=tidx;
                                else CONN_gui.warnloadbookmark{end+1}='warning: unable to select previous-design target ROIs'; 
                                end
                            end
                    end
                    if ~isfield(CONN_x.Results.xX,'roiselected2')||isempty(CONN_x.Results.xX.roiselected2)||any(CONN_x.Results.xX.roiselected2>numel(CONN_h.menus.m_results.roiresults.names2)), CONN_x.Results.xX.roiselected2=1:numel(CONN_h.menus.m_results.roiresults.names2); end
                    CONN_x.Results.xX.roiselected2byname=CONN_h.menus.m_results.roiresults.names2(CONN_x.Results.xX.roiselected2);
                    CONN_h.menus.m_results.roiresults.P=nan(size(CONN_h.menus.m_results.roiresults.p));
                    CONN_h.menus.m_results.roiresults.P(CONN_x.Results.xX.roiselected2)=conn_fdr(CONN_h.menus.m_results.roiresults.p(CONN_x.Results.xX.roiselected2),2);
                    switch CONN_x.Results.xX.inferenceleveltype
                        case 1, CONN_h.menus.m_results.roiresults.Pthr=CONN_h.menus.m_results.roiresults.P;
                        case 2, CONN_h.menus.m_results.roiresults.Pthr=CONN_h.menus.m_results.roiresults.p;
                    end
                    if size(CONN_h.menus.m_results.roiresults.dof,2)>1
                        set(CONN_h.menus.m_results_00{22},'string',sprintf('%-38s%10s%10s%10s%10s','Targets','beta',[CONN_h.menus.m_results.roiresults.statsname,'(',num2str(CONN_h.menus.m_results.roiresults.dof(1)),',',num2str(CONN_h.menus.m_results.roiresults.dof(2)),')'],'p-unc','p-FDR'));
                    else
                        set(CONN_h.menus.m_results_00{22},'string',sprintf('%-38s%10s%10s%10s%10s','Targets','beta',[CONN_h.menus.m_results.roiresults.statsname,'(',num2str(CONN_h.menus.m_results.roiresults.dof(1)),')'],'p-unc','p-FDR'));
                    end
                    [nill,CONN_h.menus.m_results.roiresults.idx]=sort(CONN_h.menus.m_results.roiresults.P(CONN_x.Results.xX.roiselected2)-1e-10*abs(CONN_h.menus.m_results.roiresults.F(CONN_x.Results.xX.roiselected2)));
                    CONN_h.menus.m_results.roiresults.idx=CONN_x.Results.xX.roiselected2(CONN_h.menus.m_results.roiresults.idx);
                    txt=[];
                    for n1=1:numel(CONN_h.menus.m_results.roiresults.idx),
                        n2=CONN_h.menus.m_results.roiresults.idx(n1);
                        tmp=CONN_h.menus.m_results.roiresults.names2{n2};if length(tmp)>38,tmp=[tmp(1:38-5),'*',tmp(end-3:end)]; end;
                        txt=strvcat(txt,...
                            [[sprintf('%-38s',tmp)],...
                            [sprintf('%10.2f',CONN_h.menus.m_results.roiresults.h(n2))],...
                            [sprintf('%10.2f',CONN_h.menus.m_results.roiresults.F(n2))],...
                            [sprintf('%10f',CONN_h.menus.m_results.roiresults.p(n2))],...
                            [sprintf('%10f',CONN_h.menus.m_results.roiresults.P(n2))]]);
                    end;
                    if ~isempty(txt)
                        parse_html=regexprep(CONN_gui.parse_html,{'<HTML>','</HTML>'},{'<HTML><pre>','</pre></HTML>'});
                        txt=cellstr(txt);
                        ntemp=~(CONN_h.menus.m_results.roiresults.Pthr(CONN_h.menus.m_results.roiresults.idx)<CONN_x.Results.xX.inferencelevel);
                        txt(ntemp)=cellfun(@(x)[parse_html{1},x,parse_html{2}],txt(ntemp),'uni',0);
                        txt=char(txt);
                    end
                    listboxtop=get(CONN_h.menus.m_results_00{18},'listboxtop');
                    if isempty(bakroiresultsidx), txtok=[]; 
                    else [txtok,txtidx]=ismember(bakroiresultsidx,CONN_h.menus.m_results.roiresults.idx);
                    end
                    if any(txtok), txtval=min(txtidx(txtok),size(txt,1));  
                    else txtval=min(get(CONN_h.menus.m_results_00{18},'value'),size(txt,1));
                    end
                    if ~isempty(txtval)&&~ismember(listboxtop,min(txtval)+(-10:0)), listboxtop=max(1,min(size(txt,1),min(txtval)-2)); end
                    set(CONN_h.menus.m_results_00{18},'string',txt,'value',txtval,'ListboxTop',listboxtop);
                    if get(CONN_h.menus.m_results_00{18},'listboxtop')>size(txt,1), warning('off','MATLAB:hg:uicontrol:ListboxTopMustBeWithinStringRange'); drawnow; warning('on','MATLAB:hg:uicontrol:ListboxTopMustBeWithinStringRange'); set(CONN_h.menus.m_results_00{18},'listboxtop',1); end
                    if size(CONN_h.menus.m_results.roiresults.dof,2)>1, strdof=[CONN_h.menus.m_results.roiresults.statsname,'(',num2str(CONN_h.menus.m_results.roiresults.dof(1)),',',num2str(CONN_h.menus.m_results.roiresults.dof(2)),')'];
                    else strdof=[CONN_h.menus.m_results.roiresults.statsname,'(',num2str(CONN_h.menus.m_results.roiresults.dof(1)),')'];
                    end
                    strwarn='design'; try, if max(abs(1-CONN_h.menus.m_results.roiresults.xX.X*(pinv(CONN_h.menus.m_results.roiresults.xX.X)*ones(size(CONN_h.menus.m_results.roiresults.xX.X,1),1))))>1e-6, strwarn='WARNING!'; end; end
                    set(CONN_h.menus.m_results_00{23},'string',sprintf('%s (n=%d)',strwarn,size(CONN_h.menus.m_results.roiresults.xX.X,1)),'horizontalalignment','right');
                else
                    set(CONN_h.menus.m_results_00{18},'string',[],'value',1,'listboxtop',1);
                    set(CONN_h.menus.m_results_00{23},'string','');
                end
            end
            if state==1, % ROI-level plots
                idxplotroi=ishandle(CONN_h.menus.m_results_00{26});
                tobedeleted=CONN_h.menus.m_results_00{26}(idxplotroi);
                CONN_h.menus.m_results_00{26}=[];
                if ~roierr
                    xtemp=cos((0:32)'/16*pi);ytemp=sin((0:32)'/16*pi);
                    axes(CONN_h.menus.m_results_00{25}); %hold on;
                    ntarget=get(CONN_h.menus.m_results_00{18},'value');
                    ntarget=CONN_h.menus.m_results.roiresults.idx(ntarget);
                    CONN_h.menus.m_results.roiresults.lastselected=ntarget;
                    ntemp=find(CONN_h.menus.m_results.roiresults.Pthr(CONN_x.Results.xX.roiselected2)<CONN_x.Results.xX.inferencelevel);
                    ntemp=CONN_x.Results.xX.roiselected2(ntemp);
                    wtemp=-log10(max(1e-8,CONN_h.menus.m_results.roiresults.p(ntemp)))/8;
                    wtemp=.25+.75*max(.1,wtemp/max(eps,max(wtemp)));
                    %ctemp=.75+.25*(CONN_h.menus.m_results.roiresults.P(ntemp)<.05);
                    if isempty(wtemp),wtemp=1;ctemp=0;end
                    scaleref=sqrt(norm(CONN_h.menus.m_results.xsen1n2(1:2)));
                    CONN_h.menus.m_results.roiresults.displayrois=[];
                    CONN_h.menus.m_results.roiresults.displayroisnames={};
                    xepos=[]; xeneg=[];
                    if 0,
                        ntemp2=find(CONN_h.menus.m_results.roiresults.h(ntemp)>0|CONN_h.menus.m_results.roiresults.h(ntemp)<0);
                        if ~isempty(ntemp2)&&~isempty(nsources)
                            xyz2=pinv(CONN_gui.refs.canonical.V.mat)*[cat(1,CONN_h.menus.m_results.roiresults.xyz2{ntemp(ntemp2)}),ones(numel(ntemp2),1)]';
                            xyz2(isnan(xyz2))=1;
                            xyz2=conn_menu_montage('xyz2coords',CONN_h.menus.m_results.xsen1n2,CONN_h.menus.m_results.xseM*xyz2);
                            xyz1=pinv(CONN_gui.refs.canonical.V.mat)*[cat(1,CONN_h.menus.m_results.roiresults.xyz{nsources}),ones(numel(nsources),1)]';
                            xyz1(isnan(xyz1))=1;
                            xyz1=conn_menu_montage('xyz2coords',CONN_h.menus.m_results.xsen1n2,CONN_h.menus.m_results.xseM*xyz1);
                            if ~isempty(ntarget), xemph=ismember(ntemp(ntemp2),ntarget);
                            else xemph=[];
                            end
                            xpos=[]; xneg=[]; 
                            b=mean(mean(CONN_h.menus.m_results.roiresults.B(:,:,:,ntemp(ntemp2)),2),3); 
                            b=b/max(eps,max(abs(b(:))));
                            for n1=1:size(xyz1,2)
                                [connx0,conny0]=conn_menu_montage('plotline',CONN_h.menus.m_results.xsen1n2,repmat(xyz1(:,n1),1,size(xyz2,2)),xyz2,max(.2,1/CONN_h.menus.m_results.xsen1n2(6)));
                                ntemp3=find(b(n1,:)>0); c=[1 0 0];
                                t=[connx0(:,ntemp3) conny0(:,ntemp3); nan(1,2*numel(ntemp3))];
                                xpos=[xpos; reshape(t,[],2)]; 
                                if ~isempty(xemph), xepos=[xepos; reshape(t(:,[xemph(ntemp3) xemph(ntemp3)]),[],2)]; end
                                ntemp3=find(b(n1,:)<0); c=[0 0 1];
                                t=[connx0(:,ntemp3) conny0(:,ntemp3); nan(1,2*numel(ntemp3))];
                                xneg=[xneg; reshape(t,[],2)]; 
                                if ~isempty(xemph), xeneg=[xeneg; reshape(t(:,[xemph(ntemp3) xemph(ntemp3)]),[],2)]; end
                            end
                            hold on; 
                            if ~isempty(xpos)
                                ht=plot(xpos(:,1),xpos(:,2),'r-','color',[1 0 0],'linewidth',2);%/2+CONN_gui.backgroundcolor/2);
                                CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},ht(:)');
                            end
                            if ~isempty(xneg)
                                ht=plot(xneg(:,1),xneg(:,2),'b-','color',[0 0 1],'linewidth',2);%/2+CONN_gui.backgroundcolor/2);
                                CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},ht(:)');
                            end
                            hold off;
                        end
                    end
                    ntemp2=find(CONN_h.menus.m_results.roiresults.h(ntemp)<0); % negative
                    if ~isempty(ntemp2)
                        xyz=pinv(CONN_gui.refs.canonical.V.mat)*[cat(1,CONN_h.menus.m_results.roiresults.xyz2{ntemp(ntemp2)}),ones(numel(ntemp2),1)]';
                        [nill,idxsort]=sort(xyz(3,:));
                        xyz(1:2,:)=conn_menu_montage('xyz2coords',CONN_h.menus.m_results.xsen1n2,CONN_h.menus.m_results.xseM*xyz);
                        for niplot=8:-1:1, CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(conn_bsxfun(@plus,xyz(1,idxsort),conn_bsxfun(@times,niplot/9*3*scaleref*wtemp(ntemp2(idxsort)),xtemp)),conn_bsxfun(@plus,xyz(2,idxsort),conn_bsxfun(@times,niplot/9*3*scaleref*wtemp(ntemp2(idxsort)),ytemp)),ones(numel(xtemp),1)*xyz(3,idxsort),'b','facecolor',min(1,4*[.25 .25 1]*(1-niplot/9)),'edgecolor','none','facealpha',.95+0*(1-niplot/9)^1)); end
                        %CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(conn_bsxfun(@plus,xyz(1,idxsort),conn_bsxfun(@times,0+3*scaleref*wtemp(ntemp2(idxsort)),xtemp)),conn_bsxfun(@plus,xyz(2,idxsort),conn_bsxfun(@times,0+3*scaleref*wtemp(ntemp2(idxsort)),ytemp)),'b','facecolor',[.25 .25 1],'edgecolor','none','facealpha',.75));
                        CONN_h.menus.m_results.roiresults.displayrois=cat(1,CONN_h.menus.m_results.roiresults.displayrois,...
                            [cat(1,CONN_h.menus.m_results.roiresults.xyz2{ntemp(ntemp2)}),2*3*scaleref*wtemp(ntemp2)',-ones(numel(ntemp2),1), xyz(1:2,:)', reshape(ntemp(ntemp2),[],1)]); %, reshape(mean(mean(CONN_h.menus.m_results.roiresults.B(:,:,:,ntemp(ntemp2)),2),3),[],numel(ntemp2))']);
                        CONN_h.menus.m_results.roiresults.displayroisnames=cat(2,CONN_h.menus.m_results.roiresults.displayroisnames,CONN_h.menus.m_results.roiresults.names2(ntemp(ntemp2)));
                        %CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(bsxfun(@plus,xyz(1,:),bsxfun(@times,0+3*scaleref*wtemp(ntemp2),xtemp)),bsxfun(@plus,xyz(2,:),bsxfun(@times,0+3*scaleref*wtemp(ntemp2),ytemp)),bsxfun(@times,ctemp(ntemp2),shiftdim([0,0,1],-1)),'edgecolor',0*[0,0,.5]));
                    end
                    ntemp2=find(CONN_h.menus.m_results.roiresults.h(ntemp)>0); % positive
                    if ~isempty(ntemp2)
                        xyz=pinv(CONN_gui.refs.canonical.V.mat)*[cat(1,CONN_h.menus.m_results.roiresults.xyz2{ntemp(ntemp2)}),ones(numel(ntemp2),1)]';
                        [nill,idxsort]=sort(xyz(3,:));
                        xyz(1:2,:)=conn_menu_montage('xyz2coords',CONN_h.menus.m_results.xsen1n2,CONN_h.menus.m_results.xseM*xyz);
                        for niplot=8:-1:1, CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(conn_bsxfun(@plus,xyz(1,idxsort),conn_bsxfun(@times,niplot/9*3*scaleref*wtemp(ntemp2(idxsort)),xtemp)),conn_bsxfun(@plus,xyz(2,idxsort),conn_bsxfun(@times,niplot/9*3*scaleref*wtemp(ntemp2(idxsort)),ytemp)),ones(numel(xtemp),1)*xyz(3,idxsort),'r','facecolor',min(1,4*[1 .25 .25]*(1-niplot/9)),'edgecolor','none','facealpha',.95+0*(1-niplot/9)^1)); end
                        %CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(conn_bsxfun(@plus,xyz(1,idxsort),conn_bsxfun(@times,0+3*scaleref*wtemp(ntemp2(idxsort)),xtemp)),conn_bsxfun(@plus,xyz(2,idxsort),conn_bsxfun(@times,0+3*scaleref*wtemp(ntemp2(idxsort)),ytemp)),'r','edgecolor','none','facealpha',.75));
                        CONN_h.menus.m_results.roiresults.displayrois=cat(1,CONN_h.menus.m_results.roiresults.displayrois,...
                            [cat(1,CONN_h.menus.m_results.roiresults.xyz2{ntemp(ntemp2)}),2*3*scaleref*wtemp(ntemp2)',ones(numel(ntemp2),1), xyz(1:2,:)', reshape(ntemp(ntemp2),[],1)]); %, reshape(mean(mean(CONN_h.menus.m_results.roiresults.B(:,:,:,ntemp(ntemp2)),2),3),[],numel(ntemp2))']);
                        CONN_h.menus.m_results.roiresults.displayroisnames=cat(2,CONN_h.menus.m_results.roiresults.displayroisnames,CONN_h.menus.m_results.roiresults.names2(ntemp(ntemp2)));
                        %CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(bsxfun(@plus,xyz(1,:),bsxfun(@times,0+3*scaleref*wtemp(ntemp2),xtemp)),bsxfun(@plus,xyz(2,:),bsxfun(@times,0+3*scaleref*wtemp(ntemp2),ytemp)),bsxfun(@times,ctemp(ntemp2),shiftdim([1,0,0],-1)),'edgecolor',0*[.5,0,0]));
                    end
                    if ~isempty(ntarget) % targets
                        for itarget=1:numel(ntarget)
                            ntemp2=find(ntemp==ntarget(itarget),1);
                            xyz=pinv(CONN_gui.refs.canonical.V.mat)*[CONN_h.menus.m_results.roiresults.xyz2{ntarget(itarget)},1]';
                            xyz(1:2,:)=conn_menu_montage('xyz2coords',CONN_h.menus.m_results.xsen1n2,CONN_h.menus.m_results.xseM*xyz);
                            if ~isempty(ntemp2), wt2=3*wtemp(ntemp2);
                            else wt2=1;
                            end
                            %patch(xyz(1)+(0+3*scaleref*wtemp(ntemp2))*[-1 -1 1 1 nan 0 0 0 0 nan],xyz(2)+(0+3*scaleref*wtemp(ntemp2))*[0 0 0 0 nan -1 1 1 -1 nan],'k','facecolor','none','edgecolor','y','linestyle','-','linewidth',1));
                            CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},...
                                patch(xyz(1)+(0+wt2)*[-1 -1 1 1 nan 0 0 0 0 nan],xyz(2)+(0+wt2)*[0 0 0 0 nan -1 1 1 -1 nan],200*ones(1,10),'k','facecolor','none','edgecolor','w','linestyle',':','linewidth',1));
                            Cext=CONN_h.menus.m_results.roiresults.c;
                            %Cext=eye(size(CONN_h.menus.m_results.roiresults.xX.X,2));
                            %if ~isequal(CONN_h.menus.m_results.roiresults.c,eye(size(CONN_h.menus.m_results.roiresults.c,2))),
                            %    Cext=[Cext;CONN_h.menus.m_results.roiresults.c];
                            %end
                            if isfield(CONN_h.menus.m_results,'showraw')&&CONN_h.menus.m_results.showraw, Cext2=[];
                            else Cext2=CONN_h.menus.m_results.roiresults.c2; 
                            end
                            [beta.h,beta.F,beta.p,beta.dof,beta.statsname]=conn_glm(CONN_h.menus.m_results.roiresults.xX.X,permute(CONN_h.menus.m_results.roiresults.y(:,ntarget(itarget),:),[1,3,2]),Cext,Cext2,'collapse_none');
                            cbeta=beta.h;
                            if nnz(~isnan(cbeta))
                                CI=spm_invTcdf(1-.05,beta.dof)*cbeta./beta.F;
                                crange=[min(0,min(cbeta(:)-CI(:))) max(0,max(cbeta(:)+CI(:)))];
                                xrange=min([10*size(cbeta,2).^.75/size(cbeta,1).^.25, 2/scaleref*abs(CONN_gui.refs.canonical.V.dim(1)-(xyz(1)-2))/size(cbeta,1)/1.25, 2*abs(xyz(1)-2)/size(cbeta,1)/1.25]);
                                h0a=line(xyz(1)-scaleref*(-2+1*xrange*(size(cbeta,1))/2*[-1 1]),xyz(2)+scaleref*(-2-wt2-0.125*10-10*(-crange(1)/diff(crange))+[0 0]),200+numel(ntarget)-itarget+1+[.2 .2],'color','k','linewidth',1);
                                h0b=patch(xyz(1)-scaleref*(-2+1.25*xrange*(size(cbeta,1))/2*[-1 -1 1 1]),xyz(2)+scaleref*(-2-wt2-1.25*10*[0 1 1 0]),200+numel(ntarget)-itarget+1+[0 0 0 0],'k','facecolor','w','edgecolor',.75*[1 1 1],'linestyle','-','linewidth',1,'facealpha',.90);
                                h0c=patch(xyz(1)-scaleref*[0 -2 -.5],xyz(2)+scaleref*(-[0 2 2]-wt2),200+numel(ntarget)-itarget+1+[.2 .2 .2],'w','facecolor','w','edgecolor',.75*[1 1 1],'facealpha',.90);
                                [h1,h2]=conn_plotbars(cbeta,CI, [xyz(1)-scaleref*(-2+xrange*size(cbeta,1)/2+xrange/2), xyz(2)+scaleref*(-2-wt2-0.125*10-10*(-crange(1)/diff(crange))), 200+numel(ntarget)-itarget+1, xrange*scaleref, -10/diff(crange)*scaleref, .1]);
                                set(h1,'facecolor',[.5 .5 .5]);%,'facealpha',.90);
                                set(h2,'linewidth',1,'color',.25*[1 1 1]);
                                %set([h0a,h0b,h0c,h1(:)',h2(:)'], 'buttondownfcn','conn(''gui_results'',35);');
                                CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},h0a,h0b,h0c,h1(:)',h2(:)');
                            end
                        end
                        hold on;
                        if ~isempty(xepos)
                            ht=plot(xepos(:,1),xepos(:,2),'r-','linewidth',4);
                            set(ht,'zdata',3+zeros(size(xepos,1),1));
                            CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},ht(:)');
                        end
                        if ~isempty(xeneg)
                            ht=plot(xeneg(:,1),xeneg(:,2),'b-','linewidth',4);
                            set(ht,'zdata',3+zeros(size(xeneg,1),1));
                            CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},ht(:)');
                        end
                        hold off;
                        if isfield(CONN_h.menus.m_results,'showraw')&&CONN_h.menus.m_results.showraw
                            conn_menu('updateplotsingle',CONN_h.menus.m_results_00{29},reshape(permute(CONN_h.menus.m_results.roiresults.y(:,ntarget,:),[1,3,2]),size(CONN_h.menus.m_results.roiresults.y,1),[]));
                            txt=regexprep(CONN_h.menus.m_results.roiresults.names2(ntarget(end:-1:1)),{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'});
                            set(CONN_h.menus.m_results_00{29}.h3,'visible','on','xtick',size(CONN_h.menus.m_results.roiresults.y,1)/2,'xticklabel','subjects','ytick',size(CONN_h.menus.m_results.roiresults.y,3)*size(CONN_h.menus.m_results.roiresults.y,4)*(0:numel(ntarget)-1),'yticklabel',txt,'xcolor',.5*[1 1 1],'ycolor',.5*[1 1 1],'box','off');
                        else
                            try
                                tt=CONN_h.menus.m_results.roiresults.y(:,ntarget,:);
                                tt=reshape(reshape(tt,[],size(tt,3))*CONN_h.menus.m_results.roiresults.c2',size(tt,1),[]);
                                conn_menu('updateplotsingle',CONN_h.menus.m_results_00{29},tt);
                                txt=regexprep(CONN_h.menus.m_results.roiresults.names2(ntarget(end:-1:1)),{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'});
                                set(CONN_h.menus.m_results_00{29}.h3,'visible','on','xtick',size(CONN_h.menus.m_results.roiresults.y,1)/2,'xticklabel','subjects','ytick',size(tt,2)/numel(ntarget)*(0:numel(ntarget)-1),'yticklabel',txt,'xcolor',.5*[1 1 1],'ycolor',.5*[1 1 1],'box','off');
                            catch
                                conn_menu('update',CONN_h.menus.m_results_00{29},[]);
                            end
                        end
                        %
                    else
                        conn_menu('update',CONN_h.menus.m_results_00{29},[]);
                    end
                    if ~isempty(nsources) % sources
                        xyz=pinv(CONN_gui.refs.canonical.V.mat)*[cat(1,CONN_h.menus.m_results.roiresults.xyz{nsources}),ones(numel(nsources),1)]';
                        [nill,idxsort]=sort(xyz(3,:));
                        xyz(1:2,:)=conn_menu_montage('xyz2coords',CONN_h.menus.m_results.xsen1n2,CONN_h.menus.m_results.xseM*xyz);
                        for niplot=8:-1:1, CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(conn_bsxfun(@plus,xyz(1,idxsort),scaleref*niplot/9*3*xtemp),conn_bsxfun(@plus,xyz(2,idxsort),scaleref*niplot/9*3*ytemp),ones(numel(xtemp),1)*xyz(3,idxsort),'w','facecolor',min(1,4*[.25 .25 .25]*(1-niplot/9)),'edgecolor','none','facealpha',.95+0*(1-niplot/9)^1)); end
                        %CONN_h.menus.m_results_00{26}=cat(2,CONN_h.menus.m_results_00{26},patch(conn_bsxfun(@plus,xyz(1,idxsort),4*xtemp),conn_bsxfun(@plus,xyz(2,idxsort),4*ytemp),'w','facecolor','k','edgecolor',.25*[1,1,1],'facealpha',.75));
                        CONN_h.menus.m_results.roiresults.displayrois=cat(1,CONN_h.menus.m_results.roiresults.displayrois,...
                            [cat(1,CONN_h.menus.m_results.roiresults.xyz2{nsources}),2*4*ones(numel(nsources),1),0*ones(numel(nsources),1), xyz(1:2,:)', reshape(nsources,[],1)]); %, reshape(mean(mean(CONN_h.menus.m_results.roiresults.B(:,:,:,nsources),2),3),[],numel(nsources))']);
                        CONN_h.menus.m_results.roiresults.displayroisnames=cat(2,CONN_h.menus.m_results.roiresults.displayroisnames,CONN_h.menus.m_results.roiresults.names2(nsources));
                    end
                    %hold off;
                    
                    if numel(CONN_h.menus.m_results_00{26})>1, set(CONN_h.menus.m_results_00{26}(cellfun(@isempty,get(CONN_h.menus.m_results_00{26},'buttondown'))),'buttondownfcn','conn(''gui_results'',26);');
                    elseif numel(CONN_h.menus.m_results_00{26})==1&&isempty(get(CONN_h.menus.m_results_00{26},'buttondown')), set(CONN_h.menus.m_results_00{26},'buttondown','conn(''gui_results'',26);'); 
                    end
                    set(findobj(CONN_h.menus.m_results_00{25}),'visible','on');
                    set(CONN_h.menus.m_results_00{25},'visible','off');
                else
                    set(findobj(CONN_h.menus.m_results_00{25}),'visible','off');
                    conn_menu('update',CONN_h.menus.m_results_00{29},[]);
                end
                delete(tobedeleted);
            end
		
        case 'gui_results_roiview',
            conn_displayroi('init','results_roi',CONN_x.Results.xX.nsources,-1);
            return;

        case 'gui_results_roi3d'
            c={[0,0,1],[.25,.25,.25],[1,0,0]};
            idx=CONN_h.menus.m_results.roiresults.displayrois(:,8); 
            idx1=find(~CONN_h.menus.m_results.roiresults.displayrois(:,5));
            b=mean(mean(CONN_h.menus.m_results.roiresults.B(:,:,:,idx),2),3);
            b=permute(b/max(eps,max(abs(b(:)))),[1,4,2,3]);
            B=zeros(max(size(b))); B(idx1,1:size(b,2))=b;
            conn_mesh_display('','',[],struct('sph_names',{CONN_h.menus.m_results.roiresults.displayroisnames},'sph_xyz',CONN_h.menus.m_results.roiresults.displayrois(:,1:3),'sph_r',CONN_h.menus.m_results.roiresults.displayrois(:,4)*.5,'sph_c',{c(2+sign(CONN_h.menus.m_results.roiresults.displayrois(:,5)))}), ...
                B, ...
                .2, ...
                [0,-.01,1],...
                [],...
                fullfile(CONN_x.folders.secondlevel,conn_resultsfolder('subjectsconditions',1,CONN_x.Results.xX.nsubjecteffects,CONN_x.Results.xX.csubjecteffects,CONN_x.Results.xX.nconditions,CONN_x.Results.xX.cconditions)));
            return
            
        case 'gui_results_wholebrain',
            %if ~CONN_x.Setup.normalized, warndlg('Second-level voxel-level analyses not available for non-normalized data'); return; end
            if CONN_x.Results.xX.modeltype==2, conn_msgbox('Second-level fixed-effects voxel-level analyses not implemented','',2); return; end
            CONN_x.Results.foldername='';
            conn_process('results_voxel','readsingle','seed-to-voxel');
            set(CONN_h.screen.hfig,'pointer','arrow');
            return;
            
        case 'gui_results_graphtheory',
            conn_displaynetwork('init',CONN_x.Results.xX.nsources);
            return;
            
		case 'gui_results_done',
			%if isempty(CONN_x.filename), conn gui_setup_save; end
            if conn_questdlgrun('Ready to Compute results for all sources',false,[1 1 1],false,true,[],6:7); 
                conn_menumanager clf;
                conn_menuframe;
                conn_menu('frame2border',[.0,.955,1,.045],'');
                conn_menumanager(CONN_h.menus.m0,'enable',CONN_x.isready);
                conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
                CONN_x.Results.foldername='';
                psteps={'setup','denoising_gui','analyses_gui_seedandroi','analyses_gui_vv','analyses_gui_dyn','seed-to-voxel','voxel-to-voxel'};
                for n=1:numel(CONN_x.gui.processes{1})
                    drawnow;
                    conn_process('results_voxel','doall',psteps{CONN_x.gui.processes{1}(n)},CONN_x.gui.processes{2}{n});
                end
                CONN_x.gui=1;
                conn gui_results;
            end
			%conn_menumanager clf;
			%axes('units','norm','position',[0,.935,1,.005]); image(shiftdim([0 0 0]+.4+.2*(mean(CONN_gui.backgroundcolorA)<.5),-1)); axis off;
			%conn_menumanager([CONN_h.menus.m0],'on',1);
			%conn gui_setup_save;
%             CONN_x.gui=0;
%             CONN_x.Results.foldername='';
%             conn_process('results');
%             if CONN_x.Setup.steps(1)&&~CONN_x.Setup.steps(2),% || ~CONN_x.Setup.normalized, 
%                 conn_process('results_roi');
%             else
%                 conn_process('results');
%             end
%             CONN_x.gui=1;
% 			conn gui_setup_save;
%             set(CONN_h.screen.hfig,'pointer','arrow')
            return;

        case 'gui_results_searchseed'
            if ~CONN_x.Setup.steps(1), disp('need to select ''voxel-to-voxel'' checkbox in Setup->Options and run Setup/Denoising/first-level Analyses'); return;
            elseif ~isfield(CONN_x.vvAnalyses(CONN_x.vvAnalysis),'measures'), disp('need to run first-level voxel-to-voxel analyses first'); return;
            end
            sources=CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures;
            iroi=zeros(size(sources));isnew=iroi;ncomp=iroi;
            for n1=1:numel(sources),[iroi(n1),isnew(n1),ncomp(n1)]=conn_v2v('match_extended',sources{n1});end
            idx=strmatch('group-MVPA',sources);
            if isempty(idx), disp('need to run first-level voxel-to-voxel analyses first'); 
            else
                idx=find(iroi==iroi(idx(find(~isnew(idx),1))));
                CONN_x.Results.xX.nmeasures=idx;
                CONN_x.Results.xX.cmeasures=eye(numel(idx));
                CONN_x.Results.xX.nmeasuresbyname=conn_v2v('cleartext',CONN_x.vvAnalyses(CONN_x.vvAnalysis).measures(idx));
                CONN_x.Results.foldername='';
                conn_process('results_voxel','readsingle','voxel-to-voxel'); 
            end 
            set(CONN_h.screen.hfig,'pointer','arrow');
            return;
            
        case 'gui_results_wholebrain_vv',
            CONN_x.Results.foldername='';
            conn_process('results_voxel','readsingle','voxel-to-voxel');
            set(CONN_h.screen.hfig,'pointer','arrow');
            return;

%         case 'gui_results_done_vv',
% 			%if isempty(CONN_x.filename), conn gui_setup_save; end
%             %if conn_questdlgrun('Ready to Compute results for all sources',false,[0 1 0],false);
%                 conn_menumanager clf;
%                 conn_menuframe;
%                 conn_menumanager([CONN_h.menus.m_setup_06,CONN_h.menus.m0],'on',1);
%                 CONN_x.Results.foldername='';
%                 conn_process('results_voxel','doall','voxel-to-voxel');
%                 CONN_x.gui=1;
%                 %conn gui_setup_save;
%                 conn gui_results;
%             %end
%             return;
            
        otherwise,
            if ~isempty(which(sprintf('conn_%s',varargin{1}))),
                fh=eval(sprintf('@conn_%s',varargin{1}));
                [varargout{1:nargout}]=feval(fh,varargin{2:end});
            else
                disp(sprintf('unrecognized option %s or conn_%s function',varargin{1},varargin{1}));
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			

    end
end
if isfield(CONN_gui,'modalfig')&&~isempty(CONN_gui.modalfig)
    CONN_gui.modalfig(~ishandle(CONN_gui.modalfig))=[];
    idx=find(ishandle(CONN_gui.modalfig),1);
    if ~isempty(idx), figure(CONN_gui.modalfig(idx)); end
end

catch me
    if dodebug
        if isempty(me), error(lasterror); %Matlab<=2007a
        else me.rethrow; 
        end
    else
        if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
        if isfield(CONN_x,'filename'), filename=CONN_x.filename; else filename=[]; end
        [str,PrimaryMessage]=conn_errormessage(me,filename,0,CONN_x.ver);
        checkdesktop=true;
        try, checkdesktop=checkdesktop&usejava('awt'); end
        %try, checkdesktop=checkdesktop&CONN_x.pobj.holdsdata; end
        if ~checkdesktop
            fprintf(2,'%s\n',str{:});
        else
            h=[];
            set(findobj(0,'tag','conn_timedwaitbar'),'windowstyle','normal');
            h.fig=dialog('windowstyle','normal','name','Sorry, CONN run into an unexpected issue','color','w','resize','on','units','norm','position',[.2 .4 .4 .2],'handlevisibility','callback','windowstyle','modal');
            h.button1=uicontrol(h.fig,'style','pushbutton','units','norm','position',[.1 .75 .8 .2],'fontsize',9+CONN_gui.font_offset,'string',PrimaryMessage);
            h.edit1=uicontrol(h.fig,'style','edit','units','norm','position',[.1 .30 .8 .65],'backgroundcolor','w','max',2,'fontsize',9+CONN_gui.font_offset,'horizontalalignment','left','string',str,'visible','off');
            h.edit2=uicontrol(h.fig,'style','edit','units','norm','position',[.1 .3 .8 .4],'backgroundcolor','w','max',2,'fontsize',8+CONN_gui.font_offset,'fontangle','italic','string',{'For support information see HELP->SUPPORT or HELP->FAQ','To check for patches and updates see HELP->UPDATES','If requesting support about this error please provide the full error message'});
            h.button2=uicontrol(h.fig,'style','pushbutton','units','norm','position',[.1 .05 .25 .2],'string','Visit support forum','callback',@(varargin)conn('gui_help','url','http://www.nitrc.org/forum/forum.php?forum_id=1144'),'tooltipstring','http://www.nitrc.org/forum/forum.php?forum_id=1144');
            h.button3=uicontrol(h.fig,'style','pushbutton','units','norm','position',[.4 .05 .25 .2],'string','Visit FAQ website','callback',@(varargin)conn('gui_help','url','http://www.alfnie.com/software/conn'),'tooltipstring','http://www.alfnie.com/software/conn');
            h.button4=uicontrol(h.fig,'style','pushbutton','units','norm','position',[.7 .05 .2 .2],'string','Continue','callback','delete(gcbf)');
            set(h.button1,'userdata',h,'callback','h=get(gcbo,''userdata'');set(h.fig,''position'',get(h.fig,''position'')+[0,0,0,.3]);set(h.button1,''visible'',''off'');set(h.edit1,''position'',[.1 .30 .8 .65],''visible'',''on'');set(h.edit2,''position'',[.1 .12 .8 .18]);set(h.button2,''position'',[.1 .025 .25 .07]);set(h.button3,''position'',[.4 .025 .25 .07]);set(h.button4,''position'',[.7 .025 .2 .07]);');
        end
    end
end

    function conn_orthogonalizemenuupdate(varargin)
        tnl2covariates_other=nl2covariates_other(get(ht1,'value'));
        if get(ht2,'value'), tnl2covariates_subjects=find(any(X(:,nl2covariates)~=0,2)&~any(isnan(X(:,nl2covariates)),2)&~any(isnan(X(:,tnl2covariates_other)),2)); 
        else tnl2covariates_subjects=find(~any(isnan(X(:,nl2covariates)),2)&~any(isnan(X(:,tnl2covariates_other)),2)); end
        x=X;
        x(tnl2covariates_subjects,nl2covariates)=X(tnl2covariates_subjects,nl2covariates)-X(tnl2covariates_subjects,tnl2covariates_other)*(pinv(X(tnl2covariates_subjects,tnl2covariates_other))*X(tnl2covariates_subjects,nl2covariates));
        t=x(:,nl2covariates)';
        set(ht3,'string',mat2str(t,max([0,ceil(log10(max(1e-10,abs(t(:)'))))])+6));
        %k=t; for n=0:6, if abs(round(k)-k)<1e-6, break; end; k=k*10; end;
        %set(ht3,'string',num2str(t,['%0.',num2str(n),'f ']));
    end

end


function ok=conn_questdlgrun(str,stepsoption,steps,condsoption,dispoption,paroption,multipleoption,subjectsoption,groupsoption)
global CONN_x CONN_gui;
if nargin<9||isempty(groupsoption), groupsoption=[]; end
if nargin<8||isempty(subjectsoption), subjectsoption=false; end
if nargin<7||isempty(multipleoption), multipleoption=[]; end
if nargin<6||isempty(paroption), paroption=false; end
if nargin<5||isempty(dispoption), dispoption=[]; end
if nargin<4||isempty(condsoption), condsoption=true; end
if nargin<3||isempty(steps), steps=CONN_x.Setup.steps(1:3); end
if nargin<2||isempty(stepsoption), stepsoption=true; end
thfig=figure('units','norm','position',[.3,.5,.4,.3],'color','w','name','CONN data processing pipeline','numbertitle','off','menubar','none');
ht3=uicontrol('style','text','units','norm','position',[.1,.8,.8,.15],'string',str,'backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
ht2a=uicontrol('style','checkbox','units','norm','position',[.1,.7,.3,.10],'string','ROI-to-ROI','value',steps(1),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w');
ht2b=uicontrol('style','checkbox','units','norm','position',[.1,.6,.3,.10],'string','Seed-to-Voxel','value',steps(2),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w');
ht2c=uicontrol('style','checkbox','units','norm','position',[.1,.5,.3,.10],'string','Voxel-to-Voxel','value',steps(3),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w');
if numel(steps)>3, 
    ht2d=uicontrol('style','checkbox','units','norm','position',[.1,.4,.3,.10],'string','Dynamic FC','value',steps(4),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w');
else ht2d=[]; 
end
ht4b=uicontrol('style','listbox','units','norm','position',[.6,.4,.3,.2],'string',CONN_x.Setup.conditions.names(1:end-1),'value',1,'fontsize',8+CONN_gui.font_offset,'max',2);
ht4a=uicontrol('style','checkbox','units','norm','position',[.4,.5,.19,.10],'string','All conditions','value',all(islogical(condsoption)),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','userdata',ht4b,'callback','h=get(gcbo,''userdata'');if get(gcbo,''value''), set(h,''visible'',''off''); else set(h,''visible'',''on''); end');
vars={'Setup','Denoising'; 1,2; [],[]}; 
for n1=1:numel(CONN_x.Analyses), vars(:,end+1)={['First-level S2V/R2R ',CONN_x.Analyses(n1).name]; 3; CONN_x.Analyses(n1).name}; end
for n1=1:numel(CONN_x.vvAnalyses), vars(:,end+1)={['First-level V2V ',CONN_x.vvAnalyses(n1).name]; 4; CONN_x.vvAnalyses(n1).name}; end
for n1=1:numel(CONN_x.dynAnalyses), vars(:,end+1)={['First-level dyn-ICA ',CONN_x.dynAnalyses(n1).name]; 5; CONN_x.dynAnalyses(n1).name}; end
for n1=1:numel(CONN_x.Analyses), if ismember(CONN_x.Analyses(n1).type,[2,3]), vars(:,end+1)={['Second-level S2V ',CONN_x.Analyses(n1).name]; 6; CONN_x.Analyses(n1).name}; end; end
for n1=1:numel(CONN_x.vvAnalyses), vars(:,end+1)={['Second-level V2V ',CONN_x.vvAnalyses(n1).name]; 7; CONN_x.vvAnalyses(n1).name}; end
if ~all(islogical(multipleoption))&&~isempty(multipleoption), vars=vars(:,ismember([vars{2,:}],multipleoption)); end
ht4d=uicontrol('style','listbox','units','norm','position',[.6,.4,.3,.2],'string',vars(1,:),'value',1,'fontsize',8+CONN_gui.font_offset,'max',2);
ht4c=uicontrol('style','checkbox','units','norm','position',[.4,.5,.19,.10],'string','All Steps','value',0,'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','userdata',ht4d,'callback','h=get(gcbo,''userdata'');if get(gcbo,''value''), set(h,''visible'',''off''); else set(h,''visible'',''on''); end');
ht4f=uicontrol('style','listbox','units','norm','position',[.6,.6,.3,.2],'string',arrayfun(@(x)sprintf('Subject %d',x),1:CONN_x.Setup.nsubjects,'uni',0),'value',1,'fontsize',8+CONN_gui.font_offset,'max',2);
ht4e=uicontrol('style','checkbox','units','norm','position',[.4,.7,.19,.10],'string','All Subjects','value',all(islogical(subjectsoption)),'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','userdata',ht4f,'callback','h=get(gcbo,''userdata'');if get(gcbo,''value''), set(h,''visible'',''off''); else set(h,''visible'',''on''); end');
if multipleoption, condsoption=false; end
if ~stepsoption, set([ht2a,ht2b,ht2c,ht2d],'enable','off'); end
if ~all(islogical(condsoption)), set(ht4b,'value',condsoption); 
elseif condsoption, set([ht4b],'visible','off'); 
else set([ht4a,ht4b],'visible','off'); 
end
if all(islogical(multipleoption)),set([ht4d],'visible','off'); 
elseif ~isempty(multipleoption), %set(ht4d,'value',multipleoption); 
else set([ht4c,ht4d],'visible','off'); 
end
if ~all(islogical(subjectsoption)), set(ht4f,'value',subjectsoption); 
elseif subjectsoption, set([ht4f],'visible','off'); 
else set([ht4e,ht4f],'visible','off'); 
end
if ~isempty(dispoption), ht5=uicontrol('style','popupmenu','units','norm','position',[.1,.32,.8,.08],'string',{'do not display GUI','display GUI'},'value',1+dispoption,'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w'); else ht5=[]; end
if ~isempty(groupsoption), ht6=uicontrol('style','popupmenu','units','norm','position',[.1,.32,.8,.08],'string',{'all steps','group-level analyses only (step1)','subject-level backprojection only (step2)'},'value',1+groupsoption,'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w'); else ht6=[]; end
ht1=uicontrol('style','popupmenu','units','norm','position',[.1,.24,.8,.08],'string',{'overwrite existing results (proceed for all subjects/seeds)','do not overwrite (skip already-processed subjects/seeds)','ask user on each individual analysis step'},'value',1,'fontsize',8+CONN_gui.font_offset);
if paroption, 
    [tstr,tidx]=conn_jobmanager('profiles'); 
    tnull=find(strcmp('Null profile',tstr)); 
    tlocal=find(strcmp('Background process (Unix,Mac)',tstr),1);
    tvalid=setdiff(1:numel(tstr),tnull);
    tstr=cellfun(@(x)sprintf('distributed processing (run on %s)',x),tstr,'uni',0);
    if 1, tvalid=tidx; if isunix&&~isempty(tlocal)&&~ismember(tlocal,tvalid), tvalid=[tvalid(:)' tlocal]; end
    elseif 1, tvalid=tidx; % show only default scheduler
    else tstr{tidx}=sprintf('<HTML><b>%s</b></HTML>',tstr{tidx});
    end
    ht0=uicontrol('style','popupmenu','units','norm','position',[.1,.16,.8,.08],'string',[{'local processing (run on this computer)' 'queue/script it (save as scripts to be run later)'} tstr(tvalid)],'value',1,'fontsize',8+CONN_gui.font_offset); 
end
uicontrol('style','pushbutton','string','Start','units','norm','position',[.1,.01,.38,.13],'callback','uiresume','fontsize',9+CONN_gui.font_offset);
uicontrol('style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.13],'callback','delete(gcbf)','fontsize',9+CONN_gui.font_offset);
uiwait(thfig);
ok=ishandle(thfig);
if ok
    switch get(ht1,'value')
        case 1, CONN_x.gui=struct('overwrite','Yes','display',1,'parallel',0);
        case 2, CONN_x.gui=struct('overwrite','No','display',1,'parallel',0);
        case 3, CONN_x.gui=struct('display',1,'parallel',0);
    end
    if ~isempty(ht5)&&isequal(get(ht5,'value'),1), CONN_x.gui.display=0; end
    if ~isempty(ht6), CONN_x.gui.grouplevel=get(ht6,'value')-1; end
    if stepsoption
        CONN_x.gui.steps=CONN_x.Setup.steps;
        CONN_x.gui.steps(1)=get(ht2a,'value');
        CONN_x.gui.steps(2)=get(ht2b,'value');
        CONN_x.gui.steps(3)=get(ht2c,'value');
        if ~isempty(ht2d), CONN_x.gui.steps(4)=get(ht2d,'value'); end
    end
    if get(ht4a,'value'), CONN_x.gui.conditions=1:numel(CONN_x.Setup.conditions.names)-1;
    else CONN_x.gui.conditions=get(ht4b,'value');
    end
    if multipleoption
        if get(ht4c,'value'), CONN_x.gui.processes={[vars{2,:}], vars(3,:)};
        else CONN_x.gui.processes={[vars{2,get(ht4d,'value')}], vars(3,get(ht4d,'value'))}; 
        end
        CONN_x.gui.processes{2}=CONN_x.gui.processes{2}(cellfun('length',CONN_x.gui.processes{2})>0); 
    end
    if subjectsoption
        if get(ht4e,'value'), %
        else CONN_x.gui.subjects=get(ht4f,'value');
        end
    end
    if paroption, 
        temp=get(ht0,'value'); 
        if temp==2, CONN_x.gui.display=0; CONN_x.gui.parallel=find(strcmp('Null profile',conn_jobmanager('profiles'))); 
        elseif temp>2, CONN_x.gui.display=0; CONN_x.gui.parallel=tvalid(temp-2); 
            if conn_jobmanager('ispending')
                answ=conn_questdlg({'There are previous pending jobs associated with this project','This job cannot be submitted until all pending jobs finish',' ','Would you like to queue this job for later?','(pending jobs can be seen at Tools.Cluster/HPC.View pending jobs'},'Warning','Queue','Cancel','Queue');
                if isempty(answ)||strcmp(answ,'Cancel'), ok=false; end
                CONN_x.gui.parallel=find(strcmp('Null profile',conn_jobmanager('profiles'))); 
            end
        end
        if temp>2&&~isfield(CONN_x.gui,'overwrite'), 
            ok=false;
            conn_msgbox('Sorry, parallelization jobs cannot depend on user-input. Select explicit ''proceed for all subjects/seeds'' or ''skip already-processed subjects/seeds'' options','',2);
        end
    end
    delete(thfig);
end
end

function conn_callbackdisplay_conditiondesignclick(pos,varargin)
global CONN_h CONN_x;
try
    xlscn=CONN_h.menus.m_setup_11e{1};
    xlses=CONN_h.menus.m_setup_11e{2};
    xlsub=CONN_h.menus.m_setup_11e{3};
    xlcon=CONN_h.menus.m_setup_11e{4};
    xlval=CONN_h.menus.m_setup_11e{5};
    if isempty(xlcon)
    else
        if isnan(xlval(pos(1),pos(2)))
        else
            set(CONN_h.menus.m_setup_00{1},'value',xlcon(pos(1),pos(2)));
            %set(CONN_h.menus.m_setup_00{2},'value',xlsub(pos(1),pos(2)));
            set(CONN_h.menus.m_setup_00{3},'value',xlses(pos(1),pos(2)));
        end
    end
    conn('gui_setup',1);
end
end

function [txt1,txt2]=conn_callbackdisplay_conditiondesign(pos,varargin)
global CONN_h CONN_x;
try
    xlscn=CONN_h.menus.m_setup_11e{1};
    xlses=CONN_h.menus.m_setup_11e{2};
    xlsub=CONN_h.menus.m_setup_11e{3};
    xlcon=CONN_h.menus.m_setup_11e{4};
    xlval=CONN_h.menus.m_setup_11e{5};
    if isempty(xlcon)
        if isnan(xlval(pos(1),pos(2)))
            txt1={'no data'};
        else
            txt1={sprintf('Subject %d Session %d: %d scans', xlsub(pos(1),pos(2)), xlses(pos(1),pos(2)),xlscn(pos(1),pos(2)))};
        end
    else
        if isnan(xlval(pos(1),pos(2)))
            txt1={' '};
        else
            if xlval(pos(1),pos(2))>0, offon='present'; %sprintf('active (%.2f)',xlval(pos(1),pos(2)));
            else offon='not present';
            end
            txt1={sprintf('Subject %d Session %d', xlsub(pos(1),pos(2)), xlses(pos(1),pos(2))),sprintf('Condition %s %s during scan %d',CONN_x.Setup.conditions.names{xlcon(pos(1),pos(2))}, offon, xlscn(pos(1),pos(2))),' (click to select)'};
        end
    end
    txt2={};
catch
    txt1={};
    txt2={};
end
end

function conn_callbackdisplay_functionalclick(pos,varargin)
global CONN_h CONN_x;
try
    if isempty(CONN_h.menus.m_setup.functional_vol), 
        hmsg=conn_msgbox('Initializing timeseries plots... please wait','');
        CONN_h.menus.m_setup.functional_vol=spm_vol(CONN_h.menus.m_setup.functional{1}); 
        if ishandle(hmsg), delete(hmsg); end
    end
    mat=CONN_h.menus.m_setup.functional{3}(1).mat;
    txyz=pinv(mat)*[pos(1:3);1];
    data=spm_get_data(CONN_h.menus.m_setup.functional_vol,txyz);
    conn_menu('updateplotstackcenter',CONN_h.menus.m_setup_00{8},data);
    txt=sprintf('(%d,%d,%d)',pos(1),pos(2),pos(3));
    set(CONN_h.menus.m_setup_00{8}.h3,'visible','on','ytick',0,'yticklabel',{txt},'ycolor',.5*[1 1 1],'box','off');
end
end

function conn_callbackdisplay_denoisingclick(pos,varargin)
persistent tpos;
global CONN_h CONN_x;
try
    if nargin>0, tpos=pos; end
    if ~isempty(tpos)
        t1=zeros(CONN_h.menus.m_preproc.Y.matdim.dim(1:2));
        t1(CONN_h.menus.m_preproc.y.idx)=1:numel(CONN_h.menus.m_preproc.y.idx);
        txyz=round(pinv(CONN_h.menus.m_preproc.Y.matdim.mat)*[tpos(1:3);1]);
        tidx=t1(txyz(1),txyz(2));
        if tidx
            conn_menu('updateplotstackcenter',CONN_h.menus.m_preproc_00{29},[CONN_h.menus.m_preproc.y.data(:,tidx) CONN_h.menus.m_preproc.y.data_afterdenoising(:,tidx)]);
            set(CONN_h.menus.m_preproc_00{29}.h4(1),'color',.75/2*[1,1,1]); set(CONN_h.menus.m_preproc_00{29}.h4(2),'color',1/2*[1,1,0]);
            CONN_h.menus.m_preproc.selectedcoords=CONN_h.menus.m_preproc.Y.matdim.mat*[txyz(1);txyz(2);CONN_h.menus.m_preproc.y.slice;1];
            txt=sprintf('(%d,%d,%d)',CONN_h.menus.m_preproc.selectedcoords(1),CONN_h.menus.m_preproc.selectedcoords(2),CONN_h.menus.m_preproc.selectedcoords(3));
            set(CONN_h.menus.m_preproc_00{29}.h3,'visible','on','ytick',1,'yticklabel',{txt},'ycolor',.5*[1 1 1],'box','off');
        else
            conn_menu('updateimage',CONN_h.menus.m_preproc_00{29},[]);
        end
    else
        conn_menu('updateimage',CONN_h.menus.m_preproc_00{29},[]);
    end
end
end

function conn_callbackdisplay_firstlevelclick(pos,varargin)
persistent tpos;
global CONN_h CONN_x;
try
    if nargin>0, tpos=pos; end
    if ~isempty(tpos)
        t1=zeros(CONN_h.menus.m_analyses.Y.matdim.dim(1:2));
        t1(CONN_h.menus.m_analyses.y.idx)=1:numel(CONN_h.menus.m_analyses.y.idx);
        txyz=round(pinv(CONN_h.menus.m_analyses.Y.matdim.mat)*[tpos(1:3);1]);
        tidx=t1(txyz(1),txyz(2));
        if tidx
            xtemp=CONN_h.menus.m_analyses.X(:,find(CONN_h.menus.m_analyses.select{1}));
            xtemp=[xtemp CONN_h.menus.m_analyses.y.data(:,tidx)];
            if size(CONN_h.menus.m_analyses.Wf,2)==1, xtemp(CONN_h.menus.m_analyses.Wf==0,:)=nan; end
            conn_menu('updateplotstack',CONN_h.menus.m_analyses_00{29},xtemp);
            CONN_h.menus.m_analyses.selectedcoords=CONN_h.menus.m_analyses.Y.matdim.mat*[txyz(1);txyz(2);CONN_h.menus.m_analyses.y.slice;1];
            txt=sprintf('(%d,%d,%d)',CONN_h.menus.m_analyses.selectedcoords(1),CONN_h.menus.m_analyses.selectedcoords(2),CONN_h.menus.m_analyses.selectedcoords(3));
            if size(xtemp,2)==1, set(CONN_h.menus.m_analyses_00{29}.h3,'visible','on','ytick',[0],'yticklabel',{txt},'ycolor',.5*[1 1 1],'box','off');
            else set(CONN_h.menus.m_analyses_00{29}.h3,'visible','on','ytick',[0 size(xtemp,2)-1],'yticklabel',{txt,'seed'},'ycolor',.5*[1 1 1],'box','off');
            end
        else
            conn_menu('updateimage',CONN_h.menus.m_analyses_00{29},[]);
        end
    else
        conn_menu('updateimage',CONN_h.menus.m_analyses_00{29},[]);
    end
end
end

function conn_callbackdisplay_secondlevelclick(pos,varargin)
persistent tpos;
global CONN_h CONN_x CONN_gui;
try
    if nargin>0, 
        if strcmp(get(CONN_h.screen.hfig,'selectiontype'),'extend'),tpos=[tpos,pos];
        else tpos=pos;
        end
    end
    dismiss=true;
    oldhandles=CONN_h.menus.m_results_00{14}.hnill;
    if ~isempty(tpos)
        txyz=round(pinv(CONN_h.menus.m_results.Y(1).mat)*[tpos(1:3,:);ones(1,size(tpos,2))]);
        tidx=sub2ind(CONN_h.menus.m_results.Y(1).dim(1:2),txyz(1,:),txyz(2,:));
        if all(tidx)
            xtemp=permute(CONN_h.menus.m_results.y.data(:,tidx,:),[1,3,2]);
            xtemp=xtemp(CONN_h.menus.m_results.design.subjects,:,:);
            dismiss=all(xtemp(:)==0);
        end
    end
    if ~dismiss
        conn_menu('updateplotsingle',CONN_h.menus.m_results_00{29},xtemp(:,:));
        CONN_h.menus.m_results.selectedcoords=CONN_h.menus.m_results.Y(1).mat*[txyz(1,:);txyz(2,:);CONN_h.menus.m_results.y.slice+zeros(1,size(txyz,2));ones(1,size(txyz,2))];
        CONN_h.menus.m_results.selectedidx=tidx;
        txt=arrayfun(@(n)sprintf('(%d,%d,%d)',CONN_h.menus.m_results.selectedcoords(1,n),CONN_h.menus.m_results.selectedcoords(2,n),CONN_h.menus.m_results.selectedcoords(3,n)),size(CONN_h.menus.m_results.selectedcoords,2):-1:1,'uni',0);
        set(CONN_h.menus.m_results_00{29}.h3,'visible','on','xtick',size(xtemp,1)/2,'xticklabel','subjects','ytick',size(xtemp,2)*(0:numel(txt)-1),'yticklabel',txt,'xcolor',.5*[1 1 1],'ycolor',.5*[1 1 1],'box','off');
        
        yf=xtemp;
        xf=CONN_h.menus.m_results.design.designmatrix;
        nsubjects=CONN_h.menus.m_results.design.subjects;
        %tnames=CONN_h.menus.m_results.design.designmatrix_name;
        Cext=CONN_h.menus.m_results.design.contrast_between;
        %tnames=arrayfun(@(n)conn_longcontrastname(tnames,Cext(n,:)),1:size(Cext,1),'uni',0);
        [Stats_values.beta,Stats_values.F,Stats_values.p,Stats_values.dof,Stats_values.stat]=conn_glm(xf,yf,Cext,[],'collapse_none');
        if nnz(~isnan(Stats_values.beta))
            hax=CONN_h.menus.m_results_00{14}.h1;
            CONN_h.menus.m_results_00{14}.hnill=[];
            scaleref=max(1,min(2, sqrt(abs(diff(get(hax,'xlim'))/100)) ));
            %scaleref=max(1,min(2,sqrt(size(CONN_h.menus.m_results.y.data,3)*size(CONN_h.menus.m_results.y.data,4)))); 
            for nbeta=1:size(Stats_values.beta,3)
                cbeta=Stats_values.beta(:,:,nbeta);
                if nnz(~isnan(cbeta)),%&&~all(xtemp(:,nbeta)==0);
                    CI=spm_invTcdf(1-.05,Stats_values(1).dof)*cbeta./[Stats_values.F(:,:,nbeta)];
                    crange=[min(0,min(cbeta(:)-CI(:))) max(0,max(cbeta(:)+CI(:)))];
                    xyz=[CONN_h.menus.m_results.Y(1).dim(1)+1-txyz(1,nbeta) CONN_h.menus.m_results.Y(1).dim(2)+1-txyz(2,nbeta) txyz(3,nbeta)]; wt2=0;
                    xrange=min([10*size(cbeta,2).^.75/size(cbeta,1).^.25, 2/scaleref*abs(CONN_gui.refs.canonical.V.dim(1)-(xyz(1)-2))/size(cbeta,1)/1.25, 2*abs(xyz(1)-2)/size(cbeta,1)/1.25]);
                    h0b=patch(xyz(1)-scaleref*(-2+1.25*xrange*(size(cbeta,1))/2*[-1 -1 1 1]),xyz(2)+scaleref*(+2+wt2+1.25*10*[0 1 1 0]),200+1+[0 0 0 0],'k','facecolor','w','edgecolor',[.75 .75 .75],'linestyle','-','linewidth',1,'facealpha',.90,'parent',hax);
                    h0c=patch(xyz(1)-scaleref*[0 -2 -.5],xyz(2)+scaleref*(+[0 2 2]-wt2),200+1+[.2 .2 .2],'w','facecolor','w','edgecolor',[.75 .75 .75],'facealpha',.90,'parent',hax);
                    h0a=line(xyz(1)-scaleref*(-2+1*xrange*(size(cbeta,1))/2*[-1 1]),xyz(2)+scaleref*(+2+wt2+1.125*10-10*(-crange(1)/diff(crange))+[0 0]),200+1+[.2 .2],'color','k','linewidth',1,'parent',hax);
                    [h1,h2]=conn_plotbars(cbeta,CI, [xyz(1)-scaleref*(-2+xrange*size(cbeta,1)/2+xrange/2), xyz(2)+scaleref*(+2+wt2+1.125*10-10*(-crange(1)/diff(crange))), 200+1, xrange*scaleref, -10/diff(crange)*scaleref, .1],hax);
                    set(h1,'facecolor',[.5 .5 .5]);%,'facealpha',.90);
                    set(h2,'linewidth',1,'color',.25*[1 1 1]);
                    CONN_h.menus.m_results_00{14}.hnill=[CONN_h.menus.m_results_00{14}.hnill,h0a,h0b,h0c,h1(:)',h2(:)'];
                    %set([h0a,h0b,h0c,h1(:)',h2(:)'], 'buttondownfcn','conn(''gui_results'',35);');
                end
            end
        else CONN_h.menus.m_results_00{14}.hnill=[];
        end
        delete(oldhandles(ishandle(oldhandles)));
    else
        conn_menu('updateimage',CONN_h.menus.m_results_00{29},[]);
        delete(oldhandles(ishandle(oldhandles)));
        CONN_h.menus.m_results_00{14}.hnill=[];
        CONN_h.menus.m_results.selectedcoords=[];
        CONN_h.menus.m_results.selectedidx=[];
    end
end
end

function [txt1,txt2]=conn_callbackdisplay_general(pos,idx)
global CONN_h;
txt1={};
txt2={};
try
    if isfield(CONN_h.menus,'general')&&isfield(CONN_h.menus.general,'names')&&~isempty(CONN_h.menus.general.names)
        if isa(CONN_h.menus.general.names,'function_handle')
            txt1=CONN_h.menus.general.names(pos);
        else
            if size(CONN_h.menus.general.names,1)==1, idx1=1; else idx1=1+mod(round(pos(1))-1,size(CONN_h.menus.general.names,1)); end
            if size(CONN_h.menus.general.names,2)==1, idx2=1; else idx2=1+mod(round(pos(2))-1,size(CONN_h.menus.general.names,2)); end
            if size(CONN_h.menus.general.names,3)==1, idx3=1; else idx3=1+mod(round(idx)-1,size(CONN_h.menus.general.names,3)); end
            txt1=CONN_h.menus.general.names(idx1,idx2,idx3);
        end
    end
    if isfield(CONN_h.menus,'general')&&isfield(CONN_h.menus.general,'names2')&&~isempty(CONN_h.menus.general.names2)
        if isa(CONN_h.menus.general.names,'function_handle')
            txt2=CONN_h.menus.general.names2(pos);
        else
            if size(CONN_h.menus.general.names,1)==1, idx1=1; else idx1=1+mod(round(pos(1))-1,size(CONN_h.menus.general.names2,1)); end
            if size(CONN_h.menus.general.names,2)==1, idx2=1; else idx2=1+mod(round(pos(2))-1,size(CONN_h.menus.general.names2,2)); end
            if size(CONN_h.menus.general.names,3)==1, idx3=1; else idx3=1+mod(round(idx)-1,size(CONN_h.menus.general.names2,3)); end
            txt2=CONN_h.menus.general.names2(idx1,idx2,idx3);
        end
    end
end
end

function [txt1,txt2]=conn_callbackdisplay_dataname(pos,idx)
global CONN_h;
txt1={};txt2={};
try
    idx1=1+mod(idx-1,numel(CONN_h.menus.m_results.y.dataname));
    idx2=ceil(idx/numel(CONN_h.menus.m_results.y.dataname));
    if CONN_h.menus.m_results.y.displayvoxels~=2, txt1={sprintf('Effect of %s: %s',CONN_h.menus.m_results.y.condname{idx2}(1:min(100,numel(CONN_h.menus.m_results.y.condname{idx2}))),CONN_h.menus.m_results.y.dataname{idx1}(1:min(100,numel(CONN_h.menus.m_results.y.dataname{idx1}))))}; end
end
end

function [txt1,txt2]=conn_callbackdisplay_denoisingtraces(pos,idx)
global CONN_h;
txt1={};
txt2={};
try
    tempXYZ=CONN_h.menus.m_preproc.tracesXYZ;
    if pos(2)>=1&&pos(2)<=size(tempXYZ,1),
        temp=round(tempXYZ(max(1,min(size(tempXYZ,1), round(pos(2)))),:));
        if ~any(isnan(temp)), txt1={sprintf('scan #%d, sample Grey Matter voxel (%d,%d,%d)',round(pos(1)),temp(1),temp(2),temp(3))}; 
        else txt1={'-'};
        end
    end
end
end
function conn_callbackdisplay_denoisingtracesclick(pos,idx)
global CONN_h;
try
    temp=CONN_h.menus.m_preproc.tracesA;
    tempB=CONN_h.menus.m_preproc.tracesB;
    str=CONN_h.menus.m_preproc.strlabel;
    fh=conn_montage_display(permute(temp(:,:,1),[1,3,4,2]),{[str ' BOLD    Top: before denoising   Bottom: after denoising']},'timeseries');%,tempB,{'GS original','GS after denoising'});
    fh('colormap','gray');
end
end

function [hpatches1,hpatches2]=conn_plotbars(cbeta,CI,M,hax)
if nargin<4||isempty(hax), hax=gca; end
if nargin<3||isempty(M), M=[0 0 0 1 1 1]; end
dx=size(cbeta,1)/(numel(cbeta)+.5*size(cbeta,1));
xx=1*repmat((1:size(cbeta,1))',[1,size(cbeta,2)])+repmat((-(size(cbeta,2)-1)/2:(size(cbeta,2)-1)/2)*dx,[size(cbeta,1),1]);
color=get(hax,'colororder');
color(all(color==1,2),:)=[];%xxd=.4/size(cbeta,2)/2;
hpatches1=zeros(size(cbeta));
hpatches2=zeros(size(cbeta));
for n1=1:numel(xx),
    color0=color(1+rem(ceil(n1/size(cbeta,1))-1,size(color,1)),:);
    h=patch(M(1)+M(4)*(xx(n1)+dx*[-1,-1,1,1]/2.25),M(2)+M(5)*(cbeta(n1)*[0,1,1,0]),M(3)+M(6)*[1 1 1 1], 'k','facecolor',1-(1-color0)/4,'edgecolor','none','parent',hax);
    set(h,'facecolor',color0);
    hpatches1(n1)=h;
    h=line(M(1)+M(4)*(xx(n1)+[1,-1,0,0,1,-1]*dx/8),M(2)+M(5)*(cbeta(n1)+CI(n1)*[-1,-1,-1,1,1,1]),M(3)+M(6)*[2 2 2 2 2 2],'linewidth',2,'color',1-(1-color0)/4,'parent',hax);
    hpatches2(n1)=h;
    set(h,'color','k');
end
end

function str=conn_strexpand(varargin)
if nargin<1, str={}; return; end
str=varargin{1};
changed=false(size(str));
for n1=2:nargin
    for n2=1:min(numel(str),numel(varargin{n1}))
        if ~isempty(varargin{n1}{n2}), changed(n2)=true; str{n2}=[str{n2} ' <i>(' varargin{n1}{n2} ')</i>']; end
    end
end
for n2=find(changed(:))'
    str{n2}=['<HTML>' str{n2} '</HTML>'];
end
end

function str=conn_longcontrastname(names,c)
str='';
n=find(c~=0);
if numel(n)==1&&c(n)==1
    str=names{n};
else
    for n=n(:)'
        str=strcat(str,regexprep(names{n},{'^(.*)',' \+1 \*',' \-1 \*'},{sprintf(' %+g * $1',c(n)),' +',' -'}));
    end
end
end

function conn_menuframe(varargin)
global CONN_gui CONN_x;
ha=axes('units','norm','position',[0,0,1,1]); 
ok=false;
if isfield(CONN_gui,'background')
    try
        if isnumeric(CONN_gui.background)&&size(CONN_gui.background,3)==3, CONN_gui.background_handle=image(CONN_gui.background); ok=true;
        elseif isnumeric(CONN_gui.background)&&~isempty(CONN_gui.background), CONN_gui.background_handle=image(max(0,min(1, conn_bsxfun(@times,(double(CONN_gui.background)-double(min(CONN_gui.background(:))))/(double(max(CONN_gui.background(:)))-double(min(CONN_gui.background(:)))),2*shiftdim(CONN_gui.backgroundcolor,-1))))); ok=true;
        end
    end
end
if ~ok, CONN_gui.background_handle=[]; end; 
%if ~ok, CONN_gui.background_handle=image(max(0,min(1,conn_bsxfun(@plus,(.85-mean(CONN_gui.backgroundcolor))*.2*[zeros(1,128) sin(linspace(0,pi,128)).^2 zeros(1,128)]',shiftdim(CONN_gui.backgroundcolor,-1))))); end
%if ~ok, CONN_gui.background_handle=image(max(0,min(1,conn_bsxfun(@plus,conn_bsxfun(@times,max(.05,(1-mean(CONN_gui.backgroundcolor))*.1)*[zeros(1,128) sin(linspace(0,pi,128)).^4 zeros(1,128)]',shiftdim(CONN_gui.backgroundcolor/max(.01,mean(CONN_gui.backgroundcolor)),-1)),shiftdim(CONN_gui.backgroundcolor,-1))))); end
hc1=uicontextmenu; uimenu(hc1,'label','<HTML>Change GUI font size (<i>Tools.GUI settings</i>)</HTML>','callback','conn(''gui_settings'');'); set(CONN_gui.background_handle,'uicontextmenu',hc1);
axis(ha,'tight','off');
if isfield(CONN_x,'filename')
%     try
        if isempty(CONN_x.filename), a=java.io.File(pwd);
        else a=java.io.File(fileparts(CONN_x.filename));
        end
        k1=a.getUsableSpace;
        k2=a.getTotalSpace;
        k0=a.canWrite;
        clear a;
        k=max(0,min(1, 1-k1/k2));
        c=ones(10,100);
        if k2==0
            c(:)=2;
            str='Storage disconnected or unavailable';
        else
            c(2:end-1,1:round(k*100))=2;
            if k0, str0=''; else str0='(read-only)'; end
            str=sprintf('storage: %.1fGb available (%d%%) %s',(k1*1e-9),round((1-k)*100),str0);
        end
        d=max(0,min(1, mod(conn_bsxfun(@times,1+1*c,shiftdim(CONN_gui.backgroundcolor,-1)),1.1) ));
        d(conn_bsxfun(@plus,[0 2]*numel(c),find(c==2)))=d(conn_bsxfun(@plus,[2 0]*numel(c),find(c==2)));
        ha=axes('units','norm','position',[.425,.0,.05,.020]); ht=image(d); axis(ha,'tight','off'); set(ht,'tag','infoline:bar');
        ht=conn_menu('text0',[.485,.00,.25,.025],'',str);
        set(ht,'horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'color',CONN_gui.fontcolorA,'tag','infoline:text');
        %text(120,(size(c,1))/2,str,'horizontalalignment','left','fontsize',5+CONN_gui.font_offset,'color',[.5 .5 .5]+.0*(mean(CONN_gui.backgroundcolor)<.5));
%     end
end
c=zeros(36,62);
c([149:176 185:212 221:248 257:284 293:320 329:356 509:528 545:564 581:600 617:636 653:672 689:708 869:896 905:932 941:968 977:1004 1013:1040 1049:1076 1229:1234 1239:1256 1265:1270 1275:1292 1301:1306 1311:1328 1337:1342 1347:1364 1373:1378 1383:1400 1409:1414 1419:1436 1589:1594 1599:1616 1625:1630 1635:1652 1661:1666 1671:1688 1697:1702 1707:1724 1733:1738 1743:1760 1769:1774 1779:1796 1805:1810 1841:1846 1877:1882 1913:1918 1949:1954 1985:1990 2021:2026 2057:2062])=1;
c([1239:1256 1275:1292 1311:1328 1347:1364 1383:1400 1419:1436])=2;
c2=zeros(36,52);
c2([75:106 111:142 147:148 177:178 183:184 213:214 219:220 249:250 255:256 285:286 291:292 321:322 327:328 357:358 363:364 393:394 399:400 429:430 435:436 465:466 471:472 501:502 507:508 537:538 543:544 573:574 579:580 609:610 615:616 645:646 651:652 681:682 687:688 717:718 723:724 753:754 759:760 789:790 795:796 825:826 831:832 861:862 867:868 897:898 903:904 933:934 939:940 969:970 975:976 1005:1006 1011:1012 1041:1042 1047:1048 1077:1078 1083:1084 1113:1114 1119:1120 1149:1150 1155:1156 1185:1186 1191:1192 1221:1222 1227:1228 1257:1258 1263:1264 1293:1294 1299:1300 1329:1330 1335:1336 1365:1366 1371:1372 1401:1402 1407:1408 1437:1438 1443:1444 1473:1474 1479:1480 1509:1510 1515:1516 1545:1546 1551:1552 1581:1582 1587:1588 1617:1618 1623:1624 1653:1654 1659:1660 1689:1690 1695:1696 1725:1726 1731:1762 1767:1798])=1;
c2([335:336 350 371:372 386 407:422 443:458 479:494 515:530 551:552 558 565:566 587:588 594 602 623:624 629:630 638 659:660 665:667 673:674 695:697 700:703 709:710 732:746 768:781 805:808 811:817 849:851 875:876 911:912 947:959 983:997 1019:1033 1055:1056 1067:1070 1091:1092 1104:1106 1141:1143 1177:1179 1213:1215 1249:1251 1285:1287 1321:1322 1343:1344 1357:1358 1379:1380 1392:1394 1415:1429 1451:1464 1487:1499 1523:1524 1559:1560])=1.5;
c=[c2 zeros(36,12) c];
%c=[c2 zeros(36,8) [zeros(2,32); kron([0 0 1 1 1 1 1 1;1 1 2 2 2 2 1 1;1 2 3 2 2 3 2 1;1 2 2 0 0 2 2 1;1 2 2 0 0 2 2 1;1 2 2 2 2 3 2 1;1 2 2 2 2 2 1 0;0 1 1 1 1 1 1 0]*2/3,ones(4)); zeros(2,32)] zeros(36,12) c];
b0=shiftdim(CONN_gui.backgroundcolor,-1); 
ha=axes('units','norm','position',[.94,.001,.06,.05],'units','pixels'); 
if isfield(CONN_gui,'background'), b0=conn_guibackground('get',get(ha,'position'),size(c)); end
d=max(0,min(1, conn_bsxfun(@plus,conn_bsxfun(@times,.2*conn_bsxfun(@times,sign(.5-mean(b0,3)),.5+0*rand*ones([1,1,3])),c),b0) ));
hi=image(d); 
axis(ha,'equal','tight','off');

end

function conn_closerequestfcn(varargin)
global CONN_gui CONN_x;
if isfield(CONN_x,'isready')&&any(CONN_x.isready)
    answ=conn_questdlg({'Closing this figure will exit CONN and loose any unsaved progress','Do you want to:'},'Warning','Exit without saving','Save and Exit','Cancel','Save and Exit');
    if isempty(answ), answ='Cancel'; end
else answ='Exit CONN'; 
end
if strcmp(answ,'Save and Exit'), conn save; end
switch(answ)
    case {'Exit CONN','Exit without saving','Save and Exit'}
        CONN_gui.status=1;
        delete(gcbf);
        CONN_x.gui=0;
        try
            if isfield(CONN_gui,'originalCOMB'),javax.swing.UIManager.put('ComboBoxUI',CONN_gui.originalCOMB); end
            if isfield(CONN_gui,'originalBORD'),javax.swing.UIManager.put('ToggleButton.border',CONN_gui.originalBORD); end
            if isfield(CONN_gui,'originalLAF'), javax.swing.UIManager.setLookAndFeel(CONN_gui.originalLAF); end
        end
    otherwise
        conn gui_setup;
end
end

function conn_deletefcn(varargin)
global CONN_gui;
try
    if ~CONN_gui.status
        str=fullfile(pwd,sprintf('CONN_autorecovery_project_%s.mat',datestr(now,'dd-mmm-yyyy-HH-MM-SS')));
        conn('save',str);
        conn_msgbox({'CONN has been closed unexpectedly',' ',sprintf('Autorecovery project created at %s\n',str)},'',2);
    end
end
end

function conn_resizefcn(varargin)
global CONN_h CONN_gui;
try
    CONN_gui.isresizing=true;
    tstate=conn_menumanager(CONN_h.menus.m0,'state');
    switch(find(tstate))
        case 1, conn gui_setup;
        case 2, conn gui_preproc;
        case 3, conn gui_analyses;
        case 4, conn gui_results;
    end
end
CONN_gui.isresizing=false;
end