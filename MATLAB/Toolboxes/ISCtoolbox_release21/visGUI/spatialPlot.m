function olf = spatialPlot(varargin)

% spatialPlot('orig',3,[3 17],[11 24],'mid',3,[3 17],[11 24],'low',3,[3 17],[11 24])
% spatialPlot('low',3,[4 10 18],[],'low',3,[],[11 16 24]);
% spatialPlot('orig',4,[4 8 14],[],'mid',4,[4 8 14],[]);
% spatialPlot('orig',6,[4 18],[],'mid',6,[4 18],[11 24]);

Mark = [{'r'};{'b'};{'k'};{'g'};{'m'}];
Y_limits = [0.4 0.8]; 
Clim = 0.4;

load areaData

iter = 1;
for h = 1:4:length(varargin)
    k = 1;
    switch varargin{h}
        case 'orig'
            data1All{iter} = dataA1cor1;
            data2All{iter} = dataA1cor2;
            if ~isempty(varargin{h+2})
                for k = 1:length(varargin{h+2})
                    data{iter}{k} = dataA1cor1{varargin{h+1},varargin{h+2}(k)}';
                    labs{iter}{k} = ['n= ' num2str(varargin{h+2}(k)) ' (set 1)'];
                end
            else
                k = 0;
            end
            if ~isempty(varargin{h+3})
                for n = 1:length(varargin{h+3})
                    data{iter}{k+n} = dataA1cor2{varargin{h+1},varargin{h+3}(n)}';
                    labs{iter}{k+n} = ['n= ' num2str(varargin{h+3}(n)) ' (set 2)'];
                end
            end
        case 'high'
            data1All{iter} = dataD2cor1;
            data2All{iter} = dataD2cor2;
            if ~isempty(varargin{h+2})
                for k = 1:length(varargin{h+2})
                    data{iter}{k} = dataD2cor1{varargin{h+1},varargin{h+2}(k)}';
                    labs{iter}{k} = ['n= ' num2str(varargin{h+2}(k)) ' (set 1)'];
                end
            else
                k = 0;
            end
            if ~isempty(varargin{h+3})
                for n = 1:length(varargin{h+3})
                    data{iter}{k+n} = dataD2cor2{varargin{h+1},varargin{h+3}(n)}';
                    labs{iter}{k+n} = ['n= ' num2str(varargin{h+3}(n)) ' (set 2)'];
                end
            end
        case 'mid-high'
            data1All{iter} = dataD3cor1;
            data2All{iter} = dataD3cor2;
            if ~isempty(varargin{h+2})
                for k = 1:length(varargin{h+2})
                    data{iter}{k} = dataD3cor1{varargin{h+1},varargin{h+2}(k)}';
                    labs{iter}{k} = ['n= ' num2str(varargin{h+2}(k)) ' (set 1)'];
                end
            else
                k = 0;
            end
            if ~isempty(varargin{h+3})
                for n = 1:length(varargin{h+3})
                    data{iter}{k+n} = dataD3cor2{varargin{h+1},varargin{h+3}(n)}';
                    labs{iter}{k+n} = ['n= ' num2str(varargin{h+3}(n)) ' (set 2)'];
                end
            end
        case 'mid'
            data1All{iter} = dataD4cor1;
            data2All{iter} = dataD4cor2;
            if ~isempty(varargin{h+2})
                for k = 1:length(varargin{h+2})
                    data{iter}{k} = dataD4cor1{varargin{h+1},varargin{h+2}(k)}';
                    labs{iter}{k} = ['n= ' num2str(varargin{h+2}(k)) ' (set 1)'];
                end
            else
                k = 0;
            end
            if ~isempty(varargin{h+3})
                for n = 1:length(varargin{h+3})
                    data{iter}{k+n} = dataD4cor2{varargin{h+1},varargin{h+3}(n)}';
                    labs{iter}{k+n} = ['n= ' num2str(varargin{h+3}(n)) ' (set 2)'];
                end
            end
        case 'mid-low'
            data1All{iter} = dataD5cor1;
            data2All{iter} = dataD5cor2;
            if ~isempty(varargin{h+2})
                for k = 1:length(varargin{h+2})
                    data{iter}{k} = dataD5cor1{varargin{h+1},varargin{h+2}(k)}';
                    labs{iter}{k} = ['n= ' num2str(varargin{h+2}(k)) ' (set 1)'];
                end
            else
                k = 0;
            end
            if ~isempty(varargin{h+3})
                for n = 1:length(varargin{h+3})
                    data{iter}{k+n} = dataD5cor2{varargin{h+1},varargin{h+3}(n)}';
                    labs{iter}{k+n} = ['n= ' num2str(varargin{h+3}(n)) ' (set 2)'];
                end
            end
        case 'low'
            data1All{iter} = dataA5cor1;
            data2All{iter} = dataA5cor2;
            if ~isempty(varargin{h+2})
                for k = 1:length(varargin{h+2})
                    data{iter}{k} = dataA5cor1{varargin{h+1},varargin{h+2}(k)}';
                    labs{iter}{k} = ['n= ' num2str(varargin{h+2}(k)) ' (set 1)'];
                end
            else
                k = 0;
            end
            if ~isempty(varargin{h+3})
                for n = 1:length(varargin{h+3})
                    data{iter}{k+n} = dataA5cor2{varargin{h+1},varargin{h+3}(n)}';
                    labs{iter}{k+n} = ['n= ' num2str(varargin{h+3}(n)) ' (set 2)'];
                end
            end
        otherwise
            error('Incorrect Argument!!')
            return
    end
    % calculate overlap factor:
    for m = 1:length(data{iter})
        for n = 1:length(data{iter})
            if n > m
                olf{iter}(m,n) = sum(( data{iter}{m} >= Clim ) & ...
                    ( data{iter}{n} >= Clim ))/min(sum(data{iter}{n} ...
                    >= Clim),sum(data{iter}{m} >= Clim));
            end
        end
    end
    iter = iter + 1;
    if iter == 4
        break
    end
end
figure

if length(data) >= 1
   H(1) = subplot(3,1,1);
    hold on
    for k = 1:length(data{1})
        plot(data{1}{k},Mark{k});xlabel(['voxel index, ' varargin{1} ' freq']);ylabel('Synch value')
    end
    hold off;grid on;ylim(Y_limits);legend(labs{1})
    title({'Spatial pattern of mostly synchronized voxels at different time instants'});
end

if length(data) >= 2
    H(2) = subplot(3,1,2);
    hold on
    for k = 1:length(data{2})
        plot(data{2}{k},Mark{k});xlabel(['voxel index, ' varargin{5} ' freq']);ylabel('Synch value')
    end
    hold off;grid on;ylim(Y_limits);legend(labs{2})
end
if length(data) >= 3
    H(3) = subplot(3,1,3);
    hold on
    for k = 1:length(data{3})
        plot(data{3}{k},Mark{k});xlabel(['voxel index, ' varargin{9} ' freq']);ylabel('Synch value')
    end
    hold off;grid on;ylim(Y_limits);legend(labs{3})
end

set(gcf,'Position',[37   332   859   497])

