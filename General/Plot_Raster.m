function reshapeWin = Plot_Raster(data,name,spikes,reshape,newFigure)
% Plot Raster
%
%       reshapeWin = Plot_Raster(data,name,spikes,reshape,create_figure)
%
%       default: name=''; spikes = true; reshape = false; create_figure = false;
%
% Pérez-Ortega Jesús 2018
% modified May 2019
% Modified Sep 2019
% Modified Sep 2021

switch nargin
    case 1
        name='';
        spikes = true;
        reshape = false;   
        newFigure = false;
    case 2
        spikes = true;
        reshape = false;    
        newFigure = false;
    case 3
        reshape = false;    
        newFigure = false;
    case 4
        newFigure = false;
end

% Get size of the raster
[cells,frames] = size(data);

% Create a new figure
if newFigure
    Set_Figure(['Raster (' name ')'],[0 0 1220 460]);
    Set_Axes(['RasterAxes' name],[0 0.34 1 0.66]);
end
axis([0.5 frames 0.5 cells+0.5]); hold on

% Plot raster
if spikes
    if reshape>1
        win = reshape;
    elseif reshape
        if frames<2000
            win = 1;
        elseif frames<4000
            win = 2;
        elseif frames<16000
            win = 5;
        elseif frames<20000
            win = 10;
        elseif frames<500000
            win = 20;
        else
            win = 50;
        end
    else
        win = 1;
    end

    if (nnz(data(:)==0)+nnz(data(:)==1)) ~= numel(data)
        imagesc(data,[0 max(data(:))]);
        colormap(gca,flipud(gray))
        binary = false;
    else
        data = Reshape_Raster(data,win);
        if cells<2
            yfin = 2;
        else
            yfin = cells;
        end
        if frames/win<2
            xfin = 2;
        else
            xfin = frames/win;
        end
        axis([1 xfin 1 yfin])
        
%       % Plot dots for each spike
%         hold on
%         for i = 1:cells
%             id = find(data(i,:));
%             plot(id,data(i,id)*i,'.k')
%         end
%         set(gca,'XTick',[])
        
        imagesc(data,[0,1]);
        colormap(gca,[1 1 1; 0 0 0])
        binary = true;
    end
else
    imagesc(data,[-4 4]); Set_Colormap_Blue_White_Red();
end
ylim([0.5 cells+0.5])
ylabel('neuron #')
box on

if reshape && binary
    xlim([0 frames/win])
else
    xlim([0 frames])
end

%set(gca,'XTicklabel','','XTick',[0 frames])
title(strrep(name,'_','-'))

if nargout
    reshapeWin = win;
end