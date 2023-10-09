function th = Select_Neuron_Threshold(data)
% Graphical tool to set a threshold to select neurons based on PSNR
%
%       th = Select_Neuron_Threshold(data)
%
% By Jesus Perez-Ortega, Feb 2023

h.th_max = max([data.Neurons(:).PSNRdB]);

% Get image with a default threshold
th = 20; % default threshold

% Get accepted neurons
accepted_id = [data.Neurons(:).PSNRdB]>th;

image = Highlight_Neurons_Selected(data.Neurons,accepted_id,data.Movie.Width,data.Movie.Height);

% Get number of neurons above threshold
n_neurons = nnz([data.Neurons(:).PSNRdB]>th);

% Plot image
h.figure = Set_Figure(['Selecting PSNR threshold: ' num2str(th) ' (' num2str(n_neurons) ' neurons)'],[0 0 500 500]);
h.image = imshow(image,'InitialMagnification',200);

h.th_scrollbar = uicontrol(h.figure,'style','slider','units','normalized',...
    'position',[0 0.97 1 0.03],'SliderStep',double([1/h.th_max 5/h.th_max]),'Value',th/h.th_max);
h.select_button = uicontrol(h.figure,'style','pushbutton','units','normalized',...
    'position',[0 0 1 0.1],'String','Select current threshold');

% Add events
addlistener(h.th_scrollbar,'Value','PostSet',@(~,~)Change_Threshold_Callback(data,h));
addlistener(h.select_button,'Value','PostSet',@(~,~)Select_Threshold_Callback(h));
h.image.ButtonDownFcn = @(~,~)ButtonDownImage(data);

selecting = true;
while selecting
    pause(0.5)
end

% Output
th = round(h.th_scrollbar.Value*h.th_max);

    function Change_Threshold_Callback(data,h)
        th = round(h.th_scrollbar.Value*h.th_max);
        h.th_scrollbar.Value = th/h.th_max;

        % Get number of neurons above threshold
        accepted_id = [data.Neurons(:).PSNRdB]>th;
        n_neurons = nnz(accepted_id);
        

        h.figure.Name = ['Selecting PSNR threshold: ' num2str(th) ' (' num2str(n_neurons) ' neurons)'];
    
        % Get image with a default threshold
        h.image.CData = Highlight_Neurons_Selected(data.Neurons,accepted_id,data.Movie.Width,data.Movie.Height);
    end
    
    function Select_Threshold_Callback(h)
        h.figure.Name = ['PSNR threshold selected: ' num2str(th) ' (' num2str(n_neurons) ' neurons)'];
        h.th_scrollbar.Enable = 'off';
        h.select_button.Enable = 'off';
        selecting = false;
    end

    function ButtonDownImage(data)
        point = get(gca,'CurrentPoint');
        x = point(1,1);
        y = point(1,2);

        % Read data;
        if isfield(data.ROIs,'NeuronRadius')
            radius = data.ROIs.NeuronRadius;
        else
            radius = data.ROIs.CellRadius;
        end
        neuron = Find_Cell_by_XY(x,y,data.XY.All,radius*1.5);
        if ~isempty(neuron)
            neuron_id = neuron(1);

            % Plot singlas from the neuron selected
            Set_Figure([data.Movie.DataName ' - Neuron signal'],...
                [0 0 1200 500]);
            
            % Plot neurons signal
            Plot_Neuron_Signal(data,neuron_id)
        else
            disp('   no neuron selected')
        end
    end
end