function [presult, sresult]=synSketch(labelling, ip, op, os, oidx)

nCh = 3;
count=zeros(250,200);
ptemplate=zeros(250,200, nCh);
stemplate=zeros(250,200);
pSize=[size(ip,1), size(ip,2)];

[nRowPatch, nColPatch] = size(labelling);

for ii=1:nRowPatch   
     for jj=1:nColPatch 
         
        i=jj+(ii-1)*nColPatch;
        k=labelling(ii,jj);

        inx1 = oidx(1,2,i):oidx(1,2,i)+pSize(1)-1;
        inx2 = oidx(2,2,i):oidx(2,2,i)+pSize(2)-1;
        
        ptemplate(inx1,inx2, :) = ptemplate(inx1,inx2,:) + op(:,:,:,k,i);

        stemplate(inx1,inx2)= stemplate(inx1,inx2)+ os(:,:,k,i);

        count(inx1,inx2)= count(inx1, inx2)+1;
    end
end

presult=ptemplate./ repmat(count, [1 1 nCh]);
sresult=stemplate./count;