function [transients,f,f0,field] = Get_Transients(mov,cellMasks,auraMasks)
% Get Ca transients by aura filter
%
%       [transients,f,f0,field] = Get_Transients(mov,cellMasks,auraMasks)
%
% By Jesus Perez-Ortega March-19
% Modified Sep 2019
% Modified Oct 2019
tic

% Data from video
[h,w,frames]= size(mov);

% Get average from whole image
field = squeeze(mean(mean(mov)));
t=toc; disp(['   Field signal - ' num2str(t) ' seconds'])

% Reshape variables
cellMasks = reshape(cellMasks,h*w,[])';
auraMasks = reshape(auraMasks,h*w,[])';
mov = single(reshape(mov,[],frames));
t=toc; disp(['   Reshaping variables - ' num2str(t) ' seconds'])

% Get the raw signal
f = cellMasks*mov;
t=toc; disp(['   Raw transients - ' num2str(t) ' seconds'])

% Get the basal level by the cell aura
f0 = auraMasks*mov;
t=toc; disp(['   Aura signal - ' num2str(t) ' seconds'])

% Filter raw transients by substracting the aura
transients = (f-f0)./f0;

% Adjust minimum value to 0
transients = transients-min(transients,[],2);
t=toc; disp(['   Filtered transients - ' num2str(t) ' seconds'])