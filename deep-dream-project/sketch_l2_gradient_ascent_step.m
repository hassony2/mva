function [ new_image, l2_value ] = sketch_l2_gradient_ascent_step( net, image, ...
                            layer_index, step, type)
%CHANGE Summary of this function goes here
%  @param layer_index : for vgg pick layer between 32 (fc6) 34(fc7)
%                       36 (fc8 with 1000 classes) 37 is the softmax
% @param image : initial image with subtracted mean coeffs from training
% @param step : size of the step for the gradient ascent

res = init_res(layer_index);       % initializate response structure
res(1).x = image;               % load image in first layer
res = sketch_forwardto(net, layer_index, res) ; % Forward propagation to selected layer

if (strcmp(type, 'l2'))
    dzdy = 2 * res(layer_index + 1).x;
elseif (strcmp(type, 'neuron'))
    dzdy = 2 * res(layer_index + 1).x;
    keep_indexes = 1:size(dzdy, 3);
    neuron_index = 100;
    keep_indexes(neuron_index) = [];
    dzdy(:,:,keep_indexes) = 0;
end
back = sketch_backwardfrom(net, layer_index, dzdy, res);
grad_im = back(1).dzdx;

new_image = image + step/(0.0000001 + mean(abs(grad_im(:))))*grad_im;
values = res(layer_index + 1).x;
l2_value = norm(reshape(values,[1, numel(values)]));
end


