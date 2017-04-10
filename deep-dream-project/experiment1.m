% Load MatConvNet
% Change the path to your installation of MatConvNet
mcnpath = 'matconvnet-1.0-beta23';

run(fullfile(mcnpath, 'matlab', 'vl_setupnn'))

result_folder = 'results';
% -------------------------------------------------------------------------
% Load sketch-a-net, give an overview
% -------------------------------------------------------------------------

net = load('sketch-models/model_without_order_info_64.mat');
info = net.info;
net = net.net;
h = fspecial('gaussian', 3, 1.0);
%% Load images
image_addresses = {'images/china-archi.jpg', 'images/marc.jpg',...
                    'images/lion.jpg', 'images/sophie2.jpg', 'images/stock.jpg'};
images = struct;
nb_images = length(image_addresses);
for idx=1:nb_images
   disp(strcat('loaded image nb', string(idx)))
   address = image_addresses{idx};
   images(idx).address = address;
   images(idx).image = sketch_preprocess(address, 256);
end

%% Experiment with various layers
% current_im = simple_sketch(256);
current_im = images(3).image;
nb_iteration = 100;
step_size = 0.1;
layer_index = 20;
regul = 0.001;
figure(1000);
imshow(current_im, [-1, 1]); 
for idx_iter=1:nb_iteration
    [new_im, l2_val] = sketch_l2_gradient_ascent_step( net, current_im, ...
                                  layer_index, step_size, 'l2');
    % current_im = max(min(new_im,1),-1);
    current_im = current_im*(1-regul);
    if(mod(idx_iter,100)==0)
        current_im = imfilter(new_im, h);
    end
    disp(max(max(new_im)))
    disp(min(min(new_im)))
    if(mod(idx_iter,10)==0)
        figure(idx_iter);
        imshow(max(min(new_im,1),-1), [-1, 1]); 
     end
end



