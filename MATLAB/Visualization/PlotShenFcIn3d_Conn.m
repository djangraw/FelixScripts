function h = PlotShenFcIn3d_Conn(FC,sphereSize)

% h = PlotShenFcIn3d_Conn.m
%
% INPUTS:
% -FC is an nxn matrix of FC connections, where n is the # of ROIs in the
% Shen atlas (268).
% -sphereSize is an nx1 matrix of the size you'd like each sphere to be. Or
% it can be 'auto', which will make each used ROI size 3 and all others 0.
% [default: 'auto']
%
% OUTPUTS:
% -h is a handle to the plotting function, which can be used to change the
% plot (e.g., feval(h,'brain_transparency',0.1); see conn_mesh_display for
% options). 
% 
% Created 2/9/17 by DJ.
% Updated 2/10/17 by DJ - added sphereSize input.
% Updated 2/23/17 by DJ - added h output.

% Declare defaults
if ~exist('sphereSize','var') || isempty(sphereSize)
    sphereSize = 'auto';
end

% Load atlas
atlasFile = '/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc';
[shenAtlas,shenInfo] = BrikLoad(atlasFile);

%% Declare parameters
% Get ROI positions
roiLocs = GetAtlasRoiPositions(shenAtlas);
nRois = length(roiLocs);

% Initialize conn toolbox, then close window
% conn;

% Declare labels & colors
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true);

% Declare params
% - XYZ can be a [N by 3] matrix containing the x/y/z coordinates (in MNI mm)
% of N ROIs, and R is a [N by N] matrix containing the correlation
% strengths between your ROIs (set to 0 those connections that you wish not
% to be displayed) 
% - If, in addition, you want to control the size and color of each ROI
% sphere, define XYZ to be a structure with fields: 
%   sph_xyz:  [N by 3] matrix of ROI coordinates (xyz mm values)
%   sph_r:      [N by 1] vector of sphere radius
%   sph_c:      [N by 3] matrix of sphere colors (rgb 0-1 values)

% Declare the struct version
XYZ = struct;
[~,XYZ.sph_xyz] = AFNI_Index2XYZcontinuous(roiLocs,shenInfo,'LPI');%shenInfo.Orientation(:,1)'); % pos should be in mm
XYZ.sph_c = shenColors_hem(shenLabels_hem,:);

% Make unused spheres tiny or invisible
if ischar(sphereSize) && strcmpi(sphereSize,'auto')
    XYZ.sph_r = repmat(3,nRois,1);
    XYZ.sph_r(all(FC==0,1) & all(FC==0,2)') = 0;%1;
else
    XYZ.sph_r = sphereSize;
end
%% Plot with default surface
% Plot
h = conn_mesh_display('', '', '', XYZ, FC, .2);
% Make brain surface very transparent
feval(h,'brain_transparency',0.1);
feval(h,'sub_transparency',0.1);
