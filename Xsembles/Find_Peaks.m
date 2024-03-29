function [indices,widths,amplitudes,ini_fin_times] = Find_Peaks(data,threshold,join,...
    detect_peaks,minimum_width,fixed_width,ignore_ini_fin)
% Find peaks from signal by a given threshold.
%
%   [indices,widths,amplitudes,ini_fin_times] = Find_Peaks(data,threshold,join,...
%    detect_peaks,minimum_width,fixed_width,ignore_ini_fin)
%
%           default: threshold = 0; join = true; detect_peaks = true;
%                    minimum_width = 0; fixed_width = 0; ignore_ini_fin = false;
%
% Inputs
% data = data as vector Fx1 (F = #frames)
% threshold = threshold
% join = set mode to get peaks (0 = each vector above threshold is a peak;
%        1 = joining of adjacent vectors above the threshold is a peak)
%
% Outputs
% indices = Fx1 vector containing the peak indices
%
% 1. Get indices above threshold
% 2. Ignore initial and final peaks (or valleys)    - Optional
% 3. Restriction to minimum width                   - Optional
% 4. Set a fixed width                              - Optional
% 5. Set the number at each peak (or valley)
% 6. Join peaks or valleys                          - Optional
%
% by Jesus E. Perez-Ortega, Feb-2012
% last modification July-2019
% Modified Oct 2021
% Modified Feb 2023

switch nargin
    case 6
        ignore_ini_fin = false;
    case 5      
        ignore_ini_fin = false;
        fixed_width = 0;
    case 4
        ignore_ini_fin = false;
        fixed_width = 0;
        minimum_width = 0;
    case 3
        ignore_ini_fin = false;
        fixed_width = 0;
        minimum_width = 0;
        detect_peaks = true;
    case 2
        ignore_ini_fin = false;
        fixed_width = 0;
        minimum_width = 0;
        detect_peaks = true;
        join = true;
    case 1
        ignore_ini_fin = false;
        fixed_width = 0;
        minimum_width = 0;
        detect_peaks = true;
        join = true;
        threshold = 0;
end

% 0. Correct signal data
if(size(data,1)==1)
    data = data';
end
original_data = data;
data = double(data);

% 1. Get peak or valley indices 
[idx,count] = Get_Peak_Indices(data,threshold,detect_peaks);

% Size of data
F = numel(data);
indices=zeros(F,1);
if ~count
    if detect_peaks
        disp('No peaks found!')
    else
        disp('No valleys found!')
    end
    widths = [];
    amplitudes = [];
    ini_fin_times = [];
    return
end

% 2. Ignore initial and final peak
if ignore_ini_fin

    % Delete if start above threshold
    last=1;
    idx=idx';
    for i=idx
        if(last==i)
            if detect_peaks
                data(i)=threshold-1;
            else
                data(i)=threshold+1;
            end
            last=last+1;
        else
            break;
        end
    end

    % Delete if ends above threshold
    last = F;
    idx = fliplr(idx);
    for i = idx
        if last==i
            if detect_peaks
                data(i)=threshold-1;
            else
                data(i)=threshold+1;
            end
            last=last-1;
        else
            break;
        end
    end

    % Get peak or valley indices 
    [idx,count] = Get_Peak_Indices(data,threshold,detect_peaks);
    if ~count
        if detect_peaks
            disp('No peaks found!')
        else
            disp('No valleys found!')
        end
        widths = [];
        amplitudes = [];
        ini_fin_times = [];
        return
    end
end

% 3. Minimum width (after join peaks or valleys)
if minimum_width

    % Join peaks or valleys
    is = find(idx~=[0; idx(1:numel(idx)-1)+1]);    % index of same peak
    % number of total peaks or valleys
    count = numel(is);                                       
    if count
        for j = 1:count-1
            indices(idx(is(j)):idx(is(j+1)-1),1)=j;    % set #peak
        end
        indices(idx(is(count)):max(idx),1)=count;
    end

    % Get peaks or valleys width
    widths=[];
    for i=1:count
        widths(i)=length(find(indices==i));
    end

    % Evaluate peaks less than or equal to minimum width
    idx_eval=find(widths<=minimum_width);
    widths=widths(idx_eval);

    % number of peaks to eliminate
    count_less=length(widths);

    % Detect initial and final times
    if count_less>0
        for i=1:count_less
            peak=find(indices==idx_eval(i));
            ini_peak=peak(1);
            end_peak=peak(end);
            if(detect_peaks)
                data(ini_peak:end_peak)=threshold-1;
            else
                data(ini_peak:end_peak)=threshold+1;
            end
        end
    end

    % Get peak or valley indices 
    [idx,count] = Get_Peak_Indices(data,threshold,detect_peaks);
    if ~count
        if(detect_peaks)
            disp('No peaks found!')
        else
            disp('No valleys found!')
        end
        widths = [];
        amplitudes = [];
        ini_fin_times = [];
        return
    end
end

% 4. Set fixed width 
if fixed_width
    last_end = -1;
    end_before = false;
    for i = idx'
        if i==last_end+1
            if detect_peaks
                data(i) = threshold-1;
            else
                data(i) = threshold+1;
            end
            if end_before
                end_before = false;
            else
                last_end = i;
            end
        else
            if i>last_end
                if fixed_width<0
                    ini = i+fixed_width;
                    fin = i-1;
                    if ini<1
                        ini = 1;
                    end    
                    fixed_width_peak = ini:fin;
                    last_end = fin+1;
                else
                    fin = i+fixed_width-1;
                    if(fin>F)
                        fin = F;
                    end    
                    fixed_width_peak = i:fin;
                    last_end = fin;
                end

                if detect_peaks
                    data(fixed_width_peak) = threshold+1;
                    if fixed_width<0
                        fixed_width_peak = fixed_width_peak+length(fixed_width_peak);
                        data(fixed_width_peak) = threshold-1;
                    elseif sum(data(fixed_width_peak)<threshold)
                        end_before = true;
                    end
                else
                    data(fixed_width_peak) = threshold-1;
                    if fixed_width<0
                        data(fixed_width_peak-fixed_width) = threshold+1;
                    elseif sum(data(fixed_width_peak)>threshold)
                        end_before = true;
                    end
                end
            end
        end
    end

    % Get peak or valley indices 
    [idx,count] = Get_Peak_Indices(data,threshold,detect_peaks);
end

% 5. Put numbers to peaks
indices=zeros(F,1);
for i=1:count
    indices(idx(i))=i;
end

% 6. Join peaks or valleys
if join
    is = find(idx~=[0; idx(1:numel(idx)-1)+1]);    % index of same peak

    % number of total peaks
    count = numel(is);                                       
    if count
        for j = 1:count-1
            indices(idx(is(j)):idx(is(j+1)-1),1)=j;    % set #peak
        end
        indices(idx(is(count)):max(idx),1)=count;
    end
end

% Get peaks or valleys width
widths = zeros(count,1);
ini_fin_times = zeros(count,2);
for i = 1:count
    id = find(indices==i);
    ini_fin_times(i,1) = id(1);
    ini_fin_times(i,2) = id(end);
    widths(i) = length(id);
end

% Get peaks or valleys amplitud
amplitudes = zeros(count,1);
for i = 1:count
    if detect_peaks
        value = max(original_data(indices==i));
    else
        value = min(original_data(indices==i));
    end
    amplitudes(i) = value;
end