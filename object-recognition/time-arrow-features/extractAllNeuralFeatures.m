function [ featureStructArray ] = extractAllNeuralFeatures( mainFolderName, net, featureSize )
%EXTRACTALLNEURALFEATURES Summary of this function goes here
%   Detailed explanation goes here


%EXTRACT10TESTFEATURES Summary of this function goes here

d = load('ilsvrc_2012_mean.mat');
mean_data = d.mean_data;
IMAGE_DIM = 256;
CROPPED_DIM = 224;

imagePrefix = '/im%08d.jpeg';

[videos,videoNb] = getFilesAndFolders(mainFolderName);

featureStructArray = struct('features',{},'labels',{},'videoName',{});


for videoIndex=1:videoNb
    videoName = videos{videoIndex};
    featureStructArray(videoIndex).videoName = videoName;
    
    forwardVideo = false;
    if videoName(1) == 'F'
        forwardVideo = true;
    end
    
    inputSubFolder = [mainFolderName,'/', videoName];
    [~, frameNb] = getFilesAndFolders(inputSubFolder);
    frameNb = 10*floor(frameNb/10); % multiple of 10 to work with forward pass batching
    %  === Fill array of image names
    imageAddresses = cell(frameNb,1);
    for frameIndex = 1:frameNb
        imageAddresses{frameIndex} = ...
                 [inputSubFolder,sprintf(imagePrefix, frameIndex )];
    end
    neuralFeatures = extractFeaturesPerBatch( imageAddresses, featureSize, net, IMAGE_DIM, CROPPED_DIM, mean_data); 
    featureStructArray(videoIndex).features = neuralFeatures;
    
    if(forwardVideo)
        featureStructArray(videoIndex).labels = ones(frameNb,1);
    else
        featureStructArray(videoIndex).labels = zeros(frameNb,1);
    end
    disp(videoIndex)   
end

