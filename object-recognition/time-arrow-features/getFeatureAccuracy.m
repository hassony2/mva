function [ resultAccuracy ] = getFeatureAccuracy(testFeatureArray, testLabels, modelName )
%GETFEATUREACCURACY Summary of this function goes here
%   Detailed explanation goes here
[predictClasses, predictScores] = predict(modelName, testFeatureArray);
confusMat = confusionmat(predictClasses, testLabels);
resultAccuracy = sum(diag(confusMat))/sum(sum(confusMat));
end

