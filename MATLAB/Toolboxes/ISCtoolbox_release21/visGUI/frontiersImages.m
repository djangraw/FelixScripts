load at
I = load_nii('MNI152_T1_2mm_brain_mask.nii');
I = double(I.img);

brainReg = 1;
clc
th = [0.15 0.2 0.25 0.3];
th = 0.15
%kk=1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Total number of synch. voxels. 

for kk = 1:length(th)

% data set 1:

% Brain region of interest:
for k = 1:24;RR = R1w_0(:,:,:,k);T1(1,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
for k = 1:24;RR = R1w_1(:,:,:,k);T1(2,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
for k = 1:24;RR = R1w_2(:,:,:,k);T1(3,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
for k = 1:24;RR = R1w_3(:,:,:,k);T1(4,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
for k = 1:24;RR = R1w_4(:,:,:,k);T1(5,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
for k = 1:24;RR = R1w_5(:,:,:,k);T1(6,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end

% Whole brain:
for k = 1:24;RR = R1w_0(:,:,:,k);Ttot1(1,k) = sum(RR(find(I))>th(kk));end
for k = 1:24;RR = R1w_1(:,:,:,k);Ttot1(2,k) = sum(RR(find(I))>th(kk));end
for k = 1:24;RR = R1w_2(:,:,:,k);Ttot1(3,k) = sum(RR(find(I))>th(kk));end
for k = 1:24;RR = R1w_3(:,:,:,k);Ttot1(4,k) = sum(RR(find(I))>th(kk));end
for k = 1:24;RR = R1w_4(:,:,:,k);Ttot1(5,k) = sum(RR(find(I))>th(kk));end
for k = 1:24;RR = R1w_5(:,:,:,k);Ttot1(6,k) = sum(RR(find(I))>th(kk));end

% Cerebral Cortex:
for k = 1:24;RR = R1w_0(:,:,:,k);Tcc1(1,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
for k = 1:24;RR = R1w_1(:,:,:,k);Tcc1(2,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
for k = 1:24;RR = R1w_2(:,:,:,k);Tcc1(3,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
for k = 1:24;RR = R1w_3(:,:,:,k);Tcc1(4,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
for k = 1:24;RR = R1w_4(:,:,:,k);Tcc1(5,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
for k = 1:24;RR = R1w_5(:,:,:,k);Tcc1(6,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end

% data set 2:

% Brain region of interest:
%for k = 1:39;RR = R2w_0(:,:,:,k);T2(1,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
% for k = 1:39;RR = R2w_1(:,:,:,k);T2(2,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
% for k = 1:39;RR = R2w_2(:,:,:,k);T2(3,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
% for k = 1:39;RR = R2w_3(:,:,:,k);T2(4,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
% for k = 1:39;RR = R2w_4(:,:,:,k);T2(5,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end
%for k = 1:39;RR = R2w_5(:,:,:,k);T2(6,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th(kk));end

% Whole brain:
%for k = 1:39;RR = R2w_0(:,:,:,k);Ttot2(1,k) = sum(RR(find(I))>th(kk));end
% for k = 1:39;RR = R2w_1(:,:,:,k);Ttot2(2,k) = sum(RR(find(I))>th(kk));end
% for k = 1:39;RR = R2w_2(:,:,:,k);Ttot2(3,k) = sum(RR(find(I))>th(kk));end
% for k = 1:39;RR = R2w_3(:,:,:,k);Ttot2(4,k) = sum(RR(find(I))>th(kk));end
% for k = 1:39;RR = R2w_4(:,:,:,k);Ttot2(5,k) = sum(RR(find(I))>th(kk));end
%for k = 1:39;RR = R2w_5(:,:,:,k);Ttot2(6,k) = sum(RR(find(I))>th(kk));end

% Cerebral cortex
%for k = 1:39;RR = R2w_0(:,:,:,k);Tcc2(1,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
% for k = 1:39;RR = R2w_1(:,:,:,k);Tcc2(2,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
% for k = 1:39;RR = R2w_2(:,:,:,k);Tcc2(3,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
% for k = 1:39;RR = R2w_3(:,:,:,k);Tcc2(4,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
% for k = 1:39;RR = R2w_4(:,:,:,k);Tcc2(5,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end
%for k = 1:39;RR = R2w_5(:,:,:,k);Tcc2(6,k) = sum(RR(find(at(:,:,:,1)))>th(kk));end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mean values:

% dataset 1:
if kk == 1
% Brain region of interest:
for k = 1:24;RR = R1w_0(:,:,:,k);T1m(1,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_1(:,:,:,k);T1m(2,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_2(:,:,:,k);T1m(3,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_3(:,:,:,k);T1m(4,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_4(:,:,:,k);T1m(5,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_5(:,:,:,k);T1m(6,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end

% Whole brain:
for k = 1:24;RR = R1w_0(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(1,k) = mean(RR);end
for k = 1:24;RR = R1w_1(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(2,k) = mean(RR);end
for k = 1:24;RR = R1w_2(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(3,k) = mean(RR);end
for k = 1:24;RR = R1w_3(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(4,k) = mean(RR);end
for k = 1:24;RR = R1w_4(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(5,k) = mean(RR);end
for k = 1:24;RR = R1w_5(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(6,k) = mean(RR);end

% Cerebral Cortex:
for k = 1:24;RR = R1w_0(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(1,k) = mean(RR);end
for k = 1:24;RR = R1w_1(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(2,k) = mean(RR);end
for k = 1:24;RR = R1w_2(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(3,k) = mean(RR);end
for k = 1:24;RR = R1w_3(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(4,k) = mean(RR);end
for k = 1:24;RR = R1w_4(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(5,k) = mean(RR);end
for k = 1:24;RR = R1w_5(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(6,k) = mean(RR);end

% Median values:

% dataset 1:
if kk == 1
% Brain region of interest:
for k = 1:24;RR = R1w_0(:,:,:,k);T1me(1,k) = median(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_1(:,:,:,k);T1me(2,k) = median(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_2(:,:,:,k);T1me(3,k) = median(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_3(:,:,:,k);T1me(4,k) = median(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_4(:,:,:,k);T1me(5,k) = median(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_5(:,:,:,k);T1me(6,k) = median(RR(find(at(:,:,:,1) == brainReg)));end

% Whole brain:
for k = 1:24;RR = R1w_0(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1me(1,k) = median(RR);end
for k = 1:24;RR = R1w_1(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1me(2,k) = median(RR);end
for k = 1:24;RR = R1w_2(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1me(3,k) = median(RR);end
for k = 1:24;RR = R1w_3(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1me(4,k) = median(RR);end
for k = 1:24;RR = R1w_4(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1me(5,k) = median(RR);end
for k = 1:24;RR = R1w_5(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1me(6,k) = median(RR);end

% Cerebral Cortex:
for k = 1:24;RR = R1w_0(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1me(1,k) = median(RR);end
for k = 1:24;RR = R1w_1(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1me(2,k) = median(RR);end
for k = 1:24;RR = R1w_2(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1me(3,k) = median(RR);end
for k = 1:24;RR = R1w_3(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1me(4,k) = median(RR);end
for k = 1:24;RR = R1w_4(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1me(5,k) = median(RR);end
for k = 1:24;RR = R1w_5(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1me(6,k) = median(RR);end




% dataset 2:

% Brain region of interest:
%for k = 1:39;RR = R2w_0(:,:,:,k);T2m(1,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
% for k = 1:39;RR = R2w_1(:,:,:,k);T2m(2,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
% for k = 1:39;RR = R2w_2(:,:,:,k);T2m(3,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
% for k = 1:39;RR = R2w_3(:,:,:,k);T2m(4,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
% for k = 1:39;RR = R2w_4(:,:,:,k);T2m(5,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
%for k = 1:39;RR = R2w_5(:,:,:,k);T2m(6,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end

% Whole brain:
%for k = 1:39;RR = R2w_0(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(1,k) = mean(RR);end
% for k = 1:39;RR = R2w_1(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(2,k) = mean(RR);end
% for k = 1:39;RR = R2w_2(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(3,k) = mean(RR);end
% for k = 1:39;RR = R2w_3(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(4,k) = mean(RR);end
% for k = 1:39;RR = R2w_4(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(5,k) = mean(RR);end
%for k = 1:39;RR = R2w_5(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(6,k) = mean(RR);end

% Cerebral Cortex:
%for k = 1:39;RR = R2w_0(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(1,k) = mean(RR);end
% for k = 1:39;RR = R2w_1(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(2,k) = mean(RR);end
% for k = 1:39;RR = R2w_2(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(3,k) = mean(RR);end
% for k = 1:39;RR = R2w_3(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(4,k) = mean(RR);end
% for k = 1:39;RR = R2w_4(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(5,k) = mean(RR);end
%for k = 1:39;RR = R2w_5(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(6,k) = mean(RR);end

end
load('D:\Tutkimus\fMRI\KatrinKoe.mat')
AR=mean(AA,2)';
Arr1 = AR(1:28); 
VR=mean(VV,2)';
Vrr1 = VR(1:28); 
clear Ar1 Vr1
for k = 1:length(Arr1)-4
    Ar1(k) = mean(Arr1(k:k+3));
    Vr1(k) = mean(Vrr1(k:k+3));
end
Vr1 = -1*Vr1;
%Vr1 = Valen1 + 5;
corr((A1(:,3)./Awhole1(:,3)),Ar1') % 0.15
corr((A1(:,4)./Awhole1(:,4)),Ar1') % 0.20
corr((A1(:,5)./Awhole1(:,5)),Ar1') % 0.25
%corr((A1(:,6)./Awhole1(:,6)),Ar1') % 0.25

corr((A1(:,3)./Awhole1(:,3)),Vr1') % 0.15
corr((A1(:,4)./Awhole1(:,4)),Vr1') % 0.20
corr((A1(:,5)./Awhole1(:,5)),Vr1') % 0.25

AR=mean(AA,2)';
Arr2 = AR(29:end); 
VR=mean(VV,2)';
Vrr2 = VR(29:end); 
clear Ar2 Vr2
for k = 1:length(Arr2)-4
    Ar2(k) = mean(Arr2(k:k+3));
    Vr2(k) = mean(Vrr2(k:k+3));
end
Vr2 = -1*Vr2;
%Vr1 = Valen1 + 5;
corr((A2(:,3)./Awhole2(:,3)),Ar2') % 0.15
corr((A2(:,4)./Awhole2(:,4)),Ar2') % 0.20
corr((A2(:,5)./Awhole2(:,5)),Ar2') % 0.25
corr((A2(:,3)./Awhole2(:,3)),Vr2') % 0.15
corr((A2(:,4)./Awhole2(:,4)),Vr2') % 0.20
corr((A2(:,5)./Awhole2(:,5)),Vr2') % 0.25


for k = 1:length(Aro16)-4
    Aro16m(k) = mean(Aro16(k:k+3));
   % Valen1(k) = mean(Val1(k:k+3));
end




for k = 1:length(Aro1)-4
    Arous1(k) = mean(Aro1(k:k+3));
    Valen1(k) = mean(Val1(k:k+3));
end
Valen1 = -1*Valen1;
Valen1 = Valen1 + 5;

figure,plot(4*((T1(6,:)./Ttot1(6,:))./max(T1(6,:)./Ttot1(6,:))),'b-*','LineWidth',1.5);
hold on;plot(Arous1,'r--.','LineWidth',1.5,'MarkerSize',15);grid on;hold on;
plot(Valen1,'g:o','LineWidth',1.5);hold off;
legend({'Synchronization','Arousal','Valence'});
ylabel('Valence / Arousal rate');xlabel('Time interval');
set(gca,'XTickLabel',[{'0:00-2:00'},{'2:30-4:30'},{'5:00-7:00'},...
    {'7:30-9:30'},{'10:00-12:00'},{'12:30-14:30'}],'YTick',[1:4],...
    'XTick',[1:5:24]);xlim([1 24])

for k = 1:length(Aro)-4
    AroMean(k) = mean(Aro(k:k+3));
    AroMax(k) = max(Aro(k:k+3));
end


Aro2=Aro(28:end);
Aro2 = Aro2(1:end-5);
%T2n = max(Arous2Max(1:end-1))*T2(6,:)./Ttot2(6,:)./max(T2(6,:)./Ttot2(6,:));
%figure,plot(14:0.5:33,Aro2,'b*-');hold on;plot(14:0.5:33,T2n,'g-x');

Aro2=Aro(28:end);
Val2=Val(28:end);

for k = 1:length(Aro2)-4
    Arous2(k) = mean(Aro2(k:k+3));
    Valen2(k) = mean(Val2(k:k+3));
    Arous2Max(k) = max(Aro2(k:k+3));
end
Valen2 = -1*Valen2+5;

figure,plot(0.5+3.355*((T2(6,:)./Ttot2(6,:))./max(T2(6,:)./Ttot2(6,:))),'b-*','LineWidth',1.5);
hold on;plot(Arous2,'r--.','LineWidth',1.5,'MarkerSize',15);grid on;hold on;
plot(Valen2,'g:o','LineWidth',1.5);hold off;
legend({'Synchronization','Arousal','Valence'});
ylabel('Valence / Arousal rate');xlabel('Time interval');
set(gca,'XTickLabel',[{'14:00-16:00'},{'19:00-21:00'},...
    {'24:00-26:00'},{'29:00-31:00'},{'34:00-36:00'}],'YTick',[1:4],'XTick',[1:10:41]);xlim([1 39])
hold on;plot(Aro(28:end-5),'k--*')




disp(['Threshold: ' num2str(th)])
disp('Dataset 1')


disp(['Sync.vs.arousal: ' num2str(corr((T1(6,:)./Ttot1(6,:))',Arous1'))])
disp(['Sync.vs.valence: ' num2str(corr((T1(6,:)./Ttot1(6,:))',Valen1'))])

disp(['cerbral cortex vs.arousal: ' num2str(corr((Tcc1(6,:)./Ttot1(6,:))',Arous1'))])
disp(['cerbral cortex vs.valence: ' num2str(corr((Tcc1(6,:)./Ttot1(6,:))',Valen1'))])

disp(['whole brain vs.arousal: ' num2str(corr(Ttot1(6,:)',Arous1'))])
disp(['whole brain vs.valence: ' num2str(corr(Ttot1(6,:)',Valen1'))])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Dataset 2')
disp(['Sync.vs.arousal: ' num2str(corr((T2(6,:)./Ttot2(6,:))',Arous2'))])
disp(['Sync.vs.valence: ' num2str(corr((T2(6,:)./Ttot2(6,:))',Valen2'))])

disp(['cerbral cortex vs.arousal: ' num2str(corr((Tcc2(6,:)./Ttot2(6,:))',Arous2'))])
disp(['cerbral cortex vs.valence: ' num2str(corr((Tcc2(6,:)./Ttot2(6,:))',Valen2'))])

disp(['whole brain vs.arousal: ' num2str(corr(Ttot2(6,:)',Arous2'))])
disp(['whole brain vs.valence: ' num2str(corr(Ttot2(6,:)',Valen2'))])
if kk == 1
R1_aro(kk,1) = corr((T1m(6,:)./Ttot1m(6,:))',Arous1');
R1_val(kk,1) = corr((T1m(6,:)./Ttot1m(6,:))',Valen1');
R1_aro(kk,3) = corr(Ttot1m(6,:)',Arous1');
R1_val(kk,3) = corr(Ttot1m(6,:)',Valen1');
R1_aro(kk,2) = corr((Tcc1m(6,:)./Ttot1m(6,:))',Arous1');
R1_val(kk,2) = corr((Tcc1m(6,:)./Ttot1m(6,:))',Valen1');
R2_aro(kk,1) = corr((T2m(6,:)./Ttot2m(6,:))',Arous2');
R2_val(kk,1) = corr((T2m(6,:)./Ttot2m(6,:))',Valen2');
R2_aro(kk,3) = corr(Ttot2m(6,:)',Arous2');
R2_val(kk,3) = corr(Ttot2m(6,:)',Valen2');
R2_aro(kk,2) = corr((Tcc2m(6,:)./Ttot2m(6,:))',Arous2');
R2_val(kk,2) = corr((Tcc2m(6,:)./Ttot2m(6,:))',Valen2');
end


R1_aro(kk+1,1) = corr((T1(6,:)./Ttot1(6,:))',Arous1');
R1_val(kk+1,1) = corr((T1(6,:)./Ttot1(6,:))',Valen1');
R1_aro(kk+1,3) = corr(Ttot1(6,:)',Arous1');
R1_val(kk+1,3) = corr(Ttot1(6,:)',Valen1');
R1_aro(kk+1,2) = corr((Tcc1(6,:)./Ttot1(6,:))',Arous1');
R1_val(kk+1,2) = corr((Tcc1(6,:)./Ttot1(6,:))',Valen1');

R2_aro(kk+1,1) = corr((T2(6,:)./Ttot2(6,:))',Arous2');
R2_val(kk+1,1) = corr((T2(6,:)./Ttot2(6,:))',Valen2');
R2_aro(kk+1,3) = corr(Ttot2(6,:)',Arous2');
R2_val(kk+1,3) = corr(Ttot2(6,:)',Valen2');
R2_aro(kk+1,2) = corr((Tcc2(6,:)./Ttot2(6,:))',Arous2');
R2_val(kk+1,2) = corr((Tcc2(6,:)./Ttot2(6,:))',Valen2');


end

p1 = polyfit(1:24,Arous1,1);
f1 = (p1(2)+p1(1)*(1:24));%+0.1*randn(1,24);
f1x = std(Arous1)*randn(1,24);

figure,plot(f1,'m--');hold on;plot(1:24,Arous1,'r-x');hold off
corr(f1',Arous1')
corr(f1x',Arous1')

p2 = polyfit(1:39,Arous2,1);
f2 = (p2(2)+p2(1)*(1:39));%+0.1*randn(1,39);
f2x = std(Arous2)*randn(1,39);
figure,plot(f2,'m--');hold on;plot(1:39,Arous2,'r-x');hold off
corr(f2',Arous2')
corr(f2x',Arous2')




p1 = polyfit(1:24,Valen1,1);
f1 = (p1(2)+p1(1)*(1:24));%+0.1*randn(1,24);
f1x = 0.1*randn(1,24);

figure,plot(f1,'m--');hold on;plot(1:24,Valen1,'r-x');hold off
corr(f1',Valen1')
corr(f2x',Valen2')

p2 = polyfit(1:39,Valen2,1);
f2 = (p2(2)+p2(1)*(1:39));%+0.1*randn(1,39);
f2x = 0.1*randn(1,39);
figure,plot(f2,'m--');hold on;plot(1:39,Valen2,'r-x');hold off
corr(f2',Valen2')
corr(f2x',Valen2')



% figure;subplot(121);plot(4*((T1(6,:)./Ttot1(6,:))./max(T1(6,:)./Ttot1(6,:))),'b-*','LineWidth',1.5);
% hold on;plot(Arous1,'r--.','LineWidth',1.5,'MarkerSize',15);grid on;hold on;
% plot(Valen1,'g:o','LineWidth',1.5);hold off;
% legend({'Synchronization','Arousal','Valence'});
% ylabel('Valence / Arousal rate');xlabel('Time interval');
% set(gca,'XTickLabel',[{'0:00-2:00'},{'2:30-4:30'},{'5:00-7:00'},...
%     {'7:30-9:30'},{'10:00-12:00'},{'12:30-14:30'}],'YTick',[1:4],...
%     'XTick',[1:5:24]);xlim([1 24])
% 
% subplot(122);plot(3.355*((T2(6,:)./Ttot2(6,:))./max(T2(6,:)./Ttot2(6,:))),'b-*','LineWidth',1.5);
% hold on;plot(Arous2,'r--.','LineWidth',1.5,'MarkerSize',15);grid on;hold on;
% plot(Valen2+5,'g:o','LineWidth',1.5);hold off;
% legend({'Synchronization','Arousal','Valence'});
% ylabel('Valence / Arousal rate');xlabel('Time interval');
% set(gca,'XTickLabel',[{'14:00-16:00'},{'19:00-21:00'},...
%     {'24:00-26:00'},{'29:00-31:00'},{'34:00-36:00'}],'YTick',[1:4],'XTick',[1:10:41]);xlim([1 39])

clear voxVals1 voxVals2
indsFP = find(at(:,:,:,1) == brainReg);
peaks1 = [4,16];
peaks1 = 1:24;
for k = 1:length(peaks1)
    RR = R1w_5(:,:,:,peaks1(k));
    voxVals1(:,k) = RR(indsFP);
end

voxVals = voxVals1;

peaks2 = [ 7, 13,20, 29, 37 ];
peaksAll = [peaks1 peaks2];
for k = 1:length(peaks2)
    RR = R2w_5(:,:,:,peaks2(k));
    voxVals2(:,k) = RR(indsFP);
end
   
voxVals = [voxVals1 voxVals2];
corrcoef(voxVals)
figure,iter=1;
for k=1:7
    for m=1:7
        if m>k
            subplot(7,3,iter);
            plot(voxVals(:,k),'b');hold on;
            plot(voxVals(:,m),'r:');hold off;
            set(gca,'XTick',[]);ylim([0 0.8]);
            round(10*corr(voxVals(:,k), voxVals(:,m)))/10
            xlabel(['Peaks ' num2str(k) ' and ' num2str(m) ... 
                ', corr: ' num2str(round(10*corr(voxVals(:,k), voxVals(:,m)))/10)]);
            iter=iter+1;
        end
    end
end

figure,plot(voxVals(:,4),'Color',[0 1 0],'LineStyle','-','LineWidth',1.5);hold on;plot(voxVals(:,5),'Color',[1 0 0],'LineStyle','--');
plot(1:size(voxVals,1),th*ones(1,size(voxVals,1)),'k--','LineWidth',1.5);hold off;
grid on;xlabel('voxel index');xlim([1 9920])


voxVals = [voxVals1 voxVals2];
corrcoef(voxVals)
iter=1;
for k=1:7
    for m=1:7
        if m>k
            V1 = find(voxVals(:,k) >= th & voxVals(:,m) < th);
            V2 = find(voxVals(:,k) < th & voxVals(:,m) >= th);
            Vtot(k,m) = (length(V1)+length(V2))/length(voxVals(:,k));
            iter=iter+1;
        end
    end
end


















% figure,plot(voxVals(:,4),'r');hold on;plot(voxVals(:,5),'r:');
% plot(1:size(voxVals,1),0.2*ones(1,size(voxVals,1)),'k--');hold off;
% xlim([0 9920]);grid on;xlabel('voxel index');ylabel([]);
figure,plot(voxVals(:,3))
figure,plot(voxVals(:,4))


inds1 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,7)>=0.2 & R2w_5(:,:,:,29)<0.2);
inds2 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,29)>=0.2 & R2w_5(:,:,:,7)<0.2);
inds3 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,29)>=0.2 & R2w_5(:,:,:,7)>=0.2);

inds1 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,13)>=th & R2w_5(:,:,:,20)<th);
inds2 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,20)>=th & R2w_5(:,:,:,13)<th);
inds3 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,20)>=th & R2w_5(:,:,:,13)>=th);


inds1 = find( at(:,:,:,1) == brainReg & R1w_5(:,:,:,peaksAll(1))>=th & R2w_5(:,:,:,peaksAll(5))<th);
inds2 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(5))>=th & R1w_5(:,:,:,peaksAll(1))<th);
inds3 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(5))>=th & R1w_5(:,:,:,peaksAll(1))>=th);

inds1 = find( at(:,:,:,1) == brainReg & R1w_5(:,:,:,peaksAll(2))>=th & R2w_5(:,:,:,peaksAll(3))<th);
inds2 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(3))>=th & R1w_5(:,:,:,peaksAll(2))<th);
inds3 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(3))>=th & R1w_5(:,:,:,peaksAll(2))>=th);


inds1 = find( at(:,:,:,1) == brainReg & R1w_5(:,:,:,peaksAll(1))>=th & R1w_5(:,:,:,peaksAll(2))<th);
inds2 = find( at(:,:,:,1) == brainReg & R1w_5(:,:,:,peaksAll(2))>=th & R1w_5(:,:,:,peaksAll(1))<th);
inds3 = find( at(:,:,:,1) == brainReg & R1w_5(:,:,:,peaksAll(2))>=th & R1w_5(:,:,:,peaksAll(1))>=th);

inds1 = find( at(:,:,:,1) == brainReg & R1w_5(:,:,:,peaksAll(1))>=th & R2w_5(:,:,:,peaksAll(3))<th);
inds2 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(3))>=th & R1w_5(:,:,:,peaksAll(1))<th);
inds3 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(3))>=th & R1w_5(:,:,:,peaksAll(1))>=th);


inds1 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(4))>=th & R2w_5(:,:,:,peaksAll(6))<th);
inds2 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(6))>=th & R2w_5(:,:,:,peaksAll(4))<th);
inds3 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(6))>=th & R2w_5(:,:,:,peaksAll(4))>=th);



inds1 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(4))>=th & R2w_5(:,:,:,peaksAll(7))<th);
inds2 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(7))>=th & R2w_5(:,:,:,peaksAll(4))<th);
inds3 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(7))>=th & R2w_5(:,:,:,peaksAll(4))>=th);

inds1 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(3))>=th & R2w_5(:,:,:,peaksAll(7))<th);
inds2 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(7))>=th & R2w_5(:,:,:,peaksAll(3))<th);
inds3 = find( at(:,:,:,1) == brainReg & R2w_5(:,:,:,peaksAll(7))>=th & R2w_5(:,:,:,peaksAll(3))>=th);

clear RRR
%RRR(:,:,:,1) = R1(:,:,:,1);
%RRR(:,:,:,2) = R1(:,:,:,16);
RRR(:,:,:,1) = R2(:,:,:,7);
RRR(:,:,:,2) = R2(:,:,:,13);
RRR(:,:,:,3) = R2(:,:,:,20);
RRR(:,:,:,4) = R2(:,:,:,29);
RRR(:,:,:,5) = R2(:,:,:,37);
for k = 1:5
    for m = 1:5
        if m > k
            inds1 = find( at(:,:,:,1) == 1 & RRR(:,:,:,k)>=th);
            inds2 = find( at(:,:,:,1) == 1 & RRR(:,:,:,m)>=th);
            inds3 = find( at(:,:,:,1) == 1 & RRR(:,:,:,k)>=th & RRR(:,:,:,m)>=th);
            if k == 2 && m == 3
               f=0 
            end
            disp([num2str(k) ',' num2str(m) ': ' num2str(length(inds3)/min(length(inds2),length(inds1)))])
        end
    end
end
clear SSS
SSS(:,:,:,1) = R2(:,:,:,7);
SSS(:,:,:,2) = R2(:,:,:,21);
SSS(:,:,:,3) = R2(:,:,:,33);
for k = 1:3
    for m = 1:3
        if m > k
            inds1 = find( at(:,:,:,1) == 12 & RRR(:,:,:,k)>=th);
            inds2 = find( at(:,:,:,1) == 12 & RRR(:,:,:,m)>=th);
            inds3 = find( at(:,:,:,1) == 12 & RRR(:,:,:,k)>=th & RRR(:,:,:,m)>=th);
            disp([num2str(k) ',' num2str(m) ': ' num2str(length(inds3)/min(length(inds2),length(inds1)))])
        end
    end
end




CUT=15:76;
RR = R2(CUT,:,CUT,:);
att = at(CUT,:,CUT,:);

PP=[13 20];th=0.13;
inds1 = find( att(:,:,:,1) == 1 & RR(:,:,:,PP(1))>=th & RR(:,:,:,PP(2))<th);
inds2 = find( att(:,:,:,1) == 1 & RR(:,:,:,PP(2))>=th & RR(:,:,:,PP(1))<th);
inds3 = find( att(:,:,:,1) == 1 & RR(:,:,:,PP(1))>=th & RR(:,:,:,PP(2))>=th);


Is = zeros(size(att,1),size(att,2),size(att,3));
Is(att(:,:,:,1)==1) = 1;
Is(inds1) = 2;
Is(inds2) = 3;
Is(inds3) = 4;
%Is = Is;
colmap = [0 0 0;0.4 0.5 0.5 ;0 1 0;1 0 0;0 0 1];
iter = 1;
clear Ico;clear Iax;clear Isa;clear ks;clear kc;clear ka

% load anatomy, scale and quantize values:
I = load_nii('MNI152_T1_2mm_brain.nii');
W = single(I.img);
W = W(CUT,:,CUT);

W = W-min(min(min(nonzeros(W))));
W = W./max(max(max(W)));
W = round(63*W);
W(W < 0) = 0;
W(W > 64) = 64;
% shift values such that they mach gray-scale part of the colormap:
W = W - 9;
W(W < 0) = 0;

GG=colormap(gray(50))
colmap = [colmap ;GG]
W = W; % 67, ..., 131
unique(W)
idx = find(Is>=1);
W(idx) = Is(idx);
W = W + 1;
figure,set(gcf,'ColorMap',colmap)
imagesc(rot90(W(:,:,40)));axis equal;axis off;
% Iax = permute(Iax,[1 2 4 3]);
% Ico = permute(Ico,[1 2 4 3]);
% Isa = permute(Isa,[1 2 4 3]);
Is = W;

clear Iax Ico Isa
for k = 1:1:size(RR,1)
    if ~isempty(find(att(:,:,k,1)==1))
        Iax(:,:,1,iter) = rot90(Is(:,:,k));
         ka(iter) = k;
        iter = iter + 1;
       
    end
end
iter = 1;
for k = 1:109
    if ~isempty(find(squeeze(att(:,k,:,1))==1))
        Ico(:,:,1,iter) = rot90(squeeze(Is(:,k,:)));
         kc(iter) = k;
        iter = iter + 1;
       
    end
end
iter = 1;
for k = 1:size(RR,3)
    if ~isempty(find(squeeze(att(k,:,:,1))==1))
        Isa(:,:,1,iter) = rot90(squeeze(Is(k,:,:)));
%        size(rot90(squeeze(Is(k,:,:))))
        ks(iter) = k;
        iter = iter + 1;
       
    end
end


figure,montage(Iax,colmap)
figure,montage(Ico,colmap)
figure,montage(Isa,colmap)



figure;
set(gcf,'ColorMap',colmap);colorbar;
imagesc(rot90(Is(:,:,50)));axis equal;axis off

figure
for k = 1:length(ks)
    imagesc(rot90(at(:,:,ks(k),1)==1));
    xlabel(num2str(ks(k)));axis equal;axis off;pause(0.2);
end

figure
for k = 80:101
    imagesc(rot90(squeeze(Is(:,k,:)==1)));
    xlabel(num2str(k));axis equal;axis off;pause(0.2);
end

% 
% 
% 









% 
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temporal Occipital Fusiform Cortex:


brainReg = 39;
th = 0.2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Total number of synch. voxels. 

% data set 1:

% Brain region of interest:
for k = 1:24;RR = R1w_0(:,:,:,k);T1(1,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
for k = 1:24;RR = R1w_1(:,:,:,k);T1(2,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
for k = 1:24;RR = R1w_2(:,:,:,k);T1(3,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
for k = 1:24;RR = R1w_3(:,:,:,k);T1(4,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
%for k = 1:24;RR = R1w_4(:,:,:,k);T1(5,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
%for k = 1:24;RR = R1w_5(:,:,:,k);T1(6,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end

% Whole brain:
for k = 1:24;RR = R1w_0(:,:,:,k);Ttot1(1,k) = sum(RR(find(I))>th);end
for k = 1:24;RR = R1w_1(:,:,:,k);Ttot1(2,k) = sum(RR(find(I))>th);end
for k = 1:24;RR = R1w_2(:,:,:,k);Ttot1(3,k) = sum(RR(find(I))>th);end
for k = 1:24;RR = R1w_3(:,:,:,k);Ttot1(4,k) = sum(RR(find(I))>th);end
%for k = 1:24;RR = R1w_4(:,:,:,k);Ttot1(5,k) = sum(RR(find(I))>th);end
%for k = 1:24;RR = R1w_5(:,:,:,k);Ttot1(6,k) = sum(RR(find(I))>th);end

% Cerebral Cortex:
for k = 1:24;RR = R1w_0(:,:,:,k);Tcc1(1,k) = sum(RR(find(at(:,:,:,1)))>th);end
for k = 1:24;RR = R1w_1(:,:,:,k);Tcc1(2,k) = sum(RR(find(at(:,:,:,1)))>th);end
for k = 1:24;RR = R1w_2(:,:,:,k);Tcc1(3,k) = sum(RR(find(at(:,:,:,1)))>th);end
for k = 1:24;RR = R1w_3(:,:,:,k);Tcc1(4,k) = sum(RR(find(at(:,:,:,1)))>th);end
%for k = 1:24;RR = R1w_4(:,:,:,k);Tcc1(5,k) = sum(RR(find(at(:,:,:,1)))>th);end
%for k = 1:24;RR = R1w_5(:,:,:,k);Tcc1(6,k) = sum(RR(find(at(:,:,:,1)))>th);end

% data set 2:

% Brain region of interest:
for k = 1:39;RR = R2w_0(:,:,:,k);T2(1,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
for k = 1:39;RR = R2w_1(:,:,:,k);T2(2,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
for k = 1:39;RR = R2w_2(:,:,:,k);T2(3,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
for k = 1:39;RR = R2w_3(:,:,:,k);T2(4,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
%for k = 1:39;RR = R2w_4(:,:,:,k);T2(5,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end
%for k = 1:39;RR = R2w_5(:,:,:,k);T2(6,k) = sum(RR(find(at(:,:,:,1) == brainReg))>th);end

% Whole brain:
for k = 1:39;RR = R2w_0(:,:,:,k);Ttot2(1,k) = sum(RR(find(I))>th);end
for k = 1:39;RR = R2w_1(:,:,:,k);Ttot2(2,k) = sum(RR(find(I))>th);end
for k = 1:39;RR = R2w_2(:,:,:,k);Ttot2(3,k) = sum(RR(find(I))>th);end
for k = 1:39;RR = R2w_3(:,:,:,k);Ttot2(4,k) = sum(RR(find(I))>th);end
%for k = 1:39;RR = R2w_4(:,:,:,k);Ttot2(5,k) = sum(RR(find(I))>th);end
%for k = 1:39;RR = R2w_5(:,:,:,k);Ttot2(6,k) = sum(RR(find(I))>th);end

% Cerebral cortex
for k = 1:39;RR = R2w_0(:,:,:,k);Tcc2(1,k) = sum(RR(find(at(:,:,:,1)))>th);end
for k = 1:39;RR = R2w_1(:,:,:,k);Tcc2(2,k) = sum(RR(find(at(:,:,:,1)))>th);end
for k = 1:39;RR = R2w_2(:,:,:,k);Tcc2(3,k) = sum(RR(find(at(:,:,:,1)))>th);end
for k = 1:39;RR = R2w_3(:,:,:,k);Tcc2(4,k) = sum(RR(find(at(:,:,:,1)))>th);end
%for k = 1:39;RR = R2w_4(:,:,:,k);Tcc2(5,k) = sum(RR(find(at(:,:,:,1)))>th);end
%for k = 1:39;RR = R2w_5(:,:,:,k);Tcc2(6,k) = sum(RR(find(at(:,:,:,1)))>th);end


for k = 1:4
    T1n(k,:) = ((T1(k,:)./Ttot1(k,:)))/max((T1(k,:)./Ttot1(k,:)));
end
for k = 1:4
    T2n(k,:) = ((T2(k,:)./Ttot2(k,:)))/max((T2(k,:)./Ttot2(k,:)));
end

load faceINDEX;
FI_2 = FI_2(4:42);
%FI_2 = -1*FI_2;
%FI_1 = -1*FI_1;

corr(T1(1,:)',FI_1')
corr(T1(2,:)',FI_1')
corr(T1(3,:)',FI_1')
corr(T1(4,:)',FI_1')
%corr(T1(5,:)',FI_1')
%corr(T1(6,:)',FI_1')

corr(T2(1,:)',FI_2(1:39)')
corr(T2(2,:)',FI_2(1:39)')
corr(T2(3,:)',FI_2(1:39)')
corr(T2(4,:)',FI_2(1:39)')
%corr(T2(5,:)',FI_2(1:39)')
%corr(T2(6,:)',FI_2(1:39)')

corr((T1(1,:)./Ttot1(1,:))',FI_1')
corr((T1(2,:)./Ttot1(1,:))',FI_1')
corr((T1(3,:)./Ttot1(1,:))',FI_1')
corr((T1(4,:)./Ttot1(1,:))',FI_1')
%corr((T1(5,:)./Ttot1(1,:))',FI_1')
%corr((T1(6,:)./Ttot1(1,:))',FI_1')

corr((T2(1,:)./Ttot2(1,:))',FI_2(1:39)')
corr((T2(2,:)./Ttot2(2,:))',FI_2(1:39)')
corr((T2(3,:)./Ttot2(3,:))',FI_2(1:39)')
corr((T2(4,:)./Ttot2(4,:))',FI_2(1:39)')
%corr((T2(5,:)./Ttot2(5,:))',FI_2(1:39)')
%corr((T2(6,:)./Ttot2(6,:))',FI_2(1:39)')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot threshold based synchronization:

figure,
h1(1)=subplot(3,2,1);plot(T1n(1,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.15 Hz');title(['Correlation: ' num2str(corr(T1n(1,:)',FI_1'))]);grid on;legend([{'Synchronization in Temporal Occipital Fusiform Gyrus','Inverted face prevalence'}])
h1(2)=subplot(3,2,2);plot(T1n(2,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0.07 - 0.15 Hz');title(['Correlation: ' num2str(corr(T1n(2,:)',FI_1'))]);grid on
h1(3)=subplot(3,2,3);plot(T1n(3,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0.04 - 0.07 Hz');title(['Correlation: ' num2str(corr(T1n(3,:)',FI_1'))]);grid on
h1(4)=subplot(3,2,4);plot(T1n(4,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0.02 - 0.04 Hz');title(['Correlation: ' num2str(corr(T1n(4,:)',FI_1'))]);grid on
%h1(5)=subplot(3,2,5);plot(T1n(5,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0.01 - 0.02 Hz');title(['Correlation: ' num2str(corr(T1n(5,:)',FI_1'))]);grid on
%h1(6)=subplot(3,2,6);plot(T1n(6,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.01 Hz');title(['Correlation: ' num2str(corr(T1n(6,:)',FI_1'))]);grid on
for k = 1:4
    set(h1(k),'XTickLabel',[{'0:00-2:00'},{'5:00-7:00'},...
    {'10:00-12:00'}],'YTick',[1:3],'XTick',[1:10:23])
    axes(h1(k));xlim([1 24]);xlabel('Time interval')
end
set(gcf,'Name','Temporal Occipital Fusiform Gyrus, Session 1')

figure,
h2(1)=subplot(3,2,1);plot(T2n(1,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.15 Hz');title(['Correlation: ' num2str(corr(T2n(1,:)',FI_2'))]);grid on;legend([{'Synchronization in Temporal Occipital Fusiform Gyrus','Inverted face prevalence'}])
h2(2)=subplot(3,2,2);plot(T2n(2,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0.07 - 0.15 Hz');title(['Correlation: ' num2str(corr(T2n(2,:)',FI_2'))]);grid on
h2(3)=subplot(3,2,3);plot(T2n(3,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0.04 - 0.07 Hz');title(['Correlation: ' num2str(corr(T2n(3,:)',FI_2'))]);grid on
h2(4)=subplot(3,2,4);plot(T2n(4,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0.02 - 0.04 Hz');title(['Correlation: ' num2str(corr(T2n(4,:)',FI_2'))]);grid on
%h2(5)=subplot(3,2,5);plot(T2n(5,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0.01 - 0.02 Hz');title(['Correlation: ' num2str(corr(T2n(5,:)',FI_2'))]);grid on
%h2(6)=subplot(3,2,6);plot(T2n(6,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.01 Hz');title(['Correlation: ' num2str(corr(T2n(6,:)',FI_2'))]);grid on
for k = 1:4
    set(h2(k),'XTickLabel',[{'0:00-2:00'},{'5:00-7:00'},...
    {'10:00-12:00'},{'15:00-17:00'},{'20:00-22:00'}],'YTick',[1:4],'XTick',[1:10:41]);xlim([1 39])
    axes(h2(k));xlim([1 39]);xlabel('Time interval')
end
set(gcf,'Name','Temporal Occipital Fusiform Gyrus, Session 2')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot threshold based synchronization:

figure,
h1(1)=subplot(1,2,1);plot(T1n(1,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.15 Hz');title(['Correlation: ' num2str(corr(T1n(1,:)',FI_1'))]);grid on;legend([{'Synchronization in Temporal Occipital Fusiform Gyrus','Inverted face prevalence'}])
h1(2)=subplot(1,2,2);plot(T1n(4,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0.02 - 0.04 Hz');title(['Correlation: ' num2str(corr(T1n(4,:)',FI_1'))]);grid on
for k = 1:2
    set(h1(k),'XTickLabel',[{'0:00-2:00'},{'5:00-7:00'},...
    {'10:00-12:00'}],'YTick',[1:3],'XTick',[1:10:23])
    axes(h1(k));xlim([1 24]);xlabel('Time interval')
end
set(gcf,'Name','Temporal Occipital Fusiform Gyrus, Session 1')

figure,
h2(1)=subplot(1,2,1);plot(T2n(1,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.15 Hz');title(['Correlation: ' num2str(corr(T2n(1,:)',FI_2'))]);grid on;
legend([{'Synchronization in Temporal Occipital Fusiform Gyrus','Inverted face prevalence'}])
h2(2)=subplot(1,2,2);plot(T2n(3,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0.04 - 0.07 Hz');title(['Correlation: ' num2str(corr(T2n(3,:)',FI_2'))]);grid on
for k = 1:2
set(h2(k),'XTickLabel',[{'14:00-16:00'},{'19:00-21:00'},...
    {'24:00-26:00'},{'29:00-31:00'},{'34:00-36:00'}],'YTick',[1:4],'XTick',[1:10:41]);xlim([1 39])
    axes(h2(k));xlim([1 39]);xlabel('Time interval')
end
set(gcf,'Name','Temporal Occipital Fusiform Gyrus, Session 2')



figure,plot(0.5+3.355*((T2(6,:)./Ttot2(6,:))./max(T2(6,:)./Ttot2(6,:))),'b-*','LineWidth',1.5);
hold on;plot(Arous2,'r--.','LineWidth',1.5,'MarkerSize',15);grid on;hold on;
plot(Valen2,'g:o','LineWidth',1.5);hold off;
legend({'Synchronization','Arousal','Valence'});
ylabel('Valence / Arousal rate');xlabel('Time interval');
set(gca,'XTickLabel',[{'14:00-16:00'},{'19:00-21:00'},...
    {'24:00-26:00'},{'29:00-31:00'},{'34:00-36:00'}],'YTick',[1:4],'XTick',[1:10:41]);xlim([1 39])
hold on;plot(Aro(28:end-5),'k--*')













T1mm = T1m./repmat(max(T1m')',1,size(T1m,2));

















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MEAN


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mean values:

% dataset 1:

% Brain region of interest:
for k = 1:24;RR = R1w_0(:,:,:,k);T1m(1,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_1(:,:,:,k);T1m(2,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_2(:,:,:,k);T1m(3,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_3(:,:,:,k);T1m(4,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_4(:,:,:,k);T1m(5,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:24;RR = R1w_5(:,:,:,k);T1m(6,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end

% Whole brain:
for k = 1:24;RR = R1w_0(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(1,k) = mean(RR);end
for k = 1:24;RR = R1w_1(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(2,k) = mean(RR);end
for k = 1:24;RR = R1w_2(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(3,k) = mean(RR);end
for k = 1:24;RR = R1w_3(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(4,k) = mean(RR);end
for k = 1:24;RR = R1w_4(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(5,k) = mean(RR);end
for k = 1:24;RR = R1w_5(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot1m(6,k) = mean(RR);end

% Cerebral Cortex:
for k = 1:24;RR = R1w_0(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(1,k) = mean(RR);end
for k = 1:24;RR = R1w_1(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(2,k) = mean(RR);end
for k = 1:24;RR = R1w_2(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(3,k) = mean(RR);end
for k = 1:24;RR = R1w_3(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(4,k) = mean(RR);end
for k = 1:24;RR = R1w_4(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(5,k) = mean(RR);end
for k = 1:24;RR = R1w_5(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc1m(6,k) = mean(RR);end

% dataset 2:

% Brain region of interest:
for k = 1:39;RR = R2w_0(:,:,:,k);T2m(1,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:39;RR = R2w_1(:,:,:,k);T2m(2,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:39;RR = R2w_2(:,:,:,k);T2m(3,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:39;RR = R2w_3(:,:,:,k);T2m(4,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:39;RR = R2w_4(:,:,:,k);T2m(5,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end
for k = 1:39;RR = R2w_5(:,:,:,k);T2m(6,k) = mean(RR(find(at(:,:,:,1) == brainReg)));end

% Whole brain:
for k = 1:39;RR = R2w_0(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(1,k) = mean(RR);end
for k = 1:39;RR = R2w_1(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(2,k) = mean(RR);end
for k = 1:39;RR = R2w_2(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(3,k) = mean(RR);end
for k = 1:39;RR = R2w_3(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(4,k) = mean(RR);end
for k = 1:39;RR = R2w_4(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(5,k) = mean(RR);end
for k = 1:39;RR = R2w_5(:,:,:,k); RR = RR(find(I)); RR = RR(~isnan(RR));Ttot2m(6,k) = mean(RR);end

% Cerebral Cortex:
for k = 1:39;RR = R2w_0(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(1,k) = mean(RR);end
for k = 1:39;RR = R2w_1(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(2,k) = mean(RR);end
for k = 1:39;RR = R2w_2(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(3,k) = mean(RR);end
for k = 1:39;RR = R2w_3(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(4,k) = mean(RR);end
for k = 1:39;RR = R2w_4(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(5,k) = mean(RR);end
for k = 1:39;RR = R2w_5(:,:,:,k); RR = RR(find(at(:,:,:,1))); RR = RR(~isnan(RR));Tcc2m(6,k) = mean(RR);end






% plot mean synchronization:
figure,
h1(1)=subplot(3,2,1);plot(T1mm(1,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.15 Hz');title(['Correlation: ' num2str(corr(T1mm(1,:)',FI_1'))]);grid on;legend([{'Mean Synchronization in Temporal Occipital Fusiform Gyrus','Inverted face prevalence'}])
h1(2)=subplot(3,2,2);plot(T1mm(2,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0.07 - 0.15 Hz');title(['Correlation: ' num2str(corr(T1mm(2,:)',FI_1'))]);grid on
h1(3)=subplot(3,2,3);plot(T1mm(3,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0.04 - 0.07 Hz');title(['Correlation: ' num2str(corr(T1mm(3,:)',FI_1'))]);grid on
h1(4)=subplot(3,2,4);plot(T1mm(4,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0.02 - 0.04 Hz');title(['Correlation: ' num2str(corr(T1mm(4,:)',FI_1'))]);grid on
h1(5)=subplot(3,2,5);plot(T1mm(5,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0.01 - 0.02 Hz');title(['Correlation: ' num2str(corr(T1mm(5,:)',FI_1'))]);grid on
h1(6)=subplot(3,2,6);plot(T1mm(6,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_1','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.01 Hz');title(['Correlation: ' num2str(corr(T1mm(6,:)',FI_1'))]);grid on
for k = 1:6
    set(h1(k),'XTickLabel',[{'0:00-2:00'},{'5:00-7:00'},...
    {'10:00-12:00'}],'YTick',[1:3],'XTick',[1:10:23])
    axes(h1(k));xlim([1 24]);xlabel('Time interval')
end
set(gcf,'Name','Temporal Occipital Fusiform Gyrus, Session 1')

T2mm = T2m./repmat(max(T2m')',1,size(T2m,2));

figure,
h2(1)=subplot(3,2,1);plot(T2mm(1,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.15 Hz');title(['Correlation: ' num2str(corr(T2mm(1,:)',FI_2'))]);grid on;
legend([{'Mean Synchronization in Temporal Occipital Fusiform Gyrus','Inverted face prevalence'}])
h2(2)=subplot(3,2,2);plot(T2mm(2,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0.07 - 0.15 Hz');title(['Correlation: ' num2str(corr(T2mm(2,:)',FI_2'))]);grid on
h2(3)=subplot(3,2,3);plot(T2mm(3,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0.04 - 0.07 Hz');title(['Correlation: ' num2str(corr(T2mm(3,:)',FI_2'))]);grid on
h2(4)=subplot(3,2,4);plot(T2mm(4,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0.02 - 0.04 Hz');title(['Correlation: ' num2str(corr(T2mm(4,:)',FI_2'))]);grid on
h2(5)=subplot(3,2,5);plot(T2mm(5,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0.01 - 0.02 Hz');title(['Correlation: ' num2str(corr(T2mm(5,:)',FI_2'))]);grid on
h2(6)=subplot(3,2,6);plot(T2mm(6,:),'.b-','LineWidth',1.5,'MarkerSize',15);hold on;plot(FI_2','--rx','LineWidth',1.5);hold off;ylabel('0 - 0.01 Hz');title(['Correlation: ' num2str(corr(T2mm(6,:)',FI_2'))]);grid on
for k = 1:6
set(h2(k),'XTickLabel',[{'14:00-16:00'},{'19:00-21:00'},...
    {'24:00-26:00'},{'29:00-31:00'},{'34:00-36:00'}],'YTick',[1:4],'XTick',[1:10:41]);xlim([1 39])
    axes(h2(k));xlim([1 39]);xlabel('Time interval')
end
set(gcf,'Name','Temporal Occipital Fusiform Gyrus, Session 2')




figure,plot(0.5+3.355*((T2(6,:)./Ttot2(6,:))./max(T2(6,:)./Ttot2(6,:))),'b-*','LineWidth',1.5);
hold on;plot(Arous2,'r--.','LineWidth',1.5,'MarkerSize',15);grid on;hold on;
plot(Valen2,'g:o','LineWidth',1.5);hold off;
legend({'Synchronization','Arousal','Valence'});
ylabel('Valence / Arousal rate');xlabel('Time interval');
set(gca,'XTickLabel',[{'14:00-16:00'},{'19:00-21:00'},...
    {'24:00-26:00'},{'29:00-31:00'},{'34:00-36:00'}],'YTick',[1:4],'XTick',[1:10:41]);xlim([1 39])
hold on;plot(Aro(28:end-5),'k--*')

for k = 1:length(Aro)-4
    Ar1(k) = mean(Aro(k:k+3));
    Vr1(k) = mean(Val(k:k+3));
end



