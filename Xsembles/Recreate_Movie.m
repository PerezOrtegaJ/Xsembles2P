function movie = Recreate_Movie(width,height,neurons,signals)
% Recreate the activity movie from data.
%
%       movie = Recreate_Movie(width,height,neurons,brightness)
%
% By Jesus Perez-Ortega, Jan 2023

disp('Recreating movie from data...')

n_neurons = length(neurons);
n_frames = size(signals,2);

brightness = rescale(signals)*255;

% Initialize variable
movie = zeros(height,width,n_frames,'uint8');

% Set brightness
tic
for frame = 1:n_frames
    value = zeros(height,width,'uint8');
    for i = 1:n_neurons
        value(neurons(i).pixels) = uint8(rescale(neurons(i).weight_pixels,0.1,0.9)*brightness(i,frame));
    end
    movie(:,:,frame) = value;
    if ~mod(frame,round(n_frames/10))
        t=toc; disp(['   ' num2str(round(frame/n_frames*100)) '% (' num2str(t) ' seconds)'])
    end
end
t=toc; disp(['   Done in ' num2str(t) ' seconds!'])