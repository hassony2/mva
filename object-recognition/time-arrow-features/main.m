% Script that extracts differences of generic features and trains a classifier
% on top of it to try and predict time's arrow for a given feature and also
% for a given video
% This script extracts features on the fly (by computing the activations of the
% GAP layer of the GoogLeNet CAM neural network)
% Consider using difference.main if you haven't pre-extracted the features as both script
% are written for the same classifying purpose

%% Uncomment and run to pre-extract all generic features from all frames
mainFolder = 'D:/remote-results/youtube-reduce/total';
allFeatures = extractAllNeuralFeatures( mainFolder, net, 1024);

%% Uncomment to load saved features
% allFeatures = load('allNeuralFeatures.mat');
% allFeatures = allFeatures.allFeatures;
%% Generate difference features
featureDiff = 2; % Number of frames between the two generic features that we subtract
spacing = 2; % at which interval the consecutive difference of generic features should be sampled
currentFeatures = assembleFeatures(allFeatures, spacing, featureDiff);
%% train/Test split
rand('seed',1);
testIndexes = randperm(180,36);
testFeaturesStruct = currentFeatures(testIndexes)
trainFeaturesStruct = currentFeatures
trainFeaturesStruct(testIndexes)=[];
trainSize = length(trainFeaturesStruct);
testSize = length(testFeaturesStruct);


%% validation split
test1Index = 1:3:trainSize;
test2Index = 2:3:trainSize;
test3Index = 3:3:trainSize;

%% create Test structures
test1 = trainFeaturesStruct(test1Index);
test2 = trainFeaturesStruct(test2Index);
test3 = trainFeaturesStruct(test3Index);

%% Create train arrays
tic
[trainFeatures1, trainLabels1] = aggregateFeaturesAndLabelsFromStruct([test2,test3]);
[trainFeatures2, trainLabels2] = aggregateFeaturesAndLabelsFromStruct([test1,test3]);
[trainFeatures3, trainLabels3] = aggregateFeaturesAndLabelsFromStruct([test1,test2]);
toc
%% Create test arrays
tic
[testFeatures1, testLabels1] = aggregateFeaturesAndLabelsFromStruct(test1);
[testFeatures2, testLabels2] = aggregateFeaturesAndLabelsFromStruct(test2);
[testFeatures3, testLabels3]= aggregateFeaturesAndLabelsFromStruct(test3);
toc

%% Compute classifiers and accuracies
[ testVideoAccuracies_3, testFeatureAccuracies_3, trainFeatureAccuracies_3, SVMModel1_3, SVMModel2_3, SVMModel3_3 ] = crossValidateLin(test1, test2, test3, 10^-3)
[ testVideoAccuracies_2, testFeatureAccuracies_2, trainFeatureAccuracies_2, SVMModel1_2, SVMModel2_2, SVMModel3_2 ] = crossValidateLin(test1, test2, test3, 10^-2)
[ testVideoAccuracies0, testFeatureAccuracies0, trainFeatureAccuracies0, SVMModel10, SVMModel20, SVMModel30 ] = crossValidateLin(test1, test2, test3, 1)
[testVideoAccuracies1, testFeatureAccuracies1, trainFeatureAccuracies1, SVMModel11, SVMModel21, SVMModel31 ] = crossValidateLin(test1, test2, test3, 10)
[testVideoAccuraciesBC_1, testFeatureAccuraciesBC_1, trainFeatureAccuraciesBC_1, SVMModel1BC_1, SVMModel2BC_1, SVMModel3BC_1 ] = crossValidateSvm(test1, test2, test3, 'linear', 0.1, 0, 0)
[testVideoAccuraciesBC1, testFeatureAccuraciesBC1, trainFeatureAccuraciesBC1, SVMModel1BC1, SVMModel2BC1, SVMModel3BC1 ] = crossValidateSvm(test1, test2, test3, 'linear', 10, 0, 0)
[testVideoAccuraciesBC2, testFeatureAccuraciesBC2, trainFeatureAccuraciesBC2, SVMModel1BC2, SVMModel2BC2, SVMModel3BC2] = crossValidateSvm(test1, test2, test3, 'linear', 100, 0, 0);

%% Subfonction on a specific example
[classes, scores] = predict(SVMModel11, trainFeatures1);
getFeatureAccuracy(trainFeatures1, trainLabels1, LinearMdl)
getFeatureAccuracy(testFeatures1, testLabels1, LinearMdl)