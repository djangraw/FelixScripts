function conn_print(varargin)
persistent printoptions;

if isempty(printoptions), printoptions={'-djpeg90','-r600','-opengl'}; end
answ=varargin;
if ~isempty(answ)&&numel(answ{1})==1&&ishandle(answ{1})&&strcmp(get(answ{1},'type'),'figure'), hfig=answ{1}; answ=answ(2:end); 
elseif any(strcmp(answ,'-spm')), hfig=spm_figure('FindWin','Graphics');if isempty(hfig)||~ishandle(hfig), return; end; answ=answ(~strcmp(answ,'-spm'));
else hfig=gcf;
end
warning('off','MATLAB:print:CustomResizeFcnInPrint');
set(hfig,'inverthardcopy','off');
units=get(hfig,{'units','paperunits'});
set(hfig,'units','points');
set(hfig,'paperunits','points','paperpositionmode','manual','paperposition',get(hfig,'position'));
set(hfig,{'units','paperunits'},units);
if any(strcmp(answ,'-nogui')), dogui=false; answ=answ(~strcmp(answ,'-nogui'));
else dogui=true;
end
if any(strcmp(answ,'-nopersistent')), persistentoptions=false; answ=answ(~strcmp(answ,'-nopersistent'));
else persistentoptions=true;
end
charansw=find(cellfun(@ischar,answ));
if any(cellfun('length',regexp(answ(charansw),'^-r\d+$'))), printoptions{2}=answ{charansw(cellfun('length',regexp(answ(charansw),'^-r\d+$'))>0)}; answ(charansw(cellfun('length',regexp(answ(charansw),'^-r\d+$'))>0))=[]; end
if numel(answ)<1, answ{1}='print01.jpg'; end
charansw=find(cellfun(@ischar,answ));
if any(cellfun(@(x)any(strcmp(x,{'-mosaic','-column','-row','-mosaic3','-mosaic8'})),answ(charansw)))
    idx=charansw(find(cellfun(@(x)any(strcmp(x,{'-mosaic','-column','-row','-mosaic3','-mosaic8'})),answ(charansw)),1));
    mosaic_commands=answ(idx+1:end);
    if any(strcmp(answ,'-mosaic')), mosaic_type=1; if numel(mosaic_commands)~=4, error('incorrect number of arguments for print -mosaic option'); end
    elseif any(strcmp(answ,'-column')), mosaic_type=2; %if numel(mosaic_commands)~=4, error('incorrect number of arguments for print -column option'); end
    elseif any(strcmp(answ,'-row')), mosaic_type=3; %if numel(mosaic_commands)~=4, error('incorrect number of arguments for print -row option'); end
    elseif any(strcmp(answ,'-mosaic8')), mosaic_type=4; if numel(mosaic_commands)~=8, error('incorrect number of arguments for print -mosaic8 option'); end
    elseif any(strcmp(answ,'-mosaic3')), mosaic_type=5; if numel(mosaic_commands)~=3, error('incorrect number of arguments for print -mosaic3 option'); end
    end
    answ=answ(1:idx-1);
else
    mosaic_commands={};
end
if numel(answ)<2, answ(1+(1:numel(printoptions)))=printoptions; end

if dogui
    answ=inputdlg({'Output file','Print options (see ''help print'')'},...
        'print options',1,...
        {answ{1},strtrim(sprintf('%s ',answ{2:end}))});
else
    answ={answ{1},strtrim(sprintf('%s ',answ{2:end}))};
end
if ~isempty(answ)
    filename=answ{1};
    if dogui&&~isempty(dir(filename))
        tansw=conn_questdlg({'Output file already exist','Overwrite existing file?'},'','Yes','No','Yes');
        if ~strcmp(tansw,'Yes'), return; end
    end
    PRINT_OPTIONS=regexp(strtrim(answ{2}),'\s+','split');
    if persistentoptions, printoptions=PRINT_OPTIONS; end
    oldpointer=get(hfig,'pointer');
    set(hfig,'pointer','watch');
    if ~isempty(mosaic_commands)
        hw=waitbar(0,'Printing. Please wait...');
        set(hw,'handlevisibility','off','hittest','off','color','w');
        domosaiccrop=true;
        a={};
        for n1=1:numel(mosaic_commands)
            if iscell(mosaic_commands{n1}), feval(mosaic_commands{n1}{1},[],[],mosaic_commands{n1}{2:end});
            elseif ishandle(mosaic_commands{n1}), feval(mosaic_commands{n1});
            else eval(mosaic_commands{n1});
            end
            drawnow;
            print(hfig,PRINT_OPTIONS{:},filename);
            b=imread(filename);
            if isa(b,'uint8'), b=double(b)/255; end
            if max(b(:))>1, b=double(b)/double(max(b(:))); end
            a{n1}=double(b);
            waitbar(n1/numel(mosaic_commands),hw);
            set(hw,'handlevisibility','off');
        end
        if domosaiccrop
            cropt_idx={};
            for n=1:numel(a)
                cropt=any(any(diff(a{n},1,2),2),3);
                cropt_idx{n,1}=max(1,sum(~cumsum(cropt))-16):size(a{n},1)-max(0,sum(~cumsum(flipud(cropt)))-16);
                cropt=any(any(diff(a{n},1,1),1),3);
                cropt_idx{n,2}=max(1,sum(~cumsum(cropt))-16):size(a{n},2)-max(0,sum(~cumsum(flipud(cropt)))-16);
            end
        end
        switch mosaic_type
            case 1, %mosaic
                if domosaiccrop
                    cropt_idx13=union(cropt_idx{1,1},cropt_idx{3,1});
                    cropt_idx12=union(cropt_idx{1,2},cropt_idx{2,2});
                    cropt_idx24=union(cropt_idx{2,1},cropt_idx{4,1});
                    cropt_idx34=union(cropt_idx{3,2},cropt_idx{4,2});
                    a=[a{1}(cropt_idx13,cropt_idx12,:),a{3}(cropt_idx13,cropt_idx34,:);a{2}(cropt_idx24,cropt_idx12,:),a{4}(cropt_idx24,cropt_idx34,:)];
                else
                    a=[a{1},a{3};a{2},a{4}];
                end
            case 2, % col
                if domosaiccrop
                    cropt_idx1234=cropt_idx{1,2}; for n=2:numel(a), cropt_idx1234=union(cropt_idx1234,cropt_idx{n,2}); end
                    ta=[]; for n=1:numel(a), ta=cat(1,ta,a{n}(cropt_idx{n,1},cropt_idx1234,:)); end; a=ta;
                    %cropt_idx1234=union(union(union(cropt_idx{1,2},cropt_idx{2,2}),cropt_idx{3,2}),cropt_idx{4,2});
                    %a=[a{1}(cropt_idx{1,1},cropt_idx1234,:);a{2}(cropt_idx{2,1},cropt_idx1234,:);a{3}(cropt_idx{3,1},cropt_idx1234,:);a{4}(cropt_idx{4,1},cropt_idx1234,:)];
                else
                    a=cat(1,a{:});
                    %a=[a{1};a{2};a{3};a{4}];
                end
            case 3, % row
                if domosaiccrop
                    cropt_idx1234=cropt_idx{1,1}; for n=2:numel(a), cropt_idx1234=union(cropt_idx1234,cropt_idx{n,1}); end
                    ta=[]; for n=1:numel(a), ta=cat(2,ta,a{n}(cropt_idx1234,cropt_idx{n,2},:)); end; a=ta;
                    %cropt_idx1234=union(union(union(cropt_idx{1,1},cropt_idx{2,1}),cropt_idx{3,1}),cropt_idx{4,1});
                    %a=[a{1}(cropt_idx1234,cropt_idx{1,2},:),a{2}(cropt_idx1234,cropt_idx{2,2},:),a{3}(cropt_idx1234,cropt_idx{3,2},:),a{4}(cropt_idx1234,cropt_idx{4,2},:)];
                else
                    a=cat(2,a{:});
                    %a=[a{1},a{2},a{3},a{4}];
                end
            case 4,%mosaic8
                if domosaiccrop
                    cropt_idx14=union(cropt_idx{1,1},cropt_idx{3,1});
                    cropt_idx25=union(cropt_idx{2,1},cropt_idx{4,1});
                    cropt_idx36=union(cropt_idx{3,1},cropt_idx{6,1});
                    cropt_idx123=union(union(cropt_idx{1,2},cropt_idx{2,2}),cropt_idx{3,2});
                    cropt_idx456=union(union(cropt_idx{4,2},cropt_idx{5,2}),cropt_idx{6,2});
                    cropt_idx78=union(cropt_idx{7,2},cropt_idx{8,2});
                    a={[a{1}(cropt_idx14,cropt_idx123,:);a{2}(cropt_idx25,cropt_idx123,:);a{3}(cropt_idx36,cropt_idx123,:)],[a{7}(cropt_idx{7,1},cropt_idx78,:);a{8}(cropt_idx{8,1},cropt_idx78,:)],[a{4}(cropt_idx14,cropt_idx456,:);a{5}(cropt_idx25,cropt_idx456,:);a{6}(cropt_idx36,cropt_idx456,:)]};
                else
                    a={[a{1};a{1};a{3}],[a{7};a{8}],[a{4};a{5};a{6}]};
                end
                a=[a{1} [a{2} ;repmat(a{1}(1,1,:),[size(a{1},1)-size(a{2},1),size(a{2},2)])] a{3}];
            case 5, %mosaic3
                if domosaiccrop
                    cropt_idx13=union(cropt_idx{1,1},cropt_idx{3,1});
                    cropt_idx12=union(cropt_idx{1,2},cropt_idx{2,2});
                    cropt_idx24=cropt_idx{2,1};
                    cropt_idx34=cropt_idx{3,2};
                    a=[a{1}(cropt_idx13,cropt_idx12,:),a{3}(cropt_idx13,cropt_idx34,:);a{2}(cropt_idx24,cropt_idx12,:),repmat(a{1}(cropt_idx13(1),cropt_idx12(1),:),numel(cropt_idx24),numel(cropt_idx34))];
                else
                    a=[a{1},a{3};a{2},repmat(a{1}(cropt_idx13(1),cropt_idx12(1),:),numel(cropt_idx24),numel(cropt_idx34))];
                end
        end
        imwrite(a,filename);
        delete(hw);
    else
        drawnow;
        print(hfig,PRINT_OPTIONS{:},filename);
    end
    disp(['Saved file: ',filename]);
    if dogui
        try
            if 1
                if ispc, winopen(filename);
                else     system(['open "',filename,'"']);
                end
            else
                a=imread(filename);
                hf=figure('name',['printed file ',filename],'numbertitle','off','color','w');
                imagesc(a); ht=title(filename); set(ht,'interpreter','none'); axis equal tight; set(gca,'box','on','xtick',[],'ytick',[]); set(hf,'handlevisibility','off','hittest','off');
            end
        end
    end
    set(hfig,'pointer',oldpointer);
end
end
