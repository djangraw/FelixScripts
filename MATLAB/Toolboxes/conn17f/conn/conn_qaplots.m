function filenames=conn_qaplots(qafolder,procedures,validsubjects,validrois,validsets)
% CONN_QAPLOTS creates Quality Assurance plots
% conn_qaplots(outputfolder,procedures,validsubjects,validrois,validsets)
%   outputfolder: target folder where to save plots
%   procedures: numbers from 1/2/3/4/5/11 describing plots to create
%     1:  QA_NORM structural    : structural data + outline of MNI TPM template
%     2:  QA_NORM functional    : mean functional data + outline of MNI TPM template
%     3:  QA_NORM rois          : ROI data + outline of MNI TPM template  
%     4:  QA_REG structural     : structural data + outline of ROI
%     5:  QA_REG functional     : mean functional data + outline of ROI
%     6:  QA_REG mni            : reference MNI structural template + outline of ROI
%     7:  QA_COREG functional   : display same single-slice (z=0) across multiple sessions/datasets
%     8:  QA_TIME functional    : display same single-slice (z=0) across all timepoints within each session
%     9:  QA_TIMEART functional : display same single-slice (z=0) across all timepoints within each session together with ART timeseries (global signal changes and framewise motion)
%     11: QA_DENOISE histogram  : histogram of voxel-to-voxel correlation values (before and after denoising)
%     12: QA_DENOISE timeseries : BOLD signal traces before and after denoising
%     13: QA_DENOISE variability : BOLD signal temporal variability (after denoising)
%   validsubjects: subject numbers to include (defaults to all subjects)
%   validrois: (only for procedures==3,4,5) ROI numbers to include (defaults to WM -roi#2-)
%   validsets: (only for procedures==2,7) functional dataset number (defaults to dataset-0)
%   


global CONN_x;
if nargin<1||isempty(qafolder), qafolder=fullfile(CONN_x.folders.qa,['QA_',datestr(now,'yyyy_mm_dd_HHMMSSFFF')]); end
if nargin<2||isempty(procedures), procedures=11; end
if nargin<3||isempty(validsubjects), validsubjects=1:CONN_x.Setup.nsubjects; end
if nargin<4||isempty(validrois), validrois=2; end %[2,4:numel(CONN_x.Setup.rois.names)-1]; end
if nargin<5||isempty(validsets), validsets=0; end %0:numel(CONN_x.Setup.roifunctional); end
erodedrois=validrois<0;
validrois=abs(validrois);

dpires='-r150'; % dpi resolution of .jpg files

if ~nargout, ht=conn_waitbar(0,'Creating displays. Please wait...'); end
filenames={};
[ok,nill]=mkdir(qafolder);
Nprocedures=numel(procedures);

Iprocedure=1;
if any(procedures==Iprocedure) % QA_NORM structural
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        %conn('gui_setupgo',2);
        %if ~nargout, conn_waitbar('redraw',ht); end
        nsubs=validsubjects;
        sessionspecific=CONN_x.Setup.structural_sessionspecific;
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
            if ~sessionspecific, nsess=1; end
            for nses=1:nsess,
                fh=conn('gui_setupgo',2,14,3,nsub,nses);
                filename=fullfile(qafolder,sprintf('QA_NORM_structural.subject%03d.session%03d.jpg',nsub,nses));
                fh('togglegui',1);
                fh('print',filename,'-nogui',dpires,'-nopersistent');
                state=fh('getstate');
                conn_args={'slice_display',state};
                save(conn_prepend('',filename,'.mat'),'conn_args');
                fh('close');
                filenames{end+1}=filename;
                if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub-1+(nses)/nsess)/numel(nsubs),ht);
                else fprintf('.');
                end
            end
        end
    catch
        disp('warning: unable to create QA_NORM-structural plot');
    end
end

Iprocedure=2;
if any(procedures==Iprocedure) % QA_NORM functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        %conn('gui_setupgo',3);
        %if ~nargout, conn_waitbar('redraw',ht); end
        nsubs=validsubjects;
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            nsess=1; %CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)); % note: for functional data, only show first-session (mean functional already incorporates all session data)
            for nses=1:nsess,
                fhset=conn('gui_setupgo',3,14,4,nsub,nses,validsets);
                for nset=1:numel(fhset)
                    fh=fhset{nset};
                    filename=fullfile(qafolder,sprintf('QA_NORM_functionalDataset%d.subject%03d.session%03d.jpg',validsets(nset),nsub,nses));
                    fh('togglegui',1);
                    fh('print',filename,'-nogui',dpires,'-nopersistent');
                    state=fh('getstate');
                    conn_args={'slice_display',state};
                    save(conn_prepend('',filename,'.mat'),'conn_args');
                    fh('close');
                    filenames{end+1}=filename;
                end
                if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub-1+(nses)/nsess)/numel(nsubs),ht);
                else fprintf('.');
                end
            end
        end
    catch
        disp('warning: unable to create QA_NORM-functional plot');
    end
end

Iprocedure=3;
if any(procedures==Iprocedure) % QA_NORM rois
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        streroded={'','eroded'};
        %conn('gui_setupgo',4);
        %if ~nargout, conn_waitbar('redraw',ht); end
        for ivalidrois=1:numel(validrois)
            nrois=validrois(ivalidrois);
            erois=erodedrois(ivalidrois);
            nsubs=validsubjects;
            if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
            else subjectspecific=1;
            end
            if ~subjectspecific, nsubs=validsubjects(1); end
            if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
            else sessionspecific=CONN_x.Setup.structural_sessionspecific;
            end
            for isub=1:numel(nsubs)
                nsub=nsubs(isub);
                nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                if ~sessionspecific, nsess=1; end
                for nses=1:nsess,
                    fh=conn('gui_setupgo',4,14,6,nrois*(1-2*erois),nsub,nses);
                    filename=fullfile(qafolder,sprintf('QA_NORM_%s.subject%03d.session%03d.jpg',[streroded{erois+1} regexprep(CONN_x.Setup.rois.names{nrois},'\W','')],nsub,nses));
                    fh('togglegui',1);
                    fh('print',filename,'-nogui',dpires,'-nopersistent');
                    state=fh('getstate');
                    conn_args={'slice_display',state};
                    save(conn_prepend('',filename,'.mat'),'conn_args');
                    fh('close');
                    filenames{end+1}=filename;
                    if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(ivalidrois-1+(isub-1+(nses)/nsess)/numel(nsubs))/numel(validrois),ht);
                    else fprintf('.');
                    end
                end
            end
        end
    catch
        disp('warning: unable to create QA_NORM-rois plot');
    end
end

Iprocedure=4;
if any(procedures==Iprocedure) % QA_REG structural
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        streroded={'','eroded'};
        %conn('gui_setupgo',4);
        %if ~nargout, conn_waitbar('redraw',ht); end
        for ivalidrois=1:numel(validrois)
            nrois=validrois(ivalidrois);
            erois=erodedrois(ivalidrois);
            nsubs=validsubjects;
            if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
            else subjectspecific=1;
            end
            %         if ~subjectspecific, nsubs=1; end
            if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
            else sessionspecific=CONN_x.Setup.structural_sessionspecific;
            end
            for isub=1:numel(nsubs)
                nsub=nsubs(isub);
                nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                if ~sessionspecific, nsess=1; end
                for nses=1:nsess,
                    fh=conn('gui_setupgo',4,14,4,nrois*(1-2*erois),nsub,nses);
                    filename=fullfile(qafolder,sprintf('QA_REG_%s_structural.subject%03d.session%03d.jpg',[streroded{erois+1} regexprep(CONN_x.Setup.rois.names{nrois},'\W','')],nsub,nses));
                    fh('togglegui',1);
                    fh('print',filename,'-nogui',dpires,'-nopersistent');
                    state=fh('getstate');
                    conn_args={'slice_display',state};
                    save(conn_prepend('',filename,'.mat'),'conn_args');
                    fh('close');
                    filenames{end+1}=filename;
                    if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(ivalidrois-1+(isub-1+(nses)/nsess)/numel(nsubs))/numel(validrois),ht);
                    else fprintf('.');
                    end
                end
            end
        end
    catch
        disp('warning: unable to create QA_REG-structural plot');
    end
end

Iprocedure=5;
if any(procedures==Iprocedure) % QA_REG functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        streroded={'','eroded'};
        %conn('gui_setupgo',4);
        %if ~nargout, conn_waitbar('redraw',ht); end
        for ivalidrois=1:numel(validrois)
            nrois=validrois(ivalidrois);
            erois=erodedrois(ivalidrois);
            nsubs=validsubjects;
            if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
            else subjectspecific=1;
            end
            %         if ~subjectspecific, nsubs=validsubjects(1); end
            if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
            else sessionspecific=CONN_x.Setup.structural_sessionspecific;
            end
            for isub=1:numel(nsubs)
                nsub=nsubs(isub);
                nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                if ~sessionspecific, nsess=1; end
                for nses=1:nsess,
                    fh=conn('gui_setupgo',4,14,3,nrois*(1-2*erois),nsub,nses);
                    filename=fullfile(qafolder,sprintf('QA_REG_%s_functional.subject%03d.session%03d.jpg',[streroded{erois+1} regexprep(CONN_x.Setup.rois.names{nrois},'\W','')],nsub,nses));
                    fh('togglegui',1);
                    fh('print',filename,'-nogui',dpires,'-nopersistent');
                    state=fh('getstate');
                    conn_args={'slice_display',state};
                    save(conn_prepend('',filename,'.mat'),'conn_args');
                    fh('close');
                    filenames{end+1}=filename;
                    if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(ivalidrois-1+(isub-1+(nses)/nsess)/numel(nsubs))/numel(validrois),ht);
                    else fprintf('.');
                    end
                end
            end
        end
    catch
        disp('warning: unable to create QA_REG-functional plot');
    end
end

Iprocedure=6;
if any(procedures==Iprocedure) % QA_REG mni
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        streroded={'','eroded'};
        %conn('gui_setupgo',4);
        %if ~nargout, conn_waitbar('redraw',ht); end
        for ivalidrois=1:numel(validrois)
            nrois=validrois(ivalidrois);
            erois=erodedrois(ivalidrois);
            nsubs=validsubjects;
            if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
            else subjectspecific=1;
            end
            if ~subjectspecific, nsubs=validsubjects(1); end
            if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
            else sessionspecific=CONN_x.Setup.structural_sessionspecific;
            end
            for isub=1:numel(nsubs)
                nsub=nsubs(isub);
                nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                if ~sessionspecific, nsess=1; end
                for nses=1:nsess,
                    fh=conn('gui_setupgo',4,14,5,nrois*(1-2*erois),nsub,nses);
                    filename=fullfile(qafolder,sprintf('QA_REG_%s_mni.subject%03d.session%03d.jpg',[streroded{erois+1} regexprep(CONN_x.Setup.rois.names{nrois},'\W','')],nsub,nses));
                    fh('togglegui',1);
                    fh('print',filename,'-nogui',dpires,'-nopersistent');
                    state=fh('getstate');
                    conn_args={'slice_display',state};
                    save(conn_prepend('',filename,'.mat'),'conn_args');
                    fh('close');
                    filenames{end+1}=filename;
                    if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(ivalidrois-1+(isub-1+(nses)/nsess)/numel(nsubs))/numel(validrois),ht);
                    else fprintf('.');
                    end
                end
            end
        end
    catch
        disp('warning: unable to create QA_REG-roi plot');
    end
end

Iprocedure=7;
if any(procedures==Iprocedure) % QA_COREG functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        nsubs=validsubjects;
        nslice=[];
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            fh=conn('gui_setupgo',3,14,7,nsub,nslice,validsets);
            filename=fullfile(qafolder,sprintf('QA_COREG_functional.subject%03d.jpg',nsub));
            fh('togglegui',1);
            fh('print',filename,'-nogui',dpires,'-nopersistent');
            state=fh('getstate');
            conn_args={'montage_display',state};
            save(conn_prepend('',filename,'.mat'),'conn_args');
            fh('close');
            filenames{end+1}=filename;
            if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub/numel(nsubs)),ht);
            else fprintf('.');
            end
        end
    catch
        disp('warning: unable to create QA_REG-functional plot');
    end
end

Iprocedure=8;
if any(procedures==Iprocedure) % QA_TIME functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        nsubs=validsubjects;
        nslice=[];
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            fh=conn('gui_setupgo',3,14,8,nsub,[],nslice,validsets,false);
            filename=fullfile(qafolder,sprintf('QA_TIME_functional.subject%03d.jpg',nsub));
            fh('print',filename,'-nogui',dpires,'-nopersistent');
            state=fh('getstate');
            conn_args={'montage_display',state};
            save(conn_prepend('',filename,'.mat'),'conn_args');
            fh('close');
            filenames{end+1}=filename;
            if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub/numel(nsubs)),ht);
            else fprintf('.');
            end
        end
    catch
        disp('warning: unable to create QA_TIME-functional plot');
    end
end

Iprocedure=9;
if any(procedures==Iprocedure) % QA_TIMEART functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        nsubs=validsubjects;
        nslice=[];
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            icov=find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'scrubbing'),1);
            if isempty(icov), error('scrubbing covariate does not exist yet'); end
            icov=0;
%             nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
%             for nses=1:nsess,
%                 fh=conn('gui_setupgo',6,14,2,icov,nsub,nses,nslice,validsets,false);
%                 fh('style','timeseries');
%                 filename=fullfile(qafolder,sprintf('QA_TIMEART_functional.subject%03d.session%03d.jpg',nsub,nses));
                fh=conn('gui_setupgo',6,14,2,icov,nsub,[],nslice,validsets,false);
                filename=fullfile(qafolder,sprintf('QA_TIMEART_functional.subject%03d.jpg',nsub));
                fh('print',filename,'-nogui',dpires,'-nopersistent');
                state=fh('getstate');
                conn_args={'montage_display',state};
                save(conn_prepend('',filename,'.mat'),'conn_args');
                fh('close');
                filenames{end+1}=filename;
%             end
            if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub/numel(nsubs)),ht);
            else fprintf('.');
            end
        end
    catch
        disp('warning: unable to create QA_TIMEART-functional plot');
    end
end

Iprocedure=[11,12];
if any(ismember(procedures,Iprocedure)) % QA_DENOISE
    try
        nprocedures=sum(ismember(procedures,1:min(Iprocedure)-1));
        nsubs=validsubjects;
        filepath=CONN_x.folders.data;
        results_patch={};
        results_stats={};
        results_str={};
        results_label={};
        Npts=100;
        maxa=-inf;
        nl1covariates=[find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'scrubbing'),1) find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'QA_timeseries'),1)];
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
            for nses=1:nsess,
                filename=fullfile(filepath,['ROI_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
                X1{nses}=load(filename);
                filename=fullfile(filepath,['COV_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
                X2{nses}=load(filename);
                filename=fullfile(filepath,['COND_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
                C{nses}=load(filename);
                if ~isequal(CONN_x.Setup.conditions.names(1:end-1),C{nses}.names), error(['Incorrect conditions in file ',filename,'. Re-run previous step']); end
                confounds=CONN_x.Preproc.confounds;
                nfilter=find(cellfun(@(x)max(x),CONN_x.Preproc.confounds.filter));
                if isfield(CONN_x.Preproc,'detrending')&&CONN_x.Preproc.detrending,
                    confounds.types{end+1}='detrend';
                    if CONN_x.Preproc.detrending>=2, confounds.types{end+1}='detrend2'; end
                    if CONN_x.Preproc.detrending>=3, confounds.types{end+1}='detrend3'; end
                end
                [X{nses},ifilter]=conn_designmatrix(confounds,X1{nses},X2{nses},{nfilter});
                if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
                    X{nses}=conn_filter(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub)),CONN_x.Preproc.filter,X{nses});
                elseif nnz(ifilter{1})
                    X{nses}(:,find(ifilter{1}))=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub))),CONN_x.Preproc.filter,X{nses}(:,find(ifilter{1})));
                end
                if size(X{nses},1)~=CONN_x.Setup.nscans{nsub}{nses}, error('Wrong dimensions'); end
                iX{nses}=pinv(X{nses});
                
                x0=X1{nses}.sampledata;
                x0=detrend(x0,'constant');
                x0=x0(:,~all(abs(x0)<1e-4,1)&~any(isnan(x0),1));
                if isempty(x0),
                    disp('Warning! No temporal variation in BOLD signal within sampled grey-matter voxels');
                end
                
                x1=x0;
                if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==1,
                    my=repmat(median(x1,1),[size(x1,1),1]);
                    sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                    x1=my+sy.*tanh((x1-my)./max(eps,sy));
                end
                x1=x1-X{nses}*(iX{nses}*x1);
                if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==2,
                    my=repmat(median(x1,1),[size(x1,1),1]);
                    sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                    x1=my+sy.*tanh((x1-my)./max(eps,sy));
                end
                [x1,fy]=conn_filter(max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub))),CONN_x.Preproc.filter,x1);
                fy=mean(abs(fy(1:round(size(fy,1)/2),:)).^2,2);
                %dof=max(0,sum(fy)^2/sum(fy.^2)-size(X{nses},2)); % change dof displayed to WelchSatterthwaite residual dof approximation
                dof1=max(0,sum(fy)^2/sum(fy.^2)); % WelchSatterthwaite residual dof approximation
                if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2, dof2=max(0,size(x0,1)*(min(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub)))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub)))))+0-size(X{nses},2));
                elseif nnz(ifilter{1}), dof2=max(0,(size(x0,1)-size(X{nses},2)+nnz(ifilter{1}))*(min(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub)))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub)))))+0-nnz(ifilter{1}));
                else dof2=max(0,(size(x0,1)-size(X{nses},2))*(min(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub)))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub)))))+0);
                end
                if any(procedures==11)
                    z0=corrcoef(x0);z1=corrcoef(x1);z0=(z0(z0~=1));z1=(z1(z1~=1));
                    [a0,b0]=hist(z0(:),linspace(-1,1,Npts));[a1,b1]=hist(z1(:),linspace(-1,1,Npts));
                    maxa=max(maxa,max(max(a0),max(a1)));
                    if isempty(z0)||isempty(z1),
                        disp('Warning! Empty correlation data');
                    else
                        results_patch={[b1(1),b1,b1(end)],[0,a1,0],[0,a0,0]};
                        results_stats=[mean(z0(z0~=1)),std(z0(z0~=1)),mean(z1(z1~=1)),std(z1(z1~=1)),dof2,dof1];
                        tstr=sprintf('subject %d. session %d',nsub,nses);
                        results_str=[tstr sprintf(' before denoising: mean %f std %f; after denoising: mean %f std %f (dof=%.1f, dof_WS=%.1f)',mean(z0(z0~=1)),std(z0(z0~=1)),mean(z1(z1~=1)),std(z1(z1~=1)),dof2,dof1)];
                        results_label=tstr;
                    end
                    filename=fullfile(qafolder,sprintf('QA_DENOISE.subject%03d.session%03d.mat',nsub,nses));
                    save(filename,'results_patch','results_stats','results_label','results_str');
                end

                if any(procedures==12)&&numel(nl1covariates)>1, 
                    temp=permute([x0 nan(size(x0,1),10) x1],[2,3,4,1]);
                    tdata=CONN_x.Setup.l1covariates.files{nsub}{nl1covariates(1)}{nses}{3};
                    tdata=sum(tdata,2);
                    tdata=cat(2,CONN_x.Setup.l1covariates.files{nsub}{nl1covariates(end)}{nses}{3},tdata);
                    fh=conn_montage_display(temp,{sprintf('Subject %d Session %d   Top: before denoising   Bottom: after denoising',nsub,nses)},'timeseries',tdata,{'GS changes','Movement','Outliers'});
                    fh('colormap','gray');
                    filename=fullfile(qafolder,sprintf('QA_DENOISE_timeseries.subject%03d.session%03d.jpg',nsub,nses));
                    fh('print',filename,'-nogui',dpires,'-nopersistent');
                    state=fh('getstate');
                    conn_args={'montage_display',state};
                    save(conn_prepend('',filename,'.mat'),'conn_args');
                    fh('close');
                end
            end
            if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*isub/numel(nsubs),ht);
            else fprintf('.');
            end
        end
    catch
        disp('warning: unable to create QA_DENOISE plot');
    end
    %filename=fullfile(qafolder,sprintf('QA_DENOISE.mat'));
    %save(filename,'results_patch','results_stats','results_label','results_str');
end

if ~nargout, conn_waitbar('close',ht);
else fprintf('\n');
end
fprintf('QA plots stored in folder %s\n',qafolder);

