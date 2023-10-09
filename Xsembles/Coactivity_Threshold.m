function th = Coactivity_Threshold(coactivations,alpha)
% Find the singificant (p<alpha) number of coactivations from samples
%
%       th = Coactivity_Threshold(coactivations,alpha)
%
% Jesus Perez-Ortega, Sep 2023

if nargin<2
    alpha = 0.05;
end

if min(coactivations)==max(coactivations)
   th = max(coactivations)+1; 
else
    x = 0:max(coactivations);
    y = histcounts(coactivations,x);
    cdy = cumsum(y);
    cdy = cdy/max(cdy);
    id = find(cdy>(1-alpha),1,'first');
    th = x(id);
end