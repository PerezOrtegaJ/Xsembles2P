function video_registered = Fast_Registration(video,locomotion,locomotion_threshold,fps,method)
% Fast registration taking into account the times where the animal is
% moving
%
%       video_registered = Fast_Registration(video,locomotion,locomotion_threshold,fps,method)
%
%   default: locomotion_threshold = 1; fps = 10; method = 'rigid'
%
% by Jesus Perez-Ortega, August 2019
% modified Sep 2019
% modified Nov 2022

if nargin<5
    method = 'rigid';
    if nargin<4
        fps = 10;
        if nargin<3
            locomotion_threshold = 1; % cm/s
        end
    end    
end

% Get size of the movie
[y,x,frames] = size(video);

% smooth locomotion at 1 s bin
loco = smooth(locomotion,round(fps));

% Get the number of the images for reference
n_img_avg = round(0.05*frames);

% Get reference (average of 5% of images with no motion)
id_no_loco = find(loco<locomotion_threshold);
[~,id] = sort(loco(id_no_loco));
n_img_avg = min([n_img_avg length(id)]);
id_no_loco = id_no_loco(id(1:n_img_avg));
reference = mean(video(:,:,id_no_loco),3);
reference = uint8(round(reference));

% Get frames with motion
id_loco = find(loco>locomotion_threshold);
if isempty(id_loco)
    warning('There were no frames to correct motion!')
    video_registered = video;
    return
end
n = length(id_loco);

% Plot summary of motion correction
Set_Figure('Frames to be corrected',[0 0 1000 200])
plot(locomotion); hold on
plot(id_loco,locomotion(id_loco),'.k')
ylabel('locomotion [cm/s]')
title([num2str(n) ' frames will be corrected'])
Set_Label_Time(frames,fps)
drawnow

% Initialize variables
registered = zeros(y,x,n);
video_loco = video(:,:,id_loco);

% Get optimizer for registration
switch method
    case 'rigid'
        [optimizer, metric] = imregconfig('monomodal');
        options.optimizer = optimizer;
        options.metric = metric;
    case 'nonrigid'
        options.iterations = [100 50 25];
        options.pyramid_levels = 3;
        options.AccumulatedFieldSmoothing = 2;
end

disp([num2str(n) ' frames will be corrected (method: ' method ')'])
ten_perc = round(n/10);
tic
for i = 1:n 
    % Image to register
    moving = video_loco(:,:,i);
    
    % Adjust histogram to match
    moving_match = imhistmatch(moving,reference);
    
    % Identify motion
    switch method
        case 'rigid'
            motion = imregtform(moving_match,reference,'translation',...
            options.optimizer,options.metric,...'DisplayOptimization',true,...
            'pyramidlevels',3);

            % Apply motion
            registered(:,:,i) = imwarp(moving,motion,'OutputView',imref2d([y x]));
        case 'nonrigid'
    
            motion = imregdemons(moving_match,reference,options.iterations,...
                'AccumulatedFieldSmoothing',options.AccumulatedFieldSmoothing,...
                'PyramidLevels',options.pyramid_levels,...
                'DisplayWaitBar',false);
            
            % Apply motion
            registered(:,:,i) = imwarp(moving,motion,'nearest');       
    end
    
    % Estimate time
    if i==1
        t = toc; 
        fprintf('   Estimated time %.1f s\n',t*n)
    end
    
    % Show the state of computation each 10% frames
    if ~mod(i,ten_perc)
        t = toc; 
        fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
    end
end

video_registered = video;
video_registered(:,:,id_loco) = registered;

t = toc; disp(['   Done (' num2str(t) ' seconds)'])