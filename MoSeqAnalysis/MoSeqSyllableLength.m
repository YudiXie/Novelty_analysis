load('GeneralUsage.mat')
fps=30;

G1Length=sum(G1Usage,1)./(sum(G1Usage_count,1).*fps);
G2Length=sum(G2Usage,1)./(sum(G2Usage_count,1).*fps);

A_G1Length=mean(G1Length,3);
A_G2Length=mean(G2Length,3);

StdG1Length=std(G1Length,0,3);
StdG2Length=std(G2Length,0,3);

SemG1Length=StdG1Length./sqrt(size(G1Length,3));
SemG2Length=StdG2Length./sqrt(size(G2Length,3));

G2plusG1Length=A_G1Length+A_G2Length;
[G2vsG1Sortedlength,G2vsG1Sortedlengthindex]=sort(G2plusG1Length,'ascend');

% two sample t-test
G1Length_tt=zeros(length(G1_Mice),101);
for sheetiter=1:length(G1_Mice)
    G1Length_tt(sheetiter,:)=G1Length(1,:,sheetiter);
end

G2Length_tt=zeros(length(G2_Mice),101);
for sheetiter=1:length(G2_Mice)
    G2Length_tt(sheetiter,:)=G2Length(1,:,sheetiter);
end

h=ttest2(G1Length_tt,G2Length_tt,'Vartype','unequal');

mksize=4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot mean with error bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_UsageCompare_sorted=figure;
errorbar(X,A_G1Length(G2vsG1Sortedlengthindex),SemG1Length(G2vsG1Sortedlengthindex),'LineWidth',1.5)
hold on
errorbar(X,A_G2Length(G2vsG1Sortedlengthindex),SemG2Length(G2vsG1Sortedlengthindex),'LineWidth',1.5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot significance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
offset=0.5;
smksize=20;
MaxUsage=max(A_G1Length(G2vsG1Sortedlengthindex),A_G2Length(G2vsG1Sortedlengthindex));
for syliter=1:101
    if h(G2vsG1Sortedlengthindex(syliter))==1
        hold on
        scatter(X(syliter),MaxUsage(syliter)+offset,smksize,'*','MarkerFaceColor','r','MarkerEdgeColor','r')
    end
end

legend({G1_name,G2_name},'FontSize',fsize)
title(['Syllable Length Comparison of ' G1_name ' vs. ' G2_name ' (' Batch_name ')'],'FontSize',fsize)
ylabel('Time in second','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX(G2vsG1Sortedlengthindex));