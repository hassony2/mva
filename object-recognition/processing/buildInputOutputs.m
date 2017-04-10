res = buildInputOutput('train-input.txt', 'train-output.txt', 'D:/Cours-MVA/ObjRecProjet/ArrowDataAll',...
    'D:/to-remote', 4, 0.2, 'test-input.txt');

%% 
[res,nb] = extractVideoNames( 'D:/Cours-MVA/ObjRecProjet/ArrowDataAll');

%%
[res,testSample] = buildInputOutput2('train-input.txt', 'train-output.txt', 'D:/Cours-MVA/ObjRecProjet/ArrowDataAll',...
    'D:/to-remote', 4, 0.2, 'test-input.txt');
%% 
randperm(360, 360*0.2)