classdef Xsembles_2P_Viewer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Xsembles2PViewerUIFigure       matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        AnalyzeTab                     matlab.ui.container.Tab
        XsembleanalysisPanel           matlab.ui.container.Panel
        XsemblesAnalysisCheckBox       matlab.ui.control.CheckBox
        NeuronsPanel                   matlab.ui.container.Panel
        NeuronRadiusSpinner            matlab.ui.control.Spinner
        samplingperiodmsLabel_3        matlab.ui.control.Label
        NeuronsDropDown                matlab.ui.control.DropDown
        SignalevaluationPanel          matlab.ui.container.Panel
        SetThresholdVisuallyCheckBox   matlab.ui.control.CheckBox
        PSNRdBThSpinner                matlab.ui.control.Spinner
        samplingperiodmsLabel_4        matlab.ui.control.Label
        AnalyzeVideoButton             matlab.ui.control.Button
        MotioncorrectionPanel          matlab.ui.container.Panel
        SpeedThSpinner                 matlab.ui.control.Spinner
        locomotionthresholdLabel       matlab.ui.control.Label
        FastMotionCorrectionCheckBox   matlab.ui.control.CheckBox
        VideoPanel                     matlab.ui.container.Panel
        FileEditField                  matlab.ui.control.EditField
        FileButton                     matlab.ui.control.Button
        AnalysisSamplingPeriodSpinner  matlab.ui.control.Spinner
        samplingperiodmsLabel_2        matlab.ui.control.Label
        VisualizeTab                   matlab.ui.container.Tab
        StimulationPanel               matlab.ui.container.Panel
        PlotStimLocationButton         matlab.ui.control.Button
        StimuliDropDown                matlab.ui.control.DropDown
        PlottrialsButton               matlab.ui.control.Button
        XsemblesPanel                  matlab.ui.container.Panel
        DividerBLabel                  matlab.ui.control.Label
        DividerALabel                  matlab.ui.control.Label
        HighlightEnsembleDropDown      matlab.ui.control.DropDown
        HighlightensembleLabel         matlab.ui.control.Label
        PlotNeuronsButton              matlab.ui.control.Button
        BrightnessNeuronsCheckBox      matlab.ui.control.CheckBox
        ShapeCheckBox                  matlab.ui.control.CheckBox
        GetStimulationFilesButton      matlab.ui.control.Button
        GetNeuronsButton               matlab.ui.control.Button
        SelectSignalsDropDown          matlab.ui.control.DropDown
        PlotSignalsButton              matlab.ui.control.Button
        PlotNonparticipantCheckBox     matlab.ui.control.CheckBox
        PlotOffsembleCheckBox          matlab.ui.control.CheckBox
        PlotOnsembleCheckBox           matlab.ui.control.CheckBox
        RasterPanel                    matlab.ui.container.Panel
        SortNeuronsDropDown            matlab.ui.control.DropDown
        ReplayActivityButton           matlab.ui.control.Button
        PlotRasterButton               matlab.ui.control.Button
        SortVectorsCheckBox            matlab.ui.control.CheckBox
        SelectDataDropDown             matlab.ui.control.DropDown
        HelpTab                        matlab.ui.container.Tab
        ContactPanel                   matlab.ui.container.Panel
        EmailLink                      matlab.ui.control.Hyperlink
        EmailLink2                     matlab.ui.control.Hyperlink
        EmailLabel                     matlab.ui.control.Label
        KeepituptodatePanel            matlab.ui.container.Panel
        GithubLink                     matlab.ui.control.Hyperlink
        GithubLabel                    matlab.ui.control.Label
        CitationPanel                  matlab.ui.container.Panel
        DOILink                        matlab.ui.control.Hyperlink
        CitationLabel                  matlab.ui.control.Label
    end

    
    properties (Access = private)
        DataName = '-- select data --';
        NeuronsName = '-- find neurons --';
        PSNR2 = [];
        Movie = [];
    end
    
    methods (Access = private)
        
        function data = Read_Data(app)
            if strcmp(app.DataName,'-- select data --')
                app.SelectDataDropDown.BackgroundColor = [0.96 0.96 0.96];
                data = [];
            else
                % Check if variable exist
                if evalin('base',['exist(''' app.DataName ''',''var'')'])
                    data = evalin('base',app.DataName);
                    
                    % Check if data has movie field
                    if isfield(data,'Movie')
                        app.SelectDataDropDown.BackgroundColor = [0.8 0.9 0.8];
                        app.SelectDataDropDown.Tooltip = 'Data compatible!';
                        
                        % Check if data has analysis field
                        if isfield(data,'Analysis') 
                            app.SortVectorsCheckBox.Enable = 'on';
                        else
                            app.SortVectorsCheckBox.Value = false;
                            app.SortVectorsCheckBox.Enable = 'off';
                            app.HighlightEnsembleDropDown.Enable = 'off';
                        end
                    
                    else
                        app.SelectDataDropDown.BackgroundColor = [0.9 0.8 0.8];
                        app.SelectDataDropDown.Tooltip = 'Data not compatible!';
                        data = [];
                    end
                else
                    app.SelectDataDropDown.BackgroundColor = [0.9 0.8 0.8];
                    app.SelectDataDropDown.Tooltip = 'Variable does not exist!';
                    data = [];
                end
            end
        end

        function neurons = Read_Neurons(app)
            if strcmp(app.NeuronsName,'-- find neurons --')
                app.NeuronsDropDown.BackgroundColor = [0.96 0.96 0.96];
                neurons = struct([]);
            else
                % Check if exist
                if evalin('base',['exist(''' app.NeuronsName ''',''var'')'])
                    neurons = evalin('base',app.NeuronsName);
                    
                    % Check if has pixels field
                    if isfield(neurons,'pixels')
                        app.NeuronsDropDown.BackgroundColor = [0.8 0.9 0.8];
                        app.NeuronsDropDown.Tooltip = 'Variable compatible!';
                    else
                        app.NeuronsDropDown.BackgroundColor = [0.9 0.8 0.8];
                        app.NeuronsDropDown.Tooltip = 'Variable not compatible!';
                        neurons = struct([]);
                    end
                else
                    app.NeuronsDropDown.BackgroundColor = [0.9 0.8 0.8];
                    app.NeuronsDropDown.Tooltip = 'Variable does not exist!';
                    neurons = struct([]);
                end
            end
        end
        
        function Plot_Xsembles(app)
            data = Read_Data(app);
            if isempty(data)
                return
            end

            plot_all = strcmp(app.HighlightEnsembleDropDown.Value,'no');
            
            % Get ensemble neurons
            if plot_all
                % All ensemble neurons
                options_title = ' (all neurons)';
                legend_text = {'all neurons'};
            else
                plot_onsemble = app.PlotOnsembleCheckBox.Value;
                plot_offsemble = app.PlotOffsembleCheckBox.Value;
                plot_nonparticipant = app.PlotNonparticipantCheckBox.Value;
    
                if ~plot_onsemble && ~plot_offsemble && ~plot_nonparticipant
                    return
                end

                % Selected ensemble neurons
                ensemble_number = str2double(app.HighlightEnsembleDropDown.Value);
                onsemble_id = data.Analysis.Ensembles.OnsembleNeurons{ensemble_number};
                offsemble_id = data.Analysis.Ensembles.OffsembleNeurons{ensemble_number};
                nonparticipant_id = setdiff(1:data.Analysis.Neurons,onsemble_id);
                nonparticipant_id = setdiff(nonparticipant_id,offsemble_id);
                ensemble_color = Get_Color(ensemble_number,'jp');
        
                % Get coordinates 
                xy_onsemble = data.XY.All(onsemble_id,:);
                xy_offsemble = data.XY.All(offsemble_id,:);
                xy_nonparticipant = data.XY.All(nonparticipant_id,:);

                if plot_onsemble && plot_offsemble && plot_nonparticipant
                    options_title = [' (onsemble, offsemble, and nonparticipant ' app.HighlightEnsembleDropDown.Value ')'];
                    legend_text = {'nonparticipant neurons','offsemble neurons','onsemble neurons'};
                elseif plot_onsemble && plot_offsemble
                    options_title = [' (ensemble and offsemble ' app.HighlightEnsembleDropDown.Value ')'];
                    legend_text = {'offsemble neurons','onsemble neurons'};
                elseif plot_onsemble && plot_nonparticipant
                    options_title = [' (ensemble and nonparticipant ' app.HighlightEnsembleDropDown.Value ')'];
                    legend_text = {'nonparticipant neurons','onsemble neurons'};
                elseif plot_onsemble
                    options_title = [' (onsemble ' app.HighlightEnsembleDropDown.Value ')'];
                    legend_text = {'onsemble neurons'};
                elseif plot_offsemble && plot_nonparticipant
                    options_title = [' (offsemble and nonparticipant ' app.HighlightEnsembleDropDown.Value ')'];
                    legend_text = {'nonparticipant neurons','offsemble neurons'};
                elseif plot_offsemble
                    options_title = [' (offsemble ' app.HighlightEnsembleDropDown.Value ')'];
                    legend_text = {'offsemble neurons'};
                elseif plot_nonparticipant
                    options_title = [' (nonparticipant neurons ' app.HighlightEnsembleDropDown.Value ')'];
                    legend_text = {'nonparticipant neurons'};
                end
            end

            % Plot
            w = data.Movie.Width;
            h = data.Movie.Height;
            Set_Figure([data.Movie.DataName ' - Xsembles' options_title],...
                [0 0 round(420*w/h) 449])
            if plot_all
                plot(data.XY.All(:,1),data.XY.All(:,2),'.','Color',[0.9 0.9 0.9],...
                        'MarkerSize',30); hold on
            else
                if plot_nonparticipant
                    plot(xy_nonparticipant(:,1),xy_nonparticipant(:,2),'.','Color',[0.9 0.9 0.9],...
                        'MarkerSize',30); hold on
                end
                if plot_offsemble
                    plot(xy_offsemble(:,1),xy_offsemble(:,2),'.','Color',...
                        Attenuate_Colors(ensemble_color),'MarkerSize',30); hold on
                end
                if plot_onsemble
                    plot(xy_onsemble(:,1),xy_onsemble(:,2),'.','Color',...
                        ensemble_color,'MarkerSize',30); hold on
                end
            end
            title(strrep([data.Movie.DataName ' - Xsembles' options_title],'_','-'))
            set(gca,'xlim',[0 w],'ylim',[0 h],'xtick',[],'ytick',[],'ydir','reverse')
            pbaspect([w/h 1 1])
            legend(legend_text);
            legend off
        end
        
        function Plot_Xsembles_Shape(app)
            % Read data
            data = Read_Data(app);
            if isempty(data)
                return
            end

            if app.BrightnessNeuronsCheckBox.Value
                brightness = data.Transients.PSNRdB;
            else
                brightness = ones(1,length(data.Neurons));
            end
            
            if strcmp(app.HighlightEnsembleDropDown.Value,'no')
                % Get mask for all neurons
                mask = Get_ROIs_Image(data.Neurons,data.Movie.Width,...
                    data.Movie.Height,brightness,0,0);
                options_title = '';
            else
                plot_onsemble = app.PlotOnsembleCheckBox.Value;
                plot_offsemble = app.PlotOffsembleCheckBox.Value;
                plot_nonparticipant = app.PlotNonparticipantCheckBox.Value;
    
                if ~plot_onsemble && ~plot_offsemble && ~plot_nonparticipant
                    return
                end

                % Set mask highlighting the selected ensemble
                ensemble_number = str2double(app.HighlightEnsembleDropDown.Value);
                onsemble_hsv = rgb2hsv(Get_Color(ensemble_number,'jp'));
                offsemble_hsv = rgb2hsv(Attenuate_Colors(Get_Color(ensemble_number,'jp')));

                % Get ids
                onsemble_id = data.Analysis.Ensembles.OnsembleNeurons{ensemble_number};
                offsemble_id = data.Analysis.Ensembles.OffsembleNeurons{ensemble_number};
                nonparticipant_id = setdiff(1:data.Analysis.Neurons,onsemble_id);
                nonparticipant_id = setdiff(nonparticipant_id,offsemble_id);

                % Initialize values
                hues = zeros(1,data.Analysis.Neurons);
                saturation = zeros(1,data.Analysis.Neurons);

                hues(onsemble_id) = onsemble_hsv(1);
                saturation(onsemble_id) = onsemble_hsv(2);
                hues(offsemble_id) = offsemble_hsv(1);
                saturation(offsemble_id) = offsemble_hsv(2);

                if ~plot_onsemble
                    brightness(onsemble_id) = 0;
                end

                if ~plot_offsemble
                    brightness(offsemble_id) = 0;
                end

                if ~plot_nonparticipant
                    brightness(nonparticipant_id) = 0;
                end

                mask = Get_ROIs_Image(data.Neurons,data.Movie.Width,...
                    data.Movie.Height,brightness,hues,saturation);

                % Get title
                if plot_onsemble && plot_offsemble && plot_nonparticipant
                    options_title = [' (onsemble, offsemble, and nonparticipant ' app.HighlightEnsembleDropDown.Value ')'];
                elseif plot_onsemble && plot_offsemble
                    options_title = [' (onsemble and offsemble ' app.HighlightEnsembleDropDown.Value ')'];
                elseif plot_onsemble && plot_nonparticipant
                    options_title = [' (onsemble and nonparticipant ' app.HighlightEnsembleDropDown.Value ')'];
                elseif plot_onsemble
                    options_title = [' (onsemble ' app.HighlightEnsembleDropDown.Value ')'];
                elseif plot_offsemble && plot_nonparticipant
                    options_title = [' (offsemble and nonparticipant ' app.HighlightEnsembleDropDown.Value ')'];
                elseif plot_offsemble
                    options_title = [' (offsemble ' app.HighlightEnsembleDropDown.Value ')'];
                elseif plot_nonparticipant
                    options_title = [' (nonparticipant neurons ' app.HighlightEnsembleDropDown.Value ')'];
                end
            end
            image = cast(rescale(mask)*double(intmax('uint8')),'uint8');
            
            % Plot image
            Set_Figure([data.Movie.DataName ' - Neurons' options_title],[0 0 500 500])
            h_image = imshow(image,'InitialMagnification',300); hold on;
            h_image.ButtonDownFcn = @(~,~)ButtonDownImage(app);
            title(strrep([data.Movie.DataName ' - Neurons' options_title],'_','-'))
        end
        
        function Plot_Neurons_Threshold(app)
            % Read data
            data = Read_Data(app);
            if isempty(data)
                return
            end
            raw = data.Transients.Raw;
            smoothed = data.Transients.Smoothed;
            raw0 = raw-smoothed;
           
            switch app.EvaluatingMeasureDropDown.Value
                case 'PSNR (f0)'
                    signals = data.Transients.PSNRdB;
                case 'PSNR (raw0)'
                    signals = max((raw-raw0),[],2)./std(raw0,[],2);
                case 'range'
                    signals = range(smoothed,2);
                case 'var (raw0)'
                    signals = var(raw0,[],2);
                case 'var (raw)'
                    signals = var(raw,[],2);
            end
            % Get ids
            accepted_id = signals>app.ThresholdSpinner.Value;

            image = Draw_Neurons_Accepted(data.Neurons,accepted_id,...
                data.Movie.Width,data.Movie.Height);
            
            % Plot image
            Set_Figure([data.Movie.DataName ' - Neurons Accepted'],[0 0 500 500])
            h_image = imshow(image,'InitialMagnification',200); hold on;
            h_image.ButtonDownFcn = @(~,~)ButtonDownImage(app);
            title(strrep([data.Movie.DataName ' - Neurons'],'_','-'))
            imwrite(image,[data.Movie.DataName ' - ' app.EvaluatingMeasureDropDown.Value '- '...
                num2str(app.ThresholdSpinner.Value,'%.2f') '.png'])
        end
        
        function ButtonDownImage(app,~)
            point = get(gca,'CurrentPoint');
            x = point(1,1);
            y = point(1,2);

            % Read data
            data = Read_Data(app);
            if isfield(data.ROIs,'NeuronRadius')
                radius = data.ROIs.NeuronRadius;
            else
                radius = data.ROIs.CellRadius;
            end
            
            neuron = Find_Neurons_By_XY(data.Neurons,[x y],radius*1.5);
            if ~isempty(neuron)
                neuron_id = neuron(1);

                % Plot singlas from the neuron selected
                h_figure = Set_Figure([data.Movie.DataName ' - Neuron signal'],...
                    [0 0 1200 500]);
                
                % Add scrollbar
                n_neurons = length(data.Neurons);
                h_scrollbar = uicontrol(h_figure,'style','slider','units','normalized',...
                    'position',[0 0 1 .05],'sliderstep',...
                    [1/n_neurons 10/n_neurons]);
    
                % Add listener to scrollbar
                addlistener(h_scrollbar,'Value','PostSet',...
                    @(~,~)NeuronScroll_Callback(app,h_scrollbar));

                h_scrollbar.Value = neuron_id/n_neurons;
            else
                disp('   no neuron selected')
            end
        end

        function NeuronScroll_Callback(app,h_scrollbar)
            data = Read_Data(app);
            n_neurons = length(data.Neurons);
            neuron_id = round(get(h_scrollbar,'value')*n_neurons-1)+1;
            Hold_Figure([data.Movie.DataName ' - Neuron signal'])
            Plot_Neuron_Signal(data,neuron_id,[])
        end

        function NeuronTestScroll_Callback(app,h_scrollbar)
            data = Read_Data(app);
            [~,neuron_id] = sort(app.PSNR2);

            selected = round(get(h_scrollbar,'value')*n_neurons-1)+1;
            Hold_Figure([data.Movie.DataName ' - Neuron test'])
            Plot_Neuron_Test(data,neuron_id(selected))
        end
            
        function ReplayScroll_Callback(app,h)
            data = Read_Data(app);

            % Get frame selected
            n = data.Movie.Frames;
            frame = round(h.frame_scrollbar.Value*n);
            if frame==0
                frame = 1;
            end
            h.frame_text.String = ['frame: ' num2str(frame,'%.0f')];
            im = uint8(app.Movie(:,:,frame));
            im = imadjust(im+1,[],[],h.gamma_scrollbar.Value);

            % Plot frame
            h.frame_image.CData = im;

            % Plot current frame
            cla(h.current_axes)
            axes(h.current_axes)
            plot([frame frame],[0 1],'--k')
            drawnow
        end
        
        function GammaScroll_Callback(app,h)
            % get value
            value = round(h.gamma_scrollbar.Value*100)/100;
            
            % change text
            h.gamma_text.String = ['gamma correction: ' num2str(value,'%0.2f')];

            % modify image
            ReplayScroll_Callback(app,h)
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Drop down opening function: SelectDataDropDown
        function SelectDataDropDownOpening(app, event)
            data_strings = evalin('base','who');
            set(app.SelectDataDropDown,'items',[{'-- select data --'};data_strings])
        end

        % Value changed function: SelectDataDropDown
        function SelectDataDropDownValueChanged(app, event)
            name = app.SelectDataDropDown.Value;
            app.DataName = name;
            
            % Initialize values
            app.HighlightEnsembleDropDown.Value = 'no';
            app.StimuliDropDown.Value = '-- select stimulus --';
            app.StimuliDropDown.Enable = 'off';

            % Read data
            data = Read_Data(app);
            if isfield(data,'VoltageRecording')
                if isfield(data.VoltageRecording,'Stimuli')||...
                   isfield(data.VoltageRecording,'Laser')
                    app.StimuliDropDown.Enable = 'on';
                    app.PlottrialsButton.Enable = 'on';
                else
                    app.StimuliDropDown.Enable = 'off';
                    app.PlottrialsButton.Enable = 'off';
                end
            else
                app.StimuliDropDown.Enable = 'off';
                app.PlottrialsButton.Enable = 'off';
            end

            HighlightEnsembleDropDownValueChanged(app)
        end

        % Button pushed function: PlotRasterButton
        function PlotRasterButtonPushed(app, event)
            % Read data
            data = Read_Data(app);
            if isempty(data)
                return
            end
            value = app.SortNeuronsDropDown.Value;
            sort_vectors = app.SortVectorsCheckBox.Value;

            switch value
                case 'no sorting of neurons'
                    sort_neurons = false;
                case 'ensemble sorting'
                    sort_neurons = true;
                case 'ONsemble sorting'
                    sort_neurons = Get_Neuron_ID(data,'on');
                case 'OFFsemble sorting'
                    sort_neurons = Get_Neuron_ID(data,'off');
                otherwise
                    if strcmp(value(1:5),'EPI -')
                        epi_ensemble = str2num(value(end));
                        [~,sort_neurons] = sort(data.Analysis.Ensembles.EPI(epi_ensemble,:),'descend');
                    else
                        sort_neurons = evalin('base',value);
                    end
            end
            
            if isfield(data,'VoltageRecording')
                voltage = data.VoltageRecording;
            else
                voltage = [];
            end
            
            if sort_vectors && sum(sort_neurons)
                options_title = '(neurons and vectors sorted)';
            elseif sort_vectors
                options_title = '(vectors sorted)';
            elseif sum(sort_neurons)
                options_title = '(neurons sorted)';
            else
                options_title = '';
            end

            Set_Figure([data.Movie.DataName ' - Ensembles ' options_title],[0 0 1200 700])
            fps = data.Movie.FPS;
            if isfield(data,'Analysis')
                Plot_Xsemble_Raster(data,sort_neurons,sort_vectors)
            else
                Plot_Raster_And_External(data.Transients.Raster,voltage,fps)
            end
        end

        % Button pushed function: PlotNeuronsButton
        function PlotNeuronsButtonPushed(app, event)
            if app.ShapeCheckBox.Value
                Plot_Xsembles_Shape(app)
            else
                Plot_Xsembles(app)
            end
        end

        % Drop down opening function: HighlightEnsembleDropDown
        function EnsembleDropDownOpening(app, event)
            data = Read_Data(app);
            if isempty(data)
                return
            end

            data_strings = {};
            for i = 1:data.Analysis.Ensembles.Count
                data_strings{i} = num2str(i);
            end
            data_strings = [{'no'} data_strings];
            set(app.HighlightEnsembleDropDown,'items',data_strings)
        end

        % Value changed function: ShapeCheckBox
        function ShapeCheckBoxValueChanged(app, event)
            shape = app.ShapeCheckBox.Value;
            if shape
                app.BrightnessNeuronsCheckBox.Enable = 'on';
            else
                app.BrightnessNeuronsCheckBox.Enable = 'off';
            end
        end

        % Value changed function: HighlightEnsembleDropDown
        function HighlightEnsembleDropDownValueChanged(app, event)
            value = app.HighlightEnsembleDropDown.Value;
            switch value
                case 'no'
                    app.PlotOnsembleCheckBox.Enable = 'off';
                    app.PlotOffsembleCheckBox.Enable = 'off';
                    app.PlotNonparticipantCheckBox.Enable = 'off';
                otherwise
                    app.PlotOnsembleCheckBox.Enable = 'on';
                    app.PlotOffsembleCheckBox.Enable = 'on';
                    app.PlotNonparticipantCheckBox.Enable = 'on';
            end
        end

        % Button pushed function: GetStimulationFilesButton
        function GetStimulationFilesButtonPushed(app, event)
            % Read data
            data = Read_Data(app);
            if isempty(data)
                return
            end

            if strcmp(app.HighlightEnsembleDropDown.Value,'no')
                % Spirals
                Write_XY_Prairie_Stim(data.XY.All,true,'',...
                    [data.Movie.DataName ' - all neurons - spiral'])
                % Point
                Write_XY_Prairie_Stim(data.XY.All,false,'',...
                    [data.Movie.DataName ' - all neurons - point'])
            else
            
                plot_onsemble = app.PlotOnsembleCheckBox.Value;
                plot_offsemble = app.PlotOffsembleCheckBox.Value;
                plot_nonparticipant = app.PlotNonparticipantCheckBox.Value;
    
                if ~plot_onsemble && ~plot_offsemble && ~plot_nonparticipant
                    return
                end

                % Selected ensemble neurons
                ensemble_number = str2double(app.HighlightEnsembleDropDown.Value);
                onsemble_id = data.Analysis.Ensembles.OnsembleNeurons{ensemble_number};
                offsemble_id = data.Analysis.Ensembles.OffsembleNeurons{ensemble_number};
                nonparticipant_id = setdiff(1:data.Analysis.Neurons,onsemble_id);
                nonparticipant_id = setdiff(nonparticipant_id,offsemble_id);
    
                % Set spiral marker points
                if plot_onsemble
                    Write_XY_Prairie_Stim(data.XY.All(onsemble_id,:),true,'',...
                        [data.Movie.DataName ' - onsemble ' num2str(ensemble_number) ' spiral'])
                    Write_XY_Prairie_Stim(data.XY.All(onsemble_id,:),false,'',...
                        [data.Movie.DataName ' - onsemble ' num2str(ensemble_number) ' point'])
                end
                if plot_offsemble
                    Write_XY_Prairie_Stim(data.XY.All(offsemble_id,:),true,'',...
                        [data.Movie.DataName ' - offsemble ' num2str(ensemble_number) ' spiral'])
                    Write_XY_Prairie_Stim(data.XY.All(offsemble_id,:),false,'',...
                        [data.Movie.DataName ' - offsemble ' num2str(ensemble_number) ' point'])
                end
                if plot_nonparticipant
                    Write_XY_Prairie_Stim(data.XY.All(nonparticipant_id,:),true,'',...
                        [data.Movie.DataName ' - nonparticipant ' num2str(ensemble_number) ' spiral'])
                    Write_XY_Prairie_Stim(data.XY.All(nonparticipant_id,:),false,'',...
                        [data.Movie.DataName ' - nonparticipant ' num2str(ensemble_number) ' point'])
                end
            end
        end

        % Button pushed function: AnalyzeVideoButton
        function AnalyzeVideoButtonPushed(app, event)
            file_path = app.FileEditField.Value;
            sampling_period = app.AnalysisSamplingPeriodSpinner.Value/1000;
            neuron_radius = app.NeuronRadiusSpinner.Value;
            motion_correction = app.FastMotionCorrectionCheckBox.Value;
            speed_threshold = app.SpeedThSpinner.Value;
            select_threshold = app.SetThresholdVisuallyCheckBox.Value;
            PSNR_Th = app.PSNRdBThSpinner.Value;
            neurons = Read_Neurons(app);
            get_xsembles = app.XsemblesAnalysisCheckBox.Value;
            Xsembles_2P(file_path,...
                'SamplingPeriod',sampling_period,...
                'NeuronRadius',neuron_radius,...
                'MotionCorrection',motion_correction,...
                'MotionCorrectionThreshold',speed_threshold,...
                'PSNRdBThreshold',PSNR_Th,...
                'SelectPSNRThresholdVisually',select_threshold,...
                'Neurons',neurons,...
                'GetXsembles',get_xsembles)
        end

        % Value changed function: FastMotionCorrectionCheckBox
        function FastMotionCorrectionCheckBoxValueChanged(app, event)
            if app.FastMotionCorrectionCheckBox.Value
                app.SpeedThSpinner.Enable = 'on';
            else
                app.SpeedThSpinner.Enable = 'off';
            end
            
        end

        % Drop down opening function: NeuronsDropDown
        function NeuronsDropDownOpening(app, event)
            data_strings = evalin('base','who');
            set(app.NeuronsDropDown,'items',[{'-- find neurons --'};data_strings])

            if isempty(data_strings)
                app.NeuronsDropDown.BackgroundColor = [0.96 0.96 0.96];
            end
        end

        % Value changed function: NeuronsDropDown
        function NeuronsDropDownValueChanged(app, event)
            app.NeuronsName = app.NeuronsDropDown.Value;
            if strcmp(app.NeuronsName,'-- find neurons --')
                app.NeuronRadiusSpinner.Enable = 'on';
            else
                app.NeuronRadiusSpinner.Enable = 'off';
            end
            Read_Neurons(app);
        end

        % Button pushed function: GetNeuronsButton
        function GetNeuronsButtonPushed(app, event)
            data = Read_Data(app);
            if isempty(data)
                return
            end

            if strcmp(app.HighlightEnsembleDropDown.Value,'no')
                neurons = data.Neurons;
                assignin('base',...
                    ['all_neurons_' data.Movie.DataName],neurons)
            else
                get_onsemble = app.PlotOnsembleCheckBox.Value;
                get_offsemble = app.PlotOffsembleCheckBox.Value;
                get_nonparticipant = app.PlotNonparticipantCheckBox.Value;
    
                ensemble_number = str2double(app.HighlightEnsembleDropDown.Value);
                onsemble_id = data.Analysis.Ensembles.OnsembleNeurons{ensemble_number};
                offsemble_id = data.Analysis.Ensembles.OffsembleNeurons{ensemble_number};
                nonparticipant_id = setdiff(1:data.Analysis.Neurons,onsemble_id);
                nonparticipant_id = setdiff(nonparticipant_id,offsemble_id);

                if get_onsemble
                    neurons = data.Neurons(onsemble_id);
                    assignin('base',...
                    ['neurons_on_' num2str(ensemble_number) '_' data.Movie.DataName],neurons)
                end

                if get_offsemble
                    neurons = data.Neurons(offsemble_id);
                    assignin('base',...
                    ['neurons_off_' num2str(ensemble_number) '_' data.Movie.DataName],neurons)
                end

                if get_nonparticipant
                    neurons = data.Neurons(nonparticipant_id);
                    assignin('base',...
                    ['neurons_non_' num2str(ensemble_number) '_' data.Movie.DataName],neurons)
                end
            end
        end

        % Button pushed function: PlotSignalsButton
        function PlotSignalsButtonPushed(app, event)
            data = Read_Data(app);
            if isempty(data)
                return
            end

            if strcmp(app.HighlightEnsembleDropDown.Value,'no')
                id = 1:length(data.Neurons);
            else
                get_onsemble = app.PlotOnsembleCheckBox.Value;
                get_offsemble = app.PlotOffsembleCheckBox.Value;
                get_nonparticipant = app.PlotNonparticipantCheckBox.Value;
    
                ensemble_number = str2double(app.HighlightEnsembleDropDown.Value);
                onsemble_id = data.Analysis.Ensembles.OnsembleNeurons{ensemble_number};
                offsemble_id = data.Analysis.Ensembles.OffsembleNeurons{ensemble_number};
                nonparticipant = setdiff(1:data.Analysis.Neurons,onsemble_id);
                nonparticipant = setdiff(nonparticipant,offsemble_id);

                id = [];
                if get_onsemble
                    id = [id onsemble_id];
                end
                if get_offsemble
                    id = [id offsemble_id];
                end
                if get_nonparticipant
                    id = [id nonparticipant];
                end
            end

            signal_type = app.SelectSignalsDropDown.Value;
            switch signal_type
                case 'binary'
                    signals = data.Transients.Raster(id,:);
                    y_label = 'neuron #';
                case 'raw'
                    signals = data.Transients.Raw(id,:);
                    y_label = 'fluorescence';
                case 'filtered'
                    signals = data.Transients.Filtered(id,:);
                    y_label = 'fluorescence';
                case 'smoothed'
                    signals = data.Transients.Smoothed(id,:);
                    y_label = 'fluorescence';
                case 'inference'
                    signals = data.Transients.Inference(id,:);
                    y_label = 'spike inference';
            end

            Set_Figure([data.Movie.DataName ' - ' signal_type],[0 0 1200 700])
            if strcmp(signal_type,'binary')
                Plot_Raster(signals)
                Set_Label_Time(size(signals,2),data.Movie.FPS)
            else
                Plot_Transients(signals,'separated',data.Movie.FPS,[0 0 0])
            end
            ylabel(y_label)
        end

        % Button pushed function: ReplayActivityButton
        function ReplayActivityButtonPushed(app, event)
            % Read data
            data = Read_Data(app);
            if isempty(data)
                return
            end

            % Get number of frames
            n_frames = data.Movie.Frames;

            % Check in workspace
            replay_name = ['replay_' data.Movie.DataName];
            if evalin('base',['exist(''replay_' data.Movie.DataName ''',''var'')'])
                app.Movie = evalin('base',replay_name);
            else
                app.Movie = [];
            end

            % If there is no movie
            if isempty(app.Movie)
                % Recreate movie
                width = data.Movie.Width;
                height = data.Movie.Height;
                signals = data.Transients.Filtered;
                app.Movie = Recreate_Movie(width,height,data.Neurons,signals);

                % Save in workspace
                assignin('base',['replay_' data.Movie.DataName],app.Movie);

                % Save in file
                Save_Tiff_Fast(app.Movie,[data.Movie.DataName ' - Replay.tiff'])
                ReplayActivityButtonPushed(app,[])
            else
                % Create figure
                factor = data.Movie.Width/data.Movie.Height;
                hfigure = Set_Figure([data.Movie.DataName ' - Replay'],[0 0 round(400*factor) 500]);
                
                % Image plot
                frame_axes = Set_Axes('frame_axes',[0 0.4 1 0.6]);
                frame_image = imshow(squeeze(app.Movie(:,:,1,:)));

                % Voltage recording plot
                external_axes = Set_Axes('external_axes',[0 0 1 0.2]);
                
                % Xsemble activity plot
                xsemble_axes = Set_Axes('xsemble_axes',[0 0.2 1 0.2]);

                % Current frame plot
                current_axes = Set_Axes('current_axes',[0 0 1 0.4]);
                
                % Create structure with convenient variables
                h.hfigure = hfigure;
                h.frame_axes = frame_axes;
                h.frame_image = frame_image;
                h.xsemble_axes = xsemble_axes;
                h.external_axes = external_axes;
                h.current_axes = current_axes;
                h.fps = data.Movie.FPS;
                
                % Add scrollbar
                h.frame_scrollbar = uicontrol(hfigure,'style','slider','units','normalized','position',[0.1 0.97 0.9 0.03],...
                    'sliderstep',[1/n_frames 10/n_frames]);
                h.frame_text = uicontrol(hfigure,'style','text','units','normalized','position',[0 0.97 0.1 0.03],...
                    'string','frame: 1','BackgroundColor',[1 1 1]);
                
                % Add second scrollbar
                h.gamma_text = uicontrol(hfigure,'style','text','units','normalized','position',[0 0.88 0.1 0.04],...
                    'string','gamma correction: 0.5','BackgroundColor',[1 1 1]);
                
                h.gamma_scrollbar = uicontrol(hfigure,'style','slider','units','normalized','position',[0 0.85 0.1 0.03],...
                    'sliderstep',[0.05 0.1],'Value',0.5);
                
                % Event scrollbar
                addlistener(h.frame_scrollbar,'Value','PreSet',@(~,~)ReplayScroll_Callback(app,h));

                % Event scrollbar
                addlistener(h.gamma_scrollbar,'Value','PostSet',@(~,~)GammaScroll_Callback(app,h));
                
                % Plot xsemble activity
                axes(xsemble_axes);
                hold(xsemble_axes,'on')
                raster = data.Analysis.Raster;
                ensemble_number = str2double(app.HighlightEnsembleDropDown.Value);

                plot_contrast_ratio = false;
                if isnan(ensemble_number)
                    plot(xsemble_axes,mean(raster,1),'k')
                    legend_text = 'entire population';
                else
                    onsemble_neurons = data.Analysis.Ensembles.OnsembleNeurons{ensemble_number};
                    offsemble_neurons = data.Analysis.Ensembles.OffsembleNeurons{ensemble_number};
                    nonparticipant_neurons = setdiff(1:data.Analysis.Neurons,onsemble_neurons);
                    nonparticipant_neurons = setdiff(nonparticipant_neurons,offsemble_neurons);
                    legend_text = {};
                    if app.PlotOnsembleCheckBox.Value
                        if app.PlotOffsembleCheckBox.Value
                            onsemble_fraction = mean(raster(onsemble_neurons,:),1);
                            offsemble_fraction = mean(raster(offsemble_neurons,:),1);
                            contrast_ratio = (onsemble_fraction+0.05)./(offsemble_fraction+0.05);
                            plot(xsemble_axes,contrast_ratio/max(contrast_ratio),'color',[0.8 0 0.8])
                            legend_text{end+1} = 'ratio ONsemble/OFFsemble';
                            plot_contrast_ratio = true;
                        end
                        plot(xsemble_axes,mean(raster(onsemble_neurons,:),1),'color',[1 0.7 0.7])
                        legend_text{end+1} = 'onsemble neurons';
                    end
                    if app.PlotOffsembleCheckBox.Value
                        plot(xsemble_axes,mean(raster(offsemble_neurons,:),1),'color',[0.7 0.7 1])
                        legend_text{end+1} = 'offsemble neurons';
                    end
                    if app.PlotNonparticipantCheckBox.Value
                        plot(xsemble_axes,mean(raster(nonparticipant_neurons,:),1),'color',[0.7 0.7 0.7])
                        legend_text{end+1} = 'nonparticipant neurons';
                    end
                    Plot_Area(data.Analysis.Ensembles.Activity(ensemble_number,:),...
                        0,[0.8 0 0.8],0.2)
                end
                set(xsemble_axes,'box','off','xtick',[],'ytick',0:0.5:1)
                
                if plot_contrast_ratio
                    set(xsemble_axes,'yticklabel',...
                        {'0',['0.5/' num2str(max(contrast_ratio)/2,'%0.1f')],...
                             ['1/' num2str(max(contrast_ratio),'%0.1f')]})
                    ylabel(xsemble_axes,{'fraction of','active neurons','/contrast ratio'})
                else
                    ylabel(xsemble_axes,{'fraction of','active neurons'})
                end
                l1 = legend(xsemble_axes,legend_text);
                l1.Position(1) = 0.88;

                % Plot current frame
                axes(current_axes)
                plot([10 10],[0 1],'--k')
                set(current_axes,'ylim',[0 1])
                axis(current_axes,'off')

                % Plot external recording
                cla(external_axes); hold on
                
                % Plot voltage recording
                if isfield(data,'VoltageRecording')
                    voltage = data.VoltageRecording;
                    legend_text = {};
                    max_y = 15;
                    if isfield(voltage,'Locomotion')
                        plot(external_axes,voltage.Locomotion,'k')
                        xlim([0 length(voltage.Locomotion)])
                        ylabel({'locomotion','[cm/s]'})
                        legend_text = {'locomotion'};
                    end
                    if isfield(voltage,'Licking')
                        axes(external_axes);
                        Plot_Area(rescale(voltage.Licking,0,max_y),0,[0.8 0.8 0.8],0.5)
                        xlim([0 length(voltage.Licking)])
                        legend_text = [legend_text {'licking'}];
                    end
                    if isfield(voltage,'Laser')
                        axes(external_axes);
                        Plot_Area(rescale(voltage.Laser,0,max_y),0,[0.3 0.3 0.3],0.5)
                        xlim([0 length(voltage.Laser)])
                        legend_text = [legend_text {'laser'}];
                    end
                    if isfield(voltage,'Stimuli')
                        axes(external_axes);
                        if nnz(voltage.Stimuli)
                            stimuli = voltage.Stimuli;
                            if nnz(stimuli)
                                stim_text = '→↗↑↖←↙↓↘';
                                legends = Plot_Stimulation(stimuli,max_y,stim_text);
                                legend_text = [legend_text legends];
                            end
                        end
                    end
                    linkaxes([external_axes xsemble_axes current_axes],'x')
                    Set_Label_Time(data.Analysis.Frames,data.Movie.FPS,0,h.external_axes)
        
                    ylim([0 max_y])
                    ylabel({'running speed','(cm/s)'})
                    box off
                    l = legend(legend_text);
                    l.Position(1)=0.91;
                    l.Position(2)=0.05;
                else
                    linkaxes([xsemble_axes current_axes],'x')
                    Set_Label_Time(data.Analysis.Frames,data.Movie.FPS,0,xsemble_axes)
                end
            end
        end

        % Value changed function: SetThresholdVisuallyCheckBox
        function SetThresholdVisuallyCheckBoxValueChanged(app, event)
            value = app.SetThresholdVisuallyCheckBox.Value;
            if value
                app.PSNRdBThSpinner.Enable = 'off';
            else
                app.PSNRdBThSpinner.Enable = 'on';
            end
        end

        % Button pushed function: PlottrialsButton
        function PlottrialsButtonPushed(app, event)
            % Read data
            data = Read_Data(app);
            if isempty(data)
                return
            end

            selection = app.StimuliDropDown.Value;
            if strcmp(selection,'-- select stimulus --')
                return
            end

            fps = data.Movie.FPS;
            pre = round(2*fps);
            post = round(2*fps);

            activation_sequence = data.Analysis.Ensembles.ActivationSequence;
            colors = Read_Colors(data.Analysis.Ensembles.Count);
            
            if isfield(data.VoltageRecording,'Stimuli')
                stimuli = data.VoltageRecording.Stimuli;
            end

            if isfield(data.VoltageRecording,'Laser')
                laser = data.VoltageRecording.Laser>0;
            end
            
            switch selection
                case 'all stimuli'
                    h_figure = Set_Figure([data.Movie.DataName ' - all stimuli'],[0 0 400 400]);
                    uicontrol(h_figure,'style','text','units','normalized',...
                    'position',[0 0.95 1 0.05],'BackgroundColor',[1 1 1],...
                    'String',data.Movie.DataName);
    
                    Plot_Ensemble_Trials(activation_sequence,stimuli,pre,post,fps,colors)
                case 'all neurons'
                    % Get the type of optogenetic activation
                    xy_stim = data.Optogenetics.XY;

                    if data.Movie.Width>256
                        xy_stim(:,1) = xy_stim(:,1)+256*2;
                    end
                    radius = data.ROIs.NeuronRadius;
                    opto = data.Optogenetics.Stimulation;
                    laser = opto.*laser;
                    n_stim_neurons = max(opto);
                    neuron_signals = data.Transients.Filtered;
                    max_signal = max(neuron_signals,[],'all');
                    
                    % Provisional ------
                    % Plot
                    h_figure = Set_Figure([data.Movie.DataName ' - Raw signal optogenetic activation'],...
                        [0 0 1200 500]);
                    uicontrol(h_figure,'style','text','units','normalized',...
                    'position',[0 0.95 1 0.05],'BackgroundColor',[1 1 1],...
                    'String',data.Movie.DataName);
    
                    n_stim_neurons = size(xy_stim,1);
                    colors = Read_Colors(n_stim_neurons);
                    [id_neuron,id_xy] = Find_Neurons_By_XY(data.Neurons,xy_stim,radius);
                    Plot_Transients(data.Transients.Raw(id_neuron,:),'separated',data.Movie.FPS,colors(id_xy,:))
                    for i = 1:n_stim_neurons
                        id_neuron = Find_Neurons_By_XY(data.Neurons,xy_stim(i,:),radius);
                        if isempty(id_neuron)
                            continue
                        end
                        opto = data.Optogenetics.Stimulation==i;
                        Plot_Area((opto>0)*max(get(gca,'ylim')),0,colors(i,:),1); hold on
                    end
                    % Provisional ------

                    % Plot
                    h_figure = Set_Figure([data.Movie.DataName ' - Optogenetic stimulation'],...
                        [0 0 1200 500]);
                    uicontrol(h_figure,'style','text','units','normalized',...
                    'position',[0 0.95 1 0.05],'BackgroundColor',[1 1 1],...
                    'String',data.Movie.DataName);
    
                    show_axis = true;
                    for i = 1:n_stim_neurons
                        % Get laser times of single neuron
                        single_laser = zeros(size(laser));
                        single_laser(laser==i) = i;

                        % Get single neurons trials
                        id_neuron = Find_Neurons_By_XY(data.Neurons,xy_stim(i,:),radius);
                        
                        if isempty(id_neuron)
                            continue
                        end

                        % Get trial responses from a stimulated neuron
                        trials = Get_Trial_Responses(neuron_signals(id_neuron,:),...
                            single_laser,pre,post);

                        if isempty(trials)
                            continue
                        end
                        
                        avg_trial = mean(trials,1);
                        frames = size(trials,2);

                        % Plot stimulated neuron
                        h_stim(i) = subplot(3,ceil(n_stim_neurons/3),i);
                        plot(trials','color',[0.5 0.5 0.5]); hold on
                        plot(avg_trial,'k','LineWidth',2)
                        plot([pre pre],[0 max_signal],'--r')
                        ylim([0 max_signal])
                        title([num2str(i) ' (' num2str(id_neuron) ')'])
                        
                        if show_axis
                            Set_Label_Time(frames,fps,pre)
                            ylabel('\DeltaF/F_0')
                            show_axis = false;
                        else
                            axis off
                        end
                    end
                    linkaxes(h_stim,'y')
                case 'laser'
                    h_figure = Set_Figure([data.Movie.DataName ' - laser (ensembles)'],[0 0 400 400]);
                    uicontrol(h_figure,'style','text','units','normalized',...
                    'position',[0 0.95 1 0.05],'BackgroundColor',[1 1 1],...
                    'String',data.Movie.DataName);
    
                    Plot_Ensemble_Trials(activation_sequence,laser,pre,post,fps,colors)
                otherwise
                    if isscalar(selection)
                        % Single visual stimulation
                        % Get the type of visual stimulation
                        id = find('→↗↑↖←↙↓↘'==selection);
                        single_stim = zeros(size(stimuli));
                        single_stim(stimuli==id) = id;

                        % Plot
                        Set_Figure([data.Movie.DataName ' - stimulus ' selection],[0 0 400 400])
                        Plot_Ensemble_Trials(activation_sequence,single_stim,pre,post,fps,colors)
                    else
                        % Single neuron 
                        % Get trial responses from a stimulated neuron
                        i = str2double(selection(8:end));
                        raster = data.Transients.Raster;
                        transients = data.Transients.Smoothed;
                        xy_stim = data.Optogenetics.XY;
                        radius = data.ROIs.NeuronRadius;
                        laser = data.Optogenetics.Stimulation;

                        % Get single neurons trials
                        id_neuron = Find_Neurons_By_XY(data.Neurons,xy_stim(i,:),radius);
                        if isempty(id_neuron)
                            return
                        end

                        % Get laser times of single neuron
                        single_laser = zeros(size(laser));
                        single_laser(laser==i) = i;

                        signal_neuron = data.Transients.Filtered(id_neuron,:);
                        [trials,trial_times] = Get_Trial_Responses(signal_neuron,...
                            single_laser,pre,post);
                        [n_trials,trial_size] = size(trials);
                        avg_trials = mean(trials,1);

                        % Get raster trials
                        avg_raster = 0;
                        avg_transients = 0;
                        for j = 1:n_trials
                            avg_raster = avg_raster+raster(:,trial_times(j,:));
                            avg_transients = avg_transients+transients(:,trial_times(j,:));
                        end
                        avg_raster = avg_raster/n_trials;

                        % correlation to neuron
                        neuron_corr = 1-pdist2(avg_trials,avg_raster,'correlation');
                        [~,sorting_id] = sort(neuron_corr,'descend');
                        
                        % Plot stimulated neuron
                        Set_Figure([data.Movie.DataName ' - neuron ' num2str(i)...
                            ' (' num2str(id_neuron) ')'],[0 0 600 500])
                        h_raster_avg = subplot(4,2,[1 3 5]);
                        Plot_Raster(avg_raster(sorting_id,:));hold on
                        plot([pre pre]+1,[0 data.Analysis.Neurons],'--r','LineWidth',2)
                        xticks([])
                        title([num2str(i) ' (' num2str(id_neuron) ')'])
                        ylabel('nuerons sorted by correlation to stimulated neuron')
                        
                        h_stim = subplot(4,2,7);
                        plot(trials','color',[0.5 0.5 0.5]); hold on
                        plot(avg_trials,'k','LineWidth',2)
                        plot([pre pre]+1,[0 max(trials(:))],'--r','LineWidth',2)
                        ylabel('\DeltaF/F_{0}')
                        Set_Label_Time(size(trials,2),fps,pre)

                        h_raster_trials = subplot(4,2,[2 4 6]);
                        Plot_Raster(raster(sorting_id,reshape(trial_times',1,[])))
                        ylabel('')
                        y_lims = get(gca,'ylim');
                        hold on
                        %Plot_Transients(avg_transients(id_corr(sorting_id_2),:),'separated',fps,[0 0 0]);
                        for j = 1:n_trials
                            plot([1 1]*trial_size*j,y_lims,'color',[0 0 0],'LineWidth',2)
                            plot([pre pre]+1+trial_size*(j-1),y_lims,'--r','LineWidth',2)
                        end
                        axis off
                        xlim([0 n_trials*trial_size])

                        % Plot raster trials
                        h_single = subplot(4,2,8);
                        plot(reshape(trials',1,[]),'color',[0.5 0.5 0.5]); hold on
                        y_lims = get(gca,'ylim');
                        for j = 1:n_trials
                            plot([1 1]*trial_size*j,y_lims,'color',[0 0 0],'LineWidth',2)
                            plot([pre pre]+1+trial_size*(j-1),y_lims,'--r','LineWidth',2)
                        end
                        ylabel('\DeltaF/F_{0}')
                        xticks((1:trial_size:n_trials*trial_size)+trial_size/2)
                        xticklabels(1:n_trials)
                        xlabel('trial #')
                        xlim([0 n_trials*trial_size])

                        linkaxes([h_raster_avg h_stim],'x')
                        linkaxes([h_raster_trials h_single],'x')
                        linkaxes([h_raster_trials h_raster_avg],'y')
                    end
            end
        end

        % Drop down opening function: StimuliDropDown
        function StimuliDropDownOpening(app, event)
            % Read data
            data = Read_Data(app);
            if isempty(data)
                return
            end
            data_strings = {'-- select stimulus --'};
            if isfield(data.VoltageRecording,'Stimuli')
                stimuli = data.VoltageRecording.Stimuli;
                stimulus_types = unique(stimuli);
                stimulus_types = setdiff(stimulus_types,0);
                n_stim = length(stimulus_types);

                if n_stim>1
                    data_strings{end+1} = 'all stimuli';
                    if stimulus_types<=8
                        arrows = '→↗↑↖←↙↓↘';
                        for i = stimulus_types
                            data_strings{end+1} = arrows(i);
                        end
                    end
                end                
            end
            if isfield(data.VoltageRecording,'Laser')
                laser = data.VoltageRecording.Laser>0;
                if nnz(laser)
                    data_strings{end+1} = 'laser';
                    if isfield(data,'Optogenetics')
                        opto = data.Optogenetics.Stimulation;
                        laser = opto.*laser;
                        laser_types = unique(laser);
                        laser_types = setdiff(laser_types,0);
    
                        if length(laser_types)>1
                            data_strings{end+1} = 'all neurons';
                        end
    
                        for i = laser_types
                            data_strings{end+1} = ['neuron ' num2str(i)];
                        end
                    end
                end
            end
            set(app.StimuliDropDown,'items',data_strings)
        end

        % Button pushed function: PlotStimLocationButton
        function PlotStimLocationButtonPushed(app, event)
            data = Read_Data(app);
            if isempty(data)
                return
            end

            if isfield(data,'Optogenetics')
                Set_Figure([data.Movie.DataName ' - Optogenetics'],[0 0 500 500])
                if data.Movie.Width>256
                    Plot_Neurons_Stimulated(data,256*2)
                else
                    Plot_Neurons_Stimulated(data)
                end
                title(strrep(data.Movie.DataName,'_','-'))
            else
                disp('There are no optogenetic data loaded!')
            end
        end

        % Button pushed function: FileButton
        function FileButtonPushed(app, event)
            [file_name,path_name] = uigetfile('*.tif;*.avi','Select one video');
            if file_name
                app.FileEditField.Value = [path_name file_name];
            end
        end

        % Drop down opening function: SortNeuronsDropDown
        function SortNeuronsDropDownOpening(app, event)
            data = Read_Data(app);
            if isempty(data)
                return
            end

            data_strings = {};
            for i = 1:data.Analysis.Ensembles.Count
                data_strings{i} = ['EPI - ensemble ' num2str(i)];
            end
            workspace_strings = evalin('base','who')';
            data_strings = [{'no sorting of neurons'}...
                            {'ensemble sorting'}...
                            {'ONsemble sorting'}...
                            {'OFFsemble sorting'}...
                            data_strings...
                            workspace_strings];
            set(app.SortNeuronsDropDown,'items',data_strings)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Xsembles2PViewerUIFigure and hide until all components are created
            app.Xsembles2PViewerUIFigure = uifigure('Visible', 'off');
            app.Xsembles2PViewerUIFigure.Position = [100 100 313 540];
            app.Xsembles2PViewerUIFigure.Name = 'Xsembles2P - Viewer';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.Xsembles2PViewerUIFigure);
            app.TabGroup.Position = [9 10 297 522];

            % Create AnalyzeTab
            app.AnalyzeTab = uitab(app.TabGroup);
            app.AnalyzeTab.Title = 'Analyze';

            % Create VideoPanel
            app.VideoPanel = uipanel(app.AnalyzeTab);
            app.VideoPanel.Title = 'Video';
            app.VideoPanel.Position = [11 393 271 95];

            % Create samplingperiodmsLabel_2
            app.samplingperiodmsLabel_2 = uilabel(app.VideoPanel);
            app.samplingperiodmsLabel_2.HorizontalAlignment = 'right';
            app.samplingperiodmsLabel_2.Position = [18 8 118 22];
            app.samplingperiodmsLabel_2.Text = 'sampling period (ms)';

            % Create AnalysisSamplingPeriodSpinner
            app.AnalysisSamplingPeriodSpinner = uispinner(app.VideoPanel);
            app.AnalysisSamplingPeriodSpinner.Limits = [1 Inf];
            app.AnalysisSamplingPeriodSpinner.HorizontalAlignment = 'center';
            app.AnalysisSamplingPeriodSpinner.Position = [166 5 92 28];
            app.AnalysisSamplingPeriodSpinner.Value = 80;

            % Create FileButton
            app.FileButton = uibutton(app.VideoPanel, 'push');
            app.FileButton.ButtonPushedFcn = createCallbackFcn(app, @FileButtonPushed, true);
            app.FileButton.Position = [11 41 28 22];
            app.FileButton.Text = '...';

            % Create FileEditField
            app.FileEditField = uieditfield(app.VideoPanel, 'text');
            app.FileEditField.Position = [48 41 209 22];

            % Create MotioncorrectionPanel
            app.MotioncorrectionPanel = uipanel(app.AnalyzeTab);
            app.MotioncorrectionPanel.Title = 'Motion correction';
            app.MotioncorrectionPanel.Position = [11 300 271 90];

            % Create FastMotionCorrectionCheckBox
            app.FastMotionCorrectionCheckBox = uicheckbox(app.MotioncorrectionPanel);
            app.FastMotionCorrectionCheckBox.ValueChangedFcn = createCallbackFcn(app, @FastMotionCorrectionCheckBoxValueChanged, true);
            app.FastMotionCorrectionCheckBox.Text = 'fast motion correction';
            app.FastMotionCorrectionCheckBox.Position = [17 40 140 22];
            app.FastMotionCorrectionCheckBox.Value = true;

            % Create locomotionthresholdLabel
            app.locomotionthresholdLabel = uilabel(app.MotioncorrectionPanel);
            app.locomotionthresholdLabel.HorizontalAlignment = 'center';
            app.locomotionthresholdLabel.Position = [13 11 128 22];
            app.locomotionthresholdLabel.Text = 'speed threshold (cm/s)';

            % Create SpeedThSpinner
            app.SpeedThSpinner = uispinner(app.MotioncorrectionPanel);
            app.SpeedThSpinner.Step = 0.1;
            app.SpeedThSpinner.Limits = [0 Inf];
            app.SpeedThSpinner.ValueDisplayFormat = '%.1f';
            app.SpeedThSpinner.HorizontalAlignment = 'center';
            app.SpeedThSpinner.Position = [166 7 92 28];
            app.SpeedThSpinner.Value = 1;

            % Create AnalyzeVideoButton
            app.AnalyzeVideoButton = uibutton(app.AnalyzeTab, 'push');
            app.AnalyzeVideoButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeVideoButtonPushed, true);
            app.AnalyzeVideoButton.Position = [11 5 270 22];
            app.AnalyzeVideoButton.Text = 'Analyze video';

            % Create SignalevaluationPanel
            app.SignalevaluationPanel = uipanel(app.AnalyzeTab);
            app.SignalevaluationPanel.Title = 'Signal evaluation';
            app.SignalevaluationPanel.Position = [11 92 271 91];

            % Create samplingperiodmsLabel_4
            app.samplingperiodmsLabel_4 = uilabel(app.SignalevaluationPanel);
            app.samplingperiodmsLabel_4.HorizontalAlignment = 'center';
            app.samplingperiodmsLabel_4.Enable = 'off';
            app.samplingperiodmsLabel_4.Position = [19 14 116 22];
            app.samplingperiodmsLabel_4.Text = 'PSNR threshold (dB)';

            % Create PSNRdBThSpinner
            app.PSNRdBThSpinner = uispinner(app.SignalevaluationPanel);
            app.PSNRdBThSpinner.Limits = [0 Inf];
            app.PSNRdBThSpinner.ValueDisplayFormat = '%.1f';
            app.PSNRdBThSpinner.HorizontalAlignment = 'center';
            app.PSNRdBThSpinner.Enable = 'off';
            app.PSNRdBThSpinner.Position = [166 10 92 28];
            app.PSNRdBThSpinner.Value = 10;

            % Create SetThresholdVisuallyCheckBox
            app.SetThresholdVisuallyCheckBox = uicheckbox(app.SignalevaluationPanel);
            app.SetThresholdVisuallyCheckBox.ValueChangedFcn = createCallbackFcn(app, @SetThresholdVisuallyCheckBoxValueChanged, true);
            app.SetThresholdVisuallyCheckBox.Text = 'set threshold visually';
            app.SetThresholdVisuallyCheckBox.Position = [20 43 134 22];
            app.SetThresholdVisuallyCheckBox.Value = true;

            % Create NeuronsPanel
            app.NeuronsPanel = uipanel(app.AnalyzeTab);
            app.NeuronsPanel.Title = 'Neurons';
            app.NeuronsPanel.Position = [11 187 271 109];

            % Create NeuronsDropDown
            app.NeuronsDropDown = uidropdown(app.NeuronsPanel);
            app.NeuronsDropDown.Items = {'-- find neurons --'};
            app.NeuronsDropDown.DropDownOpeningFcn = createCallbackFcn(app, @NeuronsDropDownOpening, true);
            app.NeuronsDropDown.ValueChangedFcn = createCallbackFcn(app, @NeuronsDropDownValueChanged, true);
            app.NeuronsDropDown.Position = [16 55 241 22];
            app.NeuronsDropDown.Value = '-- find neurons --';

            % Create samplingperiodmsLabel_3
            app.samplingperiodmsLabel_3 = uilabel(app.NeuronsPanel);
            app.samplingperiodmsLabel_3.HorizontalAlignment = 'center';
            app.samplingperiodmsLabel_3.Position = [16 16 120 22];
            app.samplingperiodmsLabel_3.Text = 'neuron radius (pixels)';

            % Create NeuronRadiusSpinner
            app.NeuronRadiusSpinner = uispinner(app.NeuronsPanel);
            app.NeuronRadiusSpinner.Limits = [1 Inf];
            app.NeuronRadiusSpinner.ValueDisplayFormat = '%.0f';
            app.NeuronRadiusSpinner.HorizontalAlignment = 'center';
            app.NeuronRadiusSpinner.Position = [165 13 92 28];
            app.NeuronRadiusSpinner.Value = 3;

            % Create XsembleanalysisPanel
            app.XsembleanalysisPanel = uipanel(app.AnalyzeTab);
            app.XsembleanalysisPanel.Title = 'Ensemble analysis';
            app.XsembleanalysisPanel.Position = [11 31 271 57];

            % Create XsemblesAnalysisCheckBox
            app.XsemblesAnalysisCheckBox = uicheckbox(app.XsembleanalysisPanel);
            app.XsemblesAnalysisCheckBox.Text = 'Get ensembles (onsembles+offsembles)';
            app.XsemblesAnalysisCheckBox.Position = [17 7 240 22];
            app.XsemblesAnalysisCheckBox.Value = true;

            % Create VisualizeTab
            app.VisualizeTab = uitab(app.TabGroup);
            app.VisualizeTab.Title = 'Visualize';

            % Create RasterPanel
            app.RasterPanel = uipanel(app.VisualizeTab);
            app.RasterPanel.Title = 'Raster';
            app.RasterPanel.Position = [12 362 278 126];

            % Create SelectDataDropDown
            app.SelectDataDropDown = uidropdown(app.RasterPanel);
            app.SelectDataDropDown.Items = {'-- select data --'};
            app.SelectDataDropDown.DropDownOpeningFcn = createCallbackFcn(app, @SelectDataDropDownOpening, true);
            app.SelectDataDropDown.ValueChangedFcn = createCallbackFcn(app, @SelectDataDropDownValueChanged, true);
            app.SelectDataDropDown.Position = [10 72 260 22];
            app.SelectDataDropDown.Value = '-- select data --';

            % Create SortVectorsCheckBox
            app.SortVectorsCheckBox = uicheckbox(app.RasterPanel);
            app.SortVectorsCheckBox.Text = 'sort vectors';
            app.SortVectorsCheckBox.Position = [184 41 86 22];

            % Create PlotRasterButton
            app.PlotRasterButton = uibutton(app.RasterPanel, 'push');
            app.PlotRasterButton.ButtonPushedFcn = createCallbackFcn(app, @PlotRasterButtonPushed, true);
            app.PlotRasterButton.Position = [10 10 120 22];
            app.PlotRasterButton.Text = 'Plot raster';

            % Create ReplayActivityButton
            app.ReplayActivityButton = uibutton(app.RasterPanel, 'push');
            app.ReplayActivityButton.ButtonPushedFcn = createCallbackFcn(app, @ReplayActivityButtonPushed, true);
            app.ReplayActivityButton.Position = [150 10 120 22];
            app.ReplayActivityButton.Text = 'Replay activity';

            % Create SortNeuronsDropDown
            app.SortNeuronsDropDown = uidropdown(app.RasterPanel);
            app.SortNeuronsDropDown.Items = {'no sorting of neurons', 'ensemble sorting'};
            app.SortNeuronsDropDown.DropDownOpeningFcn = createCallbackFcn(app, @SortNeuronsDropDownOpening, true);
            app.SortNeuronsDropDown.Position = [10 41 149 22];
            app.SortNeuronsDropDown.Value = 'ensemble sorting';

            % Create XsemblesPanel
            app.XsemblesPanel = uipanel(app.VisualizeTab);
            app.XsemblesPanel.Title = 'Xsembles';
            app.XsemblesPanel.Position = [12 110 278 248];

            % Create PlotOnsembleCheckBox
            app.PlotOnsembleCheckBox = uicheckbox(app.XsemblesPanel);
            app.PlotOnsembleCheckBox.Enable = 'off';
            app.PlotOnsembleCheckBox.Text = 'ensemble';
            app.PlotOnsembleCheckBox.Position = [10 171 74 22];
            app.PlotOnsembleCheckBox.Value = true;

            % Create PlotOffsembleCheckBox
            app.PlotOffsembleCheckBox = uicheckbox(app.XsemblesPanel);
            app.PlotOffsembleCheckBox.Enable = 'off';
            app.PlotOffsembleCheckBox.Text = 'offsemble';
            app.PlotOffsembleCheckBox.Position = [90 171 75 22];
            app.PlotOffsembleCheckBox.Value = true;

            % Create PlotNonparticipantCheckBox
            app.PlotNonparticipantCheckBox = uicheckbox(app.XsemblesPanel);
            app.PlotNonparticipantCheckBox.Enable = 'off';
            app.PlotNonparticipantCheckBox.Text = 'nonparticipant';
            app.PlotNonparticipantCheckBox.Position = [170 171 95 22];
            app.PlotNonparticipantCheckBox.Value = true;

            % Create PlotSignalsButton
            app.PlotSignalsButton = uibutton(app.XsemblesPanel, 'push');
            app.PlotSignalsButton.ButtonPushedFcn = createCallbackFcn(app, @PlotSignalsButtonPushed, true);
            app.PlotSignalsButton.WordWrap = 'on';
            app.PlotSignalsButton.Position = [150 141 120 22];
            app.PlotSignalsButton.Text = 'Plot signals';

            % Create SelectSignalsDropDown
            app.SelectSignalsDropDown = uidropdown(app.XsemblesPanel);
            app.SelectSignalsDropDown.Items = {'binary', 'raw', 'filtered', 'smoothed', 'inference'};
            app.SelectSignalsDropDown.Position = [10 141 120 22];
            app.SelectSignalsDropDown.Value = 'binary';

            % Create GetNeuronsButton
            app.GetNeuronsButton = uibutton(app.XsemblesPanel, 'push');
            app.GetNeuronsButton.ButtonPushedFcn = createCallbackFcn(app, @GetNeuronsButtonPushed, true);
            app.GetNeuronsButton.WordWrap = 'on';
            app.GetNeuronsButton.Position = [10 12 120 40];
            app.GetNeuronsButton.Text = 'Export neurons to workspace';

            % Create GetStimulationFilesButton
            app.GetStimulationFilesButton = uibutton(app.XsemblesPanel, 'push');
            app.GetStimulationFilesButton.ButtonPushedFcn = createCallbackFcn(app, @GetStimulationFilesButtonPushed, true);
            app.GetStimulationFilesButton.WordWrap = 'on';
            app.GetStimulationFilesButton.Position = [150 12 120 40];
            app.GetStimulationFilesButton.Text = 'Export prairie stimulation files';

            % Create ShapeCheckBox
            app.ShapeCheckBox = uicheckbox(app.XsemblesPanel);
            app.ShapeCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShapeCheckBoxValueChanged, true);
            app.ShapeCheckBox.Text = 'shape';
            app.ShapeCheckBox.Position = [10 95 55 22];
            app.ShapeCheckBox.Value = true;

            % Create BrightnessNeuronsCheckBox
            app.BrightnessNeuronsCheckBox = uicheckbox(app.XsemblesPanel);
            app.BrightnessNeuronsCheckBox.Text = 'PSNR brightness';
            app.BrightnessNeuronsCheckBox.Position = [10 76 114 22];
            app.BrightnessNeuronsCheckBox.Value = true;

            % Create PlotNeuronsButton
            app.PlotNeuronsButton = uibutton(app.XsemblesPanel, 'push');
            app.PlotNeuronsButton.ButtonPushedFcn = createCallbackFcn(app, @PlotNeuronsButtonPushed, true);
            app.PlotNeuronsButton.Position = [149 76 120 40];
            app.PlotNeuronsButton.Text = 'Plot spatial location';

            % Create HighlightensembleLabel
            app.HighlightensembleLabel = uilabel(app.XsemblesPanel);
            app.HighlightensembleLabel.HorizontalAlignment = 'right';
            app.HighlightensembleLabel.Position = [47 198 103 22];
            app.HighlightensembleLabel.Text = 'select ensemble:';

            % Create HighlightEnsembleDropDown
            app.HighlightEnsembleDropDown = uidropdown(app.XsemblesPanel);
            app.HighlightEnsembleDropDown.Items = {'no'};
            app.HighlightEnsembleDropDown.DropDownOpeningFcn = createCallbackFcn(app, @EnsembleDropDownOpening, true);
            app.HighlightEnsembleDropDown.ValueChangedFcn = createCallbackFcn(app, @HighlightEnsembleDropDownValueChanged, true);
            app.HighlightEnsembleDropDown.Position = [165 198 69 22];
            app.HighlightEnsembleDropDown.Value = 'no';

            % Create DividerALabel
            app.DividerALabel = uilabel(app.XsemblesPanel);
            app.DividerALabel.HorizontalAlignment = 'center';
            app.DividerALabel.Position = [3 118 269 22];
            app.DividerALabel.Text = '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -';

            % Create DividerBLabel
            app.DividerBLabel = uilabel(app.XsemblesPanel);
            app.DividerBLabel.HorizontalAlignment = 'center';
            app.DividerBLabel.Position = [3 53 269 22];
            app.DividerBLabel.Text = '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -';

            % Create StimulationPanel
            app.StimulationPanel = uipanel(app.VisualizeTab);
            app.StimulationPanel.Title = 'Stimulation';
            app.StimulationPanel.Position = [12 7 278 99];

            % Create PlottrialsButton
            app.PlottrialsButton = uibutton(app.StimulationPanel, 'push');
            app.PlottrialsButton.ButtonPushedFcn = createCallbackFcn(app, @PlottrialsButtonPushed, true);
            app.PlottrialsButton.Position = [164 49 105 22];
            app.PlottrialsButton.Text = 'Plot trials';

            % Create StimuliDropDown
            app.StimuliDropDown = uidropdown(app.StimulationPanel);
            app.StimuliDropDown.Items = {'-- select stimulus --'};
            app.StimuliDropDown.DropDownOpeningFcn = createCallbackFcn(app, @StimuliDropDownOpening, true);
            app.StimuliDropDown.Position = [10 49 141 22];
            app.StimuliDropDown.Value = '-- select stimulus --';

            % Create PlotStimLocationButton
            app.PlotStimLocationButton = uibutton(app.StimulationPanel, 'push');
            app.PlotStimLocationButton.ButtonPushedFcn = createCallbackFcn(app, @PlotStimLocationButtonPushed, true);
            app.PlotStimLocationButton.Position = [10 12 260 22];
            app.PlotStimLocationButton.Text = 'Plot location of stimulated neurons';

            % Create CitationTab
            app.HelpTab = uitab(app.TabGroup);
            app.HelpTab.Title = 'Help';

            % Create KeepituptodatePanel
            app.KeepituptodatePanel = uipanel(app.HelpTab);
            app.KeepituptodatePanel.Title = 'Keep it up to date:';
            app.KeepituptodatePanel.Position = [12 372 278 113];

            % Create GithubLabel
            app.GithubLabel = uilabel(app.KeepituptodatePanel);
            app.GithubLabel.WordWrap = 'on';
            app.GithubLabel.FontAngle = 'italic';
            app.GithubLabel.Position = [13 39 254 44];
            app.GithubLabel.Text = 'Follow Xsembles2P on GitHub. Your input matters! Feel free to comment or suggest contributions to enhance this tool.';

            % Create GithubLink
            app.GithubLink = uihyperlink(app.KeepituptodatePanel);
            app.GithubLink.HorizontalAlignment = 'center';
            app.GithubLink.URL = 'https://github.com/PerezOrtegaJ/Xsembles2P';
            app.GithubLink.Position = [16 8 243 23];
            app.GithubLink.Text = 'github.com/PerezOrtegaJ/Xsembles2P';

            % Create CitationPanel
            app.CitationPanel = uipanel(app.HelpTab);
            app.CitationPanel.Title = 'Please cite our paper:';
            app.CitationPanel.Position = [12 254 278 109];

            % Create CitationLabel
            app.CitationLabel = uilabel(app.CitationPanel);
            app.CitationLabel.WordWrap = 'on';
            app.CitationLabel.FontAngle = 'italic';
            app.CitationLabel.Position = [13 35 254 44];
            app.CitationLabel.Text = 'Pérez-Ortega, J., Akrouh, A. & Yuste, R. 2024. Stimulus encoding by specific inactivation of cortical neurons. Nat Commun 15, 3192.';

            % Create DOILink
            app.DOILink = uihyperlink(app.CitationPanel);
            app.DOILink.HorizontalAlignment = 'center';
            app.DOILink.URL = 'https://doi.org/10.1038/s41467-024-47515-x';
            app.DOILink.Position = [13 8 234 23];
            app.DOILink.Text = 'doi: 10.1038/s41467-024-47515-x';

             % Create ContactPanel
            app.ContactPanel = uipanel(app.HelpTab);
            app.ContactPanel.Title = 'Contact:';
            app.ContactPanel.Position = [12 153 278 92];

            % Create EmailLabel
            app.EmailLabel = uilabel(app.ContactPanel);
            app.EmailLabel.WordWrap = 'on';
            app.EmailLabel.FontAngle = 'italic';
            app.EmailLabel.Position = [13 40 43 22];
            app.EmailLabel.Text = 'emails: ';

            % Create EmailLink
            app.EmailLink = uihyperlink(app.ContactPanel);
            app.EmailLink.HorizontalAlignment = 'center';
            app.EmailLink.URL = 'mailto: jesus.perez@columbia.edu';
            app.EmailLink.Position = [55 40 211 23];
            app.EmailLink.Text = 'jesus.perez@columbia.edu';

            % Create EmailLink_2
            app.EmailLink2 = uihyperlink(app.ContactPanel);
            app.EmailLink2.HorizontalAlignment = 'center';
            app.EmailLink2.URL = 'mailto: jesus.epo@gmail.com';
            app.EmailLink2.Position = [55 15 211 23];
            app.EmailLink2.Text = 'jesus.epo@gmail.com';

            % Show the figure after all components are created
            app.Xsembles2PViewerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Xsembles_2P_Viewer

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Xsembles2PViewerUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Xsembles2PViewerUIFigure)
        end
    end
end