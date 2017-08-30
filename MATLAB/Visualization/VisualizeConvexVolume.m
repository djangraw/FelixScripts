function hSurf = VisualizeConvexVolume(brick)

% Created 10/19/16 by DJ.

i = find(brick>0);
[X,Y,Z] = ind2sub(size(brick),i);
k = boundary([X,Y,Z]);

hSurf = trisurf(k,X,Y,Z,'facecolor','black','facealpha',0.1,'linestyle','none');


