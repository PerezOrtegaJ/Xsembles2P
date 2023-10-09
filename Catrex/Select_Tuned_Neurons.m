function tuned = Select_Tuned_Neurons(tuning,cirvar,type,threshold)
% Get best neuron/ensemble tuned to the 4 orientations
%
%       tuned = Select_Tuned_Neurons(tuning,cirvar,type,threshold)
%
%       default: type = 'best' (also 'average', 'random', or 'threshold')
%
% By Jesus Perez-Ortega Jan 2022
% Modified Apr 2022

if nargin == 2
    type = 'best';
end

tuned = nan(1,4);
for i = 1:4
    tuned_all = find(tuning==i);
    if ~isempty(tuned_all)
        switch type
            case 'best'
                [~,id] = max(cirvar(tuned_all));
                tuned(i) = tuned_all(id);
            case 'average'
                avg = mean(cirvar);
                [sorted,id_sorted] = sort(cirvar(tuned_all),'ascend');
                [~,id] = find(sorted>avg,1,'first');
                tuned(i) = tuned_all(id_sorted(id));
            case 'random'
                n_tuned = length(tuned_all);
                tuned(i) = tuned_all(randi(n_tuned));
            case 'threshold'
                [sorted,id_sorted] = sort(cirvar(tuned_all),'ascend');
                [~,id] = find(sorted>threshold,1,'first');
                if isempty(id)
                    warning(['There is no cirvar > ' num2str(threshold) ' for orientation '...
                        num2str(i) '.'])
                    tuned(i) = tuned_all(id_sorted(end));
                else
                    tuned(i) = tuned_all(id_sorted(id));
                end
            otherwise
                warning('Invalid argument for ''type'', use ''best'', ''average'', or ''random''.')
                return
        end
    end
end