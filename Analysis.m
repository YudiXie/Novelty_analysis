% All the information are saved in Labels
% Labels(:,2) Nose x
% Labels(:,3) Nose y
% Labels(:,5) Leftear x
% Labels(:,6) Leftear y
% Labels(:,8) Rightear x
% Labels(:,9) Rightear y
% Labels(:,11) Tailbase x
% Labels(:,12) Tailbase y
% Labels(:,14) Head x  'average of nose, leftear and rightear'
% Labels(:,15) Head y
% Labels(:,17) Head distance from object
% Labels(:,15) 




path=cd
PathRoot=[path '/'];
filelist=dir([PathRoot,'*.csv']);
flen = length(filelist);

for fi =1:flen
fn = filelist(fi).name;
vn = [filelist(fi).name(1:32) '.mp4'];


Labels = csvread(fn,3,0);
video=VideoReader(vn);
frame=readFrame(video);

arena = [133.4 31.2 483.4 391.6];
% arena=Labelrect(frame,'Please Select Arena')
obj=Labelrect(frame,'Please Select Object');
obj_center=0.5.*[obj(1)+obj(3),obj(2)+obj(4)];


%
% % Show object center
% imshow(frame)
% hold on 
% plot(obj_center(1),obj_center(2),'*')
%

%***********************************************************
% Calculation
%***********************************************************

% Calculate head position
Labels(:,14)=(Labels(:,2)+Labels(:,5)+Labels(:,8))./3;
Labels(:,15)=(Labels(:,3)+Labels(:,6)+Labels(:,9))./3;
Labels(:,16)=(Labels(:,4)+Labels(:,7)+Labels(:,10))./3;

% head distance from object center
Labels(:,17)=sqrt((obj_center(1)-Labels(:,14)).^2+(obj_center(2)-Labels(:,15)).^2);

% upper left corner distance from object center
Labels(:,18)=sqrt((obj_center(1)-arena(1)).^2+(obj_center(2)-arena(2)).^2);
% buttom left or upper right conerner distance from object center
Labels(:,19)=0.5.*(sqrt((obj_center(1)-arena(1)).^2+(obj_center(2)-arena(4)).^2)...
                 + sqrt((obj_center(1)-arena(3)).^2+(obj_center(2)-arena(2)).^2));                   
% buttom right corner distance from object center
Labels(:,20)=sqrt((obj_center(1)-arena(3)).^2+(obj_center(2)-arena(4)).^2);


% Time spent near the obj
len = length(Labels(:,1));
radius = 50;

for i=1:len
    if Labels(i,17)<=radius
        Labels(i,21)=1;
    else
        Labels(i,21)=0;
    end
end

Dis_ts_frame=1;
Dis_te_frame=18000;

Dis_t_obj = sum(Labels(Dis_ts_frame:Dis_te_frame,21))./(Dis_te_frame-Dis_ts_frame)


% Calculate Orientation

v_h2t = [(Labels(:,2)-Labels(:,11)),(Labels(:,3)-Labels(:,12))];
v_o2t = [(obj_center(1)-Labels(:,11)),(obj_center(2)-Labels(:,12))];

for i=1:len
    Labels(i,22)= atan2d(det([v_h2t(i,:);v_o2t(i,:)]),dot(v_h2t(i,:),v_o2t(i,:)));
end


angle_radius = 15 ;

for i=1:len
    if Labels(i,22)<=angle_radius && Labels(i,22)>=(-angle_radius)
        Labels(i,23)=1;
    else
        Labels(i,23)=0;
    end
end

Ang_ts_frame=1;
Ang_te_frame=18000;

Ang_t_obj = sum(Labels(Ang_ts_frame:Ang_te_frame,23))./(Ang_te_frame-Ang_ts_frame)



%***********************************************************
% Plot
%***********************************************************

plot_fs=1;
plot_fe=5400;

% plot distances
Disfigure=figure(1);
plot(Labels(plot_fs:plot_fe,1)./1800,Labels(plot_fs:plot_fe,17),'linewidth',2);
hold on
plot(Labels(plot_fs:plot_fe,1)./1800,Labels(plot_fs:plot_fe,18),'linewidth',2);
hold on
plot(Labels(plot_fs:plot_fe,1)./1800,Labels(plot_fs:plot_fe,19),'linewidth',2);
hold on
plot(Labels(plot_fs:plot_fe,1)./1800,Labels(plot_fs:plot_fe,20),'linewidth',2);
title(['Distance (first 3min) radius=' num2str(radius)]);
xlabel('time min')
ylabel('Distance pixels')
set(Disfigure, 'position', [0 0 2000 1000]);
           
% plot orientation
Angfigure=figure(2);
plot(Labels(plot_fs:plot_fe,1)./1800,Labels(plot_fs:plot_fe,22),'linewidth',2);
title(['Orientation (first 3min) radius=' num2str(angle_radius)]);
xlabel('time min')
ylabel('degree');
set(Angfigure, 'position', [0 0 2000 1000]);

% Heatmap
x_length=520;
y_length=420;
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

Hmfigure=figure(3);
hm=heatmap(pooled_map,'GridVisible','off','Colormap',parula,'FontSize',0.01);
% rectangle('Position',[arena(1)-round(pool_size/2),arena(2)-round(pool_size/2),arena(3)-arena(1),arena(4)-arena(2)])


%pooling method 2


% Plot trajectory
Trafigure=figure(4);
scatter(Labels(:,14),Labels(:,15));
rectangle('Position',[arena(1),arena(2),arena(3)-arena(1),arena(4)-arena(2)],'EdgeColor','r','linewidth',4)
rectangle('Position',[obj(1),obj(2),obj(3)-obj(1),obj(4)-obj(2)],'EdgeColor','r','linewidth',4)
set(gca,'ydir','reverse')
set(Trafigure, 'position', [0 0 1400 1200]);

%***********************************************************
% Save
%***********************************************************
% pause
mkdir Figures
cd Figures
clearvars video
save([vn(1:end-4)])

mkdir([vn(1:end-4) '_Plots'])
cd([vn(1:end-4) '_Plots'])

saveas(Disfigure,['Distance_' vn(1:end-4) '.png'])
saveas(Angfigure,['Orientation_' vn(1:end-4) '.png'])
saveas(Hmfigure,['Heatmap_' vn(1:end-4) '.png'])
saveas(Trafigure,['Trajectory_' vn(1:end-4) '.png'])

close all
clearvars -except arena filelist

cd ..
cd ..

end

%***********************************************************
% Functions
%***********************************************************

%Select a rectangular ROI
%ROI = [x_upperleft,y_upperleft,x_lowerright,y_lowerright]
function ROI=Labelrect(frame_name,frame_title)
imshow(frame_name,'InitialMagnification',300);
title(frame_title,'FontSize',15);
mouse=imrect;
pos=getPosition(mouse);% x1 y1 w h
ROI=[pos(1) pos(2) pos(1)+pos(3) pos(2)+pos(4)]; 
end

% function BoxTable=getAllbox(folder)
% fileFolder=fullfile(folder);
% dirOutput=dir(fullfile(fileFolder,'*.jpg'));
% filenames={dirOutput.name}'; %列向量
% rois=[];
% for i=1:length(filenames)
%     roi=LabelBox(filenames{i});
%     rois=[rois;roi];
% end
% BoxTable=table(filenames,rois);
% end

