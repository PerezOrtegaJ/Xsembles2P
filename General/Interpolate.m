function result = Interpolate(signal,period,final_period,final_samples)
% This functions interpolate a signal with a given sampling period to a final
% period. Optional, cut the result to a given number of final
% samples.
%
%       result = Interpolate(signal,period,final_period,final_samples)
%
% By Jesus Perez-Ortega, May 2023

if nargin<4
    final_samples = [];
end

% Set initial times
t_initial = 1:length(signal);

% Compute final times
step = final_period/period;
t_final = 1:step:length(signal);

% Interpolate
result = interp1(t_initial,signal,t_final);

% Optional cut of the signal after interpolation
if ~isempty(final_samples)
    result = result(1:final_samples);
end


