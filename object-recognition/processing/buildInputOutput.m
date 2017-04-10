function [res, testSample] = buildInputOutput(nameOfInputFile, nameOfOutputFile, nameOfInputFolder, nameOfOutputFolder,...
    gap, testRatio, nameOfTestFile)

% BUILDINPUTOUTPUT Creates train test files for video-caffe c3d training
% Each video is present (in direct and reverse order) either in the train 
% test or in the test set (network never sees the test videos during training)
% files are written to nameOfInputFile and nameOfTestFike
% To use for feauture extraction set testRation to 0 and relevant files are
% nameOfInputFile and nameOfOutputFile

% @param nameOfInputFile : example : 'input.txt'
% @param nameOfOutputFile : example : 'output.txt'
% @param nameOfInputFolder : main folder that contains the folders with the
% frames
% @param nameOfOutputFolder : main folder that contains the folders that
% @params gap : number of frames between two consecutive features
% @params testRatio : % of videos that are considered test videos
% @params testInputFile : examples 'test-input.txt' 

% will receive the outputs
spacing = 16;
[imageFolders, videoNb] = extractVideoNames(nameOfInputFolder);
res = imageFolders;
inputFileID = fopen(nameOfInputFile, 'w');
outputFileID = fopen(nameOfOutputFile, 'w');
testFileID = fopen(nameOfTestFile, 'w');


testSample = randperm(videoNb, floor(videoNb*testRatio));

for i=1:videoNb
    currentSubDir = imageFolders{i};
    inputSubFolder = [nameOfInputFolder, '/F', currentSubDir];
    [~, frameNb] = getFilesAndFolders(inputSubFolder);
    stringLabel = '0';
    % Print lines to test file
    if any(i==testSample)
        for j=1:frameNb - spacing
            if(mod(j,gap) == 1)
                fprintf(testFileID, [nameOfInputFolder, '/B%s %d %s \n'], currentSubDir, j, '0');
                fprintf(testFileID, [nameOfInputFolder, '/F%s %d %s \n'], currentSubDir, j, '1');
            end
        end
    % Print lines to train file
    else
        for j=1:frameNb - spacing
            if(mod(j,gap) == 1)
                outputSubPrefixF = [nameOfOutputFolder,'/F',currentSubDir, sprintf('/%04d\n', j)];
                outputSubPrefixB = [nameOfOutputFolder,'/B',currentSubDir, sprintf('/%04d\n', j)];
                fprintf(inputFileID,[nameOfInputFolder, '/B%s %d %s \n'], currentSubDir, j, '0');
                fprintf(inputFileID,[nameOfInputFolder, '/F%s %d %s \n'], currentSubDir, j, '1');
                fprintf(outputFileID, outputSubPrefixB);
                fprintf(outputFileID, outputSubPrefixF);
            end
        end
    end
end

fclose(outputFileID);
fclose(inputFileID);
fclose(testFileID);
