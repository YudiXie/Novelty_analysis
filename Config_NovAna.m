networkname_format='DeepCut_resnet50_MoSeqNoveltySep12shuffle1_1030000';
videoname_format='C4_180907_rgb.mp4';

video_xlen=512;         % video length (x)
video_ywid=424;         % video width (y)

fpm = 1500;             % frames per minute
fps = fpm./60;          % frames per second
ppc = 340/(2*30);       % pixels per cm
radius_cm = 8.6;        % Time spent around the obj radius (cm)
radius = radius_cm.*ppc;% Time spent around the obj radius (pixels)
angle_radius = 15;      % Time orient towards the obj radius (degree)

% Calculation Parameters
Dis_ts_frame=1;          % Time spent around the obf start and end frame
Dis_te_frame=10.*60.*fps;

Ang_ts_frame=1;         % Time orient towards the obj start and end frame
Ang_te_frame=10.*60.*fps;


