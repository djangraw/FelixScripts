% TEMP_BinomialLikeScript
% Test the influence of y, # trials, and prior prob. on binomial-based
% likelihood.
% Created 11/21/12 by DJ for one-time use.

y = 0:0.01:10;
l = bernoull(ones(size(y)),y);
ntrials = [100 1000 10000 100000];
prior = [0.002:.002:0.1];

fractrials = 0.01:0.01:0.3;

clear b
for i=1:numel(ntrials)
    for j=1:numel(prior)
        b(j,:,i) = 1-binocdf(ceil((1-l)*ntrials(i)-1),ntrials(i),prior(j));
%           b(j,:,i) = 1-binocdf(ceil(fractrials*ntrials(i)-1),ntrials(i),prior(j));
    end
end
figure(13); clf
plot(y,(1-l)*100);
xlabel('y')
ylabel('equivalent % trials')


figure(14); clf;
nrows = ceil(sqrt(numel(ntrials))); ncols = ceil(numel(ntrials)/nrows);
for i=1:numel(ntrials)
    subplot(nrows,ncols,i);
    imagesc(y,prior,b(:,:,i));
    xlabel('y')
    ylabel('prior')
    colorbar
    title(sprintf('ntrials = %g',ntrials(i)));
end

% for i=1:numel(ntrials)
%     subplot(nrows,ncols,i);
%     imagesc(fractrials,prior,b(:,:,i));
%     xlabel('fractrials')
%     ylabel('prior')
%     colorbar
%     title(sprintf('ntrials = %g',ntrials(i)));
% end