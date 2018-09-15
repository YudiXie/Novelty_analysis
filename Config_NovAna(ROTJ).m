networkname_format='DeepCut_resnet50_noveltyMay21shuffle1_700000';
videoname_format='session01_2018-05-06-110119-0000.mp4';

video_xlen=520;
video_ywid=420;

fpm = 1800;               % frames per minute
fps = fpm./60;            % frames per second
ppc = 355/(2*30.48);      % pixels per cm
radius = 50;              % Time spent around the obj radius (pixels)
radius_cm = radius./ppc;  % Time spent around the obj radius (cm)

angle_radius = 15;      % Time orient towards the obj radius (degree)

% Calculation Parameters
Dis_ts_frame=1;          % Time spent around the obf start and end frame
Dis_te_frame=18000;

Ang_ts_frame=1;         % Time orient towards the obj start and end frame
Ang_te_frame=18000;


