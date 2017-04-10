function [ im_ ] = im_preprocess( image_address, net)
%IM_PREPROCESS Reads the image file and returns the image ready for input
%to net
im = imread(image_address) ;
im_ = single(im) ; % note: 255 range
mean_im_coeffs = net.meta.normalization.averageImage;
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ -  mean_im_coeffs;

end

