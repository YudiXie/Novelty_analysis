load('MoSeqDataFrame.mat');
ObjPos=[-180 -131];
cmap=jet(100);
totalcount=length(MoSeqDataFrame.model_label);
Mice_Index_path='/Users/yuxie/Dropbox/YuXie/CvsS_180831/CvsS_180831_MoSeq/Mice_Index.m';
run(Mice_Index_path);
FSize=20;

Analysis_Mice=1:8;
Analysis_Days=3;

MoSeqDataFrame.SODis=sqrt((MoSeqDataFrame.centroid_x_mm-ObjPos(1)).^2+(MoSeqDataFrame.centroid_y_mm-ObjPos(1)).^2);

FilteredLabel=[];
FilteredSODis=[];
for miceiter=Analysis_Mice

    for dayiter=Analysis_Days

        for frameiter=1:length(MoSeqDataFrame.SODis)
            if strcmp(Mice(miceiter).ExpDay(dayiter).MSid, MoSeqDataFrame.uuid(frameiter,:))
                FilteredLabel=[FilteredLabel double(MoSeqDataFrame.model_label(frameiter))];
                FilteredSODis=[FilteredSODis MoSeqDataFrame.SODis(frameiter)];
            end
        end

    end

end

% save('filteredlabels.mat','FilteredLabel','FilteredSODis');
% load('filteredlabels.mat');


disedges=0:10:700;
bin_size=disedges(2)-disedges(1);
dis=0.5.*(disedges(2:end)+disedges(1:end-1));

% Syllable usage at different distance SylDisCount
% meaning SylDisCount(r , c) = count of syllable r-1 in all data at distance c
SylDisCount=zeros(100,length(dis));
for syliter=1:100
    SylDisCount(syliter,:)=histcounts(FilteredSODis(FilteredLabel==(syliter-1)),disedges);
end
SylDisPCount=SylDisCount/totalcount;

SylDisColCount=sum(SylDisCount,1);
SylDisPCountNormalized=zeros(100,length(dis));
for coliter=1:size(SylDisCount,2)
    SylDisPCountNormalized(:,coliter)=SylDisCount(:,coliter)/SylDisColCount(coliter);
end


Plot_SyllableDisToObj=figure;
areahandle=area(dis,SylDisPCount','LineStyle','none');
title('Syllable Usage at different distance to object (N1)','FontSize',FSize)
xlabel('Distance (mm)','FontSize',FSize)
ylabel('Usage (Percentage)','FontSize',FSize)
xlim([0 630])

Plot_SyllableDisToObjNormalized=figure;
areahandleNor=area(dis,SylDisPCountNormalized','LineStyle','none');
title('Syllable Usage at different distance to object Normalized (N1)','FontSize',FSize)
xlabel('Distance (mm)','FontSize',FSize)
ylabel('Usage (Percentage)','FontSize',FSize)
axis([0,630,0,1])