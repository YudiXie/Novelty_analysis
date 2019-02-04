% !!! Haven't tested yet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Please edit the following parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IntSyllable=[63 7 17 52 34];
Mice_Index_path='/Users/yuxie/Dropbox/YuXie/Kaeser_Lab/190125/Mice_Index.m';
Analysis_Mice=1:19;
Analysis_Days=1;

MarkerSize=5;
Fsize=20;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('MoSeqDataFrame.mat');
cmap=jet(100);
totalcount=length(MoSeqDataFrame.model_label);
run(Mice_Index_path);

FilteredLabel=[];
FilteredXPos=[];
FilteredYPos=[];
for miceiter=Analysis_Mice

    for dayiter=Analysis_Days

        for frameiter=1:length(MoSeqDataFrame.SODis)
            if strcmp(Mice(miceiter).ExpDay(dayiter).MSid, MoSeqDataFrame.uuid(frameiter,:))
                FilteredLabel=[FilteredLabel double(MoSeqDataFrame.model_label(frameiter))];
                FilteredXPos=[FilteredXPos MoSeqDataFrame.centroid_x_mm(frameiter)];
                FilteredYPos=[FilteredYPos MoSeqDataFrame.centroid_y_mm(frameiter)];
            end
        end

    end

end

% save('FilteredPos.mat','FilteredLabel','FilteredXPos','FilteredYPos');
% load('FilteredPos.mat');

SyllableDis=figure;

for syliter=1:length(IntSyllable)
    XPos=FilteredXPos(FilteredLabel==IntSyllable(syliter));
    YPos=FilteredYPos(FilteredLabel==IntSyllable(syliter));
    scatter(XPos,YPos,MarkerSize,'filled')
    hold on
end

legend(strcat('Syllable  ',num2str(IntSyllable')))
title('Syllable Position Distribution','FontSize',Fsize)
xlabel('x position (mm)','FontSize',Fsize)
ylabel('y position (mm)','FontSize',Fsize)
set(gca,'ydir','reverse')
set(SyllableDis, 'position', [0 0 1000 850]);
