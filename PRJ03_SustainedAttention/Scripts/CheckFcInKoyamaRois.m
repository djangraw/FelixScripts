% CheckFcInKoyamaRois.m
% (Koyama, J Neurosci 2011)
%
% Created 4/3/17 by DJ.

load('ReadingAndGradcptNetworks_optimal.mat')
load('ReadingCpCr_19subj_Fisher_2017-02-22.mat')

% Correlate FC matrix with behavior
FC_vec = VectorizeFc(FC_fisher);
[read_cr_all,read_cp_all] = corr(FC_vec',fracCorrect);
read_cr_all = UnvectorizeFc(read_cr_all,0,true);
read_cp_all = UnvectorizeFc(read_cp_all,1,true);

% Plot
% cxns highlighted significantly in text
koyamaRois = [158 172 218 33 156 192 200 184 85 138];
koyamaLabels = {'lPCG','lPstCG','SMA/PCC','rPstCG','lIFGop (Broca''s)','lSTG (Wernicke''s)','FFG','lIPL','PRC/PCC','vmPFC'};
titlestr = 'Reading CR, all subjects, ROIs as in Koyama Text';

% As in Fig 5
% koyamaRois = [213 200 192 158 192 156 177 218 154 157 263];
% koyamaLabels = {'IOG','FFG','STG','PCG','TPJ','IFGop','IPS','SMA','IFGtr','MFG','THAL'};
% titlestr = 'Reading CR, all subjects, ROIs as in KoyamaFig5';

nKoyama = numel(koyamaRois);

% Plot
clf;
subplot(1,2,1);
imagesc(read_cr_all(koyamaRois,koyamaRois))
hold on;
colorbar
set(gca,'xtick',1:nKoyama,'xticklabel',koyamaLabels,'ytick',1:nKoyama,'yticklabel',koyamaLabels);
xticklabel_rotate;
hold on;
p_vec = VectorizeFc(read_cp_all(koyamaRois,koyamaRois));
q_vec = mafdr(p_vec,'bhfdr',true);
q_mat = UnvectorizeFc(q_vec,1,true);
[iSignif,jSignif] = find(read_cp_all(koyamaRois,koyamaRois)<0.05);
plot(iSignif,jSignif,'k*');
[iFDR,jFDR] = find(q_mat<0.05);
plot(iFDR,jFDR,'r*');
legend('p<0.05','q<0.05');
title(titlestr)

subplot(1,2,2);
imagesc(read_cp_all(koyamaRois,koyamaRois))
hold on;
colorbar
set(gca,'xtick',1:nKoyama,'xticklabel',koyamaLabels,'ytick',1:nKoyama,'yticklabel',koyamaLabels);
xticklabel_rotate;
