%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pending: 
% straight line metric
% pooling method 2 (current pooling method is not ideal)
% the calculation method for derivative needs more thinking because 
% Labels(:,27) Delta Velosity angle (degree/s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All the information are saved as folowing
% Labels(:,2) Nose x (pixel)
% Labels(:,3) Nose y (pixel)
% Labels(:,5) Leftear x (pixel)
% Labels(:,6) Leftear y (pixel)
% Labels(:,8) Rightear x (pixel)
% Labels(:,9) Rightear y (pixel)
% Labels(:,11) Tailbase x (pixel)
% Labels(:,12) Tailbase y (pixel)
% Labels(:,14) Head x (pixel) 'average of nose, leftear and rightear'
% Labels(:,15) Head y (pixel)
% Labels(:,17) Head distance from object (cm)
% Labels(:,18) upper left corner distance from object center  (cm)
% Labels(:,19) average buttom left or upper right conerner distance from object center  (cm)
% Labels(:,20) buttom right corner distance from object center  (cm)
% Labels(:,21) if distance to object <= radius 1; else 0
% Labels(:,22) orientation related to object [-180,180]
% Labels(:,23) if orientation related to object <= +angle_radius and >= -angle_radius 1; else 0
% Labels(:,24) x velocity (cm/s)
% Labels(:,25) y velocity (cm/s)
% Labels(:,26) velosity angle (degree)

% Dis_t_obj Time spent in the radius according to the distance
% Ang_t_obj Time spent orienting towards the object according to the orientation


%***********************************************************
% Initialization
%***********************************************************

cd Analyzed_Data;
load('Arena_Obj_Pos.mat');
cd ..
path = cd;
PathRoot=[path '/'];
filelist=dir([PathRoot,'*.csv']);
flen = length(filelist);
tic;
for fiter =1:flen
    fn = filelist(fiter).name;
    vn = [filelist(fiter).name(1:32) '.mp4'];
    disp(['Analyzing: ' fn]);

    Labels = csvread(fn,3,0);
    len = length(Labels(:,1));
    Labels = [Labels zeros(len,14)];

    %***********************************************************
    % Parameters
    %***********************************************************

    fpm = 1800;          % frames per minute
    fps = fpm./60;       % frames per second
    ppc = 355/(2*30.48); % pixels per cm

    % Calculation Parameters
    radius = 50;            % Time spent around the obj radius (pixels)
    radius_cm = radius/ppc;  % Time spent around the obj radius (cm)
    Dis_ts_frame=1;         % Time spent around the obf start and end frame
    Dis_te_frame=18000;

    angle_radius = 15;      % Time orient towards the obj radius (degree)
    Ang_ts_frame=1;         % Time orient towards the obj start and end frame
    Ang_te_frame=18000;

    vspace=3;      % average frame space to calculate the velocity Must be a odd intiger
    % Plot parameters
    plot_fs=1;      % Distance/Orientation plot start and end frame
    plot_fe=5400;

    x_length=520;   % Heatmap x and y axis length (pixels)
    y_length=420;

    %***********************************************************
    % Calculation
    %***********************************************************

    % Calculate head position
    Labels(:,14)=(Labels(:,2)+Labels(:,5)+Labels(:,8))./3;
    Labels(:,15)=(Labels(:,3)+Labels(:,6)+Labels(:,9))./3;
    Labels(:,16)=(Labels(:,4)+Labels(:,7)+Labels(:,10))./3;

    % head distance from object center
    Labels(:,17)=sqrt((obj_center(fiter,1)-Labels(:,14)).^2+(obj_center(fiter,2)-Labels(:,15)).^2)/ppc;

    % upper left corner distance from object center
    Labels(:,18)=sqrt((obj_center(fiter,1)-arena(fiter,1)).^2+(obj_center(fiter,2)-arena(fiter,2)).^2)/ppc;
    % buttom left or upper right conerner distance from object center
    Labels(:,19)=0.5.*(sqrt((obj_center(fiter,1)-arena(fiter,1)).^2+(obj_center(fiter,2)-arena(fiter,4)).^2)...
                    + sqrt((obj_center(fiter,1)-arena(fiter,3)).^2+(obj_center(fiter,2)-arena(fiter,2)).^2))/ppc;                   
    % buttom right corner distance from object center
    Labels(:,20)=sqrt((obj_center(fiter,1)-arena(fiter,3)).^2+(obj_center(fiter,2)-arena(fiter,4)).^2)/ppc;


    % Time spent near the obj
    for i=1:len
        if Labels(i,17)<=radius_cm
            Labels(i,21)=1;
        else
            Labels(i,21)=0;
        end
    end

    Dis_t_obj = sum(Labels(Dis_ts_frame:Dis_te_frame,21))./(Dis_te_frame-Dis_ts_frame);

    % Calculate Orientation  v as vector h2t head to tail o2t obj to tail
    v_h2t = [(Labels(:,2)-Labels(:,11)),(Labels(:,3)-Labels(:,12))];
    v_o2t = [(obj_center(fiter,1)-Labels(:,11)),(obj_center(fiter,2)-Labels(:,12))];

    for i=1:len
        Labels(i,22)= atan2d(det([v_h2t(i,:);v_o2t(i,:)]),dot(v_h2t(i,:),v_o2t(i,:)));
    end

    for i=1:len
        if Labels(i,22)<=angle_radius && Labels(i,22)>=(-angle_radius)
            Labels(i,23)=1;
        else
            Labels(i,23)=0;
        end
    end

    Ang_t_obj = sum(Labels(Ang_ts_frame:Ang_te_frame,23))./(Ang_te_frame-Ang_ts_frame);


    % Calculate head velocity
    floorfra = floor(vspace/2);
    for i = floorfra+1:len-vspace-floorfra
        Labels(i,24) = ((sum(Labels(i-floorfra:i+floorfra,14))-sum(Labels(i-floorfra+vspace:i+floorfra+vspace,14)))./ppc)./(vspace./fps);
        Labels(i,25) = ((sum(Labels(i-floorfra:i+floorfra,15))-sum(Labels(i-floorfra+vspace:i+floorfra+vspace,15)))./ppc)./(vspace./fps);
    end
    Labels(:,26)=atan2d(Labels(:,25),Labels(:,24));

    %***********************************************************
    % Plot
    %***********************************************************

    % plot distances
    Disfigure=figure('visible",‘off');
    plot(Labels(plot_fs:plot_fe,1)./fpm,Labels(plot_fs:plot_fe,17),'linewidth',2);
    hold on
    plot(Labels(plot_fs:plot_fe,1)./fpm,Labels(plot_fs:plot_fe,18),'linewidth',2);
    hold on
    plot(Labels(plot_fs:plot_fe,1)./fpm,Labels(plot_fs:plot_fe,19),'linewidth',2);
    hold on
    plot(Labels(plot_fs:plot_fe,1)./fpm,Labels(plot_fs:plot_fe,20),'linewidth',2);
    title(['Distance (first ' num2str((plot_fe-plot_fs)/fpm) 'min) radius=' num2str(radius_cm) ' cm']);
    xlabel('time (min)')
    ylabel('Distance (cm)')
    set(Disfigure, 'position', [0 0 2000 1000]);
            
    % plot orientation
    Angfigure=figure('visible",‘off');
    plot(Labels(plot_fs:plot_fe,1)./fpm,Labels(plot_fs:plot_fe,22),'linewidth',2);
    title(['Orientation (first ' num2str((plot_fe-plot_fs)/fpm) 'min) radius=' num2str(angle_radius)]);
    xlabel('time min')
    ylabel('degree');
    set(Angfigure, 'position', [0 0 2000 1000]);

    % Heatmap
    fov=zeros(x_length,y_length);
    for i=1:len
        if round(Labels(i,14))<x_length && round(Labels(i,15))<y_length...
            && round(Labels(i,14))>0 && round(Labels(i,15))>0
            fov(round(Labels(i,14)),round(Labels(i,15)))=fov(round(Labels(i,14)),round(Labels(i,15)))+10;
        end
    end


    %pooling method 1
    pool_size=50;
    pooled_map=zeros(x_length-pool_size+1,y_length-pool_size+1);

    for i=1:x_length-pool_size+1
        for j=1:y_length-pool_size+1
            pooled_map(i,j)=sum(sum(fov(i:i+pool_size-1,j:j+pool_size-1)));
        end
    end

    Hmfigure=figure('visible",‘off');
    hm=heatmap(pooled_map,'GridVisible','off','Colormap',parula,'FontSize',0.01);
    % rectangle('Position',[arena(fiter,1)-round(pool_size/2),arena(fiter,2)-round(pool_size/2),arena(fiter,3)-arena(fiter,1),arena(fiter,4)-arena(fiter,2)])


    % Plot trajectory
    Trafigure=figure('visible",‘off');
    scatter(Labels(:,14),Labels(:,15));
    rectangle('Position',[arena(fiter,1),arena(fiter,2),arena(fiter,3)-arena(fiter,1),arena(fiter,4)-arena(fiter,2)],'EdgeColor','r','linewidth',4)
    rectangle('Position',[obj(fiter,1),obj(fiter,2),obj(fiter,3)-obj(fiter,1),obj(fiter,4)-obj(fiter,2)],'EdgeColor','r','linewidth',4)
    set(gca,'ydir','reverse')
    set(Trafigure, 'position', [0 0 1400 1200]);

    % ***********************************************************
    % Save
    % ***********************************************************
    % pause
    cd Analyzed_Data

    mkdir([vn(1:end-4) '_Plots'])
    cd([vn(1:end-4) '_Plots'])

    saveas(Disfigure,['Distance_' vn(1:end-4) '.png'])
    saveas(Angfigure,['Orientation_' vn(1:end-4) '.png'])
    saveas(Hmfigure,['Heatmap_' vn(1:end-4) '.png'])
    saveas(Trafigure,['Trajectory_' vn(1:end-4) '.png'])

    cd ..

    save([vn(1:end-4)],'Labels','Dis_t_obj','Ang_t_obj');
    close all
    clearvars -except arena obj obj_center filelist fiter

    cd ..
    toc;
end

close all
clear