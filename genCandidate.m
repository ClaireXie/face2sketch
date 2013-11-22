function [op, os, odiff, oidx, ip]=genCandidate(ipImg, ipTrain, isTrain, pSize, overlap)
% op: output candidate patches for every image in the training set
% odiff: differnece values for later inference
% oidx: index list;

%searchReg=[20,20];
searchRadius = [10,10];

if (size(ipImg,3)==3)
    ipImg=single(rgb2gray(ipImg));
else
    ipImg=single(ipImg);
end

[r,c]=size(ipImg);

count=1;
counti=0;
countj=0;

nTrainData = size(ipTrain,3);

%for every input patch, find the candidate in each training image
step_row = pSize(1)-overlap(1);
step_col = pSize(2)-overlap(2);
end_row = r-pSize(1)+1;
end_col = c-pSize(2)+1;

nRowPatch = floor(end_row/step_row);
nColPatch = floor(end_col/step_col);
nPatch = nRowPatch * nColPatch;
op= zeros(pSize(1), pSize(2), nTrainData, nPatch);
os= zeros(pSize(1), pSize(2), nTrainData, nPatch);
oidx = zeros(2,2, nPatch);
ip = zeros(pSize(1), pSize(2), nPatch);
odiff = zeros(nRowPatch, nColPatch);


xIndex = zeros(end_row, pSize(1));
yIndex = zeros(end_col, pSize(2));

for i=1:end_row
    xIndex(i,:) = i:i+pSize(1)-1;
end

for j= 1:end_col
    yIndex(j,:) = j:j+pSize(2)-1;
end

for i=1:step_row:end_row
    counti=counti+1;
    for j= 1:step_col:end_col
        %tmp1=ipImg(i:i+pSize(1)-1,j:j+pSize(2)-1);
        tmp1=ipImg(xIndex(i,:),yIndex(j,:));
        rep_tmp1 = repmat(tmp1, [1, 1, nTrainData]);
        countj=countj+1;
        %for k=1:nTrainData
        
        %xRange=max(i-searchRadius,1):min(i+searchRadius,size(ipTrain,1)-pSize(1)+1);
        %yRange=max(j-searchRadius,1):min(j+searchRadius,size(ipTrain,2)-pSize(2)+1);
        
        xStart = max(i-searchRadius(1),1);
        xEnd = min(i+searchRadius(1),size(ipTrain,1)-pSize(1)+1);
        yStart = max(j-searchRadius(2),1);
        yEnd = min(j+searchRadius(2),size(ipTrain,2)-pSize(2)+1);
        nxRange = xEnd - xStart+1;
        nyRange = yEnd - yStart+1;
        
        diff=zeros(nxRange, nyRange, nTrainData);
        for ii=xStart:xEnd
            for jj=yStart:yEnd
                
                tmp2 = ipTrain(xIndex(ii,:),yIndex(jj,:),:);
                dist = (rep_tmp1-tmp2).^2;
                s1 = sum(dist, 1);
                s2 = sum(s1, 2);
                s3 = squeeze(s2);
                diff(ii-xStart+1,jj-yStart+1,:)= s3;
            end
        end
        
        for k=1:nTrainData
            [v,rr]=min(diff(:,:,k),[],1);
            [minv,cc]=min(v);
            rr=rr(cc);
            
            op(:,:,k,count)=ipTrain(xIndex(rr+xStart-1,:),yIndex(cc+yStart-1,:),k);
            os(:,:,k,count)=isTrain(xIndex(rr+xStart-1,:),yIndex(cc+yStart-1,:),k);
            odiff(counti,countj,k)=minv;
        end
        
        % index list
        oidx(:,:,count)=[counti i; countj j];
        ip(:,:,count)=tmp1;
        count=count+1;
    end
    countj=0;
end

