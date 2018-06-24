function [oW,dW,fW,occ,fcc,dcc] = filtSim(Cort)

%linInds=(find(Cort==7|Cort==6|Cort==3|Cort==1));
linInds = find(Cort==3);

linInds = linInds(51:100);

oW = zeros(5,length(linInds));
dW = zeros(5,length(linInds)); 
fW = zeros(5,length(linInds));
occ = zeros(5,length(linInds));
fcc = zeros(5,length(linInds));
dcc = zeros(5,length(linInds));

%[odata cData kc cc] = loadTS(linInds(k),'app',1);

for k = 1:size(linInds,1)
    disp(['Iter: ' num2str(k) '/' num2str(size(linInds,1))])
    odata = loadTS(linInds(k),'app',1);
    fdata = filtData(odata);
    ddata = detrendData(odata);
    for m = 1:size(odata,2)
        [oT(m,:,:) oX(m,:,:)] = ISWT_TESTI(odata(:,m),'approx',0);
        [fT(m,:,:) fX(m,:,:)] = ISWT_TESTI(fdata(:,m),'approx',0);
        [dT(m,:,:) dX(m,:,:)] = ISWT_TESTI(ddata(:,m),'approx',0);
    end
    for n = 1:5
        oD = squeeze(oT(:,n,:))';
        fD = squeeze(fT(:,n,:))';
        dD = squeeze(dT(:,n,:))';
        oW(n,k) = calcKendall(oD);
        fW(n,k) = calcKendall(fD);
        dW(n,k) = calcKendall(dD);
        occ(n,k) = calcPearson(corrcoef(oD));
        fcc(n,k) = calcPearson(corrcoef(fD));
        dcc(n,k) = calcPearson(corrcoef(dD));
    end

    %     save(['C:\fMRI data\frontalAreas\ASig' num2str(k)],'ASig');
end


figure
for k = 1:5
    subplot(5,1,k)
    plot([oW(k,:)' fW(k,:)' dW(k,:)']);title(['Kendall level ' num2str(k)]);
end
legend('orig','detrend','filt')
figure
for k = 1:5
    subplot(5,1,k)
    plot([occ(k,:)' fcc(k,:)' dcc(k,:)']);title(['Pearson level ' num2str(k)]);
end
legend('orig','detrend','filt')


function fdata = filtData(data)

load('C:\fMRI data\GUI\Hd.mat');
for k = 1:size(data,2)
    fdata(:,k) = filter(Hd,data(:,k));
end
fdata = (fdata-repmat(mean(fdata),size(fdata,1),1))./repmat(std(fdata),size(fdata,1),1);

function ddata = detrendData(data)

for k = 1:size(data,2)
    dd = iddata(data(:,k),[],3.4);
    dd = detrend(dd,1);
    e = get(dd);
    ddata(:,k) = e.OutputData{1};
end
ddata = (ddata-repmat(mean(ddata),size(ddata,1),1))./repmat(std(ddata),size(ddata,1),1);


