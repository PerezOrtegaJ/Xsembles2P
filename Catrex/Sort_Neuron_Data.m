function [neuronData,id] = Sort_Neuron_Data(neuronData)
% Sort neurons
%
%      [neuronData,id] = Sort_Neuron_Data(neuronData)
%
% By Jesus Perez-Ortega, July 2019
% modified Jan 2020

[~,id_1] = sort([neuronData.x_median]);
[~,id_2] = sort([neuronData(id_1).y_median]);
id = id_1(id_2);
neuronData = neuronData(id);