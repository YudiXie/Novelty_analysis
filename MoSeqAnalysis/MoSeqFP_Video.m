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

GCaMP=GCaMP-mean(GCaMP);
tdTom=tdTom-mean(tdTom);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
len=length(tstep);
deplen=length(depthts);

GCaMP_v=zeros(1,deplen);
tdTom_v=zeros(1,deplen);

tstep_index=1;
for iter=1:deplen
    while tstep(tstep_index)<depthts(iter)
        tstep_index=tstep_index+1;
    end
    GCaMP_v(iter)=GCaMP(tstep_index);
    tdTom_v(iter)=tdTom(tstep_index);
end


nor_depthts=(depthts-depthts(1))';

plot_window_t=5;
plot_window=plot_window_t*30;
m_time=zeros(deplen,2.*plot_window+1);
m_sg1=zeros(deplen,2.*plot_window+1);
m_sg2=zeros(deplen,2.*plot_window+1);
for iter=1:deplen
    startfm=iter-plot_window;
    endfm=iter+plot_window;
    if startfm<1
        m_time(iter,:)=[nan(1,-startfm+1) nor_depthts(1:endfm)];
        m_sg1(iter,:)=[nan(1,-startfm+1) GCaMP_v(1:endfm)];
        m_sg2(iter,:)=[nan(1,-startfm+1) tdTom_v(1:endfm)];
    elseif endfm>deplen
        m_time(iter,:)=[nor_depthts(startfm:deplen) nan(1,endfm-deplen)];
        m_sg1(iter,:)=[GCaMP_v(startfm:deplen) nan(1,endfm-deplen)];
        m_sg2(iter,:)=[tdTom_v(startfm:deplen) nan(1,endfm-deplen)];
    else
        m_time(iter,:)=nor_depthts(startfm:endfm);
        m_sg1(iter,:)=GCaMP_v(startfm:endfm);
        m_sg2(iter,:)=tdTom_v(startfm:endfm);
    end
end

% legend('GCaMP','tdTom');
y_bound=[-0.2,0.4];
mywaitbar = waitbar(0,[num2str(round(100*0/deplen)) '%' '    |    ' num2str(0) '/' num2str(deplen)]);
figure('Position',[0 0 300 100],'visible','off');
for plotiter = 1:deplen
    plot(m_time(plotiter,:),m_sg1(plotiter,:),'Color','g')
    hold on
    plot(m_time(plotiter,:),m_sg2(plotiter,:),'Color','r')
    hold on
    plot([nor_depthts(plotiter),nor_depthts(plotiter)],[y_bound(1),y_bound(2)],'Color','m','LineWidth',1.5);
    axis([nor_depthts(plotiter)-plot_window_t nor_depthts(plotiter)+plot_window_t y_bound(1) y_bound(2)]);
    drawnow limitrate
    saveas(gcf,['/Users/yuxie/Downloads/Temp/fig_' num2str(plotiter) '.jpg']);
    clf
    waitbar(plotiter/deplen,mywaitbar,[num2str(round(100*plotiter/deplen)) '%' '    |    ' num2str(plotiter) '/' num2str(deplen)]);
end
close(mywaitbar);





% S1=animatedline('Color','g');
% S2=animatedline('Color','r');
% % legend('GCaMP','tdTom');

% plot_window=10;
% y_bound=[-0.2,0.4];
% for plotiter = 1:deplen
%     addpoints(S1,depthts(plotiter),GCaMP_v(plotiter));
%     % addpoints(S2,depthts(plotiter),tdTom_v(plotiter));
%     axis([depthts(plotiter)-plot_window depthts(plotiter)+plot_window y_bound(1) y_bound(2)]);
%     plot([],[],'Color','r');
%     drawnow limitrate
% end

% h = animatedline;
% axis([0,4*pi,-1,1])
% numpoints = 10000;
% x = linspace(0,4*pi,numpoints);
% y = sin(x);
% a = tic; % start timer
% for k = 1:numpoints
%     addpoints(h,x(k),y(k))
%     b = toc(a); % check timer
%     if b > (1/30)
%         drawnow % update screen every 1/30 seconds
%         a = tic; % reset timer after updating
%     end
% end
% drawnow % draw final frame