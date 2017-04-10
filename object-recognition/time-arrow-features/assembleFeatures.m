function [ finalStruct ] = assembleFeatures( rawFeatureStruct, spacing, featureDiffTime )
%ASSEMBLEFEATURES creates structures with difference features from the
%original raw features
% The assumption here is that for one video the order of the original feature is either
% chronological or reversed and that this information is accessible in
% currentLabels

videoNb = length(rawFeatureStruct);
finalStruct = struct('features',{},'labels',{},'videoName',{});


for videoIndex = 1:videoNb
    currentLabels = rawFeatureStruct(videoIndex).labels;
    videoLength = length(currentLabels);
    featureSize =  size(rawFeatureStruct(1).features,2);
    featureNb = floor((videoLength-featureDiffTime)/spacing);
    labels = zeros(2*featureNb, 1); % *2 because direct and reverse
    rawFeatures = rawFeatureStruct(videoIndex).features;
    newFeatures = Inf*ones(2*featureNb, featureSize);
    for featureIndex=1:featureNb
        newFeatures(2*featureIndex-1, :) = rawFeatures(spacing*(featureIndex-1) + 1 + featureDiffTime,:)- ...
            rawFeatures(spacing*(featureIndex-1) + 1,:);
        newFeatures(2*featureIndex, :) = - (rawFeatures(spacing*(featureIndex-1) + 1 + featureDiffTime,:)- ...
            rawFeatures(spacing*(featureIndex-1) + 1,:));
        labels(2*featureIndex - 1) = currentLabels(1);
        labels(2*featureIndex) = 1 - currentLabels(1);
    end
    assert(sum(sum(newFeatures==Inf))==0, 'newFeatures should have been completely filled' );
    finalStruct(videoIndex).features = newFeatures;
    finalStruct(videoIndex).labels = labels;
    finalStruct(videoIndex).videoName = rawFeatureStruct(videoIndex).videoName;
end