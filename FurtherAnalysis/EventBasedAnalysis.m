% Mice(miceiter).act(:,1) Starting frame of interesting behaviors
% Mice(miceiter).act(:,2) Key time point of interesting behaviors
% Mice(miceiteri).act(:,3) Endding frame of interesting behaviors
% Mice(miceiter).act(:,4) the whole duration of interesting behaviors (s)
% Mice(miceiter).act(:,5) in radius time (s) of each action, sum(if(inradius from action start to action end))/fps
% Mice(miceiter).act(:,6) average Body length index (interaction body length/average body length) during interaction, (act_end-50:act_end)
% Mice(miceiter).act(:,7) average retreat speed during interaction (cm/s)
% Mice(miceiter).act(:,8) approching angle - retreat angle (degree)

% Mice(miceiteri).actcount an array of action count corrsponding to time segment
% Mice(miceiter).actcount_per_minute an array corrsponding to different time segment of action count per minute
% Mice(miceiter).actcount_total total interaction count (during specific time segment)

% Mice(miceiter).interactiontime an array of total interaction time in radius corrsponding time segment
% Mice(miceiter).time_per_interaction an array corrsponding to different time segment of time (s) of each interaction (in radius time)
% Mice(imiceiter).interactiontime_total total interaction time
% Mice(miceiter).avetimeperinteraction_at time per interaction (average of all trial)

% Mice(miceiter).sumretreatspeed sum of retreat speed in each segment 
% Mice(miceiter).avgretreatspeed average retreat speed in each segment
% Mice(miceiter).avgretreatspeed_at retreat speed average of all trials

% Mice(miceiter).sumbodylengthindex sum of body length index in each segment
% Mice(miceiter).avgbodylengthindex average of body length index in each segment
% Mice(miceiter).avgbodylengthindex_at body length index average of all trials

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fps=30;
starttime=0.01;              % in minute  Pending: in the future, this should depend on the starting frame of each experiments
timeseg=[0 2 4 6 8 15];     % in minute

timeseg=starttime+timeseg;
frameseg=timeseg.*60.*fps;
fsize=16;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AnalysisDay=3;      % first novelty day

Mice(1).datanum=32;
Mice(2).datanum=23;
Mice(3).datanum=30;
Mice(4).datanum=24;
Mice(5).datanum=17;
Mice(6).datanum=29;


Mice(1).name='C1_Akbar';
Mice(2).name='C2_Emperor';
Mice(3).name='C3_Piett';
Mice(4).name='S1_Anakin';
Mice(5).name='S2_Jabba';
Mice(6).name='S3_Wedge';

Mice(1).novelty='C';
Mice(2).novelty='C';
Mice(3).novelty='C';
Mice(4).novelty='S';
Mice(5).novelty='S';
Mice(6).novelty='S';


AllActLabels=csvread('ROTJManualLabels.csv',1,2);
AllActLabels(:,4)=(AllActLabels(:,3)-AllActLabels(:,1))./fps;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Mice(1).index=1;
for miceiter=2:length(Mice)
    Mice(miceiter).index=Mice(miceiter-1).index+Mice(miceiter-1).datanum;
    endindex=Mice(miceiter).index+Mice(miceiter).datanum;
end

if endindex ~= length(AllActLabels)+1
    error('index calculation error');
end


for miceiter=1:length(Mice)
    Mice(miceiter).act=AllActLabels(Mice(miceiter).index:Mice(miceiter).index+Mice(miceiter).datanum-1,:);
end


for miceiter=1:length(Mice)
    cd(Mice(miceiter).name);
    cd Analyzed_Data

    subpath=cd;
    PathRoot=[subpath '/'];
    filelist=dir([PathRoot,'*.mat']);
    load(filelist(AnalysisDay+1).name);

    Mice(miceiter).bodylength=mean(sqrt((Labels(frameseg(1):frameseg(end),2)-Labels(frameseg(1):frameseg(end),11)).^2 ...
                                       +(Labels(frameseg(1):frameseg(end),3)-Labels(frameseg(1):frameseg(end),12)).^2));
    for actiter=1:length(Mice(miceiter).act)
        act_start=Mice(miceiter).act(actiter,1);
        act_point=Mice(miceiter).act(actiter,2);
        act_end=Mice(miceiter).act(actiter,3);

        Mice(miceiter).act(actiter,5)=sum(Labels(act_start:act_end,21))./fps;
        Mice(miceiter).act(actiter,6)=mean(sqrt((Labels(act_point-30:act_point,2)-Labels(act_point-30:act_point,11)).^2+...
                                                (Labels(act_point-30:act_point,3)-Labels(act_point-30:act_point,12)).^2))./Mice(miceiter).bodylength;
        Mice(miceiter).act(actiter,7)=mean(sqrt(Labels(act_point:act_point+30,24).^2+Labels(act_point:act_point+30,25).^2));

        % startpos=[mean(Labels(act_point-100:act_point-80,14)) mean(Labels(act_point-100:act_point-80,15))];
        % pointpos=[mean(Labels(act_point-10:act_point,14)) mean(Labels(act_point-10:act_point,15))];
        % endpos = [mean(Labels(act_point:act_point+20,14)) mean(Labels(act_point:act_point+20,15))];
        tcal_start=act_point-30;
        tcal_point=act_point-10;
        tcal_end=act_point+10;
        startpos=[mean(Labels(tcal_start,14)) mean(Labels(tcal_start,15))];
        pointpos=[mean(Labels(tcal_point,14)) mean(Labels(tcal_point,15))];
        endpos = [mean(Labels(tcal_end,14)) mean(Labels(tcal_end,15))];
        v1 = startpos-pointpos;
        v2 = endpos-pointpos;
        Mice(miceiter).act(actiter,8)=atan2d(det([v1;v2]),dot(v1,v2));
    end



    Mice(miceiter).actcount=zeros(1,length(frameseg)-1);
    Mice(miceiter).interactiontime=zeros(1,length(frameseg)-1);
    Mice(miceiter).sumretreatspeed=zeros(1,length(frameseg)-1);
    Mice(miceiter).sumbodylengthindex=zeros(1,length(frameseg)-1);

    for actiter=1:length(Mice(miceiter).act)
        segpos=FindPosition(Mice(miceiter).act(actiter,2),frameseg);
        if segpos>0 && segpos<length(frameseg)
            Mice(miceiter).actcount(segpos)=1+Mice(miceiter).actcount(segpos);
            Mice(miceiter).interactiontime(segpos)=Mice(miceiter).act(actiter,5)+Mice(miceiter).interactiontime(segpos);
            Mice(miceiter).sumbodylengthindex(segpos)=Mice(miceiter).act(actiter,6)+Mice(miceiter).sumbodylengthindex(segpos);
            Mice(miceiter).sumretreatspeed(segpos)=Mice(miceiter).act(actiter,7)+Mice(miceiter).sumretreatspeed(segpos);
        end
    end

    Mice(miceiter).actcount_total=sum(Mice(miceiter).actcount);
    Mice(miceiter).interactiontime_total=sum(Mice(miceiter).interactiontime);

    Mice(miceiter).avetimeperinteraction_at=mean(Mice(miceiter).act(:,5));
    Mice(miceiter).avgretreatspeed_at=mean(Mice(miceiter).act(:,7));
    Mice(miceiter).avgbodylengthindex_at=mean(Mice(miceiter).act(:,6));


    Mice(miceiter).actcount_per_minute=Mice(miceiter).actcount./(timeseg(2:end)-timeseg(1:end-1));
    Mice(miceiter).time_per_interaction=Mice(miceiter).interactiontime./Mice(miceiter).actcount;
    Mice(miceiter).avgbodylengthindex=Mice(miceiter).sumbodylengthindex./Mice(miceiter).actcount;
    Mice(miceiter).avgretreatspeed=Mice(miceiter).sumretreatspeed./Mice(miceiter).actcount;

    cd ..
    cd ..
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ptotalactioncount=zeros(length(Mice),1);
Ptotalinteractiontime=zeros(length(Mice),1);
Pavetimeperinteraction_at=zeros(length(Mice),1);
Pavgretreatspeed_at=zeros(length(Mice),1);
Pavgbodylengthindex_at=zeros(length(Mice),1);

Pactcount_per_minute=zeros(length(Mice),length(frameseg)-1);
Ptime_per_interaction=zeros(length(Mice),length(frameseg)-1);
Pavgretreatspeed=zeros(length(Mice),length(frameseg)-1);
Pavgbodylengthindex=zeros(length(Mice),length(frameseg)-1);
ContextualAvsRangledis=[];
StimulusAvsRangledis=[];

for miceiter=1:length(Mice)
    Ptotalactioncount(miceiter,:)=Mice(miceiter).actcount_total;
    Ptotalinteractiontime(miceiter,:)=Mice(miceiter).interactiontime_total;
    Pavetimeperinteraction_at(miceiter,:)=Mice(miceiter).avetimeperinteraction_at;
    Pavgretreatspeed_at(miceiter,:)=Mice(miceiter).avgretreatspeed_at;
    Pavgbodylengthindex_at(miceiter,:)=Mice(miceiter).avgbodylengthindex_at;

    Pactcount_per_minute(miceiter,:)=Mice(miceiter).actcount_per_minute;
    Ptime_per_interaction(miceiter,:)=Mice(miceiter).time_per_interaction;
    Pavgretreatspeed(miceiter,:)=Mice(miceiter).avgretreatspeed;
    Pavgbodylengthindex(miceiter,:)=Mice(miceiter).avgbodylengthindex;

    if Mice(miceiter).novelty == 'C'
        ContextualAvsRangledis=[ContextualAvsRangledis Mice(miceiter).act(:,8)'];
    elseif Mice(miceiter).novelty == 'S'
        StimulusAvsRangledis=[StimulusAvsRangledis Mice(miceiter).act(:,8)'];
    else
        error('Novelty class not defined');
    end
end


Cnum=3;
Snum=3;

CVSXTick={'Contextual' 'Stimulus'};
CVSX=1:2;

IntersessionXTick={'0-2 min' '2-4 min' '4-6 min' '6-8 min' '8-10 min'};
IntersessionX=1:5;

mksize=80;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_total_interaction_count=figure('visible','off');

Plotdata=Ptotalactioncount;
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

legend('Contextual vs Stimulus',' ','Akb','Emp','Pie','Ana','Jab','Wed')
set(Plot_total_interaction_count, 'position', [0 0 500 800]);
ylim([0 50])
title('Interaction Count in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
ylabel('Interaction Count','FontSize',fsize)
xticks(CVSX);
xticklabels(CVSXTick);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_total_interaction_time=figure('visible','off');

Plotdata=Ptotalinteractiontime;
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

legend('Contextual vs Stimulus',' ','Akb','Emp','Pie','Ana','Jab','Wed')
set(Plot_total_interaction_time, 'position', [0 0 500 800]);
title('Total Interaction Time in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
ylabel('Time (s)','FontSize',fsize)
xticks(CVSX);
xticklabels(CVSXTick);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_time_per_interaction_at=figure('visible','off');

Plotdata=Pavetimeperinteraction_at;

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

legend('Contextual vs Stimulus',' ','Akb','Emp','Pie','Ana','Jab','Wed')
set(Plot_time_per_interaction_at, 'position', [0 0 500 800]);

title('Average time per interaction (all bouts) in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
ylabel('Time (s)','FontSize',fsize)
xticks(CVSX);
xticklabels(CVSXTick);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_interaction_count=figure('visible','off');

Plotdata=Pactcount_per_minute;

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
xlim([0.5 5.5]);


title('Interaction per minute in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
legend('Contextual','Stimulus','Akb','Emp','Pie','Ana','Jab','Wed')
ylabel('Interaction Count','FontSize',fsize)
xticks(IntersessionX);
xticklabels(IntersessionXTick);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_time_per_interaction=figure('visible','off');

Plotdata=Ptime_per_interaction;

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
xlim([0.5 5.5]);


title('Average time per interaction in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
legend('Contextual','Stimulus','Akb','Emp','Pie','Ana','Jab','Wed')
ylabel('Time (s)','FontSize',fsize)
xticks(IntersessionX);
xticklabels(IntersessionXTick);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_retreat_speed_at=figure('visible','off');

Plotdata=Pavgretreatspeed_at;

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

legend('Contextual vs Stimulus',' ','Akb','Emp','Pie','Ana','Jab','Wed')
set(Plot_retreat_speed_at, 'position', [0 0 500 800]);
ylim([0 100]);

title('Averaged retreat speed (all bouts) in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
ylabel('Speed  (cm/s)','FontSize',fsize)
xticks(CVSX);
xticklabels(CVSXTick);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_retreat_speed=figure('visible','off');

Plotdata=Pavgretreatspeed;

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
xlim([0.5 5.5]);


title('Averaged retreat speed in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
legend('Contextual','Stimulus','Akb','Emp','Pie','Ana','Jab','Wed')
ylabel('Speed  (cm/s)','FontSize',fsize)
xticks(IntersessionX);
xticklabels(IntersessionXTick);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_body_length_at=figure('visible','off');
Plotdata=Pavgbodylengthindex_at;
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

legend('Contextual vs Stimulus',' ','Akb','Emp','Pie','Ana','Jab','Wed')
title('Averaged body length index during interaction (all bouts) in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
ylabel('body length index    (length during interaction)/(average length)','FontSize',fsize)
xticks(CVSX);
xticklabels(CVSXTick);
set(Plot_body_length_at, 'position', [0 0 500 800]);
ylim([0.5 2]);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_body_length=figure('visible','off');

Plotdata=Pavgbodylengthindex;

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
xlim([0.5 5.5]);

title('Averaged body length index during interaction in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
legend('Contextual','Stimulus','Akb','Emp','Pie','Ana','Jab','Wed')
ylabel('body length index    (length during interaction)/(average length)','FontSize',fsize)
xticks(IntersessionX);
xticklabels(IntersessionXTick);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_AvsR_Angle=figure('visible','off');

csavg=[mean(ContextualAvsRangledis) mean(StimulusAvsRangledis)];
csstd=[std(ContextualAvsRangledis) std(StimulusAvsRangledis)];

bar(CVSX,csavg);
hold on
errorbar(CVSX,csavg,csstd,'.','LineWidth',2,'Color','black')
hold on

X1=ones(1,length(ContextualAvsRangledis));
X2=2.*ones(1,length(StimulusAvsRangledis));

scatter(X1,ContextualAvsRangledis,10,'Marker','d')
hold on 
scatter(X2,StimulusAvsRangledis,10,'Marker','d')

title('Averaged approach-retreat angle (all bouts) in first 10 min on novelty day 1 (ROTJ)','FontSize',fsize)
ylabel('Retreat angle (degree)','FontSize',fsize)
xticks(CVSX);
xticklabels(CVSXTick);
set(Plot_AvsR_Angle, 'position', [0 0 500 800]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plot_AvsR_Angle_dis=figure('visible','off');
diflen=length(ContextualAvsRangledis)-length(StimulusAvsRangledis);

if diflen>0
    Anglecompare(:,1)=ContextualAvsRangledis';
    Anglecompare(:,2)=[StimulusAvsRangledis 500.*ones(1,diflen)]';
else
    Anglecompare(:,1)=[ContextualAvsRangledis 500.*ones(1,abs(diflen))]';
    Anglecompare(:,2)=StimulusAvsRangledis';
end

hist(Anglecompare,15);
legend('Contextual','Stimulus')
xlim([-200 200]);
title('Approach-Retreat angle distribution')
xlabel('Approach-Retreat (degree)','FontSize',fsize)
ylabel('Count','FontSize',fsize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PolarDistribution=figure('visible','off');
stepsize=30;
AngleHistEdge=-180:stepsize:180;
ContextualAvsRangleHistCount=histcounts(ContextualAvsRangledis,AngleHistEdge);
StimulusAvsRangleHistCount=histcounts(StimulusAvsRangledis,AngleHistEdge);
PolarX=deg2rad([-180+(stepsize/2):stepsize:180-(stepsize/2) 180+stepsize/2]);
polarplot(PolarX,[ContextualAvsRangleHistCount ContextualAvsRangleHistCount(1)],'LineWidth',1.5);
hold on
polarplot(PolarX,[StimulusAvsRangleHistCount StimulusAvsRangleHistCount(1)],'LineWidth',1.5);
title('Approach-Retreat Angle Distribution','FontSize',fsize);
legend('Contextual','Stimulus');
%***********************************************************
% Save
% ***********************************************************

mkdir('EventBasedAnalysis')
cd('EventBasedAnalysis')

saveas(Plot_total_interaction_count,'Plot_total_interaction_count.png')
saveas(Plot_total_interaction_time,'Plot_total_interaction_time.png')
saveas(Plot_time_per_interaction_at,'Plot_time_per_interaction_at.png')
saveas(Plot_interaction_count,'Plot_interaction_count.png')
saveas(Plot_time_per_interaction,'Plot_time_per_interaction.png')
saveas(Plot_retreat_speed_at,'Plot_retreat_speed_at.png')
saveas(Plot_retreat_speed,'Plot_retreat_speed.png')
saveas(Plot_body_length_at,'Plot_body_length_at.png')
saveas(Plot_body_length,'Plot_body_length.png')
saveas(Plot_AvsR_Angle,'Plot_AvsR_Angle.png')
saveas(Plot_AvsR_Angle_dis,'Plot_AvsR_Angle_dis.png')
saveas(PolarDistribution,'Plot_AvsR_Angle_dis_polar.png')

save('Noveltyday1EventAnalysis.mat');
cd ..

clear
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Given an array of frame segment and a frame number 
% return the postion in the segment, if 
function IndexInArray=FindPosition(FrameNum,seg)
    IndexInArray=sum(FrameNum>seg);
end