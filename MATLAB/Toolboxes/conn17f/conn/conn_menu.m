
function [h,h2,htb]=conn_menu(type,position,title,string,tooltipstring,callback,callback2)

global CONN_gui CONN_h;
persistent nullstr;

if isempty(nullstr), nullstr=''; end
h=[];h2=[];htb=[];
nmax=500;
if nargin<2 || isempty(position), position=[0,0,0,0]; end
if nargin<3, title=''; end
if nargin<4, string=''; end
if nargin<5, tooltipstring=''; end
if nargin<6, callback=''; end
if nargin<7, callback2=''; end
if ~ischar(type), [type,position,title]=deal(title,get(type,'userdata'),get(type,'value')); end
if ~CONN_gui.tooltips, tooltipstring=''; end
titleopts={'fontname','Arial','fontangle','normal','fontweight','normal','foregroundcolor',CONN_gui.fontcolorA,'fontsize',9+CONN_gui.font_offset};
titleopts2=titleopts;titleopts2(7:8)={'color',CONN_gui.fontcolorA};
contropts={'fontname','Arial','fontangle','normal','fontweight','normal','foregroundcolor',CONN_gui.fontcolorB,'fontsize',8+CONN_gui.font_offset};
contropts2=contropts;contropts2(7:8)={'color',CONN_gui.fontcolorA};
doemphasis1=CONN_gui.doemphasis1;
doemphasis2=CONN_gui.doemphasis2;
if any(strcmpi(type,{'pushbutton2','togglebutton2','edit2','textedit2','listbox2','text2','title2','popup2','checkbox2','image2','imagep2','imageonly2','frame2','frame2border','frame2noborder','popup2big','pushbuttonblue2'})), bgcolor=CONN_gui.backgroundcolor; mapcolor=CONN_h.screen.colormap;
else bgcolor=CONN_gui.backgroundcolorA; mapcolor=CONN_h.screen.colormapA;
end
switch(lower(type)),
    case 'nullstr',
        nullstr=position;
	case {'pushbutton','togglebutton','pushbutton2','togglebutton2','pushbuttonblue','pushbuttonblue2'}
        type2=regexprep(type,{'2$','blue$'},'');
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,.03,0,0],'string',title,'backgroundcolor',bgcolor,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
		if strcmp(lower(type2),'togglebutton')&&CONN_gui.domacGUIbugfix==2, bgcolor(:)=1; end
        h=uicontrol('style',type2,'units','norm','position',position,'backgroundcolor',bgcolor,'horizontalalignment','left','string',string,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:},'fontweight','bold');
        if ismember(lower(type),{'pushbuttonblue','pushbuttonblue2'}), set(h,'backgroundcolor',CONN_gui.backgroundcolorE); end
        set(h,'units','pixels');
        tpos=get(h,'position');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-2*CONN_gui.uicontrol_border,0,2*CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,2*CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm')];
        set(h,'units','norm');
        if doemphasis1, conn_menumanager('onregion',htb,-1,get(h,'position'),h); end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
% 	case {'pushbutton2','togglebutton2'}
%         if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
% 		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,.03,0,0],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','center'); end
%         bgcolor=CONN_gui.backgroundcolorA;
% 		if strcmp(lower(type),'togglebutton2')&&CONN_gui.domacGUIbugfix==2, bgcolor(:)=1; end
% 		h=uicontrol('style',regexprep(type,'2$',''),'units','norm','position',position,'backgroundcolor',bgcolor,'horizontalalignment','left','string',string,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
%         set(h,'units','pixels');
%         tpos=get(h,'position');
%         htb=[uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
%             uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
%             uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm'),...
%             uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm')];
%         set(h,'units','norm');
%         %conn_menumanager('onregion',htb,-1,get(h,'position'),h);
%         if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case {'edit','edit2','textedit','textedit2'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,.03,0,0],'string',title,'backgroundcolor',bgcolor,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
		h=uicontrol('style','edit','units','norm','position',position,'backgroundcolor',bgcolor,'horizontalalignment','left','string',string,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        if strcmp(lower(type),'textedit')||strcmp(lower(type),'textedit2'), set([h h2],'horizontalalignment','center'); end
        set(h,'units','pixels');
        tpos=get(h,'position');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-CONN_gui.uicontrol_border-2,0,CONN_gui.uicontrol_border+2-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
             uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
        	 uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,CONN_gui.uicontrol_border+1-tpos(4)],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
        	 uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm')];
        set(h,'units','norm');
        if ~strcmp(lower(type),'textedit')&&~strcmp(lower(type),'textedit2')
            if doemphasis1, conn_menumanager('onregion',htb(3:4),-1,get(h,'position'),h); end
            if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
        end
	case 'edit0'
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,.03,0,0],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        bgcolor=CONN_gui.backgroundcolorA; %min(1,CONN_gui.backgroundcolorA*5*min(2*(position(2)+.5*position(4)),2-2*(position(2)+.5*position(4))).^2);
		h=uicontrol('style','edit','units','norm','position',position,'backgroundcolor',bgcolor,'horizontalalignment','left','string',string,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,'max',2,contropts{:});
        set(h,'units','pixels');
        tpos=get(h,'position');
        set(h,'units','norm');
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-18,0,18-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm')];
        conn_menumanager('onregion',htb,-1,get(h,'position'),h);
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm')];
        uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,CONN_gui.uicontrol_border+1-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
        if doemphasis1, conn_menumanager('onregion',htb,-1,get(h,'position'),h); end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case {'listbox','listbox2','listboxbigblue'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',bgcolor,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        if isempty(string), string=' '; end
        if strcmpi(type,'listboxbigblue'), bgcolor=.75*bgcolor+.25*(2/6*.5+.5*[1/6,2/6,4/6]); end
		h=uicontrol('style','listbox','units','norm','position',position,'foregroundcolor',.0+1.0*([0 0 0]+(mean(bgcolor)<.5)),'backgroundcolor',bgcolor,'string',string,'max',1,'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        if strcmpi(type,'listboxbigblue'), set(h,'fontsize',13+CONN_gui.font_offset); end
        set(h,'units','pixels');
        tpos=get(h,'position');
        tpos2=get(h,'extent');
%         set(h,'position',tpos+[0,0,18,0]);
%         tpos=get(h,'position');
        set(h,'units','norm');
%         position1=get(h,'position');
        ht=[uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,CONN_gui.uicontrol_border+1-tpos(4)],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
        	uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm')];
        if doemphasis1, conn_menumanager('onregion',ht,-1,get(h,'position')+~isempty(callback2)*[0 -.04 0 0],h); end
        ht=uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,tpos2(4)-tpos(4)],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm');
        conn_menumanager('onregion',ht,-1,get(h,'position')+~isempty(callback2)*[0 -.04 0 0],h);
        ht=uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-18,0,18-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm');
        %conn_menumanager('onregion',ht,-1,get(h,'position'),@(x)get(h,'extent')*max(1,(get(h,'max')==1)*numel(cellstr(get(h,'string'))))*[0;0;0;1]>=get(h,'position')*[0;0;0;1]);
        conn_menumanager('onregion',ht,-1,get(h,'position'));
        if ~isempty(callback2), 
            if ~iscell(callback2), callback2={['h=get(gcbo,''userdata''); set(h,''value'',numel(cellstr(get(h,''string'')))); ',callback],callback2}; end
            ht=[conn_menu(regexprep(type,'listbox','pushbutton'),position+[0 -.04 .02-position(3) .04-position(4)],'','+',['Adds new ',lower(title)],callback2{1}),...
                conn_menu(regexprep(type,'listbox','pushbutton'),position+[.02 -.04 .02-position(3) .04-position(4)],'','-',['Removes selected ',lower(title)],['if isequal(conn_questdlg(''Are you sure you want to delete the selected ',lower(title),'?'','''',''Yes'',''No'',''Yes''),''Yes''), ',callback2{2},'; end'])];
            set(ht,'userdata',h,'fontweight','bold','visible','off');
            conn_menumanager('onregion',ht,1,get(h,'position')+[0 -.04 0 0],h);
        end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case 'listbox0',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolor,titleopts{:},'fontname','monospaced','horizontalalignment','left'); end
		h=uicontrol('style','listbox','units','norm','position',position,'backgroundcolor',CONN_gui.backgroundcolor,'string',string,'max',1,'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        set(h,'units','pixels');
        tpos=get(h,'position');
        tpos2=get(h,'extent');
%         set(h,'position',tpos+[0,0,18,0]);
%         tpos=get(h,'position');
        set(h,'units','norm');
%         position1=get(h,'position');
        htb=uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-18,0,18-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolor,'backgroundcolor',CONN_gui.backgroundcolor,'units','norm');
        conn_menumanager('onregion',htb,-1,get(h,'position'),h);
%             conn_menumanager('onregion',htb,-1,get(h,'position'),@(x)set(h,'position',position+(~x)*(position1-position)));
        uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolor,'backgroundcolor',CONN_gui.backgroundcolor,'units','norm');
        uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,tpos2(4)-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolor,'backgroundcolor',CONN_gui.backgroundcolor,'units','norm');
        uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolor,'backgroundcolor',CONN_gui.backgroundcolor,'units','norm');
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
	case {'text','text2'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',bgcolor,titleopts{:},'fontunits','norm','horizontalalignment','center'); end
		h=uicontrol('style','text','units','norm','position',position,'backgroundcolor',bgcolor,'string',string,'tooltipstring',tooltipstring,'max',2,'horizontalalignment','center',contropts{:});
    case 'text0',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
        ht=axes('units','norm','position',position,'visible','off');
        h=text(0,0,string,'horizontalalignment','left','verticalalignment','middle',contropts2{:});
        set(ht,'xlim',[-.01,1],'ylim',[-1,1]);
    case 'text0c',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
        ht=axes('units','norm','position',position,'visible','off');
        h=text(0,0,string,'horizontalalignment','center','verticalalignment','middle',contropts2{:});
        set(ht,'xlim',[-1,1],'ylim',[-1,1]);
	case {'title','title2'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		h=uicontrol('style','text','units','norm','position',position,'string',title,'backgroundcolor',bgcolor,titleopts{:},'fontunits','norm','horizontalalignment','right'); 
	case {'popup','popup2','popupbig','popup2big','popupbigblue','popupblue'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.03-position(4)],'string',title,'backgroundcolor',bgcolor,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        if 0,%CONN_gui.domacGUIbugfix==1,%&&mean(bgcolor)<.5,
            try
                drawnow;
                originalLnF = javax.swing.UIManager.getLookAndFeel;
                javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
                %javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.nimbus.NimbusLookAndFeel');
                %javax.swing.UIManager.setLookAndFeel('com.jgoodies.looks.plastic.PlasticLookAndFeel');
            catch
                CONN_gui.domacGUIbugfix=2;
            end
        end
        xtraborder=0;
        opts=contropts;
        if strcmpi(type,'popupbigblue')||strcmpi(type,'popupblue'), bgcolor=CONN_gui.backgroundcolorE; end %opts=titleopts; end %.75*bgcolor+.25*(2/6*.5+.5*[1/6,2/6,4/6]); end
		h=uicontrol('style','popupmenu','units','norm','position',position,'backgroundcolor',bgcolor,'string',cellstr(string),'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,opts{:});
        if any(strcmp(lower(type),{'popup2big','popupbig','popupbigblue'})), set(h,'fontsize',13+CONN_gui.font_offset,'fontweight','bold'); xtraborder=1; end
        if CONN_gui.domacGUIbugfix==2,
            set(h,'backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0]);
        end
		if 0,%CONN_gui.domacGUIbugfix==1,%&&mean(bgcolor)<.5, 
           drawnow;
           javax.swing.UIManager.setLookAndFeel(originalLnF);
        end
        set(h,'units','pixels');
        tpos=get(h,'position');
        tpos2=get(h,'extent');
        tpos=tpos+[0,tpos(4)-tpos2(4)-3*CONN_gui.uicontrol_border,0,tpos2(4)-tpos(4)+3*CONN_gui.uicontrol_border]; 
        %uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-2,0,2-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
        
        %uicontrol('style','checkbox','units','pixels','position',tpos+[tpos(3)-18,tpos(4)-12,10-tpos(3),10-tpos(4)],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'cdata',max(0,min(1,conn_bsxfun(@plus,shiftdim(bgcolor,-1),conn_bsxfun(@times,shiftdim(bgcolor-bgcolor,-1),[0 0 0 0 0 0 0;0 0 0 0 0 0 0;1 1 1 1 1 1 1;0 1 1 1 1 1 0;0 0 1 1 1 0 0;0 0 0 1 0 0 0;0 0 0 0 0 0 0;0 0 0 0 0 0 0])))),'units','norm');
        htb=[];
        htb=[uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-CONN_gui.uicontrol_borderpopup,0,CONN_gui.uicontrol_borderpopup-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0,CONN_gui.uicontrol_border-tpos(3),0],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,0-xtraborder,0,3+CONN_gui.uicontrol_border-tpos(4)+xtraborder],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm'),...
            uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-CONN_gui.uicontrol_border,0,CONN_gui.uicontrol_border-tpos(4)],'foregroundcolor',bgcolor,'backgroundcolor',bgcolor,'units','norm')];
        %uicontrol('style','frame','units','pixels','position',tpos+[0-3,tpos(4)-11,3-tpos(3),3-tpos(4)],'foregroundcolor',CONN_gui.fontcolorB,'backgroundcolor',CONN_gui.fontcolorB,'units','norm');
        set(h,'units','norm');
        if doemphasis1, conn_menumanager('onregion',htb,-1,get(h,'position'),h); end
        if doemphasis2, conn_menumanager('onregion',h,0,get(h,'position')); end
        %if doemphasis2&&~(strcmpi(type,'popupbigblue')||strcmpi(type,'popupblue')), conn_menumanager('onregion',h,0,get(h,'position')); end
	case {'checkbox','checkbox2'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[position(3),0,.15-position(3),0],'string',title,'backgroundcolor',bgcolor,contropts{:},'fontunits','norm','horizontalalignment','left'); hext=get(h2,'extent'); hext=hext(end-1:end); set(h2,'position',position+[position(3),0,max(.05,min(hext(1),.15))-position(3),0]); else hext=[0 0]; end
        if ischar(string),string={string}; end
        for n1=1:numel(string), 
            h(n1)=uicontrol('style','checkbox','units','norm','position',position-[0,position(4)*(n1-1),0,0],'backgroundcolor',bgcolor,'string',string{n1},'value',1,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:}); 
            hext2=get(h(n1),'extent'); hext2=hext2(end-1:end);
            if doemphasis2, hpos=get(h(n1),'position'); conn_menumanager('onregion',[h2 h(n1)],0,hpos+[0 0 max(hext,hext2)-hpos(3:4)]); end
        end
	case 'checkbox0',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','left'); end
        if ischar(string),string={string}; end
        if ischar(tooltipstring), tooltipstring=repmat({tooltipstring},1,numel(string)); end
        for n1=1:numel(string), 
            h(n1)=uicontrol('style','checkbox','units','norm','position',position-[0,position(4)*(n1-1),0,0],'backgroundcolor',CONN_gui.backgroundcolorA,'string',string{n1},'value',1,'tooltipstring',tooltipstring{n1},'interruptible','off','callback',callback,contropts{:}); 
            if doemphasis2, conn_menumanager('onregion',h(n1),0,get(h(n1),'position')); end
        end
    case 'slider',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		h=uicontrol('style','slider','units','norm','position',position,'foregroundcolor','w','backgroundcolor',CONN_gui.backgroundcolorA,'tooltipstring',tooltipstring,'interruptible','off','callback',callback,contropts{:});
        try, if iscell(callback)&&~isempty(callback), addlistener(h, 'ContinuousValueChange',@(varargin)feval(callback{1},h,[],callback{2:end})); end; end
%         set(h,'units','pixels');
%         tpos=get(h,'position');
%         uicontrol('style','frame','units','pixels','position',tpos+[tpos(3)-2,0,2-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
%         uicontrol('style','frame','units','pixels','position',tpos+[0,0,2-tpos(3),0],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
%         uicontrol('style','frame','units','pixels','position',tpos+[0,0,0,2-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
%         uicontrol('style','frame','units','pixels','position',tpos+[0,tpos(4)-2,0,2-tpos(4)],'foregroundcolor',CONN_gui.backgroundcolorA,'backgroundcolor',CONN_gui.backgroundcolorA,'units','norm');
%         set(h,'units','norm');
	case 'axes',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','center'); end
		h=axes('units','norm','position',position,'visible','off'); 
	case {'image','image2','imagep','imagep2','imageonly','imageonly2'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), 
            %h.htitle=uicontrol('style','text','units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,0,0,.04],'string',title,'backgroundcolor',bgcolor,titleopts{:},'fontunits','norm','horizontalalignment','center'); 
            ht=axes('units','norm','position',position+[0,position(4),0,.04-position(4)],'visible','off');
            h.htitle=text(0,0,title,titleopts2{:},'horizontalalignment','center','verticalalignment','middle','interpreter','none'); 
            set(ht,'xlim',[-1,1],'ylim',[-1,1]);
            h2=h.htitle;
        end
        if any(strcmpi(type,{'imagep','imagep2'})), data=struct('n',[],'thr',.001,'cscale',1,'x0',[],'x1',[],'p',1,'view',[],'viewselect',false); 
        else data=struct('n',[],'thr',.25,'cscale',1,'x0',[],'x1',[],'p',0,'view',[],'viewselect',false); 
        end
        h.mapcolor=mapcolor;
        h.maxvolsdisplayed=2;
        h.hnill=[];
		h.h21=axes('units','norm','position',position+[.01*position(3),0,-.02*position(3),0],'color',bgcolor,'xtick',[],'ytick',[]);  axis off;
		h.h22=text(0,0,nullstr,'fontsize',14+CONN_gui.font_offset,'horizontalalignment','center','clipping','on','color',.3+[0 0 0]+.4*(mean(bgcolor)>.5));%[0.54 0.14 0.07]);
        set(h.h21,'xlim',[-1,1],'ylim',[-1,1],'xtick',[],'ytick',[]);
		h.h1=axes('units','norm','position',position,'xtick',[],'ytick',[]); 
		h.h2=image(shiftdim(bgcolor,-1)); 
        hold on; h.h2b=plot(.5+zeros(2),.5+zeros(2),'w','color',0*[1 1 1],'linewidth',2); h.h2b=h.h2b(:)'; hold off;
        hold on; h.h2c=plot(0,0,'k+'); h.h2c=h.h2c(:)'; hold off;
		%h.h6=text(0,0,'','fontsize',8+CONN_gui.font_offset,'color','k','backgroundcolor','w'); 
        if ~any(strcmpi(type,{'imageonly','imageonly2'}))
            h.h3=axes('units','norm','position',position+0*[.1*position(3),0,-.2*position(3),0]);
            h.h4=plot(0,zeros(1,nmax))';
            hold on; h.h4b=plot(0,nan,':o','color',[.1 .1 .1]+.8*(.5>mean(CONN_gui.backgroundcolor))); hold off;
        else h.h3=[]; h.h4=[]; h.h4b=[];
        end
		h.h11=axes('units','norm','position',position+[.02*position(3),0,-.04*position(3),0],'color',bgcolor,'xtick',[],'ytick',[]); 
		h.h12=patch(struct('vertices',[],'faces',[]),'edgecolor','none','facecolor','w','specularstrength',0,'backFaceLighting','lit');
        h.h13=[light('position',[1000 0 .1]) light('position',[-1000 0 .1])];
        hc1=uicontextmenu;
        uimenu(hc1,'Label','Superior view','callback','set(gca,''cameraposition'',[0 0 1000],''cameraupvector'',[0 1 0])');
        uimenu(hc1,'Label','Inferior view','callback','set(gca,''cameraposition'',[0 0 -1000],''cameraupvector'',[0 1 0])');
        uimenu(hc1,'Label','Anterior view','callback','set(gca,''cameraposition'',[0 1000 0],''cameraupvector'',[0 0 1])');
        uimenu(hc1,'Label','Posterior view','callback','set(gca,''cameraposition'',[0 -1000 0],''cameraupvector'',[0 0 1])');
        set([h.h11 h.h12],'uicontextmenu',hc1);
		h.h5=conn_menu('slider',[position(1)+position(3)-0*.015,position(2),.015,max(.001,position(4)-.04)],'','','',{@conn_menu,'updateslider1'});
        h.h5b=uicontrol('style','pushbutton','string','o','units','norm','position',[position(1)+position(3)+.25*.015,position(2)+position(4)-.03,.65*.015,.65*.03],'tooltipstring','switch view (axial/coronal/sagittal)','callback',{@conn_menu,'updateview'});
        %h.h5b=conn_menu('pushbuttonblue',[position(1)+position(3)-0*.015,position(2)+position(4)-.04,.015,.04],'','','switch view',{@conn_menu,'updateview'});
        %try, addlistener(h.h5, 'ContinuousValueChange',@(varargin)conn_menu([],[],'updateslider1')); end
		%h.h6=conn_menu('slider',[position(1),position(2)-.035,position(3),.03],'','','display threshold',{@conn_menu,'updateslider2'});
        %set(h.h6,'min',0,'max',1,'value',data.thr);
		%h.h5=uicontrol('style','slider','units','norm','position',[position(1)+position(3)-0*.015,position(2),.015,position(4)],'callback',{@conn_menu,'updateslider1'},'backgroundcolor',bgcolor);
		%h.h6=uicontrol('style','slider','units','norm','position',[position(1),position(2)-.03,position(3),.03],'min',0,'max',1,'callback',{@conn_menu,'updateslider2'},'backgroundcolor',bgcolor,'value',data.thr);
		%h.h7=axes('position',[position(1)+0*.015,position(2)-.06,position(3)-0*.03,.02],'color',bgcolor); 
		h.h7=axes('position',[position(1)-.01,position(2)+position(4)*.15,.01,position(4)*.7],'color',bgcolor,'xtick',[],'ytick',[]); 
		h.h8=image((1:128)'); 
        [h.h9,nill,h.h9a]=conn_menu(regexprep(type,'imagep?','edit'),[position(1)-.01,position(2)+position(4)*.85+.001,.01,.035],'',num2str(data.cscale),'display colorscale',{@conn_menu,'updatecscale'});
        [h.h10,nill,h.h10a]=conn_menu(regexprep(type,'imagep?','edit'),[position(1)+position(3)/2,position(2)-1*.05,min(position(3)/4,.05),.04],'',num2str(data.thr),'display threshold',{@conn_menu,'updatethr'});
		h.h6a=uicontrol('units','norm','position',[.0001 .0001 .0001 .0001],'style','text','fontsize',8+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','horizontalalignment','left'); 
        conn_menumanager('onregion',h.h6a,1,position,h.h2,@(varargin)conn_menubuttonmtnfcn('volume',gcf,h.h1,h.h2,h.h6a,h.h2c,varargin{:}));
		h.h6b=uicontrol('units','norm','position',[.0001 .0001 .0001 .0001],'style','text','fontsize',8+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','horizontalalignment','left'); 
        if ~isempty(h.h3), 
            conn_menumanager('onregion',h.h6b,1,position,h.h3,@(varargin)conn_menubuttonmtnfcn('line',gcf,h.h3,h.h4,h.h6b,h.h4b,varargin{:})); 
            conn_menumanager('onregion',h.h4b,1,position,h.h3);
        end
        h.hcallback=callback;
        h.hcallback2=callback2;
		%h.h9=uicontrol('style','edit','units','norm','position',[position(1)-.015,position(2)+position(4),.02,.04],'callback',{@conn_menu,'updatecscale'},'backgroundcolor',bgcolor,'string',num2str(data.cscale),'fontsize',8+CONN_gui.font_offset); 
		%h.h10=uicontrol('style','edit','units','norm','position',[position(1)+position(3)-.1,position(2)-1*.05,.1,.04],'callback',{@conn_menu,'updatethr'},'backgroundcolor',bgcolor,'foregroundcolor',.0+1.0*([0 0 0]+(mean(bgcolor)<.5)),'string',num2str(data.thr),'fontsize',8+CONN_gui.font_offset); 
		set(h.h1,'color',bgcolor,'xtick',[],'ytick',[],'xcolor',bgcolor,'ycolor',bgcolor); 
		set(h.h3,'color',bgcolor,'xtick',[],'ytick',[],'xcolor',bgcolor,'ycolor',bgcolor,'visible','off'); 
		set(h.h7,'color',bgcolor,'xtick',[],'ytick',[64.5],'yticklabel',{'0'},'xcolor',bgcolor,'ycolor',bgcolor,'visible','off','ydir','normal'); 
		set(h.h11,'color',bgcolor,'xtick',[],'ytick',[],'xcolor',bgcolor,'ycolor',bgcolor,'zcolor',bgcolor,'visible','off'); 
		set(h.h9,'backgroundcolor',bgcolor,'foregroundcolor',.0+1.0*([0 0 0]+(mean(bgcolor)<.5)),'visible','off'); 
		set([h.h4,h.h4b,h.h5,h.h5b,h.h6a,h.h6b,h.h7,h.h8,h.h9,h.h9a,h.h10,h.h10a,h.h11],'visible','off'); 
		set([h.h5,h.h5b,h.h9,h.h10],'userdata',h);
		set([h.h2],'userdata',data);
% 	case 'image2',
%         if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
% 		if ~isempty(title), 
%             ht=axes('units','norm','position',position+[0,position(4),0,.04-position(4)],'visible','off');
%             h.htitle=text(0,0,title,titleopts2{:},'horizontalalignment','center','verticalalignment','middle'); 
%             set(ht,'xlim',[-1,1],'ylim',[-1,1]);
%             %h.htitle=uicontrol('style','text','units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,0,0,.04],'string',title,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'backgroundcolor',CONN_gui.backgroundcolorA,titleopts{:},'fontunits','norm','horizontalalignment','center'); 
%         end
% 		data=struct('n',[],'thr',.001,'cscale',1,'x0',[],'x1',[],'p',0); 
% 		h.h21=axes('units','norm','position',position+[.01*position(3),0,-.02*position(3),0],'color',CONN_gui.backgroundcolorA); axis off;
% 		h.h22=text(0,0,nullstr,'fontsize',14+CONN_gui.font_offset,'horizontalalignment','center','color',.3+[0 0 0]+.4*(mean(CONN_gui.backgroundcolorA)>.5),'clipping','on');
%         set(h.h21,'xlim',[-1,1],'ylim',[-1,1],'xtick',[],'ytick',[]);
% 		h.h1=axes('units','norm','position',position); 
% 		h.h2=image(shiftdim(CONN_gui.backgroundcolorA,-1)); 
%         hold on; h.h2b=plot(.5+zeros(2),.5+zeros(2),'k','color',0*[1 1 1],'linewidth',2); h.h2b=h.h2b(:)'; hold off;
%         hold on; h.h2c=plot(0,0,'k+'); h.h2c=h.h2c(:)'; hold off;
% 		%h.h6=text(0,0,'','fontsize',8+CONN_gui.font_offset,'color','k','backgroundcolor','w'); 
% 		h.h3=axes('units','norm','position',position+[.1*position(3),0,-.2*position(3),0]); 
% 		h.h4=plot(0,zeros(1,nmax))';
% 		hold on; h.h4b=plot(0,nan,':o','color',[.1 .1 .1]+.8*(.5>mean(CONN_gui.backgroundcolor))); hold off;
% 		h.h11=axes('units','norm','position',position+[.02*position(3),0,-.04*position(3),0],'color',CONN_gui.backgroundcolorA); 
% 		h.h12=patch(struct('vertices',[],'faces',[]),'edgecolor','none','facecolor','w','specularstrength',0,'backFaceLighting','lit');
%         h.h13=[light('position',[1000 0 .1]) light('position',[-1000 0 .1])];
%         hc1=uicontextmenu;
%         uimenu(hc1,'Label','Superior view','callback','set(gca,''cameraposition'',[0 0 1000],''cameraupvector'',[0 1 0])');
%         uimenu(hc1,'Label','Inferior view','callback','set(gca,''cameraposition'',[0 0 -1000],''cameraupvector'',[0 1 0])');
%         uimenu(hc1,'Label','Anterior view','callback','set(gca,''cameraposition'',[0 1000 0],''cameraupvector'',[0 0 1])');
%         uimenu(hc1,'Label','Posterior view','callback','set(gca,''cameraposition'',[0 -1000 0],''cameraupvector'',[0 0 1])');
%         set([h.h11 h.h12],'uicontextmenu',hc1);
% 		h.h5=conn_menu('slider',[position(1)+position(3)-0*.015,position(2),.015,position(4)],'','','z-slice',{@conn_menu,'updateslider1'});
% 		%h.h6=conn_menu('slider',[position(1),position(2)-.035,position(3),.03],'','','display threshold',{@conn_menu,'updateslider2'});
%         %set(h.h6,'min',0,'max',1,'value',data.thr);
% 		%h.h5=uicontrol('style','slider','units','norm','position',[position(1)+position(3)-0*.015,position(2),.015,position(4)],'callback',{@conn_menu,'updateslider1'},'backgroundcolor',CONN_gui.backgroundcolorA);
% 		%h.h6=uicontrol('style','slider','units','norm','position',[position(1),position(2)-.03,position(3),.03],'min',0,'max',1,'callback',{@conn_menu,'updateslider2'},'backgroundcolor',CONN_gui.backgroundcolorA,'value',data.thr);
% 		%h.h7=axes('position',[position(1)+0*.015,position(2)-.06,position(3)-0*.03,.02],'color',CONN_gui.backgroundcolorA); 
% 		h.h7=axes('position',[position(1)-.01,position(2),.01,position(4)],'color',CONN_gui.backgroundcolorA); 
% 		h.h8=image((1:128)'); 
%         [h.h9,nill,h.h9a]=conn_menu('edit',[position(1)-.01,position(2)+position(4),.02,.04],'',num2str(data.cscale),'display colorscale',{@conn_menu,'updatecscale'});
%         [h.h10,nill,h.h10a]=conn_menu('edit',[position(1)+position(3)-.1,position(2)-1*.05,.05,.04],'',num2str(data.thr),'display threshold',{@conn_menu,'updatethr'});
% 		h.h6a=uicontrol('units','norm','position',[.0001 .0001 .0001 .0001],'style','text','fontsize',8+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','horizontalalignment','left');
%         conn_menumanager('onregion',h.h6a,1,position,h.h2,@(varargin)conn_menubuttonmtnfcn('volume',gcf,h.h1,h.h2,h.h6a,h.h2c));
% 		h.h6b=uicontrol('units','norm','position',[.0001 .0001 .0001 .0001],'style','text','fontsize',8+CONN_gui.font_offset,'foregroundcolor','k','backgroundcolor','w','horizontalalignment','left'); 
%         conn_menumanager('onregion',h.h6b,1,position,h.h3,@(varargin)conn_menubuttonmtnfcn('line',gcf,h.h3,h.h4,h.h6b,h.h4b));
%         conn_menumanager('onregion',h.h4b,1,position,h.h3);
%         h.hcallback=callback;
% 		%h.h9=uicontrol('style','edit','units','norm','position',[position(1)-.015,position(2)+position(4),.02,.04],'callback',{@conn_menu,'updatecscale'},'backgroundcolor',CONN_gui.backgroundcolorA,'string',num2str(data.cscale)); 
% 		%h.h10=uicontrol('style','edit','units','norm','position',[position(1)+position(3)-.1,position(2)-1*.05,.1,.04],'callback',{@conn_menu,'updatethr'},'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'string',num2str(data.thr)); 
% 		set(h.h1,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA); 
% 		set(h.h3,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'ycolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'visible','off'); 
% 		set(h.h7,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[64.5],'yticklabel',{'0'},'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA,'visible','off','ydir','normal'); 
% 		set(h.h9,'backgroundcolor',CONN_gui.backgroundcolorA,'foregroundcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'visible','off'); 
% 		set(h.h11,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA,'zcolor',CONN_gui.backgroundcolorA,'visible','off'); 
% 		set([h.h4,h.h4b,h.h5,h.h6a,h.h6b,h.h7,h.h8,h.h9,h.h9a,h.h10,h.h10a,h.h11],'visible','off'); 
% 		set([h.h5,h.h9,h.h10],'userdata',h);
% 		set([h.h2],'userdata',data);
	case 'scatter',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolor,titleopts{:},'fontunits','norm','horizontalalignment','center'); end
		h.h1=axes('units','norm','position',position,'fontsize',8+CONN_gui.font_offset); 
		hold on; h.h2=plot(zeros(2,64),zeros(2,64),'.'); hold off;
        h.h2=fliplr(h.h2(:)');
		hold on; h.h3=plot(0,0,'w:'); hold off;
        h.mapcolor=mapcolor;
        set(h.h2(1),'color',.75/2*[1,1,1]);set(h.h2(2),'color',1/2*[1,1,0]); 
        set(h.h2(3),'color',.75/4*[1,1,1]);set(h.h2(4),'color',1/4*[1,1,0]); 
		set(h.h1,'color',CONN_gui.backgroundcolor,'xcolor',.5+0.0*([0 0 0]+(mean(CONN_gui.backgroundcolor)<.5)),'ycolor',.5+0.0*([0 0 0]+(mean(CONN_gui.backgroundcolor)<.5)),'visible','off'); 
        grid(h.h1,'on');
        set([h.h1,h.h2,h.h3],'visible','off');
	case 'hist',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), h2=uicontrol('style','text','units','norm','position',position+[0,position(4),0,.04-position(4)],'string',title,'backgroundcolor',CONN_gui.backgroundcolor,titleopts{:},'fontunits','norm','horizontalalignment','center'); end
		h.h1=axes('units','norm','position',position,'fontsize',8+CONN_gui.font_offset); 
		hold on; h.h2=plot([0,0],[0,0],'k:'); hold off;
		h.h3=patch(0,0,'k'); 
		h.h4=patch(0,0,'k'); 
		h.h5=patch(0,0,'k'); 
		h.h6=text(0,0,'original','fontsize',8+CONN_gui.font_offset); 
		h.h7=text(0,0,'after denoising','fontsize',8+CONN_gui.font_offset); 
        h.mapcolor=mapcolor;
		set(h.h1,'color',CONN_gui.backgroundcolor,'ytick',[],'xcolor',.5+0.0*([0 0 0]+(mean(CONN_gui.backgroundcolor)<.5)),'ycolor',CONN_gui.backgroundcolor,'visible','off'); 
        set([h.h1,h.h2,h.h3,h.h4,h.h5,h.h6,h.h7],'visible','off');
	case 'filesearch',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		h=conn_filesearchtool('position',[.78,.10,.20,.80],'backgroundcolor',CONN_gui.backgroundcolor,titleopts{:},...
			'title',title,'filter',string,'callback',callback,'max',1);
	case 'filesearchlocal',
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		h=conn_filesearchtool('position',[.78,.10,.20,.80],'backgroundcolor',CONN_gui.backgroundcolor,titleopts{:},...
			'title',title,'filter',string,'callback',callback,'max',1,'localcopy',1);
	case {'frame','frame2','frame2noborder','frame2border'}
        if ~isequal(CONN_h.screen.hfig,gcf), figure(CONN_h.screen.hfig); end
		if ~isempty(title), 
            if 0
                if 0,%strcmpi(type,'frame')
                    bg1=bgcolor;
                    bg2=max(0,min(1, (1-.75/8)*bg1+.75/8*[6/6,2/6,2/6]));
                    ht=axes('units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,.01,0,.04],'color',bg2,'xtick',[],'ytick',[],'xcolor',bg1,'ycolor',bg1); %,'visible','off');
                else
                    ht=axes('units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,.01,0,.04],'visible','off');
                end
                h2=text(0,0,title,'horizontalalignment','center',titleopts2{:}); %,'color',.1+[0 0 0]+.8*(mean(bgcolor)<.5));
                if 1||strcmpi(type,'frame'), set(h2,'fontsize',12+CONN_gui.font_offset); end %,'fontweight','bold'); end
                set(ht,'xlim',[-1,1],'ylim',[-1,1]);
            elseif 1
                if 0,%strcmpi(type,'frame')&&~isempty(deblank(title)), bg2=CONN_gui.backgroundcolorE; 
                else bg2=bgcolor;
                end
                if strcmpi(type,'frame'), temp=(position+[0,position(4),0,0]).*[1,1,1,0]+[0,.01,.001,.04];
                %if strcmpi(type,'frame'), temp=(position+[0,position(4),0,0]).*[1,1,1,0]+[.005,0,-.010,.039];
                else temp=(position+[0,position(4),0,0]).*[1,1,1,0]+[.001,0,-.002,.04];
                end
                h2=uicontrol('style','text','units','norm','position',temp,'string',title,titleopts{:},'backgroundcolor',bg2,'units','norm','horizontalalignment','center','fontweight','bold');
                if 1||strcmpi(type,'frame'), set(h2,'fontsize',13+CONN_gui.font_offset); end %,'fontweight','bold'); end 
            else
                %h2=conn_menu('pushbutton2',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,0*.01,0,.04],'',title);
                h2=uicontrol('style','pushbutton','units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,0*.01,0,.04],'string',title,titleopts{:},'backgroundcolor',CONN_gui.backgroundcolor,'units','norm','horizontalalignment','center');
                if 1||strcmpi(type,'frame'), set(h2,'fontsize',12+CONN_gui.font_offset); end %,'fontweight','bold'); end 
                temp=get(CONN_h.screen.hfig,'position');
                temp=temp([3 4 3 4]).*((position+[0,position(4),0,0]).*[1,1,1,0]+[0,0*.01,0,.04]);
                bg1=conn_guibackground('get',temp([1 2 3 4]),ceil(temp([4 3])));
                set(h2,'cdata',bg1);
                %%uicontrol('style','text','units','norm','position',(position+[0,position(4),0,0]).*[1,1,1,0]+[0,0,0,.04],'string',title,'foregroundcolor',.0+1.0*([0 0 0]+(mean(bgcolor)<.5)),'backgroundcolor',min(1,1.4*get(gcf,'color')),'fontweight','bold','fontsize',8+CONN_gui.font_offset,'fontunits','norm','horizontalalignment','center');
            end
            extendshade=1;
        else h2=[]; extendshade=0;
        end
        if strcmpi(type,'frame')||strcmpi(type,'frame2border')
            if extendshade, position=position+[0 0 0 .05]; end
            ht2=axes('units','norm','position',position);
            set(ht2,'unit','pixels');
            bscale=.75;
            tpos=get(ht2,'position')+[-12 -12 2*12 1.5*12]*bscale;
            %if extendshade, tpos(4)=(tpos(4)-1*24)*(1+.04/position(4))+1*24; end
            %tpos=get(ht2,'position')+1*[-8 -12 20 20];
            set(ht2,'position',tpos,'color',min(1,CONN_gui.backgroundcolor),'xtick',[],'ytick',[],'xcolor',max(0,CONN_gui.backgroundcolor),'ycolor',max(0,CONN_gui.backgroundcolor),'box','off','yaxislocation','right');
            [i,j]=ndgrid([0:2:tpos(4) tpos(4):-2:0],[0:2:tpos(3) tpos(3):-2:0]);
            b0=conn_guibackground('get',tpos,size(i));
            b1=CONN_gui.backgroundcolor;
            %if strcmpi(type,'frame'), b1=CONN_gui.backgroundcolor; %max(0,min(1,(CONN_gui.backgroundcolorA)*.5/max(eps,max(CONN_gui.backgroundcolorA))));
            %else b1=CONN_gui.backgroundcolorA; %b1=max(0,min(1,CONN_gui.backgroundcolor*(mean(CONN_gui.backgroundcolor)<.5)/max(eps,max(CONN_gui.backgroundcolor)))); 
            %end
            b1=max(0,min(1, 0.75*b1));
            %h3=image(max(0,min(1, conn_bsxfun(@plus,b0,conn_bsxfun(@times,shiftdim([1 1 .75],-1),-mean(b0(:))*max(0,1-(max(0,1-i/24/2).^4+max(0,1-j/24/2).^4)).^4)))),'parent',ht2);
            h3=image(max(0,min(1, conn_bsxfun(@plus,b0,conn_bsxfun(@times,mean(mean(b0,1),2)-shiftdim(b1,-1),-mean(1+0*b0(:))*max(0,1-(max(0,1-i/24/1).^2+max(0,1-.75*j/24/1).^2)).^2)))),'parent',ht2);
            %h3=image(max(0,min(1, conn_bsxfun(@plus,b0,conn_bsxfun(@times,shiftdim([1 1 .75],-1),-mean(b0(:))*(min(1,min(i,j)/24/4).^2))))),'parent',ht2);
            set(ht2,'visible','off','units','norm');
            %h3=patch([0,0,1,1],[0,1,1,0],'w');set(h3,'edgecolor',CONN_gui.backgroundcolorA,'facecolor','none');set(ht2,'xlim',[0 1],'ylim',[0 1]); axis off;
            bg2=bgcolor;%max(0,min(1,CONN_gui.backgroundcolorE));
            h=axes('units','norm','position',position);
            set(h,'color',bgcolor,'xtick',[],'ytick',[],'xcolor',1*bg2,'ycolor',1*bg2,'box','off');%'on','yaxislocation','right');
            %set(h,'color',bgcolor,'xtick',[],'ytick',[],'xcolor',(bg2),'ycolor',(bg2),'box','off','yaxislocation','left');
            %set(h,'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',CONN_gui.backgroundcolorA,'ycolor',CONN_gui.backgroundcolorA,'box','on');
            if 1, % higlighted frame has constant border
                if strcmpi(type,'frame2'), set([h3],'visible','off'); %conn_menumanager('onregion',[h3],1,get(h,'position'));
                else set([h3],'visible','on'); %conn_menumanager('onregion',[h3],-1,get(h,'position'));
                end
            else  % higlighted frame has contextual border
                set([h3],'visible','off'); conn_menumanager('onregion',[h3],1,get(h,'position'));
            end
        else
            bg2=max(0,min(1,CONN_gui.backgroundcolor));
            h=axes('units','norm','position',position);
            set(h,'color',bgcolor,'xtick',[],'ytick',[],'xcolor',bg2,'ycolor',bg2,'box','off','yaxislocation','right');
        end
        %image(conn_bsxfun(@times,shiftdim(get(gcf,'color'),-1),0+.5*convn(rand(100),ones(11)/25,'same')));
		%h=axes('units','norm','position',[position(1),position(2)+.99*position(4),position(3),.01*position(4)],'color',CONN_gui.backgroundcolorA,'xtick',[],'ytick',[],'xcolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'ycolor',.0+1.0*([0 0 0]+(mean(CONN_gui.backgroundcolorA)<.5)),'box','on');
        
	case 'updatescatter',
		if isempty(title), 
			set([position.h1,position.h2,position.h3],'visible','off'); 
        else 
            maxtitle=[];
            if iscell(title{1})
                for n=1:min(numel(position.h2),numel(title{1})), 
                    if isempty(maxtitle), maxtitle=[min(title{2}{n}(:)) max(title{2}{n}(:))]; else maxtitle=[min(maxtitle(1),min(title{2}{n}(:))) max(maxtitle(2),max(title{2}{n}(:)))]; end
                    set(position.h2(n),'xdata',title{1}{n},'ydata',title{2}{n}); 
                end
            else
                for n=1:min(numel(position.h2),size(title{1},2)), 
                    if isempty(maxtitle), maxtitle=[min(title{2}(:,n)) max(title{2}(:,n))]; else maxtitle=[min(maxtitle(1),min(title{2}(:,n))) max(maxtitle(2),max(title{2}(:,n)))]; end
                    set(position.h2(n),'xdata',title{1}(:,n),'ydata',title{2}(:,n)); 
                end
            end
            set(position.h3,'xdata',[0,0],'ydata',maxtitle+[0 1e-10],'color','w');
            axis(position.h1,'tight');
			set(position.h2,'visible','off'); 
			set([position.h1,position.h2(1:min(numel(position.h2),size(title{1},2)))],'visible','on'); 
        end
        
	case 'updatehist',
		if isempty(title), 
			set([position.h1,position.h2,position.h3,position.h4,position.h5,position.h6,position.h7],'visible','off'); 
		else 
            set(position.h3,'xdata',title{1},'ydata',title{2},'facecolor',1/2*[1,1,0],'facealpha',1,'edgecolor','none');
            set(position.h4,'xdata',title{1},'ydata',title{3},'facecolor',.75/2*[1,1,1],'facealpha',1,'edgecolor','none');
            set(position.h5,'xdata',title{1},'ydata',min(title{2},title{3}),'facecolor',[.2,.2,.4],'facealpha',1,'edgecolor','none');
            set(position.h2,'xdata',[0,0],'ydata',[0,max(max(title{2}),max(title{3}))*1.35],'color','w');
            axis(position.h1,'tight');
            [nill,idxtemp]=max(title{3});
            xbak1=title{1}(idxtemp); ybak1=title{3}(idxtemp);
            [nill,idxtemp]=max(title{2});
            xbak2=title{1}(idxtemp); ybak2=title{2}(idxtemp);
            if ybak2>ybak1&&(ybak2-ybak1)/max(ybak2,ybak1)<.15, ybak2=ybak1+.15*max(ybak1,ybak2);
            elseif ybak1>ybak2&&(ybak1-ybak2)/max(ybak2,ybak1)<.15, ybak1=ybak2+.15*max(ybak1,ybak2);
            end
            set(position.h6,'position',[xbak1,ybak1,1],'color',.75/2*[1,1,1],'horizontalalignment','center','verticalalignment','bottom');
            set(position.h7,'position',[xbak2,ybak2,1],'color',1/2*[1,1,0],'horizontalalignment','center','verticalalignment','bottom');
            set([position.h1,position.h2,position.h3,position.h4,position.h5,position.h6,position.h7],'visible','on');
        end
	case {'update','updateplot','updateplotsingle','updateplotstack','updateplotstackcenter','updateplotstacktoscale','updateimage','updatematrix','updatematrixequal'},
		if isempty(title), 
			set(position.h2,'cdata',min(1,conn_bsxfun(@plus,conn_bsxfun(@times,eye(100)|flipud(eye(100)),shiftdim([.25 0 0],-1)),min(1,shiftdim(bgcolor,-1))))); set(position.h1,'xlim',[.5,1.5],'ylim',[.5,1.5],'xtick',[],'ytick',[]); axis(position.h1,'equal','tight');
			set([position.h1,position.h2,position.h2b,position.h2c],'visible','off'); 
			set([position.h3,position.h4,position.h4b,position.h5,position.h5b,position.h7,position.h9,position.h9a,position.h10,position.h10a,position.h11,position.h12,position.h13],'visible','off'); 
            if isfield(position,'htitle')&&all(ishandle(position.htitle)), set(position.htitle,'visible','off'); end
            if isfield(position,'hnill')&&~isempty(position.hnill), delete(position.hnill(ishandle(position.hnill))); position.hnill=[]; end
            conn_menumanager('onregionremove',position.h5);
            conn_menumanager('onregionremove',position.h5b);
		else 
            if any(strcmp(lower(type),{'updatematrix','updatematrixequal'}))
                temp=title; %256*(title-min(title(:)))/(max(title(:))-min(title(:)));
                temp(isnan(temp))=0;
                if size(temp,3)>1, set(position.h2,'cdata',temp);
                else set(position.h2,'cdata',conn_ind2rgb((temp-min(temp(:)))/max(eps,max(temp(:))-min(temp(:)))*128,position.mapcolor)); 
                end
                data.buttondown=struct('callback',position.hcallback,'callbackclick',position.hcallback2);
                set(position.h2,'userdata',data);
                set(position.h6a,'userdata',data);
                set(position.h1,'xlim',[.5,size(title,2)+.5],'ylim',[.5,size(title,1)+.5+eps],'xtick',[],'ytick',[]);
                set([position.h1,position.h2,position.h2b,position.h2c],'visible','on'); set([position.h3,position.h4,position.h4b,position.h11,position.h12,position.h13],'visible','off');
				if strcmp(lower(type),'updatematrix'), axis(position.h1,'normal'); 
                else axis(position.h1,'equal');
                end
                if isfield(position,'htitle')&&all(ishandle(position.htitle)), set(position.htitle,'visible','on'); end
            elseif strcmp(lower(type),'updateimage')||isstruct(title)||iscell(title)||size(title,2)>nmax||size(title,3)>1, 
				data=get(position.h2,'userdata');
                volhdr=[];
				if iscell(title), 
					title0=title{2}; titleTHR=title{end}; title=title{1}; 
					if any(titleTHR(:)<0), data.p=1; titleTHR=-titleTHR; else  data.p=0; end
				else  title0=[]; data.p=0; end; % title: structural; title0: activation; titleTHR: p-value (nan for missing data)
                icon=[];
                try
                    if isstruct(title)&&isfield(title(1),'fname')&&~isempty(title(1).fname)&&conn_existfile(conn_prepend('',title(1).fname,'.icon.jpg'))
                        icon=imread(conn_prepend('',title(1).fname,'.icon.jpg'),'jpg');
                    end
                end
                if isstruct(title)&&isfield(title,'vertices')
                    title=shiftdim(title(:),-2);
                    title=title(:,:,[1 1 2 2]);
                elseif isstruct(title), 
                    ok=false;
                    if isfield(title(1),'checkSurface'), 
                        [ok,FS_folder,files]=conn_checkFSfiles(title(1)); 
                    end
                    if ok
                        title=[conn_surf_readsurf(files{2}) conn_surf_readsurf(files{5})];
                        title(1).faces=fliplr(title(1).faces);
                        title(2).faces=fliplr(title(2).faces);
                        title=reshape(repmat(title(:)',[2,1]),[1,1,4]);
%                         [xyz,faces]=read_surf(files{2});
%                         %title=accumarray(max(1,min(200, 100+round(xyz(:,2:3)))),abs(xyz(:,1)),[200 200],@max,0);
%                         title=struct('vertices',xyz,'faces',fliplr(faces+1));
%                         [xyz,faces]=read_surf(files{5});
%                         title(1,1,2)=struct('vertices',xyz,'faces',fliplr(faces+1));
%                         title=title(:,:,[1 1 2 2]);
                        %title=cat(3,title,accumarray(max(1,min(200, 100+round(xyz(:,2:3)))),abs(xyz(:,1)),[200 200],@max,0));
%                         xyz=conn_surf_readsurfresampled(files{2});
%                         title=struct('vertices',xyz(CONN_gui.refs.surf.default2reduced,:),'faces',fliplr(CONN_gui.refs.surf.spherereduced.faces));
%                         xyz=conn_surf_readsurfresampled(files{5});
%                         title(1,1,2)=struct('vertices',xyz(CONN_gui.refs.surf.default2reduced,:),'faces',fliplr(CONN_gui.refs.surf.spherereduced.faces));
                    else
                        if conn_surf_dimscheck(title(1).dim), %if isequal(title(1).dim,conn_surf_dims(8).*[1 1 2]) % surface
                            if length(title)>1,
                                volhdr=title(1);
                                temp1=spm_read_vols(title(1));
                                temp1=reshape(temp1(:,:,[1,size(temp1,3)/2+1],:),size(temp1,1)*size(temp1,2),2,1,[]);
                                temp2=spm_read_vols(title(end));
                                temp2=reshape(temp1(:,:,[1,size(temp2,3)/2+1],:),size(temp2,1)*size(temp2,2),2,1,[]);
                                temp=cat(4,temp1,temp2);
                                title={CONN_gui.refs.surf.defaultreduced,temp(CONN_gui.refs.surf.default2reduced,:,:,:),abs(temp(CONN_gui.refs.surf.default2reduced,:,:,:))};
                            else
                                volhdr=title(1);
                                temp=spm_read_vols(title);
                                temp=reshape(temp,size(CONN_gui.refs.surf.default(1).vertices,1),2,1,[]);
                                title={CONN_gui.refs.surf.default,temp,abs(temp)};
                                %temp=reshape(temp(:,:,[1,size(temp,3)/2+1],:),size(temp,1)*size(temp,2),2,1,[]);
                                %title={CONN_gui.refs.surf.defaultreduced,temp(CONN_gui.refs.surf.default2reduced,:,:,:),abs(temp(CONN_gui.refs.surf.default2reduced,:,:,:))};
                            end
                            title0=title{2}; titleTHR=title{end}; title=title{1};
                            if any(titleTHR(:)<0), data.p=1; titleTHR=-titleTHR; else  data.p=0; end
                            data.cscale=max(titleTHR(:));
                            title=shiftdim(title(:),-2);
                            title=title(:,:,[1 1 2 2]);
                            string={volhdr,[]};
                        else
                            if length(title)>1,
                                newtitle=[];
                                for n=reshape(unique(round(linspace(1,length(title),position.maxvolsdisplayed))),1,[])
                                    [temp,volhdr]=conn_spm_read_vols(title(n));
                                    newtitle=cat(4,newtitle,permute(temp,[2,1,3]));
                                end
                                title=newtitle;
%                             elseif length(title)>1,
%                                 [temp1,volhdr1]=conn_spm_read_vols(title(1));
%                                 [temp2,volhdr2]=conn_spm_read_vols(title(end));
%                                 title=cat(4,permute(temp1,[2,1,3]),permute(temp2,[2,1,3]));
%                                 volhdr=volhdr2;
                            else
                                [temp,volhdr]=conn_spm_read_vols(title);
                                title=permute(temp,[2,1,3]);
                            end
                        end
                    end
					%title=permute(spm_read_vols(title),[2,1,3,4]); 
				end
				%if size(title,4)>1, title=cat(2,title(:,:,:,end),title(:,:,:,1)); end
                if isstruct(title), data.x1=title;
                else
                    title(isnan(title))=0;
                    data.x1=max(1,min(128, round(1+127*(title-min(min(title(:))))/max(eps,max(max(title(:)))-min(min(title(:)))) )));
                    %if mean(title(:)<0)>.10, data.x1=round(64.5+63.5*title/max(max(abs(title(:))),eps));
                    %else data.x1=max(1,min(128, round(1+127*title/max(max(title(:)),eps)) ));
                    %end
                    %data.x1=round(1+127*(title-min(title(:)))/max(max(title(:))-min(title(:)),eps));
                end
				if size(data.x1,3)>1, if ~isfield(data,'view')||isempty(data.view), data.view=3-~isempty(icon); end; data.viewselect=true;
                else data.view=3; data.viewselect=false;
                end
                xslice={'change coronal slice','change sagittal slice','change axial slice'};
                set(position.h5,'tooltipstring',xslice{data.view});
				if ~isfield(data,'n')||isempty(data.n), if numel(title)==4, data.n=1; else data.n=ceil(size(title,data.view)/2); end; end
				data.n=max(1,min(size(title,data.view),data.n));
                %data.x1=round(1+127*max(0,min(1,title)));
				if ~isempty(title0),
					data.x0=title0; %max(-1,min(1,title0)); % x1: structural; x0: activation; xTHR: p-value
					data.xTHR=titleTHR;%max(0,min(1,titleTHR));
					t0=(129:256)'; idxt0=find(~isnan(titleTHR)); 
					if isempty(idxt0), idxt0=[1,1]; %ceil(128*max(eps,max(title0(:))))];
					else  idxt0=ceil(128*max(eps,min(1,.5+.5*max(-1,min(1, [min(title0(idxt0)),max(title0(:))]/data.cscale ))))); end
					t0(1:min(idxt0)-1)=1;t0(max(idxt0)+1:end)=1;%t0(idxt0)=128;%t0(max(1,idxt0-1))=1;t0(min(128,idxt0+1))=1;
					set(position.h8,'cdata',conn_ind2rgb(t0,position.mapcolor));
					set([position.h7,position.h8,position.h9,position.h9a,position.h10,position.h10a],'visible','on');
				else  
					data.x0=[]; 
					set([position.h7,position.h8,position.h9,position.h9a,position.h10,position.h10a],'visible','off');
				end
				if size(data.x1,data.view)>1, 
                    conn_menumanager('onregionremove',position.h5);
                    conn_menumanager('onregionremove',position.h5b);
					set(position.h5,'min',1,'max',size(data.x1,data.view),'sliderstep',min(1,[1,10]/(size(data.x1,data.view)-1)),'value',data.n,'visible','off');
                    set(position.h5b,'visible','off');
                    if isstruct(title), conn_menumanager('onregion',[position.h5],1,get(position.h1,'position')+[0 0 .015 0]);
                    else conn_menumanager('onregion',[position.h5,position.h5b],1,get(position.h1,'position')+[0 0 .015 0]);
                    end
                else
                    set([position.h5,position.h5b],'visible','off');
                    conn_menumanager('onregionremove',position.h5);
                    conn_menumanager('onregionremove',position.h5b);
                end
                n1n2=[1 1];
                if isstruct(title)
                    if size(data.x0,4)>1
                        mv=mean(title(data.n).vertices,1);
                        rv=max(title(data.n).vertices,[],1)-min(title(data.n).vertices,[],1);
                        units=get(position.h11,'units');set(position.h11,'units','points');emphx=get(position.h11,'position');set(position.h11,'units',units);
                        emphx=emphx(4)/emphx(3);
                        [n1,n2]=ndgrid(1:size(data.x0,4),1:size(data.x0,4)); n1=n1(:); n2=n2(:);
                        [nill,idx]=max(min(emphx*rv(2)./n1(:), rv(3)./n2(:))-1e10*(n1(:).*n2(:)<size(data.x0,4)));
                        n1=n1(idx); n2=n2(idx);
                        vertices=[]; faces=[];
                        R=diag([-[1 1]+2*rem(data.n,2) 1]);
                        [n2,n1]=ndgrid(1:n2,1:n1);
                        for n3=1:size(data.x0,4),
                            faces=[faces; title(data.n).faces+size(vertices,1)];
                            vertices=[vertices; title(data.n).vertices*R+repmat(-mv+[0 -rv(2)*(n2(n3)-1) -rv(3)*(n1(n3)-1)],size(title(data.n).vertices,1),1)];
                        end
                        title0=permute(data.x0,[1,3,4,2]);
                        titleTHR=permute(data.xTHR,[1,3,4,2]);
                    else
                        vertices=title(data.n).vertices;
                        faces=title(data.n).faces;
                        if ~isempty(data.x0)
                            title0=data.x0;
                            titleTHR=data.xTHR;
                        end
                    end
                    set(position.h12,'vertices',vertices,'faces',faces);%,'facevertexcdata',max(0,min(1,abs(title(data.n).vertices(:,1))/100))*128,'facecolor','flat','cdatamapping','direct');
                    vnorm=get(position.h12,'VertexNormals');
                    if isempty(vnorm), vnorm=zeros(size(vertices)); end
                    vnorm=conn_bsxfun(@rdivide,vnorm,sqrt(sum(vnorm.^2,2)));
                    title=128*(.1+max(0,min(1,abs(vnorm*[1;0;0]).^2))*.5); 
                    if ~isempty(data.x0),
                        title0=reshape(title0,[],2);
                        title0=title0(:,ceil(data.n/2));
                        titleTHR=reshape(titleTHR,[],2);
                        titleTHR=titleTHR(:,ceil(data.n/2));
                        if data.p, idx=find(titleTHR<=data.thr); else  idx=find(titleTHR>data.thr); end
                        title(idx)=round(192.5+63.5*max(-1,min(1, title0(idx)/data.cscale )));
                    end
                    set(position.h12,'facevertexcdata',conn_ind2rgb(title,position.mapcolor,2),'facecolor','interp');
                    %set(position.h12,'facevertexcdata',title,'facecolor','interp','cdatamapping','direct'); %Use this line instead of line above if experiencing render-related errors 
                    set(position.h11,'xtick',[],'ytick',[],'ztick',[]);
                    set([position.h11 position.h12 position.h13],'visible','on');
                    set([position.h1 position.h2 position.h2b position.h2c position.h3],'visible','off');
                    axis(position.h11,'equal','tight'); 
                    if size(data.x0,4)>1, set(position.h11,'view',[-90,0]);
                    else set(position.h11,'cameraPosition',[1000-2000*rem(data.n,2) 0 .1],'cameraupvector',[0 0 1]);
                    end
                    %set(position.h13,'position',[1000-2000*rem(data.n,2) 0 .1]);
                else
                    %title=fliplr(flipud(data.x1(:,:,data.n,:)));
                    title=conn_menu_selectslice(data.x1,data.n,data.view);
                    c1=zeros(2,0);c2=zeros(2,0); c1c=[0 0 0]; c2c=[0 0 0]; n1n2=[1 1];
                    if ~isempty(data.x0),
                        %title0=fliplr(flipud(data.x0(:,:,data.n,:))); %if all(size(title)==2*size(title0)-1), title0=interp2(title0,'nearest'); end
                        %titleTHR=fliplr(flipud(data.xTHR(:,:,data.n,:))); %if all(size(title)==2*size(titleTHR)-1), titleTHR=interp2(titleTHR,'nearest'); end
                        title0=conn_menu_selectslice(data.x0,data.n,data.view);
                        titleTHR=conn_menu_selectslice(data.xTHR,data.n,data.view);
                        if size(title0,4)>1, [title,title0,titleTHR,n1n2]=conn_menu_montage(position.h1,title,title0,titleTHR); end
                        title3a=conn_ind2rgb(title,position.mapcolor);
                        if data.p, idx=find(titleTHR<=data.thr); c1=contourc(double(title0>0&titleTHR<=data.thr),[.5 .5]); c2=contourc(double(title0<0&titleTHR<=data.thr),[.5 .5]); 
                        else  idx=find(titleTHR>data.thr); c1=contourc(double(title0>0&titleTHR>data.thr),[.5 .5]); c2=contourc(double(title0<0&titleTHR>data.thr),[.5 .5]); 
                        end
                        title(idx)=round(192.5+63.5*max(-1,min(1, title0(idx)/data.cscale )));
                        data.displayed.val=title0;
                        data.displayed.thr=titleTHR;
                        cmap=get(get(position.h1,'parent'),'colormap');
                        c1c=cmap(round(192.5+63.5*max(-1,min(1, min(title0(idx(title0(idx)>0)))/data.cscale ))),:); if isempty(c1c), c1c=[0 0 0]; end
                        c2c=cmap(round(192.5+63.5*max(-1,min(1, max(title0(idx(title0(idx)<0)))/data.cscale ))),:); if isempty(c2c), c2c=[0 0 0]; end
                        ci=1;while ci<size(c1,2), cj=ci+c1(2,ci)+1; if cj-ci<8, c1(:,ci:cj-1)=nan; else c1(:,ci)=nan; end; ci=cj; end
                        ci=1;while ci<size(c2,2), cj=ci+c2(2,ci)+1; if cj-ci<8, c2(:,ci:cj-1)=nan; else c2(:,ci)=nan; end; ci=cj; end
                    elseif size(title,4)>1, 
                        [title,n1n2]=conn_menu_montage(position.h1,title);
                        title3a=conn_ind2rgb(title,position.mapcolor);
                        data.displayed.val=[];
                    else title3a=conn_ind2rgb(title,position.mapcolor);
                        data.displayed.val=[];
                    end
                    data.displayed.raw=title;
                    title3b=conn_ind2rgb(title,position.mapcolor);
                    set(position.h2,'cdata',.4*title3a+.6*title3b);set(position.h1,'xlim',[.5,size(title,2)+.5],'ylim',[.5,size(title,1)+.5+eps],'xtick',[],'ytick',[]);
                    set(position.h2b(1),'xdata',c1(1,:),'ydata',c1(2,:),'color',.8*mean(position.mapcolor(1,:))+.2*c1c);
                    set(position.h2b(2),'xdata',c2(1,:),'ydata',c2(2,:),'color',.8*mean(position.mapcolor(1,:))+.2*c2c);
                    set(position.h2c,'xdata',[],'ydata',[]);
                    set([position.h1,position.h2,position.h2b,position.h2c],'visible','on'); set([position.h3,position.h4,position.h4b,position.h11,position.h12,position.h13],'visible','off');
                end
				axis(position.h1,'equal','tight'); 

                if ~isempty(string),
                    data.buttondown=struct('matdim',conn_menu_selectslice(string{1},data.n,data.view),'z',string{2},'h1',position.h1,'callback',position.hcallback,'callbackclick',position.hcallback2);
                    data.buttondown.matdim.dim(4:5)=n1n2(1:2);
                    set(position.h2,'userdata',data); %,'buttondownfcn',@conn_menubuttondownfcn);
                    set(position.h6a,'userdata',data);
                else 
                    if ~isempty(volhdr),  data.buttondown=struct('matdim',conn_menu_selectslice(volhdr,data.n,data.view),'z',[],'h1',position.h1,'callback',position.hcallback,'callbackclick',position.hcallback2); data.buttondown.matdim.dim(4:5)=n1n2(1:2); end
                    set(position.h2,'userdata',data);
                    set(position.h6a,'userdata',data);
                end
                if ~isempty(icon)
                    icon=double(icon);
                    icon=max(0,icon/max(icon(:)));
                    w=mean(icon,3).^.5;
                    icon=conn_bsxfun(@times, w, icon) + conn_bsxfun(@times, 1-w, shiftdim(position.mapcolor(1,:),-1));
                    set(position.h2,'cdata',icon);
                    set(position.h6a,'string','','units','pixels','position',[1,1,1,1]);
                    %                     data.buttondown=[];
                    %                     set(position.h2,'userdata',data);
                    %                     set(position.h6a,'userdata',data);
                    set(position.h1,'xlim',[.5,size(icon,2)+.5],'ylim',[.5,size(icon,1)+.5+eps],'xtick',[],'ytick',[]);
                    set([position.h1,position.h2],'visible','on'); set([position.h2b,position.h2c,position.h3,position.h4,position.h4b,position.h11,position.h12,position.h13],'visible','off');
                    axis(position.h1,'equal','tight');
                    %axis(position.h1,'normal');
                end
                if isfield(position,'htitle')&&all(ishandle(position.htitle)), set(position.htitle,'visible','on'); end
			else  
				if isstruct(title), title=permute(conn_spm_read_vols(title),[2,1,3,4]); end
                if size(title,2)==1&&size(title,1)<=100,
                    set(position.h4(1),'xdata',(1:size(title,1))','ydata',title,'zdata',title,'linestyle','none','marker','o','markerfacecolor','r','markeredgecolor','r','tag','plot');
                    for n1=1:size(title,1),set(position.h4(1+n1),'xdata',n1+[0 0],'ydata',[0 title(n1)],'zdata',title(n1)+[1 1],'linestyle',':','marker','none','color',[.5 .5 .5],'tag','none');end
                    set(position.h4(size(title,1)+2:nmax),'xdata',(1:size(title,1))','ydata',zeros(size(title,1),1),'zdata',zeros(size(title,1),1),'linestyle',':','marker','none','color',[.5 .5 .5],'tag','none');
                    %for n1=size(title,1)+2:nmax,set(position.h4(n1),'xdata',(1:size(title,1))','ydata',zeros(size(title,1),1),'zdata',zeros(size(title,1),1),'linestyle',':','marker','none','color',[.5 .5 .5],'tag','none');end
                else
                    titleraw=title;
                    markers={'marker','none'};
                    if strcmp(lower(type),'updateplotsingle')
                        maxtitleraw=max(eps,max(abs(title),[],1));
                        maxtitleraw=maxtitleraw.*(max(maxtitleraw.^1)./(maxtitleraw.^1));
                        title=repmat(size(title,2)-1:-1:0, size(title,1),1) + .65*title./repmat(max(eps,maxtitleraw),size(title,1),1);
                        offsets=0:size(title,2)-1;
                        markers={'marker','o','markerfacecolor','r','markeredgecolor','r'};
                    elseif strcmp(lower(type),'updateplotstack')
                        maxtitleraw=max(eps,max(abs(title),[],1));
                        maxtitleraw=maxtitleraw.*(max(maxtitleraw.^.25)./(maxtitleraw.^.25));
                        title=repmat(size(title,2)-1:-1:0, size(title,1),1) + .65*title./repmat(max(eps,maxtitleraw),size(title,1),1);
                        offsets=0:size(title,2)-1;
                    elseif strcmp(lower(type),'updateplotstackcenter')
                        temp1=title;temp2=~isnan(temp1);temp1(~temp2)=0;
                        title=title-repmat(sum(temp1,1)./max(eps,sum(temp2,1)),size(title,1),1);
                        maxtitleraw=max(eps,max(abs(title),[],1));
                        maxtitleraw=maxtitleraw.*(max(maxtitleraw)./(maxtitleraw));
                        title=repmat(size(title,2)-1:-1:0, size(title,1),1) + .65*title./repmat(max(eps,maxtitleraw),size(title,1),1);
                        offsets=0:size(title,2)-1;
                    elseif strcmp(lower(type),'updateplotstacktoscale')
                        maxtitleraw=max(eps,max(abs(title),[],1));
                        maxtitleraw=maxtitleraw.*(max(maxtitleraw)./(maxtitleraw));
                        title=repmat(size(title,2)-1:-1:0, size(title,1),1) + .65*title./repmat(max(eps,maxtitleraw),size(title,1),1);
                        offsets=0:size(title,2)-1;
                    else offsets=0; markers={'marker','o','markerfacecolor','r','markeredgecolor','r'};
                    end
                    colors=get(position.h3,'colorOrder');
                    for n1=1:size(title,2),set(position.h4(n1),'xdata',(1:size(title,1))','ydata',title(:,n1),'zdata',titleraw(:,n1),'linestyle','-','color',colors(1+mod(n1,size(colors,1)),:),'tag','plot',markers{:});end
                    for n1=size(title,2)+1:nmax,set(position.h4(n1),'xdata',(1:size(title,1))','ydata',offsets(1+mod(n1-1,numel(offsets)))+zeros(size(title,1),1),'zdata',zeros(size(title,1),1),'linestyle',':','marker','none','color',[.5 .5 .5],'tag','none');end
                end
				minmaxt=[min(0,min(title(:))),max(0,max(title(:)))]; set(position.h3,'xlim',[0,size(title,1)+1],'ylim',minmaxt*[1.1,-.1;-.1,1.1]+[-1e-10,1e-10]); 
                data.buttondown=struct('callback',position.hcallback,'callbackclick',position.hcallback2);
                set(position.h2,'userdata',data);
                set(position.h4,'userdata',data);
				set([position.h3,position.h4],'visible','on'); 
                set([position.h1,position.h2,position.h2b,position.h2c,position.h5,position.h5b,position.h7,position.h9,position.h9a,position.h10,position.h10a,position.h11,position.h12,position.h13],'visible','off'); 
                conn_menumanager('onregionremove',position.h5);
                conn_menumanager('onregionremove',position.h5b);
                if isfield(position,'htitle')&&all(ishandle(position.htitle)), set(position.htitle,'visible','on'); end
			end
		end
	case {'updateslider1','updateslider2','updatethr','updatecscale','updateview'}
        if strcmpi(type,'updateview')
            if nargin<=3, tgcbo=gcbo;
            else tgcbo=string;
            end
            position=get(tgcbo,'userdata');
            data=get(position.h2,'userdata');
            if data.viewselect
                data.view=1+mod(data.view,3);
                data.n=max(1,min(size(data.x1,data.view), data.n));
                xslice={'change coronal slice','change sagittal slice','change axial slice'};
                set(position.h5,'min',1,'max',size(data.x1,data.view),'sliderstep',min(1,[1,10]/(size(data.x1,data.view)-1)),'value',data.n,'tooltipstring',xslice{data.view});
                set(position.h2,'userdata',data);
            end
        end
        if any(strcmpi(type,{'updatethr','updatecscale'}))
            if nargin<=3, tgcbo=gcbo;
            else tgcbo=string;
            end
            position=get(tgcbo,'userdata');
            title=str2num(get(tgcbo,'string'));
            data=get(position.h2,'userdata');
            if strcmpi(type,'updatethr')
                data.thr=max(0,min(inf,str2num(get(tgcbo,'string'))));
                %set(position.h6,'value',data.thr);
            else
                data.cscale=max(eps,title);
            end
        else
            data=get(position.h2,'userdata');
        end
        if strcmpi(type,'updateslider1')
            data.n=max(1,min(size(data.x1,data.view), round(title)));
        end
        if strcmpi(type,'updateslider2')
            data.thr=max(0,min(1, title));
        end
        if isfield(data,'thr'), set(position.h10,'string',num2str(data.thr)); end
        if isstruct(data.x1)
            title=data.x1;
            if size(data.x0,4)>1
                mv=mean(title(data.n).vertices,1);
                rv=max(title(data.n).vertices,[],1)-min(title(data.n).vertices,[],1);
                units=get(position.h11,'units');set(position.h11,'units','points');emphx=get(position.h11,'position');set(position.h11,'units',units);
                emphx=emphx(4)/emphx(3);
                [n1,n2]=ndgrid(1:size(data.x0,4),1:size(data.x0,4)); n1=n1(:); n2=n2(:);
                [nill,idx]=max(min(emphx*rv(2)./n1(:), rv(3)./n2(:))-1e10*(n1(:).*n2(:)<size(data.x0,4)));
                n1=n1(idx); n2=n2(idx);
                vertices=[]; faces=[];
                R=diag([-[1 1]+2*rem(data.n,2) 1]);
                [n2,n1]=ndgrid(1:n2,1:n1);
                for n3=1:size(data.x0,4),
                    faces=[faces; title(data.n).faces+size(vertices,1)];
                    vertices=[vertices; title(data.n).vertices*R+repmat(-mv+[0 -rv(2)*(n2(n3)-1) -rv(3)*(n1(n3)-1)],size(title(data.n).vertices,1),1)];
                end
                title0=permute(data.x0,[1,3,4,2]);
                titleTHR=permute(data.xTHR,[1,3,4,2]);
            else
                vertices=title(data.n).vertices;
                faces=title(data.n).faces;
                if ~isempty(data.x0)
                    title0=data.x0;
                    titleTHR=data.xTHR;
                end
            end
            set(position.h12,'vertices',vertices,'faces',faces);%,'facevertexcdata',max(0,min(1,abs(title(data.n).vertices(:,1))/100))*128,'facecolor','flat','cdatamapping','direct');
            %set(position.h12,'vertices',title(data.n).vertices,'faces',title(data.n).faces);%,'facevertexcdata',max(0,min(1,abs(title(data.n).vertices(:,1))/100))*128,'facecolor','flat','cdatamapping','direct');
            vnorm=get(position.h12,'VertexNormals');
            if isempty(vnorm), vnorm=zeros(size(vertices)); end
            vnorm=conn_bsxfun(@rdivide,vnorm,sqrt(sum(vnorm.^2,2)));
            title=128*(.1+max(0,min(1,abs(vnorm*[1;0;0]).^2))*.5);
            title3a=conn_ind2rgb(title,position.mapcolor,2);
            if ~isempty(data.x0),
                title0=reshape(title0,[],2);
                title0=title0(:,ceil(data.n/2));
                titleTHR=reshape(titleTHR,[],2);
                titleTHR=titleTHR(:,ceil(data.n/2));
                if data.p, idx=find(titleTHR<=data.thr); else  idx=find(titleTHR>data.thr); end
                title(idx)=round(192.5+63.5*max(-1,min(1, title0(idx)/data.cscale )));
                t0=(129:256)'; idxt0=find(~isnan(titleTHR));
                if isempty(idxt0), idxt0=[1,1]; %ceil(128*max(eps,max(title0(:))))];
                else  idxt0=ceil(128*max(eps,min(1,.5+.5*max(-1,min(1, [min(title0(idxt0)),max(title0(:))]/data.cscale ))))); end
                t0(1:min(idxt0)-1)=1;t0(max(idxt0)+1:end)=1;%t0(idxt0)=128;%t0(max(1,idxt0-1))=1;t0(min(128,idxt0+1))=1;
                set(position.h8,'cdata',conn_ind2rgb(t0,position.mapcolor));
            end
            set(position.h10,'string',num2str(data.thr));
            title3b=conn_ind2rgb(title,position.mapcolor,2);
            set(position.h12,'facevertexcdata',.4*title3a+.6*title3b,'facecolor','interp');
            %set(position.h12,'facevertexcdata',title,'facecolor','interp','cdatamapping','direct'); %Use this line instead of line above if experiencing render-related errors 
            set(position.h11,'xtick',[],'ytick',[],'ztick',[]);
            set([position.h11 position.h12 position.h13],'visible','on');
            set([position.h1 position.h2 position.h2b position.h2c position.h3],'visible','off');
            axis(position.h11,'equal','tight');
            if size(data.x0,4)>1, set(position.h11,'view',[-90,0]);
            else set(position.h11,'cameraPosition',[1000-2000*rem(data.n,2) 0 .1],'cameraupvector',[0 0 1]);
            end
            %set(position.h13,'position',[1000-2000*rem(data.n,2) 0 .1]);
        else
            %title=fliplr(flipud(data.x1(:,:,data.n,:)));
            title=conn_menu_selectslice(data.x1,data.n,data.view);
            c1=zeros(2,0);c2=zeros(2,0); c1c=[0 0 0]; c2c=[0 0 0]; n1n2=[1 1];
            if ~isempty(data.x0),
                %title0=fliplr(flipud(data.x0(:,:,data.n,:))); %if all(size(title)==2*size(title0)-1), title0=interp2(title0,'nearest'); end
                %titleTHR=fliplr(flipud(data.xTHR(:,:,data.n,:))); %if all(size(title)==2*size(titleTHR)-1), titleTHR=interp2(titleTHR,'nearest'); end
                title0=conn_menu_selectslice(data.x0,data.n,data.view);
                titleTHR=conn_menu_selectslice(data.xTHR,data.n,data.view);
                if size(title0,4)>1, [title,title0,titleTHR,n1n2]=conn_menu_montage(position.h1,title,title0,titleTHR); end
                title3a=conn_ind2rgb(title,position.mapcolor);
                if data.p, idx=find(titleTHR<=data.thr); c1=contourc(double(title0>0&titleTHR<=data.thr),[.5 .5]); c2=contourc(double(title0<0&titleTHR<=data.thr),[.5 .5]);
                else  idx=find(titleTHR>data.thr); c1=contourc(double(title0>0&titleTHR>data.thr),[.5 .5]); c2=contourc(double(title0<0&titleTHR>data.thr),[.5 .5]);
                end
                title(idx)=round(192.5+63.5*max(-1,min(1, title0(idx)/data.cscale )));
                data.displayed.val=title0;
                data.displayed.thr=titleTHR;
                cmap=get(get(position.h1,'parent'),'colormap');
                c1c=cmap(round(192.5+63.5*max(-1,min(1, min(title0(idx(title0(idx)>0)))/data.cscale ))),:); if isempty(c1c), c1c=[0 0 0]; end
                c2c=cmap(round(192.5+63.5*max(-1,min(1, max(title0(idx(title0(idx)<0)))/data.cscale ))),:); if isempty(c2c), c2c=[0 0 0]; end
                t0=(129:256)'; idxt0=find(~isnan(titleTHR));
                if isempty(idxt0), idxt0=[1,1]; %ceil(128*max(eps,max(title0(:))))];
                else  idxt0=ceil(128*max(eps,min(1,.5+.5*max(-1,min(1, [min(title0(idxt0)),max(title0(:))]/data.cscale ))))); end
                t0(1:min(idxt0)-1)=1;t0(max(idxt0)+1:end)=1;%t0(idxt0)=128;%t0(max(1,idxt0-1))=1;t0(min(128,idxt0+1))=1;
                set(position.h8,'cdata',conn_ind2rgb(t0,position.mapcolor));
                ci=1;while ci<size(c1,2), cj=ci+c1(2,ci)+1; if cj-ci<8, c1(:,ci:cj-1)=nan; else c1(:,ci)=nan; end; ci=cj; end
                ci=1;while ci<size(c2,2), cj=ci+c2(2,ci)+1; if cj-ci<8, c2(:,ci:cj-1)=nan; else c2(:,ci)=nan; end; ci=cj; end
            elseif size(title,4)>1, 
                [title,n1n2]=conn_menu_montage(position.h1,title);
                title3a=conn_ind2rgb(title,position.mapcolor);
                data.displayed.val=[];
            else title3a=conn_ind2rgb(title,position.mapcolor);
                data.displayed.val=[];
            end
            data.displayed.raw=title;
            if isfield(data,'thr'), set(position.h10,'string',num2str(data.thr)); end
            title3b=conn_ind2rgb(title,position.mapcolor);
            set(position.h2,'cdata',.4*title3a+.6*title3b);
            set(position.h2b(1),'xdata',c1(1,:),'ydata',c1(2,:),'color',.8*mean(position.mapcolor(1,:))+.2*c1c);
            set(position.h2b(2),'xdata',c2(1,:),'ydata',c2(2,:),'color',.8*mean(position.mapcolor(1,:))+.2*c2c);
            set(position.h2c,'xdata',[],'ydata',[]);
            set(position.h1,'xlim',[.5,size(title,2)+.5],'ylim',[.5,size(title,1)+.5+eps],'xtick',[],'ytick',[]);
            axis(position.h1,'equal','tight');
            set([position.h1,position.h2,position.h2b,position.h2c],'visible','on'); set([position.h3,position.h4,position.h4b],'visible','off');
            if isfield(data,'buttondown')&&isfield(data.buttondown,'matdim')
                data.buttondown.matdim=conn_menu_selectslice(data.buttondown.matdim,data.n,data.view);
                data.buttondown.matdim.dim(4:5)=n1n2(1:2); 
            end
        end
		set([position.h2 position.h6a position.h6b],'userdata',data);
end
end

% function varargout=conn_menu_montage(h,varargin)
% if ishandle(h), 
%     units=get(h,'units');
%     set(h,'units','points');
%     emphx=get(h,'position');
%     set(h,'units',units);
%     emphx=emphx(4)/emphx(3);
% elseif ~isempty(h), emphx=h;
% else emphx=.75;
% end
% sX=[size(varargin{end}) 1 1 1];
% if sX(4)>1
%     [n1,n2]=ndgrid(1:sX(4),1:sX(4)); n1=n1(:); n2=n2(:);
%     [nill,idx]=max(sX(1)*sX(2)./max(sX(1)*n1,emphx*sX(2)*n2).^2-1e10*(n1(:).*n2(:)<sX(4)));
%     n1=n1(idx); n2=n2(idx);
% else
%     n1=1; n2=1;
% end
% nX=[n2 n1];
% [i2,i1]=ind2sub(nX,1:sX(4));
% varargout={};
% for n=1:numel(varargin),
%     x=nan([sX(1)*n1,sX(2)*n2,sX(3)]);
%     for m=1:numel(i1)
%         x(sX(1)*(i1(m)-1)+(1:sX(1)),sX(2)*(i2(m)-1)+(1:sX(2)),:)=varargin{n}(:,:,:,min(size(varargin{n},4),m));
%     end
%     varargout{n}=x; %permute(x,[2,1,3]);
% end
% varargout{end+1}=nX;
% end

function rout=conn_ind2rgb(a,cm,dim)
a = min(size(cm,1),max(1,round(a)));
rout=reshape(cm(a,:),size(a,1),[],size(cm,2));
if nargin>2, 
    if dim==1,      rout=permute(rout, [3,1,2]);
    elseif dim==2,  rout=permute(rout, [1,3,2]);
    end
end
end
  
function [x,matdim]=conn_spm_read_vols(v)
global CONN_gui;
try
    xyz=pinv(v(1).mat)*CONN_gui.refs.canonical.xyz;
    v1dim=reshape(v(1).dim(1:3),3,1);
    xyz_scale=max(.25, min(1, round(min((max(xyz(1:3,:),[],2)-min(xyz(1:3,:),[],2)+1)./v1dim)*10)/10));
    if xyz_scale==.25, disp('warning: Volume too big. Displaying only a portion of the original volume'); end
    xyz=xyz/xyz_scale; % scale/center to fit
    xyz_center=mean(xyz(1:3,:),2)-(v1dim+1)/2;
    xyz(1:3,:)=conn_bsxfun(@minus,xyz(1:3,:),xyz_center);
    x=double(spm_sample_vol(v,xyz(1,:),xyz(2,:),xyz(3,:),1));
catch
    error('Error reading file %s. File may have been modified or relocated. Please load file again',v(1).fname);
end
%x=spm_get_data(v,xyz);
x=permute(reshape(x,[numel(v),CONN_gui.refs.canonical.V.dim]),[2,3,4,1]);
matdim=struct('dim',CONN_gui.refs.canonical.V.dim,'mat',v(1).mat*[[eye(3) -xyz_center(:)];[0 0 0 1]]*[[eye(3)/xyz_scale zeros(3,1)];[zeros(1,3) 1]]*pinv(v(1).mat)*CONN_gui.refs.canonical.V.mat);
end

function y=conn_menu_selectslice(x,n,dim)
if isstruct(x)
    y=x;
    if isfield(x,'mat0'), y.mat=y.mat0; end
    if isfield(x,'dim0'), y.dim=y.dim0; end
    y.mat0=y.mat;
    y.dim0=y.dim;
    switch(dim), 
        case 1, order=[1,3,2]; flip=[1 1 1];
        case 2, order=[2,3,1]; flip=[1,1,-1];
        case 3, order=[1,2,3]; flip=[1,1,1];
    end
    y.mat(:,1:3)=y.mat(:,order);
    y.dim=y.dim(order);
    M=eye(4);
    M(flip<0,1:3)=-M(flip<0,1:3);
    M(flip<0,4)=reshape(y.dim(flip<0)'+1,[],1);
    y.mat=y.mat*M;
else
    switch(dim),
        case 1, y=permute(x(n,end:-1:1,end:-1:1,:),[3,2,1,4]);
        case 2, y=permute(x(end:-1:1,end+1-n,end:-1:1,:),[3,1,2,4]);
        case 3, y=x(end:-1:1,end:-1:1,n,:);
    end
end
end

function ok=conn_menubuttonmtnfcn(option,hfig,hax,hplot,htxt,hmark,varargin)
if nargin>=7&&ischar(varargin{1})&&strcmp(varargin{1},'cursorup'), isclick=true; 
else isclick=false;
end
ok=1;
%persistent bakpos
global CONN_gui;
pos0=get(hfig,'currentpoint');
pos=round(get(hax,'currentpoint'));
xlim=get(hax,'xlim');
ylim=get(hax,'ylim');
pos=pos(1,1:2);
if pos(1)>=xlim(1)&&pos(1)<=xlim(2)&&pos(2)>=ylim(1)&&pos(2)<=ylim(2),
    switch option
        case 'volume'
            data=get(htxt,'userdata');
            if isfield(data,'buttondown')&&isfield(data.buttondown,'matdim'),
                if ~isempty(data.buttondown.z), z=data.buttondown.z; else z=data.n; end
                if pos(1)>=1&&((pos(1)<=data.buttondown.matdim.dim(1))||(numel(data.buttondown.matdim.dim)>3&&pos(1)<=data.buttondown.matdim.dim(1)*data.buttondown.matdim.dim(4)))&&pos(2)>=1&&((pos(2)<=data.buttondown.matdim.dim(2))||(numel(data.buttondown.matdim.dim)>4&&pos(2)<=data.buttondown.matdim.dim(2)*data.buttondown.matdim.dim(5)))
                    posabs=pos;
                    pos(1)=1+mod(pos(1)-1,data.buttondown.matdim.dim(1));
                    pos(2)=1+mod(pos(2)-1,data.buttondown.matdim.dim(2));
                    xyz=round(data.buttondown.matdim.mat(1:3,:)*[data.buttondown.matdim.dim(1)+1-pos(1),data.buttondown.matdim.dim(2)+1-pos(1,2),z,1]');
                    v=spm_get_data(CONN_gui.refs.rois.V,pinv(CONN_gui.refs.rois.V(1).mat)*[xyz;1]);
                    if numel(v)>1, [v,iv]=max(v); if v>0, v=iv; end; end
                    if v>0, txt=CONN_gui.refs.rois.labels{v}; else  txt=''; end
                    %if v>0, txt=[CONN_gui.refs.rois.filenameshort,'.',CONN_gui.refs.rois.labels{v}]; else  txt=''; end
                    str={['x,y,z = (',num2str(xyz(1)),',',num2str(xyz(2)),',',num2str(xyz(3)),') mm']};
                    if ~isempty(txt), str=[{txt} str]; end
                    %strend=str{end};
                    if isfield(data,'displayed')&&isfield(data.displayed,'val')&&~isempty(data.displayed.val)
                        if data.p>0, 
                            txt=sprintf('stat = %g; p = %f',data.displayed.val(round(posabs(2)),round(posabs(1))),data.displayed.thr(round(posabs(2)),round(posabs(1))));
                            str=[str reshape(cellstr(txt),1,[])];
                        elseif ~isnan(data.displayed.val(round(posabs(2)),round(posabs(1)))), 
                            txt=sprintf('value = %g',data.displayed.val(round(posabs(2)),round(posabs(1))));
                            str=[str reshape(cellstr(txt),1,[])];
                        end
                        
                    end
                    if isfield(data.buttondown,'callback')&&~isempty(data.buttondown.callback)
                        if numel(data.buttondown.matdim.dim)>=5, [txt1,txt2]=feval(data.buttondown.callback,xyz,1+floor((posabs(1)-1)/data.buttondown.matdim.dim(1))+data.buttondown.matdim.dim(4)*floor((posabs(2)-1)/data.buttondown.matdim.dim(2)));
                        else [txt1,txt2]=feval(data.buttondown.callback,xyz);
                        end
                        str=[reshape(cellstr(txt1),1,[]) str reshape(cellstr(txt2),1,[])]; 
                    end
                    strend=str;
                    %if numel(data.buttondown.matdim.dim)>=5, str=[{sprintf('Image #%d',1+floor((posabs(1)-1)/data.buttondown.matdim.dim(1))+data.buttondown.matdim.dim(4)*floor((posabs(2)-1)/data.buttondown.matdim.dim(2)))} str]; end
                    %set(htxt,'units','pixels','position',[pos0(1:2)+[-2 -2] 6 6],'tooltipstring',conn_cell2html(str));
                    set(htxt,'units','pixels','string',strend);
                    hext=get(htxt,'extent'); hext=hext(end-1:end)+4;
                    %hext=min([400 inf],hext);
                    set(htxt,'string',str);
                    hext2=get(htxt,'extent'); hext2=hext2(end-1:end)+4;
                    %hext2=min([400 inf],hext2);
                    hang=(posabs(1)-xlim(1))/max(eps,xlim(2)-xlim(1));
                    newpos=[pos0(1:2)+[-hext(1)*hang 10] max(hext,hext2)];
                    %newpos=newpos+[0 -newpos(4)-20 0 0];
                    %if ~isempty(bakpos)&&abs(newpos(1)-bakpos(1))<50, newpos(1)=.1*newpos(1)+.9*bakpos(1); end
                    %bakpos=newpos; 
                    set(htxt,'units','pixels','string',str,'position',newpos);
                    if numel(data.buttondown.matdim.dim)>=5&&any(data.buttondown.matdim.dim(4:5)>1), set(hmark,'xdata',1+mod(pos(1)-1+data.buttondown.matdim.dim(1)*(0:data.buttondown.matdim.dim(5)*data.buttondown.matdim.dim(4)-1),data.buttondown.matdim.dim(1)*data.buttondown.matdim.dim(4)),'ydata',pos(2)+data.buttondown.matdim.dim(2)*floor((0:data.buttondown.matdim.dim(4)*data.buttondown.matdim.dim(5)-1)/data.buttondown.matdim.dim(4)));
                    else set(hmark,'xdata',[],'ydata',[]);
                    end
                    if isclick&&isfield(data.buttondown,'callbackclick')&&~isempty(data.buttondown.callbackclick)
                        if numel(data.buttondown.matdim.dim)>=5, feval(data.buttondown.callbackclick,xyz,1+floor((posabs(1)-1)/data.buttondown.matdim.dim(1))+data.buttondown.matdim.dim(4)*floor((posabs(2)-1)/data.buttondown.matdim.dim(2)));
                        else [txt1,txt2]=feval(data.buttondown.callbackclick,xyz);
                        end
                    end
                end
            else
                if ~isfield(data,'buttondown')||~isfield(data.buttondown,'callback')||isempty(data.buttondown.callback)
                    str=sprintf('x,y = (%d,%d)',round(pos(1)),round(pos(2)));
                else
                    str=feval(data.buttondown.callback,pos(1:2));
                    if isempty(str), str=sprintf('x,y = (%d,%d)',round(pos(1)),round(pos(2))); end
                end
                %cdata=get(hplot(1),'cdata');
                %pos=round(max(1,min([size(cdata,2),size(cdata,1)], pos)));
                %if any(cdata(pos(2),pos(1),:),3), str=sprintf('f(%d,%d) > 0',pos(1),pos(2)); else str=sprintf('f(%d,%d) = 0',pos(1),pos(2)); end
                set(htxt,'units','pixels','string',str);
                hext=get(htxt,'extent'); hext=hext(end-1:end);
                set(htxt,'position',[pos0(1:2)+[10 10] hext]);
                if isclick&&isfield(data.buttondown,'callbackclick')&&~isempty(data.buttondown.callbackclick)
                    feval(data.buttondown.callbackclick,pos(1:2));
                    ok=2; % placeholder, evals may need cleaner return
                end
            end
        case 'line'
            xdata=get(hplot(1),'xdata');
            [nill1,idx1]=min(abs(xdata-pos(1)));
            xdata=xdata(idx1);
            if nill1<1
                ydata=[];zdata=[];
                for n1=1:numel(hplot)
                    if strcmp(get(hplot(n1),'visible'),'on')&&strcmp(get(hplot(n1),'tag'),'plot')
                        temp=get(hplot(n1),'ydata');
                        ydata=[ydata temp(idx1)];
                        temp=get(hplot(n1),'zdata');
                        if ~isempty(temp), zdata=[zdata temp(idx1)]; end
                    end
                end
                if isempty(zdata), zdata=ydata; end
                maxt1=max(0,floor(log10(max(eps,max(abs(xdata(:)))))));
                maxt2=max(0,floor(log10(max(eps,max(abs(zdata(:)))))));
                str=sprintf('f(%s) = %s',mat2str(xdata,3+maxt1),mat2str(zdata',3+maxt2));
                set(htxt,'units','pixels','string',str);
                hext=get(htxt,'extent'); hext=hext(end-1:end);
                set(htxt,'position',[pos0(1:2)+[10 10] hext]);
                %hang=(pos(1)-xlim(1))/max(eps,xlim(2)-xlim(1));
                %set(htxt,'position',[pos0(1:2)+[-hext(1)*hang 10] hext]);
                if numel(ydata)>1, set(hmark,'xdata',xdata+zeros(size(ydata)),'ydata',sort(ydata),'zdata',sort(ydata));
                elseif numel(ydata)==1, set(hmark,'xdata',xdata,'ydata',ydata,'zdata',ydata);
                else set(hmark,'xdata',[],'ydata',[],'zdata',[]);
                end
            end
        otherwise, disp(sprintf('warning: unknown option %s',type));
    end
    %try, uistack(htxt,'top'); end
    %set(htxt,'position',[pos+.05*[diff(xlim) diff(ylim)] 1],'string',str);
end
end


% function conn_menubuttondownfcn(varargin)
% global CONN_gui;
% if strcmp(get(gcbf,'selectionType'),'normal')
%     data=get(gcbo,'userdata');
%     if isfield(data,'buttondown'), 
%         data=data.buttondown;
%         xyz=get(data.h1,'currentpoint');
%         xyz=round(data.matdim.mat(1:3,:)*[data.matdim.dim(1)+1-xyz(1),data.matdim.dim(2)+1-xyz(1,2),data.z,1]');
%         v=spm_get_data(CONN_gui.refs.rois.V,pinv(CONN_gui.refs.rois.V.mat)*[xyz;1]);
%         if v>0, txt=[CONN_gui.refs.rois.filenameshort,'.',CONN_gui.refs.rois.labels{v}]; else  txt=''; end
%         %if v>0, txt=[CONN_gui.refs.rois.filenameshort,'.',CONN_gui.refs.rois.labels{v}]; else  txt=''; end
%         h=findobj('tag','conn_menubuttondownfcn');if isempty(h), h=figure('units','pixels','position',[get(0,'pointerlocation')-[600,30],450,40]);else  figure(h); end;
%         set(h,'units','pixels','position',[get(0,'pointerlocation')-[150,30],0,0]+get(h,'position')*[0,0,0,0;0,0,0,0;-1,0,1,0;0,0,0,1],'menubar','none','numbertitle','off','color','k','tag','conn_menubuttondownfcn');
%         clf(h);text(0,1,['x,y,z = (',num2str(xyz(1)),',',num2str(xyz(2)),',',num2str(xyz(3)),') mm'],'color','y','fontweight','bold','horizontalalignment','center','fontsize',8+CONN_gui.font_offset);
%         text(0,0,txt,'color','y','fontweight','bold','horizontalalignment','center','fontsize',8+CONN_gui.font_offset,'interpreter','none');set(gca,'units','norm','position',[0,0,1,1],'xlim',[-1,1],'ylim',[-.5,1.5],'visible','off');
%     end
%     %hc=get(0,'children');if length(hc)>0&&hc(1)~=h,hc=[h;hc(hc~=h)];set(0,'children',h); end
% end
% end


