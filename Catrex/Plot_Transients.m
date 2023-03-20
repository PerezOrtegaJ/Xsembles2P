function Plot_Transients(transients,mode,fps,colors,shift,newFigure,name)
% Plot Ca transients
%
%       Plot_Transients(transients,mode,fps,colors,shift,newFigure,name)
%
%       default: name = ''; mode = 'raster'; fps = 1; colors = []; 
%                newFigure = false; shift = 0;
%
%       modes: 'raster', 'basic', 'steps', 'separated', 'area', and 'normalized'
%
% Jesus Perez-Ortega March-19
% Modified Oct 2019
% Modified Ago 2021
% Modified Feb 2022

switch nargin
    case 1
        mode = 'raster';
        fps = 1;
        colors = [];
        shift = 0;
        newFigure = false;
        name = [];
    case 2
        fps = 1;
        colors = [];
        shift = 0;
        newFigure = false;
        name = [];
    case 3
        colors = [];
        shift = 0;
        newFigure = false;
        name = [];
    case 4
        shift = 0;
        newFigure = false;
        name = [];
    case 5
        newFigure = false;
        name = [];
    case 6
        name = [];
end

% Get information
[nCells,nFrames] = size(transients);

% Get colors
if isempty(colors)
    colors = Read_Colors(nCells);
elseif size(colors,1)==1
    colors = repmat(colors,nCells,1);
end
        

% Set Figure
if newFigure
    Set_Figure(['Transients - ' name],[0 0 1000 400]);
    Set_Axes('axTransients',[0 0 1 1]); hold on
end

switch (mode)
    case 'raster'
        imagesc(transients); colormap(flipud(gray))
        ylim([0.5 nCells+0.5])
        ylabel('neuron #')
        c = colorbar;
        c.Label.String = 'Intensity (\DeltaF)';
        set(gca,'ydir','normal')
    case 'basic'
        % Plot
        for i = 1:nCells
            plot(transients(i,:),'color',colors(i,:)); hold on
        end
        %ylabel('Intensity (\DeltaF)')
        ylabel('activity')
    case 'steps'
        % Set the size of steps
        step_x = nFrames/nCells/2;
        step_y = max(transients(:))*0.05;
        
        % Plot
        c = mod(nCells,5)+1;
        for i = nCells:-1:1
            if (c==1)
                c=5;
            else
                c=c-1;
            end
            time = ((step_x*i):(step_x*i+nFrames-1))/2.55;
            plot(time,transients(i,:)+step_y*i,'color',colors(i,:)); hold on
        end    
        ylabel('Intensity (\DeltaF)')
    case 'separated'
        % Set the size of steps
        increment = 0;
        
        % Plot
        for i = 1:nCells
            signal = transients(i,:)-min(transients(i,:));
            plot(signal+increment,'color',colors(i,:)); hold on
            increment = increment+max(signal);
        end    
        ylabel('Intensity (\DeltaF)')
    case 'area'
            % Set the size of steps
        increment = 0;
        
        % Plot
        for i = 1:nCells
            signal = transients(i,:)-min(transients(i,:));
            Plot_Area(signal+increment,increment,colors(i,:)); hold on
            increment = increment+max(signal);
        end    
        ylabel('Intensity (\DeltaF)')
    
    case 'normalized'
        % Set the size of steps
        increment = 0;
        
        % Plot
        for i = 1:nCells
            signal = rescale(transients(i,:));
            plot(signal+increment,'color',colors(i,:)); hold on
            increment = increment + max(signal);
        end    
        ylabel('Intensity (\DeltaF)')
    otherwise
        warning('The ''raster'' mode was applied.')
        imagesc(transients,[0,1]); colormap(flipud(gray))
        ylabel('neuron #')
        c = colorbar;
        c.Label.String = 'Intensity (\DeltaF)';
end
title(strrep(name,'_','-'))
xlim([0 nFrames])

Set_Label_Time(nFrames,fps,shift)