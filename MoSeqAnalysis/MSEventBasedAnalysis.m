% Now using a loop to generate image, by implementing matrix operation using index information in actalignedusage could improve speed
% when syllable index is -5 it is a 'none' type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PlotWidth=500;
BarHeight=5;
cmap=jet(100);
fps=30;

AnalysisDay=3;      % first novelty day

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

AllActLabels=csvread('serenity_poke_labels_N1.csv',1,2);
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
load('ModelData.mat')

for miceiter=1:length(Mice)


    % find MSid index
    MSidindex=1;
    for indexiter=1:size(MSid,1)
        if strcmp(MSid(indexiter,:),Mice(miceiter).ExpDay(AnalysisDay).MSid)
            break
        end
        MSidindex=MSidindex+1;
        if MSidindex==size(MSid,1)+1
            error('MSid not found');
        end
    end

    Labels=MSLabels{MSidindex};
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


% Calculating general usage only used, when plot width is cosistent across mice
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Making plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timeline=((1:PlotWidth)-round(PlotWidth./2,0))./fps;

Plot_actalignedusage=figure(1);
areahandle=area(timeline,PGAASU');
areahandle(82).FaceColor=cmap(82,:);
title('Syllable Usage Aligned by Human Labeled interaction')
xlabel('Time (s)')
ylabel('Usage Percentage')
axis([timeline(1),timeline(end),0,1])


% for coloriter=1:100
%     areahandle(coloriter).FaceColor=cmap(coloriter,:);
% end
% areahandle(101).FaceColor=[0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir('EventBasedAnalysis')
cd('EventBasedAnalysis')

% Saving raster plot
for miceiter=1:length(Mice)
    imwrite(Mice(miceiter).ExpDay(AnalysisDay).rasterimage,[Mice(miceiter).name '_interaction_raster_plot.png']);
end
cd ..
toc

