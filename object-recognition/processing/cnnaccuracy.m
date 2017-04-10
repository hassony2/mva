%% Get name of files and folders in directoy
[content, contentSize] = getFilesAndFolders('D:/Cours-MVA/ObjRecProjet/ArrowDataAll');

%%% Get min number of files in subdirectories of a directory
%[minFrameNb, frameNbArray] = getMinVideoSize( 'D:/Cours-MVA/ObjRecProjet/ArrowDataAll')

%% info to create test file with forward and backward (fb) examples for each spatio-temporal cube
testNames = {'B1U5XS34QmUuI','B1X6jprOZ29wY','B1Y2KN-ZgfZAM','B2ADMcXAQCzo0','B4X6jprOZ29wY','B501TL9bUWr6I','F_0-ByBCf1biM','F_05gGCvIopwE','F_5f8rm','F_mDI','F_8973s_nv62E','F_D3ylhYOOuzk','F_FaAjPRKXXv0','F_JQRRnAhmB58','F_PosKL3to6l8','F_SXIzyO_5MFI','F_WeI44K6kCRU','F_WzdTXenuzCE','F__18hsqaDrHs','F__aAMwBO1Tco','F_aDEecz10DnY','F_aqvxyejK0MQ','F_dP15zlyra3c','F_ebcfFg2ihYw','F_fFVT_CtL62M','F_kWetGqX9uFc','F_l87MRRjpkxM','F_nUiTNySs1Lk','F_oB2W0HIgpHg','F_raCFAL5CZEU','F_rcp4eckcBoU','F_rpzY8gP_jkQ','F_tfMMAwlD7gs','F_wNeoWLEtQjI','F_wQS3ADyLsUk','F_zdwQBU4QzTw'}
mainFolder = 'D:/remote-results/youtube-reduce/total';
testCount = buildTestFb(  mainFolder, testNames, 'test-fb-new.txt' );

%% Remark : the first proba value in the file is for the 0 label
% fid = fopen('results-1000-it-test.txt','rt');
fid = fopen('results-1000-it-train.txt','rt');
% fid = fopen('results-2600-it-test.txt','rt');
% fid = fopen('results-2600-it-train.txt','rt');
tmp = textscan(fid, '%.7f');
it1000results = tmp{1};
fullResultLength = length(it1000results);
fclose(fid);
class1pred = -1*ones(fullResultLength/2, 1);

%% Pre process class probas from file
for i=1:fullResultLength
    if mod(i,2)==0
        class1pred((i)/2)=it1000results(i);
    end
end
backwardResults =-1*ones(fullResultLength/4,1);
forwardResults = -1*ones(fullResultLength/4,1);

for i=1:fullResultLength/2
    if mod(i,2)==1
        backwardResults((i+1)/2)=class1pred(i);
    else
        forwardResults((i)/2)=class1pred(i);
    end
end
%% Determine per-video accuracy
videoNb = length(forwardResults)/10;
predictionsOnVideos = -1*ones(videoNb,1);
for i=1:videoNb
     if (sum(forwardResults((i-1)*10 + 1:i*10)-backwardResults((i-1)*10 + 1:i*10))>0)
        predictionsOnVideos(i) = 1;
     else 
        predictionsOnVideos(i) = 0;
     end
end

accuracyPerVideo = sum(predictionsOnVideos)/videoNb
accuracyPerFeature = sum((forwardResults-backwardResults)>0)/length(forwardResults)