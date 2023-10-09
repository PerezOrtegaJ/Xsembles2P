function colors_darkened = Darken_Colors(colors,n_times)
% Return the colors darkened.
%
%       colors_attenuated = Darken_Colors(colors,n_times)
%
%   default: n_times = 1;
%
% By Perez-Ortega Jesus, Nov 2021
% Modified Dec 2021
%
% See also ATTENUATE_COLORS

if nargin==1
    n_times = 1;
end

% Get number of colors
n_colors = size(colors,1);

% Attenuate each colos n times
for i = 1:n_colors
    if n_times<1
        colors_darkened(i,:) = mean([repmat(colors(i,:),round(1/n_times),1); [0 0 0]]);
    else
        colors_darkened(i,:) = mean([colors(i,:); repmat([0 0 0],n_times,1)]);
    end
end