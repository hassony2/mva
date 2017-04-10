show_images = 1; % 1 if you want to see the original images, 0 otherwise

%% =========== STYLE IMAGES ==============
style = struct;

% Image 1
im1 = imread('final-art/blum.jpg');
im1 = imresize(im1, .4);
if(show_images)
    figure(1);
    imshow(im1);
end
%%

% Image 2
im2 = imread('final-art/fritz.jpg');
im2 = im2(150:2000,150:3000, :); % remove frame
im2 = imresize(im2, .3);
if(show_images)
    figure(2);
    imshow(im2);
end
%%
% Image 3

im3 = imread('final-art/pencil-portrait.jpg');
% im3 = im3(150:2000,150:3000, :); % remove frame
im3 = imresize(im3, .5);
if(show_images)
    figure(3);
    imshow(im3);
end

% Image 4

im4 = imread('final-art/first-step.jpg');

im4 = im4(30:440,40:550,:);
im4 = imresize(im4, 1.3);
if(show_images)
    figure(4);
    imshow(im4);
end

%% Create struct
style(1).image = im1;
style(2).image = im2;
style(3).image = im3;
style(4).image = im4;


%% ============ CONTENT IMAGES ============
content = struct;


pow2Size = 512;
padding = 3;
myImSize = pow2Size + 2*padding;

%% Image 1
imc1 = imread('final-content/great-wall.jpg');

imc1 = imresize(imc1, 0.17);

imc1 = imc1(50:50+myImSize - 1, 1:1+myImSize -1, :);
if(show_images)
    figure(11);
    imshow(imc1);
end
content(1).image = imc1;

%% Image
imc2 = imread('final-content/china-archi.jpg');

imc2 =imresize(imc2, 0.2);
imc2 = imc2(1:1+myImSize - 1, 1:1+myImSize -1, :);
if(show_images)
    figure(12);
    imshow(imc2);
end
content(2).image = imc2;

%% Image 3
imc3 = imread('final-content/houses.jpg');
imc3 =imresize(imc3, 0.15);


imc3 = imc3(1:1+myImSize - 1, 1:1+myImSize -1, :);
if(show_images)
    figure(13);
    imshow(imc3);
end
content(3).image = imc3;

%% Image 4
imc4 = imread('final-content/flower.jpg');
imc4 = imc4(200:end, 800:end, :);
imc4 =imresize(imc4, 0.14);
imc4 = imc4(1:1+myImSize - 1, 1:1+myImSize -1, :);
if(show_images)
    figure(14);
    imshow(imc4);
end
content(4).image = imc4;

%% Settings for quad-quilting

minDim = 8;
maxDim = 64;
varThreshold = 18;
distThreshold = 5;
decal = 32;
vectorType = 'rgb';

%%  ============= Transfer the style ! ==============
totalResultStruct = struct;
for j=1:length(content)
    partialResultStruct = struct;
    imcontent = content(j).image;
    for i=1:length(style)
        imstyle = style(i).image;
        tic;
        [S, newImage, patches] = quadTree(imcontent, imstyle, varThreshold, distThreshold, minDim, maxDim, padding, decal, vectorType);
        toc;
        figure(5);
        imshow(uint8(newImage));
        partialResultStruct(i).image = newImage;
    end
    totalResultStruct(j).images = partialResultStruct;
end
%% Save

save('totalResultStructReg.mat','totalResultStruct');


%% Save images
contentListing = dir('C:\Users\Yana\OneDrive - CentraleSupelec\Cours\MVA\Sparsity\Project\implementation\final-content')
contentFiles = contentListing(3:end);
styleListing = dir('C:\Users\Yana\OneDrive - CentraleSupelec\Cours\MVA\Sparsity\Project\implementation\final-art')
styleFiles = styleListing(3:end);
%%
loadtotalResult = load('totalResultStruct.mat');
totalResultStruct = loadtotalResult.totalResultStruct;
%%
contentLength = length(contentFiles);
styleLength = length(styleFiles);

for j=1:contentLength
    contentName = contentFiles(j).name;
    for i=1:styleLength
       styleName = styleFiles(i).name;
       current = figure;
       imshow(uint8(totalResultStruct(j).images(i).image));
       saveas(current, ['results/',contentName,styleName(1:6), '.jpg']) ;
    end
end
%%
imshow(uint8(totalResultStruct(2).images(2).image))

