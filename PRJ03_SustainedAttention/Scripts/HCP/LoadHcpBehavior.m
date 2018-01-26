function [info, beh, behNames,taskBeh,taskBehNames,otherBeh,otherBehNames] = LoadHcpBehavior()

% [info, beh, behNames,taskBeh,taskBehNames,otherBeh,otherBehNames] = LoadHcpBehavior()
%
% Created 1/26/18 by DJ.


behDir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/FromEmily';
info = readtable([behDir '/unrestricted_esfinn_7_14_2016_8_52_0.csv']);
beh = [info.PicSeq_Unadj, info.CardSort_Unadj, info.Flanker_Unadj, info.PicVocab_Unadj, info.ProcSpeed_Unadj, info.ListSort_Unadj, info.ReadEng_Unadj, info.PMAT24_A_CR];  
behNames = {'Pic Seq (ep mem)','Card Sort (cog flex)','Flanker (inhib)','Pic Vocab (lang)','Pattern Compl (proc speed)','List Sort (WM)','Oral Reading Recog', 'PMAT (IQ)'};

taskBeh = [info.Emotion_Task_Acc, info.Gambling_Task_Perc_NLR, ...
    info.Language_Task_Story_Acc, info.Language_Task_Math_Acc, ...
    info.Relational_Task_Acc, info.Social_Task_Perc_TOM, info.WM_Task_2bk_Acc];
taskBehNames = {'Emotion','Gambling','Language (story)','Language (math)','Relational','Social','WM'};

otherBeh = [info.Age, info.Gender];
otherBehNames = {'Age','Gender'};