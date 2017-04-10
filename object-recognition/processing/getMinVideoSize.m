function [ minFrameNb, frameNbArray ] = getMinVideoSize( pathToVideoMainFolder )
%GETMINVIDEOSIZE Gets nb of frames of shortest video
[videoNames, videoNb] = getFilesAndFolders(pathToVideoMainFolder);
frameNbArray = zeros(videoNb, 1);
for i=1:videoNb
    [~, frameNbArray(i)] = getFilesAndFolders([pathToVideoMainFolder, '/', videoNames{i}]);
end
minFrameNb = min(frameNbArray);

