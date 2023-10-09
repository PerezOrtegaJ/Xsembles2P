function voltage_recording = Read_Voltage_Recording(file,frame_period,samples)
% Read voltage recording from prairie. It works for names of recordings of
% stimuli, laser and locomotion
%
%       voltage_recording = Read_Voltage_Recording(file,frame_period,samples)
%
%       frame_period = period of each frame
%       samples = samples of the imaging
%
% See also Join_Voltage_Recordings
%
% By Jesus Perez-Ortega, Nov 2019
% Modified March 2021
% Modified Jul 2021
% Modified Sep 2021
% Modified Feb 2022 - interpolation
% Modified Apr 2023 - stimuli>8 orientations

% Disable warning because the header of the time is "Time (ms)"
warning off
dataTable = readtable(file);
warning on

% Get sample rate
voltage_period = diff(dataTable.Time_ms_(1:2))/1000;
voltage_sample_rate = 1/voltage_period;
disp(['   Voltage recording at ' num2str(voltage_sample_rate) ' Hz'])

% Visual stimuli
if ismember('stimuli', dataTable.Properties.VariableNames)

    % Usually: 0.5 V represents 0 deg, 1 V represents 45 deg, and so on... 
    stimuli = round(dataTable.stimuli*2);
    
    % if sample frequencies are the same
    if abs(frame_period-voltage_period)<0.001
        stimuli = stimuli(1:samples);
    else
        % interpolate
        stimuli = round(Interpolate(stimuli,voltage_period,frame_period,samples));

        % If more than usual 8 directions
        if length(unique(stimuli))>9 || nnz(unique(stimuli)>8)
            stimuli = round((dataTable.stimuli-0.5)*90);
            stimuli = round(Interpolate(stimuli,voltage_period,frame_period,samples));
            stimuli(stimuli<0) = nan;
        end
    end

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
    velocity = diff(angles)*diameter/pi*voltage_sample_rate;
    velocity = smooth(velocity,100);

    % interpolate
    locomotion = abs(Interpolate(velocity,voltage_period,frame_period,samples));
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
    laser = Get_Stimulated_Frames(dataTable.laser,samples,frame_period*voltage_sample_rate,...
        voltage_period*1000);
    voltage_recording.Laser = laser;
    disp('   Laser stimulation loaded')
end

% Add file data
voltage_recording.File = file;
voltage_recording.RecordingSampleRate = voltage_sample_rate;
voltage_recording.DownsampledTo = 1/frame_period;
voltage_recording.Method = 'Interpolation';