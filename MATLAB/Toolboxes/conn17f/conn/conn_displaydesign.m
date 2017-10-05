function conn_displaydesign(varargin)
% internal function (used by conn.m gui)

global CONN_h;
dataAll=CONN_h.menus.m_results.design.data;
hfig=figure('units','norm','position',[.6 .15 .4 .8],'color',[1 1 1],'name','second-level design display','numbertitle','off','menubar','none','colormap',[1 1 1; jet(256)]);
hax1=axes('units','norm','position',[.05 .1 .45 .8],'parent',hfig);
x0=CONN_h.menus.m_results.design.designmatrix;
c0=CONN_h.menus.m_results.design.contrast_between;
m0=CONN_h.menus.m_results.design.contrast_within;
[h,f,p,dof,statsname]=conn_glm(CONN_h.menus.m_results.design.designmatrix,randn(size(CONN_h.menus.m_results.design.data)),CONN_h.menus.m_results.design.contrast_between,CONN_h.menus.m_results.design.contrast_within);
try, 
    if max(abs(1-x0*(pinv(x0)*ones(size(x0,1),1))))>1e-6, uicontrol('style','text','units','norm','position',[0.,.95,1,.05],'string',{'WARNING: possibly incorrect model: no constant term modeled','(suggestion: add AllSubjects term to selected subject-effects list)'}); end; 
    if any(dof<=0), uicontrol('style','text','units','norm','position',[0.,.95,1,.05],'string',{'WARNING: possibly incorrect model: insufficient degrees of freedom','(suggestion: simplify second-level model)'}); end; 
end
if isequal(statsname,'X'), statsname=['Chi' char(178)]; end
hu0=uicontrol('style','popup','units','norm','position',[.05 0 .9 .05],'string',{'Multivariate model','Univariate model (SPM)'},'value',1);
hu1=uicontrol('style','text','units','norm','position',[.55 .05 .4 .2],'backgroundcolor','w','max',2,'horizontalalignment','left','parent',hfig);
hu2=uicontrol('style','popup','units','norm','position',[.55 .90 .40 .05],'string','','value',1,'parent',hfig);
hu3=uicontrol('style','popup','units','norm','position',[.55 .85 .40 .05],'string','','value',1,'parent',hfig);
hu4=uicontrol('style','listbox','units','norm','position',[.55 .3 .40 .55],'string','','parent',hfig);
set([hu0 hu2,hu3],'callback',@conn_displaydesign_update);
if CONN_h.menus.m_results.design.designmultivariateonly||size(CONN_h.menus.m_results.design.data,2)==1, set(hu0,'visible','off'); end
hlabel=uicontrol('style','text','horizontalalignment','left','visible','off');
label={};
set(hfig,'units','pixels','windowbuttonmotionfcn',@conn_displaydesign_mousemove);
conn_displaydesign_update;

    function conn_displaydesign_update(varargin)
        v0=get(hu0,'value');
        switch(v0)
            case 1,
                x=x0; 
                data=dataAll;
                c=c0;
                m=m0;
            case 2,
                x=kron(eye(size(dataAll,2)),x0);
                data=dataAll(:);
                c=kron(m0,c0);
                m=1;
        end
        pmode=2;
        nx=size(x);
        ndat=size(data);
        ncon=size(c,1);
        nm=size(m,1);
        xplot=conn_bsxfun(@rdivide,x,max(eps,max(abs(x),[],1)));
        cplot=c/max([eps,max(abs(c(:)))]);
        mplot=m/max([eps,max(abs(m(:)))]);
        label={};
        img=[];
        if pmode==1, img(max(ncon,nm)+1+(1:ndat(1)),2+(1:ndat(2)))=reshape(linspace(1,256,ndat(1)*ndat(2)),ndat(1),ndat(2));
        else img(max(ncon,nm)+1+(1:ndat(1)),2+(1:ndat(2)))=256;
        end
        img(max(ncon,nm)+1+(1:ndat(1)),2+ndat(2)+2+(1:nx(2)))=128.5+127.5*xplot;
        img(max(ncon,nm)-ncon+(1:ncon),2+ndat(2)+2+(1:nx(2)))=128.5+127.5*cplot;
        if ~isequal(m,1), img(max(ncon,nm)-nm+(1:nm),2+(1:ndat(2)))=128.5+127.5*mplot; end
        label(max(ncon,nm)+1+(1:ndat(1)),2+(1:ndat(2)))=data;
        label(max(ncon,nm)+1+(1:ndat(1)),2+ndat(2)+2+(1:nx(2)))=arrayfun(@num2str,x,'uni',0);
        label(max(ncon,nm)-ncon+(1:ncon),2+ndat(2)+2+(1:nx(2)))=arrayfun(@num2str,c,'uni',0);
        if ~isequal(m,1), label(max(ncon,nm)-nm+(1:nm),2+(1:ndat(2)))=arrayfun(@num2str,m,'uni',0); end
        img(:,end+2)=0;
        cla(hax1);
        if pmode==1, hi=image(1+img,'parent',hax1);
        else
            timg=max(-1,min(1,(img-128.5)/127.5));
            timg=(-1+2*(timg>=0)).*(.1+.7*abs(timg));
            timg(img==0)=nan;
            [nill,hi]=conn_menu_plotmatrix(timg,'parent',hax1);
        end
        axis(hax1,'equal','off');
        set(hax1,'ydir','reverse','xlim',[.5 size(img,2)+.5],'ylim',[.5 size(img,1)+.5]);
        hold on;
        ht1=text(2-.02*max(size(img)),max(ncon,nm)+1+ndat(1)/2,'Data (Y)','rotation',90,'horizontalalignment','center','parent',hax1);
        ht2=text(2+ndat(2)+2+nx(2)+1+.02*max(size(img)),max(ncon,nm)+1+ndat(1)/2,'Design matrix (X)','horizontalalignment','center','rotation',90,'parent',hax1);
        if ~isequal(m,1), 
            ht3=text(2+ndat(2)+2+nx(2)/2+1,0-.02*max(size(img)),'contrast (C)','horizontalalignment','center','parent',hax1);
            ht4=text(2+ndat(2)/2+1,0-.02*max(size(img)),'contrast (M)','horizontalalignment','center','parent',hax1); 
            %ht3=text(2+ndat(2)+2+nx(2)/2+1,0-.02*max(size(img)),'between- (C)','horizontalalignment','center','parent',hax1);
            %ht4=text(2+ndat(2)/2+1,0-.02*max(size(img)),'within- (M)','horizontalalignment','center','parent',hax1); 
            %ht5=text(2-.02*max(size(img)),.5+max(ncon,nm)/2,'Contrasts','rotation',90,'horizontalalignment','center','parent',hax1); 
            %ht5=text(2-.02*max(size(img)),.5+max(ncon,nm)/2,{'Within-samples','contrast (M)'},'rotation',90,'horizontalalignment','center','parent',hax1); 
            %ht3=text(2+ndat(2)+2+nx(2)+1+.02*max(size(img)),.5+max(ncon,nm)/2,{'Between-samples','contrast (C)'},'rotation',90,'horizontalalignment','center','parent',hax1);
        else 
            ht3=text(2+ndat(2)+2+nx(2)/2+1,0-.02*max(size(img)),'Contrast (C)','horizontalalignment','center','parent',hax1);
        end
        hold off;
        if ~isequal(m,1)
            set(hu2,'string',{'Data (Y)','Design matrix (X)','Between-samples contrast (C)','Within-samples contrast (M)'});
            strtemp0='Null Hypothesis: C * B * M'' = 0'; strtemp1=sprintf('Independent samples. Statistic: %s(%s)',statsname,mat2str(dof));
        else
            set(hu2,'string',{'Data (Y)','Design matrix (X)','Contrast (C)'});
            strtemp0='Null Hypothesis: C * B = 0'; 
            if v0==1, strtemp1=sprintf('Independent samples. Statistic: %s(%s)',statsname,mat2str(dof));
            else      strtemp1='Nonindependent samples (ReML)';
            end
        end
        set(hu1,'string',{'Model: Y = X * B', strtemp0,strtemp1, ' ', sprintf('%d samples',ndat(1)),sprintf('%d outcome measures',ndat(2)),sprintf('%d predictors (%d independent)',nx(2),rank(x)),sprintf('%d null-hypothesis constrains (%d independent)',ncon*nm,rank(m)*rank(x*c'))});
        v1=get(hu2,'value');
        switch(v1)
            case 1, set(hu3,'string',arrayfun(@(n)sprintf('Column %d',n),1:ndat(2),'uni',0),'value',min(get(hu3,'value'),ndat(2)));
            case 2, set(hu3,'string',arrayfun(@(n)sprintf('Column %d',n),1:nx(2),'uni',0),'value',min(get(hu3,'value'),nx(2)));
            case 3, set(hu3,'string',arrayfun(@(n)sprintf('Column %d',n),1:nx(2),'uni',0),'value',min(get(hu3,'value'),nx(2)));
            case 4, set(hu3,'string',arrayfun(@(n)sprintf('Column %d',n),1:ndat(2),'uni',0),'value',min(get(hu3,'value'),ndat(2)));
        end
        v2=get(hu3,'value');
        switch(v1)
            case 1, set(hu4,'string',strcat(arrayfun(@(n)sprintf('Row %d = ',n),(1:ndat(1))','uni',0),data(:,v2)),'value',min(get(hu4,'value'),ndat(1)));
            case 2, set(hu4,'string',arrayfun(@(n,m)sprintf('Row %d = %g',n,m),(1:ndat(1))',x(:,v2),'uni',0),'value',min(get(hu4,'value'),ndat(1)));
            case 3, set(hu4,'string',arrayfun(@(n,m)sprintf('Row %d = %g',n,m),(1:ncon)',c(:,v2),'uni',0),'value',min(get(hu4,'value'),ncon));
            case 4, set(hu4,'string',arrayfun(@(n,m)sprintf('Row %d = %g',n,m),(1:nm)',m(:,v2),'uni',0),'value',min(get(hu4,'value'),nm));
        end
    end                
    function conn_displaydesign_mousemove(varargin)
        p1=get(0,'pointerlocation');
        p2=get(hfig,'position');
        p3=get(0,'screensize');
        p4=p2(1:2)+p3(1:2)-1; % note: fix issue when connecting to external monitor/projector
        pos0=(p1-p4);
        set(hfig,'currentpoint',pos0);
        pos=round(get(hax1,'currentpoint'));
        pos=pos(1,1:3);
        if pos(1)>=1&&pos(1)<=size(label,2)&&pos(2)>=1&&pos(2)<=size(label,1)&&~isempty(label{pos(2),pos(1)}), 
            tlabel=label{pos(2),pos(1)};
            set(hlabel,'units','pixels','position',[pos0+[10 -10] 20 20],'visible','on','string',tlabel);
            hext=get(hlabel,'extent'); 
            nlines=ceil(hext(3)/(p2(3)/2));
            ntlabel=numel(tlabel);
            set(hlabel,'position',[pos0+[10 -10] min(p2(3)/2,hext(3)) nlines*hext(4)],'string',reshape([tlabel,repmat(' ',1,nlines*ceil(ntlabel/nlines)-ntlabel)]',[],nlines)');
        else set(hlabel,'visible','off','string','');
        end
    end
end

