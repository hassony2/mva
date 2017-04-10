function [ imageFolders, videoNb ] = extractVideoNames( nameOfInputFolder )
%EXTRACT-VIDEO-NAMES Gets the name of the videos without the 'F'/'B' prefix

[imageFolders, videoNb] = getFilesAndFolders(nameOfInputFolder);
for i = 1:videoNb
    s = imageFolders{i};
    imageFolders{i} = s(2:end);
end
imageFolders = unique(imageFolders);
videoNb = length(imageFolders);
end

