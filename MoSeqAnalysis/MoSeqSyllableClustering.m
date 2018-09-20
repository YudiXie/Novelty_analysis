load('MoSeqDataFrame_syllabledissorted.mat');
for syllableiter=1:30
    nodename{syllableiter}=num2str(syllableiter-1);
end

CThreshold=0.7;
NodeNum=30;
LWidth=2;
FSize=20;

syllable_dis_vct=squareform(MoSeqDataFrame.syllable_dis);
syllable_linkage=linkage(syllable_dis_vct,'average');
leafOrder = optimalleaforder(syllable_linkage,syllable_dis_vct,'Criteria','group');

Plot_SyllableDis=figure;
[SyllableDenG,T,outperm]=dendrogram(syllable_linkage,NodeNum,'reorder',leafOrder,'ColorThreshold',CThreshold*max(syllable_linkage(:,3)),'Labels',nodename);
title('Syllable Distance Clustering','FontSize',FSize);
xlabel('Syllabel Number Rank (Sorted by usage','FontSize',FSize);
ylabel('Syllable Distance','FontSize',FSize)
set(SyllableDenG,'LineWidth',LWidth);