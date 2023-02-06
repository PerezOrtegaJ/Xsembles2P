function p = Test_Ensemble_Similarity(sim_matrix,sim_ensembles,count_ensembles,iterations)
% Test significance of similarity between vectors of ensembles
%
%       p = Test_Ensemble_Similarity(sim_matrix,sim_ensembles,count_ensembles,iterations)
%
%       default: iterations = 1000
%
% By Jesus Perez-Ortega, Oct 2021

switch nargin
    case 3
        iterations = 1000;
end

% Get number of vectors
n_vectors = length(sim_matrix);

% Get average of similarities
rng(0)
for i = 1:iterations
    % Shuffle vectors
    vector_id = randperm(n_vectors);
    vector_i = vector_id(1);
    group_i = sim_matrix(vector_i,vector_id(2:end));
    
    % Get average similarity from 2 to n_vectors
    sum_vectors = cumsum(group_i);
    avg_sim(i,:) = sum_vectors./(1:n_vectors-1);
end

% Get probability for each ensemble

% Get number of ensembles
n_ensembles = length(sim_ensembles);

for i = 1:n_ensembles
    ensemble_sim = sim_ensembles(i);
    ensemble_count = count_ensembles(i);
    selected = avg_sim(:,ensemble_count);
    pd = fitdist(selected,'normal');
    mu = pd.mu;
    sigma = pd.sigma;
    % [~,pCov] = normlike([mu,sigma],selected); % this is for confidence intervals (pLo and pUp)
    % [p,pLo,pUp] = normcdf(ensemble_sim,mu,sigma,pCov);
    p(i) = 1-normcdf(ensemble_sim,mu,sigma);
end

