path=cd;
PathRoot=[path '/'];
filelist=dir([PathRoot,'*.csv']);
flen = length(filelist);

group_arena=zeros(flen,4);
group_obj=zeros(flen,4);
group_obj_center=zeros(flen,2);

cd Figures

for fiter =1:flen
load([filelist(fiter).name(1:32) '.mat'],'arena','obj','obj_center')
group_arena(fiter,:)=arena;
group_obj(fiter,:)=obj;
group_obj_center(fiter,:)=obj_center;
end

clearvars -except group_arena group_obj group_obj_center
arena=group_arena;
obj=group_obj;
obj_center=group_obj_center;
clearvars -except arena obj obj_center

cd ..
mkdir Analyzed_Data
cd Analyzed_Data
save('Arena_Obj_Pos.mat')
cd ..
clear
