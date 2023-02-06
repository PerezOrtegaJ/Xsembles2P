function S = Get_Neuropil_Basis(x,y,n_tiles)
% Get the neuropil basis
%
%       S = Get_Neuropil_Basis(x,y,n_tiles)
%
% Modified by Jesus Perez-Ortega, July 2019
% for cell diameter = 8 and 512x512 FOV, default is 22 x 22 tiles

% Fourier
S = zeros(y, x, n_tiles, n_tiles, 'single');

% elementary basic funtions x
i=0:x-1;
j=0:x-1;
[I,J]=meshgrid(i,j);
A=sqrt(2/x)*cos(((2.*I+1).*J*pi)/(x*2));
A(1,:)=A(1,:)./sqrt(2);
Ax=A';   

% elementary basic funtions y
i=0:y-1;
j=0:y-1;
[I,J]=meshgrid(i,j);
A=sqrt(2/y)*cos(((2.*I+1).*J*pi)/(y*2));
A(1,:)=A(1,:)./sqrt(2);
Ay=A';  

for j = 1:n_tiles
    for i = 1:n_tiles
        S(:,:,i,j) = Ay(:,j) * Ax(:,i)';
    end
end
S = reshape(S, [], n_tiles^2);
S = normc(S);
