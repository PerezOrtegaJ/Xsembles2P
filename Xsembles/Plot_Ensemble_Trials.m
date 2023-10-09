function Plot_Ensemble_Trials(activation_sequence,stimuli,pre,post,fps,colors)
% Plot the sequence of ensemble activation on each trial
%
%   Plot_Ensemble_Trials(activation_sequence,stimuli,pre,post,fps,colors)
%
% By Jesus Perez-Ortega, Oct 2022
% Modified, Feb 2023
% Modified, Mar 2023
% Modified, Apr 2023
% Modified, Jun 2023
% Modified, Oct 2023 (same orientation together)

% Get number of ensembles
n_ensembles = max(activation_sequence);

if n_ensembles<1
    warning('There are no ensembles!')
    return
end

if nargin<6
    colors = Read_Colors(n_ensembles);
end

% Get all stimuli
if iscolumn(stimuli)
    stimuli = stimuli';
end
stim_type = unique(stimuli);
stim_type = setdiff(stim_type,0);
n_stim = length(stim_type);

if n_stim>8
    stim_text = 'stimuli';
    stim_type = 1;
    trials_i = Get_Trial_Responses(activation_sequence,stimuli>0,pre,post);
    [n_trials,samples] = size(trials_i);
   
    trial_responses = trials_i;
    n_trial_divisor = n_trials+0.5;
    n_trials_all = n_trials;
else
    stim_text_all = '→↗↑↖←↙↓↘';
    stim_text = '';
    
    % Get the sequences of each stimulus
    trial_responses = [];
    j = 1;
    for i = 1:4
        if ismember(i,stim_type)
            trials_i = Get_Trial_Responses(activation_sequence,stimuli==i,pre,post);
            [n_trials,samples] = size(trials_i);
            if j==1
                trial_responses = trials_i;
                n_trial_divisor(j) = n_trials+0.5;
            else
                trial_responses(end+1:end+n_trials,1:samples) = trials_i;
                n_trial_divisor(j) = n_trials+n_trial_divisor(j-1);
            end
            stim_text(j,1) = stim_text_all(i);
            n_trials_all(j) = n_trials;
            j = j+1;
        end
        if ismember(i+4,stim_type)
            trials_i = Get_Trial_Responses(activation_sequence,stimuli==i+4,pre,post);
            [n_trials,samples] = size(trials_i);
            if j==1
                trial_responses = trials_i;
                n_trial_divisor(j) = n_trials+0.5;
            else
                trial_responses(end+1:end+n_trials,1:samples) = trials_i;
                n_trial_divisor(j) = n_trials+n_trial_divisor(j-1);
            end
            stim_text(j,1) = stim_text_all(i+4);
            n_trials_all(j) = n_trials;
            j = j+1;
        end
    end
end

% Plot trials
imagesc(trial_responses,[0 n_ensembles]); hold on
colormap(gca,[1 1 1;colors])
plot([pre pre]+1,[0 size(trial_responses,1)],'--k')
for i = 1:length(stim_type)-1
    plot([0 samples],[1 1]*n_trial_divisor(i),'--k')
end
yticks(n_trial_divisor-n_trials_all/2)
yticklabels(stim_text)

ylabel('trial #')
Set_Label_Time(size(trial_responses,2),fps,pre)