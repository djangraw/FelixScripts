function [AA1,AA2,q,qabs] = calculateReproducibilityIndex(Params,reg)


load([Params.PublicParams.dataDestination 'memMaps'])
if reg == 0
    M = load_nii(Params.PrivateParams.brainMask);
else
    M = load_nii(Params.PrivateParams.brainAtlases{5});
end
M = M.img;
M = M(:);
if reg > 0
    M = M == reg; 
end

pF = Params.PrivateParams.prefixFreqBand;
pS = Params.PrivateParams.prefixSession;
iter = 1;
clear AA1 AA2 q me st
for k = 0:Params.PrivateParams.maxScale + 1
    for m = 1:Params.PrivateParams.nrSessions
        for n = 1:Params.PrivateParams.nrSessions
            if n > m
                A1 = swapbytes(memMaps.resultMap.whole.([pF num2str(k)]).([pS num2str(m)]).cor.Data.xyz);
                A2 = swapbytes(memMaps.resultMap.whole.([pF num2str(k)]).([pS num2str(n)]).cor.Data.xyz);
                A1 = A1(:);
                A2 = A2(:);
                brainInds = setdiff(find(M),find(isnan(sum(A1,2)) | isnan(sum(A2,2))));
                A1 = A1(brainInds);
                A2 = A2(brainInds);
                q(iter) = mean(abs(A1-A2))/(mean((A1+A2)/2));
                qabs(iter) = mean(abs(A1-A2));

%                (sum(abs(A1-A2))/(0.5*sum(A1+A2)))
                AA1{iter} = A1;
                AA2{iter} = A2;
                me(iter) = mean(A1-A2);
                st(iter) = std(A1-A2);
                iter = iter + 1;
                
            end
        end
    end
end
