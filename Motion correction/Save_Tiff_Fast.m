function Save_Tiff_Fast(movie,file_name)
% Save data in an TIFF file
%
%       Save_Tiff_Fast(movie,file_name)
%
% By Jesus Perez-Ortega, Nov 2022

% Get the number of images
frames = size(movie,3);

% Create Tiff file
tfile = Fast_Tiff_Write(file_name);

% Write all images
for i = 1:frames
    tfile.WriteIMG(permute(movie(:,:,i),[2,1]));
end

% Close Tiff file
tfile.close;