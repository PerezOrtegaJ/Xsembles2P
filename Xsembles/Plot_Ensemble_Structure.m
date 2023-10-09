function colors_structure = Plot_Ensemble_Structure(structure,colors,new_figure,node_size,fade)
% Plot the structure of the ensembles, i.e., the neurons that belong to the
% ensembles and their weights
%
%       colors_structure = Plot_Ensemble_Structure(structure,colors,new_figure,node_size,fade)
%
%       default: colors = []; new_figure = false; node_size = 30; fade = false;
%
%       structure: columns represent neurons and rows represent ensembles.
%
% By Jesus Perez-Ortega, Aug 2021
% Modified Sep 2021
% Modified Oct 2021
% Modified Jan 2022 (name changed)
% Modified Oct 2022 (ploting neurons)
% Modified Oct 2023 (red blue colors)

switch nargin
    case 1
        colors = [];
        new_figure = false;
        node_size = 30;
        fade = false;
    case 2
        new_figure = false;
        node_size = 30;
        fade = false;
    case 3
        node_size = 30;
        fade = false;
    case 4
        fade = false;
end

if strcmp(colors,'red-blue')
    redblue = true;
else
    redblue = false;
end

% Get number of neurons and ensembles
structure = structure';
[n_neurons,n_ensembles] = size(structure);

% Get colors
if isempty(colors)
    colors = Read_Colors(n_ensembles);
end

if fade
    % Get hue 
    hsvColors = rgb2hsv(colors);
    hue = hsvColors(:,1);
    hues = repmat(hue,1,n_neurons)';
    
    % Set saturation to colors
    for i = 1:n_ensembles
        sat = hsvColors(i,2);
        saturation(:,i) = structure(:,i)*sat;
    end
    
    % Set values
    value = hsvColors(:,3);
    values = repmat((1-value),1,n_neurons)'.*(1-structure)+repmat(value,1,n_neurons)';
    
    % Create image
    color_neurons = hsv2rgb(cat(3,hues,saturation,values));
end

% Plot structure
if new_figure
    Set_Figure('Structure weigthed',[0 0 40*n_ensembles 300]);
end

% Plot each neuron
for i = 1:n_ensembles
    if fade
        colors = squeeze(color_neurons(:,i,:));
        for j = n_neurons:-1:1
            if sum(colors(j,:))<3
    %             scatter(i,j,node_size,'MarkerEdgeColor',colors(j,:)*2/3,'MarkerFaceColor',colors(j,:),...
    %                 'MarkerEdgeAlpha',0.5,'MarkerFaceAlpha',0.5); hold on
                scatter(i,j,node_size,colors(j,:),'.'); hold on
            end
        end
    else
        % Plot onsemble neurons
        neurons = find(structure(:,i)==1)';
        if ~isempty(neurons)
            if redblue
                plot(i,neurons,'.','color',[0.91 0.33 0.33],'MarkerSize',node_size/3); hold on
            else
                plot(i,neurons,'.','color',colors(i,:),'MarkerSize',node_size/3); hold on
            end
        end
        
        % Plot offsemble neurons
        neurons = find(structure(:,i)==-1)';
        if ~isempty(neurons)
            if redblue
                plot(i,neurons,'.','color',[0.40 0.63 0.85],'MarkerSize',node_size/3); hold on
            else
                plot(i,neurons,'.','color',Darken_Colors(colors(i,:)),'MarkerSize',node_size/3); hold on
            end
        end
    end
end

if n_ensembles==1
    xlim([0.5 1.5])
else
    xlim([0.5 n_ensembles+0.5])
end

ylim([1 n_neurons])
xlabel('ensemble #')
ylabel('neuron #')
set(gca,'ydir','normal')

if nargout
    colors_structure = color_neurons;
end