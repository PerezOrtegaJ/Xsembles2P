function id = Select_Best_Index(indices,method,sem_indices)
% Select the best index from clustering evluation
%
%   id = Select_Best_Index(indices,method,sem_indices)
%
%   default: method = 'max' (or 'firstpeak', 'bigincrease', 'maxsem', 'firstpeaksem')
%
% By Jesus Perez-Ortega, March 2022

if nargin==1
    method = 'max';
end

% If any index is equal to 1 it is a perfect separation, so choose the maximum number of groups            
if nnz(indices == 1)
    id = find(indices == 1,1,'last');
else
    switch method
        case 'max'
            [~,id] = max(indices);
        case 'firstpeak'
            id = find(diff(indices)>0,1,'first');
            if isempty(id) || id==length(indices)-1
                % The indices are decreasing, so select the first
                id = 1;
            else
                % Find the first peak of the indices
                indices_copy = indices;
                indices_copy(1:id) = 0;
                id = find(diff(indices_copy)<0,1,'first');
                if isempty(id)
                    % If there is no peak find the max
                    [~,id] = max(indices);
                end
            end
        case 'bigincrease'
            id = find(diff(diff(indices))<0,1,'first');
            id = id+1;
        case 'maxsem'
            [value_max,id_max] = max(indices);
            sem_max = sem_indices(id_max);
            id = find(indices>(value_max-sem_max),1,'first');
        case 'firstpeaksem'
            next_value = indices-sem_indices;
            next_value = next_value(2:end);
            id = find((indices(1:end-1)-next_value)>0,1,'first');
        otherwise
            warning(['Select only the following methods ''max'', ''firstpeak'', '...
                '''bigincrease'', ''maxsem'', ''firstpeaksem''.'])
    end
end