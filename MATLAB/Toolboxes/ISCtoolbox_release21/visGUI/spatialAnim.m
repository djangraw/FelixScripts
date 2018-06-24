function spatialAnim(varargin)

pt = 0

Mark = [{'r'};{'b'};{'k'};{'g'};{'m'}];
Y_lim = [0.4 0.7]; 
Clim = 0.4;

load areaData

iter = 1;
for h = 1:2:length(varargin)
    region(iter) = varargin{h+1};
    switch varargin{h}
        case 'orig'
            data1All{iter} = dataA1cor1;
            data2All{iter} = dataA1cor2;
        case 'high'
            data1All{iter} = dataD2cor1;
            data2All{iter} = dataD2cor2;
        case 'mid-high'
            data1All{iter} = dataD3cor1;
            data2All{iter} = dataD3cor2;
        case 'mid'
            data1All{iter} = dataD4cor1;
            data2All{iter} = dataD4cor2;
        case 'mid-low'
            data1All{iter} = dataD5cor1;
            data2All{iter} = dataD5cor2;
        case 'low'
            data1All{iter} = dataA5cor1;
            data2All{iter} = dataA5cor2;
        otherwise
            error('Incorrect Argument!!')
            return
    end
    
    iter = iter + 1;
    if iter == 4
        break
    end
end

if length(data1All) == 3
    R = 3;
elseif length(data1All) == 2
    R = 2;
elseif length(data1All) == 1
    R = 1;
else
    error('Error...')
    return
end
    
figure
for s = 1:size(data1All{1},2)
    for f = 1:R
        subplot(R,1,f);cla
        plot(data1All{f}{region(f),s});ylim([Y_lim])
    end
    title(['n=' num2str(s)])
    set(gcf,'Position',[217   319   544   382])
    if pt > 0
        pause(pt)
    else
        pause
    end
    
end
figure
for s = 1:size(data2All{1},2)
    for f = 1:R
        subplot(R,1,f);cla
         plot(data2All{f}{region(f),s});ylim([Y_lim])
    end
 set(gcf,'Position',[847   319   544   382])
 title(['n=' num2str(s)])   
 if pt > 0
        pause(pt)
    else
        pause
    end
    
end

% title([{'Dataset 1'};'Region: ' lab{region(1)}]);grid on;xlabel('Voxel index')
%    
%   title([{'Dataset 2'};'Region: ' lab{region(1)}]);grid on;xlabel('Voxel index')
%    