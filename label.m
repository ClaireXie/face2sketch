function [nodeLabels] = label(nodePot,edgePot,edgeStruct, new_msg, ip, op, os, oidx,iter)

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

% Compute nodeBel
for n = 1:nNodes
    edges = E(V(n):V(n+1)-1);
    prod_of_msgs(1:nStates(n),n) = nodePot(n,1:nStates(n))';
    for e = edges(:)'
        if n == edgeEnds(e,2)
            prod_of_msgs(1:nStates(n),n) = prod_of_msgs(1:nStates(n),n) .* new_msg(1:nStates(n),e);
        else
            prod_of_msgs(1:nStates(n),n) = prod_of_msgs(1:nStates(n),n) .* new_msg(1:nStates(n),e+nEdges);
        end
    end
    nodeBel(n,1:nStates(n)) = prod_of_msgs(1:nStates(n),n)'./sum(prod_of_msgs(1:nStates(n),n));
end
[pot nodeLabels] = max(nodeBel,[],2);
labelling=reshape(nodeLabels,oidx(2,1,end),oidx(1,1,end))';

[presult, sresult]=synSketch(labelling, ip, op, os, oidx);

subplot(1,3,1);imshow(uint8(sresult));
title(sprintf('Loopy-BP after %d iterations',iter));