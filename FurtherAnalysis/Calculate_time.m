startframe=3000;
endframe=21000;

path=cd
PathRoot=[path '/'];
filelist_fortime=dir([PathRoot,'*.mat']);
flen_fortime = length(filelist_fortime);


for fi = 2:flen_fortime
filename = filelist_fortime(fi).name;
load(filename)
Time_distance(fi-1)=sum(Labels(startframe:endframe,21));
Time_angle(fi-1)=sum(Labels(startframe:endframe,23));

clearvars -except filelist_fortime Time_angle Time_distance startframe endframe
close all
end


Time=[Time_distance;Time_angle];
Time=Time./(endframe-startframe);

save('Time.txt','Time','-ascii','-double','-tabs');
