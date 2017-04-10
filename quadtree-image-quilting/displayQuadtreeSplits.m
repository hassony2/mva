
imstyle = imread('final-art/first-step.jpg');
imc = imread('512/sophie.jpg');
%% Set settings for separate decision
varThreshold = 10;
distThreshold = 5;
padding = 0;
[S, newImage, patches] = quadTree(imc, imstyle , varThreshold, distThreshold, 8, 64, padding, 64, vectorType);
%% Set settings for entangled decision
totThreshold = varThreshold + distThreshold;
totThreshold = 12;
padding = 0;
[S, newImage, patches] = quadTreeFrigo(imc, imstyle , totThreshold, 8, 128, padding, 32, vectorType);
%%
imshow(uint8(newImage));
%% display splits
im = imc;
blocks = repmat(uint8(0), [size(S), 3]);
squareSize = 512;
padding = 1;
splitIm = im(padding: squareSize+ padding - 1, padding: squareSize + padding - 1, :);
for dim = [256 128 64 32 16 8 4 2 1];
  [vals, r, c] = quadTreeGetBlock(splitIm, S, dim, 0);
  numblocks = length(find(S==dim));    
  if (numblocks>0)
%       values = repmat(uint8(255),[dim dim numblocks]);
      for i=1:numblocks        
%         values(2:dim,2:dim,i) = vals(2:dim,2:dim,i);
        blocks(r(i)+1:r(i)-1+dim,c(i)+1:c(i)-1+dim,:) = im(r(i)+1:r(i)-1+dim,c(i)+1:c(i)-1+dim,:);
      end 
  end
end
% blocks(end,1:end) = 1;
% blocks(1:end,end) = 1;
figure(10);


imshow(blocks);