function created = Hold_Figure(titleName)
%% Hold on a Figure with an specific name
%
%       created = Hold_Figure(titleName)
%
% Jesus Perez-Ortega March-18
% Modified Sep 2019
% Modified Oct 2021

h = findobj('name',titleName);
    
if isempty(h)
    exist_figure = false;
else
    figure(h);
    exist_figure = true;
end

if nargout
    created = exist_figure;
end
