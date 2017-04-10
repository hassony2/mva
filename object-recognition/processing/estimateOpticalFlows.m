mainFolder = 'D:/remote-results/youtube-reduce/total';
[videoNames, videoNb] = getFilesAndFolders(mainFolder);
% opticalFlowFarneback
%% 
videoFlowStatistics = struct

%%

for videoIndex=70:videoNb
    currentVideoName =  videoNames{videoIndex};
    [frameNames, frameNb]=getFilesAndFolders([mainFolder, '/', currentVideoName]);
    opticFlow = opticalFlowFarneback;
    averageFlow = zeros(frameNb,1);
    normFlow = zeros(frameNb, 1);
    for frameIndex=1:frameNb
        currentFrameName = frameNames{frameIndex};
        imgRgb = imread([mainFolder, '/', currentVideoName, '/', currentFrameName]);
        img = rgb2gray(imgRgb);
        flow = estimateFlow(opticFlow, img);
%         figure(frameIndex)
%         displayFlowOnImage(imgRgb, flow);
        averageFlow(frameIndex) = mean(mean( flow.Magnitude) );
        normFlow(frameIndex) = norm( flow.Magnitude);
    end
    videoFlowStatistics(videoIndex).averageFlow = averageFlow(2:end);
    videoFlowStatistics(videoIndex).normFlow = normFlow(2:end); 
    videoFlowStatistics(videoIndex).videoName = currentVideoName;
    disp(videoIndex);
end
% 
% figure(1);
% plot(normFlow(2:end))
% figure(2)
% plot(averageFlow(2:end))
%% save and load
%save('videoFlowsStatistics.mat', 'videoFlowStatistics')
videoStats = load('videoFlowsStatistics.mat');
videoStats = videoStats.videoFlowStatistics
%% display flow graphs
nbRow = 4;
nbCol = 4;
nbVideo = nbRow*nbCol;
decal = 100;
ha = tight_subplot(nbRow,nbCol,[.1 .1],[0.1 0.1],[0.1 0.1]);
for videoIndex = decal:decal+nbVideo+1
    axes(ha(videoIndex-decal+1));
    currentFlowAverages = videoStats(videoIndex).averageFlow;
    plot(currentFlowAverages)
    title(videoStats(videoIndex).videoName(1:4))
end