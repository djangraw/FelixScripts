% GetOverlapOfNetworkWithNeurosynthMemoryTopic.m
%
% Created 9/18/17 by DJ.

vars = GetDistractionVariables;


posFilename = fullfile(vars.homedir,...
    'Results/NeuroSynth/NeuroSynth_v4-topics-100_24_memory_encoding_retrieval_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc');
negFilename = '';
% posFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_15_reading_words_language_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
% negFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_86_speech_auditory_sounds_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
atlasFilename = [vars.homedir '/Results/Shen_2013_atlas/MNI_EPIres_shen_1mm_268_parcellation+tlrc'];
posMaskThreshold = 0;
negMaskThreshold = 0;
posMatchThreshold = 0.15;%0.5;%
negMatchThreshold = 0.15;%0.5;%
MemNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);

%% Check for prediction
[mem_pos,mem_neg,mem_combo] = GetFcMaskMatch(FC_fisher,MemNetwork,zeros(size(MemNetwork)));
[mem_pos,mem_neg,mem_combo] = deal(mem_pos',mem_neg',mem_combo');
[r_mem,p_mem] = corr(mem_pos,fracCorrect,'tail','right');
fprintf('Memory Network Correlation w/ Behavior: r=%.3g, p=%.3g\n',r_mem,p_mem);

%% Check for overlapping EDGES
load('ReadingNetwork_73edge.mat','readingNetwork');
PlotOverlapBetweenFcNetworks(readingNetwork,MemNetwork,shenAtlas,...
    shenLabels_hem,shenColors_hem,show_symbols(shenLabelNames_hem),{'Reading','Memory'});

%% Check for overlapping NODES
isMemNode = any(MemNetwork>0,1);
isReadingPosNode = any(readingNetwork>0,1);
isReadingNegNode = any(readingNetwork<0,1);
olap_pos = sum(isMemNode & isReadingPosNode);
olap_neg = sum(isMemNode & isReadingNegNode);
fprintf('%d memory nodes overlap with %d/%d reading pos nodes and %d/%d reading neg nodes.\n',...
    sum(isMemNode),olap_pos,sum(isReadingPosNode),olap_neg,sum(isReadingNegNode));
% Get stats
nNodes = numel(isMemNode);
pOverlapPos = 1-hygecdf(olap_pos, nNodes, sum(isMemNode), sum(isReadingPosNode));
pOverlapNeg = 1-hygecdf(olap_neg, nNodes, sum(isMemNode), sum(isReadingNegNode));
fprintf('hygecdf: pPos = %.3g, pNeg = %.3g\n',pOverlapPos,pOverlapNeg);

%% Write brik of memory network
cd /gpfs/gsfs5/users/jangrawdc/PRJ03_SustainedAttention/Results
BrickToWrite = MapValuesOntoAtlas(shenAtlas,isMemNode);
Opt = struct('Prefix',sprintf('Memory_NeuroSynth_isPos+tlrc'));
fprintf('Writing AFNI Brik %s...\n',Opt.Prefix);
WriteBrik(BrickToWrite,shenInfo,Opt);
fprintf('Done!\n');
