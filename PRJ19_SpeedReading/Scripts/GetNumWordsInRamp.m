function nWords = GetNumWordsInRamp(wpm_min,wpm_max,tTotal)

%%
nWords_vec = [100:100:2000];
% wpm_min = 60;
% wpm_max = 500;

dur_total = nan(1,numel(nWords_vec));
for i=1:numel(nWords_vec)
    % declare speeds
    wpm_vec = linspace(wpm_min,wpm_max,nWords_vec(i));

    % Get word start times
    dur_ideal = 60./wpm_vec;
    dur_total(i) = sum(dur_ideal);
end

plot(nWords_vec,dur_total,'.-');

m = median(diff(dur_total)./diff(nWords_vec));
b = dur_total(1)-m*nWords_vec(1);

nWords = floor(tTotal/m-b);
fprintf('%d words for a total of %.1f seconds.\n',nWords,tTotal);
