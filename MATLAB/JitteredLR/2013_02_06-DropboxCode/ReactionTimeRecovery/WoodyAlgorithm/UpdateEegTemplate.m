function template = UpdateEegTemplate(data,weights,windowSize)

% Created 11/27/12 by DJ.

[ntrials, noffsets] = size(weights);

template = zeros(size(data,1),windowSize);
for i=1:ntrials
    for j=1:noffsets
        template = template + data(:,j-1+(1:windowSize),i)*weights(i,j);
    end
end
    
template = template/ntrials;