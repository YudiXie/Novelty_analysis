load('MoSeqSynTest.mat')
sig=ch02;
LightOnFrame=[];
th=10;
for frameiter=1:length(tstep)-1
    readwin=[sig(frameiter) sig(frameiter+1)];
    if readwin(1)<th && readwin(2)>th
        LightOnFrame=[LightOnFrame;frameiter+1];
    end
end


% vn = 'rgb.mp4';
% raw_video=VideoReader(vn);
% final_video = VideoWriter([vn(1:end-4) '_Labeled.avi']);
% final_video.FrameRate = raw_video.FrameRate;
% open(final_video);
% videolength=round(raw_video.Duration.*raw_video.FrameRate);

% framenum = 1;
% h = waitbar(0,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
% while hasFrame(raw_video)
%     rawframe=readFrame(raw_video); 

%     %Adding text
%     textpos  = [10,10;    %Frame Number
%                 10,20;];
%     insertedtext = {'Frame Number:';
%                     num2str(framenum)};      
%     finalframe = insertText(rawframe,textpos,insertedtext,'BoxOpacity',0,'TextColor','white');

%     writeVideo(final_video,finalframe);
%     framenum = framenum + 1;

%     waitbar(framenum/videolength,h,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
% end
% close(h);
% close(final_video);
% close all
