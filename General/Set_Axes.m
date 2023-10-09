function h = Set_Axes(axes_name,position,mode)
% Set Axes
%
%       h = Set_Axes(axes_name,position,mode)
%
%   default: mode 'outerposition'
%
% By Jesus Perez-Ortega, Sep 2013
% Modified Jun 2023

if nargin<3
    mode = 'outerposition';
end

ax = axes(mode,position);
set(ax,'Tag',axes_name)

if nargout
    h = ax;
end