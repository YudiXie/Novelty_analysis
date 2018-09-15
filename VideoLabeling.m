% Features shown on the videos:
% Frame number
% Distance to the object
% If in radius
% Orientation towards object
% If orientate towards the object
% x speed
% y speed
% speed plot

% Pending
% Dleta angle velocity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ppcs= 40/100;    %pixels per cm/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Config_NovAna;
path = cd;
PathRoot=[path '/'];
filelist=dir([PathRoot,'*' videoname_format(end-3:end)]);
flen = length(filelist);
for fiter =1:flen
    if ~isempty(strfind(filelist(fiter).name,'abeled'))
        filelist(fiter)=[];
    end
end
flen = length(filelist);
tic

for fiter =1:flen
    vn = filelist(fiter).name;
    matn = [vn(1:end-4) '.mat'];
    cd Analyzed_Data;
    load(matn);
    load('Arena_Obj_Pos.mat');
    cd ..
    disp(['Analyzing: ' vn]);

    raw_video=VideoReader(vn);
    final_video = VideoWriter([filelist(fiter).name(1:end-4) '_Labeled.avi']);
    final_video.FrameRate = raw_video.FrameRate;
    open(final_video);
    videolength=round(raw_video.Duration.*raw_video.FrameRate);

    framenum = 1;
    h = waitbar(0,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
    while hasFrame(raw_video)
        rawframe=readFrame(raw_video); 
        if raw_video.Height>420
            sideframe=255*ones(raw_video.Height,100,3);
            finalframe = cat(2,rawframe,sideframe);
        elseif raw_video.Height<420
            bottomframe=255*ones(420-raw_video.Height,raw_video.Width,3);
            sideframe=255*ones(420,100,3);
            finalframe = cat(1,rawframe,bottomframe);
            finalframe = cat(2,finalframe,sideframe);
        else
            sideframe=255*ones(420,100,3);
            finalframe = cat(2,rawframe,sideframe);
        end
    
        

        %Adding text
        textpos  = [raw_video.Width,0;    %Frame Number
                    raw_video.Width,20;   %
                    raw_video.Width,40;   %Distance (cm)
                    raw_video.Width,60;   %
                    raw_video.Width,80;   %In radius
                    raw_video.Width,120;  %Orientation (d)
                    raw_video.Width,140;  %
                    raw_video.Width,160;  %Towards
                    raw_video.Width,200;  %x speed (cm/s)
                    raw_video.Width,220;  %
                    raw_video.Width,240;  %y speed (cm/s)
                    raw_video.Width,260;  %
                    raw_video.Width,280]; %legend
        insertedtext = {'Frame Number:';
                        num2str(framenum);
                        'Distance (cm)';
                        num2str(Labels(framenum,17));
                        'In radius';
                        'Orientation (d)';
                        num2str(Labels(framenum,22));
                        'Towards';
                        'x speed (cm/s)';
                        num2str(Labels(framenum,24));
                        'y speed (cm/s)';
                        num2str(Labels(framenum,25));
                        '100cm/s'};      
        finalframe = insertText(finalframe,textpos,insertedtext,'BoxOpacity',0);

        if Labels(framenum,21)==1  
        finalframe = insertShape(finalframe,'Filledcircle',[raw_video.Width+70 90 10],'Color','Red');
        end
        if Labels(framenum,23)==1
        finalframe = insertShape(finalframe,'Filledcircle',[raw_video.Width+70 170 10],'Color','Red');
        end
        
        %Adding marker
        markerpos = [Labels(framenum,2) Labels(framenum,3);
                     Labels(framenum,5) Labels(framenum,6);
                     Labels(framenum,8) Labels(framenum,9);
                     Labels(framenum,11) Labels(framenum,12)];
        markercolor = {'red';      %Nose
                       'white';    %Leftear
                       'green';    %Rightear
                       'magenta'}; %Tailbase
        finalframe = insertMarker(finalframe,markerpos,'x','color',markercolor,'size',3);

        %Adding speed plot
        finalframe = insertShape(finalframe,'Line',[raw_video.Width+10 370 raw_video.Width+90 370;raw_video.Width+50 330 raw_video.Width+50 410],'Color','Black');  % x y axis
        finalframe = insertShape(finalframe,'Line',[raw_video.Width+60 290 raw_video.Width+100 290],'Color','Black');  % legend

        finalframe = insertShape(finalframe,'Line',[raw_video.Width+50,370,raw_video.Width+50-Labels(framenum,24).*ppcs,370-Labels(framenum,25).*ppcs],'Color','Red');  % velosity
        
        finalframe = insertShape(finalframe,'circle',[obj_center(fiter,1) obj_center(fiter,2) radius]);
        
        writeVideo(final_video,finalframe);
        framenum = framenum + 1;

        waitbar(framenum/videolength,h,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
    end
    close(h);
    toc
    close(final_video);
    close all
    clearvars -except filelist flen fiter ppcs radius
end