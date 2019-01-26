load('GeneralUsage.mat')

N_G1Usage=sum(G1Usage,1)./sum(sum(G1Usage,1),2);
N_G2Usage=sum(G2Usage,1)./sum(sum(G2Usage,1),2);

AN_G1Usage=mean(N_G1Usage,3);
AN_G2Usage=mean(N_G2Usage,3);

StdN_G1Usage=std(N_G1Usage,0,3);
StdN_G2Usage=std(N_G2Usage,0,3);

SemN_G1Usage=StdN_G1Usage./sqrt(size(N_G1Usage,3));
SemN_G2Usage=StdN_G2Usage./sqrt(size(N_G2Usage,3));

G2vsG1usage=(AN_G2Usage-AN_G1Usage)./(AN_G2Usage+AN_G1Usage);
[G2vsG1Sortedusage,G2vsG1Sortedusageindex]=sort(G2vsG1usage,'descend');

% two sample t-test
N_G1Usage_tt=zeros(length(G1_Mice),101);
for sheetiter=1:length(G1_Mice)
    N_G1Usage_tt(sheetiter,:)=N_G1Usage(1,:,sheetiter);
end

N_G2Usage_tt=zeros(length(G2_Mice),101);
for sheetiter=1:length(G2_Mice)
    N_G2Usage_tt(sheetiter,:)=N_G2Usage(1,:,sheetiter);
end

h=ttest2(N_G1Usage_tt,N_G2Usage_tt,'Vartype','unequal');


mksize=4;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Plot mean without error bar
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_UsageCompare_sorted=figure;
% plot(X,AN_G1Usage(G2vsG1Sortedusageindex),'LineWidth',1.5)
% hold on
% plot(X,AN_G2Usage(G2vsG1Sortedusageindex),'LineWidth',1.5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot mean with error bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_UsageCompare_sorted=figure;
errorbar(X,AN_G1Usage(G2vsG1Sortedusageindex),SemN_G1Usage(G2vsG1Sortedusageindex),'LineWidth',1.5)
hold on
errorbar(X,AN_G2Usage(G2vsG1Sortedusageindex),SemN_G2Usage(G2vsG1Sortedusageindex),'LineWidth',1.5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot significance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
offset=0.01;
smksize=20;
MaxUsage=max(AN_G1Usage(G2vsG1Sortedusageindex),AN_G2Usage(G2vsG1Sortedusageindex));
for syliter=1:101
    if h(G2vsG1Sortedusageindex(syliter))==1
        hold on
        scatter(X(syliter),MaxUsage(syliter)+offset,smksize,'*','MarkerFaceColor','r','MarkerEdgeColor','r')
    end
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Plot each data
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for plotiter=1:length(G1_Mice)
%     hold on
%     scatter(X,N_G1Usage(1,G2vsG1Sortedusageindex,plotiter),mksize,'MarkerFaceColor',[ 0    0.4470    0.7410],'MarkerEdgeColor',[ 0    0.4470    0.7410])
% end
% for plotiter=1:length(G2_Mice)
%     hold on
%     scatter(X,N_G2Usage(1,G2vsG1Sortedusageindex,plotiter),mksize,'MarkerFaceColor',[0.8500    0.3250    0.0980],'MarkerEdgeColor',[0.8500    0.3250    0.0980])
% end


legend({G1_name,G2_name},'FontSize',fsize)
title(['Syllable Usage (Averaged percentatge) Comparison of ' G1_name ' vs. ' G2_name ' (' Batch_name ')'],'FontSize',fsize)
ylabel('Fraction','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX(G2vsG1Sortedusageindex));