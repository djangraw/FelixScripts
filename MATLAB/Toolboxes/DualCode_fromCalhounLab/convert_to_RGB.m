function IMrgb = convert_to_RGB(IM, cm, cmLIM)
% convert_to_RGB - converts any image to truecolor RGB using a specified colormap  
% USAGE: IMrgb = convert_to_RGB(IM, cm, cmLIM)
% INPUTS: 
%    IM    = the image [m x n]
%    cm    = the colormap [p x 3], optional; default = jet(256)
%    cmLIM = the data limits [min max] to be used in the color-mapping 
%            optional; default = [min(IM) max(IM)]
% OUTPUTS: 
%    IMrgb = the truecolor RGB image [m x n x 3]
% Based on ind2rgb from the Image Processing Toolbox
% EA Allen August 30, 2011
% eallen@mrn.org
%--------------------------------------------------------------------------
if nargin < 2, cm = jet(256); end
if nargin < 3, cmLIM = [min(IM(:)) max(IM(:))]; end

IM = IM-cmLIM(1);
IM = IM/(cmLIM(2)-cmLIM(1));
nIND = size(cm,1);
IM = round(IM*(nIND-1));

IM = double(IM)+1;
r = zeros(size(IM)); r(:) = cm(IM,1);
g = zeros(size(IM)); g(:) = cm(IM,2);
b = zeros(size(IM)); b(:) = cm(IM,3);

IMrgb = zeros([size(IM),3]);
% Fill in the r, g, and b channels
IMrgb(:,:,1) = r;
IMrgb(:,:,2) = g;
IMrgb(:,:,3) = b;
