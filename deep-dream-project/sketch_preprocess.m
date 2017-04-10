function [ im] = sketch_preprocess( image_address, image_size)
%SKETCH_PREPROCESS Loads and prepares image for sketch a net
%   

%IM_PREPROCESS Reads the image file and returns the image ready for input
%to net
im = imread(image_address) ;
im = rgb2gray(im);
im = 2*(single(imresize(im, [image_size, image_size]))./255 - 0.5);
end


