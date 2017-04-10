function [ testVideoAccuracies, testFeatureAccuracies, trainFeatureAccuracies, SVMModel1, SVMModel2, SVMModel3 ] = crossValidateSvm( test1, test2, test3, kernelName, boxConstraint, standardization, polynomialOrder)
%CROSSVALIDATESVM returns accuracy for the three testSets by fitting the
%SVM on the other two testSets
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

if strcmp(kernelName, 'polynomial')
    SVMModel1 = fitcsvm(trainFeatures1,trainLabels1, 'KernelFunction',kernelName , 'BoxConstraint',boxConstraint, 'PolynomialOrder',polynomialOrder, 'Standardize', standardization);
    SVMModel2 = fitcsvm(trainFeatures2,trainLabels2, 'KernelFunction',kernelName , 'BoxConstraint',boxConstraint, 'PolynomialOrder',polynomialOrder, 'Standardize', standardization);
    SVMModel3 = fitcsvm(trainFeatures3,trainLabels3, 'KernelFunction',kernelName , 'BoxConstraint',boxConstraint, 'PolynomialOrder',polynomialOrder, 'Standardize', standardization);
else
    SVMModel1 = fitcsvm(trainFeatures1,trainLabels1, 'KernelFunction',kernelName , 'BoxConstraint',boxConstraint, 'Standardize', standardization);
    SVMModel2 = fitcsvm(trainFeatures2,trainLabels2, 'KernelFunction',kernelName , 'BoxConstraint',boxConstraint, 'Standardize', standardization);
    SVMModel3 = fitcsvm(trainFeatures3,trainLabels3, 'KernelFunction',kernelName , 'BoxConstraint',boxConstraint, 'Standardize', standardization);
end

testVideoAccuracies(1) = getVideoAccuracy(test1, SVMModel1);
testVideoAccuracies(2) = getVideoAccuracy(test2, SVMModel2);
testVideoAccuracies(3) = getVideoAccuracy(test3, SVMModel3)

testFeatureAccuracies(1) = getFeatureAccuracy(testFeatures1, testLabels1, SVMModel1);
testFeatureAccuracies(2) = getFeatureAccuracy(testFeatures2, testLabels2, SVMModel2);
testFeatureAccuracies(3) = getFeatureAccuracy(testFeatures3, testLabels3, SVMModel3)

trainFeatureAccuracies(1) = getFeatureAccuracy(trainFeatures1, trainLabels1, SVMModel1);
trainFeatureAccuracies(2) = getFeatureAccuracy(trainFeatures2, trainLabels2, SVMModel2);
trainFeatureAccuracies(3) = getFeatureAccuracy(trainFeatures3, trainLabels3, SVMModel3)

end

