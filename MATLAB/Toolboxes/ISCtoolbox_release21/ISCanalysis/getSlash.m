function slash = getSlash

if isunix
    slash = '/';
else
    slash = '\';   
end
