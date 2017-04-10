function [ patches ] = getPatches( Image, patchSize, padding, decal )

%GETPATCHES Extracts square color patches of size patchSize from image with an
%           overlap 

%       @params Image : input image
%       @params patchSize : size in pixels of the square extracted patches 
%       @params decal : step between two neighbour patches
%       No decal : decal = patchSize
%       @params padding : additional pixels extracted on the side
%       @return patches array of size patchSize*patchSize*3*numberOfPatches
%       patches(:,:,:,i) gets us the patch number i  

    % size of patches should be augmented with size of paddings on each
    % side
    patchSize = patchSize + 2*padding;
    if(not(exist('decal', 'var')))
        decal = patchSize;
    end
    assert(decal>0, 'Decal should necessarily be positive, otherwise infinit number of patches ! ');
    imageSizeRow = size(Image,1);
    patchLineNbRow = floor((imageSizeRow-patchSize)/decal)+1;
    imageSizeCol = size(Image,2);
    patchLineNbCol = floor((imageSizeCol-patchSize)/decal)+1;
    patchNb = patchLineNbRow*patchLineNbCol;
    
    patches = -1 * ones( patchSize, patchSize, 3, patchNb);
    patchIdRow = 1:decal:imageSizeRow;
    patchIdCol = 1:decal:imageSizeCol;
    % fill array with extracted patches
    for i=1:patchLineNbRow
        patchIdx = patchIdRow(i);
        for j=1:patchLineNbCol
            patchIdy = patchIdCol(j);
            patches(:,:,:,j+(i-1)*patchLineNbCol) = Image(patchIdx:(patchIdx+patchSize-1), patchIdy:(patchIdy+patchSize-1), :);
        end
    end
    disp('patch number');
    disp(patchNb);
end

