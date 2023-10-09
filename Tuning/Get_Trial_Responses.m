function [trial_responses,trial_times] = Get_Trial_Responses(response,stimuli,pre,post)
% Get the matrix of trial responses from a continuous recording.
%
%       [trial_responses,trial_times] = Get_Trial_Responses(response,stimuli,pre,post)
%
%   default: pre = 0; post = 0;
%
% By Jesus Perez-Ortega, Sep 2021
% Modified, Feb 2023

switch nargin
    case 2
        pre = 0;
        post = 0;
    case 3
        post = 0;
end

% Get number of samples
samples = length(stimuli);

% Find all the time the stimulus happened
during = stimuli>0;
[stim_id,widths] = Find_Peaks(during,0.5,true,true,0,0,true);

trial_responses = [];
trial_times = [];

if isempty(widths)
    return
end

% maximum length of stimulation
max_length = max(widths);

% Get the total number of stimuli
n_stims = max(stim_id);
for i = 1:n_stims
    id = find(stim_id==i);

    % Add extra frames before and after stimulus
    ini = id(1)-pre;
    fin = id(end)+post;

    % Check if there are samples before and after stimulus
    if ini<1
        warning('The number of samples from the first pre-stimulus was not reachable.')
        continue
%         inidiff = 1-ini;
%         ini = 1;
    else
        inidiff = 0;
    end
    if fin>samples
        warning('The number of samples from the last post-stimulus was not reachable.')
        continue
%         findiff = fin-samples;
%         fin = samples;
    else
        findiff = 0;
    end
    extra = max_length-widths(i);

    % Get total number of frames
    trial_times = [trial_times; ini:fin+extra];
    trial_responses = [trial_responses; response(ini:fin) zeros(1,extra)]; 
%     trial_responses = [trial_responses; zeros(1,inidiff) response(ini:fin+extra) zeros(1,findiff)]; 
end
