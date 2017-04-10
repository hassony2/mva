function [ testVideoAccuracies, testFeatureAccuracies, trainFeatureAccuracies, SVMModel1, SVMModel2, SVMModel3 ] = crossValidateLin( test1, test2, test3, lambda)

%CROSSVALIDATELIN returns accuracy for the three testSets by fitting the
% a regularized linear classifier
% @return testVideoAccuracies the time arrow prediction Accuracy aggregated by video
% @return test(/train)FeatureAccuracies the the time arrow prediction for the
% features of the test(/train) set

testVideoAccuracies = zeros(3,1);
testFeatureAccuracies = zeros(3,1);
trainFeatureAccuracies = zeros(3,1);

[trainFeatures1, trainLabels1] = aggregateFeaturesAndLabelsFromStruct([test2,test3]);
[trainFeatures2, trainLabels2] = aggregateFeaturesAndLabelsFromStruct([test1,test3]);
[trainFeatures3, trainLabels3] = aggregateFeaturesAndLabelsFromStruct([test1,test2]);    
[testFeatures1, testLabels1] = aggregateFeaturesAndLabelsFromStruct(test1);
[testFeatures2, testLabels2] = aggregateFeaturesAndLabelsFromStruct(test2);
[testFeatures3, testLabels3] = aggregateFeaturesAndLabelsFromStruct(test3);    


SVMModel1 = fitclinear(trainFeatures1,trainLabels1,  'Lambda', lambda);
SVMModel2 = fitclinear(trainFeatures2,trainLabels2,  'Lambda', lambda);
SVMModel3 = fitclinear(trainFeatures3,trainLabels3,  'Lambda', lambda);

testVideoAccuracies(1) = getVideoAccuracy(test1, SVMModel1);
testVideoAccuracies(2) = getVideoAccuracy(test2, SVMModel2);
testVideoAccuracies(3) = getVideoAccuracy(test3, SVMModel3);

testFeatureAccuracies(1) = getFeatureAccuracy(testFeatures1, testLabels1, SVMModel1);
testFeatureAccuracies(2) = getFeatureAccuracy(testFeatures2, testLabels2, SVMModel2);
testFeatureAccuracies(3) = getFeatureAccuracy(testFeatures3, testLabels3, SVMModel3);

trainFeatureAccuracies(1) = getFeatureAccuracy(trainFeatures1, trainLabels1, SVMModel1);
trainFeatureAccuracies(2) = getFeatureAccuracy(trainFeatures2, trainLabels2, SVMModel2);
trainFeatureAccuracies(3) = getFeatureAccuracy(trainFeatures3, trainLabels3, SVMModel3);
end




