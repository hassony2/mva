function [ vecIm ] = vecToImage( imVector, vectorType )
%VECTOIMAGE Recomposes a square image from vector by unstacking colors and
%columns 

    vecSize = size(imVector, 2);
    imSize = sqrt(vecSize/3);
    vecImRgb = reshape(imVector, imSize, imSize, 3);
    if (vectorType == 'rgb')
        vecIm = vecImRgb;
    end
end

