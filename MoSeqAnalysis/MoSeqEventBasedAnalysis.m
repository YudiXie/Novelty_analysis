%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('MoSeqDataFrame.mat')
Syllablebinedge=[-6,-0.5:1:99.5];

Mice_Index_path='/Users/yuxie/Dropbox/YuXie/CvsS_180831/CvsS_180831_MoSeq/Mice_Index.m';
run(Mice_Index_path);

cmap=cool(12);

mksize=80;
fsize=16;

fps=30;
starttime=0;         % in minute  Pending: in the future, this should depend on the starting frame of each experiments
timeseg=0:5:30;      % in minute
timeseg=starttime+timeseg;
frameseg=timeseg.*60.*fps;

Analysis_Mice=1:8;
Analysis_Day=1:6;     % first novelty day
Plot_SingleDay=3;
Plot_MultiDay=3:6;

IntSyl=70;          % Interesting Syllable

Cnum=4;
Snum=4;

CVSXTick={'Contextual' 'Stimulus'};
CVSX=1:2;

for segiter=1:length(timeseg)-1
    IntersessionXTick{segiter}=[num2str(timeseg(segiter)) '-' num2str(timeseg(segiter+1))];
end
IntersessionX=1:length(timeseg)-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for miceiter=Analysis_Mice

    for dayiter=Analysis_Day

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

        Mice(miceiter).ExpDay(dayiter).IntSIndex=find(Labels==IntSyl);
        Mice(miceiter).ExpDay(dayiter).syltime=histcounts(Mice(miceiter).ExpDay(dayiter).IntSIndex,frameseg)./fps;
        Mice(miceiter).ExpDay(dayiter).syltime_total=sum(Mice(miceiter).ExpDay(dayiter).syltime);
        Mice(miceiter).ExpDay(dayiter).syltime_per_minute=Mice(miceiter).ExpDay(dayiter).syltime./(timeseg(2:end)-timeseg(1:end-1));
    end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
syltime_total=zeros(length(Mice),1,length(Mice(1).ExpDay));
syltime_per_minute=zeros(length(Mice),length(timeseg)-1,length(Mice(1).ExpDay));
for miceiter=Analysis_Mice
    for dayiter=Analysis_Day
        syltime_total(miceiter,:,dayiter)=Mice(miceiter).ExpDay(dayiter).syltime_total;
        syltime_per_minute(miceiter,:,dayiter)=Mice(miceiter).ExpDay(dayiter).syltime_per_minute;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_total_interaction_time=figure;

Plotdata=syltime_total(:,:,Plot_SingleDay);
csavg=[mean(Plotdata(1:Cnum,:)) mean(Plotdata(Cnum+1:Cnum+Snum,:))];
csstd=[std(Plotdata(1:Cnum,:)) std(Plotdata(Cnum+1:Cnum+Snum,:))];

bar(CVSX,csavg);
hold on
errorbar(CVSX,csavg,csstd,'.','LineWidth',2,'Color','black')
hold on

for miceiter=1:length(Mice)
    if Mice(miceiter).novelty == 'C'
        scatter(1,Plotdata(miceiter),mksize,'filled','d')
        hold on 
    elseif Mice(miceiter).novelty == 'S'
        scatter(2,Plotdata(miceiter),mksize,'filled','d')
        hold on
    else
        error('Novelty class not defined');
    end
end

legend('C vs S','SD','C4','C5','C6','C7','S4','S5','Mal','Wash')
set(Plot_total_interaction_time, 'position', [0 0 500 800]);
% ylim([0 50])
title(['Syllable ' num2str(IntSyl) ' on novelty day 1 (CvsS_180831)'],'FontSize',fsize)
ylabel(['Syllable ' num2str(IntSyl) ' Usage Time (s)'],'FontSize',fsize)
xticks(CVSX);
xticklabels(CVSXTick);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_interaction_time=figure;

Plotdata=syltime_per_minute(:,:,Plot_SingleDay);

intersessioncavg=mean(Plotdata(1:Cnum,:));
intersessioncstd=std(Plotdata(1:Cnum,:));

intersessionsavg=mean(Plotdata(Cnum+1:Cnum+Snum,:));
intersessionsstd=std(Plotdata(Cnum+1:Cnum+Snum,:));

errorbar(IntersessionX,intersessioncavg,intersessioncstd,'LineWidth',1.5)
hold on
errorbar(IntersessionX,intersessionsavg,intersessionsstd,'LineWidth',1.5)
hold on

for miceiter=1:length(Mice)
    if Mice(miceiter).novelty == 'C'
        scatter(IntersessionX,Plotdata(miceiter,:),'Marker','o','MarkerFaceColor','b','LineWidth',1)
        hold on
    elseif Mice(miceiter).novelty == 'S'
        scatter(IntersessionX,Plotdata(miceiter,:),'Marker','o','MarkerFaceColor','r','LineWidth',1)
        hold on
    else
        error('Novelty class not defined');
    end
end
xlim([0.5 length(timeseg)-0.5]);


title(['Syllable ' num2str(IntSyl) ' per minute novelty day 1 (CvsS_180831)'],'FontSize',fsize)
legend('Contextual','Stimulus','C4','C5','C6','C7','S4','S5','Mal','Wash')
xlabel('Time Segments (min)','FontSize',fsize)
ylabel(['Syllable ' num2str(IntSyl) ' Usage Time (s)'],'FontSize',fsize)
xticks(IntersessionX);
xticklabels(IntersessionXTick);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_interaction_time_multiday=figure;

Plotdata=syltime_per_minute(:,:,Plot_MultiDay);

intersessioncavg=mean(Plotdata(1:Cnum,:,:),1);
intersessioncstd=std(Plotdata(1:Cnum,:,:),1);

intersessionsavg=mean(Plotdata(Cnum+1:Cnum+Snum,:,:),1);
intersessionsstd=std(Plotdata(Cnum+1:Cnum+Snum,:,:),1);

for dayiter=1:length(Plot_MultiDay)
    plot(IntersessionX,intersessioncavg(:,:,dayiter),'LineWidth',1.5,'Color',cmap(dayiter,:))
    hold on
end
for dayiter=1:length(Plot_MultiDay)
    plot(IntersessionX,intersessionsavg(:,:,dayiter),'LineWidth',1.5,'Color',cmap(end-dayiter,:))
    hold on
end
legend('C-N1','C-N2','C-N3','C-N4','S-N1','S-N2','S-N3','S-N4');
xlim([0.5 length(timeseg)-0.5]);
xticks(IntersessionX);
xticklabels(IntersessionXTick);
xlabel('Time Segments (min)','FontSize',fsize)
ylabel(['Syllable ' num2str(IntSyl) ' Usage Time (s)'],'FontSize',fsize)
title(['Syllable ' num2str(IntSyl) ' per minute on all novelty days (CvsS_180831)'],'FontSize',fsize)