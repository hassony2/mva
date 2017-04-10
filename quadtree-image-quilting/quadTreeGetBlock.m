function [val,r,c] = quadTreeGetBlock(A, S, dim, padding)
%QUADTREEGETBLOCK Retrieves all blocks from image A
% marked in S as of a given size (dim)
% @returns val : array of size(dim, dim, 3, blockNb)
% @returns r : corresponding array of row indexes
% @returns c : corresponding array of column indexes

M = size(A,1);

[r, c] = find(S == dim);
numBlocks = length(r);

if (numBlocks == 0)
    % Didn't find any blocks.
    val = zeros(dim + 2*padding, dim + 2*padding, 3, 0);
    r = zeros(0,1);
    c = zeros(0,1);
    return;
end

redIm = A(:,:,1);
greenIm = A(:,:,2);
blueIm = A(:,:,3);

val= zeros(dim + 2*padding, dim + 2*padding, 3, numBlocks);


for k = 1:numBlocks
    rows = r(k) : r(k) + dim - 1 + 2*padding;
    cols = c(k) : c(k) + dim - 1 + 2*padding;
    val(:,:,1,k) = redIm(rows, cols); 
    val(:,:,2,k) = greenIm(rows,cols);
    val(:,:,3,k) = blueIm(rows, cols);
end

[r,c] = find(S == dim);
end

