function preprocessed = Preprocessing(transients,fps)
% Preprocess calcium signals for spike inference
%
%       preprocessed = Preprocessing(transients,fps)
%
% 1. Moving median filter (500 ms)
% 2. Moving minimum filter (500 ms)
% 3. Moving maximum filter (500 ms)
%
% By Jesus Perez-Ortega, Mar 2022

switch nargin
    case 1
        bin = 6;
    case 2
        % bin 500 ms
        bin = round(fps/2);
end

% Get number of neurons
[n_neurons,n_frames] = size(transients);

% Preprocess every signal
preprocessed = zeros(n_neurons,n_frames);
for i = 1:n_neurons
    % 1. Moving median filter
    temporal = medfilt1(transients(i,:),bin,'truncate');

    % 2. Moving minimum filter
    temporal = movmin(temporal,bin);

    % 3. Moving maximum filter
    preprocessed(i,:) = movmax(temporal,bin);
end