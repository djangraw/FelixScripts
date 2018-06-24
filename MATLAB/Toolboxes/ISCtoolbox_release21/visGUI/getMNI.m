for k = 1:size(Acor{1},1)
    [x,y,z]=ind2sub([91 109 91],Acor{1}{k,2});
    Corig_cor(k,:) = [x - 46 y - 55 z - 46];
end

for k = 1:size(Aken{1},1)
    [x,y,z]=ind2sub([91 109 91],Aken{1}{k,2});
    Corig_ken(k,:) = [x - 46 y - 55 z - 46];
end

for k = 1:size(Acor{5},1)
    [x,y,z]=ind2sub([91 109 91],Acor{5}{k,2});
    Capp4_cor(k,:) = [x - 46 y - 55 z - 46];
end

for k = 1:size(Aken{5},1)
    [x,y,z]=ind2sub([91 109 91],Aken{5}{k,2});
    Capp4_ken(k,:) = [x - 46 y - 55 z - 46];
end

for k = 1:size(Dcor{4},1)
    [x,y,z]=ind2sub([91 109 91],Dcor{4}{k,2});
    Cdet3_cor(k,:) = [x - 46 y - 55 z - 46];
end

for k = 1:size(Dken{4},1)
    [x,y,z]=ind2sub([91 109 91],Dken{4}{k,2});
    Cdet3_ken(k,:) = [x - 46 y - 55 z - 46];
end

