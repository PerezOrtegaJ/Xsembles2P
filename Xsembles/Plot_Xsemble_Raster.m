function Plot_Xsemble_Raster(data,sort_neurons,sort_vectors,new_figure)
% Plot raster and ensemble activity from a structure variable generated
% from Get_Xsembles()
%
%       Plot_Xsemble_Raster(data,sort_neurons,sort_vectors,new_figure)
%
%       default: sort_neurons = true; sort_vectors = false; new_figure = false;
%
% By Jesus Perez-Ortega, Feb 2023 (based on Plot_Ensemble_Raster)

if nargin<4
    new_figure = false;
    if nargin<3
        sort_vectors = false;
        if nargin<2
            sort_neurons = true;
        end
    end
end

if length(sort_neurons)==1
    neuron_id = data.Analysis.Ensembles.NeuronID;
else
    neuron_id = sort_neurons;
    sort_neurons = true;
end

%% Get data from data structure
raster = data.Analysis.Raster;
vector_id = data.Analysis.Ensembles.VectorID;

if isfield(data.Analysis,'NonEnsembles')
    colors = Read_Colors(data.Analysis.Ensembles.Count+data.Analysis.NonEnsembles.Count);
    color_ensembles = Read_Colors(data.Analysis.Ensembles.Count);
    color_nonensembles = Attenuate_Colors(colors(data.Analysis.Ensembles.Count+1:end,:),2);
    colors = [color_ensembles; color_nonensembles];
    xsemble_activity = [data.Analysis.Ensembles.Activity; data.Analysis.NonEnsembles.Activity];
    ensemble_similarity = [data.Analysis.Ensembles.Similarity data.Analysis.NonEnsembles.Similarity];
    p_ensemble = [data.Analysis.Ensembles.Probability data.Analysis.NonEnsembles.Probability];
    if sort_neurons
        ensemble_structure = [data.Analysis.Ensembles.StructureWeightsSignificant(:,neuron_id);...
                              data.Analysis.NonEnsembles.StructureWeightsSignificant(:,neuron_id)];
    else
        ensemble_structure = [data.Analysis.Ensembles.StructureWeightsSignificant;...
                              data.Analysis.NonEnsembles.StructureWeightsSignificant];
    end
else
    colors = Read_Colors(data.Analysis.Ensembles.Count);
    xsemble_activity = data.Analysis.Ensembles.Activity;
    ensemble_similarity = data.Analysis.Ensembles.Similarity;
    p_ensemble = data.Analysis.Ensembles.Probability;
    if sort_neurons
        ensemble_structure = data.Analysis.Ensembles.StructureWeightsSignificant(:,neuron_id);
    else
        ensemble_structure = data.Analysis.Ensembles.StructureWeightsSignificant;
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
    title([strrep(data.Movie.DataName,'_','-') ' - Raster (time vectors sorted)'])
else
    if sort_neurons
        Plot_Raster(raster(neuron_id,:),'',true,false)
        ylabel('neuron # (sorted)')
    else
        Plot_Raster(raster,'',true,false)
        ylabel('neuron #')
    end
    title([strrep(data.Movie.DataName,'_','-') ' - Raster'])
end
set(gca,'xtick',[])

% B. Plot structure
axStructure = Set_Axes('axXsembleIdentity',[raster_width-0.055 1-raster_height...
    1-raster_width+0.01 raster_height]);
Plot_Ensemble_Structure(ensemble_structure,colors)
title('Neuronal identity')
axis off

% C. Plot ensemble activity
axActivity = Set_Axes('axXsembleActivity',[0 0 raster_width 1-raster_height-0.01]);
if sort_vectors
    Plot_Ensemble_Activity(xsemble_activity(:,vector_id),colors)
else
    Plot_Ensemble_Activity(xsemble_activity,colors)
end

% Set label time (or just the number of vectors)
if sort_vectors
    xlabel('vectors (sorted)')
else
    Set_Label_Time(data.Analysis.Frames,data.Movie.FPS)
end

% D. Plot ensemble similarity
Set_Axes('axXsembleSimilarity',[raster_width-0.07 0 1-raster_width+0.03 1-raster_height+0.06]);
Plot_Ensemble_Similarity(ensemble_similarity,p_ensemble,colors)

% E. Voltage recording
if isfield(data,'VoltageRecording')
    legend_text = {};
    max_y = 15;
    axVoltage = Set_Axes('axdata.VoltageRecording',[0 0.14 raster_width 1-raster_height-0.05]);
    if isfield(data.VoltageRecording,'Locomotion')
        if sort_vectors
            plot(data.VoltageRecording.Locomotion(vector_id),'k')
            xlim([0 length(vector_id)])
        else
            plot(data.VoltageRecording.Locomotion,'k')
            xlim([0 length(data.VoltageRecording.Locomotion)])
        end
        ylabel({'locomotion','[cm/s]'})
        legend_text = {'locomotion'};
    end
    if isfield(data.VoltageRecording,'Licking')
        if sort_vectors
            Plot_Area(rescale(data.VoltageRecording.Licking(vector_id),0,max_y),0,[0.8 0.8 0.8],0.5)
            xlim([0 length(vector_id)])
        else
            Plot_Area(rescale(data.VoltageRecording.Licking,0,max_y),0,[0.8 0.8 0.8],0.5)
            xlim([0 length(data.VoltageRecording.Licking)])
        end        
        legend_text = [legend_text {'licking'}];
        
    end
    if isfield(data.VoltageRecording,'Laser')
        if isfield(data,'Optogenetics')
            laser = data.Optogenetics.Stimulation;
        else
            laser = data.VoltageRecording.Laser;
        end
        if sort_vectors
            Plot_Area(rescale(laser(vector_id),0,max_y),0,[0.3 0.3 0.3],0.5)
        else
            Plot_Area(rescale(laser,0,max_y),0,[0.3 0.3 0.3],0.5)
        end
        xlim([0 length(data.VoltageRecording.Laser)])
        legend_text = [legend_text {'laser'}];
    end
    if isfield(data.VoltageRecording,'Stimuli')
        if nnz(data.VoltageRecording.Stimuli)
            if sort_vectors
                stimuli = data.VoltageRecording.Stimuli(vector_id);
            else
                stimuli = data.VoltageRecording.Stimuli;
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
