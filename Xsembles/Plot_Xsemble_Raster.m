function Plot_Xsemble_Raster(data,sort_neurons,sort_vectors,new_figure)
% Plot raster and ensemble activity from a structure variable generated
% from Get_Xsembles()
%
%       Plot_Xsemble_Raster(data,sort_neurons,sort_vectors,new_figure)
%
%       default: sort_neurons = true; sort_vectors = false; new_figure = false;
%
% By Jesus Perez-Ortega, Feb 2023 (based on Plot_Ensemble_Raster)
% Modified, Sep 2023 (Bug Fixed when sorting id>1,
%                     Vector_and_Neuron_ID function and trinary_structure added)

if nargin<4
    new_figure = false;
    if nargin<3
        sort_vectors = false;
        if nargin<2
            sort_neurons = true;
        end
    end
end

% Sorting vectors ('ori' selected for oriented stimuli)
[vector_id_sorted,neuron_id_sorted,ensemble_id] = Vector_and_Neuron_ID(data,'none');

if length(sort_neurons)==1
    if sort_neurons
        neuron_id = neuron_id_sorted;
        %neuron_id = data.Analysis.Ensembles.NeuronID;
    else
        neuron_id = 1:data.Analysis.Neurons;
    end
else
    neuron_id = sort_neurons;
    sort_neurons = true;
end

if length(sort_vectors)==1
    if sort_vectors
        %vector_id = data.Analysis.Ensembles.VectorID;
        vector_id = vector_id_sorted;
    else
        vector_id = 1:data.Movie.Frames;
    end
else
    vector_id = sort_vectors;
    sort_vectors = true;
end


%% Get data from data structure
raster = data.Analysis.Raster;
colors = Read_Colors(data.Analysis.Ensembles.Count);
xsemble_activity = data.Analysis.Ensembles.Activity(ensemble_id,:);
ensemble_similarity = data.Analysis.Ensembles.Similarity(ensemble_id);
p_ensemble = data.Analysis.Ensembles.Probability(ensemble_id);
onsemble_structure = data.Analysis.Ensembles.StructureOn(ensemble_id,neuron_id);
offsemble_structure = data.Analysis.Ensembles.StructureOff(ensemble_id,neuron_id);
%ensemble_structure = data.Analysis.Ensembles.StructureWeightsSignificant(:,neuron_id);
ensemble_structure = double(onsemble_structure);
ensemble_structure(offsemble_structure) = -1;


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
raster_height = 0.75;
raster_width = 0.9;

% A. Plot raster
axis_raster = Set_Axes('ax_raster',[0 1-raster_height raster_width raster_height]);

Plot_Raster(raster(neuron_id,vector_id),'',true,false)
if sort_vectors
    if sort_neurons
        ylabel('neuron # (sorted)')
    else
        ylabel('neuron #')
    end
    title([strrep(data.Movie.DataName,'_','-') ' - Raster (time vectors sorted)'])
else
    if sort_neurons
        ylabel('neuron # (sorted)')
    else
        ylabel('neuron #')
    end
    title([strrep(data.Movie.DataName,'_','-') ' - Raster'])
end
set(gca,'xtick',[])

% B. Plot structure
axis_structure = Set_Axes('ax_ensemble_identity',[raster_width-0.055 1-raster_height...
    1-raster_width+0.01 raster_height]);
Plot_Ensemble_Structure(ensemble_structure,colors)
%Plot_Ensemble_Structure(ensemble_structure,'red-blue')
title({'Neuronal participation','on light | off dark'})
axis off

% C. Plot ensemble activity
axis_activity = Set_Axes('ax_xsemble_activity',[0 0 raster_width 0.1]);
all_x_axis = [axis_raster axis_activity]; 
Plot_Ensemble_Activity(xsemble_activity(:,vector_id),colors)
ylabel(''); title(''); yticks([])
text(0,0.5,'ensemble activity','HorizontalAlignment','right')

% Set label time (or just the number of vectors)
if sort_vectors
    xlabel('vectors (sorted)')
else
    Set_Label_Time(data.Analysis.Frames,data.Movie.FPS)
end

% D. Plot ensemble similarity
Set_Axes('ax_xsemble_similarity',[raster_width-0.07 0 1-raster_width+0.03 1-raster_height+0.06]);
Plot_Ensemble_Similarity(ensemble_similarity,p_ensemble,colors)

% E. Voltage recording
if isfield(data,'VoltageRecording')
    axis_voltage = [];
    % Visual stimulation
    if isfield(data.VoltageRecording,'Stimuli')
        if nnz(data.VoltageRecording.Stimuli)
            axis_voltage(end+1) = Set_Axes('ax_voltage_stimuli',[0 0.29 raster_width 0.05]);
            stim_text = '→↗↑↖←↙↓↘';
            legends = Plot_Stimulation(data.VoltageRecording.Stimuli(vector_id),1,stim_text);
            axis off
            text(0,0.5,'visual stimulation','HorizontalAlignment','right')
            hl2 = legend(legends);
            hl2.Position(1) = 0.0525;
            hl2.Position(2) = 0.342;
        end
    end

    % Laser
    if isfield(data.VoltageRecording,'Laser')
        if nnz(data.VoltageRecording.Laser)
            axis_voltage(end+1) = Set_Axes('ax_voltage_laser',[0 0.27 raster_width 0.05]);
            if isfield(data,'Optogenetics')
                if isfield(data.Optogenetics,'Stimulation')
                    laser = data.Optogenetics.Stimulation;
                else
                    laser = data.VoltageRecording.Laser;
                end
            else
                laser = data.VoltageRecording.Laser;
            end
            Plot_Area(laser(vector_id))
            axis off
            text(0,max(laser)/2,'laser','HorizontalAlignment','right')
        end
    end

    % Face
    if isfield(data,'Face')
        % Blinking
        axis_voltage(end+1) = Set_Axes('ax_face_blinking',[0 0.25 raster_width 0.05]);
        Plot_Area(data.Face.Blinking(vector_id))
        axis off
        text(0,0.5,'blinking','HorizontalAlignment','right')

        % Sniffing
        axis_voltage(end+1) = Set_Axes('ax_face_sniffing',[0 0.23 raster_width 0.05]);
        Plot_Area(data.Face.Sniffing(vector_id),0,[0.5 0.5 0.5])
        axis off
        text(0,0.5,'sniffing','HorizontalAlignment','right')

        % Whiskers
        axis_voltage(end+1) = Set_Axes('ax_face_whiskers',[0 0.08 raster_width 0.1]); hold on
        motion_energy = data.Face.Whiskers.Energy;
        plot(motion_energy(vector_id),'color',[0.5 0.5 0.5])
        plot([0 0],[0 round(max(motion_energy))],'k')
        axis off
        text(0,max(get(gca,'YLim'))/2,{'whisker energy';[num2str(round(max(motion_energy))) ...
            ' |\Delta intensity|']},'HorizontalAlignment','right')
        if max(motion_energy)<5
            ylim([0 5])
        end
    end

    % Licking
    if isfield(data.VoltageRecording,'Licking')
        if nnz(data.VoltageRecording.Licking)
            axis_voltage(end+1) = Set_Axes('ax_voltage_licking',[0 0.21 raster_width 0.05]);
            Plot_Area(data.VoltageRecording.Licking(vector_id))
            axis off
            text(0,0.5,'licking','HorizontalAlignment','right')
        end
    end
    
    % Locomotion
    if isfield(data.VoltageRecording,'Locomotion')
        axis_voltage(end+1) = Set_Axes('ax_voltage_locomotion',[0 0.15 raster_width 0.1]); hold on
        locomotion = data.VoltageRecording.Locomotion;
        plot(locomotion(vector_id),'color',[0.3 0.3 0.3])
        plot([0 0],[0 round(max(locomotion))],'k')
        axis off
        text(0,max(get(gca,'YLim'))/2,{'running speed';[num2str(round(max(locomotion))) ' cm/s']},...
            'HorizontalAlignment','right')
        if max(locomotion)<5
            ylim([0 5])
        end
    end

    % combine all axis
    all_x_axis = [all_x_axis axis_voltage]; 
end

% if isfield(data,'Pupil')
%     axis_pupil = Set_Axes('ax_pupil',[0 0.08 raster_width 0.1]); hold on
%     all_x_axis = [all_x_axis axis_pupil]; 
%     radius = data.Pupil.Radius;
%     if sort_vectors
%         plot(radius(vector_id),'k')
%     else
%         plot(radius,'k')
%     end
%     plot([0 0],[0 round(max(radius))],'k')
%     axis off
%     text(0,max(get(gca,'YLim'))/2,{'pupil radius';[num2str(round(max(radius))) ' pixels']},...
%         'HorizontalAlignment','right')
% end

% Link x axis
linkaxes(all_x_axis,'x');
xlim(axis_raster,[0 data.Movie.Frames])

% Link y axis
linkaxes([axis_raster axis_structure],'y');
