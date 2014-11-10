clear;
clc;
close all;

addpath('utils/');
cd utils/UGM;
addpath(genpath(pwd));
cd ..
cd ..

%--Change the follwing parameters according to your folder structure--%
%========================================%
%training dir
ipDir = '../Dataset/photos/';
isDir = '../Dataset/sketches/';
% pre-training data (NOT available online)
% created by running createTrainingData_color(...)
opFile = 'trainingData_color.mat';

%testing dir
ipDir_test = '../Dataset/testing/photos/';
isDir_test = '../Dataset/testing/sketches/';

%saved result dir
outputDir = '../exp/syn-';

% optimization methods
method = 'lbp';
% opptions:
% 1. trw: tree-reweighted max-product message passing
% mex file provided under WINDOWS environment ONLY
% You will need to compile this yourself if you wish to run it on other operating systems. 
% http://pub.ist.ac.at/~vnk/papers/TRW-S.html
% 2. lbp: loopy-bp
% 3. icm
%========================================%


findCandidate = true;
collectTraining = true;
saveCandidate = false;
display = true;
useMex = true;
maxIter = 100;
useColorFeature = true;

pSize = [11,11];
overlap = [4, 4];
weight = [2 0.7];

% collect training data
if (collectTraining)
    disp('Generating Training Dataset');
    % color
    if (useColorFeature)
        [pImg, pImg_rgb, sImg] = createTrainingData_color(ipDir, isDir, opFile, pSize);
    %gray
    else 
        %createTrainingData(ipDir, isDir, opFile, pSize);
    end
else
    load trainingData_color.mat;
end


files_ptest = dir([ipDir_test '*.jpg']);
files_stest = dir([isDir_test '*.jpg']);
nFile = numel(files_ptest);


for i = 1:nFile
    
    inputFile = [ipDir_test files_ptest(i).name];
    gt = [isDir_test files_stest(i).name];
    
    fprintf('synthesize %s\n',files_ptest(i).name);
    
    ipImg = imread(inputFile);
    
    % find candiates
    if (findCandidate) 
        if (display)
            disp('Generating Candidate Patches');
        end
        % color
        if (useColorFeature)
            [op, os, odiff, oidx, ip] = genCandidate_color(ipImg, pImg_rgb, sImg, pSize, overlap);
        % gray
        else
            %[op, os, odiff, oidx, ip] = genCandidate2(ipImg, pImg, sImg, pSize, overlap);
        end
        
        if (saveCandidate)
            save('candidate.mat','op','os','odiff','oidx','ip');
        end
    else 
        load candidate.mat;
    end

    % creat graph
    if (display)
        fprintf(1,'Creating unary and pairwise potentials\n');
    end
    [unary pwHorz pwVert edgeEnds] = createGraph( ip, op, os, oidx, odiff, overlap);

    % do inference
    if (display)
        disp('Optimization ...');
    end
    labelling = infer(weight, unary, pwHorz, pwVert, edgeEnds,'lbp',useMex, display, maxIter);  %graphcut

    % synthesize
    if (display)
        disp('Synthesize the sketch');
    end
    [presult, sresult] = synSketch(labelling, ip, op, os, oidx);

    figure(1); clf; 
    subplot(2,2,1);imshow(uint8(presult));
    title('Synthesized Photo');
    subplot(2,2,2);imshow(ipImg);
    title('Real Photo (GT)');
    subplot(2,2,3);imshow(uint8(sresult));
    title('Synthesized Sketch');
    subplot(2,2,4);imshow(imread(gt));
    title('Sketch by Artist (GT)');
    
    print('-djpeg ',[outputDir,files_ptest(i).name]);
end


