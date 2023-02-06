function Plot_Area(data,baseline,color,alpha)
% Plot area
%
%       Plot_Area(data,baseline,color,alpha)
%
%       Default: baseline = 0; color = [0 0 0]; alpha = 1;
%
% By Jesus Perez-Ortega, August 2021

switch nargin
    case 1
        baseline = 0;
        color = [0 0 0];
        alpha = 1;
    case 2
        color = [0 0 0];
        alpha = 1;
    case 3
        alpha = 1;
end

% Set X values
n = length(data);
x = 1:n;

% Set Y values
base = repmat(baseline,1,n);
if iscolumn(data)
    % make it row
    data = data';
end

% Plot
patch([x fliplr(x)], [base fliplr(data)],color,'facealpha',alpha,'edgecolor','none')