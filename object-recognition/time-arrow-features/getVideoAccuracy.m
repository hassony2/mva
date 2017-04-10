function [ resultAccuracy] = getVideoAccuracy( videoStructArray, modelName)
%GETTESTACCURACY Computes accuracy over predictions by averaging svm scores
% compute accuracy
testVideoNb = length(videoStructArray);
trueLabels = -1*ones(testVideoNb, 1);
predictedLabels = -1*ones(testVideoNb, 1);
sumScore = zeros(testVideoNb,1);
for videoIndex = 1:testVideoNb
    if (videoStructArray(videoIndex).videoName(1)=='F')
        trueLabels(videoIndex) = 1;
    else
        trueLabels(videoIndex) = 0;
    end
    testFeatures = videoStructArray(videoIndex).features;
    [~,score] = predict(modelName,testFeatures);
    x = sum(sum(isnan(score)));
    
    assert(sum(sum(isnan(score)))==0);
    sumScore(videoIndex) = mean(score(1:2:end,1)) - mean(score(2:2:end,1));
    % if the video is forward, the ten first scores are the forward
    % predictions and the ten next are the backward ones
    % if the video is backward, it's the opposite

    if (sumScore(videoIndex) > 0)
        predictedLabels(videoIndex) = 0;
    else 
        predictedLabels(videoIndex) = 1;
    end

end
resultAccuracy = (testVideoNb - sum(abs(trueLabels-predictedLabels)))/testVideoNb;

end

