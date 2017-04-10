% Script that extracts differences of generic features and trains a classifier
% on top of it to try and predict time's arrow for a given feature and also
% for a given video
% This script extracts features on the fly (by computing the activations of the
% GAP layer of the GoogLeNet CAM neural network)
% Consider using main.m if you pre-extracted the features as both script
% are written for the same classifying purpose

clear;
%% setup caffe
addpath('D:\Packages\caffe\Build\x64\Release\matcaffe');
caffe.set_mode_gpu();

%% Load net
net_weights = ['models/imagenet_googleletCAM_train_iter_120000.caffemodel'];
net_model = ['models/deploy_googlenetCAM.prototxt'];
net = caffe.Net(net_model, net_weights, 'test');

%% Main folders
trainFolder = 'D:/remote-results/youtube-reduce/train';
test1Folder = 'D:/remote-results/youtube-reduce/train-split/test-1';
test2Folder = 'D:/remote-results/youtube-reduce/train-split/test-2';
test3Folder = 'D:/remote-results/youtube-reduce/train-split/test-3';
valFolder = 'D:/remote-results/youtube-reduce/val';

%% Extract test features

rand('seed',1);
tic;
test1 = extractTestFeatures(test1Folder, net, 1024);
toc;
test2 = extractTestFeatures(test2Folder, net, 1024);
toc;
test3 = extractTestFeatures(test3Folder, net, 1024);
toc;

%% Create train test features and labels as arrays
[trainFeatures1, trainLabels1] = aggregateFeaturesAndLabelsFromStruct([test2,test3]);
[trainFeatures2, trainLabels2] = aggregateFeaturesAndLabelsFromStruct([test1,test3]);
[trainFeatures3, trainLabels3] = aggregateFeaturesAndLabelsFromStruct([test1,test2]);
[testFeatures1, testLabels1] = aggregateFeaturesAndLabelsFromStruct(test1);
[testFeatures2, testLabels2] = aggregateFeaturesAndLabelsFromStruct(test2);
[testFeatures3, testLabels3]= aggregateFeaturesAndLabelsFromStruct(test3);
%%
% lambdas = logspace(-6,-0.5,11);

%% get Accuracies
testAccuracy = getFeatureAccuracy(testFeatures1, testLabels1, LinearMdl);
trainAccuracy = getFeatureAccuracy(trainFeatures1, trainLabels1, LinearMdl);

%%
[ testVideoAccuracies, testFeatureAccuracies, trainFeatureAccuracies, SVMModel1, SVMModel2, SVMModel3 ] = crossValidateLin(test1, test2, test3, 10^-1);
%%
[ testVideoAccuracies, testFeatureAccuracies, trainFeatureAccuracies, SVMModel1, SVMModel2, SVMModel3 ] = crossValidateSvm(test1, test2, test3, 'linear', 1, 1, 0);