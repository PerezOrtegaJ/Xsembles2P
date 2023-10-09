function Set_Label_Time(samples,sample_frequency,sample_shift,axis,window)
% Set convenient label of time
%
%   Set_Label_Time(samples,sample_frequency,sample_shift,axis,window)
%
%       default: sample_shift = 0; axis = gca; window = samples
%
% Jesus Perez-Ortega April-19
% Modified May 2019
% Modified Oct 2019
% Modified Nov 2019
% Modified Jul 2020
% Modified Aug 2020
% Modified Feb 2021
% Modified Feb 2023
% Modified Apr 2023

switch nargin
    case 2
        sample_shift = 0;
        axis = gca;
        window = samples;
    case 3
        axis = gca;
        window = samples;
    case 4
        window = samples;
end

% Plot depending on the duration
if(window/sample_frequency<=0.03)           % Less than 30 ms
    step = 0.005;
    x_label = 'time (ms)';
    factor = 0.001;
elseif(window/sample_frequency<=0.1)        % Less than 100 ms
    step = 0.01;
    x_label = 'time (ms)';
    factor = 0.001;
elseif(window/sample_frequency<=0.2)        % Less than 200 ms
    step = 0.025;
    x_label = 'time (ms)';
    factor = 0.001;
elseif(window/sample_frequency<=1)          % Less than 1 s
    step = 0.1;
    x_label = 'time (ms)';
    factor = 0.001;
elseif(window/sample_frequency<=3)          % Less than 3 s
    step = 0.5;
    x_label = 'time (s)';
    factor = 1;
elseif(window/sample_frequency<=5)     % Less than 5 s
    step = 0.5;
    x_label = 'time (s)';
    factor = 1;
elseif(window/sample_frequency<=15)     % Less than 15 s
    step = 1;
    x_label = 'time (s)';
    factor = 1;
elseif(window/sample_frequency<=30)      % Less than 30 s
    step = 5;
    x_label = 'time (s)';
    factor = 1;
elseif(window/sample_frequency/60<1)    % Less than 1 min
    step = 10;
    x_label = 'time (s)';
    factor = 1;
elseif(window/sample_frequency/60<2)    % Less than 2 min
    step = 20;
    x_label = 'time (s)';
    factor = 1;
elseif(window/sample_frequency/60<3)    % Less than 3 min
    step = 30;
    x_label = 'time (s)';
    factor = 1;
elseif(window/sample_frequency/60<30)   % Less than 30 min
    step = 60;
    x_label = 'time (min)';
    factor = 60;
elseif(window/sample_frequency/60<60)   % Less than 60 min
    step = 60*5;
    x_label = 'time (min)';
    factor = 60;
elseif(window/sample_frequency/60<180)  % Less than 180 min
    step = 60*30;
    x_label = 'time (min)';
    factor = 60;
else
    step = 60*60;
    x_label = 'time (h)';
    factor = 3600;
end

set(axis,'box','off','xtick',(1:step*sample_frequency:(samples+1))+sample_shift,...
    'xticklabel',(0:samples/sample_frequency/step)*step/factor,...
    'xlim',[1 samples+1])
xlabel(axis,x_label)
