
vn='results_00.mp4';
raw_video=VideoReader(vn);
final_video = VideoWriter([vn(1:end-4) '_FP_Labeled.avi']);
final_video.FrameRate = raw_video.FrameRate;
open(final_video);
videolength=round(raw_video.Duration.*raw_video.FrameRate,0);

imageslen=55474;
imagesfile='/Users/yuxie/Downloads/Temp/';

framenum = 1;
mywaitbar = waitbar(0,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);

for frameiter=1:imageslen

    if ~hasFrame(raw_video)
        break
    end

    rawframe=readFrame(raw_video);

    sidebar1=uint8(255.*ones(494,65,3));
    finalframe=cat(2,sidebar1,rawframe);

    sidebar2=uint8(255.*ones(494,66,3));
    finalframe=cat(2,finalframe,sidebar2);

    FPbar=imread([imagesfile 'fig_' num2str(framenum) '.jpg']);
    finalframe=cat(1,finalframe,FPbar);

    writeVideo(final_video,finalframe);

    framenum = framenum + 1;
    waitbar(framenum/videolength,mywaitbar,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
end
close(mywaitbar);
close(final_video);