%%
im = imread('512/vangogh-nuit.jpg');
figure(2);
imshow(im);
%%
overlapSize = 3;
tileSize = 50;
overlap1 = im(1:tileSize,1:overlapSize,:);
overlap2 = im(1:tileSize, overlapSize+1:2*overlapSize,:);
borderError = sum((overlap1-overlap2).^2,3);
cumulativeError = zeros(tileSize,overlapSize);
path = zeros(tileSize,overlapSize);

resultBorder = overlap1;
%%
cumulativeError(tileSize, :) = borderError(tileSize,:);
%%
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
%%
figure(1)
imshow(resultBorder);
figure(2);
imshow(overlap1);
figure(3);
imshow(overlap2);

%%
dim = 10;
M = size(im,1);
rows = (0:dim-1)';
cols = 0:M:(dim-1)*M;
rows = rows(:,ones(1,dim));
cols = cols(ones(dim,1),:);
ind = rows + cols;
ind = bsxfun(@plus, ind(:), Sind');

redIm = A(:,:,1);
greenIm = A(:,:,2);
blueIm = A(:,:,3);

%% 
[val,r,c] = quadTreeGetBlock(A, S, 64, 2);
imshow(val(:,:,:,1));
disp(size(val));