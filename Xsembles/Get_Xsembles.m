function analysis = Get_Xsembles(varargin)
% Unsupervised model-free extraction of neuronal ensembles from a binary matrix 
% representing the neuronal activity. ONSEMBLES are significant active neurons and OFFSEMBLES are 
% signficant sienced neurons.
%
%       analysis = Get_Xsembles(raster)
%
%       analysis = Get_Xsembles(raster,Name,Value,...)
%
%       Name-Value Arguments: NetworkBin (default: 1)
%                             NetworkIterations (default: 1000)
%                             NetworkSignificance (default: 0.01)
%                             CoactiveNeuronsThreshold(default: 2)
%                             ClusteringRange (default: 3:10)
%                             ClusteringFixed (default: 0)
%                             EnsembleIterations (default: 1000)
%                             ParallelProcessing (default: true)
%                             FileLog (default: '')
%                             
% By Jesus Perez-Ortega, Aug 2022
% Modified Oct 2022
% Modified May 2023
% Modified Sep 2023 (inputs and functions updated and new, and names renamed)

%% Default values
default_network_bin = 1;
default_network_iterations = 1000;
default_network_significance = 0.05;
default_coactive_neurons_threshold = 2;
default_clustering_range = 3:10;
default_clustering_fixed = 0; % if zero, it will select recommended clusters 
default_iterations_ensemble = 1000;
default_parallel_processing = true;
default_file_log = '';

%% Parse inputs
inputs = inputParser;
valid_pos_num = @(x)isnumeric(x)&&(x>0);
valid_scalar_pos = @(x)isnumeric(x)&&isscalar(x)&&(x>0);
addRequired(inputs,'Raster',@(x)validateattributes(x,{'logical'},{'2d'}))
addParameter(inputs,'NetworkBin',default_network_bin,valid_scalar_pos);
addParameter(inputs,'NetworkIterations',default_network_iterations,valid_scalar_pos);
addParameter(inputs,'NetworkSignificance',default_network_significance,valid_pos_num);
addParameter(inputs,'CoactiveNeuronsThreshold',default_coactive_neurons_threshold,valid_scalar_pos);
addParameter(inputs,'ClusteringRange',default_clustering_range,...
    @(x)validateattributes(x,{'numeric'},{'vector'}));
addParameter(inputs,'ClusteringFixed',default_clustering_fixed,...
    @(x)validateattributes(x,{'numeric'},{'nonnegative'}))
addParameter(inputs,'EnsembleIterations',default_iterations_ensemble,valid_scalar_pos);
addParameter(inputs,'ParallelProcessing',default_parallel_processing,@islogical);
addParameter(inputs,'FileLog',default_file_log,@(x)isstring(x)||ischar(x))
parse(inputs,varargin{:});

% Get parameters
raster = inputs.Results.Raster;
network_bin = inputs.Results.NetworkBin;
network_iterations  = inputs.Results.NetworkIterations;
network_significance = inputs.Results.NetworkSignificance;
coactive_neurons_threshold = inputs.Results.CoactiveNeuronsThreshold;
clustering_range = inputs.Results.ClusteringRange;
clustering_fixed = inputs.Results.ClusteringFixed;
ensemble_iterations = inputs.Results.EnsembleIterations;
parallel_processing = inputs.Results.ParallelProcessing;
file_log = inputs.Results.FileLog;

%% Create a log of computations
if isfile([file_log '_log_XsembleAnalysis.txt'])
    delete([file_log '_log_XsembleAnalysis.txt'])
end
diary([file_log '_log_XsembleAnalysis.txt'])
disp('---Xsembles---')
disp('Extraction of neuronal ensembles (onsembles and offsembles)...')
disp(datetime)
disp('   Saving log in')
disp(['      ' file_log '_log_XsembleAnalysis.txt'])

% Get initial time point
t_initial = tic;

%% Display raster information
[n_neurons,n_frames] = size(raster);
disp('   Analyzing activity from') 
disp(['      ' num2str(n_neurons) ' neurons along ' num2str(n_frames) ' frames...'])

%% Get significant network
tic; disp('   Identifying functional network connectivity...')
disp([    '      iterations = ' num2str(network_iterations)])
disp([    '      p < ' num2str(network_significance)])
disp([    '      bin = ' num2str(network_bin)])
rng(0); % for repeatable results
if parallel_processing
    network = Neuronal_Network_Parallel(raster,network_iterations,network_significance,network_bin);
else
    network = Neuronal_Network(raster,network_iterations,network_significance,network_bin);
end

%% Remove noisy spikes based on functional connections
tic; disp('   Filtering non-significant coactivations...')
[raster_filtered,spikes_fraction_removed] = Filter_Raster_By_Network(raster,network);
t = toc; fprintf('      Done in %.1f s\n',t)

%% Detect coactivations above 2 active neurons
tic; disp('   Finding coactivity...')
disp([     '      coactivation > ' num2str(coactive_neurons_threshold) ' neurons...'])
population_vectors = Find_Peaks(sum(raster_filtered),coactive_neurons_threshold,false);

% Return if no data
if isempty(population_vectors)
    warning('    There is not enough coactivity to extract ensembles.')
    analysis = [];
    return
end
t = toc; fprintf('      Done in %.1f s\n',t)

%% Get neural vectors
tic; disp('   Getting vectors...')
raster_vectors = Get_Peak_Vectors(raster,population_vectors,'binary');
t = toc; fprintf('      Done in %.1f s\n',t)

%% Get similarity
tic; disp('   Getting similarity...')
similarity = Get_Peaks_Similarity(raster_vectors,'jaccard');
if isempty(similarity)
    analysis = [];
    return
end
t = toc; fprintf('      Done in %.1f s\n',t)

%% Get dendrogram tree
tic; disp('   Clustering vectors...')
tree = Linkage_JP(squareform(1-similarity,'tovector'),'ward');
try
    treeID = Dendrogram_Node_Order(tree);
catch
    treeID = 'It was not possible to get the tree ID.';
    warning(treeID)
end
t = toc; fprintf('      Done in %.1f s\n',t)
%% Get number of ensembles
tic; disp('   Evaluating clusters by contrast index...')
[n_recommended,clustering_indices] = Contrast_Test(tree,similarity,clustering_range,'localmax');
if clustering_fixed
    disp(['      Number of clusters fixed to ' num2str(clustering_fixed)])
    n_ensembles = clustering_fixed;
else
    n_ensembles = n_recommended;
end
disp(['      Number of clusters recommended = ' num2str(n_recommended)])
t = toc; fprintf('      Done in %.1f s\n',t)

%% Get n ensembles
tic; disp(['   Extracting ' num2str(n_ensembles) ' ensembles...'])
sequence = cluster(tree,'maxclust',n_ensembles);
t = toc; fprintf('      Done in %.1f s\n',t)

%% Get significant neurons
tic; disp('   Identifying significant activated and silenced neurons for each ensemble...')
[structures,significant_neurons,ensemble_vectors,ensemble_indices]= ...
    Get_Xsemble_Neurons(raster,population_vectors,sequence);

% Get structures
structure_on = structures.Activated;
structure_off = structures.Silenced;
structure_trinary = structures.Trinary;
structure_belongingness = structures.BelongingnessTest;
structure_EPI = structures.EPI;
structure_p = structures.P;

% Get neurons
onsemble_neurons = significant_neurons.Onsemble;
offsemble_neurons = significant_neurons.Offsemble;
t = toc; fprintf('      Done in %.1f s\n',t)

%% Get ensemble networks
tic; disp('   Getting ensemble networks...')
[onsemble_networks,all_onsemble_networks] = Subnetworks(network,onsemble_neurons);
[offsemble_networks,all_offsemble_networks] = Subnetworks(network,offsemble_neurons);
t = toc; fprintf('      Done in %.1f s\n',t)

%% Get ensemble activity
tic; disp('   Getting ensemble activity...')
[ensemble_activity,on_activity,off_activity,structure_weights,structure_weights_significant] =...
    Get_Xsemble_Activity(raster,ensemble_indices,ensemble_vectors,structure_on,structure_off);
t = toc; fprintf('      Done in %.1f s\n',t)

%% Number of ensemble activation and duration
tic; disp('   Getting ensemble durations...')
[widths,n_continuous_activations] = Ensemble_Duration(population_vectors,sequence);
t = toc; fprintf('      Done in %.1f s\n',t)

%% Evaluate similarity within ensemble vectors
tic; disp('   Testing similarity within ensemble vectors...')
disp([    '      iterations = ' num2str(ensemble_iterations)])
% Get similarity within rasters
[within_similarity,vector_count] = Similarity_Within_Rasters(ensemble_vectors);
ensemble_p = Test_Ensemble_Similarity(similarity,within_similarity,n_continuous_activations,ensemble_iterations);

disp([    '      ' num2str(nnz(ensemble_p<0.05)) ' ensembles with similarity p < 0.05'])
t = toc; fprintf('      Done in %.1f s\n',t)

%% Sort ensembles
tic; disp('   Sorting ensembles from high to low participation...')
[~,ensemble_id_sorted,ensemble_avg_weights] = Sort_Ensembles_By_EPI(structure_EPI);

on_activity = on_activity(ensemble_id_sorted,:);
off_activity = off_activity(ensemble_id_sorted,:);
ensemble_activity = ensemble_activity(ensemble_id_sorted,:);
onsemble_networks = onsemble_networks(ensemble_id_sorted);
offsemble_networks = offsemble_networks(ensemble_id_sorted);
ensemble_vectors = ensemble_vectors(ensemble_id_sorted);
ensemble_indices = ensemble_indices(ensemble_id_sorted);
within_similarity = within_similarity(ensemble_id_sorted);
vector_count = vector_count(ensemble_id_sorted);
structure_on = structure_on(ensemble_id_sorted,:);
structure_off = structure_off(ensemble_id_sorted,:);
structure_trinary = structure_trinary(ensemble_id_sorted,:);
structure_belongingness = structure_belongingness(ensemble_id_sorted,:);
structure_EPI = structure_EPI(ensemble_id_sorted,:);
structure_p = structure_p(ensemble_id_sorted,:);    
structure_weights = structure_weights(ensemble_id_sorted,:);
structure_weights_significant = structure_weights_significant(ensemble_id_sorted,:);
onsemble_neurons = onsemble_neurons(ensemble_id_sorted);
offsemble_neurons = offsemble_neurons(ensemble_id_sorted);
widths = widths(ensemble_id_sorted);
n_continuous_activations = n_continuous_activations(ensemble_id_sorted);
ensemble_p = ensemble_p(ensemble_id_sorted);

% Sort neurons
[~,neuron_id] = Sort_Neurons_By_Weights(structure_weights_significant);

% Sort vectors
n_ensemble_activations = zeros(1,n_ensembles);
for i = 1:n_ensembles
    n_ensemble_activations(i) = length(ensemble_indices{i});
end
vector_id = zeros(1,sum(n_ensemble_activations));
activations = cumsum([1 n_ensemble_activations]);
for i = 1:n_ensembles
    vector_id(activations(i):(activations(i+1)-1)) = ensemble_indices{i};
end

% Get ensembles sequence activity
activation_sequence = zeros(1,n_frames);
for i = 1:n_ensembles
    activation_sequence(ensemble_activity(i,:)) = i;
end
t = toc; fprintf('      Done in %.1f s\n',t)

%% Add to analysis structure
disp('   Adding results to ''analysis'' variable output...')

analysis.Options.Network.Bin = network_bin;
analysis.Options.Network.Iterations = network_iterations;
analysis.Options.Network.SignificanceLevel = network_significance;
analysis.Options.Vectors.CoactivityThreshold = coactive_neurons_threshold;
analysis.Options.Clustering.Range = clustering_range;
analysis.Options.Clustering.Fixed = clustering_fixed;
analysis.Options.Ensemble.Iterations = ensemble_iterations;
analysis.Options.ParallelProcessing = parallel_processing;

analysis.Raster = raster;
analysis.Neurons = n_neurons;
analysis.Frames = n_frames;
analysis.Network = network;

analysis.Filter.RasterFiltered = raster_filtered;
analysis.Filter.SpikesFractionRemoved = spikes_fraction_removed;
analysis.Filter.RasterVectors = raster_vectors;
analysis.Filter.VectorID = population_vectors;

analysis.Clustering.Similarity = similarity;
analysis.Clustering.Tree = tree;
analysis.Clustering.TreeID = treeID;
analysis.Clustering.Fixed = clustering_fixed;
analysis.Clustering.RecommendedClusters = n_recommended;
analysis.Clustering.ClusteringRange = clustering_range;
analysis.Clustering.ClusteringIndices = clustering_indices;

analysis.Ensembles.Count = n_ensembles;
analysis.Ensembles.ActivationSequence = activation_sequence;
analysis.Ensembles.Activity = ensemble_activity;
analysis.Ensembles.OnsembleNeurons = onsemble_neurons;
analysis.Ensembles.OffsembleNeurons = offsemble_neurons;
analysis.Ensembles.OnsembleActivity = on_activity;
analysis.Ensembles.OffsembleActivity = off_activity;
analysis.Ensembles.OnsembleNetworks = onsemble_networks;
analysis.Ensembles.OffsembleNetworks = offsemble_networks;
analysis.Ensembles.AllOnsembleNetwork = all_onsemble_networks;
analysis.Ensembles.AllOffsembleNetwork = all_offsemble_networks;
analysis.Ensembles.Vectors = ensemble_vectors;
analysis.Ensembles.Indices = ensemble_indices;
analysis.Ensembles.VectorCount = vector_count;
analysis.Ensembles.Similarity = within_similarity;
analysis.Ensembles.StructureOn = structure_on;
analysis.Ensembles.StructureOff = structure_off;
analysis.Ensembles.StructureTrinary = structure_trinary;
analysis.Ensembles.StructureBelongingness = structure_belongingness;
analysis.Ensembles.StructureP = structure_p;
analysis.Ensembles.StructureWeights = structure_weights;
analysis.Ensembles.StructureWeightsSignificant = structure_weights_significant;
analysis.Ensembles.EPI = structure_EPI;
analysis.Ensembles.Weights = ensemble_avg_weights;
analysis.Ensembles.NeuronID = neuron_id;
analysis.Ensembles.VectorID = vector_id;
analysis.Ensembles.Durations = widths;
analysis.Ensembles.ContinuousActivationCount = n_continuous_activations;
analysis.Ensembles.FrameActivationCount = n_ensemble_activations;
analysis.Ensembles.Probability = ensemble_p;
analysis.Ensembles.Iterations = ensemble_iterations;

% Display the total time
t_final = toc(t_initial);
disp(['You are all set! (total time: ' num2str(t_final) ' seconds)'])
disp(datetime)
analysis.Log = readlines([file_log '_log_XsembleAnalysis.txt']);