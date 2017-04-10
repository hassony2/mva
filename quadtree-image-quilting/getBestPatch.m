function [ patch, normDist, fail, patchIdQuadtree] = getBestPatch( currentBlock, currentRow, currentCol, patches, vectorType, patchIdQuadtree, padding)
%GETBESTPATCH Retrieves nearest neighbour patch
% @return fail : 1 if did not manage to find neirest neighbor, 0 otherwise
% @return patch : image color patch of same size as currentBlock
% @return normDist : distance to selected patch
    lambda = 4; % how much the presence of close-by blocks is penalized
    fail = 0;
    blockSize = size(currentBlock, 2);
    blockSizeWithoutPadding = blockSize - 2*padding;

    formatPatches = reshape(patches, blockSize^2*3, size(patches,4));
    formatKnnBlocks = double(transpose(formatPatches));

    formatBlock = imageToVec(currentBlock, vectorType);
    bestMatchNb = 10;
    [IDX,D] = knnsearch( formatKnnBlocks,  double(formatBlock), 'k', bestMatchNb);
    obtainedNb = size(IDX,2);
    normDists = D./(blockSize^2);
    if(obtainedNb<bestMatchNb)
        fail =1;
    end
    errorResults = zeros(1,bestMatchNb);
    for matchIndex=1:bestMatchNb
        currentLabel = IDX(matchIndex);
        [nearestIdRow, nearestIdCol] = find(patchIdQuadtree==currentLabel);
        previousPatchNb = length(nearestIdRow);
        if previousPatchNb > 0
            distToPrevious = Inf*ones(1, previousPatchNb);
            % find Minimal distance to previous block with same label
            for previousPatchIndex=1:previousPatchNb
                distToPrevious = sqrt(   (nearestIdRow(previousPatchIndex)- currentRow)^2 + ...
                    (nearestIdCol(previousPatchIndex)- currentCol)^2);
            end
            minVal = min(distToPrevious);
            errorResults(matchIndex) = lambda / (minVal/blockSizeWithoutPadding) + normDists(matchIndex);
        else
            errorResults(matchIndex) = normDists(matchIndex);
        end
    end
    [normDist, pickedMatchIdx] = min(errorResults);
    pickedLabel = IDX(pickedMatchIdx);
    patchIdQuadtree(currentRow, currentCol) = pickedLabel;
    patch = vecToImage(formatKnnBlocks(pickedLabel,:), vectorType);

end

