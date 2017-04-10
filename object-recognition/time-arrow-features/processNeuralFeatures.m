function [ finalFeatures ] = processNeuralFeatures( neuralFeatures )
%PROCESSNEURALFEATURES Takes the raw neural Features and returns it in a format that is
%processible by the SVM
initialFeatureNb = size(neuralFeatures, 1);
featureSize = size(neuralFeatures, 2);
finalFeatureNb = initialFeatureNb/2;
finalFeatures = Inf*ones(finalFeatureNb, featureSize);
for rawFeatureIndex=1:finalFeatureNb
    beginIndex = (rawFeatureIndex - 1)*2 + 1;
    finalFeatures(rawFeatureIndex, :) = neuralFeatures(beginIndex+1,:) - ...
        neuralFeatures(beginIndex,:);
end

assert(sum(sum(any(finalFeatures==Inf))) == 0, 'All features should be filled');
