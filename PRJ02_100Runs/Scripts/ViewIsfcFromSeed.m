function ViewIsfcFromSeed(coordFile,voxel2indFile,brickFile)

% Created 2/10/15 by DJ.
[err,Info] = BrikInfo(voxel2indFile);
voxel2ind_names = strsplit(Info.BRICK_LABS,'~');

[err,Info] = BrikInfo(brickFile);
subbrick_names = strsplit(Info.BRICK_LABS,'~');
clear Info

oldDatenum = 0;
while true
    % check if file has changed
    fileInfo = dir(coordFile);
    newDatenum = fileInfo.datenum;
    
    % if it has, plot a new brick
    if newDatenum ~= oldDatenum
        oldDatenum = newDatenum;
        % read new coords
        fid=fopen(coordFile);
        data=textscan(fid,'%f');
        fclose(fid);

        % find the proper slice
        ijk = data{1}(end-2:end); % format is x y z i j k
        vox2indString = sprintf('v%03d.%03d.%03d',ijk);
        iVox2ind = find(strcmp(vox2indString,voxel2ind_names));

        % load the slice 
        frameString = sprintf('SetA_Zscr#%05d',iVox2ind);
        iFrame = find(strcmp(frameString,subbrick_names));
        brick = BrikLoad(brickFile,struct('Frames',iFrame));

        % get current data, if it's open
        if exist('fig','var');      
            figdata = guidata(fig);
            iSlice = figdata.iSlice;
        else
            iSlice = ijk';
        end
        % plot data
        fig = GUI_3View(brick,iSlice);  
        figdata = guidata(fig);
        set(figdata.text_file,'String',sprintf('%s, seed = %s',brickFile,vox2indString))
    end
    pause(1)
end
