function handles = loadNewImage(handles)

if handles.loadMemMaps
    % load memory maps:
    load([handles.Pub.dataDestination 'memMaps'])
else
    memMaps = handles.memMaps;
end
flag = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD DATA FROM MEMORY MAPS BASED ON USER SELECTION
%try
str = {'whole','win'};
if handles.freqCompOn
    switch handles.ZPFtest
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 2 % pairwise ZPF test
            if handles.freqBand2 ~= handles.freqBand
                if handles.freqBand2 > handles.freqBand
                    compDir = 1;
                else
                    compDir = 2;
                end
                IDX = [0 2 4];
                if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
                    handles.dataT = swapbytes( memMaps.(handles.Priv.PFMapName).(str{handles.win+1}...
                        ).([handles.Priv.prefixSession num2str(handles.dataset)...
                        ]).(handles.Priv.simM{3}).([handles.Priv.prefixFreqComp ...
                        num2str(handles.freqComp)]).Data.xyzc(:,:,:,IDX(handles.alpha)+compDir) );
                else
                    handles.dataT = memMaps.(handles.Priv.PFMapName).(str{handles.win+1}...
                        ).([handles.Priv.prefixSession num2str(handles.dataset)...
                        ]).(handles.Priv.simM{3}).([handles.Priv.prefixFreqComp ...
                        num2str(handles.freqComp)]).Data.xyzc(:,:,:,IDX(handles.alpha)+compDir);
                end
            else
                handles.dataT = zeros(handles.Priv.dataSize(handles.Priv.nrSessions,1:3));
            end
            %            if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
            %                handles.dataT = swapbytes(handles.dataT);
            %            end
            if handles.swapBytesOn % swap bytes if option is specified
                handles.dataT = swapbytes(handles.dataT);
            end
            % normalize between zero and one:
            %            handles.dataT = handles.dataT/handles.subjPairs;
        case 1 % sum ZPF test
            if handles.freqBand2 ~= handles.freqBand && ~isnan(handles.freqComp)
                if handles.freqBand2 > handles.freqBand
                    K = 1;
                else
                    K = -1;
                end
                % load sum ZPF maps:
                if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
                    handles.dataT = sum(swapbytes( memMaps.(handles.Priv.PFmatMapName).(str{handles.win+1}...
                        ).([handles.Priv.prefixSession num2str(handles.dataset)...
                        ]).(handles.Priv.simM{3}).([handles.Priv.prefixFreqComp ...
                        num2str(handles.freqComp)]).Data.xyzc ),4);
                else
                    handles.dataT = sum(memMaps.(handles.Priv.PFmatMapName).(str{handles.win+1}...
                        ).([handles.Priv.prefixSession num2str(handles.dataset)...
                        ]).(handles.Priv.simM{3}).([handles.Priv.prefixFreqComp ...
                        num2str(handles.freqComp)]).Data.xyzc,4);
                end
                %               if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
                %                  handles.dataT = swapbytes(handles.dataT);
                %               end
                if handles.swapBytesOn % swap bytes if option is specified
                    handles.dataT = swapbytes(handles.dataT);
                end
                handles.dataT = K*handles.dataT; % flip values to change contrast map direction "<" to ">"
            else
                handles.dataT = zeros(handles.Priv.dataSize(handles.Priv.nrSessions,1:3));
            end
            
            %          handles.maxSc = max(handles.dataT(:));
            %          if handles.maxSc ~= 0
            %              handles.dataT = handles.dataT/handles.maxSc;
            %          end
    end
    flag = 1;
    mapType = 'freqComp';
end
if ~flag
    if handles.sessionCompOn
        if handles.dataset2 ~= handles.dataset && ~isnan(handles.sessionComp)
            if handles.dataset2 > handles.dataset
                K = 1;
            else
                K = -1;
            end
            % load sum ZPF maps:
            if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
                handles.dataT = sum(swapbytes( memMaps.(handles.Priv.PFmatMapSessionName).(str{handles.win+1}...
                    ).([handles.Priv.prefixFreqBand num2str(handles.freqBand-1)...
                    ]).(handles.Priv.simM{3}).([handles.Priv.prefixSessComp...
                    num2str(handles.sessionComp)]).Data.xyzc),4);
            else
                handles.dataT = sum( memMaps.(handles.Priv.PFmatMapSessionName).(str{handles.win+1}...
                    ).([handles.Priv.prefixFreqBand num2str(handles.freqBand-1)...
                    ]).(handles.Priv.simM{3}).([handles.Priv.prefixSessComp...
                    num2str(handles.sessionComp)]).Data.xyzc,4);
            end
            %               if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
            %                  handles.dataT = swapbytes(handles.dataT);
            %               end
            if handles.swapBytesOn % swap bytes if option is specified
                handles.dataT = swapbytes(handles.dataT);
            end
            handles.dataT = K*handles.dataT; % flip values to change contrast map direction "<" to ">"
        else
            handles.dataT = zeros(handles.Priv.dataSize(handles.Priv.nrSessions,1:3));
        end
        
        %          handles.maxSc = max(handles.dataT(:));
        %          if handles.maxSc ~= 0
        %              handles.dataT = handles.dataT/handles.maxSc;
        %          end
        flag = 1;
        mapType = 'sessionComp';
    end
end
if ~flag
    if handles.allFreq
        [handles.dataT,R] = freqComparison(handles,memMaps);
        mapType = 'allFreq';
    elseif handles.Synch == 0 && handles.timeWinAnalysis == 1 % get phase sync map
        handles.dataT = zeros(handles.Priv.dataSize(handles.Priv.nrSessions,1:3));
                
%         Le = length(memMaps.(handles.Priv.phaseMapName).([handles.Priv.prefixSession num2str(handles.dataset)...
%             ]).([handles.Priv.prefixFreqBand num2str(handles.freqBand-1)...
%             ]).Data);
%         Dat = zeros(handles.Priv.dataSize(handles.dataset,1:3));
%         ss=handles.anatomy~=65;
%         for m = 1:Le
%             if sum(sum(squeeze(ss(m,:,:)))) > 0
%                 Dat(m,:,:) = squeeze(memMaps.(handles.Priv.phaseMapName).([handles.Priv.prefixSession num2str(handles.dataset)...
%                     ]).([handles.Priv.prefixFreqBand num2str(handles.freqBand-1)...
%                     ]).Data(m).tyz(handles.timeVal,:,:));
%             end
%         end
%         handles.dataT = Dat;
        mapType = 'phaseMap_NoStatisticalMapPlot';
    else % get ISC map
        
        if handles.mapType == 1
            handles.dataT = memMaps.(handles.Priv.resultMapName).(str{handles.win+1}...
                ).([handles.Priv.prefixFreqBand num2str(handles.freqBand-1)...
                ]).([handles.Priv.prefixSession num2str(handles.dataset)...
                ]).(handles.Priv.simM{handles.SimMeasure+2}).Data(handles.timeVal).xyz;
        else
            handles.dataT = memMaps.(handles.Priv.statMapName).(str{handles.win+1}...
                ).([handles.Priv.prefixFreqBand num2str(handles.freqBand-1)...
                ]).([handles.Priv.prefixSession num2str(handles.dataset)...
                ]).(handles.Priv.simM{handles.SimMeasure+2}).Data(handles.timeVal).xyz(:,:,:,handles.mapType-1);
        end
        
        if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
            handles.dataT = swapbytes(handles.dataT);
        end
        if handles.swapBytesOn % swap bytes if option is specified
            handles.dataT = swapbytes(handles.dataT);
        end
        if handles.mapType == 1
            mapType = 'ISCmap';
        elseif handles.mapType == 2
            mapType = 'ISCtmap';
        else
            mapType = 'otherISCmap';
        end
    end
end

handles.repeatLoadingImages = 0;
clear memMaps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SCALE DATA FOR FAST VISUALIZATION:
handles.maxSc = max(max(handles.dataT(:)));%,-1*min(handles.dataT(:)));
handles.minSc = max(0,min(min(handles.dataT(:))));%,-1*min(handles.dataT(:)));
handles = updateThresholds(handles,mapType);

%handles = setColorMapScale(handles);

%if strcmp(mapType,'freqComp') || strcmp(mapType,'sessionComp')
% quantize floating-point synchronization data:
% if handles.freqCompOn && handles.ZPFtest == 2
maxSc1 = max(handles.dataT(:));
minSc1 = max(min(handles.dataT(:)),0);
maxSc2 = max(-1*handles.dataT(:));
minSc2 = max(min(-1*handles.dataT(:)),0);

dataT1 = zeros(size(handles.dataT));
dataT2 = zeros(size(handles.dataT));

dataT1(handles.dataT>0) = handles.dataT(handles.dataT>0);
dataT2(handles.dataT<0) = -1*handles.dataT(handles.dataT<0);

handles.ScaleMax1 = maxSc1;
handles.ScaleMin1 = minSc1;
handles.ScaleMax2 = maxSc2;
handles.ScaleMin2 = minSc2;

%    dataT1(dataT1 >= handles.ScaleMax1) = handles.ScaleMax1;
%    dataT1(dataT1 <= handles.ScaleMin1) = handles.ScaleMin1;
%    dataT1 = (dataT1-handles.ScaleMin1)/handles.ScaleMax1;
MaskedI1 = dataT1 >= handles.Threshold;
MaskedI2 = dataT2 >= handles.Threshold;

if ~strcmp(mapType,'allFreq')
    
    %    dataT1 = round(handles.colMapSize*dataT1/max(handles.ScaleMax1,handles.ScaleMax2));
    %    dataT2(dataT2 >= handles.ScaleMax1) = handles.ScaleMax1;
    %    dataT2(dataT2 <= handles.ScaleMin1) = handles.ScaleMin1;
    %    dataT2 = (dataT2-handles.ScaleMin1)/handles.ScaleMax1;
    %    dataT2 = round(handles.colMapSize*dataT2/max(handles.ScaleMax1,handles.ScaleMax2));
    %    dataT2(dataT2==handles.colMapSize+handles.rangeAnatomy) = handles.ScaleMin1;
    switch handles.direction
        case -1
            dataT2 = round(handles.colMapSize*dataT2/handles.ScaleMax2);
            handles.dataT = dataT2;
            dataMax = maxSc2;
            MaskedI = MaskedI2;
            handles.dataT = handles.dataT + handles.colMapSize + handles.rangeAnatomy;
            
            handles.ScaleMax2quant = max(nonzeros(handles.dataT(:)));
            handles.ScaleMin2quant = min(nonzeros(handles.dataT(:)));
            if isempty(find(MaskedI(:)))
                handles.ScaleMax2quant = NaN;
                handles.ScaleMin2quant = NaN;
            end
            
        case 0
            %           handles.dataT = dataT1 + dataT2;
            dataT1 = round(handles.colMapSize*dataT1/max(handles.ScaleMax1,handles.ScaleMax2));
            handles.ScaleMin1quant = min(nonzeros(dataT1(:)));
            handles.ScaleMax1quant = max(nonzeros(dataT1(:)));
            
            dataT2 = round(handles.colMapSize*dataT2/max(handles.ScaleMax1,handles.ScaleMax2));
            dataT2 = dataT2 + handles.colMapSize + handles.rangeAnatomy;
            dataT2(dataT2 == handles.colMapSize + handles.rangeAnatomy) = 0;
            
            handles.ScaleMin2quant = min(nonzeros(dataT2(:)));
            handles.ScaleMax2quant = max(nonzeros(dataT2(:)));
            
            handles.dataT = dataT1 + dataT2;
            dataMax = max(maxSc1,maxSc2);
            MaskedI = MaskedI1 | MaskedI2;
            if isempty(find(MaskedI1(:)))
                handles.ScaleMax1quant = NaN;
                handles.ScaleMin1quant = NaN;
            end
            if isempty(find(MaskedI2(:)))
                handles.ScaleMax2quant = NaN;
                handles.ScaleMin2quant = NaN;
            end
        case 1
            dataT1 = round(handles.colMapSize*dataT1/handles.ScaleMax1);
            handles.dataT = dataT1;
            dataMax = maxSc1;
            MaskedI = MaskedI1;
            
            handles.ScaleMax1quant = max(nonzeros(handles.dataT(:)));
            handles.ScaleMin1quant = min(nonzeros(handles.dataT(:)));
            if isempty(find(MaskedI(:)))
                handles.ScaleMax1quant = NaN;
                handles.ScaleMin1quant = NaN;
            end
            
    end
    
    handles.dataT = int16(handles.dataT);
    
else
    switch handles.direction
        case -1
            MaskedI = MaskedI2;
            R(MaskedI) = R(MaskedI) + 198;
            handles.ScaleMax2quant = max(R(:));%max(nonzeros(handles.dataT(:)));
            handles.ScaleMin2quant = 199;%min(nonzeros(handles.dataT(:)));         
            if isempty(find(MaskedI(:)))
                handles.ScaleMax2quant = NaN;
                handles.ScaleMin2quant = NaN;
            end
        case 0            
            MaskedI = MaskedI1 | MaskedI2;
            R(MaskedI1) = R(MaskedI1) + 191;
            R(MaskedI2) = R(MaskedI2) + 198;
            ma1 = max(unique(R(MaskedI1)));
            ma2 = max(unique(R(MaskedI2)));
            handles.ScaleMin1quant = 192;
            handles.ScaleMax1quant = ma1;                        
            handles.ScaleMin2quant = 199;
            handles.ScaleMax2quant = ma2;            
            if isempty(find(MaskedI1(:)))
                handles.ScaleMax1quant = NaN;
                handles.ScaleMin1quant = NaN;
            end
            if isempty(find(MaskedI2(:)))
                handles.ScaleMax2quant = NaN;
                handles.ScaleMin2quant = NaN;
            end
        case 1
            MaskedI = MaskedI1;            
            R(MaskedI) = R(MaskedI) + 191;
            handles.ScaleMax1quant = max(R(:));
            handles.ScaleMin1quant = 192;
            if isempty(find(MaskedI(:)))
                handles.ScaleMax1quant = NaN;
                handles.ScaleMin1quant = NaN;
            end
    end
end
    %dataMax1 = min(single(maxSc1),single(handles.ScaleMax1));
    %dataMax2 = min(single(maxSc2),single(handles.ScaleMax1));
    %dataMax = max(dataMax1,dataMax2);
    %dataMax1 = maxSc1;
    %dataMax2 = maxSc2;
    %dataMax = max(dataMax1,dataMax2);
    %else
    %    handles.dataT(handles.dataT >= handles.ScaleMax1) = handles.ScaleMax1;
    %    handles.dataT(handles.dataT <= handles.ScaleMin1) = handles.ScaleMin1;
    %    handles.dataT = (handles.dataT-handles.ScaleMin1)/handles.ScaleMax1;
    %    handles.dataT = round(handles.colMapSize*handles.dataT);
    %    warning off
    %    handles.dataT = int16(handles.dataT);
    %    warning on
    %    dataMax = min(single(handles.maxSc),single(handles.ScaleMax1));
    %end
    
    
    % return red colored brain region to its original color:
    %if isfield(handles,'prevReg')
    %    handles.dataAt(handles.dataAt == handles.colMapSize+...
    %        handles.rangeAnatomy+handles.rangeAtlas) = handles.prevReg;
    %end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % THRESHOLD DATA:
    if ( handles.Masking == 1 )
        if handles.MaskingType == 1
            % create mask based on current brain region:
            MaskedI = handles.atlas; % == handles.regionLabelsOrig(handles.CurrentRegion);
        end
        %         % create mask based on given threshold:
        %         warning off
        %         %if handles.freqCompOn && handles.ZPFtest == 1
        %         switch handles.direction
        %             case -1
        %                 % get quantized threshold and mask data:
        %                 handles.TH = round((handles.Threshold*max( double(handles.dataT(:))) )/dataMax);
        %                 MaskedI = handles.dataT >= handles.TH;
        %
        %                 % create offset for plotting:
        %                 handles.dataT = handles.dataT + handles.colMapSize + handles.rangeAnatomy;
        %                 handles.TH = handles.TH  + handles.colMapSize + handles.rangeAnatomy;
        %             case 0
        %
        %                 handles.TH = round((handles.Threshold*max( double(handles.dataT(:))) )/dataMax);
        %                 MaskedI = handles.dataT >= handles.TH;
        %                 handles.TH = round((handles.Threshold*max( double(handles.dataT(:))) )/dataMax);
        %                 MaskedI = handles.dataT >= handles.TH;
        %
        %
        %                 MaxVal = max(max(dataT1(:)),max(dataT2(:)-handles.colMapSize-handles.rangeAnatomy));
        %                 handles.TH = round(handles.Threshold*MaxVal/dataMax);
        %                 MaskedI = (handles.dataT >= handles.TH & handles.dataT < handles.colMapSize) | (handles.dataT >= handles.TH + handles.colMapSize+handles.rangeAnatomy);
        %             case 1
        %                 handles.TH = round((handles.Threshold*max( double(handles.dataT(:))) )/dataMax);
        %                 MaskedI = handles.dataT >= handles.TH;
        %
        %         end
        %         warning on
        
        % overlay synchronization map on anatomical template:
        handles.SegIm = handles.anatomy;
        if handles.allFreq
            handles.SegIm(find(MaskedI)) = R(find(MaskedI));
        else
            handles.SegIm(find(MaskedI)) = handles.dataT(find(MaskedI));
        end
        % set image background to black by indexing last value in the colormap:
        handles.SegIm(handles.SegIm == 65) = size(get(gcf,'colormap'),1);
    else
        % if no segmentation is specified, anatomical data is not needed:
        if handles.allFreq
            handles.SegIm = R;
        else
            handles.SegIm = handles.dataT;
        end        
    end
    
    % overlay atlas on anatomical image:
    %handles.dataAs = handles.anatomy;
    %handles.dataAs(find(handles.dataAt)) = handles.dataAt(find(handles.dataAt));
    %handles.dataAt = handles.dataAs;
    
    % set background to black by indexing last value in the colormap:
    %handles.dataAt(handles.dataAt == 0) = size(get(gcf,'colormap'),1);
    
    % color currently activated brain region using red color:
    %MI = handles.dataAt == handles.labels{handles.At}(handles.CurrentRegion)+handles.colMapSize + handles.rangeAnatomy+1;
    %handles.prevReg = handles.labels{handles.At}(handles.CurrentRegion)+handles.colMapSize + handles.rangeAnatomy+1;
    %handles.dataAt(MI) = handles.colMapSize+handles.rangeAnatomy+handles.rangeAtlas;
    switch handles.direction
        case -1
            set(handles.Colbar1,'Visible','off')
            if isnan(handles.ScaleMin2quant) || isnan(handles.ScaleMax2quant)
                set(handles.Colbar2,'Visible','off')
            else
                set(handles.Colbar2,'Visible','on')
                if strcmp(mapType,'allFreq')
                    bn = handles.bandNames;clear bn2
                    for m = 2:length(bn);bn2{m-1} = bn{m};end;bn=bn2;
                        set(handles.Colbar2,'XLim',[handles.ScaleMin2quant-0.5 handles.ScaleMax2quant+0.5],'XTick',(handles.ScaleMin2quant:handles.ScaleMax2quant),'XTickLabel',bn);                
                else                    
                        set(handles.Colbar2,'XLim',[handles.ScaleMin2quant handles.ScaleMax2quant],'XTick',linspace(handles.ScaleMin2quant,handles.ScaleMax2quant,8),'XTickLabel',round(100*linspace(handles.ScaleMin2,handles.ScaleMax2,8))/100);
                end
            end
        case 0
            if isnan(handles.ScaleMin2quant) || isnan(handles.ScaleMax2quant)
                set(handles.Colbar2,'Visible','off')
            else
                set(handles.Colbar2,'Visible','on')
                if strcmp(mapType,'allFreq')
                    bn = handles.bandNames;clear bn2
                    for m = 2:length(bn);bn2{m-1} = bn{m};end;bn=bn2;
                    set(handles.Colbar2,'XLim',[handles.ScaleMin2quant-0.5 handles.ScaleMax2quant+0.5],'XTick',(handles.ScaleMin2quant:handles.ScaleMax2quant),'XTickLabel',bn);
                else                                    
                    set(handles.Colbar2,'XLim',[handles.ScaleMin2quant handles.ScaleMax2quant],'XTick',linspace(handles.ScaleMin2quant,handles.ScaleMax2quant,8),'XTickLabel',round(100*linspace(handles.ScaleMin2,handles.ScaleMax2,8))/100);
                end
            end
            if isnan(handles.ScaleMin1quant) || isnan(handles.ScaleMax1quant)
                set(handles.Colbar1,'Visible','off')
            else
                set(handles.Colbar1,'Visible','on')
                if strcmp(mapType,'allFreq')
                    bn = handles.bandNames;clear bn2
                    for m = 2:length(bn);bn2{m-1} = bn{m};end;bn=bn2;
                    set(handles.Colbar1,'XLim',[handles.ScaleMin1quant-0.5 handles.ScaleMax1quant+0.5],'XTick',(handles.ScaleMin1quant:handles.ScaleMax1quant),'XTickLabel',bn);
                else                    
                    set(handles.Colbar1,'XLim',[handles.ScaleMin1quant handles.ScaleMax1quant],'XTick',linspace(handles.ScaleMin1quant,handles.ScaleMax1quant,8),'XTickLabel',round(100*linspace(handles.ScaleMin1,handles.ScaleMax1,8))/100);
                end
            end
        case 1
            set(handles.Colbar2,'Visible','off')
            if isnan(handles.ScaleMin1quant) || isnan(handles.ScaleMax1quant)
                set(handles.Colbar1,'Visible','off')
            else
                set(handles.Colbar1,'Visible','on')
                if strcmp(mapType,'allFreq')
                    bn = handles.bandNames;clear bn2
                    for m = 2:length(bn);bn2{m-1} = bn{m};end;bn=bn2;
                    set(handles.Colbar1,'XLim',[handles.ScaleMin1quant-0.5 handles.ScaleMax1quant+0.5],'XTick',(handles.ScaleMin1quant:handles.ScaleMax1quant),'XTickLabel',bn);
                else                    
                    set(handles.Colbar1,'XLim',[handles.ScaleMin1quant handles.ScaleMax1quant],'XTick',linspace(handles.ScaleMin1quant,handles.ScaleMax1quant,8),'XTickLabel',round(100*linspace(handles.ScaleMin1,handles.ScaleMax1,8))/100);
                end
            end
    end
    %set(handles.Colbar1,'XLim',[-1 200])
    %ddd=0;
    %figure,hist(unique(handles.SegIm(:)),min(handles.SegIm(:)):max(handles.SegIm(:)))
    %handles = setCurrentColorBar(handles);
    
    
    
