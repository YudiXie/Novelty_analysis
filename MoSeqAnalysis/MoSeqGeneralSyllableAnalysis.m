%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('ModelData.mat')
cmap=jet(100);
fps=30;
Syllablebinedge=[-6,-0.5:1:99.5];

Mice(1).datanum=26;
Mice(2).datanum=43;
Mice(3).datanum=40;
Mice(4).datanum=41;


Mice(1).name='Mal';
Mice(2).name='Wash';
Mice(3).name='Kaylee';
Mice(4).name='River';

Mice(1).novelty='S';
Mice(2).novelty='S';
Mice(3).novelty='S';
Mice(4).novelty='S';

% Mal:
Mice(1).ExpDay(1).MSid='e7ed0e85-149a-45d7-b40d-f56b73b3050c';  % H1
Mice(1).ExpDay(2).MSid='1a6cc63c-934a-4fb6-8c2f-b1e1616b9604';  % H2
Mice(1).ExpDay(3).MSid='af5e0790-8ffb-4fa1-86e4-614a4efae7d4';  % N1
Mice(1).ExpDay(4).MSid='a52bf424-0b9a-4195-8f9e-7b87abe5398c';  % N2

% Wash
Mice(2).ExpDay(1).MSid='1b21fd16-843d-40a2-a180-e885b618060d';  % H1
Mice(2).ExpDay(2).MSid='06232efa-884e-44f6-b3a2-b8ef949e2b14';  % H2
Mice(2).ExpDay(3).MSid='84ca42ce-f065-4298-a097-b18c49a7cbe1';  % N1
Mice(2).ExpDay(4).MSid='4b737026-c1ce-4e93-95b7-458e52259ad3';  % N2

% Kaylee
Mice(3).ExpDay(1).MSid='798b577a-1a84-453a-8dc3-aa020f26acf3';  % H1
Mice(3).ExpDay(2).MSid='fc9658f3-8614-42ad-9275-4037e37da9f9';  % H2
Mice(3).ExpDay(3).MSid='dd7ceaaf-ff8c-4a0e-a386-58698597cfcf';  % N1
Mice(3).ExpDay(4).MSid='08eaaec2-c507-4b3b-a822-79d531453937';  % N2

% River
Mice(4).ExpDay(1).MSid='d97fe1d2-4959-45bb-8da6-6166fd0300f4';  % H1
Mice(4).ExpDay(2).MSid='bb40083a-e633-498f-8397-b8e6ac91aa0a';  % H2
Mice(4).ExpDay(3).MSid='352262f2-2c47-420d-a8cc-debbac31061d';  % N1
Mice(4).ExpDay(4).MSid='45813819-f6e2-42eb-a5f7-763a87187996';  % N2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic

% Generate Transition Matrix

for miceiter=1:length(Mice)

    for dayiter=1:length(Mice(miceiter).ExpDay)

        % find MSid index
        MSidindex=1;
        for indexiter=1:size(MSid,1)
            if strcmp(MSid(indexiter,:),Mice(miceiter).ExpDay(dayiter).MSid)
                break
            end
            MSidindex=MSidindex+1;
            if MSidindex==size(MSid,1)+1
                error('MSid not found');
            end
        end

        Labels=MSLabels{MSidindex};
        labellen=length(Labels);

        % Calculate three-elements Transition Matrix (self transition included)
        % TriMatrixSum is the sum of tri-transition, exclude window with 'none' type
        Mice(miceiter).ExpDay(dayiter).TriMatrix=zeros(100,100,100);
        Mice(miceiter).ExpDay(dayiter).TriMatrixSum=0;
        
        for frameiter=1:labellen-2

            readwindow=Labels(frameiter:frameiter+2);
            if sum(readwindow<0)>0
                continue
            end

            Mice(miceiter).ExpDay(dayiter).TriMatrix(readwindow(1)+1,readwindow(2)+1,readwindow(3)+1) = 1 + Mice(miceiter).ExpDay(dayiter).TriMatrix(readwindow(1)+1,readwindow(2)+1,readwindow(3)+1);
            Mice(miceiter).ExpDay(dayiter).TriMatrixSum=Mice(miceiter).ExpDay(dayiter).TriMatrixSum+1;

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



% Calculate Usage of of all Habituation and Novelty Day
HUsage=zeros(1,101);
for miceiter=1:length(Mice)
    for dayiter=1:2
        HUsage = HUsage + Mice(miceiter).ExpDay(dayiter).usage;   
    end
end
PHUsage=HUsage./sum(HUsage);

NUsage=zeros(1,101);
for miceiter=1:length(Mice)
    for dayiter=3:4
        NUsage = NUsage + Mice(miceiter).ExpDay(dayiter).usage;
    end
end
PNUsage=NUsage./sum(NUsage);

NvsHusage=(PNUsage-PHUsage)./(PNUsage+PHUsage);
[NvsHSortedusage,NvsHSortedusageindex]=sort(NvsHusage,'descend');


% Calculate General Bigram Transition Matrix of all experiments
GBM=zeros(100,100);
for miceiter=1:length(Mice)
    for dayiter=1:length(Mice(miceiter).ExpDay)
        GBM = GBM + sum(Mice(miceiter).ExpDay(dayiter).TriMatrix,3);   
    end
end
InterGBM=GBM-GBM.*diag(ones(1,100));     % subtract self transition 
PGBM=InterGBM./sum(sum(InterGBM));       % Normalization


% Calculate Bigram Transition Matrix of Habituation Day
HBM=zeros(100,100);
for miceiter=1:length(Mice)
    for dayiter=1:2
        HBM = HBM + sum(Mice(miceiter).ExpDay(dayiter).TriMatrix,3);
    end
end
InterHBM=HBM-HBM.*diag(ones(1,100));     % subtract self transition
PHBM=InterHBM./sum(sum(InterHBM));       % Normalization

% Calculate Bigram Transition Matrix of Novelty Day
NBM=zeros(100,100);
for miceiter=1:length(Mice)
    for dayiter=3:4
        NBM = NBM + sum(Mice(miceiter).ExpDay(dayiter).TriMatrix,3);
    end
end
InterNBM=NBM-NBM.*diag(ones(1,100));     % subtract self transition
PNBM=InterNBM./sum(sum(InterNBM));       % Normalization



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Making plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=0:100;
SyllablesX=-1:99;
fsize=16;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_GeneralUsage=figure;
plot(X,GSortedusage,'LineWidth',1.5)
title('General Syllable Usage (sorted by usage, Serenity H1H2N1N2)','FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX(GSortedusageindex));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_AccGeneralUsage=figure;
plot(X,AccGSortedusage,'LineWidth',1.5)
title('Accumulated General Syllable Usage (Serenity H1H2N1N2)','FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables Rank','FontSize',fsize)
xticks(X);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_UsageCompare=figure;
plot(X,PHUsage,'LineWidth',1.5)
hold on
plot(X,PNUsage,'LineWidth',1.5)

legend('Habituation Day','Novelty Day')
title('Syllable Usage Compare of Stimulus Novely Mice (Serenity H1H2N1N2)','FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_UsageCompare_sorted=figure;
plot(X,PHUsage(NvsHSortedusageindex),'LineWidth',1.5)
hold on
plot(X,PNUsage(NvsHSortedusageindex),'LineWidth',1.5)

legend('Habituation Day','Novelty Day')
title('Syllable Usage Compare of Stimulus Novely Mice (Serenity H1H2N1N2) (Sorted by novelty enrichment)','FontSize',fsize)
ylabel('Percentage','FontSize',fsize)
xlabel('Syllables','FontSize',fsize)
xticks(X);
xticklabels(SyllablesX(NvsHSortedusageindex));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Making plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clearvars Plot_UsageCompare_sorted Plot_UsageCompare Plot_AccGeneralUsage Plot_GeneralUsage
save('GeneralUsage.mat')



