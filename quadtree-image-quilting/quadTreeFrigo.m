function [ S, newImage, patches ] = quadTreeFrigo( Image, styleImage, threshold, minDim, maxDim, padding, decal, vectorType )
%QUADTREE Computes quadTree decomposition of image
%   @params styleImage : image from which the initial Image is recomposed
%   @params patchOverlap : length of overlap in patches taken from
%   styleImage
%   @params threshold : max tolerance value withou split
    if(not(exist('minDim', 'var')))
        minDim = 4;
    end
    if(not(exist('maxDim', 'var')))
        maxDim = min(size(Image, 1), size(styleImage, 1));
    end

    [M,N,color] = size(Image);
    assert(M==N, 'Should receive square image');
    assert(color==3, 'Did not get colored image');
    newImage = -1*ones(M,M,3);
    % test that size of image without padding is a power of two 
    % (and therefore inner part supports quadtree structure)
    binaryStringSearch = strfind(string(dec2bin(M-2*padding)), '1');
    assert(length(binaryStringSearch)==1, '(imageSize - 2 * padding) should be a power of two');
    
    S = zeros(M - 2*padding, M - 2*padding);
    % Initialize blocks
    S(1:maxDim:M-2*padding, 1:maxDim:M-2*padding) = maxDim;

    dim = maxDim;
    while (dim > minDim)
        % Find all the blocks at the current size.
        [blockValues, r, c] = quadTreeGetBlock(Image, S, dim, padding);
        Sind = r + size(S,1)*(c-1); %absolute indexes
        if (isempty(Sind))
            % Done!
            break;
        end
        % keeps track weather patches from style image have already been
        % retrieved at this dim
        computedPatches = false;
        % fill new image
        currentBlockNb = size(r,1);
        stdDevs = zeros(1, currentBlockNb);
        dists = zeros(1, currentBlockNb);
        patches = getPatches(styleImage, dim, padding, decal);
        for k=1:currentBlockNb
            currentBlock = blockValues(:,:,:,k);
            stdDev = illuminationStd(currentBlock);
            stdDevs(k)=stdDev;
            replaceImage = false;
            [ patch, normDist, fail ] = getBestPatch( currentBlock, patches, vectorType );
            dists(k)=normDist;
            % patches are computed only if variance test passes for a block
            if (stdDev + normDist < threshold )              
                if(not(computedPatches))
                    replaceImage = true;
                end
            end
            tileSize = dim + 2*padding - 1;
            if(replaceImage)
                % merge upper border if needed
                if (  newImage(r(k), c(k) + floor((2*padding+dim)/2)) >= 0  )     
                   newImage(r(k):r(k) + 2*padding - 1,c(k):c(k) + tileSize, : ) = ...
                       getBestBorder(newImage(r(k):r(k) + 2*padding - 1 ,c(k):c(k) + tileSize, :),patch(1:2*padding, 1:tileSize + 1, :));
                else
                    newImage(r(k):r(k)+ 2*padding - 1 ,c(k):c(k) + tileSize, : ) = patch(1:2*padding, 1:tileSize + 1, :);
                end
                % merge lower border if needed
                if (  newImage(r(k)+ dim - 1 + 2*padding, c(k)  + floor((2*padding+dim)/2)) >= 0  )
                    newImage(r(k) + dim : r(k)+dim + 2*padding - 1,c(k):c(k) + tileSize, : ) = ...
                        getBestBorder( newImage(r(k) + dim : r(k)+dim + 2*padding - 1,c(k):c(k) + tileSize, : ) , patch(end - 2*padding + 1:end, 1 : tileSize + 1, :));
                else
                    newImage(r(k) + dim : r(k)+dim + 2*padding - 1,c(k):c(k) + tileSize, : ) = patch(end - 2*padding + 1:end, 1 : tileSize + 1, :);
                end
                % merge right border if needed
                if (  newImage(r(k) + floor((2*padding+dim)/2) , c(k) + dim - 1 + 2*padding) >= 0  )        
                     newImage(r(k):r(k) + tileSize, c(k) + dim: c(k) + 2*padding + dim - 1, : ) = ...
                        getBestBorder( newImage(r(k):r(k) + tileSize, c(k) + dim: c(k) + 2*padding + dim - 1, : ), patch(1:1 + tileSize, end - 2*padding + 1:end,:));
                else
                    newImage(r(k):r(k) + tileSize, c(k) + dim: c(k) + 2*padding + dim - 1, : ) = patch(1:1 + tileSize, end - 2*padding + 1:end,:);
                end
                % merge left border if needed
                if (  newImage(r(k) + floor((2*padding+dim)/2), c(k)) >= 0  )
                    newImage(r(k):r(k) + tileSize,c(k):c(k)+2*padding - 1, : ) = ...
                        getBestBorder(newImage(r(k):r(k) + tileSize,c(k):c(k)+2*padding - 1 , :), patch(1:tileSize + 1, 1:2*padding, :));
                else
                    newImage(r(k):r(k) + tileSize,c(k):c(k)+2*padding - 1, : ) = patch(1:tileSize + 1, 1:2*padding, :);
                end        
                newImage(r(k) + 2 * padding : r(k) + dim - 1 , c(k) + 2*padding : c(k) + dim - 1, :) = patch(2*padding + 1: dim , 2*padding + 1 : dim, :);

            else
                currentRow = r(k);
                currentCol = c(k);
                S(currentRow, currentCol) = dim/2;
                if (currentRow + dim/2<M-2*padding)
                    S(currentRow+dim/2, currentCol) = dim/2;
                end
                if (currentCol + dim/2<M-2*padding)
                    S(currentRow, currentCol + dim/2) = dim/2;
                end
                if ((currentCol + dim/2<M-2*padding)&&(currentRow + dim/2<M-2*padding))
                    S(currentRow+dim/2, currentCol + dim/2) = dim/2;
                end
            end
        end

        disp(dim);
        disp('Mean of std');
        disp(mean(stdDevs));
        disp('Max dists to patches');
        disp(max(dists));
        
        dim = dim/2;
    end

    % Fill last dim patches
    [blockValues, r, c] = quadTreeGetBlock(Image, S, dim, padding);
    blockNb = size(blockValues,4);
    patches = getPatches(styleImage, dim, padding, decal);
    tileSize = dim + 2*padding - 1;
    for k=1:blockNb
        currentBlock = blockValues(:,:,:,k);
        [ patch, normDist, fail ] = getBestPatch( currentBlock, patches, vectorType );
        % merge upper border if needed
        if (  newImage(r(k), c(k) + floor((2*padding+dim)/2)) >= 0  )     
           newImage(r(k):r(k) + 2*padding - 1,c(k):c(k) + tileSize, : ) = ...
               getBestBorder(newImage(r(k):r(k) + 2*padding - 1 ,c(k):c(k) + tileSize, :),patch(1:2*padding, 1:tileSize + 1, :));
        else
            newImage(r(k):r(k)+ 2*padding - 1 ,c(k):c(k) + tileSize, : ) = patch(1:2*padding, 1:tileSize + 1, :);
        end
        % merge lower border if needed
        if (  newImage(r(k)+ dim - 1 + 2*padding, c(k)  + floor((2*padding+dim)/2)) >= 0  )
            newImage(r(k) + dim : r(k)+dim + 2*padding - 1,c(k):c(k) + tileSize, : ) = ...
                getBestBorder( newImage(r(k) + dim : r(k)+dim + 2*padding - 1,c(k):c(k) + tileSize, : ) , patch(end - 2*padding + 1:end, 1 : tileSize + 1, :));
        else
            newImage(r(k) + dim : r(k)+dim + 2*padding - 1,c(k):c(k) + tileSize, : ) = patch(end - 2*padding + 1:end, 1 : tileSize + 1, :);
        end
        % merge right border if needed
        if (  newImage(r(k) + floor((2*padding+dim)/2) , c(k) + dim - 1 + 2*padding) >= 0  )        
             newImage(r(k):r(k) + tileSize, c(k) + dim: c(k) + 2*padding + dim - 1, : ) = ...
                getBestBorder( newImage(r(k):r(k) + tileSize, c(k) + dim: c(k) + 2*padding + dim - 1, : ), patch(1:1 + tileSize, end - 2*padding + 1:end,:));
        else
            newImage(r(k):r(k) + tileSize, c(k) + dim: c(k) + 2*padding + dim - 1, : ) = patch(1:1 + tileSize, end - 2*padding + 1:end,:);
        end
        % merge left border if needed
        if (  newImage(r(k) + floor((2*padding+dim)/2), c(k)) >= 0  )
            newImage(r(k):r(k) + tileSize,c(k):c(k)+2*padding - 1, : ) = ...
                getBestBorder(newImage(r(k):r(k) + tileSize,c(k):c(k)+2*padding - 1 , :), patch(1:tileSize + 1, 1:2*padding, :));
        else
            newImage(r(k):r(k) + tileSize,c(k):c(k)+2*padding - 1, : ) = patch(1:tileSize + 1, 1:2*padding, :);
        end        
        newImage(r(k) + 2 * padding : r(k) + dim - 1 , c(k) + 2*padding : c(k) + dim - 1, :) = patch(2*padding + 1: dim , 2*padding + 1 : dim, :);
    end
%     S = sparse(S);
end
