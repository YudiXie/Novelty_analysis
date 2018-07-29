path=cd
PathRoot=[path '/'];
filelist_fortime=dir([PathRoot,'*.mat']);
flen_fortime = length(filelist_fortime);


for fi = 1:flen_fortime
filename = filelist_fortime(fi).name;
load(filename)
Time_distance(fi)=Dis_t_obj;
Time_angle(fi)=Ang_t_obj;

clearvars -except filelist_fortime Time_angle Time_distance
close all
end


Time=[Time_distance;Time_angle];

save('Time.txt','Time','-ascii','-double','-tabs');
