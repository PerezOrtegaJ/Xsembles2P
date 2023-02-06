function legends = Plot_Stimulation(stimuli,amplitude,stim_text,colors)
% Plot stimulation 
%
%   legends = Plot_Stimulation(stimuli,amplitude,stim_text,colors)
%
%   default: colors = [Read_Colors(4); Attenuate_Colors(Read_Colors(4))]
%
% By Jesus Perez-Ortega, Oct 2022

switch nargin
    case 3
        colors = Read_Colors(4);
        colors = [colors; Attenuate_Colors(colors)];
end

stims = setdiff(unique(stimuli),0);
n_stims = length(stims);
legend_text = {};
for i = 1:n_stims
    stim = stimuli==stims(i);
    Plot_Area(rescale(stim,0,amplitude),0,colors(stims(i),:),0.5); hold on
    legend_text = [legend_text {stim_text(i)}];
end
xlim([0 length(stimuli)])

if nargout
    legends = legend_text;
end