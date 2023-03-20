function cell = Find_Cell_by_XY(x,y,xy,radius)

xy_updated = [x y; xy];
n = size(xy_updated,1);

% Get the distance between coordinates
distance = squareform(pdist(xy_updated))+eye(n)*radius;

% Get the cell
cell = find(distance(1,2:end)<radius);
