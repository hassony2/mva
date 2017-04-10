function [ videos ] = createInverseFolders( pathToFolder )
%CREATEINVERSEFOLDERS Creates folders with reverse-order frames
% Keeps the rights prefix for the files ('F' for forward and 'B' for backwards)

listing = dir(pathToFolder);
videos = listing(3:length(listing)); % remove . and .. from listing
videoNb = length(videos);
for i=1:videoNb
    videoName = videos(i).name;
    newName = videoName;
    if (videoName(1)=='F')
        newName(1) = 'B';
    else 
        newName(1) = 'F';
    end
    pathToNewVideoFolder = [pathToFolder, '/', newName];
    pathToOldVideoFolder = [pathToFolder, '/', videoName];
    mkdir(pathToNewVideoFolder);
    frameListing = dir(pathToOldVideoFolder);
    frames = frameListing(3:length(frameListing)); % remove . and .. from listing
    frameNb = length(frames);
    for j=1:frameNb
        disp([pathToOldVideoFolder, '/image_',sprintf('%04d', j),'.jpg']);
        copyfile([pathToOldVideoFolder, '/image_',sprintf('%04d', j),'.jpg'], [pathToNewVideoFolder, '/image_', sprintf('%04d',frameNb - j + 1), '.jpg']);
    end
end
end

