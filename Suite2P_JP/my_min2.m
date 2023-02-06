function S1 = my_min2(S1,sig)
% 2D radius filtering
% Modified by Jesus Perez-Ortega Oct 2019

sig = ceil(sig);

xs = repmat(-sig:sig,2*sig+1,1);
ys = xs';

rs = (xs.^2 + ys.^2).^.5;

xs = xs(rs<=sig);
ys = ys(rs<=sig);

[Ly,Lx] = size(S1);

Smax = S1;
for j = 1:numel(xs)
    yc = (1:Ly)+ys(j);
    ig = ~(yc<1|yc>Ly);
    yc = yc(ig);
        
    xc = (1:Lx)+xs(j);
    ig = ~(xc<1|xc>Lx);
    xc = xc(ig);
    
    Smax(yc-ys(j),xc-xs(j),:) = min(Smax(yc-ys(j),xc-xs(j),:),S1(yc,xc,:));
end

S1 = Smax;

