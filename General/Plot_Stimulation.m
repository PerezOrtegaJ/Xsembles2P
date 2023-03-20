function legends = Plot_Stimulation(stimuli,amplitude,stim_text,colors)
% Plot stimulation 
%
%   legends = Plot_Stimulation(stimuli,amplitude,stim_text,colors)
%
%   default: amplitude = 1; stim_text = '→↗↑↖←↙↓↘'; 
%            colors = [Read_Colors(4); Attenuate_Colors(Read_Colors(4))]
%
% By Jesus Perez-Ortega, Oct 2022
% Modified Feb 2023 (default inputs)
% Modified Mar 2023 (InputMin)

if nargin<4
    colors = lines(4);
    colors = [colors; Attenuate_Colors(colors)];
    if nargin<3
        stim_text = '→↗↑↖←↙↓↘';
        if nargin<2
            amplitude = 1;
        end
    end
end

stims = setdiff(unique(stimuli),0);
n_stims = length(stims);
legend_text = {};
if ~isempty(stims)
    for i = 1:n_stims
        stimulus = stimuli==stims(i);
        Plot_Area(rescale(stimulus,0,amplitude,'InputMin',0),0,colors(stims(i),:),0.5); hold on
        legend_text = [legend_text {stim_text(stims(i))}];
    end
    xlim([0 length(stimuli)])
end

if nargout
    legends = legend_text;
end