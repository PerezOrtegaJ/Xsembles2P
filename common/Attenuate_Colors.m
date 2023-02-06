function colors_attenuated = Attenuate_Colors(colors,n_times)
% Return the colors attenuated.
%
%       colors_attenuated = Attenuate_Colors(colors,n_times)
%
%   default: n_times = 1;
%
% By Perez-Ortega Jesus, Oct 2021
% Modified Dec 2021
%
% See also DARKEN_COLORS

if nargin==1
    n_times = 1;
end

% Get number of colors
n_colors = size(colors,1);

% Attenuate each colos n times
for i = 1:n_colors
    if n_times<1
        colors_attenuated(i,:) = mean([repmat(colors(i,:),round(1/n_times),1); [1 1 1]]);
    else
        colors_attenuated(i,:) = mean([colors(i,:); repmat([1 1 1],n_times,1)]);
    end
end