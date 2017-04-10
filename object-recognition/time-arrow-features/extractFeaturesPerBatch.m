function [ resultingFeatures ] = extractFeaturesPerBatch( addressesNames, featureSize, net, IMAGE_DIM, CROPPED_DIM, mean_data)
%EXTRACTFEATURESPERBATCH Extracts the features matching the name of the images
% stored in @addessNames
% The addressNames should have a size of a multiple of 10 to optimize batch
% processing by the neural network

batchSize = 10;
featureNb = length(addressesNames);
passResidu = mod(featureNb, batchSize);
assert(passResidu == 0, 'extractFeaturesPerBatch must receive a number of addresses that is multiple of batchSize');
passNb = featureNb/ batchSize;
resultingFeatures = Inf*ones(featureNb, featureSize);
for passIndex = 1:passNb
    currentBatchAddresses = addressesNames((passIndex-1)*batchSize + 1 : passIndex*batchSize);
    resultingFeatures((passIndex-1)*batchSize + 1 : passIndex*batchSize, :) = ...
        extract10FeaturesFromImages( currentBatchAddresses, net, IMAGE_DIM, CROPPED_DIM, mean_data);
end
assert(sum(sum(resultingFeatures==Inf))==0);