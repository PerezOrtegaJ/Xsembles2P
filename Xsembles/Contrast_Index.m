function [contrast_index,SEM_contrast_index] = Contrast_Index(clusters,similarity,indices,exclude)
% Contrast index
% Get the Contrast index for g groups given a similarity matrix.
% (Michelson 1927, Plenz 2004)
%
%       contrast_index = Contrast_Index(groups,similarity,indices,exclude)
%
%       default: exclude = false;
%
% Inputs
% clusters = number of groups
% similarity = similarity as matrix PxP (P = #peaks)
% indices = cluster which each data point belongs
%
% by Jesus Perez-Ortega, Apr 2012
% Modified Sep 2021
% Modified Mar 2022

switch nargin
    case 3
        exclude = false;
end

if exclude && clusters<=2
    warning('It can not be an exclusion with 2 or less groups.')
    exclude = false;
end
   
% Remove diagonal values from similarity matrix
sim = similarity-diag(diag(similarity));

for i = 1:clusters
    id_in = find(indices==i);
    id_out = find(indices~=i);

    % Similarity average inside group
    avg_in(i) = sum(sum(sim(id_in,id_in)))/(numel(id_in)^2-length(id_in));

    % Similarity average outside group
    avg_out(i) = sum(sum(sim(id_in,id_out)))/(numel(id_in)*numel(id_out));

    % Compute the contrast index
    index(i) = (avg_in(i)-avg_out(i))/(avg_in(i)+avg_out(i));
end

% Identify the group to exclude
if exclude && clusters>2
    [~,group_excluded] = min(index);
    ids = setdiff(1:clusters,group_excluded);
    
    avg_in = [];
    avg_out = [];
    index = [];
    j = 1;
    for i = ids
        % Get indices from inside group and outside group
        id_in = find(indices==i);
        id_out = find(indices~=i);
        
        % Similarity average inside group
        avg_in(j) = sum(sum(sim(id_in,id_in)))/(numel(id_in)^2-length(id_in));

        % Similarity average outside group
        avg_out(j) = sum(sum(sim(id_in,id_out)))/(numel(id_in)*numel(id_out));
        
        % Compute the contrast index
        index(j) = (avg_in(j)-avg_out(j))/(avg_in(j)+avg_out(j));

        j = j+1;
    end
    
end

% Get the mean of indices and its standard error
contrast_index = mean(index);
SEM_contrast_index = Get_SEM(index);

% Previously
% % Sum the similarities
% S_in = sum(avg_in);
% S_out = sum(avg_out);
% 
% % Compute the contrast index
% contrast_index = (S_in-S_out)/(S_in+S_out);