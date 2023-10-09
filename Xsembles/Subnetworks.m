function [subnetworks,all_subnetworks] = Subnetworks(network,sub_nodes)
% Get subnetworks from a given nodes (cell array)
%
%       [subnetworks,all_subnetworks] = Subnetworks(network,sub_nodes)
%
% By Jesus Perez-Ortega, Sep 2023

% Get number of nodes and subnetworks
n_nodes = length(network);
n_sub = length(sub_nodes);

% Initialize variables
all_subnetworks = zeros(n_nodes);
subnetworks = cell(n_sub,1);

% Get subnetworks
for i = 1:n_sub
    nodes = sub_nodes{i};
    network_i = zeros(n_nodes);
    network_i(nodes,nodes) = network(nodes,nodes);
    subnetworks{i} = network_i;
    all_subnetworks = all_subnetworks|subnetworks{i};
end