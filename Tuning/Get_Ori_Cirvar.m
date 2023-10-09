function [cirvar,p,tuning,avg_response,sem_response,all_points] = Get_Ori_Cirvar(raster,stimuli)
% Get the the orientation selectivity of a neuron.
% The values ranges between 0-1. This measure works if stimuli has given 1:8 different directions 
% (degrees = [0 45 90 135 180 225 270 315]).
%
%       [cirvar,p,tuning,avg_response,sem_response,all_points] = Get_Ori_Cirvar(raster,stimuli)
%
% circular variance (Ringach et al., 2002; Mazurek et al., 2014)
% selectivity = 1 - circular variance
%
% By Jesus Perez-Ortega March 2022

% Get the number of cells
n_neurons = size(raster,1);

% Get number of trials
n_trials = max(Find_Peaks(stimuli>0));

% Degrees of drifting gratings
degrees = [0 45 90 135 180 225 270 315];

% Get the count of spikes at each trial from each stimulus
avg_response = zeros(n_neurons,8);
sem_response = zeros(n_neurons,8);
spikes = [];
angles = [];
for i = 1:8
    % Get indices from each stimulus
    during = stimuli==i;

    if nnz(during)
        indices = Find_Peaks(during,0,true,true,2);
    
        % Get the sum of spikes at each trial
        spikes_i = Get_Peak_Vectors(raster,indices,'average')';
        count = size(spikes_i,2);
    
        % Concatenate vectors
        spikes = [spikes spikes_i];
    
        % Get the angle
        angles = [angles; repmat(degrees(i),count,1)];
    
        % Get mean spikes per stimulus and sem
        if count==1
            avg_response(:,i) = spikes_i;
            sem_response(:,i) = nan(size(spikes_i));
        else
            avg_response(:,i) = mean(spikes_i,2);
            sem_response(:,i) = std(spikes_i,[],2)/sqrt(count);
        end
    else
        avg_response(:,i) = 0;
        sem_response(:,i) = nan;
    end
end

% Get the exponential values
exps = exp(angles.*2*pi/180*1i);

% Compute selectivity
cirvar = zeros(1,n_neurons);
p = ones(1,n_neurons);
h = false(1,n_neurons);
all_points = zeros(n_neurons,n_trials);
for i = 1:n_neurons
    cell_spikes = sum(spikes(i,:));
    points = transpose(spikes(i,:)'.*exps);
    if cell_spikes
        % Get Significant Orientation Selectivity
        [p(i), h(i)] = Hotelling_T2_Test([real(points);imag(points)]',0.05);
        cirvar(i) = abs(sum(points))/cell_spikes;
    end
    all_points(i,1:length(points)) = points; 
end

% Identify the maximum response
[~,selective_stim] = max(avg_response,[],2);
selective_stim(selective_stim>4) = selective_stim(selective_stim>4)-4;

% Set significant orientation
tuning = nan(1,n_neurons);
tuning(h) = selective_stim(h);