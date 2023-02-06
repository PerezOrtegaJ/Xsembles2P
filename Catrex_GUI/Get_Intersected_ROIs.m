function cells = Get_Intersected_ROIs(neuronsA,neuronsB,radius,minintersection)
% GET_INTERSECTED_ROIS Get the intersection of two sets of ROIs
%
%       cells = Get_Intersected_ROIs(neuronsA,neuronsB,radius,minintersection)
%
%       default: minintersection = 1/3; minimum fraction of pixels overlapped between neurons
%
%       neuronsA and neuronsB should be structures with the following
%       fields: 'x_median', 'y_median', and 'pixels'
%
%         'cells' structure:
%                           .IDSameA
%                           .IDSameB
%                           .IDOnlyA
%                           .IDOnlyB
%                           .IDBeyondRadius 
%                           .IDSmallIntersection 
%                           .NumSame 
%                           .NumA
%                           .NumB
%                           .NumOnlyA 
%                           .NumOnlyB 
%                           .Total
%                           .FractionA 
%                           .FractionB 
%                           .FractionAB
%                           .FractionOnlyA
%                           .FractionOnlyB
%
% By Jesus Perez-Ortega, Jun 2020
% Modified Nov 2021

if nargin == 3
    minintersection = 1/3; % proportion of a cell on the session A
end

disp('Finding intersection...')

% Get neurons
nA = length(neuronsA);
nB = length(neuronsB);
xyB = [neuronsB(:).x_median; neuronsB(:).y_median]';

% Get intersection between masks
idSameA = [];
idSameB = [];
idOnlyA = [];
idBeyondRadius = [];
idSmallIntersection = [];
for i = 1:nA
    xyA = [neuronsA(i).x_median neuronsA(i).y_median];
   
    dist = pdist2(xyA,xyB);
    [mindist,idB] = min(dist);
    
    % Evaluate distance <= radius
    if mindist>radius
        % different
        idOnlyA = [idOnlyA; i];
        idBeyondRadius = [idBeyondRadius; i];
    else
        areaintersected = nnz(intersect(neuronsA(i).pixels,neuronsB(idB).pixels))/...
                          length(neuronsA(i).pixels);
        
        % Evaluate area >= minimum area
        if areaintersected<minintersection
            % different
            idOnlyA = [idOnlyA; i];
            idSmallIntersection = [idSmallIntersection; i];
        else
            % same
            idSameA = [idSameA; i];
            idSameB = [idSameB; idB];
        end
    end
end
idOnlyB = setdiff(1:nB,idSameB)';

% Get number of neurons
nsameA = length(idSameA);
nsameB = length(unique(idSameB));

% Check fo consistency
duplicates = nsameA-nsameB;
idDuplicates = [];
if duplicates
    % Evaluate duplicates
    values = Find_Duplicates(idSameB);
    
    removeid = [];
    for i = 1:length(values)
        value = values(i);
        id = find(idSameB==value);
        xA = [neuronsA(idSameA(id)).x_median];
        yA = [neuronsA(idSameA(id)).y_median];
        xyA = [xA; yA]';
        xB = neuronsB(value).x_median;
        yB = neuronsB(value).y_median;
        xyB = [xB yB];
        dist = pdist2(xyA,xyB);
        [~,idbest] = min(dist);
        removeid = [removeid setdiff(id,id(idbest))'];
        idDuplicates = [idDuplicates; value];
    end
    
    % Remove duplicates
    idSameA(removeid) = [];
    idSameB(removeid) = [];
    idOnlyB = unique([idOnlyB; idDuplicates]);
end

% Get number of neurons
nAB = length(idSameA);
nOnlyA = length(idOnlyA);
nOnlyB = length(idOnlyB);
nBeyondRadius = length(idBeyondRadius);
nSmallIntersection = length(idSmallIntersection);
nDuplicates = length(idDuplicates);

% Get fraction of neurons
nTotal = nA+nB-nAB;
fractionA = nA/nTotal;
fractionB = nB/nTotal;
fractionAB = nAB/nTotal;
fractionOnlyA = nOnlyA/nTotal;
fractionOnlyB = nOnlyB/nTotal;

disp(['   Neurons only in session A: ' num2str(nOnlyA) ' (' num2str(fractionOnlyA*100,'%.0f') '%)'])
disp(['                              ' num2str(nBeyondRadius) ' beyond the radius'])
disp(['                              ' num2str(nSmallIntersection) ' with small intersection'])
disp(['                              ' num2str(nDuplicates) ' duplicates'])
disp(['   Neurons only in session B: ' num2str(nOnlyB) ' (' num2str(fractionOnlyB*100,'%.0f') '%)'])
disp(['   Total neurons intersected: ' num2str(nAB) ' (' num2str(fractionAB*100,'%.0f') '%)'])

% Cells data
cells.IDSameA = idSameA;
cells.IDSameB = idSameB;
cells.IDOnlyA = idOnlyA;
cells.IDOnlyB = idOnlyB;
cells.IDBeyondRadius = idBeyondRadius;
cells.IDSmallIntersection = idSmallIntersection;
cells.IDDuplicates = idDuplicates;
cells.NumSame = nAB;
cells.NumA = nA;
cells.NumB = nB;
cells.NumOnlyA = nOnlyA;
cells.NumOnlyB = nOnlyB;
cells.Total = nTotal;
cells.FractionA = fractionA;
cells.FractionB = fractionB;
cells.FractionAB = fractionAB;
cells.FractionOnlyA = fractionOnlyA;
cells.FractionOnlyB = fractionOnlyB;