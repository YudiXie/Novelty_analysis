% Now using a loop to generate image, by implementing matrix operation using index information in actalignedusage could improve speed
% when syllable index is -5 it is a 'none' type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PlotWidth=500;
BarHeight=5;
cmap=jet(100);
fps=30;
fsize=20;

AnalysisDay=3;      % first novelty day
G1_Mice=[1 2 3 4];
G2_Mice=[5 6 7 8];

load('MoSeqDataFrame.mat');
Mice_Index_path='/Users/yuxie/Dropbox/YuXie/CvsS_180831/CvsS_180831_MoSeq/Mice_Index.m';
run(Mice_Index_path);

trim_frame_start=1200;

AllActLabels=csvread('CvsS_poke_labels_N1.csv',1,2);
AllActLabels=AllActLabels-trim_frame_start;
AllActLabels(:,4)=(AllActLabels(:,3)-AllActLabels(:,1))./fps;

Mice(1).index=1;
for miceiter=2:length(Mice)
    Mice(miceiter).index=Mice(miceiter-1).index+Mice(miceiter-1).datanum;
    endindex=Mice(miceiter).index+Mice(miceiter).datanum;
end

if endindex ~= length(AllActLabels)+1
    error('index calculation error');
end

for miceiter=1:length(Mice)
    Mice(miceiter).ExpDay(AnalysisDay).act=AllActLabels(Mice(miceiter).index:Mice(miceiter).index+Mice(miceiter).datanum-1,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic

for miceiter=1:length(Mice)


    % find MSid index
    MSidindex=1;
    for indexiter=1:size(MoSeqDataFrame.session_uuid,1)
        if strcmp(MoSeqDataFrame.session_uuid(indexiter,:),Mice(miceiter).ExpDay(AnalysisDay).MSid)
            break
        end
        MSidindex=MSidindex+1;
        if MSidindex==size(MoSeqDataFrame.session_uuid,1)+1
            error('MSid not found');
        end
    end

    Labels=double(MoSeqDataFrame.labels{MSidindex});
    labellen=length(Labels);

    Mice(miceiter).ExpDay(AnalysisDay).rasterimage=uint8(255.*ones(20,PlotWidth,3));
    Mice(miceiter).ExpDay(AnalysisDay).rasterimage=insertText(Mice(miceiter).ExpDay(AnalysisDay).rasterimage,[round(PlotWidth./2-35,0),0],[Mice(miceiter).name '  Day: ' num2str(AnalysisDay)],'BoxOpacity',0,'TextColor','black');

    for actiter=1:Mice(miceiter).datanum

        framenum=Mice(miceiter).ExpDay(AnalysisDay).act(actiter,2);

        %Adding Syllable Bar
        middle_x=round(PlotWidth./2,0);
        middle_y=1;

        Syllableline=255.*ones(3,PlotWidth);

        for lineiter=1:PlotWidth
            rpos=lineiter-middle_x;


            plotframenum=framenum+rpos;

            if plotframenum<=0 || plotframenum>labellen
                syllableindex=-5;
            else
                syllableindex=Labels(plotframenum);
            end


            % Adding to a matrix actalignedusage that store all syllable usage around the labeled point
            % actalignedpoint is the labeled point
            Mice(miceiter).ExpDay(AnalysisDay).actalignedusage(actiter,lineiter)=syllableindex;
            Mice(miceiter).ExpDay(AnalysisDay).actalignedpoint(actiter)=middle_x;

            % Calculatiing syllabel color corrisponding to color map
            if syllableindex==-5
                syllablecolor=[0 0 0];
            elseif syllableindex<100 && syllableindex>=0
                syllablecolor=cmap(syllableindex+1,:);
            else
                error(['syllableindex out of bund, index=' num2str(syllableindex)]);
            end

            % Adding current position pointer in the raster plot
            if rpos>-1 && rpos<1
                syllablecolor=[1 0 0];
            end

            Syllableline(:,lineiter)=Syllableline(:,lineiter).*(syllablecolor');
        end

        barline=uint8(zeros(1,PlotWidth,3));
        barline(1,:,1)=Syllableline(1,:);
        barline(1,:,2)=Syllableline(2,:);
        barline(1,:,3)=Syllableline(3,:);

        Syllablebar=barline;
        for appenditer=1:BarHeight-1
            Syllablebar=cat(1,Syllablebar,barline);
        end
        Mice(miceiter).ExpDay(AnalysisDay).rasterimage=cat(1,Mice(miceiter).ExpDay(AnalysisDay).rasterimage,Syllablebar);
    end
end


% Calculating general usage only used when plot width is cosistent across mice
Generalactalignedusage=[];
for miceiter=1:length(Mice)
    Generalactalignedusage=cat(1,Generalactalignedusage,Mice(miceiter).ExpDay(AnalysisDay).actalignedusage);
end

% General act aligned syllable usage GAASU, 
% meaning GAASU(r , c) = count of syllable r-1 in all data at frame c
Syllablebinedge=[-6,-0.5:1:99.5];
GAASU=zeros(101,PlotWidth);
for lineiter =1:PlotWidth
    GAASU(:,lineiter)=(histcounts(Generalactalignedusage(:,lineiter),Syllablebinedge))';
end
GAASU(size(GAASU,1)+1,:)=GAASU(1,:);
GAASU(1,:)=[];

% Percentage usage
PGAASU=GAASU./size(Generalactalignedusage,1);

% % Accumulated act aligned syllable usage AAASU
% AAASU=GAASU;
% for rowiter=size(AAASU,1):-1:2
%     AAASU(rowiter,:)=sum(AAASU(1:rowiter,:));
% end

% Calculating Group1 Group2 usage only used when plot width is cosistent across mice
G1actalignedusage=[];
for miceiter=G1_Mice
    G1actalignedusage=cat(1,G1actalignedusage,Mice(miceiter).ExpDay(AnalysisDay).actalignedusage);
end

G2actalignedusage=[];
for miceiter=G2_Mice
    G2actalignedusage=cat(1,G2actalignedusage,Mice(miceiter).ExpDay(AnalysisDay).actalignedusage);
end

% Group1 act aligned syllable usage G1AASU,  
% meaning G1AASU(r , c) = count of syllable r-1 in all data at frame c
Syllablebinedge=[-6,-0.5:1:99.5];
G1AASU=zeros(101,PlotWidth);
for lineiter =1:PlotWidth
    G1AASU(:,lineiter)=(histcounts(G1actalignedusage(:,lineiter),Syllablebinedge))';
end
G1AASU(size(G1AASU,1)+1,:)=G1AASU(1,:);
G1AASU(1,:)=[];

% Percentage usage
PG1AASU=G1AASU./size(G1actalignedusage,1);


% Group2 act aligned syllable usage G2AASU,
% meaning G2AASU(r , c) = count of syllable r-1 in all data at frame c
G2AASU=zeros(101,PlotWidth);
for lineiter =1:PlotWidth
    G2AASU(:,lineiter)=(histcounts(G2actalignedusage(:,lineiter),Syllablebinedge))';
end
G2AASU(size(G2AASU,1)+1,:)=G2AASU(1,:);
G2AASU(1,:)=[];

% Percentage usage
PG2AASU=G2AASU./size(G2actalignedusage,1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Making plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timeline=((1:PlotWidth)-round(PlotWidth./2,0))./fps;

Plot_Gactalignedusage=figure;
Gareahandle=area(timeline,PGAASU','LineWidth',0.05);
% areahandle(82).FaceColor=cmap(82,:);
title('Syllable Usage Aligned by Human Labeled interaction','FontSize',fsize)
xlabel('Time (s)','FontSize',fsize)
ylabel('Usage Percentage','FontSize',fsize)
axis([timeline(1),timeline(end),0,1])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_G1actalignedusage=figure;
G1areahandle=area(timeline,PG1AASU','LineWidth',0.05);
title('Syllable Usage of Contextual Novelty Mice','FontSize',fsize)
xlabel('Time (s)','FontSize',fsize)
ylabel('Usage Percentage','FontSize',fsize)
axis([timeline(1),timeline(end),0,1])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Plot_G2actalignedusage=figure;
G2areahandle=area(timeline,PG2AASU','LineWidth',0.05);
title('Syllable Usage of Stimulus Novelty Mice','FontSize',fsize)
xlabel('Time (s)','FontSize',fsize)
ylabel('Usage Percentage','FontSize',fsize)
axis([timeline(1),timeline(end),0,1])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is for matching the syllable color with the color in the raster plot and labeled videos
% for coloriter=1:100
%     areahandle(coloriter).FaceColor=cmap(coloriter,:);
% end
% areahandle(101).FaceColor=[0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir('EventAlignedAnalysis')
cd('EventAlignedAnalysis')

% Saving raster plot
for miceiter=1:length(Mice)
    imwrite(Mice(miceiter).ExpDay(AnalysisDay).rasterimage,[Mice(miceiter).name '_interaction_raster_plot.png']);
end
cd ..
toc

