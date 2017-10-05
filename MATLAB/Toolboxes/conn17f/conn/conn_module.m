function varargout=conn_module(option,varargin)

% CONN_MODULE provides 3rd-party access to independent CONN modules 
%
% conn_module(module_name, ...) runs individual CONN's module "module_name" on user-defined data
% Current module names:
%
%    PREPROCESSING : runs CONN preprocessing pipeline on user-defined data (see help conn_setup_preproc)
%       e.g. conn_module('preprocessing',...
%             'steps','default_mni',...
%             'functionals',{'./func.nii'},...
%             'structurals',{'./anat.nii'},...
%             'RT',2,...
%             'sliceorder','interleaved (Siemens)');
%       runs default MNI-space preprocessing pipeline on the specified functional/structural data
%       see conn_batch help: batch.Setup.preprocessing fields for additional options
%       
%       Additional functionality:
%          conn_module('get','structurals');            outputs current structural files (e.g. output of structural preprocessing steps)
%          conn_module('get','functionals');            outputs current functional files (e.g. output of functional preprocessing steps)
%          conn_module('get','l1covariates');           outputs first-level covariate files (e.g. other potential outputs of functional preprocessing)
%          conn_module('get','l1covariates',covname);   outputs covname first-level covariate files (e.g. other potential outputs of functional preprocessing)
%          conn_module('get','masks');                  outputs Grey Matter/White Matter/CSF files (e.g. other potential outputs of functional preprocessing)
%          conn_module('get','masks',roiname);          outputs roiname files (e.g. other potential outputs of functional preprocessing)
%
%    GLM           : runs CONN second-level analyses on user-defined data (see help conn_module_glm)
%       e.g. conn_module('glm',...
%             [1; 1; 1; 1] ,...
%             {'subject1.img'; 'subject2.img'; 'subject3.img'; 'subject4.img'} );
%       performs a one-sample t-test and stores the analysis results in the current folder
%


varargout={[]};
switch(lower(option))
    
    case 'get'
        names={};
        switch(lower(varargin{1}))
            case 'structurals',
                files=conn('get','Setup.structural');
                for nsub=1:numel(files),
                    if conn('get','Setup.structural_sessionspecific'),
                        for nses=1:nsessall,
                            files{nsub}{nses}=files{nsub}{nses}{1};
                        end
                    else
                        files{nsub}=files{nsub}{1}{1};
                    end
                end
            case 'functionals',
                files=conn('get','Setup.functional');
                for nsub=1:numel(files),
                    for nses=1:numel(files{nsub}),
                        files{nsub}{nses}=files{nsub}{nses}{1};
                    end
                end
            case 'l1covariates',
                data=conn('get','Setup.l1covariates');
                files={};
                for nsub=1:numel(data.files),
                    for ncov=1:numel(data.files{nsub}),
                        for nses=1:numel(data.files{nsub}{ncov}),
                            files{ncov}{nsub}{nses}=data.files{nsub}{ncov}{nses}{1};
                        end
                    end
                end
                for ncov=1:numel(data.names)-1,
                    names{ncov}=data.names{ncov};
                end
                if numel(varargin)>1,
                    icov=find(ismember(names,cellstr(varargin{2})));
                    if numel(icov)==1,
                        names=names{icov};
                        files=files{icov};
                    else
                        names=names(icov);
                        files=files(icov);
                    end
                end
            case 'masks',
                data=conn('get','Setup.rois');
                files={};
                for nsub=1:numel(data.files),
                    for nroi=1:min(3, numel(data.files{nsub})),
                        for nses=1:numel(data.files{nsub}{nroi}),
                            files{nroi}{nsub}{nses}=data.files{nsub}{nroi}{nses}{1};
                        end
                    end
                end
                for nroi=1:min(3, numel(data.names)-1),
                    names{nroi}=data.names{nroi};
                end
                if numel(varargin)>1,
                    iroi=find(ismember(names,cellstr(varargin{2})));
                    if numel(iroi)==1,
                        names=names{iroi};
                        files=files{iroi};
                    else
                        names=names(iroi);
                        files=files(iroi);
                    end
                end
            otherwise
                files=conn('get',varargin{:});
        end
        varargout={files,names};

    case 'set'
        try
            switch(lower(varargin{1}))
                case 'structurals',
                    conn_batch('Setup.structurals',varargin{2});
                case 'functionals',
                    conn_batch('Setup.functionals',varargin{2});
                case 'l1covariates',
                    files=varargin{2};
                    names=varargin{3};
                    if ~iscell(names),
                        names={names};
                        files={files};
                    end
                    data.names={};
                    data.files={};
                    for ncov=1:numel(files),
                        for nsub=1:numel(files{ncov}),
                            for nses=1:numel(files{ncov}{nsub}),
                                data.files{nsub}{ncov}{nses}=conn_file(files{ncov}{nsub}{nses});
                            end
                        end
                    end
                    for ncov=1:numel(names),
                        data.names{ncov}=names{ncov};
                    end
                    data.names{numel(names)+1}=' ';
                    conn('set','Setup.l1covariates',data);
                case 'rois',
                    files=varargin{2};
                    names=varargin{3};
                    if ~iscell(names),
                        names={names};
                        files={files};
                    end
                    data.names={};
                    data.files={};
                    for nroi=1:min(3, numel(files)),
                        for nsub=1:numel(files{nroi}),
                            for nses=1:numel(files{nroi}{nsub}),
                                data.files{nsub}{nroi}{nses}=conn_file(files{nroi}{nsub}{nses});
                            end
                        end
                    end
                    for nroi=1:min(3, numel(names)),
                        data.names{nroi}=names{nroi};
                    end
                    data.names{numel(names)+1}=' ';
                    conn('set','Setup.rois.files',data.files);
                    conn('set','Setup.rois.names',data.names);
                otherwise
                    files=conn('set',varargin{:});
            end
        end
        
    case 'preprocessing'
        batch=[];
        if isstruct(varargin{1})
            batch=varargin{1};
            varargin=varargin(2:end);
        end
        for n=1:2:numel(varargin)-1
            str=regexp(varargin{n},'\.','split');
            batch=setfield(batch,str{:},varargin{n+1});
        end
        Batch=struct;
        if isfield(batch,'functionals')&&~isfield(batch,'nsubjects'), batch.nsubjects=numel(batch.functionals); end
        if isfield(batch,'structurals')&&~isfield(batch,'nsubjects'), batch.nsubjects=numel(batch.structurals); end
        if isfield(batch,'parallel'),
            str=fullfile(pwd,sprintf('CONN_module_%s%s.mat',datestr(now,'dd-mmm-yyyy-HHMMSSFFF'),char(floor('0'+10*rand(1,8)))));
            Batch.filename=str;
            Batch.Setup.isnew=true;
        elseif isfield(batch,'nsubjects')&&~isfield(batch,'filename')
            conn('init');
            conn('set','filename','');
        end
        if isfield(batch,'functionals')
            if ~iscell(batch.functionals), batch.functionals={batch.functionals}; end
            for nsub=1:numel(batch.functionals),
                if ~iscell(batch.functionals{nsub}), batch.functionals{nsub}={batch.functionals{nsub}}; end
            end
        end
        if isfield(batch,'structurals')
            if ~iscell(batch.structurals), batch.structurals={batch.structurals}; end
            for nsub=1:numel(batch.structurals),
                if ~iscell(batch.structurals{nsub}), batch.structurals{nsub}={batch.structurals{nsub}}; end
            end
        end
        Fields={'functionals','structurals','nsubjects','RT','unwarp_functionals','coregsource_functionals'}; % send these to Setup
        for n=1:numel(Fields)
            if isfield(batch,Fields{n}),
                Batch.Setup.(Fields{n})=batch.(Fields{n});
                batch=rmfield(batch,Fields{n});
            elseif isfield(batch,lower(Fields{n})),
                Batch.Setup.(Fields{n})=batch.(lower(Fields{n}));
                batch=rmfield(batch,lower(Fields{n}));
            end
        end
        Fields=fieldnames(batch);
        for n=1:numel(Fields)
            if any(strcmp(Fields{n},{'filename','parallel','subjects'})), % leave these in root
                Batch.(Fields{n})=batch.(Fields{n});
                batch=rmfield(batch,Fields{n});
            else,                                                         % send others to Setup.preprocessing
                Batch.Setup.preprocessing.(Fields{n})=batch.(Fields{n});
                batch=rmfield(batch,Fields{n});
            end
        end
        conn_batch(Batch);
        
    otherwise
        if ~isempty(which(sprintf('conn_module_%s',option))),
            fh=eval(sprintf('@conn_%s',option));
            [varargout{1:nargout}]=feval(fh,varargin{:});
        else
            disp(sprintf('unrecognized option %s or conn_module_%s function',option,option));
        end
end
end
