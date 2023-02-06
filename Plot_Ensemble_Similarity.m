function Plot_Ensemble_Similarity(ensembleSimilarity,p,new_figure)
% Plot ensemble activity
%
%       Plot_Ensemble_Similarity(ensembleActivity,p,newFigure)
%
%       default: newFigure = false;
%
% By Jesus Perez-Ortega, Aug 2021
% Modified Oct 2021

switch nargin
    case 2
        new_figure = false;
end

% Get information
n_ensembles = length(ensembleSimilarity);   

% Set Figure
if new_figure
    Set_Figure('Ensemble activity',[0 0 1000 400]);
    Set_Axes('axEnsembleActivity',[0 0 1 1]); hold on
end

% Plot
colors = Read_Colors(n_ensembles);
for i = 1:n_ensembles
    bar(i,ensembleSimilarity(i),'FaceColor',colors(i,:)); hold on
    
    if p(i)<0.001
        significant = '***';
    elseif p(i)<0.01
        significant = '**';
    elseif p(i)<0.05
        significant = '*';
    else
        significant = 'NS';
    end
    text(i,ensembleSimilarity(i)+0.05,significant,'HorizontalAlignment','center')
end
xlabel('ensemble #')
ylabel('activation average')
xlim([0.5 n_ensembles+0.5])
ylim([0 max(ensembleSimilarity)+0.1])
set(gca,'xtick',1:n_ensembles)
box off
title('Ensemble similarity')