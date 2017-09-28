%% Get avg volume of a node
[shenAtlas,shenInfo] = BrikLoad([homedir '/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc.BRIK']);
nInRoi = nan(1,268);
for i=1:268
    nInRoi(i) = sum(shenAtlas(:)==i);
end
fprintf('mean voxels in ROI = %.3f\n',mean(nInRoi));
fprintf('mean volume = %.3f mm^3\n',mean(nInRoi)*prod(abs(shenInfo.DELTA)));

%% Use overlap between reading and gradCPT networks to predict

%[read_pos, read_neg, read_combo,read_posMask_all,read_negMask_all] = RunLeave1outBehaviorRegression(FC_fisher,fracCorrect,thresh,corr_method,mask_method);
attnNets = load([homedir '/Collaborations/MonicaRosenberg/attn_nets_268.mat']);
gradCptNetwork = attnNets.pos_overlap - attnNets.neg_overlap;

% For each LOO run, get overlap with gradCPT network and use to get score
nSubj = numel(subjects);
olapScore = nan(nSubj,1);
for i=1:nSubj
    [~,~,olapScore(i)] = GetFcMaskMatch(FC_fisher(:,:,i),attnNets.pos_overlap & read_posMask_all(:,:,i),attnNets.neg_overlap & read_negMask_all(:,:,i));
end

% Get correlation with behavior
[r,p] = corr(olapScore,fracCorrect,'tail','right');
fprintf('Reading/GradCPT overlap: LOO corr w/ beh: r=%.3f, p=%.3g\n',r,p);
    

%% Check for memory-specific nodes in reading network
load ReadingNetwork_73edge.mat
readingNetwork = UnvectorizeFc(VectorizeFc(readingNetwork),0,true);
load ReadingNetwork_p01_Fisher.mat
readingNetwork_p01 = UnvectorizeFc(VectorizeFc(readingNetwork_p01),0,true);

memNodes = [182 222 138 231 197,99];
memNodeNames = {'lAG','PCC','mPFC','lHC','lMTG','rHC'};
for i=1:numel(memNodes)
    %find pos
    foo = find(readingNetwork(memNodes(i),:)>0);
    if ~isempty(foo)
        fprintf('%s has %d nodes in 73-edge reading + network: [%s]\n',memNodeNames{i},numel(foo),num2str(foo));
    end
    %find neg
    foo = find(readingNetwork(memNodes(i),:)<0);
    if ~isempty(foo)
        fprintf('%s has %d nodes in 73-edge reading - network: [%s]\n',memNodeNames{i},numel(foo),num2str(foo));
    end
    %find pos
    foo = find(readingNetwork_p01(memNodes(i),:)>0);
    if ~isempty(foo)
        fprintf('%s has %d nodes in p<0.01 reading + network: [%s]\n',memNodeNames{i},numel(foo),num2str(foo));
    end
    %find neg
    foo = find(readingNetwork_p01(memNodes(i),:)<0);
    if ~isempty(foo)
        fprintf('%s has %d nodes in p<0.01 reading - network: [%s]\n',memNodeNames{i},numel(foo),num2str(foo));
    end
    
end

%% Check these nodes' CP/CR using all subjects

load('ReadingCpCr_19subj_Fisher_TrainOnAll_2017-05-17.mat');
read_cp = UnvectorizeFc(VectorizeFc(read_cp),0,true);
read_cr = UnvectorizeFc(VectorizeFc(read_cr),0,true);
thresh = 0.01;
for i=1:numel(memNodes)
    % find pos
    foo = find(read_cp(memNodes(i),:)<thresh & read_cr(memNodes(i),:)>0);
    if ~isempty(foo)
        fprintf('%s has %d nodes with p<%g + (all subj): [%s]\n',memNodeNames{i},numel(foo),thresh,num2str(foo));
    end
    % find neg
    foo = find(read_cp(memNodes(i),:)<thresh & read_cr(memNodes(i),:)<0);
    if ~isempty(foo)
        fprintf('%s has %d nodes with p<%g - (all subj): [%s]\n',memNodeNames{i},numel(foo),thresh,num2str(foo));
    end
end

