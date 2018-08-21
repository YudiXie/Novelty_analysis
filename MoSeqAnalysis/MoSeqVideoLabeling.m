tic
load('ModelData.mat')
Labels=MSLabels{14};
BarHeight=30;

vn='ff8c_Kaylee_N1.mp4';
Changepoint=(abs(Labels(2:end)-Labels(1:end-1))>0);
Changepoint=[Changepoint zeros(1,6)];
cmap=jet(100);

raw_video=VideoReader(vn);
final_video = VideoWriter([vn(1:end-4) '_Labeled.avi']);
final_video.FrameRate = raw_video.FrameRate;
open(final_video);
videolength=round(raw_video.Duration.*raw_video.FrameRate,0);

labellen=length(Labels);
if videolength~=labellen
    error('video and label mot match');
end

framenum = 1;
mywaitbar = waitbar(0,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
while hasFrame(raw_video)
    rawframe=readFrame(raw_video);

    finalframe=rawframe;
    %Adding text
    textpos = [0,100;    % Frame Number
               0,120;
               0,140;    % Syllable Number
               0,160;];

    insertedtext = {'Frame Number:';
                    num2str(framenum);
                    'Syllable';
                    num2str(Labels(framenum))};

    finalframe = insertText(finalframe,textpos,insertedtext,'BoxOpacity',0,'TextColor','white');

    %Adding Changepoint Notation

    if Changepoint(framenum)~=0 ||  Changepoint(framenum+1)~=0 || Changepoint(framenum+2)~=0
        finalframe = insertShape(finalframe,'Filledcircle',[40 90 10],'Color','Red');
        finalframe = insertShape(finalframe,'Filledcircle',[40 raw_video.Height-10 10],'Color','Red');
    end

    %Adding Syllable Bar
    
    middle_x=round(raw_video.Width./2,0);
    middle_y=raw_video.Height+1;

    Syllableline=255.*ones(3,raw_video.Width);
    for lineiter=1:raw_video.Width
        rpos=lineiter-middle_x;
        if rpos>-1 && rpos<1
            syllablecolor=[1 0 0];
        else
            plotframenum=framenum+rpos;

            if plotframenum<=0 || plotframenum>labellen
                syllableindex=-5;
            else
                syllableindex=Labels(plotframenum);
            end

            if syllableindex==-5
                syllablecolor=[0 0 0];
            elseif syllableindex<100 && syllableindex>=0
                syllablecolor=cmap(syllableindex+1,:);
            else
                error(['syllableindex out of bund, index=' num2str(syllableindex)]);
            end
        end

        Syllableline(:,lineiter)=Syllableline(:,lineiter).*(syllablecolor');
    end

    videoline=zeros(1,raw_video.Width,3);
    videoline(1,:,1)=Syllableline(1,:);
    videoline(1,:,2)=Syllableline(2,:);
    videoline(1,:,3)=Syllableline(3,:);

    Syllablebar=videoline;
    for appenditer=1:BarHeight-1
        Syllablebar=cat(1,Syllablebar,videoline);
    end

    finalframe=cat(1,finalframe,Syllablebar);
    writeVideo(final_video,finalframe);

    framenum = framenum + 1;
    waitbar(framenum/videolength,mywaitbar,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
end

close(mywaitbar);
close(final_video);
toc