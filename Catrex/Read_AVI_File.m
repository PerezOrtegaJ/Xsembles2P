function [mov,prop] = Read_AVI_File(file)
% Create a matrix from an avi file
%
%       [mov,prop] = Read_AVI_File(file)
%
% By Jesus Perez-Ortega Jan 2020

tic; disp('Loading AVI file...')

% Get info from the file
v = VideoReader(file);
prop.height = v.Height;
prop.width = v.Width;
prop.depth = v.BitsPerPixel;
prop.frames = v.NumFrames;

% Read file
mov = read(v);
mov = squeeze(mov);

t=toc; disp(['   Done (' num2str(t) ' seconds)'])