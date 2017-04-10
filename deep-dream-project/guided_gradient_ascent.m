function [ new_image ] = guided_gradient_ascent( net, image, ...
                                                layer_index, guided_vals, ...
                                                step)
%ONE_NEURON_GRADIENT_ASCENT Summary of this function goes here
%   Detailed explanation goes here

res = init_res(layer_index);       % initializate response structure
res(1).x = image;               % load image in first layer
res = forwardto(net, layer_index + 1, res); % Forward propagation to selected layer

dzdy = guided_vals;
back = backwardfrom(net, layer_index, dzdy, res);
grad_im = back(1).dzdx;
% normalization to avoid small or huge gradients
normalization_factor = mean(abs(grad_im(:)));
epsilon = 0.0000001; % For numerical stability
grad_im = grad_im/(normalization_factor + epsilon);
new_image = image + step*(grad_im);

activation_values = res(layer_index + 1).x;

end



