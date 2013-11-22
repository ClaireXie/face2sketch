clear;
clc;
close all;

addpath('utils\');
cd utils\UGM;
addpath(genpath(pwd));
cd ..
cd ..

%inlut parameters
ipDir='../Dataset/photos/';
isDir='../Dataset/sketches/';
opFile='trainingData_color.mat';

findCandidate=false;
collectTraining=false;
saveCandidate=false;
display=true;
useMex=true;
maxIter=100;

pSize=[11,11];
overlap=[4, 4];
weight=[2 0.7];

% collect training data
if (collectTraining)
    disp('Generating Training Dataset');
    % color
    createTrainingData_color(ipDir, isDir, opFile, pSize);
    %gray
    createTrainingData(ipDir, isDir, opFile, pSize);
else
    load trainingData_color.mat;
end

%testing
ipDir_test='../Dataset/testing/photos/';
isDir_test='../Dataset/testing/sketches/';

files_ptest = dir([ipDir_test '*.jpg']);
files_stest = dir([isDir_test '*.jpg']);
nFile = numel(files_ptest);


for i=1:nFile
    
    inputFile=[ipDir_test files_ptest(i).name];
    gt=[isDir_test files_stest(i).name];
    
    fprintf('synthesize %s\n',files_ptest(i).name);
    
    ipImg=imread(inputFile);
    
    % find candiates
    if (findCandidate) 
        if (display)
            disp('Generating Candidate Patches');
        end
        % color
        [op, os, odiff, oidx, ip]=genCandidate_color(ipImg, pImg_rgb, sImg, pSize, overlap);
        % gray
        %[op, os, odiff, oidx, ip]=genCandidate2(ipImg, pImg, sImg, pSize, overlap);
        
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
    [ unary pwHorz pwVert edgeEnds] = createGraph( ip, op, os, oidx, odiff, overlap);

    % do inference
    if (display)
        disp('Optimization ...');
    end
    labelling=infer(weight, unary, pwHorz, pwVert, edgeEnds,'trw',useMex, display, maxIter);  %graphcut
    %save('label.mat','labelling');

    % synthesize
    if (display)
        disp('Synthesize the sketch');
    end
    [presult, sresult]=synSketch(labelling, ip, op, os, oidx);

    figure(1); clf; 
    subplot(2,2,1);imshow(uint8(presult));
    title('Synthesized Photo');
    subplot(2,2,2);imshow(ipImg);
    title('Real Photo (GT)');
    subplot(2,2,3);imshow(uint8(sresult));
    title('Synthesized Sketch');
    subplot(2,2,4);imshow(imread(gt));
    title('Sketch by Artist (GT)');
    
    print('-djpeg ',['../exp/syn-',files_ptest(i).name]);
end


