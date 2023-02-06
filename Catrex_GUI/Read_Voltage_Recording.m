function voltage_recording = Read_Voltage_Recording(file,period,samples)
% Read voltage recording from prairie. It works for names of recordings of
% stimuli, laser and locomotion
%
%       voltage_recording = Read_Voltage_Recording(file,period,samples)
%
%       period = period of each frame
%       samples = samples of the imaging
%
% See also Join_Voltage_Recordings
%
% By Jesus Perez-Ortega, Nov 2019
% Modified March 2021
% Modified Jul 2021
% Modified Sep 2021
% Modified Feb 2022 - interpolation

% Disable warning because the header of the time is "Time (ms)"
warning off
dataTable = readtable(file);
warning on

% Get sample rate
msPeriod = diff(dataTable.Time_ms_(1:2));
sample_rate_voltage = 1000/msPeriod;
disp(['   Voltage recording at ' num2str(sample_rate_voltage) ' Hz'])

% Visual stimuli
if ismember('stimuli', dataTable.Properties.VariableNames)
    stimuli = round(dataTable.stimuli*2);

    % if sample frequencies are the same
    if abs(period*1000-msPeriod)<1
        stimuli = stimuli(1:samples);
    else
        % interpolate
        limit = floor(period*samples*1000);
        t = 0:limit;
        stim = stimuli(1:length(t));
        step = period*1000;
        t2 = 0:step:limit;
        t2 = t2(1:samples);
        stimuli = round(interp1(t,stim,t2));
    end

    % this was used previously when images were taken at ms round (vg 81 ms period)
    %stimuli = downsample(round(stimuli),round(period*sample_rate_voltage));
    %stimuli = stimuli(1:samples);

    voltage_recording.Stimuli = stimuli;
    disp('   Visual stimulation loaded')
end

% Frequency of drifting gratings
if ismember('frequency', dataTable.Properties.VariableNames)
    freq = dataTable.frequency;
    freq = freq(1:samples);
    voltage_recording.Frequency = freq;
    disp('   Frequency loaded')
end


% Locomotion from wheel recording
if ismember('locomotion', dataTable.Properties.VariableNames)
    % Get locomotion in cm/s
    locomotion = dataTable.locomotion;
    diameter = 6;           % cm (diameter of the wheel)
    min_locomotion = min([locomotion; 0.5]);
    max_locomotion = max([locomotion; 4.5]);
    range = max_locomotion-min_locomotion;
    angles = unwrap((locomotion-min_locomotion)/range*2*pi);
    velocity = diff(angles)*diameter/pi*sample_rate_voltage;
    velocity = smooth(velocity,100);

    % interpolate
    limit = round(period*samples*1000);
    t = 0:limit;
    v = velocity(1:length(t));
    step = period*1000;
    t2 = 0:step:limit;
    t2 = t2(1:samples);
    locomotion = interp1(t,v,t2);

    % previous version
    %locomotion = downsample(velocity,round(period*sample_rate_voltage));
    %locomotion = locomotion(1:samples);

    locomotion = abs(locomotion);
    voltage_recording.Locomotion = locomotion;
    disp('   Locomotion loaded')
end

% Locomotion already in cm/s
if ismember('locomotion_cm_s_', dataTable.Properties.VariableNames)
    locomotion = dataTable.locomotion_cm_s_;
    locomotion = abs(locomotion(1:samples));
    voltage_recording.Locomotion = locomotion;
    disp('   Locomotion loaded')
end

% Laser stimulation
if ismember('laser', dataTable.Properties.VariableNames)
    laser = Get_Stimulated_Frames(dataTable.laser,samples,period*sample_rate_voltage,msPeriod);
    voltage_recording.Laser = laser;
    disp('   Laser stimulation loaded')
end

% Add file data
voltage_recording.File = file;
voltage_recording.RecordingSampleRate = sample_rate_voltage;
voltage_recording.DownsampledTo = 1/period;
voltage_recording.Method = 'Interpolation';