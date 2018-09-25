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

figure;
for actiter=1:size(acttime,1)

    acttime_index=find(tstep>depthts(acttime(actiter)));
    acttime_index=acttime_index(1);

    Signal1=GCaMP(acttime_index-lenbef:acttime_index+lenaft);
    Signal2=tdTom(acttime_index-lenbef:acttime_index+lenaft);
    X=(0-lenbef):lenaft;

    subplot(ceil(size(acttime,1)/2),2,actiter)
    plot(X,Signal1,'Color','g')
    hold on
    plot(X,Signal2,'Color','r')

end




