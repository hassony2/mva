%% Load style and content images 

% imcontent = imread('not-resized/tubingen.jpg');
imcontent = imread('not-resized/fuji-original.jpg');
% imstyle = imread('not-resized/starry_night.jpg');
imstyle = imread('not-resized/impressionist-original.jpg');
imcontent = imresize(imcontent, 1.2);
imstyle = imresize(imstyle, 1.5);
minDim = 4;
maxDim = 64;
varThreshold =15;
distThreshold = 5;
decal = 32;
vectorType = 'rgb';

%% Prepare content Image
pow2Size = 512;
padding = 2;
myImSize = pow2Size + 2*padding;

imcontentResized = ones(myImSize, myImSize,3);
imcontentResized(1:myImSize, 1:myImSize,:) = imcontent(1:myImSize, 1:myImSize, :);
%% Split and Quilt !
tic
[S, newImage, patches] = quadTree(imcontentResized, imstyle, varThreshold, distThreshold, minDim, maxDim, padding, decal, vectorType);
toc
%% Display resulting image
figure(12);
imshow(uint8(newImage))

%% Display splits on original image
im = imcontentResized;
blocks = repmat(uint8(0), [size(S), 3]);
squareSize = 512;
padding = 1;
splitIm = im(padding: squareSize+ padding - 1, padding: squareSize + padding - 1, :);
for dim = [256 128 64 32 16 8 4 2 1]
  [vals, r, c] = quadTreeGetBlock(splitIm, S, dim, 0);
  numblocks = length(find(S==dim));    
  if (numblocks>0)
      for i=1:numblocks        
        blocks(r(i)+1:r(i)-1+dim,c(i)+1:c(i)-1+dim,:) = im(r(i)+1:r(i)-1+dim,c(i)+1:c(i)-1+dim,:);
      end 
  end
end
figure(10);


imshow(blocks);