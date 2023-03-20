function optogenetics = Read_Optogenetics_File(file_name,sampling_period,frames,spatial_resolution)
% Read optogenetic file from XML file generated by prairie
%
%       optogenetics = Read_Optogenetics_File(file_name,sampling_period,frames,spatial_resolution)
%
% By Jesus Perez-Ortega, Feb 2023

% Read XML file
marker_points = xml2struct(file_name);

%% Read every coordinate and point properties

% Get number of coordinates
n_points = length(marker_points.PVMarkPointSeriesElements.PVMarkPointElement);

if n_points==1
    n_points = length(marker_points.PVMarkPointSeriesElements.PVMarkPointElement.PVGalvoPointElement.Point);
    
    if n_points>1
        warning('File with a stimulated neurons grouped... to be done!')
        optogenetics = 'Information not loaded';
        return
    end
end

for i = 1:n_points
    % Get point
    element = marker_points.PVMarkPointSeriesElements.PVMarkPointElement{i};

    if isfield(element.PVGalvoPointElement.Point,'Attributes')
        % Get coordinates
        x = element.PVGalvoPointElement.Point.Attributes.X;
        y = element.PVGalvoPointElement.Point.Attributes.Y;
        xy_all(i,:) = [str2num(x) str2num(y)];
    
        % Get other parameters
        is_spiral(i) = strcmp(element.PVGalvoPointElement.Point.Attributes.IsSpiral,'True');
        revolutions(i) = str2double(element.PVGalvoPointElement.Attributes.SpiralRevolutions);
        radius_um(i) = str2double(element.PVGalvoPointElement.Point.Attributes.SpiralSizeInMicrons)/2;
        radius_px(i) = str2double(element.PVGalvoPointElement.Point.Attributes.SpiralWidth)*spatial_resolution/2;        
    else
        warning('File with a stimulated neurons grouped... to be done!')
        optogenetics = 'Information not loaded';
        return
    end
end

% Rescale coordinates
xy(:,1) = round(xy_all(:,1)*spatial_resolution)+1;
xy(:,2) = round(xy_all(:,2)*spatial_resolution)+1;

% Add optogenetics point properties
optogenetics.File = file_name;
optogenetics.XY = xy;
optogenetics.IsSpiral = is_spiral;
optogenetics.Revolutions = revolutions;
optogenetics.RadiusMicrons = radius_um;
optogenetics.RadiusPixels = radius_px;

%% Build the general signal of stimulation

% Get general iterations
iterations = str2double(marker_points.PVMarkPointSeriesElements.Attributes.Iterations);
iteration_delay_ms = str2double(marker_points.PVMarkPointSeriesElements.Attributes.IterationDelay);

% Initialize the signal
signal_ms = [];

% Get number of coordinates
n_points = length(marker_points.PVMarkPointSeriesElements.PVMarkPointElement);

for i = 1:n_points
    % Get single point data
    point_element = marker_points.PVMarkPointSeriesElements.PVMarkPointElement{i};

    % Get durations
    initial_delay_ms = str2double(point_element.PVGalvoPointElement.Attributes.InitialDelay);
    duration_ms = str2double(point_element.PVGalvoPointElement.Attributes.Duration);
    inter_delay_ms = str2double(point_element.PVGalvoPointElement.Attributes.InterPointDelay);

    % Get repetitions
    repetitions = str2double(point_element.Attributes.Repetitions);
    
    single_point_us = [zeros(1,initial_delay_ms*1000),...
                       repmat([ones(1,duration_ms*1000)*i,zeros(1,inter_delay_ms*1000)],...
                       1,repetitions)];
    single_point_ms = downsample(single_point_us,1000);

    signal_ms = [signal_ms single_point_ms];
end

% Build the signal
stimulation_ms = repmat([signal_ms zeros(1,iteration_delay_ms)],1,iterations);
stimulation = Get_Stimulated_Frames(stimulation_ms,frames,sampling_period*1000,1);

% Add optogenetics signal
optogenetics.Stimulation = stimulation;