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

%% Extract
rand('seed',1);
test1 = extractTestFeatures(test1Folder, net, 1024);
test2 = extractTestFeatures(test2Folder, net, 1024);
test3 = extractTestFeatures(test3Folder, net, 1024);
toc;

%%
kernelName = 'polynomial';
boxConstraint = 1;
tic
[ accuracies1 ] = crossValidateSvm( test1, test2, test3, kernelName, 1, 0, 2)
[ accuracies2 ] = crossValidateSvm( test1, test2, test3, kernelName, 10, 0, 2)
toc

%%

tic
rand('seed', 1);
[ accuracies1 ] = crossValidateSvm( test1, test2, test3, 'linear', 1, 0, 0 )
toc
%%
[trainFeatures1, trainLabels1] = aggregateFeaturesAndLabelsFromStruct([test2,test3]);

%% 
tic
trainVideos = extract10testFeatures(trainFolder, net);
toc

%%
[trainFeatures1, trainLabels1] = aggregateFeaturesAndLabelsFromStruct([test1, test2, test3 ]);

%% get validation Features 
tic
% rand('seed', 1);
rand('seed', 2);
valVideos = extract10testFeatures(valFolder, net);
toc
%% Validation accuracy
tic
% train model on all training set
SVMModelVal = fitcsvm(trainFeatures1,trainLabels1, 'KernelFunction','polynomial', 'BoxConstraint',0.01,'PolynomialOrder',3);
toc
%%
acc = getTestAccuracy( valVideos,SVMModelVal)
toc

%% Monitor overfitting
tic
SVMModelVal = fitcsvm(trainFeatures1,trainLabels1, 'KernelFunction','polynomial', 'BoxConstraint',100,'PolynomialOrder',2);
toc
acc = getTestAccuracy( trainVideos,SVMModelVal)
toc
%% Run tests
polynomialOrders = [2 3];
boxConstraints = [0.001 1 1000];
standardizations = [true false];

boxNb = length(boxConstraints);
polOrdNb = length(polynomialOrders);
standardizationNb = length(standardizations);
accuracies = zeros(polOrdNb, boxNb, standardizationNb ,3);
%%

for polOrdIndex = 1:polOrdNb
    for boxConstraintIndex=1:boxNb
        for standardIndex = 1:standardizationNb
            tic
            accuracies(polOrdIndex, boxConstraintIndex, standardIndex, :) = ...
                crossValidateSvm( test1, test2, test3, 'linear', boxConstraints(boxConstraintIndex), polynomialOrders(polOrdIndex), standardizations(standardIndex))
            toc
        end
    end
end

%% accuracies on various features
randomIterations = 100;
accuracies = zeros(randomIterations,3);
%%
[accuracies(1, :), SVMModel1, SVMModel2, SVMModel3 ] = ...
                crossValidateSvm( test1, test2, test3, 'polynomial', 1 , 3, 1)

for i=2:randomIterations
    rand('seed',30+i);
    tic
    test1 = extract10testFeatures(test1Folder, net);
    test2 = extract10testFeatures(test2Folder, net);
    test3 = extract10testFeatures(test3Folder, net);
    accuracies(i,1) = getTestAccuracy(test1, SVMModel1);
    accuracies(i,2) = getTestAccuracy(test2, SVMModel2);
    accuracies(i,3) = getTestAccuracy(test3, SVMModel3)
    toc
end
%%
crossValidateSvm( test1, test2, test3, 'polynomial', boxConstraints(boxConstraintIndex), polynomialOrders(polOrdIndex), standardizations(standardIndex))
%% Test boxConstraint influence

tic
SVMModelVal = fitcsvm(trainFeatures1,trainLabels1, 'KernelFunction','polynomial', 'PolynomialOrder',3);
toc
acc = getTestAccuracy( trainVideos,SVMModelVal)
toc

%% Nan hunting

[trainFeatures1, trainLabels1] = aggregateFeaturesAndLabelsFromStruct([test2,test3]);
[trainFeatures2, trainLabels2] = aggregateFeaturesAndLabelsFromStruct([test1,test3]);
[trainFeatures3, trainLabels3] = aggregateFeaturesAndLabelsFromStruct([test1,test2]);
polynomialOrder = 3;
boxConstraint = 1;
kernelName = 'polynomial';
 SVMModel1 = fitcsvm(trainFeatures1,trainLabels1, 'KernelFunction',kernelName , 'BoxConstraint',boxConstraint, 'PolynomialOrder',polynomialOrder, 'Standardize', standardizations(1));
 SVMModel2 = fitcsvm(trainFeatures2,trainLabels2, 'KernelFunction',kernelName , 'BoxConstraint',boxConstraint, 'PolynomialOrder',polynomialOrder, 'Standardize', standardizations(1));
 SVMModel3 = fitcsvm(trainFeatures3,trainLabels3, 'KernelFunction',kernelName , 'BoxConstraint',boxConstraint, 'PolynomialOrder',polynomialOrder, 'Standardize', standardizations(1));
 
 %%
 [~,score] = predict(SVMModel3,test3(1).features);
 
 
 