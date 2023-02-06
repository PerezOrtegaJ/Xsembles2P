function [U,U2] = Get_Spatial_Mask(movie,normalized,bin_seconds,fps)
% Get spatial mask by SVDs 
%
%       [U,U2] = Get_Spatial_Mask(movie,normalized,bin_seconds,fps)
%
% Modified by Jesus Perez-Ortega, July 2019

% number of SVD components kept
[y,x,frames] = size(movie);
n_pixels_frame = x*y;

% bin frames every X seconds
bin_SVD = round(bin_seconds*fps); 

% images bined
n_images = bin_SVD * floor(frames/bin_SVD);
n_SVD = n_images/bin_SVD;

% bin normalized images
data = single(normalized(:,:,1:n_images));
data = reshape(data,y,x,bin_SVD,[]);
normalized_bined = squeeze(mean(data,3));
normalized_bined = reshape(normalized_bined,[],n_SVD);

% compute covariance of frames
COV = normalized_bined'*normalized_bined/n_pixels_frame;

% maximum 500 SVDs
n_SVD_final = min([n_SVD 500]); 
%n_SVD_final = min([n_SVD 200]); 

% compute SVD of covariance matrix
[V,~] = eigs(double(COV),n_SVD_final);

% compute spatial mask with normalized movie
U = single(normalized_bined*V);
U = reshape(U, y, x, []);

% compute spatial mask from raw movie
data = single(movie(:,:,1:n_images));
data = reshape(data,y,x,bin_SVD,[]);
movie_bined = squeeze(mean(data,3));
movie_bined = reshape(movie_bined,[],n_SVD);
U2 = single(movie_bined*V);
U2 = reshape(U2,y,x,[]);