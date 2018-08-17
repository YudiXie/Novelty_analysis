% Only works when frame size is 420X520
% video labeling without side bar

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
radius = 50;     %radius pixels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path = cd;
PathRoot=[path '/'];
filelist=dir([PathRoot,'*.avi']);
flen = length(filelist);
for fiter =1:flen
    if ~isempty(strfind(filelist(fiter).name,'abeled'))
        filelist(fiter)=[];
    end
end
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
    final_video = VideoWriter([filelist(fiter).name(1:32) '_Labeled.avi']);
    final_video.FrameRate = raw_video.FrameRate;
    open(final_video);
    videolength=round(raw_video.Duration.*raw_video.FrameRate);

    framenum = 1;
    h = waitbar(0,[num2str(round(100*framenum/videolength)) '%' '    |    ' num2str(framenum) '/' num2str(videolength)]);
    while hasFrame(raw_video)
        rawframe=readFrame(raw_video); 
        sideframe=255*ones(420,100,3);
        finalframe = cat(2,rawframe,sideframe);

        %Adding text
        textpos  = [520,0;    %Frame Number
                    520,20;   %
                    520,40;   %Distance (cm)
                    520,60;   %
                    520,80;   %In radius
                    520,120;  %Orientation (d)
                    520,140;  %
                    520,160;  %Towards
                    520,200;  %x speed (cm/s)
                    520,220;  %
                    520,240;  %y speed (cm/s)
                    520,260;  %
                    520,280]; %legend
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
        finalframe = insertShape(finalframe,'Filledcircle',[590 90 10],'Color','Red');
        end
        if Labels(framenum,23)==1
        finalframe = insertShape(finalframe,'Filledcircle',[590 170 10],'Color','Red');
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
        finalframe = insertShape(finalframe,'Line',[530 370 610 370;570 330 570 410],'Color','Black');  % x y axis
        finalframe = insertShape(finalframe,'Line',[570 290 610 290],'Color','Black');  % legend

        finalframe = insertShape(finalframe,'Line',[570,370,570-Labels(framenum,24).*ppcs,370-Labels(framenum,25).*ppcs],'Color','Red');  % velosity
        
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