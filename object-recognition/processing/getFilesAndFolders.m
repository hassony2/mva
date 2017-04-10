function [ names, subNb ] = getFilesAndFolders( pathToFolder )
%GETFILESANDFOLDERS Returns list of names of subdirectories and files in
%directory
%   @params fileNb : number of subfiles and folders
%   @params names : cell list of folder names
listing = dir(pathToFolder);
listingNb = length(listing);
subs = listing(3:listingNb); % remove . and .. from listing
subNb = length(subs);
names = cell(subNb,1);
for i=1:subNb
    names{i} = subs(i).name;
end

end

