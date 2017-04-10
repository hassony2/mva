function [testFeatureStructArray ] = extractTestFeatures(mainFolderName, net, featureSize)

%EXTRACTTESTFEATURES extracts differences of generic features from videos such
% Time consuming as does not uses preprocessed  extracted features for each
% video

featuresPerVideo = 100;
neuralFeaturePerFinalFeatureNb = 2;
frameSpacing = 10;

d = load('ilsvrc_2012_mean.mat');
mean_data = d.mean_data;
IMAGE_DIM = 256;
CROPPED_DIM = 224;

imagePrefix = '/im%08d.jpeg';

[videos,videoNb] = getFilesAndFolders(mainFolderName);

testFeatureStructArray = struct('features',{},'labels',{},'videoName',{});


for videoIndex=1:videoNb
    videoName = videos{videoIndex};
    testFeatureStructArray(videoIndex).videoName = videoName;
    
    forwardVideo = false;
    if videoName(1) == 'F'
        forwardVideo = true;
    end
    
    inputSubFolder = [mainFolderName,'/', videoName];
    [~, frameNb] = getFilesAndFolders(inputSubFolder);
    
    %  === Fill array of image names
    imageAddresses = cell(neuralFeaturePerFinalFeatureNb*featuresPerVideo,1);
    maxFrame = (frameNb - frameSpacing);
    for finalFeatureIndex = 1:featuresPerVideo
        firstFrame = randi([1 maxFrame]);
        for frameIndex = 1:neuralFeaturePerFinalFeatureNb
            beginIndex = neuralFeaturePerFinalFeatureNb*(finalFeatureIndex-1)+1; % first storage index for triplet
             imageAddresses{beginIndex} = ...
                 [inputSubFolder,sprintf(imagePrefix, firstFrame)];
             imageAddresses{beginIndex + 1} = ...
                 [inputSubFolder,sprintf(imagePrefix, firstFrame + frameSpacing)];
        end
    end
    assert(length(imageAddresses)==neuralFeaturePerFinalFeatureNb*featuresPerVideo);
    neuralFeatures = extractFeaturesPerBatch( imageAddresses, featureSize, net, IMAGE_DIM, CROPPED_DIM, mean_data); 
    currentFeatures = processNeuralFeatures(neuralFeatures);
    testFeatureStructArray(videoIndex).features = [currentFeatures; -currentFeatures] ;
    
    % fill labels
    if (forwardVideo)
       testFeatureStructArray(videoIndex).labels = [ones(featuresPerVideo,1); zeros(featuresPerVideo,1)];
    else
       testFeatureStructArray(videoIndex).labels = [zeros(featuresPerVideo,1) ; ones(featuresPerVideo,1)];
    end
    
end

end

