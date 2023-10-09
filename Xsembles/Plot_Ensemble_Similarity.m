function Plot_Ensemble_Similarity(ensemble_similarity,p,colors,new_figure)
% Plot ensemble activity
%
%       Plot_Ensemble_Similarity(ensemble_similarity,p,colors,new_figure)
%
%       default: newFigure = false;
%
% By Jesus Perez-Ortega, Aug 2021
% Modified, Oct 2021 
% Modified, Mar 2023  (colors input)

% Get information
n_ensembles = length(ensemble_similarity);   

if nargin<4
   new_figure = false;
   if nargin<3
       colors = Read_Colors(n_ensembles);
       if nargin<2
           p = [];
       end
   end
end

% Set Figure
if new_figure
    Set_Figure('Ensemble activity',[0 0 1000 400]);
    Set_Axes('axEnsembleActivity',[0 0 1 1]); hold on
end

% Plot

for i = 1:n_ensembles
    bar(i,ensemble_similarity(i),'FaceColor',colors(i,:)); hold on
    
    if ~isempty(p)
        if p(i)<0.001
            significant = '***';
        elseif p(i)<0.01
            significant = '**';
        elseif p(i)<0.05
            significant = '*';
        else
            significant = 'NS';
        end
        text(i,ensemble_similarity(i)+0.05,significant,'HorizontalAlignment','center')
    end
end
xlabel('ensemble #')
ylabel('similarity average')
xlim([0.5 n_ensembles+0.5])
ylim([0 max(ensemble_similarity)+0.1])
set(gca,'xtick',1:n_ensembles)
box off
title('Ensemble similarity')