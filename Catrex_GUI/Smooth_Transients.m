function transients = Smooth_Transients(transients,window)
% Smooth calcium signals by a moving average filter
%
%       transients = Smooth_Transients(transients,window)
%
% By Jesus Perez-Ortega, Nov 2019

n = size(transients,1);

for i = 1:n
   transients(i,:) = smooth(transients(i,:),window);
end

