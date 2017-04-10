function res = buildInputOutputSplitVideo(nameOfInputFile, nameOfOutputFile, nameOfInputFolder, nameOfOutputFolder,...
    gap, testRatio, nameOfTestFile)

% BUILDINPUTOUTPUTSPLITVIDEO Creates train test files for video-caffe c3d training
% Preserves initial proportion of forward videos in test and training samples
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
[imageFolders, videoNb] = getFilesAndFolders(nameOfInputFolder);
inputFileID = fopen(nameOfInputFile, 'w');
outputFileID = fopen(nameOfOutputFile, 'w');
testFileID = fopen(nameOfTestFile, 'w');

labels = zeros(videoNb, 1);
for k=1:videoNb
    currentSubDir = imageFolders{k};
    if (currentSubDir(1) == 'F')
            labels(k) = 1;
    else 
            labels(k) = 0;
    end
end
testSample = randperm(videoNb, floor(videoNb*testRatio));
numit = 0; 

initialProportion = sum(labels)/size(labels,1);

while (sum(labels(testSample)) ~= floor(videoNb*testRatio*initialProportion)) % Proportion of positives should stay 50% in test set 
    testSample = randperm(videoNb, floor(videoNb*testRatio));
    numit = numit + 1;
end
for i=1:videoNb
    currentSubDir = imageFolders{i};
    inputSubFolder = [nameOfInputFolder, '/', currentSubDir];
    [~, frameNb] = getFilesAndFolders(inputSubFolder);

    label = labels(i);
    stringLabel = '0';
    if (label == 1)
        stringLabel = '1';
    end
    % Print lines to test file
    if any(i==testSample)
        for j=1:frameNb - spacing
            if(mod(j,gap) == 1)
                fprintf(testFileID, [nameOfInputFolder, '/%s %d %s \n'], currentSubDir, j, stringLabel);
            end
        end
    % Print lines to train file
    else
        for j=1:frameNb - spacing
            if(mod(j,gap) == 1)
                outputSubPrefix = [nameOfOutputFolder,'/',currentSubDir, sprintf('/%04d\n', j)];
                fprintf(inputFileID,[nameOfInputFolder, '/%s %d %s \n'], currentSubDir, j, stringLabel);
                fprintf(outputFileID, outputSubPrefix);
            end
        end
    end
end

fclose(outputFileID);
fclose(inputFileID);
fclose(testFileID);

res = listing;