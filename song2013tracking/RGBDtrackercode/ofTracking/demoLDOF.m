im1 = double(imread('1.bmp'));
im2 = double(imread('2.bmp'));
tic
flow = mex_LDOF(im1,im2);
toc