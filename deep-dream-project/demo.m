
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
                    'images/lion.jpg', 'images/sophie2.jpg'};
images = struct;
nb_images = length(image_addresses);
for idx=1:nb_images
   disp(idx)
   address = image_addresses{idx};
   images(idx).address = address;
   images(idx).image = im_preprocess(address, net);
end
    
%%
nb_iteration = 10;
for idx_image=1:nb_images
    current_im = images(idx_image).image;
    for idx_iter=1:nb_iteration
        [new_im, l2_val] = l2_gradient_ascent_step( net, current_im, ...
                                      layer_index, step_size);
        current_im = new_im;
    end
    figure(1);
    imagesc(uint8(new_im + mean_im_coeffs )); 
end


