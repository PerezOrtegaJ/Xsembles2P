function [tuned1,cp,weights,p,tuned2] = Get_Evoked_Neurons(activity,stim1,stim2)
% Identify the neurons that are evoked by stimulation versus
% without stimulation or a second stimulation
%
%       [tuned1,cp,weights,p,tuned2] = Get_Evoked_Neurons(activity,stim1,stim2)
%
%       stim2 can be omited.
%
% By Jesus Perez-Ortega, Nov 2019
% modified Jul 2021
% modified Oct 2021

if nargin==2
    is_2nd_stim = false;
else
    is_2nd_stim = true;
end

% Get number of neurons
n_neurons = size(activity,1);

% Get indices from each stimulus
stimID = Find_Peaks(stim1,0.1,true,true);

if max(stimID)<2
    tuned1 = false(1,n_neurons);
    cp = zeros(1,n_neurons);
    weights = zeros(1,n_neurons);
    p = ones(1,n_neurons);
    tuned2 = false(1,n_neurons);
    return
end

if is_2nd_stim
    noStimID = Find_Peaks(stim2,0.1,true,true);
else
    noStimID = Find_Peaks(stim1,0.1,true,false,0,0,true);
end

% Get the average of evoked spikes
spikesStim = Get_Peak_Vectors(activity,stimID,'average')';
avgStim = mean(spikesStim,2)';

% Get the average of spontaneous spikes
spikesNoStim = Get_Peak_Vectors(activity,noStimID,'average')';
avgNoStim = mean(spikesNoStim,2)';

% Get weigths
weights = [avgStim; avgNoStim]';

% Compute selectivity
for i = 1:n_neurons
    total_spikes = sum(spikesStim(i,:))+sum(spikesNoStim(i,:));
    if total_spikes
        [tuned(i),p(i)] = ttest2(spikesStim(i,:),spikesNoStim(i,:));
        cp(i) = (sum(spikesStim(i,:))-sum(spikesNoStim(i,:)))/total_spikes;
    else
        p(i) = 1;
        tuned(i) = false;
        cp(i) = 0;
    end
end
tuned1 = tuned;
tuned2 = tuned;

% Get significant to stim 1
tuned1(diff(weights')>0) = 0;
tuned1 = logical(tuned1);

% Get significant to stim 2
tuned2(diff(weights')<0) = 0;
tuned2 = logical(tuned2);
