%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BarHeight=30;
Dates={'180812','180813','180814','180815'};



Mice(1).name='Mal';
Mice(2).name='Wash';
Mice(3).name='Kaylee';
Mice(4).name='River';

Mice(1).novelty='S';
Mice(2).novelty='S';
Mice(3).novelty='S';
Mice(4).novelty='S';

% Mal:
Mice(1).ExpDay(1).MSid='e7ed0e85-149a-45d7-b40d-f56b73b3050c';  % H1
Mice(1).ExpDay(2).MSid='1a6cc63c-934a-4fb6-8c2f-b1e1616b9604';  % H2
Mice(1).ExpDay(3).MSid='af5e0790-8ffb-4fa1-86e4-614a4efae7d4';  % N1
Mice(1).ExpDay(4).MSid='a52bf424-0b9a-4195-8f9e-7b87abe5398c';  % N2

% Wash
Mice(2).ExpDay(1).MSid='1b21fd16-843d-40a2-a180-e885b618060d';  % H1
Mice(2).ExpDay(2).MSid='06232efa-884e-44f6-b3a2-b8ef949e2b14';  % H2
Mice(2).ExpDay(3).MSid='84ca42ce-f065-4298-a097-b18c49a7cbe1';  % N1
Mice(2).ExpDay(4).MSid='4b737026-c1ce-4e93-95b7-458e52259ad3';  % N2

% Kaylee
Mice(3).ExpDay(1).MSid='798b577a-1a84-453a-8dc3-aa020f26acf3';  % H1
Mice(3).ExpDay(2).MSid='fc9658f3-8614-42ad-9275-4037e37da9f9';  % H2
Mice(3).ExpDay(3).MSid='dd7ceaaf-ff8c-4a0e-a386-58698597cfcf';  % N1
Mice(3).ExpDay(4).MSid='08eaaec2-c507-4b3b-a822-79d531453937';  % N2

% River
Mice(4).ExpDay(1).MSid='d97fe1d2-4959-45bb-8da6-6166fd0300f4';  % H1
Mice(4).ExpDay(2).MSid='bb40083a-e633-498f-8397-b8e6ac91aa0a';  % H2
Mice(4).ExpDay(3).MSid='352262f2-2c47-420d-a8cc-debbac31061d';  % N1
Mice(4).ExpDay(4).MSid='45813819-f6e2-42eb-a5f7-763a87187996';  % N2



tic
load('ModelData.mat');
cd('SerenityVideos');

for miceiter=1:length(Mice)
    cd(Mice(miceiter).name);

    for dayiter=1:length(Mice(miceiter).ExpDay)
        cd(Dates{dayiter})
        % find MSid index
        MSidindex=1;
        for indexiter=1:size(MSid,1)
            if strcmp(MSid(indexiter,:),Mice(miceiter).ExpDay(dayiter).MSid)
                break
            end
            MSidindex=MSidindex+1;
            if MSidindex==size(MSid,1)+1
                error('MSid not found');
            end
        end

        Labels=MSLabels{MSidindex};

        vn='results_00.mp4';
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

        cd ..
    end

    cd ..
end
 cd ..