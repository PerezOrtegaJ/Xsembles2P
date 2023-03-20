function [normalized,maxMovie,meanMovie,stdMovie,PSNR] = Normalize_Movie(movie)
% Normalize the pixel along the movie
%
% Jesus Perez-Ortega April-19
% Modified Oct 2019
% modify in future the way to compute the normalization to save RAM memory space

% Get average
meanMovie = mean(movie,3);

if isa(movie,'uint8')
    % Get standar deviation
    normalized = bsxfun(@minus, movie, uint8(meanMovie));
    stdMovie = sqrt(mean(normalized.*normalized, 3));

    % Normalized
    normalized = bsxfun(@times, single(normalized), 1./stdMovie);
    normalized = uint8(normalized/max(normalized(:))*255);
elseif isa(movie,'uint16')
    % Get standar deviation
    normalized = bsxfun(@minus, movie, uint16(meanMovie));
    stdMovie = sqrt(mean(normalized.*normalized, 3));

    % Normalized
    normalized = bsxfun(@times, single(normalized), 1./stdMovie);
    normalized = uint16(normalized);
else
    % Get standar deviation
    normalized = bsxfun(@minus, movie, meanMovie);
    stdMovie = sqrt(mean(normalized.*normalized, 3));

    % Normalize
    normalized = bsxfun(@times, normalized, 1./stdMovie);
end

% Mean squared error
MSE = sum(stdMovie.^2,3);

% Maximum of video
maxMovie = max(movie,[],3);

% Peak signal-to-noise ratio
PSNR = 20*log(double(maxMovie))-10*log(double(MSE));