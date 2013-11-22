function labelling=infer(weight, unary, pwHorz, pwVert, edgeEnds, method, useMex, display, maxIter)

nNodes=size(unary,1)*size(unary,2);
nState=sqrt(size(pwHorz,2));

[V,E] = UGM_makeEdgeVE(edgeEnds,nNodes,useMex);

edgeStruct.edgeEnds = edgeEnds;
edgeStruct.V = V;
edgeStruct.E = E;
edgeStruct.nNodes = nNodes;
edgeStruct.nEdges = size(edgeEnds,1);
edgeStruct.nStates = repmat(nState,nNodes,1);
edgeStruct.useMex = useMex;
edgeStruct.maxIter = maxIter;

unary1=permute(unary,[2 1 3]);
nodePot = reshape(unary1,nNodes,nState)/255;
edgePot = [pwHorz; pwVert];
edgePot=edgePot'/255;
%normalize
%edgePot=exp(-1*edgePot-repmat(logsumExp(-1*edgePot,1)',nState*nState,1));
edgePot=exp(-1*edgePot);
edgePot=reshape(edgePot, nState, nState, size(edgePot,2));
%edgePot=permute(edgePot,[2 1 3]);

%normalize
%nodePot=exp(-1*nodePot-repmat(logsumExp(-1*nodePot,2),1,nState));
nodePot=exp(-1*nodePot); 

if (strcmp( method,'trw'))
    if (display)
        disp('Decode with the Sequential tree-reweighted message passing (TRW-S) Algorithm ...');
    end
    labelling = mex_TRW(weight(1)*unary, weight(2)*pwHorz, weight(2)*pwVert);

elseif (strcmp( method,'icm'))
    if (display)
        disp('Decode with the ICM Algorithm ...');
    end
    edgeStruct.nStates=int32(edgeStruct.nStates);
    ICMDecoding = UGM_Decode_ICM((weight(1)*nodePot),(weight(2)*edgePot),edgeStruct);
    %ICMDecoding =UGM_Decode_Greedy(nodePot,edgePot,edgeStruct);
    labelling=reshape(ICMDecoding,size(unary,2),size(unary,1))';
    
elseif (strcmp( method,'graphcut'))
    GCDecoding = UGM_Decode_GraphCut(nodePot,edgePot,edgeStruct);
    labelling=reshape(GCDecoding,size(unary,2),size(unary,1))';

elseif (strcmp( method,'lbp'))
    if (display)
        disp('Decode with the Loopy BP Algorithm ...');
    end
    if (edgeStruct.useMex==1)
        edgeStruct.nStates=int32(edgeStruct.nStates);
    end
    LBPDecoding = UGM_Decode_LBP(nodePot,edgePot,edgeStruct);
    labelling=reshape(LBPDecoding,size(unary,2),size(unary,1))';
end
