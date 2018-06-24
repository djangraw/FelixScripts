region = 1;
P=path;
path(P,'/home/kauppij/Matlabkoodit/codes');
at = load_nii(Params.PrivateParams.brainAtlases{5});
at = at.img;
regInds = find(at(:)==1);

clear I2 C2 I1 C1 c2 c1 i1 i2 ts1 ts2 TS21 TS11 TS12 TS22


a1 = swapbytes(memMaps.resultMap.whole.band5.Session1.cor.Data.xyz);
a2 = swapbytes(memMaps.resultMap.whole.band5.Session2.cor.Data.xyz);

[c1 i1] = max(a1(regInds));
[c2 i2] = max(a2(regInds));

ii1 = regInds(i1);
ii2 = regInds(i2);

[x1,y1,z1] = ind2sub([91 109 91],ii1);
[x2,y2,z2] = ind2sub([91 109 91],ii2);
for k = 1:12
    ts1(k,:) = swapbytes(memMaps.filtMap.Session1.(['fMRIfilt' num2str(k)]).band5.Data(x1).tyz(:,y1,z1));
    ts2(k,:) = swapbytes(memMaps.filtMap.Session2.(['fMRIfilt' num2str(k)]).band5.Data(x2).tyz(:,y2,z2));
end

for s = 1:66
    A1 = swapbytes(memMaps.cormatMap.whole.band5.Session1.cor.Data.xyzc(:,:,:,s));
    A2 = swapbytes(memMaps.cormatMap.whole.band5.Session2.cor.Data.xyzc(:,:,:,s));
    [C1(s) I1(s)] = max(A1(regInds));
    [C2(s) I2(s)] = max(A2(regInds));
end

II1 = regInds(I1);
II2 = regInds(I2);

INDS = [];
for hh = 1:11
    INDS = [INDS (1+hh*12):(1+hh*12+hh-1)];
end
for k = 1:66
   [x0,y0] = ind2sub([12 12],INDS(k));
   subPairs(k,1) = x0;
   subPairs(k,2) = y0;
   [x1,y1,z1]=ind2sub([91 109 91],II1(k));
   TS11(k,:) = swapbytes(memMaps.filtMap.Session1.(['fMRIfilt' num2str(x0)]).band5.Data(x1).tyz(:,y1,z1));
   TS12(k,:) = swapbytes(memMaps.filtMap.Session1.(['fMRIfilt' num2str(y0)]).band5.Data(x1).tyz(:,y1,z1));

   [x2,y2,z2]=ind2sub([91 109 91],II2(k));
   TS21(k,:) = swapbytes(memMaps.filtMap.Session2.(['fMRIfilt' num2str(x0)]).band5.Data(x2).tyz(:,y2,z2));
   TS22(k,:) = swapbytes(memMaps.filtMap.Session2.(['fMRIfilt' num2str(y0)]).band5.Data(x2).tyz(:,y2,z2));
end
clear Ar1 Ar2 Va1 Va2
load('D:\Tutkimus\HBM2009\Ratings')
Aro1 = Aro(1:28,:);
Aro2 = Aro(29:end-1,:);
Val1 = Val(1:28,:);
Val2 = Val(29:end-1,:);

for k = 1:size(subPairs,1)
    Ar1(k,:) = interp1( mean(Aro1(:,subPairs(k,:)),2), linspace(1,28,244));
    Ar2(k,:) = interp1( mean(Aro2(:,subPairs(k,:)),2), linspace(1,42,382));
    Va1(k,:) = interp1( mean(Val1(:,subPairs(k,:)),2), linspace(1,28,244));
    Va2(k,:) = interp1( mean(Val2(:,subPairs(k,:)),2), linspace(1,42,382));
end
clear tm1 tm2
for k = 1:size(subPairs,1)
  tm1(k,:) = mean( [TS11(k,:);TS12(k,:)] );
  tm2(k,:) = mean( [TS21(k,:);TS22(k,:)] );
end
for k = 1:size(subPairs,1)
%figure
%subplot(211);plot(3+tm1(k,:));hold on;plot(Ar1(k,:),'r')
%subplot(212);plot(3+tm2(k,:));hold on;plot(Ar2(k,:),'r')
CC2a(k) = corr(tm2(k,:)',Ar2(k,:)');
CC1a(k) = corr(tm1(k,:)',Ar1(k,:)');
CC2v(k) = corr(tm2(k,:)',Va2(k,:)');
CC1v(k) = corr(tm1(k,:)',Va1(k,:)');

end
figure,subplot(221);plot(CC1a);xlabel('ses1 Aro');grid on;xlim([1 66])
subplot(222);plot(CC2a);xlabel('ses2 Aro');grid on;xlim([1 66])
subplot(223),plot(CC1v);xlabel('ses1 Val');grid on;xlim([1 66])
subplot(224),plot(CC2v);xlabel('ses2 Val');grid on;xlim([1 66])
suptitle('Correlation coefficients, best pairwise frontal polar BOLD response vs. emotion ratings')

ts1m = mean(ts1);
ts2m = mean(ts2);
Ar1m = interp1( mean(Aro1,2), linspace(1,28,244));
Ar2m = interp1( mean(Aro2,2), linspace(1,42,382));
Va1m = interp1( mean(Val1,2), linspace(1,28,244));
Va2m = interp1( mean(Val2,2), linspace(1,42,382));
figure,plot(3+ts1m);hold on;plot(Ar1m,'r');xlabel('Aro ses 1')
figure,plot(3+ts2m);hold on;plot(Ar2m,'r');xlabel('Aro ses 2')
figure,plot(3+ts1m);hold on;plot(Va1m,'r');xlabel('Val ses 1')
figure,plot(3+ts2m);hold on;plot(Va2m,'r');xlabel('Val ses 2')
corr(ts1m',Ar1m')
corr(ts1m',Va1m')
corr(ts2m',Ar2m')
corr(ts2m',Va2m')


figure,subplot(221);plot(3+ts1m);hold on;plot(Ar1m,'r');xlabel('Aro ses 1')
subplot(222),plot(3+ts2m);hold on;plot(Ar2m,'r');xlabel('Aro ses 2')
subplot(223),plot(3+ts1m);hold on;plot(Va1m,'r');xlabel('Val ses 1')
subplot(224),plot(3+ts2m);hold on;plot(Va2m,'r');xlabel('Val ses 2')



load R
%R=interp1(R,linspace(1,length(R),244+382),'nearest');
figure,plot(3.4*(1:length(ts1m))/60,ts1m);hold on;plot(3.4*(1:length(ts1m))/60,R(1:244),'r');xlim([0 14]);title('Risky behaviors, session 1');xlabel('time (min)')
figure,plot(3.4*(1:length(ts2m))/60,ts2m);hold on;plot(3.4*(1:length(ts2m))/60,R(245:end),'r');xlim([0 22]);title('Risk behavior, session 2');xlabel('time (min)')

for k = 1:size(subPairs,1)
    figure
    subplot(211);plot(3+tm1(k,:));hold on;plot(R(1:244),'r')
    subplot(212);plot(3+tm2(k,:));hold on;plot(R(245:end),'r')
    CC2r(k) = corr(tm2(k,:)',R(245:end)');
    CC1r(k) = corr(tm1(k,:)',R(1:244)');
end
