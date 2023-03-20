function Plot_Ensemble_Activity(ensemble_activity,colors,new_figure)
% Plot ensemble activity
%
%       Plot_Ensemble_Activity(ensemble_activity,colors,new_figure)
%
%       default: colors = []; newFigure = false;
%
% By Jesus Perez-Ortega, Aug 2021
% Modified Oct 2021

switch nargin
    case 1
        colors = [];
        new_figure = false;
    case 2
        new_figure = false;
end

% Get information
[n_ensembles,n_frames] = size(ensemble_activity);   

% Set Figure
if new_figure
    Set_Figure('Ensemble activity',[0 0 1000 400]);
    Set_Axes('axEnsembleActivity',[0 0 1 1]); hold on
end

% Plot
if isempty(colors)
    colors = Read_Colors(n_ensembles);
end

for i = 1:n_ensembles
    signal = ensemble_activity(i,:);
    Plot_Area(signal,0,colors(i,:),0.5); hold on
end    
ylabel({'fraction of','ensemble neurons'})
title('Ensemble activity')
if n_frames
    xlim([0 n_frames])
end