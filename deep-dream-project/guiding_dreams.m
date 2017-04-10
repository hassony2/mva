
% Load MatConvNet
% Change the path to your installation of MatConvNet
mcnpath = 'matconvnet-1.0-beta23';

run(fullfile(mcnpath, 'matlab', 'vl_setupnn'))

result_folder = 'results';
% -------------------------------------------------------------------------
% Load VGG-ImageNet, give an overview
% -------------------------------------------------------------------------

% Indicate the location of imagenet-vgg-verydeep-16.mat
% you need to download it first from http://www.vlfeat.org/matconvnet/pretrained/
net = load('data/imagenet-vgg-verydeep-16.mat') ;
mean_im_coeffs = net.meta.normalization.averageImage;
%% Load images
image_addresses = {'images/flower.jpg', 'images/leopard.jpg', 'images/sky-mountain.jpg','images/china-archi.jpg', 'images/marc.jpg',...
                    'images/lion.jpg', 'images/sophie2.jpg', 'images/stock.jpg'};
images = struct;
nb_images = length(image_addresses);
for idx=1:nb_images
   disp(strcat('loaded image nb', string(idx)))
   address = image_addresses{idx};
   images(idx).address = address;
   images(idx).image = im_preprocess(address, net);
end


%% Experiment with other response maximization

nb_iteration = 50;
step_size = 1;
layer_index = 3;
lambda_regul = 0;
randn('seed',0);
blur_step = 10;
noise_im = randi([0 255],[224 224 3],'single');
noise_im = noise_im - mean_im_coeffs;


% current_im = noise_im;
%%
current_im = images(4).image;
guided_res = init_res(layer_index);       % initializate response structure
guided_res(1).x = images(2).image;               % load image in first layer
guided_res = forwardto(net, layer_index + 1, guided_res); % Forward propagation to selected layer
activation_guide = guided_res(layer_index + 1).x;
h = fspecial('gaussian', 2, 0.5);
for idx_iter=1:nb_iteration
    new_im = guided_gradient_ascent( net, current_im, ...
                                  layer_index, activation_guide, step_size);
    if(mod(idx_iter, blur_step)==1)
       new_im = imfilter(new_im, h);
    end
    current_im = new_im;
    
    if(mod(idx_iter, 1) == 0)
        figure(idx_iter);
        imagesc(uint8(new_im + mean_im_coeffs));
    end
    disp(idx_iter)
end
