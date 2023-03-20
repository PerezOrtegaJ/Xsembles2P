function Write_XY_Prairie_Stim(xy,spiral,path_name,file_name)
% Create a prairie file to stimulate neurons of specific coordinates
%
%       Write_XY_Prairie_Stim(xy,spiral,path_name,file_name)
%
%       By default: 30 spiral revolutions in 20 ms are for a size of 10 um
%
% By Jesus Perez-Ortega, Nov 2022

if spiral
    spiral_text = 'True';
else
    spiral_text = 'False';
end

%% Marker points file
% Transform coordinates to prairie coordinates 256x256
factorX = 7.6;
factorY = 8.3;
x = xy(:,1);
X = factorX*(2*x/256-1);
y = 256-xy(:,2);
Y = factorY*(2*y/256-1);

% Open file
fileID = fopen(fullfile(path_name,[file_name '.gpl']),'w');
fprintf(fileID,'<?xml version="1.0" encoding="utf-8"?>\r\n<PVGalvoPointList>\r\n');

% Neuron coordinates
nXY = size(xy,1);
for i = 1:nXY
    fprintf(fileID,['  <PVGalvoPoint X="' num2str(X(i)) '" Y="' num2str(Y(i))...
        '" Name="Neuron ' num2str(i) '" Index="' num2str(i-1)...
        '" ActivityType="MarkPoints" UncagingLaser="Uncaging" UncagingLaserPower="5"'...
        ' Duration="20" IsSpiral="' spiral_text '" SpiralSize="0.338219758489174"'...
        ' SpiralRevolutions="30" Z="0" />\r\n']);
end

% Single group for same order of stimulation
indices = num2str(0:nXY-1,'%u,');
indices_stim = num2str(1:nXY,'%u,');
fprintf(fileID,['  <PVGalvoPointGroup Indices="' indices(1:end-1)...
    '" Name="Sequence group" Index="' num2str(nXY+1)...
    '" ActivityType="MarkPoints" Order="Custom" CustomOrder="' indices_stim(1:end-1)...
    '" UncagingLaser="Uncaging" UncagingLaserPower="5" Duration="20'...
    '" IsSpiral="' spiral_text '" SpiralSize="0.338219758489174" SpiralRevolutions="30" Z="0" />\r\n']);
fprintf(fileID,'</PVGalvoPointList>');

% Close file
fclose(fileID);