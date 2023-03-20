function optogenetics_ab = Join_Optogenetics_File(optogenetics_a,optogenetics_b)
% Join two optogenetic structures
%
%   optogenetics_ab = Join_Optogenetics_File(optogenetics_a,optogenetics_b)
%
% See also Read_Optogenetics_File
%
% By Jesus Perez-Ortega, Feb 2023

optogenetics_ab.File = [optogenetics_a.File optogenetics_b.File];

optogenetics_ab.XY = optogenetics_a.XY;
optogenetics_ab.IsSpiral = optogenetics_a.IsSpiral;
optogenetics_ab.Revolutions = optogenetics_a.Revolutions;
optogenetics_ab.RadiusMicrons = optogenetics_a.RadiusMicrons;
optogenetics_ab.RadiusPixels = optogenetics_a.RadiusPixels;
optogenetics_ab.Stimulation = [optogenetics_a.Stimulation optogenetics_b.Stimulation];

if size(optogenetics_a.XY,1)==size(optogenetics_b.XY,1)
    warning('   Stimulation points may be different!')
end