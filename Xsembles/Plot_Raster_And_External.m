function Plot_Raster_And_External(raster,external,fps,new_figure)
% Plot raster and external voltage recording
%
%       Plot_Raster_And_External(raster,external,fps,new_figure)
%
%       default: new_figure = false;
%
% By Jesus Perez-Ortega, Feb 2023

if nargin<4
    new_figure = false;
    if nargin<3
        fps = [];
        if nargin<2
            external = [];
        end
    end
end

%% Plot
% Set new figure
if new_figure
    Set_Figure('Raster and external recording',[0 0 1200 700])
end

% Proportions of raster
raster_height = 0.85;
raster_width = 1;

% A. Plot raster
h(1) = subplot(5,1,1:4);
Plot_Raster(raster,'',true,false)
ylabel('neuron #')
set(gca,'xtick',[])

% B. Plot external recordign
if ~isempty(external)
    legend_text = {};
    max_y = 15; % maximum running speed (cm/s)

    h(2) = subplot(5,1,5);
    if isfield(external,'Locomotion')
        plot(external.Locomotion,'k')
        xlim([0 length(external.Locomotion)])
        ylabel({'locomotion','[cm/s]'})
        legend_text = {'locomotion'};
    end
    
    if isfield(external,'Licking')
        Plot_Area(rescale(external.Licking,0,max_y),0,[0.8 0.8 0.8],0.5)
        xlim([0 length(external.Licking)])
        legend_text = [legend_text {'licking'}];
    end
    if isfield(external,'Laser')
        Plot_Area(rescale(external.Laser,0,max_y),0,[0.3 0.3 0.3],0.5)
        xlim([0 length(external.Laser)])
        legend_text = [legend_text {'laser'}];
    end
    if isfield(external,'Stimuli')
        if nnz(external.Stimuli)
            stimuli = external.Stimuli;
            if nnz(stimuli)
                stim_text = '→↗↑↖←↙↓↘';
                legends = Plot_Stimulation(stimuli,max_y,stim_text);
                legend_text = [legend_text legends];
            end
        end
    end
    
    ylim([0 max_y])
    title('External recording')
    box off
    xticks([])
    l = legend(legend_text);
    l.Position(1)=0.005;
    
    % Link x axis
    linkaxes(h,'x');
end

% Set label time (or just the number of vectors)
if isempty(fps)
    xlabel('vectors')
else
    frames = size(raster,2);
    Set_Label_Time(frames,fps)
end