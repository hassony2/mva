function [ new_image ] = multi_scale_dream(net, input_image, step_size, layer_index, stride)
%MULTI_SCALE_DREAN Summary of this function goes here
%   Detailed explanation goes here
[height, width, ~] = size(input_image);
stride = 100;
patch_size = 224;
new_image = input_image;
for idx_height=1:stride:height-patch_size
    for idx_width=1:stride:width-patch_size
        patch = new_image(idx_height:idx_height + patch_size, ...
                            idx_width:idx_width + patch_size, :);
        [new_patch, ~ ] = l2_gradient_ascent_step( net, patch, ...
                                             layer_index, step_size);
        new_image(idx_height:idx_height + patch_size, ...
                            idx_width:idx_width + patch_size, :) = new_patch;
        disp('widht')
    end
    disp('height')
end

