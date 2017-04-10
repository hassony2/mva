
% Load MatConvNet
% Change the path to your installation of MatConvNet
mcnpath = 'matconvnet-1.0-beta23';

run(fullfile(mcnpath, 'matlab', 'vl_setupnn'))

% -------------------------------------------------------------------------
% Load VGG-ImageNet, give an overview
% -------------------------------------------------------------------------

% Indicate the location of imagenet-vgg-verydeep-16.mat
% you need to download it first from http://www.vlfeat.org/matconvnet/pretrained/
net = load('data/imagenet-vgg-verydeep-16.mat') ;
vl_simplenn_display(net) ;

%% -------------------------------------------------------------------------
% Use the model to classify an image
% -------------------------------------------------------------------------

% obtain and preprocess an image
im = imread('images/piano.jpg') ;
im_ = single(im) ; % note: 255 range
mean_im_coeffs = net.meta.normalization.averageImage;
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ -  mean_im_coeffs;
%%
% run the CNN
layer = length(net.layers);   % pick layer
res = init_res(layer) ;       % initializate response structure
res(1).x = im_;               % load image in first layer
res = forwardto(net, layer, res) ; % Forward propagation to selected layer

% show the classification result
scores = squeeze(gather(res(layer+1).x)) ;
[bestScore, best] = max(scores) ;
figure(1) ; clf ; imagesc(im) ; axis image ;
title(sprintf('%s (%d), score %.3f',...
net.meta.classes.description{best}, best, bestScore)) ;

% backwardfrom has similar usage: you should keep the same res structure
% and backpropagate from an extra dzdy argument specifying the jacobian
% with respect to the last layer activations.

%% Network visualization
vl_simplenn_display(net);

%% Operate gradient ascent with various step sizes

nb_iteration = 16;
step_sizes = [0.001, 0.0005, 0.0001];
[~, nb_step] = size(step_sizes);
layer_index = 27;   % pick layer between 32 (fc6) 34(fc7) 36 (fc8 with 1000 classes) 37 is the softmax

% good choices for 10 iteration: layer_indx = 36, step_size = 10
% 34, 1
% 32, 0.1

l2_values = zeros(nb_step, nb_iteration);
for idx_step=1:nb_step
    current_im = images(3).image;
    step_size = step_sizes(idx_step);
    for i=1:nb_iteration
        [new_im, l2_value]= l2_gradient_ascent_step( net, current_im, layer_index, step_size);
        l2_values(idx_step, i) = l2_value;
        h = fspecial('gaussian', 3, 1.0);
        current_im = imfilter(new_im, h);
        if (i==15)
            f = figure(i);
            imshow(uint8(current_im + mean_im_coeffs ));
            title_name = sprintf('results/lion-it-%d-step-%.0e-lay-27', ...
            i, step_size)
            saveas(f, title_name, 'png')
        end
    end
end

% Display l2 norm evolution for various step sizes
figure(20);
t = 1:15
plot(t, l2_values(1,1:15),'DisplayName','step : 0.001'); hold on;
plot(t, l2_values(2,1:15),'DisplayName','step : 0.0005');
plot(t, l2_values(3,1:15),'DisplayName','step : 0.0001'); hold off;
legend('show');
                              
%% Test on various inputs
image_addresses = {'images/china-archi.jpg', 'images/marc.jpg',...
                    'images/lion.jpg', 'images/sophie2.jpg', 'images/stock.jpg'};
images = struct;
nb_images = length(image_addresses);
for idx=1:nb_images
   disp(idx)
   address = image_addresses{idx};
   images(idx).address = address;
   images(idx).image = im_preprocess(address, net);
end
    
%% Experiment with various layers
nb_iteration = 20;
step_size = 0.0001;
layer_index = 27;

for idx_image=5:nb_images
    current_im = images(idx_image).image;
    for idx_iter=1:nb_iteration
        [new_im, l2_val] = l2_gradient_ascent_step( net, current_im, ...
                                      layer_index, step_size);
        current_im = new_im;
    end
    figure(1);
    imagesc(uint8(new_im + mean_im_coeffs )); 
end

%% 
current_im = images(4).image;
nb_iteration = 60;
l2_reponse = zeros(1, nb_iteration);
step_size = 0.00001;
layer_index = 15;
h = fspecial('gaussian', 2, 1.0);
l2_values = zeros(1, nb_iteration);
for i=1:nb_iteration
    disp(i)
    [new_im, l2_value]= l2_gradient_ascent_step( net, current_im, layer_index, step_size);
    l2_values(i) = l2_value;
    current_im = imfilter(new_im, h);
end

%% Display divergense of l2 response
plot(l2_values(1:60))
xlabel('iterations')
ylabel('l2 norm of response')

%% Various input sizes
nb_iteration = 10;
step_size = 0.00001;
layer_index = 15;
im_not_resized = single(imread('images/sophie.jpg'));
im_not_resized = im_not_resized - mean_im_coeffs;
size(im_not_resized)
current_im = im_not_resized;
for idx_iter=1:nb_iteration
    [new_im, l2_val] = l2_gradient_ascent_step( net, current_im, ...
                                  layer_index, step_size);
    current_im = new_im;
    figure(idx_iter)
    imshow(uint8(current_im + mean_im_coeffs))
end

%% 4 patches
layer_index = 15;
iterations = 10;
step_size = 0.00001;
current_image = im_not_resized;
for iter = 1:iterations
    res_image = multi_scale_dream(net, current_image, step_size, layer_index, 224);
    figure(iter);
    imshow(uint8(res_image + mean_im_coeffs));
    current_image = res_image;
end

%% multi scale : layer cycle
layers = [3,15,27];
nb_layers = size(layers, 2);
iterations = 10;
step_sizes = [0.0001, 0.00001, 0.001];
current_image = im_not_resized;
for iter = 1:iterations
    for layer = 1:nb_layers
        step_size = step_sizes(layer);
        layer_index= layers(layer);
        disp(step_size)
        res_image = multi_scale_dream(net, current_image, step_size, layer_index, 224);
        current_image = res_image;       
    end
    figure(iter);
    imshow(uint8(res_image + mean_im_coeffs));
end

%% multi scale : layer cycle
layers = [3,15,27];
nb_layers = size(layers, 2);
im_not_resized = single(imread('images/fuji-original.jpg'));
im_not_resized = im_not_resized - mean_im_coeffs;
size(im_not_resized)
iterations = 10;
step_sizes = [0.00005, 0.000005, 0.0005];
current_image = im_not_resized;
for iter = 1:iterations
    for layer = 1:nb_layers
        step_size = step_sizes(layer);
        layer_index= layers(layer);
        disp(step_size)
        res_image = multi_scale_dream(net, current_image, step_size, layer_index, 100);
        current_image = res_image;       
    end
    figure(iter);
    imshow(uint8(res_image + mean_im_coeffs));
end

%% starting from pure noise
randn('seed',0)
noise_im = randi([0 255],[224 224 3],'single');
noise_im = noise_im - mean_im_coeffs;
%% Patterns from noise
nb_iteration = 20;
step_size = 0.0001;
layer_index = 3;

current_im = noise_im;
for idx_iter=1:nb_iteration
    [new_im, l2_val] = l2_gradient_ascent_step( net, current_im, ...
                                  layer_index, step_size);
    current_im = new_im;
    figure(idx_iter);
    imagesc(uint8(new_im + mean_im_coeffs )); 
end
