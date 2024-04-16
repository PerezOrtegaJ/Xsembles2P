function Plot_Neuron_Signal(data,neuron_id,vector_id)
% Plot single Ca transients
%
%       Plot_Neuron_Signal(data,neuron_id,vector_id)
%
%   default: vector_id = [];
%
% By Jesus Perez-Ortega, Nov 2022
% Modified Feb 2023

if nargin==2
    vector_id = [];
end

% Read data 
filtered = data.Transients.Filtered(neuron_id,:);
max_filtered = max(data.Transients.Filtered(:));

if isfield(data.Transients,'Raster')
    raster = data.Transients.Raster(neuron_id,:);
else
    raster = [];
end

fps = data.Movie.FPS;
if isfield(data,'VoltageRecording')
    if isfield(data.VoltageRecording,'Stimuli')
        stimuli = data.VoltageRecording.Stimuli;
    else
        stimuli = [];
    end
    if isfield(data.VoltageRecording,'Locomotion')
        locomotion = data.VoltageRecording.Locomotion;
    else
        locomotion = [];
    end
    if isfield(data.VoltageRecording,'Laser')
        laser = data.VoltageRecording.Laser>0;
    else
        laser = [];
    end
else
    stimuli = [];
    locomotion = [];
    laser = [];
end

if isfield(data,'Optogenetics')
    laser = data.Optogenetics.Stimulation;
end

if isfield(data,'Analysis')
    ensemble_activity = data.Analysis.Ensembles.Activity;
    n_ensembles = data.Analysis.Ensembles.Count;
else
    ensemble_activity = [];
    n_ensembles = 0;
end

if ~isempty(vector_id)
    filtered = filtered(vector_id);
    raster = raster(vector_id);
    stimuli = stimuli(vector_id);
    locomotion = locomotion(vector_id);
    ensemble_activity = ensemble_activity(:,vector_id);
end
n_frames = data.Movie.Frames;

% Get PSNR
PSNRdB = data.Transients.PSNRdB(neuron_id);

%% Plot neuron
% Plot basal and raw
h(1) = subplot(4,1,1);cla
Plot_Area(raster*max_filtered,0,[0.5 0.5 0.5],0.5); hold on
plot(filtered,'k')
xlim([1 n_frames])
ylim([0 max_filtered])
set(gca,'xtick',[])
l1 = legend({'spike inference','calcium signal'});
l1.Position(1) = 0.9;
l1.Position(2) = 0.9;
ylabel('\DeltaF/F_0')
title(['Neuron ' num2str(neuron_id)  ' (PSNR = ' num2str(PSNRdB,'%.0f') ' dB)'])

% Plot laser and visual stimulation
h(2) = subplot(4,1,2);cla
if isempty(laser) || max(laser)==0
    max_value = 1;
else
    max_value = max(laser);
end
plot(laser,'k'); hold on
Plot_Area(rescale(laser,0,max_value),0,[0.3 0.3 0.3],0.5)
legends = Plot_Stimulation(stimuli,max_value,'→↗↑↖←↙↓↘');
xlim([1 n_frames])
set(gca,'xtick',[],'ytick',[])
if isempty(laser)
    l2 = legend(legends);
else
    l2 = legend([{'laser'},legends]);
end
l2.Position(1) = 0.9158;
l2.Position(2) = 0.5230;

ylabel({'visual/optogenetic','stimulation'})

% Plot ensemble activity
h(3) = subplot(4,1,3);cla
Plot_Ensemble_Activity(ensemble_activity)
xlim([1 n_frames])
ylabel(''); title('')
set(gca,'xtick',[],'ytick',[])
if n_ensembles
    legend_text = [];
    for i = 1:n_ensembles
        legend_text = [legend_text {['ensemble ' num2str(i)]}];
    end
    l3 = legend(legend_text);
    l3.Position(1) = 0.02;
    l3.Position(2) = 0.34;
end
ylabel({'ensemble','activity'})

% Plot locomotion
h(4) = subplot(4,1,4);cla
plot(locomotion,'k');hold on
xlim([1 n_frames])
ylabel({'locomotion','(cm/s)'})
if isempty(vector_id)
    Set_Label_Time(n_frames,fps)
else
    xlabel('frames sorted')
end
linkaxes(h,'x')
