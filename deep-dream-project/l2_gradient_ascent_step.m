function [ new_image, l2_value ] = l2_gradient_ascent_step( net, image, ...
                            layer_index, step)
%CHANGE Summary of this function goes here
%  @param layer_index : for vgg pick layer between 32 (fc6) 34(fc7)
%                       36 (fc8 with 1000 classes) 37 is the softmax
% @param image : initial image with subtracted mean coeffs from training
% @param step : size of the step for the gradient ascent

res = init_res(layer_index);       % initializate response structure
res(1).x = image;               % load image in first layer
res = forwardto(net, layer_index, res) ; % Forward propagation to selected layer

dzdy = 2 * res(layer_index + 1).x;

back = backwardfrom(net, layer_index, dzdy, res);
grad_im = back(1).dzdx;

new_image = image + step*grad_im;
values = res(layer_index + 1).x;
l2_value = norm(reshape(values,[1, numel(values)]));
end

