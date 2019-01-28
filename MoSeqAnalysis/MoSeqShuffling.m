%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please edit the following parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Batch_name='KaeserLab 190126';
G1_name='Group1';
G2_name='Group2';

All_Mice=1:19;
G1_Num=11;
G2_Num=length(All_Mice)-G1_Num;

G1_Comb=nchoosek(All_Mice,G1_Num);
G2_Comb=zeros(size(G1_Comb,1),G2_Num);
for combiter=1:size(G1_Comb,1)
    G2_Comb(combiter,:)=setdiff(All_Mice,G1_Comb(combiter,:));
end


G1_Days=[1];
G2_Days=[1];

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
        % Calculate syllable usage count, usage(1) 'none' syllable, usage(2) number of syllable 0 is used...
        % usagesum is the sum of all frames except 'none' type
        Mice(miceiter).ExpDay(dayiter).usage=histcounts(Labels,Syllablebinedge);
        Mice(miceiter).ExpDay(dayiter).usagesum=sum(Mice(miceiter).ExpDay(dayiter).usage(2:end));
        
    end

end

h=zeros(size(G1_Comb,1),101);

for combiter=1:size(G1_Comb,1)
    combiter
    % Calculate Usage of Group1, Group2
    G1Usage=zeros(length(G1_Days),101,length(G1_Comb(combiter,:)));
    d1iter=1;
    d3iter=1;
    for miceiter=G1_Comb(combiter,:)
        for dayiter=G1_Days
            G1Usage(d1iter,:,d3iter) = Mice(miceiter).ExpDay(dayiter).usage;
            d1iter=d1iter+1;
        end
        d3iter=d3iter+1;
    end

    G2Usage=zeros(length(G2_Days),101,length(G2_Comb(combiter,:)));
    d1iter=1;
    d3iter=1;
    for miceiter=G2_Comb(combiter,:)
        for dayiter=G2_Days
            G2Usage(d1iter,:,d3iter) = Mice(miceiter).ExpDay(dayiter).usage;
            d1iter=d1iter+1;
        end
        d3iter=d3iter+1;
    end

    % Statistical Test
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
    N_G1Usage_tt=zeros(length(G1_Comb(combiter,:)),101);
    for sheetiter=1:length(G1_Comb(combiter,:))
        N_G1Usage_tt(sheetiter,:)=N_G1Usage(1,:,sheetiter);
    end

    N_G2Usage_tt=zeros(length(G2_Comb(combiter,:)),101);
    for sheetiter=1:length(G2_Comb(combiter,:))
        N_G2Usage_tt(sheetiter,:)=N_G2Usage(1,:,sheetiter);
    end

    h(combiter,:)=ttest2(N_G1Usage_tt,N_G2Usage_tt,'Vartype','unequal');

end
