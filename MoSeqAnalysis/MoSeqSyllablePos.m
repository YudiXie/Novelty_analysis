load('MoSeqDataFrame.mat')
Syllablebinedge=[-6,-0.5:1:99.5];

Mice_Index_path='/Users/yuxie/Dropbox/YuXie/CvsS_180831/CvsS_180831_MoSeq/Mice_Index.m';
run(Mice_Index_path);

MarkerSize=5;
Fsize=20;

IntSyllable=[42 94 39 38 70 13];

SyllableDis=figure;

for syliter=1:length(IntSyllable)
    XPos=MoSeqDataFrame.centroid_x_mm(MoSeqDataFrame.model_label==IntSyllable(syliter));
    YPos=MoSeqDataFrame.centroid_y_mm(MoSeqDataFrame.model_label==IntSyllable(syliter));
    scatter(XPos,YPos,MarkerSize,'filled')
    hold on
end

legend(strcat('Syllable  ',num2str(IntSyllable')))
title('Syllable Position Distribution','FontSize',Fsize)
xlabel('x position (mm)','FontSize',Fsize)
ylabel('y position (mm)','FontSize',Fsize)
set(gca,'ydir','reverse')
set(SyllableDis, 'position', [0 0 1000 850]);
