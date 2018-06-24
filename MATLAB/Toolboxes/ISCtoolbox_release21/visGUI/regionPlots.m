function [dataset1,dataset2,dataset3] = regionPlots(W)

% e.g.
% load Xmeanset1winA5 Wcor; A5cor1_ = Wcor;
% load Xmeanset2winA5 Wcor; A5cor2_ = Wcor;
% load Xmeanset1winA4 Wcor; A4cor1_ = Wcor;
% load Xmeanset2winA4 Wcor; A4cor2_ = Wcor;
% load Xmeanset1winA3 Wcor; A3cor1_ = Wcor;
% load Xmeanset2winA3 Wcor; A3cor2_ = Wcor;
% load Xmeanset1winA2 Wcor; A2cor1_ = Wcor;
% load Xmeanset2winA2 Wcor; A2cor2_ = Wcor;
% load Xmeanset1winA1 Wcor; A1cor1_ = Wcor;
% load Xmeanset2winA1 Wcor; A1cor2_ = Wcor;
% 
% clear Wcor;
% [A5cor1.dataset1 A5cor1.dataset2 A5cor1.dataset3] = regionPlots(A5cor1_);
% [A5cor2.dataset1 A5cor2.dataset2 A5cor2.dataset3] = regionPlots(A5cor2_);
% [A4cor1.dataset1 A4cor1.dataset2 A4cor1.dataset3] = regionPlots(A4cor1_);
% [A4cor2.dataset1 A4cor2.dataset2 A4cor2.dataset3] = regionPlots(A4cor2_);
% [A3cor1.dataset1 A3cor1.dataset2 A3cor1.dataset3] = regionPlots(A3cor1_);
% [A3cor2.dataset1 A3cor2.dataset2 A3cor2.dataset3] = regionPlots(A3cor2_);
% [A2cor1.dataset1 A2cor1.dataset2 A2cor1.dataset3] = regionPlots(A2cor1_);
% [A2cor2.dataset1 A2cor2.dataset2 A2cor2.dataset3] = regionPlots(A2cor2_);
% [A1cor1.dataset1 A1cor1.dataset2 A1cor1.dataset3] = regionPlots(A1cor1_);
% [A1cor2.dataset1 A1cor2.dataset2 A1cor2.dataset3] = regionPlots(A1cor2_);
% 
% clear A1cor1_ A1cor2_ A2cor1_ A2cor2_ A3cor1_ A3cor2_ A4cor1_ A4cor2_ A5cor1_ A5cor2_
% save areaDataA
% clear all
% 
% load Xmeanset1winD3 Wcor; D3cor1_ = Wcor;
% load Xmeanset2winD3 Wcor; D3cor2_ = Wcor;
% load Xmeanset1winD2 Wcor; D2cor1_ = Wcor;
% load Xmeanset2winD2 Wcor; D2cor2_ = Wcor;
% load Xmeanset1winD4 Wcor; D4cor1_ = Wcor;
% load Xmeanset2winD4 Wcor; D4cor2_ = Wcor;
% load Xmeanset1winD5 Wcor; D5cor1_ = Wcor;
% load Xmeanset2winD5 Wcor; D5cor2_ = Wcor;
% 
% [D5cor1.dataset1 D5cor1.dataset2 D5cor1.dataset3] = regionPlots(D5cor1_);
% [D5cor2.dataset1 D5cor2.dataset2 D5cor2.dataset3] = regionPlots(D5cor2_);
% [D4cor1.dataset1 D4cor1.dataset2 D4cor1.dataset3] = regionPlots(D4cor1_);
% [D4cor2.dataset1 D4cor2.dataset2 D4cor2.dataset3] = regionPlots(D4cor2_);
% [D3cor1.dataset1 D3cor1.dataset2 D3cor1.dataset3] = regionPlots(D3cor1_);
% [D3cor2.dataset1 D3cor2.dataset2 D3cor2.dataset3] = regionPlots(D3cor2_);
% [D2cor1.dataset1 D2cor1.dataset2 D2cor1.dataset3] = regionPlots(D2cor1_);
% [D2cor2.dataset1 D2cor2.dataset2 D2cor2.dataset3] = regionPlots(D2cor2_);
% 
% clear D1cor1_ D1cor2_ D2cor1_ D2cor2_ D3cor1_ D3cor2_ D4cor1_ D4cor2_ D5cor1_ D5cor2_
% save areaDataD


% [valsA4cor1 dataA4cor1 lab] = regionPlots(A4cor1);
% [valsA4cor2 dataA4cor2 lab] = regionPlots(A4cor2);
% [valsA3cor1 dataA3cor1 lab] = regionPlots(A3cor1);
% [valsA3cor2 dataA3cor2 lab] = regionPlots(A3cor2);
% [valsA1cor1 dataA1cor1 lab] = regionPlots(A1cor1);
% [valsA1cor2 dataA1cor2 lab] = regionPlots(A1cor2);
% [valsD2cor1 dataD2cor1 lab] = regionPlots(D2cor1);
% [valsD2cor2 dataD2cor2 lab] = regionPlots(D2cor2);
% [valsD3cor1 dataD3cor1 lab] = regionPlots(D3cor1);
% [valsD3cor2 dataD3cor2 lab] = regionPlots(D3cor2);
% [valsD4cor1 dataD4cor1 lab] = regionPlots(D4cor1);
% [valsD4cor2 dataD4cor2 lab] = regionPlots(D4cor2);
% [valsD5cor1 dataD5cor1 lab] = regionPlots(D5cor1);
% [valsD5cor2 dataD5cor2 lab] = regionPlots(D5cor2);
%
% load Xmeanset1winA5 Wken; A5ken1 = Wken;
% load Xmeanset2winA5 Wken; A5ken2 = Wken;
% load Xmeanset1winA1 Wken; A1ken1 = Wken;
% load Xmeanset2winA1 Wken; A1ken2 = Wken; 
% load Xmeanset1winD4 Wken; D4ken1 = Wken;
% load Xmeanset2winD4 Wken; D4ken2 = Wken;
% load Xmeanset1winD5 Wken; D5ken1 = Wken;
% load Xmeanset2winD5 Wken; D5ken2 = Wken;
% clear Wken
% [valsA5ken1 dataA5ken1 lab] = regionPlots(A5ken1);
% [valsA5ken2 dataA5ken2 lab] = regionPlots(A5ken2);
% [valsA1ken1 dataA1ken1 lab] = regionPlots(A1ken1);
% [valsA1ken2 dataA1ken2 lab] = regionPlots(A1ken2);
% [valsD4ken1 dataD4ken1 lab] = regionPlots(D4ken1);
% [valsD4ken2 dataD4ken2 lab] = regionPlots(D4ken2);
% [valsD5ken1 dataD5ken1 lab] = regionPlots(D5ken1);
% [valsD5ken2 dataD5ken2 lab] = regionPlots(D5ken2);

load at % load atlas
% process following brain regions:
regionIdx{1} = [1:23];
regionIdx{2} = [24:48];
regionIdx{3} = [49:69];
% 
% lab{1} = '1 Frontal Pole';
% lab{2} = '2 Insular Cortex';
% lab{3} = '3 Superior Frontal Gyrus';
% lab{4} = '4 Middle Frontal Gyrus';
% lab{5} = '5 Inferior Frontal Gyrus, pars triangularis';
% lab{6} = '6 Inferior Frontal Gyrus, pars opercularis';
% lab{7} = '7 Precentral Gyrus';
% lab{8} = '8 Temporal Pole';
% lab{9} = '9 Left Thalamus';
% lab{10} = '10 Right Thalamus';


for r = 1:length(regionIdx)
data = cell(length(regionIdx{r}),size(W,4));
vals = zeros(length(regionIdx{r}),size(W,4));

    for m = 1:length(regionIdx{r})
    for k = 1:size(W,4)
        % obtain certain wavelet-level:
        Wslice = W(:,:,:,k);
        % get prefrontal area data utilizing cortical atlas
        if ~isempty(find(at(:,:,:,1)==regionIdx{r}(m)))
            data{m,k} = Wslice(find(at(:,:,:,1)==regionIdx{r}(m)));
        end
        % get thalamus data utilizing subcortical atlas:
        if ~isempty(find(at(:,:,:,2)==regionIdx{r}(m)))
            data{m,k} = Wslice(find(at(:,:,:,2)==regionIdx{r}(m)));
        end
        % calculate average synch. per region:
        vals(m,k) = sum(data{m,k})/length(data{m,k});
    end
end

% figure,plot(vals');grid on;legend(regionIdx{r});xlabel('Aika');set(gca,'XTick',1:56);
% title('Average Activations in frontal areas')

switch r
    case 1
        dataset1.vals1=vals;
        dataset1.data1=data;
        dataset1.lab1=regionIdx{1};
    case 2
        dataset2.vals1=vals;
        dataset2.data1=data;
        dataset2.lab1=regionIdx{2};
    case 3
        dataset3.vals1=vals;
        dataset3.data1=data;
        dataset3.lab1=regionIdx{3};
end
end