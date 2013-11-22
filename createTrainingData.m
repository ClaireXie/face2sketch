function createTrainingData(ipDir, isDir, opFile, pSize)

addpath('utils\');

%ipDir='../Dataset/photos/';
%isDir='../Dataset/photos/';

files_p = dir([ipDir '*.jpg']);
files_s = dir([isDir '*.jpg']);

for i=1:numel(files_p)
    tmp1=imread([ipDir files_p(i).name]);
    pImg(:,:,i)=single(rgb2gray(tmp1));
    
    intImg(:,:,i) = integralimage(pImg(:,:,i).^2);
    
    %IRs
    for m=1:size(tmp1,1)-pSize(1)
        for n=1:size(tmp1,2)-pSize(2)
            squareSum(m,n,i)=intImg(m,n,i)+intImg(m+pSize(1)-1,n+pSize(2)-1,i)-...
                intImg(m,n+pSize(2)-1,i)-intImg(m+pSize(1)-1,n,i);
        end
    end
    
    tmp2=imread([isDir files_s(i).name]);
    sImg(:,:,i)=single(tmp2);
end

save(opFile, 'pImg', 'squareSum', 'sImg', 'files_p', 'files_s');





