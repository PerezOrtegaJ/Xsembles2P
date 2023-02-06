function Plot_Ensemble_Raster(analysis,fps,sort_neurons,sort_vectors,new_figure,voltage)
% Plot raster and ensemble activity from a structure variable generated
% from Get_Xsembles()
%
%       Plot_Ensemble_Raster(analysis,fps,sort_neurons,sort_vectors,new_figure,external)
%
%       default: fps = []; sort_neurons = true; sort_vectors = false; new_figure = true;
%                external = [];
%
% By Jesus Perez-Ortega, Oct 2021
% Modified Jan 2022

switch nargin
    case 1
        fps = [];
        sort_neurons = true;
        sort_vectors = false;
        new_figure = true;
        voltage = [];
    case 2
        sort_neurons = true;
        sort_vectors = false;
        new_figure = true;
        voltage = [];
    case 3
        sort_vectors = false;
        new_figure = true;
        voltage = [];
    case 4
        new_figure = true;
        voltage = [];
    case 5
        voltage = [];
end

%% Get data from analysis structure
raster = analysis.Raster;

neuron_id = analysis.Ensembles.NeuronID;
if isfield(analysis.Ensembles,'VectorID')
    vector_id = analysis.Ensembles.VectorID;
else
    disp('Getting vector id...')
    vector_id = [];
    for i = 1:analysis.Ensembles.Count
        vector_id = [vector_id; analysis.Ensembles.Indices{i}];
    end
    
    if isfield(analysis,'NonEnsembles')
        for i = 1:analysis.NonEnsembles.Count
            vector_id = [vector_id; analysis.NonEnsembles.Indices{i}];
        end
    end
end

if isfield(analysis,'NonEnsembles')
    ensemble_activity = analysis.Ensembles.Activity;
    ensemble_activity_raster = [analysis.Ensembles.Activity; analysis.NonEnsembles.Activity];
    ensemble_similarity = [analysis.Ensembles.Similarity analysis.NonEnsembles.Similarity];
    p_ensemble = [analysis.Ensembles.Probability analysis.NonEnsembles.Probability];
    if sort_neurons
        ensemble_structure = [analysis.Ensembles.StructureWeightsSignificant(:,neuron_id);...
                              analysis.NonEnsembles.StructureWeightsSignificant(:,neuron_id)];
    else
        ensemble_structure = [analysis.Ensembles.StructureWeightsSignificant;...
                              analysis.NonEnsembles.StructureWeightsSignificant];
    end
else
    ensemble_activity = analysis.Ensembles.Activity;
    ensemble_activity_raster = analysis.Ensembles.Activity;
    ensemble_similarity = analysis.Ensembles.Similarity;
    p_ensemble = analysis.Ensembles.Probability;
    if sort_neurons
        ensemble_structure = analysis.Ensembles.StructureWeightsSignificant(:,neuron_id);
    else
        ensemble_structure = analysis.Ensembles.StructureWeightsSignificant;
    end
end

%% Plot
% Set new figure
if new_figure
    if sort_vectors
        Set_Figure('Xsembles (sorted)',[0 0 1200 700])
    else
        Set_Figure('Xsembles',[0 0 1200 700])
    end
end

% Proportions of raster
raster_height = 0.85;
raster_width = 0.9;

% A. Plot raster
axRaster = Set_Axes('axraster',[0 1-raster_height raster_width raster_height]);

if sort_vectors
    if sort_neurons
        Plot_Raster(raster(neuron_id,vector_id),'',true,false)
        ylabel('neuron # (sorted)')
    else
        Plot_Raster(raster(:,vector_id),'',true,false)
        ylabel('neuron #')
    end
    title('Raster activity (sorted)')
else
    if sort_neurons
        Plot_Raster(raster(neuron_id,:),'',true,false)
        ylabel('neuron # (sorted)')
    else
        Plot_Raster(raster,'',true,false)
        ylabel('neuron #')
    end
    title('Raster activity')
end
set(gca,'xtick',[])

% B. Plot structure
axStructure = Set_Axes('axEnsembleIdentity',[raster_width-0.055 1-raster_height...
    1-raster_width+0.01 raster_height]);
Plot_Ensemble_Structure(ensemble_structure)
title('Neuronal identity')
axis off

% C. Plot ensemble activity
axActivity = Set_Axes('axEnsembleActivity',[0 0 raster_width 1-raster_height-0.01]);
if sort_vectors
    Plot_Ensemble_Activity(ensemble_activity_raster(:,vector_id))
else
    Plot_Ensemble_Activity(ensemble_activity)
end

% Set label time (or just the number of vectors)
if sort_vectors
    xlabel('vectors (sorted)')
else
    if isempty(fps)
        xlabel('vectors')
    else
        frames = size(raster,2);
        Set_Label_Time(frames,fps)
    end
end

% D. Plot ensemble similarity
Set_Axes('axEnsembleSimilarity',[raster_width-0.07 0 1-raster_width+0.03 1-raster_height+0.06]);
Plot_Ensemble_Similarity(ensemble_similarity,p_ensemble)

% (Optional)
if ~isempty(voltage)
    legend_text = {};
    max_y = 15;
    axVoltage = Set_Axes('axvoltage',[0 0.14 raster_width 1-raster_height-0.05]);
    if isfield(voltage,'Locomotion')
        if sort_vectors
            plot(voltage.Locomotion(vector_id),'k')
            xlim([0 length(vector_id)])
        else
            plot(voltage.Locomotion,'k')
            xlim([0 length(voltage.Locomotion)])
        end
        ylabel({'locomotion','[cm/s]'})
        legend_text = {'locomotion'};
    end
    if isfield(voltage,'Licking')
        if sort_vectors
            Plot_Area(rescale(voltage.Licking(vector_id),0,max_y),0,[0.8 0.8 0.8],0.5)
            xlim([0 length(vector_id)])
        else
            Plot_Area(rescale(voltage.Licking,0,max_y),0,[0.8 0.8 0.8],0.5)
            xlim([0 length(voltage.Licking)])
        end        
        legend_text = [legend_text {'licking'}];
        
    end
    if isfield(voltage,'Laser')
        if sort_vectors
            Plot_Area(rescale(voltage.Laser(vector_id),0,max_y),0,[0.3 0.3 0.3],0.5)
        else
            Plot_Area(rescale(voltage.Laser,0,max_y),0,[0.3 0.3 0.3],0.5)
        end
        xlim([0 length(voltage.Laser)])
        legend_text = [legend_text {'laser'}];
    end
    if isfield(voltage,'Stimuli')
        if nnz(voltage.Stimuli)
            if sort_vectors
                stimuli = voltage.Stimuli(vector_id);
            else
                stimuli = voltage.Stimuli;
            end
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
    linkaxes([axRaster axActivity axVoltage],'x'); 
else
    % Link x axis
    linkaxes([axRaster axActivity],'x'); 
end

% Link y axis
linkaxes([axRaster axStructure],'y');
