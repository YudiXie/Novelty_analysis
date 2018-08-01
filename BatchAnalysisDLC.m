%This script doesn't work because the foldernames is deleted by MarkObjPos

folderpath = cd;
d = dir(folderpath);
isub = [d(:).isdir];
foldernames = {d(isub).name}';
foldernames(ismember(foldernames,{'.','..'})) = [];
folderlen=length(foldernames);

for i=1:folderlen
    cd(foldernames{i});
    MarkObjPos;
    cd ..
end


for i=1:folderlen
    cd(foldernames{i});
    Analysis;
    VideoLabeling;
    cd ..
end