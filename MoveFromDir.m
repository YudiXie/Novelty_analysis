
folderpath = cd;
folderd = dir(folderpath);
isub = [folderd(:).isdir];
foldernames = {folderd(isub).name}';
foldernames(ismember(foldernames,{'.','..'})) = [];
folderlen=length(foldernames);

for i=1:folderlen
    cd(foldernames{i});

    subfolderpath = cd;
    subd = dir(subfolderpath);
    subisub = [subd(:).isdir];
    subfoldernames = {subd(subisub).name}';
    subfoldernames(ismember(subfoldernames,{'.','..'})) = [];
    subfolderlen=length(subfoldernames);

    for j=1:subfolderlen
        cd(subfoldernames{j});

        PathRoot=cd;
        filelist=dir([PathRoot '/']);
        flen = length(filelist);
        for k=3:flen
            movefile(filelist(k).name,[folderpath '/' foldernames{i} '/'])
        end
        cd ..
        rmdir(subfoldernames{j})
    end

    cd ..

end