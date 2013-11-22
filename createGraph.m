function [ unary pwHorz pwVert edgeEnds] = createGraph( inputP, candidatesP, candidatesS, idx, diff, overlap)

%candidates: pSize*pSize*channel*c*count
c = size(candidatesP,4);   %3
num = size(candidatesP,5); %4
pSize = [size(inputP,1),size(inputP,2)];
gSize = [size(diff,1),size(diff,2)];

unary = zeros(gSize(1),gSize(2),c);
unary = sqrt(diff);

pwHorz = zeros(gSize(1),gSize(2)-1, c*c);
pwVert = zeros(gSize(1)-1,gSize(2), c*c);

enum_h=1;
enum_v=1;

for n=1:num
    
    i=idx(1,1,n);
    j=idx(2,1,n);
    
    if (j<gSize(2))
        edgeEnds_h(i,j,:)=[j+(i-1)*gSize(2) j+(i-1)*gSize(2)+1];
        enum_h=enum_h+1;
    end
    
    if (i<gSize(1))
        edgeEnds_v(i,j,:)=[j+(i-1)*gSize(2) j+i*gSize(2)];
        enum_v=enum_v+1;
    end
    
    for k = 1:c

        if (j<gSize(2))
            
            currentPatch = candidatesS(:,end-overlap(2)+1:end,:,n);
            currentPatch=reshape(currentPatch,pSize(1)*overlap(2),c);

            nextPatch = candidatesS(:,1:overlap(2),k,n+1);
            nextPatch=nextPatch(:);
            
            overlapDiff = sqrt(sum((currentPatch - repmat(nextPatch,1,c)).^2,1));
            
            pwHorz(i,j,((k-1)*c)+1:((k-1)*c)+c) = overlapDiff;
         
        end
        
        if (i<gSize(1))

            currentPatch = candidatesS(end-overlap(1)+1:end,:,:,n);
            currentPatch=reshape(currentPatch,pSize(2)*overlap(1),c);

            nextPatch = candidatesS(1:overlap(1),:,k,n+gSize(2));
            nextPatch=nextPatch(:);
            
            overlapDiff = sqrt(sum((currentPatch - repmat(nextPatch,1,c)).^2,1));
            
            pwVert(i,j,((k-1)*c)+1:((k-1)*c)+c) = overlapDiff;  
            
        end
        
    end
end

pwHorz = reshape(pwHorz,gSize(1)*(gSize(2)-1),c*c);
pwVert = reshape(pwVert,(gSize(1)-1)*gSize(2),c*c);
edgeEnds_h=reshape(edgeEnds_h, gSize(1)*(gSize(2)-1),2);
edgeEnds_v=reshape(edgeEnds_v, (gSize(1)-1)*gSize(2),2);
edgeEnds = int32([edgeEnds_h; edgeEnds_v]);
