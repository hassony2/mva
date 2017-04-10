function [ centralFeature ] = extractFeatureFromImage( imageAddresses, net )
%EXTRACTFEATUREFROMIMAGE Summary of this function goes here
%   Detailed explanation goes here
    img = imread(imageAddress);
    prepared = prepare_image(img);
    scores = net.forward({prepared});
    pool_activ = net.blobs('CAM_pool').get_data();
    centralFeature = reshape(pool_activ(1,1,:,5), 1, 1024);
end

