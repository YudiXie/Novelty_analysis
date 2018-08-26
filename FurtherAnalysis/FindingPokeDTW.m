%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AnalysisDay=3;      % first novelty day
fps=30;

startframe=300;
endframe=21000;
Swindow=40;         % Smooth Window Size
DisThreshold=10;       % Distance threshold

Mice(1).datanum=32;
Mice(2).datanum=23;
Mice(3).datanum=30;
Mice(4).datanum=24;
Mice(5).datanum=17;
Mice(6).datanum=29;


Mice(1).name='C1_Akbar';
Mice(2).name='C2_Emperor';
Mice(3).name='C3_Piett';
Mice(4).name='S1_Anakin';
Mice(5).name='S2_Jabba';
Mice(6).name='S3_Wedge';

Mice(1).novelty='C';
Mice(2).novelty='C';
Mice(3).novelty='C';
Mice(4).novelty='S';
Mice(5).novelty='S';
Mice(6).novelty='S';


AllActLabels=csvread('ROTJManualLabels.csv',1,2);
AllActLabels(:,4)=(AllActLabels(:,3)-AllActLabels(:,1))./fps;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Mice(1).index=1;
for miceiter=2:length(Mice)
    Mice(miceiter).index=Mice(miceiter-1).index+Mice(miceiter-1).datanum;
    endindex=Mice(miceiter).index+Mice(miceiter).datanum;
end

if endindex ~= length(AllActLabels)+1
    error('index calculation error');
end


for miceiter=1:length(Mice)
    Mice(miceiter).act=AllActLabels(Mice(miceiter).index:Mice(miceiter).index+Mice(miceiter).datanum-1,:);
end

for miceiter=2
    cd(Mice(miceiter).name);
    cd('Analyzed_Data');

    pathname = cd;
    PathRoot=[pathname '/'];
    filelist=dir([PathRoot,'*.mat']);
    flen = length(filelist);

    load(filelist(AnalysisDay+1).name);

    % Distance
    Xtime=startframe:endframe;
    Dis=Labels(startframe:endframe,17);
    SDis=smoothdata(Labels(startframe:endframe,17),'rloess',Swindow);

    SDis_whole=smoothdata(Labels(:,17),'rloess',Swindow);
    DisMin=islocalmin(SDis_whole);

    % Derivative of Distance
    DisVelocity=diff(Labels(startframe:endframe,17)');
    DisVelocity=[0 DisVelocity];
    SDisVelocity=smoothdata(DisVelocity,'rloess',Swindow);

    Mice(miceiter).PokingLabels=[];

    windowiter=startframe;
    while windowiter<endframe
        if SDis_whole(windowiter)<DisThreshold
            minfound=0;
            for wpointer=1:length(Labels)
                if minfound==0
                    if DisMin(windowiter+wpointer)==1
                        minfound=1;
                        Mice(miceiter).PokingLabels=[Mice(miceiter).PokingLabels windowiter+wpointer];
                    end
                end
                if SDis_whole(windowiter+wpointer)>DisThreshold
                    break
                end
            end
            windowiter=windowiter+wpointer;
        end
        windowiter=windowiter+1;
    end



    DisPlot=figure(1);
    plot(Xtime/fps,SDis)
    hold on
    plot(Xtime/fps,Labels(startframe:endframe,18),'LineWidth',1.5)
    hold on
    plot(Xtime/fps,Labels(startframe:endframe,19),'LineWidth',1.5)
    hold on
    plot(Xtime/fps,Labels(startframe:endframe,20),'LineWidth',1.5)
    hold on
    scatter(Mice(miceiter).PokingLabels/fps,SDis_whole(Mice(miceiter).PokingLabels))


    DisPatchY=[0 70 70 0];
    for actiter=1:length(Mice(miceiter).act(:,1))
        hold on
        patch([Mice(miceiter).act(actiter,1) Mice(miceiter).act(actiter,1) Mice(miceiter).act(actiter,3) Mice(miceiter).act(actiter,3)]/fps,DisPatchY,[0.6 0.4 0.9],...
        'FaceAlpha',0.3, 'EdgeColor','none')
    end
    xlim([375 445])
    ylabel('Distance (cm)')
    xlabel('time (s)')

    VelPlot=figure(2);
    

    plot(Xtime/fps,SDisVelocity*fps);
    hold on
    plot(Xtime/fps,zeros(1,length(Xtime)),'LineWidth',1.5);
    DisPatchY=[-30 50 50 -30];

    for actiter=1:length(Mice(miceiter).act(:,1))
        hold on
        patch([Mice(miceiter).act(actiter,1) Mice(miceiter).act(actiter,1) Mice(miceiter).act(actiter,3) Mice(miceiter).act(actiter,3)]/fps,DisPatchY,[0.6 0.4 0.9],...
        'FaceAlpha',0.3, 'EdgeColor','none')
    end
    xlim([375 445])
    ylabel('Derivative of Distance cm/s')
    xlabel('time (s)')

    cd ..
    cd ..
end
