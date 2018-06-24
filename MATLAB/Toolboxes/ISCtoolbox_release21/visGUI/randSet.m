function [T T2 T3 Tm totSync Arous Valen] = randSet(tyyppi)
clear Arous
clear Valen

load('D:\Tutkimus\fMRI\KatrinKoe.mat')
for k = 1:length(Aro1)-4
    Arous(k) = mean(Aro1(k:k+3));
    Valen(k) = mean(Val1(k:k+3));

end
% clear Arous
% for k = 1:length(Aro2)-4
%     Arous(k) = mean(Aro2(k:k+3));
%     Valen(k) = mean(Val2(k:k+3));
% end
Valen = -1*Valen;

I = load_nii('MNI152_T1_2mm_brain_mask.nii');
I = double(I.img);

% fil{1} = 'D:\Tutkimus\fMRI\data\0504\ASig_SWT\meanset1winA1';
% fil{2} = 'D:\Tutkimus\fMRI\data\0504\DSig_SWT\meanset1winD2';
% fil{3} = 'D:\Tutkimus\fMRI\data\0504\DSig_SWT\meanset1winD3';
% fil{4} = 'D:\Tutkimus\fMRI\data\0504\DSig_SWT\meanset1winD4';
% fil{5} = 'D:\Tutkimus\fMRI\data\0504\DSig_SWT\meanset1winD5';
% fil{6} = 'D:\Tutkimus\fMRI\data\0504\ASig_SWT\meanset1winA5';

load at
% a = load_nii('HarvardOxford-cort-maxprob-thr0-2mm.nii');
% at(:,:,:,1) = a.img;
% a = load_nii('HarvardOxford-sub-maxprob-thr0-2mm.nii');
% at(:,:,:,2) = a.img;

randMask = ( at(:,:,:,1) ~= 0 );%| at(:,:,:,2) ~= 0 );

Z = zeros(91,109,91);
brainReg = 1;%[60 49];
atl = 1;



switch tyyppi
    case 1
        th = 0.2; % threshold for high sync.
        nrVox = length(find(at(:,:,:,atl)==brainReg)); % number of random voxels
        iter = 1; % number of random samplings
        
        % get indices of every brain voxel:
        indsBrain = find(I);
        % get random indices of cortical voxels:
        indsCort = find(randMask);
        THH = [0.2 0.3 0.4 0.5];
        THH = 0.2;
        rrr = 1;
%        for rrr = 1:length(fil)
            clear Wcor
            %load(fil{rrr},'Wcor')
            %Wcor = maskData(Wcor);
            Wcor = R1w_5;
            T = zeros(iter,size(Wcor,4));
            for ff = 1:4
                th = THH(ff);
                for s = 1:50

                    if length(find(at(:,:,:,atl)==s)) > 0
                        brainReg = s;
                        for m = 1:iter
                            % obtain random cortical indices:
                            Rind = randperm(length(indsCort));
                            randIndsCort = indsCort(Rind(1:nrVox));
                            % construct brain map of random voxels:
                            Z(randIndsCort) = m;
                            % go through each time interval:
                            for k = 1:size(Wcor,4)
                                W = Wcor(:,:,:,k);
                                % get high sync. indices in brain region of interest:
                                Af = find(W.*( at(:,:,:,atl)==brainReg));
                                if m == 1
                                    % update brain map and sync. curve in
                                    % the region of interest:
                                    Z(Af) = iter + 1;
                                    T2(k) = sum(W(Af)> th);
                                    totSync(k) = sum(W(indsBrain) > th);
                                end

                                % get random cortical voxel set:
                                voxSet = W(randIndsCort);
                                % update random sample synchronization curves:
                                T(m,k) = sum(voxSet > th); % random region
                            end
                        end

                        %  figure,plot(totSync,'ro');title('Tot Sync')
                        T3 = T2./totSync;
                        %  figure
                        %  plot(T');set(gca,'XTick',[1:24]);hold on;plot(T2,'r','LineWidth',2);hold off
                        %  xlabel('aikaväli');ylabel('Sync vokseleita');title(['Satunnaiset otokset ' num2str(iter) ' kpl + Brain region ' num2str(brainReg) ', kynnys = ' num2str(th)])
                        % figure,plot(Arous./max(Arous),'bo-');hold on;plot(T3./max(T3)+0.2,'ko-');hold off;legend('Arousal',['Brain region' num2str(brainReg)])%,'Normalized Brain reg.')
                        corr(Arous',totSync')
                        disp(['Brain region: ' num2str(brainReg)])
                        disp(['Corr original: ' num2str(corr(Arous',T2'))])
                        disp(['Corr normalized: ' num2str(corr(Arous',T3'))])
                        CORRTABLE{rrr}{ff}(1,s) = brainReg;
                        CORRTABLE{rrr}{ff}(2,s) = corr(Arous',T2');
                        CORRTABLE{rrr}{ff}(3,s) = corr(Arous',T3');
                        CORRTABLE{rrr}{ff}(4,s) = corr(Valen',T2');
                        CORRTABLE{rrr}{ff}(5,s) = corr(Valen',T3');
                        %        figure,for k = 10:85;imagesc(rot90(Z(:,:,k)),[0.5 iter+1.5]);colorbar;pause(0.2);end
                    end
                end
            end
 %       end

        [txtSub txtCort] = loadLabels;
        for a = 1:length(CORRTABLE)
        for g = 1:length(CORRTABLE{1})
            [vals inds] = sort(CORRTABLE{a}{g}(3,:),'descend');
            for k = 1:48;CT{a}{g}{k} = [num2str(vals(k)) ' ' txtCort{inds(k)}];CT2{a}{g}{k} = [txtCort{inds(k)}];end
            CT{a}{g}{30} = CT{a}{g}{30}(1:end-38);
            CT2{a}{g}{30} = CT2{a}{g}{30}(1:end-38);
            CT2 = CT2';
            CT = CT';
        end
        end
        figure,subplot(211);plot(1:48,vals02,'o');grid on;ylabel('Korrelaatio');xlabel('aivoalueen indeksi');set(gca,'XTick',1:48,'XTickLabel',inds02);title('Korrelaatiot pienenevässä järjestyksessä, kynnys = 0.2')
        subplot(212);plot(1:48,vals03,'o');grid on;ylabel('Korrelaatio');xlabel('aivoalueen indeksi');set(gca,'XTick',1:48,'XTickLabel',inds03);title('Korrelaatiot pienenevässä järjestyksessä, kynnys = 0.3')
       save CORRTABLE_set2_all CORRTABLE

    case 2

        th = [0.2:0.1:0.6];

        for m = 1:length(th)
            Rinds = find(I);
            for k = 1:size(Wcor,4)
                W = Wcor(:,:,:,k);
                voxSet = W(Rinds);
                T(m,k) = sum(voxSet > th(m));
                Af = find(W.*(at(:,:,:,1)==1));
                T2(m,k) = sum(W(Af) > th(m));
            end 
        end
        figure
        subplot(3,1,1)
        plot(T');set(gca,'XTick',[1:24]);%hold on;plot(T2,'r','LineWidth',2);hold off
        ylabel('Sync vokseleita');xlabel('Kaikki vokselit');
        for h = 1:length(th)
            lth{h} = ['Threshold ' num2str(th(h))];
        end
        legend(lth)
        subplot(3,1,2)
        plot(T2');set(gca,'XTick',[1:24]);%hold on;plot(T2,'r','LineWidth',2);hold off
        xlabel(['Frontal pole alkuperäinen']);
        subplot(3,1,3)
        zT = T2'./T';
        plot(zT);set(gca,'XTick',[1:24]);%hold on;plot(T2,'r','LineWidth',2);hold off
        xlabel('Frontal Pole normalisoitu');
        T = T';
        T2 = T2';


    
    
    case 3
        th = 0.2; % threshold for high sync.
        nrVox = length(find(at(:,:,:,atl)==brainReg)); % number of random voxels
        iter = 3; % number of random samplings
%        load('D:\Tutkimus\fMRI\data\1103\dataset1\ASig_SWT\meanset1winA5','Wcor')
%        load('D:\Tutkimus\fMRI\data\1103\dataset1\ASig_SWT\meanset1winA1','Wcor')
%        load('D:\Tutkimus\fMRI\data\1103\dataset2\ASig_SWT\meanset2winA1','Wcor')
        load('D:\Tutkimus\fMRI\data\0504\meanset2winA5','Wcor')
        
        % get indices of every brain voxel:
        indsBrain = find(I);
        % get indices of cortical voxels:
        indsCort = find(randMask);
        Wcor = maskData(Wcor);
        T = zeros(iter,size(Wcor,4));
        Tm = zeros(iter,size(Wcor,4));

        for m = 1:iter
            % obtain random cortical indices:
            Rind = randperm(length(indsCort));
            randIndsCort = indsCort(Rind(1:nrVox));
            % construct brain map of random voxels:
            Z(randIndsCort) = m;
            % go through each time interval:
            for k = 1:size(Wcor,4)
                W = Wcor(:,:,:,k);
                % get high sync. indices in brain region of interest:
                Af = find(W.*( at(:,:,:,atl)==brainReg));
                if m == 1
                    % update brain map and sync. curve in
                    % the region of interest:
                    Z(Af) = iter + 1;
                    T2(1,k) = sum(W(Af)> th);
                    T2(2,k) = mean(W(Af));
                    T2(3,k) = median(W(Af));
                    totSync(1,k) = sum(W(indsBrain) > th);
                    totSync(2,k) = mean(W(indsBrain));
                    totSync(3,k) = median(W(indsBrain));
                end

                % get random cortical voxel set:
                voxSet = W(randIndsCort);
                % update random sample synchronization curves:
                T(m,k) = sum(voxSet > th); % random region
                Tm(m,k) = mean(voxSet);
            end
        end

         T3 = T2./totSync;
%         figure
%         subplot(211),plot(T');set(gca,'XTick',[1:24]);hold on;plot(T2,'r','LineWidth',2);hold off
%         xlabel('aikaväli');ylabel('Sync vokseleita');title(['Satunnaiset otokset ' num2str(iter) ' kpl + Brain region ' num2str(brainReg) ', kynnys = ' num2str(th)])
%         subplot(212);plot(Arous./max(Arous),'bo-');hold on;plot(Valen./max(Valen),'r.-');plot(T3./max(T3)+0.2,'kx-');hold off;legend('Arousal','Valence',['Brain region' num2str(brainReg)])%,'Normalized Brain reg.')
%         figure,subplot(211);plot(T2);title('Brain region of interest');grid on
%         subplot(212);plot(totSync./max(totSync),'b-');hold on;plot(Arous./max(Arous),'r');plot(Valen./max(Valen),'g');hold off;title('Tot Sync');legend('Whole brain','Arousal','Valence')

%         corr(Arous',totSync')
%         disp(['Brain region: ' num2str(brainReg)])
%         disp('Arousal:')
%         disp(['Corr original: ' num2str(corr(Arous',T2'))])
%         disp(['Corr normalized: ' num2str(corr(Arous',T3'))])
%         %        figure,for k = 10:85;imagesc(rot90(Z(:,:,k)),[0.5 iter+1.5]);colorbar;pause(0.2);end
%         
%         disp(['Valence: '])
%         disp(['Corr original: ' num2str(corr(Valen',T2'))])
%         disp(['Corr normalized: ' num2str(corr(Valen',T3'))])

        
        %figure,subplot(211);plot(1:48,vals02,'o');grid on;ylabel('Korrelaatio');xlabel('aivoalueen indeksi');set(gca,'XTick',1:48,'XTickLabel',inds02);title('Korrelaatiot pienenevässä järjestyksessä, kynnys = 0.2')
        %subplot(212);plot(1:48,vals03,'o');grid on;ylabel('Korrelaatio');xlabel('aivoalueen indeksi');set(gca,'XTick',1:48,'XTickLabel',inds03);title('Korrelaatiot pienenevässä järjestyksessä, kynnys = 0.3')

end



