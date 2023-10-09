function [network,coactivity,th,surrogate_coactivity] = ...
    Neuronal_Network_Parallel(raster,iterations,alpha,bin)
% Get neuronal network from raster (using parallel pool)
%
%       [network,coactivity,th,surrogate_coactivity] = Neuronal_Network_Parallel(raster,iterations,alpha,bin)
%
%       default: iterations = 1000; alpha = 0.05; bin = 1
%
% Jesus Perez-Ortega, Sep 2023
% Modified from 'Get_Significant_Network_From_Raster.m'

tic
if nargin<4
    bin = 1;
    if nargin<3
        alpha = 0.05;
        if nargin<2
            iterations = 1000;
        end
    end
end

% Reduce raster in bin
if bin>1
    raster = Reshape_Raster(raster,bin);
end

% Get original adjacency network
coactivity = Pairwise_Coactivity(raster);

% Random versions
n_neurons = length(coactivity);
surrogate_coactivity = zeros(iterations,(n_neurons^2-n_neurons)/2);
q = parallel.pool.DataQueue;
afterEach(q,@count_iterations);
iterations_processed = 0;
disp('   Shuffling data (parallel processing)...')
parfor i = 1:iterations
    shuffled = Shuffle_Raster(raster,true);

    if bin>1
        shuffled = Reshape_Raster(shuffled,bin);
    end

    surrogate_coactivity(i,:) = squareform(Pairwise_Coactivity(shuffled),...
        'tovector');
    
    % Show the state of computation each 100 frames
    send(q,1)
end

% Set a pairwise threshold
n_edges = size(surrogate_coactivity,2);
th = zeros(1,n_edges);
parfor i = 1:n_edges
    th(i) = Coactivity_Threshold(surrogate_coactivity(:,i),alpha);
end
th = squareform(th);

% Get significant adjacency
network = coactivity>th;
t = toc; 
fprintf('   Done in %.1f s\n',t)

    % Nested function to count iterations
    function count_iterations(~)
        iterations_processed = iterations_processed+1;
        if ~mod(iterations_processed,100)
            t = toc; 
            fprintf('      %d/%d iterations, %.1f s\n',iterations_processed,iterations,t)
        end
    end
end
