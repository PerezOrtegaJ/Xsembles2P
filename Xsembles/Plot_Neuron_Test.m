function Plot_Neuron_Test(data,neuron_id)
% Plot single Ca transients
%
%       Plot_Neuron_Test(data,neuron_id)
%
%
% By Jesus Perez-Ortega, Nov 2022

% Read data 
raw = data.Transients.Raw(neuron_id,:);
f0 = data.Transients.F0(neuron_id,:);
filtered = data.Transients.Filtered(neuron_id,:);
smoothed = data.Transients.Smoothed(neuron_id,:);
inference = data.Transients.Inference(neuron_id,:);
raster = data.Transients.Raster(neuron_id,:);
PSNRdB = data.Transients.PSNRdB(neuron_id);
fps = data.Movie.FPS;
n_frames = length(raw);

% General minmax
min_raw_f0 = min([min(data.Transients.Raw(:)) min(data.Transients.F0(:))]);
max_raw_f0 = max([max(data.Transients.Raw(:)) max(data.Transients.F0(:))]);
max_filtered = max(data.Transients.Filtered(:));
max_inference = max(data.Transients.Inference(:));
%% Plot neuron
% Plot f0 and raw
h(1) = subplot(4,1,1);cla
plot(f0,'color',[0.5 0.5 0.5]); hold on
plot(raw,'k')
xlim([1 n_frames])
ylim([min_raw_f0 max_raw_f0])
set(gca,'xtick',[])
ylabel('fluorescence')
title(['Neuron ' num2str(neuron_id)  ' (PSNR=' num2str(PSNRdB,'%.1f') ' dB)'])

% Plot filtered and smoothed
h(2) = subplot(4,1,2);cla
plot(filtered,'color',[0.5 0.5 0.5]); hold on
plot(smoothed,'k')
xlim([1 n_frames])
ylim([0 max_filtered])
set(gca,'xtick',[])
ylabel('\DeltaF/F_0')

% Plot inference
h(3) = subplot(4,1,3);cla
plot(inference,'k')
xlim([1 n_frames])
ylim([0 max_inference])
ylabel('spike inference')
set(gca,'xtick',[])

% Plot binary identification of activity
h(4) = subplot(4,1,4);cla
Plot_Area(raster,0,[0.5 0.5 0.5],0.5)
yticks([])
xlim([1 n_frames])
ylabel('neuron activity')
Set_Label_Time(n_frames,fps)
linkaxes(h,'x')