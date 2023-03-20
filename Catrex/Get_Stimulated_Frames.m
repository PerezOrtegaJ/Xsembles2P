function laser = Get_Stimulated_Frames(laser_signal,frames,imaging_period_ms,laser_period_ms)
% Get the active frames from laser stimulation
%
%       laser = Get_Stimulated_Frames(laserSignal,frames,msPeriodFrames,msPeriodVoltage)
%
% By Jesus Perez-Ortega, Oct 2019
% Modified Feb 2023

laser_signal = round(laser_signal*10)/10;

% Find the times from signal
activation_times = find(laser_signal)*laser_period_ms;
n_activations = length(activation_times);

% Find frame times
frame_times = imaging_period_ms:imaging_period_ms:(frames*imaging_period_ms);

% Identify each activation
laser = zeros(1,frames);
for i = 1:n_activations
    id = find(frame_times>activation_times(i),1,'first');
    value = laser_signal(activation_times(i));
    laser(id) = value;
end