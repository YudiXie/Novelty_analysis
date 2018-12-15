%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Importing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'depth_ts.txt';

delimiter = ' ';

%% Format for each line of text:
%   column2: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*q%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
depthts = [dataArray{1:end-1}];
%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('MoSeqFP.mat');
acttime=csvread('NoveltyResponse.csv');
acttime=acttime+1; % labeled frame number start at 0 while depthts start at 1

GCaMP=ch00;
tdTom=ch01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clean photometry signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%remove 60Hz noise
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',58,'HalfPowerFrequency2',62, ...
               'DesignMethod','butter','SampleRate',1000);
filtered_GCaMP = filtfilt(d,GCaMP);
GCaMP = filtered_GCaMP;
filtered_tdTom = filtfilt(d,tdTom);
tdTom = filtered_tdTom;

%remove sudden rise noise

diff_GCaMP = diff(GCaMP);
std_GCaMP = std(diff_GCaMP);
ind_noise = find(diff_GCaMP>5*std_GCaMP);
exclude_green = size(ind_noise)

for i = 1:length(ind_noise)
    GCaMP(ind_noise(i))=GCaMP(ind_noise(i)-1);
    for k=1:1000
        if GCaMP(ind_noise(i)+k)-GCaMP(ind_noise(i)+k-1)>5*std_GCaMP
            GCaMP(ind_noise(i)+k) = GCaMP(ind_noise(i)+k-1);
        end
    end
end

diff_tdTom = diff(tdTom);
std_tdTom = std(diff_tdTom);
ind_noise = find(diff_tdTom>5*std_tdTom);
exclude_red = size(ind_noise)

for i = 1:length(ind_noise)
    tdTom(ind_noise(i))=tdTom(ind_noise(i)-1);
    for k=1:1000
        if tdTom(ind_noise(i)+k)-tdTom(ind_noise(i)+k-1)>5*std_tdTom
            tdTom(ind_noise(i)+k) = tdTom(ind_noise(i)+k-1);
        end
    end
end

%smoothing
normG = smooth(GCaMP,50);
GCaMP = normG;
normR = smooth(tdTom,50);
tdTom = normR;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trace average
plotWin = -4000:5000;

actlen=size(acttime,1);

acttime_index=zeros(actlen,1);
for actiter=1:actlen
    acttime_index(actiter,1)=find(tstep>depthts(acttime(actiter)),1,'first');
end

plotind = repmat(plotWin,length(acttime_index),1)+acttime_index;
rawTrace = GCaMP(plotind);
F = mean(rawTrace(:,1:1000),2);        %using this time window in plotwin for baseline
deltaF = rawTrace-F;
m_plot = mean(deltaF);
s_plot = std(deltaF)/sqrt(length(acttime_index));

R_rawTrace = tdTom(plotind);
R_F = mean(R_rawTrace(:,1:1000),2);        %using this time window in plotwin for baseline
R_deltaF = R_rawTrace-R_F;
R_m_plot = mean(R_deltaF);
R_s_plot = std(R_deltaF)/sqrt(length(acttime_index));

figure
errorbar_patch(plotWin,m_plot,s_plot,[0 1 0]);
errorbar_patch(plotWin,R_m_plot,R_s_plot,[1 0 0]);
title('GCaMP signals during approach-retreat')
legend('GCaMP','tdTom')
xlabel('time - point of retreat (ms)')
ylabel('signals dF/F')

% Response average trace for conparison
response = deltaF(:,4000:5000); %4000 is trigger
response = mean(response,2);
response = response';
ste_response = std(response)/sqrt(length(response));

% randon trace for conparison
randtime_index=round((rand(actlen,1).*0.8+0.1).*length(tstep),0);
randind = repmat(plotWin,length(randtime_index),1)+randtime_index;
rand_rawTrace = GCaMP(randind);
rand_F = mean(rand_rawTrace(:,1:1000),2);        %using this time window in plotwin for baseline
rand_deltaF = rand_rawTrace-rand_F;

rand_response = rand_deltaF(:,4000:5000); %4000 is trigger
rand_response = mean(rand_response,2);
rand_response = rand_response';
ste_rand_response = std(rand_response)/sqrt(length(rand_response));


X=1:2;
XTick={'Retreat Response' 'Random'};

figure
Yres=[mean(response) mean(rand_response)];
Yerr=[ste_response ste_rand_response];
bar(X,Yres)
hold on
errorbar(X,Yres,Yerr,'b.','LineWidth',1.5)
hold on
scatter(ones(1,actlen),response,'filled')
hold on
scatter(2.*ones(1,actlen),rand_response,'filled')
legend('GCaMP response','Standard Error');
title('GCaMP response')
ylabel('signals dF/F')
xticks(X);
xticklabels(XTick);


% raster plot green
scrsz = get(groot,'ScreenSize');
figure('Position',[1 scrsz(4)/1.5 scrsz(3)/1.5 scrsz(4)/1.5])
%1) bin the data
trialNum = size(deltaF,1); 
binSize = 100;
length_x = plotWin(end)-plotWin(1);
[sorted_response,sr_index]=sort(response','descend');
sorted_deltaF=deltaF(sr_index,:);
binedF = squeeze(mean(reshape(sorted_deltaF(:,1:length_x),trialNum, binSize,[]),2));
% imagesc(binedF,[-1 1]);
% imagesc(binedF,[-0.2 0.2]);
% imagesc(binedF,[-0.05 0.05]);
imagesc(binedF,[-0.15 0.15]);
colormap parula
colorbar
h=gca;
h.XTick = [0:10:(length_x/binSize)];
h.XTickLabel = {(plotWin(1)/1000):(plotWin(end)/1000)};
title('GCaMP signals during approach-retreat')
xlabel('time - point of retreat (s)');
hold on

% 2) plot the triggers
Xtri = [-plotWin(1)/binSize -plotWin(1)/binSize];
plot(Xtri,[0 trialNum+0.5],'r','LineWidth',2) 



function h = errorbar_patch(x,y,er,c)

    %ERRORBAR_PATCH    - errorbar by patch
    %
    % errorbar_patch(x,y,er,c)
    %
    %   input
    %     - x:    
    %     - y:    mean
    %     - er:    
    %     - color
    %     - N:          start y value for plot
    %     
    %   output
    %
    if nargin < 4
        c = [0 0 1];
    end
    
    if size(x,1)~= 1
        x = x';
    end
    
    if size(y,1)~= 1
        y = y';
    end
    
    if size(x,1)~= 1
        er = er';
    end
    
    X = [x fliplr(x)];
    Y = [y+er fliplr(y-er)];
    h1 = patch(X,Y,c,'edgecolor','none','FaceAlpha',0.2); hold on
    h2 = plot(x,y,'color',c,'LineWidth',1.5);
    set(get(get(h1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    if nargout>0
        h = [h1 h2]; 
    end
    
end    