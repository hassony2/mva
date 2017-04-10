function [ counter] = buildTestFb(  nameOfInputFolder, testNames, nameOfTestFile )
%BUILDTESTFB Summary of this function goes here
featuresPerVideo = 10;
spacing = 16;
[imageFolders, videoNb] = extractVideoNames(nameOfInputFolder);
res = imageFolders;
testFileID = fopen(nameOfTestFile, 'w');
counter = 0;

for i=1:videoNb
    currentSubDir = imageFolders{i};
    if (ismember(['F',currentSubDir], testNames))
        counter = counter + 1;
        inputSubFolder = [nameOfInputFolder, '/F', currentSubDir];
        [~, frameNb] = getFilesAndFolders(inputSubFolder);
        % Print lines to test file
        maxFrame = frameNb - spacing;
        for j=1:featuresPerVideo
            firstFrame = randi([1 maxFrame]);
            fprintf(testFileID, [nameOfInputFolder, '/B%s %d %s \n'], currentSubDir, firstFrame, '0');
            fprintf(testFileID, [nameOfInputFolder, '/F%s %d %s \n'], currentSubDir, frameNb + 1 - firstFrame, '1');
        end
    end
end

fclose(testFileID);
