function [raster_filtered,fraction_removed] = Filter_Raster_By_Network(raster,network)
% Reduce the noisy spikes from a given raster based on the connectivity
% between neurons
%
%       [raster,fractionRemoved] = Filter_Raster_By_Network(raster,network)
%
% By Jesus Perez-Ortega, Dec 2019
% Modified Oct 2021

% Duplicate raster
raster_filtered = raster;

% Get number of frames
n_frames = size(raster,2);

% Evaluate for each frame
for frame = 1:n_frames
    % Find active neurons on single frame
    active = find(raster(:,frame));

    if ~isempty(active)
        % Identify active neurons without no significant coactivation
        no_significant = find(sum(network(active,active))==0);

        if ~isempty(no_significant)
            % Delete no significant neuronal coactivity from frame
            raster_filtered(active(no_significant),frame) = 0;
        end
    end
end

% Get fraction of removed spikes
n_initial_spikes = sum(raster(:));
n_final_spikes = sum(raster_filtered(:));
removed = n_initial_spikes-n_final_spikes;
fraction_removed = removed/n_initial_spikes;
disp(['      ' num2str(removed) '(' num2str(fraction_removed*100,'%.1f') '%) spikes removed!'])