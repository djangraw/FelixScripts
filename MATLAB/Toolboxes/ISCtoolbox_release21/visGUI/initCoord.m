function [x_start,y_start,iter] = initCoord(dataDim,BlockMin);

coord_start = getDatablockIndex(dataDim(1:2),BlockMin);
x_start = coord_start(1);
y_start = coord_start(2);
iter = BlockMin;
