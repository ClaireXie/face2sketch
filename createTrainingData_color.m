function [pImg, pImg_rgb, sImg] = ... 
    createTrainingData_color(ipDir, isDir, opFile, pSize)

addpath('utils/');

%ipDir='../Dataset/photos/';
%isDir='../Dataset/photos/';

files_p = dir([ipDir '*.jpg']);
files_s = dir([isDir '*.jpg']);

%Find the nubmer files and the size of images
tmp1=imread([ipDir files_p(1).name]);
nFile = numel(files_p);
[nRow, nCol, nCh] = size(tmp1);

%initialize matrix for data
pImg_luv = zeros(nRow,nCol,nCh, nFile);
pImg_rgb = zeros(nRow,nCol,nCh, nFile);

pImg = zeros(nRow,nCol,nFile);
sImg = zeros(nRow,nCol,nFile);
intImg = zeros(nRow,nCol,nFile);
nRowPatch = nRow-pSize(1);
nColPatch = nCol- pSize(2);
squareSum = zeros(nRowPatch, nColPatch, nFile);

for i=1:nFile
    tmp1=imread([ipDir files_p(i).name]);
    pImg(:,:,i)=single(rgb2gray(tmp1));

    pImg_rgb(:,:,:,i)= tmp1;
    pImg_luv(:,:,:,i)= rgb2luv(tmp1);
    intImg(:,:,i) = integralimage(pImg(:,:,i).^2);
    
    %IRs
    for m=1:nRowPatch
        for n=1:nColPatch
            
            squareSum(m,n,i)=intImg(m,n,i)+intImg(m+pSize(1)-1,n+pSize(2)-1,i)-intImg(m,n+pSize(2)-1,i)-intImg(m+pSize(1)-1,n,i);
        end
    end
    
    tmp2=imread([isDir files_s(i).name]);
    sImg(:,:,i)=single(tmp2);
end

save(opFile, 'pImg', 'pImg_rgb', 'pImg_luv', 'squareSum', 'sImg', 'files_p', 'files_s');
