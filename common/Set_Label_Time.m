function Set_Label_Time(samples,sampleFrequency,sampleShift,axis,window)
% Set convenient label of time
%
%   Set_Label_Time(samples,sampleFrequency,sampleShift,axis,window)
%
%       default: sampleShift = 0; axis = gca; window = samples
%
% Jesus Perez-Ortega April-19
% Modified May 2019
% Modified Oct 2019
% Modified Nov 2019
% Modified Jul 2020
% Modified Aug 2020
% Modified Feb 2021
% Modified Feb 2023

switch nargin
    case 2
        sampleShift = 0;
        axis = gca;
        window = samples;
    case 3
        axis = gca;
        window = samples;
    case 4
        window = samples;
end

% Plot depending on the duration
if(window/sampleFrequency<=0.03)           % Less than 30 ms
    step = 0.005;
    xlabel('time (ms)');
    factor = 0.001;
elseif(window/sampleFrequency<=0.1)        % Less than 100 ms
    step = 0.01;
    xlabel('time (ms)');
    factor = 0.001;
elseif(window/sampleFrequency<=0.2)        % Less than 200 ms
    step = 0.025;
    xlabel('time (ms)');
    factor = 0.001;
elseif(window/sampleFrequency<=1)          % Less than 1 s
    step = 0.1;
    xlabel('time (ms)');
    factor = 0.001;
elseif(window/sampleFrequency<=3)          % Less than 3 s
    step = 0.5;
    xlabel('time (s)');
    factor = 1;
elseif(window/sampleFrequency<=5)     % Less than 5 s
    step = 0.5;
    xlabel('time (s)');
    factor = 1;
elseif(window/sampleFrequency<=15)     % Less than 15 s
    step = 1;
    xlabel('time (s)');
    factor = 1;
elseif(window/sampleFrequency<=30)      % Less than 30 s
    step = 5;
    xlabel('time (s)');
    factor = 1;
elseif(window/sampleFrequency/60<2)    % Less than 2 min
    step = 20;
    xlabel('time (s)');
    factor = 1;
elseif(window/sampleFrequency/60<3)    % Less than 3 min
    step = 30;
    xlabel('time (s)');
    factor = 1;
elseif(window/sampleFrequency/60<30)   % Less than 30 min
    step = 60;
    xlabel('time (min)');
    factor = 60;
elseif(window/sampleFrequency/60<60)   % Less than 60 min
    step = 60*5;
    xlabel('time (min)');
    factor = 60;
elseif(window/sampleFrequency/60<180)  % Less than 180 min
    step = 60*30;
    xlabel('time (min)');
    factor = 60;
else
    step = 60*60;
    xlabel('time (h)');
    factor = 3600;
end

set(axis,'box','off','xtick',(1:step*sampleFrequency:(samples+1))+sampleShift,...
    'xticklabel',(0:samples/sampleFrequency/step)*step/factor)
xlim([1 samples+1])

