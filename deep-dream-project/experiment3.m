
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
net = load('place-model/.mat') ;
mean_im_coeffs = net.meta.normalization.averageImage;
%% Load images
image_addresses = {'images/sky-mountain.jpg','images/china-archi.jpg', 'images/marc.jpg',...
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

nb_iteration = 200;
step_size = 1;
layer_index = 36;
neuron_index = 220;
lambda_regul = 0;
randn('seed',0)
noise_im = randi([0 255],[224 224 3],'single');
noise_im = noise_im - mean_im_coeffs;

current_im = images(1).image;
% current_im = noise_im;
%%

for idx_iter=1:nb_iteration
    [new_im, loss] = one_neuron_gradient_ascent( net, current_im, ...
                                  layer_index, step_size, neuron_index);
    disp(loss);
    h = fspecial('gaussian', 2, 0.5);
    new_im = imfilter(new_im, h);
    current_im = new_im;
    
    % disp(mean(mean(mean(current_im))))
    if(mod(idx_iter, 10) == 0)
        figure(idx_iter);
        imagesc(uint8(new_im + mean_im_coeffs));
    end
    disp(idx_iter)
end

%%

current_im = images(3).image;
blur_step = 10;
nb_iteration = 200;
classes = [170];
class_nb = length(classes);
step_size = 1;
lambda_regul = 0.01;
for class_index=1:class_nb
    neuron_index = classes(class_index);
    for idx_iter=1:nb_iteration
        [new_im, loss] = one_neuron_gradient_ascent( net, current_im, ...
                                      layer_index, step_size, neuron_index);
        % new_im = (1-lambda_regul)*new_im;
        disp(min(new_im(:)))
        disp(mean(new_im(:)));
        disp(max(new_im(:)));
         % disp(loss);
         if(mod(idx_iter, blur_step)==1)
             h = fspecial('gaussian', 5, 1);
             new_im = imfilter(new_im, h);
         end
        current_im = new_im;

        % disp(mean(mean(mean(current_im))))
        if(mod(idx_iter, 10) == 0)
            f = figure(idx_iter);
            imagesc(uint8(new_im + mean_im_coeffs));
            class_name = net.meta.classes.description{neuron_index};
            file_path = file_name(class_name, result_folder, idx_iter);
            % saveas(f, char(strcat(file_path, '-bl-10-step-4')), 'png');
        end
        disp(idx_iter)
    end
end