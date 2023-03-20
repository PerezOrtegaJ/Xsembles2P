function [inference,model] = Get_Spike_Inference(transients,method,max_iterations)
% Get spike inference given a specific method (derivative, oasis or foopsi)
%
%   [inference,model] = Get_Spike_Inference(transients,method,max_iterations)
%
%            default: method = 'foopsi'; ,max_iterations = 10
%                     method could be 'foopsi', 'oasis' or 'derivative'
%
% By Jesus Perez-Ortega, Nov 2019

if nargin<3
    max_iterations = 10; % for foopsi method
    if nargin<2
        method = 'foopsi';
    end
end

% Get number of signals
[n,f] = size(transients);
inference = zeros(n,f);
model = zeros(n,f);

switch method
    case 'derivative'
        for i = 1:n
            % Get derivative
            singleInference = [0;diff(transients(i,:))'];

            % Get binary
            inference(i,:) = singleInference;
        end
        model = [];
    case 'oasis'
        tic
        ten_perc = round(n/10);
        for i = 1:n
            % Get oasis model
            [singleModel,singleInference] = oasisAR2(transients(i,:));

            % Get binary from inference
            inference(i,:) = singleInference;
            
            % Get binary from model
            model(i,:) = singleModel;
            
            if ~mod(i,ten_perc)
                t = toc; 
                fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
            end   
        end
    case 'foopsi'
        ten_perc = round(n/10);
        notmodeled = 0;
        for i = 1:n
            % Get foopsi model
            [singleModel,singleInference] = foopsi_oasisAR2(transients(i,:),[],[],true,true,[],max_iterations);
            if ~sum(singleModel)
                notmodeled = notmodeled+1;
            end

            % Get binary from inference
            inference(i,:) = singleInference;
            
            % Get binary from model
            model(i,:) = singleModel;
            
            if i==1
                tic
            end
            if i==2
                t = toc;
                estimated_time = t*n/60;
                fprintf('   (estimated time: %.1f min)\n',estimated_time)
            end
            if ~mod(i,ten_perc)
                t = toc; 
                fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
            end            
        end
        
        if notmodeled
            warning([num2str(notmodeled) ' neurons were not modeled!'])
        end
    otherwise
        error('You can only select ''derivative'', ''oasis'', or ''foopsi''.')
end