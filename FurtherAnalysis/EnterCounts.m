% Not finished!!!!


% in subfolder when looking for .mat files, prsumed there is an Arena_Obj_Pos.mat file
% omit the first .mat file which is Arena_Obj_Pos.mat. If there are other .mat files in subfolder will cause error

start_min=1;
end_min=11;
fps=30;
startframe=start_min.*60.*fps;
endframe=end_min.*60.*fps;

folderpath = cd;
folderd = dir(folderpath);
isub = [folderd(:).isdir];
foldernames = {folderd(isub).name}';
foldernames(ismember(foldernames,{'.','..'})) = [];
folderlen=length(foldernames);

for folderi=1:folderlen
    cd(foldernames{folderi});
    cd Analyzed_Data

    subpath=cd;
    PathRoot=[subpath '/'];
    filelist=dir([PathRoot,'*.mat']);
    flen = length(filelist);

    for filei = 2:flen
        filename = filelist(filei).name;
        load(filename)
        Time_distance(filei-1)=sum(Labels(startframe:endframe,21));
        Time_angle(filei-1)=sum(Labels(startframe:endframe,23));
    end

    Time_distance_all(folderi,:)=Time_distance;
    Time_angle_all(folderi,:)=Time_angle;
    clearvars Time_angle Time_distance
    cd ..
    cd ..
    DisOrAng{folderi,1}='Distatnce';
    DisOrAng{folderlen+folderi,1}='Angle';


end

Time_distance_all=Time_distance_all./(endframe-startframe);
Time_angle_all=Time_angle_all./(endframe-startframe);
Table=table(cat(1,foldernames,foldernames),DisOrAng,[Time_distance_all;Time_angle_all]);
writetable(Table,'TimeStatistic.csv');
clear all