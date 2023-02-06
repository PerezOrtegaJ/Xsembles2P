function [neuronalData,summary,options] = Find_Cells_J2P(uSmoothed,URaw,cellDiameter,options)
% Pipeline for cell detection from suit2P
%
%       [neuronalData,summary,options] = Find_Cells_J2P(uSmoothed,URaw,cellDiameter,options)
%
% Based on suite2P
% Modified by Jesus Perez-Ortega, Dec 2019

if nargin == 4
    scaling = options.Scaling;
    if isfield(options,'UCell')
        uCell = options.UCell;
    else
        uCell = [];
    end
    if isfield(options,'ReferenceConvolution')
        referenceConvolution = options.ReferenceConvolution;
    else
        referenceConvolution = [];
    end
    if isfield(options,'Threshold')
        threshold = options.Threshold;
    else
        threshold = [];
    end    
else
    scaling = 0.5; % 1 (stability paper)
    referenceConvolution = [];
    uCell = [];
    threshold = [];
end

% Get size of spatial mask
[y,x,n_SVD] = size(uSmoothed);

% reshape U to be (nMaps x Y x X)
uSmoothed = reshape(uSmoothed,[],n_SVD)';
uSmoothed = reshape(uSmoothed,n_SVD,y,x);

% Get summary image
S_summ = Get_Neuropil_Basis(x,y,round(cellDiameter/2));
StU_summ = S_summ'*uSmoothed(:,:)'; 
StS_summ = S_summ'*S_summ;
neu_summ = StS_summ\StU_summ;
uCell_summ = uSmoothed-reshape(neu_summ'*S_summ',size(uSmoothed));
summary = imadjust(rescale(squeeze(var(uCell_summ))),[],[],0.1);

% compute neuropil basis functions for cell detection
if cellDiameter<15
    tiles = cellDiameter*5; % *5 added Oct 2021
else
    tiles = 1;
end

S = Get_Neuropil_Basis(x,y,tiles);
n_basis = size(S,2);
StU = S'*uSmoothed(:,:)'; % covariance of neuropil with spatial masks
StS = S'*S; % covariance of neuropil basis functions

% regress maps onto basis functions and subtract neuropil contribution
neu = StS\StU;

% Make cell mask 
sig = ceil(cellDiameter/4); 
dx = repmat(-cellDiameter:cellDiameter,2*cellDiameter+1, 1);
dy = dx';
rs = dx.^2+dy.^2-cellDiameter^2;
dx = dx(rs<=0);
dy = dy(rs<=0);

% initialize cell matrices
L = sparse(y*x,0);
LtU = zeros(0,n_SVD);
LtS = zeros(0,n_basis);

% Find cells for the first time
% -----
% residual is smoothed at every iteration

if isempty(uCell)
    uCell = uSmoothed-reshape(neu'*S',size(uSmoothed));
end
us = my_conv2_circ(uCell, sig, [2 3]);
V = double(squeeze(mean(us.^2,1)));

% compute log variance at each location
um = squeeze(mean(uCell.^2,1));
um = my_conv2_circ(um, sig, [1 2]);
V = double(V./um);

% do the morphological opening trick
% take the running max of the running min
% this normalizes the brightness of the image
lbound = -my_min2(-my_min2(V,cellDiameter),cellDiameter);
V = V-lbound;

if isempty(referenceConvolution)
    referenceConvolution = V;
end

% find indices of all maxima  in plus minus 1 range
% use the median of these peaks to decide stopping criterion
maxV    = -my_min(-V, 1, [1 2]);
ix      = (V > maxV-1e-10);

%if isempty(threshold)
    % threshold is the mean peak, times a potential scaling factor
    pks = V(ix);
    threshold  = scaling*median(pks(pks>1e-4));
%end

% just in case this goes above original value
V = min(V, referenceConvolution);

% find local maxima in a +- d neighborhood
maxV = -my_min(-V, cellDiameter, [1 2]);

% find indices of these maxima above a threshold
ix  = (V > maxV-1e-10) & (V > threshold);
ind = find(ix);
nCells = numel(ind); 

new_codes = normc(us(:, ind));
LtU(nCells,n_SVD) = 0;

% each source needs to be iteratively subtracted off
mPix = zeros(numel(dx),nCells);
mLam = zeros(numel(dx),nCells);
for i = 1:nCells
    [ipix, ipos] = getIpix(ind(i), dx, dy, x, y);
    Usub = uCell(:, ipix);
    lam = max(0, new_codes(:, i)' * Usub);        

    % threshold pixels
    lam(lam<max(lam)/5) = 0;        
    mPix(ipos,i) = ipix;
    mLam(ipos,i) = lam;

    % extract biggest connected region of lam only
    mLam(:,i)   = normc(getConnected(mLam(:,i), rs)); % ADD normc HERE and BELOW!!!
    lam              = mLam(ipos,i) ;
    L(ipix,i)   = lam;
    LtU(i, :)   = uSmoothed(:,ipix) * lam;
    LtS(i, :)   = lam' * S(ipix,:);
end    

% ADD NEUROPIL INTO REGRESSION HERE    
LtL     = full(L'*L);
codes   = ([LtL LtS; LtS' StS]+ 1e-3 * eye(nCells+n_basis))\[LtU; StU];
neu     = codes(nCells+1:end,:);    
codes   = codes(1:nCells,:);

% subtract off everything
uCell = uSmoothed - reshape(neu' * S', size(uSmoothed)) - reshape(double(codes') * L', size(uSmoothed));    

% re-estimate masks
L   = sparse(y*x, nCells);
for j = 1:nCells        
    ipos = find(mPix(:,j)>0);
    ipix = mPix(ipos,j);        
    Usub = uCell(:, ipix)+ codes(j, :)' * mLam(ipos,j)';
    lam = max(0, codes(j, :) * Usub);

    % threshold pixels
    lam(lam<max(lam)/5) = 0;
    mLam(ipos,j) = lam;

    % extract biggest connected region of lam only
    mLam(:,j) = normc(getConnected(mLam(:,j), rs));
    lam = mLam(ipos,j);
    L(ipix,j) = lam;
    LtU(j, :) = uSmoothed(:,ipix) * lam;
    LtS(j, :) = lam' * S(ipix,:);
    uCell(:, ipix) = Usub - (Usub * lam)* lam';
end

% Print findings
%fprintf('   %d new ROIs\n',nCells)
% -----
    
%% Refine ROIs
% this runs only the mask re-estimation step, on non-smoothed PCs
% (because smoothing is done during clustering to help)

% reshape U to be (nMaps x Y x X)
URaw =  reshape(URaw, [], n_SVD)';
URaw = reshape(URaw, n_SVD, y, x);

% regress maps onto basis functions and subtract neuropil contribution
StU     = S'*URaw(:,:)'; % covariance of neuropil with spatial masks
neu     = StS\StU;

% set to 0 the masks, to be re-estimated
mLam    = zeros(numel(dx), 1e4);
L       = sparse(y*x, nCells); 

for iter = 1:3
    % subtract off everything
    uCell = URaw-reshape(neu'*S',size(URaw))-reshape(double(codes')*L',size(URaw));    
    
    % re-estimate masks
    L   = sparse(y*x, nCells);
    for j = 1:nCells        
        ipos = find(mPix(:,j)>0);
        ipix = mPix(ipos,j);        
        
        Usub = uCell(:, ipix)+ codes(j, :)' * mLam(ipos,j)';
        lam = max(0, codes(j, :) * Usub);
        % threshold pixels
        lam(lam<max(lam)/5) = 0;
        mLam(ipos,j) = lam;

        % extract biggest connected region of lam only
        mLam(:,j) = normc(getConnected(mLam(:,j), rs));
        lam = mLam(ipos,j);
        L(ipix,j) = lam;
        uCell(:, ipix) = Usub - (Usub * lam)* lam';
    end
    
    % ADD NEUROPIL INTO REGRESSION HERE    
    uCell = uCell + reshape(neu' * S', size(URaw));    
    StU     = S'*uCell(:,:)'; % covariance of neuropil with spatial masks
    neu     = StS\StU;
end

mLam  =  mLam(:, 1:nCells);
mPix  =  mPix(:, 1:nCells);
mLam = bsxfun(@rdivide, mLam, sum(mLam,1));


% Write options for the following search
options.UCell = uCell;
options.ReferenceConvolution = referenceConvolution;
options.Threshold = threshold;
options.Scaling = scaling;

% Get neuron data
for i = 1:nCells
    % Get pixels from cell
    ipos = find(mPix(:,i)>0 & mLam(:,i)>1e-6);
    ipix = mPix(ipos,i);
    [ypix, xpix] = ind2sub([y x], ipix);
    
    % write data
    neuronalData(i).pixels = ipix;
    neuronalData(i).weight_pixels = mLam(ipos,i);
    neuronalData(i).x_pixels = xpix;
    neuronalData(i).y_pixels = ypix;
    neuronalData(i).num_pixels = numel(ipix);
    neuronalData(i).x_median = round(median(neuronalData(i).x_pixels));
    neuronalData(i).y_median = round(median(neuronalData(i).y_pixels));
end

% Get overlaping
neuronalData = Get_Overlaping(neuronalData,x,y);

% Get eccentricity
neuronalData = Get_Eccentricity(neuronalData,x,y);

% Sort neurons
neuronalData = Sort_Neuron_Data(neuronalData);