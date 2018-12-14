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
load('MoSeqDataFrame.mat');
load('MoSeqFP.mat');
ObjPos=[-200 -125];
totalcount=length(MoSeqDataFrame.model_label);

FSize=20;

MSid='7c39030c-3ec5-4366-ac15-513773fa5607';

MoSeqDataFrame.SODis=sqrt((MoSeqDataFrame.centroid_x_mm-ObjPos(1)).^2+(MoSeqDataFrame.centroid_y_mm-ObjPos(2)).^2);

FilteredXpos=[];
FilteredYpos=[];
FilteredSODis=[];
FilteredVel=[];

for frameiter=1:length(MoSeqDataFrame.SODis)
    if strcmp(MSid, MoSeqDataFrame.uuid(frameiter,:))
        FilteredXpos=[FilteredXpos double(MoSeqDataFrame.centroid_x_mm(frameiter))];
        FilteredYpos=[FilteredYpos double(MoSeqDataFrame.centroid_y_mm(frameiter))];
        FilteredSODis=[FilteredSODis MoSeqDataFrame.SODis(frameiter)];
        FilteredVel=[FilteredVel MoSeqDataFrame.velocity_3d_mm(frameiter)];
    end
end

len=length(tstep);
deplen=length(depthts);
Dis=zeros(1,len);
Vel=zeros(1,len);
depth_index=1;
for iter=1:len
    if depthts(depth_index)<tstep(iter)
        depth_index=depth_index+1;
    end
    if depth_index<=deplen
        Dis(iter)=FilteredSODis(depth_index);
        Vel(iter)=FilteredVel(depth_index);
    else
        break
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

acttime=csvread('NoveltyResponse.csv');
acttime=acttime+1; % labeled frame number start at 0 while depthts start at 1

GCaMP=ch00;
tdTom=ch01;

%remove 60Hz noise
d = designfilt('bandstopiir','FilterOrder',2, ...
 'HalfPowerFrequency1',58,'HalfPowerFrequency2',62, ...
 'DesignMethod','butter','SampleRate',1000);
filtered_GCaMP = filtfilt(d,GCaMP);
GCaMP = filtered_GCaMP;
filtered_tdTom = filtfilt(d,tdTom);
tdTom = filtered_tdTom;

GCaMP=GCaMP-mean(GCaMP);
tdTom=tdTom-mean(tdTom);
GCaMP=GCaMP-GCaMP(1);
tdTom=tdTom-tdTom(1);

lenbef=3000;
lenaft=4000;

% figure;
% for actiter=1:size(acttime,1)

%     acttime_index=find(tstep>depthts(acttime(actiter)));
%     acttime_index=acttime_index(1);

%     Signal1=GCaMP(acttime_index-lenbef:acttime_index+lenaft);
%     Signal2=tdTom(acttime_index-lenbef:acttime_index+lenaft);
%     Signal3=Dis(acttime_index-lenbef:acttime_index+lenaft);
%     Signal4=Vel(acttime_index-lenbef:acttime_index+lenaft);
%     X=(0-lenbef):lenaft;

%     subplot(ceil(size(acttime,1)/2),2,actiter)
%     plot(X,Signal1,'Color','g')
%     hold on
%     plot(X,Signal2,'Color','r')
%     hold on
%     plot(X,Signal4/50,'Color','m')
%     xlabel('time (ms)')
%     ylabel('signals dF/F')
%     % legend('GCaMP','tdTom','Velocity')
% end


tspan_start=210000;
tspan_end=350000;

Signal1=GCaMP(tspan_start:tspan_end);
Signal2=tdTom(tspan_start:tspan_end);
Signal4=Vel(tspan_start:tspan_end);
X=tstep-tstep(1);
X=X(tspan_start:tspan_end);
figure;
plot(X,Signal1,'Color','g')
hold on
plot(X,Signal2,'Color','r')
hold on
plot(X,Signal4/50+0.3,'Color','m')
xlabel('time (s)')
ylabel('signals dF/F | Speed/50+0.3 mm/s')
legend('GCaMP','tdTom','Velocity')


Signal3=Dis(tspan_start:tspan_end);
figure;
plot(X,Signal1,'Color','g')
hold on
plot(X,Signal2,'Color','r')
hold on
plot(X,Signal3/1000+0.3,'Color','b','LineWidth',1.5)
xlabel('time (s)')
ylabel('signals dF/F | Distance to Obj (m)')
legend('GCaMP','tdTom','Distance')



% % Plot trajectory
% Trafigure=figure();
% scatter(FilteredXpos,FilteredYpos,20);
% hold on
% scatter(-200,-125,'MarkerEdgeColor','r')
% % rectangle('Position',[arena(fiter,1),arena(fiter,2),arena(fiter,3)-arena(fiter,1),arena(fiter,4)-arena(fiter,2)],'EdgeColor','r','linewidth',4)
% % rectangle('Position',[obj(fiter,1),obj(fiter,2),obj(fiter,3)-obj(fiter,1),obj(fiter,4)-obj(fiter,2)],'EdgeColor','r','linewidth',4)
% %  set(gca,'ydir','reverse')
% % xlim([0 video_xlen]);
% % ylim([0 video_ywid]);
% % set(Trafigure, 'position', [0 0 1200 900]);














