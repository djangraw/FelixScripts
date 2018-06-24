function v = assertVec(v,type)

if strcmp(type,'row')
    if size(v,1) > 1
        v=v';
    end
elseif strcmp(type,'col')
    if size(v,2) > 1
        v=v';
    end
else
    error('Unknown type');
end
