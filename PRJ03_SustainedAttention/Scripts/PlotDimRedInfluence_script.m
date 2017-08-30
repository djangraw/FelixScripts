% PlotDimRedInfluence_script.m
%
% Created 3/17/16 by DJ.

tc = [75 80 85 90 95 97 100];
% tc = [85 97];
% tc = [75 80 85 90 95 97];
fc = [10 20 30 40:5:60 70 80 90];
% fc = [50 55 60 65 70 80];
% fc = [60 70 80];
% fc = 70;

[Az_mag,Az_fc] = deal(nan(numel(tc),numel(fc)));
for i=1:numel(tc)
    for j=1:numel(fc)
        try
            Az_this = eval(sprintf('mean(Az_%d_%d,1)',tc(i),fc(j)));
        catch
            Az_this = nan(2,2,2);
        end
        Az_mag(i,j) = Az_this(1,1,1);
        Az_fc(i,j) = Az_this(1,2,2);
    end
end

figure(772); clf;
subplot(2,1,1);
plot(tc,max(Az_mag,[],2),'.-');
xlabel('% Mag var kept')
ylabel('AUC');
title('Mag AUC for whiteNoise vs. Speech') 
grid on
subplot(2,1,2);
plot(fc,Az_fc','.-');
legendstr = {};
for i=1:numel(tc)
    legendstr{i} = sprintf('%d%% Mag var kept',tc(i));
end
legend(legendstr)
xlabel('% FC var kept');
ylabel('AUC');
title('FC AUC for attended vs. ignored speech');
grid on
%%
