function Xsembles_2P(varargin)
% Analyze two-photon calcium imaging video(s) to extract neuronal activity and
% identify ensembles (onsembles and offsembles).
%
%       Xsembles_2P()
%
%       Xsembles_2P(FilePath)
%
%       Xsembles_2P(FilePath,...)
% 
% By Jesus Perez-Ortega, Nov 2022
% Modified Sep 2023 (New Get_Xsembles funtion)

%% Default values
default_file_path = '';
default_neuron_radius = 3;      % in pixels
default_sampling_period = 0.1;  % in seconds
default_output_path = '';

% Motion correction
default_motion_correction = true;
default_locomotion_threshold = 1; % cm/s

% Time of binning the spatial mask
default_bin_seconds = 1;

% Threshold to select neurons with enough peak signal to noise ratio (PSNR)
default_select_th_visually = false;
default_thPSNRdB = 10;

% Spike inference algorithm
default_inference_method = 'foopsi';
expected_inference_method = {'foopsi','oasis','derivative'};
default_max_iterations_foopsi = 2;

% Threshold coefficients for spike inference to get the raster
default_inference_th_b = [];

% Neuron ROIs (if given, no neuronal search will be done)
default_neurons = [];

% Identify xsembles (change to false if you just want to get the signals from the raw video)
default_get_xsembles = true;

%% Parse inputs
inputs = inputParser;
valid_pos_num = @(x) isnumeric(x) && (x > 0);
valid_zero_pos_num = @(x) isnumeric(x) && (x >= 0);
valid_scalar_pos = @(x) isnumeric(x) && isscalar(x) && (x > 0);
valid_string = @(x) isstring(x) || ischar(x);
addOptional(inputs,'FilePath',default_file_path,valid_string)
addParameter(inputs,'NeuronRadius',default_neuron_radius,valid_scalar_pos);
addParameter(inputs,'SamplingPeriod',default_sampling_period,valid_pos_num);
addParameter(inputs,'OutputPath',default_output_path,valid_string);
addParameter(inputs,'MotionCorrection',default_motion_correction,@islogical);
addParameter(inputs,'MotionCorrectionThreshold',default_locomotion_threshold,valid_zero_pos_num);
addParameter(inputs,'SpatialMaskBinning',default_bin_seconds,valid_scalar_pos);
addParameter(inputs,'SelectPSNRThresholdVisually',default_select_th_visually,@islogical);
addParameter(inputs,'PSNRdBThreshold',default_thPSNRdB,valid_zero_pos_num);
addParameter(inputs,'InferenceMethod',default_inference_method,...
    @(x) any(validatestring(x,expected_inference_method)));
addParameter(inputs,'MaxIterationsFoopsi',default_max_iterations_foopsi,valid_scalar_pos);
addParameter(inputs,'InferenceThresholdB',default_inference_th_b,valid_zero_pos_num);
addParameter(inputs,'Neurons',default_neurons,@isstruct);
addParameter(inputs,'GetXsembles',default_get_xsembles,@islogical);
parse(inputs,varargin{:});

% Get parameters
file_path = inputs.Results.FilePath;
neuron_radius = inputs.Results.NeuronRadius;
sampling_period = inputs.Results.SamplingPeriod;
output_path = inputs.Results.OutputPath;
motion_correction = inputs.Results.MotionCorrection;
locomotion_threshold = inputs.Results.MotionCorrectionThreshold;
bin_seconds = inputs.Results.SpatialMaskBinning;
select_th_visually = inputs.Results.SelectPSNRThresholdVisually;
thPSNRdB = inputs.Results.PSNRdBThreshold;
inference_method = inputs.Results.InferenceMethod;
max_iterations_foopsi = inputs.Results.MaxIterationsFoopsi;
inference_th_b = inputs.Results.InferenceThresholdB;
neurons = inputs.Results.Neurons;
get_xsembles = inputs.Results.GetXsembles;

%% Get files
warning('off','verbose')
warning('off','backtrace')
if isempty(file_path)
    % Open dialog box
    [file_name,path_name] = uigetfile('*.tif;*.avi','Select one or more videos','Multiselect','on');
    if length(path_name)==1
        warning('No file selected!')
        return;
    end

    if iscell(file_name)
        name = [];
        for i = 1:length(file_name)
            name = [name file_name{i}(1:end-4)];
        end
    else
        name = file_name;
    end
else
    [path_name,name,ext] = fileparts(file_path);
    path_name = [path_name filesep];
    file_name = [name ext];
end

if isempty(output_path)
    output_path = path_name;
end

if isfile([output_path name '_log_Xsembles2P.txt'])
    delete([output_path name '_log_Xsembles2P.txt'])
end
diary([output_path name '_log_Xsembles2P.txt'])

disp('---Xsembles 2P---')
disp(datetime)
disp(['   Path selected: ' path_name])
if iscell(file_name)
    disp('   Files selected: ')
    disp(file_name)
    n_files = length(file_name);
else
    disp(['   File selected: ' file_name])
    file_name = {file_name};
    n_files = 1;
end
disp(['   Sampling period: ' num2str(sampling_period) ' s'])
disp(['   Neuron radius: ' num2str(neuron_radius) ' um'])
disp(['   Output path: ' output_path])

%% Read file(s)

% Read all videos
total_frames = 0;
frames = zeros(n_files,1);
all_mov = [];
for i = 1:n_files
    % Set file path
    file_path = [path_name file_name{i}];
    
    % Read file
    if strcmp(file_name{i}(end-2:end),'avi')
        % Read AVI file
        [mov,prop] = Read_AVI_File(file_path);
    else
        % Read TIF file
        [mov,prop] = Read_Tiff_File(file_path);
    end
    all_mov = cat(3,all_mov,mov);
    total_frames = total_frames+prop.frames;
    frames(i) = prop.frames;
    if i==1
        width = prop.width;
        height = prop.height;
    else
        % Check same size
        if width ~= prop.width
            error('All video files need to be the same width!')
        elseif height ~= prop.height
            error('All video files need to be the same height!')
        end
    end
end

% Assign name based on its cointaining folders (up to 2)
id_path = find(path_name==filesep);
switch length(id_path)
    case 1
        path_file_name = path_name;
    case 2
        path_file_name = path_name(id_path(end-1):end);
    otherwise
        path_file_name = path_name(id_path(end-2):end);
end

% Join names of files analyzed
session_name = '';
for i =1:n_files
    session_name = [session_name file_name{i}(1:end-4)];
end
data_name = Validate_Name([path_file_name '_' session_name]);

% Write data in workspace
data.Movie.FilePath = path_name;
data.Movie.FileName = file_name;
data.Movie.DataName = data_name;
data.Movie.SessionName = session_name;
data.Movie.Width = width;
data.Movie.Height = height;
data.Movie.Depth = prop.depth;
data.Movie.Frames = total_frames;
data.Movie.Images = all_mov;
data.Movie.FPS = 1/sampling_period; 
data.Movie.Period = sampling_period; 
data.ROIs.NeuronRadius = neuron_radius;

% Get voltage recordings
for i = 1:n_files
    % Set file path
    file_path = [path_name file_name{i}];
    file_voltage = [file_path(1:end-3) 'csv'];
    if exist(file_voltage,'file')
        if i==1
            disp('Loading voltage recording file...')
            data.VoltageRecording = Read_Voltage_Recording(file_voltage,sampling_period,frames(i));
        else
            voltage_extra = Read_Voltage_Recording(file_voltage,sampling_period,frames(i));
            data.VoltageRecording = Join_Voltage_Recordings(data.VoltageRecording,voltage_extra);
        end
    else
        warning('No voltage recording loaded!')
        if isfield(data,'VoltageRecording')
            data = rmfield(data,'VoltageRecording');
        end
        break
    end
end

% Get optogenetic stimulation file
for i = 1:n_files
    % Set file path
    file_path = [path_name file_name{i}];
    file_stim = [file_path(1:end-3) 'xml'];
    if exist(file_stim,'file')
        if i==1
            disp('Loading optogenetic stimulation file...')
            data.Optogenetics = Read_Optogenetics_File(file_stim,sampling_period,frames(i),height);
        else
            optogenetics_extra = Read_Optogenetics_File(file_stim,sampling_period,frames(i),height);
            data.Optogenetics = Join_Optogenetics_File(data.VoltageRecording,optogenetics_extra);
        end
        disp('   Optogenetic stimulation data loaded')
    else
        warning('No optogenetic stimulation file loaded!')
        if isfield(data,'Optogenetics')
            data = rmfield(data,'Optogenetics');
        end
        break
    end
end

%% Fast registration
if motion_correction
    if isfield(data,'VoltageRecording')    
        % Motion correction
        disp('Adjusting motion (rigid)...')
        data.Movie.Images = Fast_Registration(data.Movie.Images,data.VoltageRecording.Locomotion,...
            locomotion_threshold,data.Movie.FPS,'rigid');
        data.Movie.ImagesRegistered = true;
        data.Movie.RegistrationMethod = 'rigid';
        data.Movie.RegistrationLocomotionThreshold = locomotion_threshold;

        % Save video
        disp('Saving video...')
        tic
        movefile([output_path session_name '.tif'],[output_path session_name '_raw.tif']);
        Save_Tiff_Fast(data.Movie.Images,[output_path session_name '.tif'])
        t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    else
        warning('There is no voltage recording, so it is not possible to do a fast registration!')
    end
end

%% Finding neurons
if isempty(neurons)
    %% Normalize movie
    % Read data
    height = data.Movie.Height;
    width = data.Movie.Width;
    neuron_diameter = neuron_radius*2;
    
    tic; disp('Normalizing movie...')
    [normalized,maxMovie,meanMovie,stdMovie,PSNR] = Normalize_Movie(data.Movie.Images);
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    
    % Write data
    data.Movie.Norm = normalized;
    data.Movie.ImageMaximum = maxMovie;
    data.Movie.ImageAverage = meanMovie;
    data.Movie.ImageSTD = stdMovie;
    data.Movie.ImagePSNR = PSNR;
    
    %% Get spatial mask
    tic; disp('Computing spatial mask...')
    [U_smoothed,U_raw] = Get_Spatial_Mask(data.Movie.Images,...
        data.Movie.Norm,bin_seconds,data.Movie.FPS);
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
    
    % Write data
    data.ROIs.SpatialMaskSmoothed = U_smoothed;
    data.ROIs.SpatialMask = U_raw;

    %% Find neurons
    tic; disp(['Finding neurons of ' num2str(neuron_diameter) ' pixels of diameter...'])
    [neuron_rois,summary,options] = Find_Cells_J2P(U_smoothed,U_raw,neuron_diameter);
    disp(['    ' num2str(length(neuron_rois)) ' neurons found.'])
    
    % Try to find more neurons -1 pixel of diameter
    disp(['Finding neurons of ' num2str(neuron_diameter-1) ' pixels of diameter...'])
    [neuronalData_extra,~,extra_options{1}] = Find_Cells_J2P(U_smoothed,U_raw,neuron_diameter-1);
    disp(['    ' num2str(length(neuronalData_extra)) ' neurons found.'])
    disp('Combining neurons')
    neuron_rois = Combine_Neurons(neuron_rois,neuronalData_extra,neuron_radius);
    
    % Try to find more neurons +1 pixel of diameter
    disp(['Finding neurons of ' num2str(neuron_diameter+1) ' pixels of diameter...'])
    [neuronalData_extra,~,extra_options{2}] = Find_Cells_J2P(U_smoothed,U_raw,neuron_diameter+1);
    disp(['    ' num2str(length(neuronalData_extra)) ' neurons found.'])
    disp('Combining neurons')
    neuron_rois = Combine_Neurons(neuron_rois,neuronalData_extra,neuron_radius);
    
    % Sort neurons
    neuron_rois = Sort_Neuron_Data(neuron_rois);
    disp(['   TOTAL of ROIs found: ' num2str(length(neuron_rois))])

    % Evaluate ROIs found
    disp('Evaluating shape of neurons...')

    % Criteria to evaluate the shape of ROIs (neurons) found
    minArea = pi*neuron_radius^2/2;
    maxArea = minArea*8;
    outline = neuron_radius;
    minCircularity = 0.2;
    maxPerimeter = 3*pi*neuron_radius;
    maxEccentricity = 0.9;
    neuron_rois = Evaluate_Neurons(neuron_rois,minArea,maxArea,minCircularity,maxPerimeter,...
        maxEccentricity,width,height,outline);
    
    % Get overlaping
    neuron_rois = Get_Overlaping(neuron_rois,width,height);
    
    % Write constrains
    criteria.MinimumPixels = minArea;
    criteria.MaximumPixels = maxArea;
    criteria.Outline = outline;
    criteria.MinimumCircularity = minCircularity;
    criteria.MaxPerimeter = maxPerimeter;
    criteria.MaxEccentricity = maxEccentricity;
    
    disp(['   ROIs after evaluation: ' num2str(length(neuron_rois))])
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])

    % Write data
    data.ROIs.SearchOptions = options;
    data.ROIs.ExtraSearchOptions = extra_options;
    data.ROIs.EvaluationCriteria = criteria;
    data.ROIs.GivenROIs = false;
    data.Movie.Summary = summary;
else
    tic;disp(['Reading ' num2str(length(neurons)) ' ROIs given.'])
    neuron_rois = neurons;

    % Write data
    data.Movie.Norm = [];
    data.ROIs.SpatialMaskSmoothed = [];
    data.ROIs.SpatialMask = [];
    data.ROIs.SearchOptions = [];
    data.ROIs.ExtraSearchOptions = [];
    data.ROIs.EvaluationCriteria = 'neurons loaded from variable';
    data.ROIs.GivenROIs = true;
    data.Movie.Summary = [];
    t=toc; disp(['   Done (' num2str(t) ' seconds)'])
end

% Write data
data.XY.All = [neuron_rois.x_median; neuron_rois.y_median]';
data.Neurons = neuron_rois;

%% Get transients
% Get masks
tic; disp('Generating neuropil mask...')
neuropil = Get_Neuropil_Mask(data.Neurons,[height width]);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])

tic; disp('Creating neuronal and neuropil masks...')
neuropil_radius = 10*neuron_radius;
[cellMasks,auraMasks,cellWMasks] = Get_Neuronal_Masks(data.Neurons,neuropil,...
    neuropil_radius,[height width]);
cellMaskImage = sum(cellMasks,3);
cellWMaskImage = sum(cellWMasks,3);
auraMaskImage = sum(auraMasks,3);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])

% Get calcium signals
n_neurons = length(data.Neurons);
estimated_time = round(n_neurons*total_frames*4.6e-06);
tic; fprintf('Computing transients from %i cells... (estimated time: %i s)\n',...
    n_neurons,estimated_time)

[filtered,raw,f0,field] = Get_Transients(data.Movie.Images,...
   cellWMasks,auraMasks);

% Smooth transients (1 s window)
smoothed = Smooth_Transients(filtered,round(data.Movie.FPS));

% Get Peak signal-to-noise ratio PSNR max(S-N)/std(N)
% based on https://en.wikipedia.org/wiki/Signal-to-noise_ratio_(imaging)
PSNR = max((raw-f0),[],2)./std(f0,[],2);
PSNR(PSNR<1) = 1;
PSNRdB = 20*log10(PSNR); % converting to dB (Added on Aug 2021)

t=toc; disp(['   Done (' num2str(t) ' seconds)'])

% Write data in workspace
for i = 1:n_neurons
    data.Neurons(i).PSNRdB = PSNRdB(i);
end
data.ROIs.NeuropilRadius = neuropil_radius;
data.ROIs.CellMasks = cellMasks;
data.ROIs.CellWeightedMasks = cellWMasks;
data.ROIs.AuraMasks = auraMasks;
data.ROIs.CellMasksImage = cellMaskImage;
data.ROIs.CellWeightedMasksImage = cellWMaskImage;
data.ROIs.AuraMasksImage = auraMaskImage;
data.ROIs.NeuropilMask = reshape(neuropil,height,width);
data.Transients.Raw = raw;
data.Transients.Filtered = filtered;
data.Transients.Smoothed = smoothed;
data.Transients.F0 = f0;
data.Transients.Field = field;
data.Transients.Cells = n_neurons;
data.Transients.PSNRdB = PSNRdB;

%% Get inference

% dB = 20*log10(PSNR)
% Rose criterion (https://en.wikipedia.org/wiki/Signal-to-noise_ratio_(imaging)):
%                - 5dB is needed to distinguish features with certainty
%                - 10 dB 'acceptable'
%                - 40 dB 'excellent' 

if select_th_visually
    tic; disp('Waiting for selecting a PSNR trheshold...')
    thPSNRdB = Select_Neuron_Threshold(data);
    fprintf('   PSNR threshold set to: %i \n',thPSNRdB)
end

id = find(data.Transients.PSNRdB>thPSNRdB);
n_final = length(id);

tic;
fprintf('Doing spike inference from %i of %i cells above %i dB PSNR...\n',...
    n_final,n_neurons,thPSNRdB)

% Preprocess data with median, minimum, and maximum moving filter of 500 ms window
preprocessed = Preprocessing(data.Transients.Filtered,data.Movie.FPS);

% Get spike inference
[inf,mdl] = Get_Spike_Inference(preprocessed(id,:),inference_method,max_iterations_foopsi);

% Assign to the variables
inference = zeros(n_neurons,total_frames);
inference(id,:) = inf;
model = zeros(n_neurons,total_frames);
model(id,:) = mdl;    
t=toc; disp(['   Done (' num2str(t) ' seconds)'])

% Write data
data.Transients.Preprocessed = preprocessed;
data.Transients.Preprocessing = 'med min max 500ms';
data.Transients.Inference = inference;
data.Transients.Model = model;
data.Transients.InferenceMethod = inference_method;
data.Transients.ThresholdPSNR = thPSNRdB;
    
%% Get Raster
n_neurons = length(data.Neurons);
tic; fprintf('Getting raster from %i neurons...\n',n_neurons)

% [raster,inference_thresholded,inference_th,inference_th_b] = Get_Raster_From_Inference(...
%     data.Transients.Inference,data.Transients.PSNRdB,inference_th_b);
[raster,inference_thresholded,inference_th,inference_th_b] = Get_Raster_From_Inference(...
    data.Transients.Inference,data.Transients.PSNRdB,inference_th_b);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])

% Write data
data.Transients.Raster = raster;
data.Transients.InferenceTh = inference_thresholded;
% data.Transients.SameThreshold = inference_same_th;
% data.Transients.Threshold = inference_th;
data.Transients.SameThreshold = false;
data.Transients.Threshold = inference_th;
data.Transients.ThresholdLinearModelB = inference_th_b;
data.Transients.InferenceThresholdMethod = 'Inference threshold proportionally to PSNRdB';

%% Remove inactive neurons
% Do not remove neurons if given ROIs
if ~data.ROIs.GivenROIs
    active = sum(raster,2)>0;
    
    % Remove from Neurons vairable
    data.DiscardedNeurons = data.Neurons(~active);
    data.Neurons = data.Neurons(active);
    
    % Remove from Transients
    data.Transients.Raw = data.Transients.Raw(active,:);
    data.Transients.Filtered =data.Transients.Filtered(active,:);
    data.Transients.Smoothed = data.Transients.Smoothed(active,:);
    data.Transients.F0 = data.Transients.F0(active,:);
    data.Transients.Cells = nnz(active);
    data.Transients.PSNRdB = data.Transients.PSNRdB(active);
    data.Transients.Inference = data.Transients.Inference(active,:);
    data.Transients.Model = data.Transients.Model(active,:);
    data.Transients.Raster = data.Transients.Raster(active,:);
    data.Transients.InferenceTh = data.Transients.InferenceTh(active,:);
    
    % Remove from ROIs
    data.ROIs.CellMasks = data.ROIs.CellMasks(:,:,active);
    data.ROIs.CellWeightedMasks = data.ROIs.CellWeightedMasks(:,:,active);
    data.ROIs.AuraMasks = data.ROIs.AuraMasks(:,:,active);
    data.ROIs.CellMasksImage = sum(data.ROIs.CellMasks,3);
    data.ROIs.CellWeightedMasksImage = sum(data.ROIs.CellWeightedMasks,3);
    data.ROIs.AuraMasksImage = sum(data.ROIs.AuraMasks,3);
    
    % Remove from XY
    data.XY.All = data.XY.All(active,:);
    
    % Display neurons removed
    disp([num2str(nnz(~active)) ' neurons removed'])
end

%% Write log
disp(datetime)
data.Log = readlines([output_path name '_log_Xsembles2P.txt']);

%% Get ensembles
if get_xsembles
    %data.Analysis = Get_Xsembles(data.Transients.Raster,[],[output_path name]);
    data.Analysis = Get_Xsembles(data.Transients.Raster,'FileLog',[output_path name]);
end

%% Save data in file
tic
disp('Saving results in file (without video)...')
data.Movie = rmfield(data.Movie,'Images');
data.Movie = rmfield(data.Movie,'Norm');
data.ROIs = rmfield(data.ROIs,'SpatialMaskSmoothed');
data.ROIs = rmfield(data.ROIs,'SpatialMask');
data.ROIs = rmfield(data.ROIs,'SearchOptions');
data.ROIs = rmfield(data.ROIs,'ExtraSearchOptions');
data.ROIs = rmfield(data.ROIs,'CellMasks');
data.ROIs = rmfield(data.ROIs,'CellWeightedMasks');
data.ROIs = rmfield(data.ROIs,'AuraMasks');

% Write data in both workspaces
assignin('base',['data_' data.Movie.DataName],data);
eval(['data_' data.Movie.DataName '=data;']);

% Save data
save([output_path data.Movie.SessionName],['data_' data.Movie.DataName],'-v7.3')
    
t = toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Plot ensembles
if isfield(data,'Analysis')
    tic
    disp('Plot and saving figure...')

    Set_Figure(data.Movie.DataName,[0 0 1200 700])
    Plot_Xsemble_Raster(data,true,false)

    savefig([output_path  data.Movie.SessionName '.fig'])
    t = toc; disp(['   Done (' num2str(t) ' seconds)'])
end
