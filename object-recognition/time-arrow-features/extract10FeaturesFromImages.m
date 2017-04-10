function [ features ] = extract10FeaturesFromImages( imageAddresses, net, IMAGE_DIM, CROPPED_DIM, mean_data )
%EXTRACTFEATUREFROMIMAGE One pass in the neural network for a batch of 10
%videos

% @ return features : an array containing in each row one of the 10
% resulting generic features

    center = floor((IMAGE_DIM - CROPPED_DIM + 1) / 2) + 1;
    initValue = -200;
    images = initValue*ones(CROPPED_DIM, CROPPED_DIM, 3, 10, 'single');
    assert(length(imageAddresses) == 10);
    for m=1:length(imageAddresses)
        currentImage = imread(imageAddresses{m});
        caffeImage = convertImageForCaffe(currentImage, IMAGE_DIM, mean_data);
        images(:,:,:,m) = caffeImage(center:center+CROPPED_DIM-1,center:center+CROPPED_DIM-1,:);
    end
    assert(sum(sum(sum(any(images==initValue))))==0); %% Make sure no initialization values left
    scores = net.forward({images});
    pool_activ = squeeze(net.blobs('CAM_pool').get_data());
    features = permute(pool_activ, [2 1]);
end



