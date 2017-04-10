function [ imVec ] = imageToVec( Image, vectorType )
%GETIMAGEVECTOR Flattens a square image to a vector by stacking columns and
%colors
    if (vectorType == 'rgb')
        imVec = reshape(Image, 1, size(Image,1)^2*3);
    end
end

