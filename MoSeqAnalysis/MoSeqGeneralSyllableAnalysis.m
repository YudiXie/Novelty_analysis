%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please edit the following parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Batch_name='KaeserLab 190126';
G1_name='Group1';
G2_name='Group2';

G1_Mice=1:11;
G2_Mice=12:19;
G1_Days=[1];
G2_Days=[1];


% G3 Base line
G3_Mice=1:19;
G3_Days=[1];
G3_name='Averaged Baseline';

Mice_Index_path='/Users/yuxie/Dropbox/YuXie/Kaeser_Lab/190125/Mice_Index.m';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('MoSeqDataFrame.mat')
cmap=jet(100);
fps=30;
Syllablebinedge=[-6,-0.5:1:99.5];
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

        Mice(miceiter).ExpDay(dayiter).usage_count=zeros(1,101);
        Mice(miceiter).ExpDay(dayiter).usage_countsum=0;
        
        for frameiter=1:labellen-1

            % Calculate number of times of syllable usage, usage_count(1) 'none' syllable, usage_count(2) number of times syllable 0 is used...
            % usagesum_count is the sum of all syllables except 'none' type
            if readwindow(1)~=readwindow(2)
                if readwindow(1)==-5
                    Mice(miceiter).ExpDay(dayiter).usage_count(1)=Mice(miceiter).ExpDay(dayiter).usage_count(1)+1;
                else 
                    Mice(miceiter).ExpDay(dayiter).usage_count(readwindow(1)+2)=Mice(miceiter).ExpDay(dayiter).usage_count(readwindow(1)+2)+1;
                end
            end

            readwindow=Labels(frameiter:frameiter+1);
            if sum(readwindow<0)>0
                continue
            end

            Mice(miceiter).ExpDay(dayiter).BiMatrix(readwindow(1)+1,readwindow(2)+1) = 1 + Mice(miceiter).ExpDay(dayiter).BiMatrix(readwindow(1)+1,readwindow(2)+1);
            Mice(miceiter).ExpDay(dayiter).BiMatrixSum=Mice(miceiter).ExpDay(dayiter).BiMatrixSum+1;

        end

        if readwindow(2)==-5
            Mice(miceiter).ExpDay(dayiter).usage_count(1)=Mice(miceiter).ExpDay(dayiter).usage_count(1)+1;
        else 
            Mice(miceiter).ExpDay(dayiter).usage_count(readwindow(2)+2)=Mice(miceiter).ExpDay(dayiter).usage_count(readwindow(2)+2)+1;
        end

        Mice(miceiter).ExpDay(dayiter).usage_countsum=sum(Mice(miceiter).ExpDay(dayiter).usage_count(2:end));

        % Calculate total frames of syllable usage, usage(1) 'none' syllable, usage(2) total frames of syllable 0...
        % usagesum is the sum of all syllables except 'none' type
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

% Calculate General Usage Count of all experiments
GUsage_count=zeros(1,101);
for miceiter=1:length(Mice)
    for dayiter=1:length(Mice(miceiter).ExpDay)
        GUsage_count = GUsage_count + Mice(miceiter).ExpDay(dayiter).usage_count;   
    end
end
PGUsage=GUsage_count./sum(GUsage_count);


% Calculate Usage of Group1, Group2, and Group3
G1Usage=zeros(length(G1_Days),101,length(G1_Mice));
d3iter=1;
for miceiter=G1_Mice
    d1iter=1;
    for dayiter=G1_Days
        G1Usage(d1iter,:,d3iter) = Mice(miceiter).ExpDay(dayiter).usage;
        d1iter=d1iter+1;
    end
    d3iter=d3iter+1;
end
PG1Usage=sum(sum(G1Usage,1),3)./sum(sum(sum(G1Usage,1),3));

G2Usage=zeros(length(G2_Days),101,length(G2_Mice));
d3iter=1;
for miceiter=G2_Mice
    d1iter=1;
    for dayiter=G2_Days
        G2Usage(d1iter,:,d3iter) = Mice(miceiter).ExpDay(dayiter).usage;
        d1iter=d1iter+1;
    end
    d3iter=d3iter+1;
end
PG2Usage=sum(sum(G2Usage,1),3)./sum(sum(sum(G2Usage,1),3));

G3Usage=zeros(length(G3_Days),101,length(G3_Mice));
d3iter=1;
for miceiter=G3_Mice
    d1iter=1;
    for dayiter=G3_Days
        G3Usage(d1iter,:,d3iter) = Mice(miceiter).ExpDay(dayiter).usage;
        d1iter=d1iter+1;
    end
    d3iter=d3iter+1;
end
PG3Usage=sum(sum(G3Usage,1),3)./sum(sum(sum(G3Usage,1),3));

G2vsG1usage=(PG2Usage-PG1Usage)./(PG2Usage+PG1Usage);
[G2vsG1Sortedusage,G2vsG1Sortedusageindex]=sort(G2vsG1usage,'descend');

% Calculate Usage Count of Group1, Group2, and Group3
G1Usage_count=zeros(length(G1_Days),101,length(G1_Mice));
d3iter=1;
for miceiter=G1_Mice
    d1iter=1;
    for dayiter=G1_Days
        G1Usage_count(d1iter,:,d3iter) = Mice(miceiter).ExpDay(dayiter).usage_count;
        d1iter=d1iter+1;
    end
    d3iter=d3iter+1;
end
PG1Usage_count=sum(sum(G1Usage_count,1),3)./sum(sum(sum(G1Usage_count,1),3));

G2Usage_count=zeros(length(G2_Days),101,length(G2_Mice));
d3iter=1;
for miceiter=G2_Mice
    d1iter=1;
    for dayiter=G2_Days
        G2Usage_count(d1iter,:,d3iter) = Mice(miceiter).ExpDay(dayiter).usage_count;
        d1iter=d1iter+1;
    end
    d3iter=d3iter+1;
end
PG2Usage_count=sum(sum(G2Usage_count,1),3)./sum(sum(sum(G2Usage_count,1),3));

G3Usage_count=zeros(length(G3_Days),101,length(G3_Mice));
d3iter=1;
for miceiter=G3_Mice
    d1iter=1;
    for dayiter=G3_Days
        G3Usage_count(d1iter,:,d3iter) = Mice(miceiter).ExpDay(dayiter).usage_count;
        d1iter=d1iter+1;
    end
    d3iter=d3iter+1;
end
PG3Usage_count=sum(sum(G3Usage_count,1),3)./sum(sum(sum(G3Usage_count,1),3));

G2vsG1usage_count=(PG2Usage_count-PG1Usage_count)./(PG2Usage_count+PG1Usage_count);
[G2vsG1Sortedusage_count,G2vsG1Sortedusage_countindex]=sort(G2vsG1usage_count,'descend');

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
title(['General Syllable Usage (sorted by usage, ' Batch_name ' )'],'FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX(GSortedusageindex));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_AccGeneralUsage=figure;
plot(X,AccGSortedusage,'LineWidth',1.5)
title(['Accumulated General Syllable Usage (' Batch_name ')'],'FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables Rank','FontSize',fsize)
xticks(X);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_UsageCompare=figure;
plot(X,PG1Usage,'LineWidth',1.5)
hold on
plot(X,PG2Usage,'LineWidth',1.5)

legend({G1_name,G2_name},'FontSize',fsize)
title(['Syllable Usage Comparison of ' G1_name ' vs. ' G2_name ' (' Batch_name ')'],'FontSize',fsize)
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

legend({G1_name,G2_name,G3_name},'FontSize',fsize)
title(['Syllable Usage Comparison of ' G1_name ' vs. ' G2_name ' (' Batch_name ')' '(Sorted by ' G2_name ' enrichment)'],'FontSize',fsize)
ylabel('Fraction','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX(G2vsG1Sortedusageindex));


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Plot syllable usage without plotting less frequently used syllables
% PG1Usage_sort_filtered_raw=PG1Usage(G2vsG1Sortedusageindex);
% PG2Usage_sort_filtered_raw=PG2Usage(G2vsG1Sortedusageindex);
% SyllablesX_sort_filtered_raw=SyllablesX(G2vsG1Sortedusageindex);

% Usage_th=0.01; % usage threshold
% iter=1;
% for syliter=1:101
%     if PG1Usage_sort_filtered_raw(syliter)+PG2Usage_sort_filtered_raw(syliter)>Usage_th
%         PG1Usage_sort_filtered(iter)=PG1Usage_sort_filtered_raw(syliter);
%         PG2Usage_sort_filtered(iter)=PG2Usage_sort_filtered_raw(syliter);
%         SyllablesX_sort_filtered(iter)=SyllablesX_sort_filtered_raw(syliter);
%         iter=iter+1;
%     end
% end

% Plot_UsageCompare_sorted_filtered=figure;
% plot(X(1:length(PG1Usage_sort_filtered)),PG1Usage_sort_filtered,'LineWidth',1.5)
% hold on
% plot(X(1:length(PG1Usage_sort_filtered)),PG2Usage_sort_filtered,'LineWidth',1.5)

% legend({G1_name,G2_name,G3_name},'FontSize',fsize)
% title(['Syllable Usage Comparison of ' G1_name ' vs. ' G2_name ' (' Batch_name ')' '(Sorted by ' G2_name ' enrichment) filtered'],'FontSize',fsize)
% ylabel('Fraction','FontSize',fsize)
% xlabel('Syllables','FontSize',fsize)
% xticks(X(1:length(PG1Usage_sort_filtered)));
% xticklabels(SyllablesX_sort_filtered);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pause
close all
clearvars Plot_UsageCompare_sorted Plot_UsageCompare Plot_AccGeneralUsage Plot_GeneralUsage
save('GeneralUsage.mat')
clear

