path=cd
PathRoot=[path '/'];
filelist=dir([PathRoot,'*.(mp4|avi)']);
flen = length(filelist);
arena=zeros(flen,4);
obj=zeros(flen,4);
obj_center=zeros(flen,2);

for fi =1:flen
    vn = filelist(fi).name;
    fn=[vn(1:end-4) 'DeepCut_resnet50_noveltyMay21shuffle1_700000.csv'];

    Labels = csvread(fn,3,0);
    video=VideoReader(vn);
    frame=readFrame(video);

    arena_choice=input('Use deflault arena? 1/0');
    if arena_choice == 1
        cur_arena = [133.4 31.2 483.4 391.6];
    elseif arena_choice == 0
        cur_arena=Labelrect(frame,'Please Select Arena');
        close all
    else
        error('invalid input');
    end
    arena(fi,:)=cur_arena;

    cur_obj=Labelrect(frame,'Please Select Object');
    close all
    obj(fi,:)=cur_obj;

    cur_obj_center=0.5.*[cur_obj(1)+cur_obj(3),cur_obj(2)+cur_obj(4)];
    obj_center(fi,:)=cur_obj_center;

end
%***********************************************************
% Save
%***********************************************************
% pause

mkdir Analyzed_Data
cd Analyzed_Data

clearvars -except arena obj obj_center
save('Arena_Obj_Pos.mat')

cd ..
clear

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




