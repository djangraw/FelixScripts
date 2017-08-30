function motion = GetMotionEnergy(movieFilename,tStart,tEnd)

% Created 5/12/15 by DJ.

[mov, frameRate] = GetMovie(movieFilename,tStart,tEnd);

img1 = rgb2gray(mov(1).cdata);
img2 = rgb2gray(mov(2).cdata);

hbm = vision.BlockMatcher('ReferenceFrameSource', 'Input port', 'BlockSize', [35 35]);

motion = step(hbm, img1, img2);

% Make alpha blended image
halphablend = vision.AlphaBlender;
img12 = step(halphablend, img2, img1);
% Plot results
[X, Y] = meshgrid(1:35:size(img1, 2), 1:35:size(img1, 1));
imshow(img12); hold on;
quiver(X(:), Y(:), real(motion(:)), imag(motion(:)), 0); hold off;


