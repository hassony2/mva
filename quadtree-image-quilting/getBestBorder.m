function [ resultBorder ] = getBestBorder( overlap1, overlap2 )
%GETBESTBORDER takes two overlaps and returns a merge of the two
%     assert(min(min(overlap1(:,:,1))) >=0, 'first image input of getBestBorder should not contain negative values');
%     assert(min(min(overlap2(:,:,1))) >=0, 'second image input of getBestBorder should not contain negative values');
    
    [size1ov1, size2ov1, size3ov1] = size(overlap1);
    [size1ov2, size2ov2, size3ov2] = size(overlap2);
    assert(size3ov1==3&&size3ov2==3, 'overlaps should have 3 color channels')
    assert(size1ov1==size1ov2&&size2ov1==size2ov2, 'overlaps should be of same size')
    if (size2ov1>=size1ov1)
        turnedPatch = true;
        tileSize = size2ov1;
        overlapSize = size1ov1;
        overlap1 = permute(overlap1, [2 1 3]);
        overlap2 = permute(overlap2, [2 1 3]);
    else
        turnedPatch = false;
        tileSize = size1ov1;
        overlapSize = size2ov1;
    end
    
    borderError = sum((overlap1-overlap2).^2,3);
    cumulativeError = zeros(tileSize,overlapSize);
    path = zeros(tileSize,overlapSize);

    resultBorder = overlap1;
    cumulativeError(tileSize, :) = borderError(tileSize,:);
    for k = tileSize-1:-1:1
      for j = 1:overlapSize
          % min max insures l is not out of bounds of border
          index =  max(1,j-1):min(overlapSize,j+1);
          [cumulativeError(k,j), temp_index] = min( cumulativeError(k+1,index));
          cumulativeError(k,j) = cumulativeError(k,j) + borderError(k,j);
          path(k,j) = index(temp_index);
      end
    end
    minimumErrorPath = zeros(1,tileSize);

    [temp,minimumErrorPath(1)] = min(cumulativeError(1,:));

    for k=2:tileSize
      minimumErrorPath(k) = path(k-1,minimumErrorPath(k-1));
    end

    for k = 1:tileSize
      resultBorder(k,minimumErrorPath(k)+1:overlapSize,:) = overlap2(k,minimumErrorPath(k)+1:overlapSize,:);
    end
    if (turnedPatch==true)
        resultBorder = permute(resultBorder, [2 1 3]);
    end
end

