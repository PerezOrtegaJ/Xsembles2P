function SEM = Get_SEM(data,dim)
% get the standar error of the mean (SEM)
%
%       SEM = Get_SEM(data)
%
% By Jesus Perez-Ortega, March 2020
% Modified, Apr 2021
% Modified, Jun 2021
% Modified, Mar 2022

if nargin == 1
    dim = 1;
end

if isrow(data)||iscolumn(data)
    n = sum(~isnan(data));
    SEM = nanstd(data)./sqrt(n);
else
    n = sum(~isnan(data),dim);
    SEM = nanstd(data,0,dim)./sqrt(n);
end