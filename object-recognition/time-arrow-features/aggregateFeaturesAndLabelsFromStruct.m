function [ finalFeatures, finalLabels ] = aggregateFeaturesAndLabelsFromStruct( videoStruct)
%AGGREGATEFEATURESANDLABELSFROMSTRUCT puts features and labels from several
%videos in one struct to same array in @finalFeatures and @finalLabels

% @params videoStruct : structure array that contains three fields :
% {features, labels, videoName}
% @return finalFeatures : array of features 
% @return finalLabels : array of labels that encode time's arrow for the
% corresponding features

videoNb = length(videoStruct);

currentIndex = 1;
for videoIndex=1:videoNb
    featuresPerVideo = size(videoStruct(videoIndex).features, 1);    
    for featureIndex=1:featuresPerVideo
        finalFeatures(currentIndex, :)=videoStruct(videoIndex).features(featureIndex, :);
        finalLabels(currentIndex) = videoStruct(videoIndex).labels(featureIndex); 
        currentIndex = currentIndex + 1;
    end
end
assert(any(finalLabels==-1)==0);
assert(sum(any(finalFeatures==Inf))==0);