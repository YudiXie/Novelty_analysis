% Note: Have not tested yet
% test before using it
vn = 'rgb.mp4';
disp(['Analyzing: ' vn]);

raw_video=VideoReader(vn);
final_video = VideoWriter([vn(1:end-4) '_Converted.avi']);
final_video.FrameRate = raw_video.FrameRate;
open(final_video);
videolength=round(raw_video.Duration.*raw_video.FrameRate);

framenum = 1;
h = waitbar(0,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
while hasFrame(raw_video)
    rawframe=readFrame(raw_video);     
    writeVideo(final_video,finalframe);
    framenum = framenum + 1;
    waitbar(framenum/videolength,h,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
end
close(h);
toc
close(final_video);