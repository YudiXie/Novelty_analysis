%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
G1_Mice=[1 2 3 4];
G2_Mice=[5 6 7 8];
G1_Days=[3 4 5 6];
G2_Days=[3 4 5 6];

% G3 Base line
G3_Mice=1:8;
G3_Days=[1 2];

load('MoSeqDataFrame.mat')
cmap=jet(100);
fps=30;
Syllablebinedge=[-6,-0.5:1:99.5];

Mice_Index_path='/Users/yuxie/Dropbox/YuXie/CvsS_180831/CvsS_180831_MoSeq/Mice_Index.m';
run(Mice_Index_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic

% Generate Transition Matrix

for miceiter=1:length(Mice)

    for dayiter=1:length(Mice(miceiter).ExpDay)

        % find MSid index
        MSidindex=1;
        for indexiter=1:size(MoSeqDataFrame.session_uuid,1)
            if strcmp(MoSeqDataFrame.session_uuid(indexiter,:),Mice(miceiter).ExpDay(dayiter).MSid)
                break
            end
            MSidindex=MSidindex+1;
            if MSidindex==size(MoSeqDataFrame.session_uuid,1)+1
                error('MSid not found');
            end
        end

        Labels=double(MoSeqDataFrame.labels{MSidindex});
        labellen=length(Labels);

        % Calculate Empirical Bigram Transition Matrix (self transition included)
        % BiMatrixSum is the sum of Bi-transition, exclude window with 'none' type
        Mice(miceiter).ExpDay(dayiter).BiMatrix=zeros(100,100);
        Mice(miceiter).ExpDay(dayiter).BiMatrixSum=0;
        
        for frameiter=1:labellen-1

            readwindow=Labels(frameiter:frameiter+1);
            if sum(readwindow<0)>0
                continue
            end

            Mice(miceiter).ExpDay(dayiter).BiMatrix(readwindow(1)+1,readwindow(2)+1) = 1 + Mice(miceiter).ExpDay(dayiter).BiMatrix(readwindow(1)+1,readwindow(2)+1);
            Mice(miceiter).ExpDay(dayiter).BiMatrixSum=Mice(miceiter).ExpDay(dayiter).BiMatrixSum+1;

        end

        % Calculate syllable usage count, usage(1) 'none' syllable, usage(2) number of syllable 0 is used...
        % usagesum is the sum of all frames except 'none' type
        Mice(miceiter).ExpDay(dayiter).usage=histcounts(Labels,Syllablebinedge);
        Mice(miceiter).ExpDay(dayiter).usagesum=sum(Mice(miceiter).ExpDay(dayiter).usage(2:end));
        
    end

end

% Calculate General Usage of all experiments
GUsage=zeros(1,101);
for miceiter=1:length(Mice)
    for dayiter=1:length(Mice(miceiter).ExpDay)
        GUsage = GUsage + Mice(miceiter).ExpDay(dayiter).usage;   
    end
end
PGUsage=GUsage./sum(GUsage);

[GSortedusage,GSortedusageindex]=sort(PGUsage,'descend');

AccGSortedusage=zeros(1,101);
for usageiter=1:length(GSortedusage)
    AccGSortedusage(usageiter)=sum(GSortedusage(1:usageiter));
end

% Calculate Usage of Group1, Group2, and Group3
G1Usage=zeros(1,101);
for miceiter=G1_Mice
    for dayiter=G1_Days
        G1Usage = G1Usage + Mice(miceiter).ExpDay(dayiter).usage;   
    end
end
PG1Usage=G1Usage./sum(G1Usage);

G2Usage=zeros(1,101);
for miceiter=G2_Mice
    for dayiter=G2_Days
        G2Usage = G2Usage + Mice(miceiter).ExpDay(dayiter).usage;
    end
end
PG2Usage=G2Usage./sum(G2Usage);

G3Usage=zeros(1,101);
for miceiter=G3_Mice
    for dayiter=G3_Days
        G3Usage = G3Usage + Mice(miceiter).ExpDay(dayiter).usage;
    end
end
PG3Usage=G3Usage./sum(G3Usage);

G2vsG1usage=(PG2Usage-PG1Usage)./(PG2Usage+PG1Usage);
[G2vsG1Sortedusage,G2vsG1Sortedusageindex]=sort(G2vsG1usage,'descend');

% Calculate General Bigram Transition Matrix of all experiments
GBM=zeros(100,100);
for miceiter=1:length(Mice)
    for dayiter=1:length(Mice(miceiter).ExpDay)
        GBM = GBM + Mice(miceiter).ExpDay(dayiter).BiMatrix;
    end
end
InterGBM=GBM-GBM.*diag(ones(1,100));     % subtract self transition 
PGBM=InterGBM./sum(sum(InterGBM));       % Normalization


% Calculate Bigram Transition Matrix of Group1
G1BM=zeros(100,100);
for miceiter=G1_Mice
    for dayiter=G1_Days
        G1BM = G1BM + Mice(miceiter).ExpDay(dayiter).BiMatrix;
    end
end
InterG1BM=G1BM-G1BM.*diag(ones(1,100));     % subtract self transition
PG1BM=InterG1BM./sum(sum(InterG1BM));       % Normalization

% Calculate Bigram Transition Matrix of Group2
G2BM=zeros(100,100);
for miceiter=G2_Mice
    for dayiter=G2_Days
        G2BM = G2BM + Mice(miceiter).ExpDay(dayiter).BiMatrix;
    end
end
InterG2BM=G2BM-G2BM.*diag(ones(1,100));     % subtract self transition
PG2BM=InterG2BM./sum(sum(InterG2BM));       % Normalization

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Making plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=0:100;
SyllablesX=-1:99;
fsize=16;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_GeneralUsage=figure;
plot(X,GSortedusage,'LineWidth',1.5)
title('General Syllable Usage (sorted by usage, CvsS 180831)','FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX(GSortedusageindex));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_AccGeneralUsage=figure;
plot(X,AccGSortedusage,'LineWidth',1.5)
title('Accumulated General Syllable Usage (CvsS 180831)','FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables Rank','FontSize',fsize)
xticks(X);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_UsageCompare=figure;
plot(X,PG1Usage,'LineWidth',1.5)
hold on
plot(X,PG2Usage,'LineWidth',1.5)

legend('Contextual Novelty','Stimulus Novelty')
title('Syllable Usage Comparison of Contextual/Stimulus Novely Mice (CvsS 180831)','FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_UsageCompare_sorted=figure;
plot(X,PG1Usage(G2vsG1Sortedusageindex),'LineWidth',1.5)
hold on
plot(X,PG2Usage(G2vsG1Sortedusageindex),'LineWidth',1.5)
hold on
plot(X,PG3Usage(G2vsG1Sortedusageindex),'LineWidth',1,'Color','Black')

legend({'Contextual Novelty','Stimulus Novelty','Habituattion'},'FontSize',fsize)
title('Syllable Usage Comparison of Contextual/Stimulus Novely Mice (CvsS 180831) (Sorted by stimulus novelty enrichment)','FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX(G2vsG1Sortedusageindex));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving Datas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pause
close all
clearvars Plot_UsageCompare_sorted Plot_UsageCompare Plot_AccGeneralUsage Plot_GeneralUsage
save('GeneralUsage.mat')
clear



