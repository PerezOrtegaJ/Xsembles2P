function vectors = Get_Peak_Vectors(data,peak_indices,vector_method,connectivity_method,bin_network)
% Get Peak Vectors
% Join the vectors of the same peak.
%
%           vectors = Get_Peak_Vectors(data,peak_indices,vector_method,connectivity_method,bin_network)
%
% Inputs
% data                  = data as C x F matrix (C = #cells, F = #frames)
% peak_indices              = Fx1 vector containing the peaks indexes
% vector_method         = choose the method for build the vetor ('sum','average','binary','network')
% connectivity_method   = connectivity method is used in case of
%                         'Vector_method' is 'network' ('coactivity','jaccard','pearson','kendall','spearman')
% bin_network           = bin is used in case of 'Vector_method' is 'network'
% 
% Outputs
% DataPeaks = data as matrix PxC (P = #peaks)
%
%           Default:    connectivity_method = 'none'; bin_network = 1;
%
% Pérez-Ortega Jesús E. - March 2018
% Modified Nov 2018
% Modified Oct 2021

switch nargin
    case 4
        bin_network = 1;
    case 3
        connectivity_method = 'none';
        bin_network = 1;
end

peaks = max(peak_indices);
if peaks
    C = size(data,1);
    switch vector_method
        case 'sum'
            vectors = zeros(peaks,C);
            for i = 1:peaks
                data_peak_i = data(:,peak_indices==i);
                vectors(i,:) = sum(data_peak_i,2);
            end
        case 'binary'
            vectors = zeros(peaks,C);
            for i = 1:peaks
                data_peak_i = data(:,peak_indices==i);
                vectors(i,:) = sum(data_peak_i,2)>0;
            end
        case 'average'
            vectors = zeros(peaks,C);
            for i = 1:peaks
                data_peak_i = data(:,peak_indices==i);
                vectors(i,:) = mean(data_peak_i,2);
            end
        case 'network'
            vectors = zeros(peaks,C*(C-1)/2);
            for i = 1:peaks
                data_peak_i = data(:,peak_indices==i);
                A = Get_Adjacency_From_Raster(Reshape_Raster(data_peak_i,bin_network),...
                    connectivity_method);
                vectors(i,:) = squareform(A,'tovector');
            end
        otherwise
            warning('Vector method should be: ''sum'', ''binary'', ''average'', or ''network''')
    end
else
    vectors = [];
    warning('There are no data peaks!')
end
