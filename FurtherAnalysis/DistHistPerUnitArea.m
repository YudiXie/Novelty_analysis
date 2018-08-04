
pathname = cd;
PathRoot=[pathname '/'];
filelist=dir([PathRoot,'*.csv']);
flen = length(filelist);
cd Analyzed_Data;
load('Arena_Obj_Pos.mat');
tic;

fine_scale=1;        % fine scale for estimation
ppc=355./(2.*30.48); % pixels per cm
fps=30;              % video frame per second
frame_start=1;
frame_end=18000;

for fiter =1
    fn = filelist(fiter).name;
    disp(['Analyzing: ' fn]);
    load([filelist(fiter).name(1:32) '.mat'],'Labels');
    x_c=obj_center(fiter,1);
    y_c=obj_center(fiter,2);
    x_1=round(arena(fiter,1),0);
    y_1=round(arena(fiter,2),0);
    x_2=round(arena(fiter,3),0);
    y_2=round(arena(fiter,4),0);
    
    Distances=Labels(frame_start:frame_end,17);
    Locate=find(Distances>Labels(1,20));
    Distances(Locate)=[];
    [N,edges]=histcounts(Distances);
    bin_size=edges(2)-edges(1);
    dis=0.5.*(edges(2:end)+edges(1:end-1));


    for iter=1:length(N)
        % N_correct(iter)=N(iter)./area_weight_est(dis(iter),x_1,y_1,x_2,y_2,x_c,y_c,bin_size,fine_scale,ppc);
        N_correct(iter)=N(iter)./area_weight(dis(iter),x_1,y_1,x_2,y_2,x_c,y_c,ppc);
        %calculate number of frames spent per unit cm^2
    end
    N=N./fps;
    N_correct=N_correct./fps;

    
    % rawHist=figure(1);
    % hist(Labels(frame_start:frame_end,17));
    height=1.5;
    NHist=figure(2);
    plot(dis,N);
    title('Time spent at different distance');
    xlabel('distance (cm)');
    ylabel('time (s)');
    hold on
    xc_1=[1 1].*Labels(1,18);
    xc_2=[1 1].*Labels(1,19);
    xc_3=[1 1].*Labels(1,20);
    y=[0 height];
    plot(xc_1,y,xc_2,y,xc_3,y);


    NCHist=figure(3);
    plot(dis,N_correct)
    title('Time spent at different distance per cm^2');
    xlabel('distance (cm)');
    ylabel('time (s)');
    hold on
    xc_1=[1 1].*Labels(1,18);
    xc_2=[1 1].*Labels(1,19);
    xc_3=[1 1].*Labels(1,20);
    y=[0 height];
    plot(xc_1,y,xc_2,y,xc_3,y);


    WeightPlot=figure(4);
    for witer=1:length(dis)
        weights1(witer)=area_weight_est(dis(witer),x_1,y_1,x_2,y_2,x_c,y_c,bin_size,fine_scale,ppc);
        weights2(witer)=area_weight(dis(witer),x_1,y_1,x_2,y_2,x_c,y_c,ppc);
    end
    plot(dis,weights1,dis,weights2)
    legend('w1','w2');
    hold on
    xc_1=[1 1].*Labels(1,18);
    xc_2=[1 1].*Labels(1,19);
    xc_3=[1 1].*Labels(1,20);
    y=[0 height];
    plot(xc_1,y,xc_2,y,xc_3,y);


    % % ***********************************************************
    % % Save
    % % ***********************************************************
    % % pause

    % cd Analyzed_Data

    % mkdir([vn(1:end-4) '_Plots'])
    % cd([vn(1:end-4) '_Plots'])

    % saveas(Disfigure,['Distance_' vn(1:end-4) '.png'])
    % saveas(Angfigure,['Orientation_' vn(1:end-4) '.png'])
    % saveas(Hmfigure,['Heatmap_' vn(1:end-4) '.png'])
    % saveas(Trafigure,['Trajectory_' vn(1:end-4) '.png'])

    % cd ..

    % save(vn(1:end-4),'Labels','Dis_t_obj','Ang_t_obj');
    % close all
    % clearvars -except arena obj obj_center filelist fiter

    % cd ..

    toc;
end

cd ..



% Returning the weight for normalizing distance histogram
% It recieve (x1,y1) (x2,y2) the position of the upperleft and the bottom right corner of the arena
% (xc,yc) is the position of center of object
% r is the diatance to the object (in cm)
% returns a weight w,  it is acctually the part of perimeter of a circle which has r as radius and (xc,yc) as radius intersected by the arena
% 
% this function gernally apply, but it is not exact
% bin is the histogram diatance bin (in cm)
function w=area_weight_est(r,x1,y1,x2,y2,xc,yc,bin,finescale,ppc)
    dim1=abs(x1-x2).*finescale;
    dim2=abs(y1-y2).*finescale;
    M = zeros(dim1,dim2);
    for i=1:dim1
        for j=1:dim2
            diatance=sqrt((i-xc.*finescale).^2+(j-yc.*finescale).^2);
            rmdr=(r-(0.5.*bin)).*ppc.*finescale;
            rpdr=(r+(0.5.*bin)).*ppc.*finescale;
            if diatance>rmdr && diatance<rpdr
                M(i,j)=1;
            end
        end
    end
    w=sum(sum(M))./(finescale.^2.*ppc.^2);   % returns area (in cm^2) of the defined bin size
end



% Returning the weight for normalizing distance histogram
% It recieve (x1,y1) (x2,y2) the position of the upperleft and the bottom right corner of the arena
% (xc,yc) is the position of center of object
% r is the diatance to the object (cm)
% returns a weight w,  it is acctually the part of perimeter of a circle which has r as radius and (xc,yc) as radius intersected by the arena
% 
% this function does not gernally apply, only applys to those object is placed near one corner of the arena and near the diagonal line  (len(3)<len(4))
function w=area_weight(r,x1,y1,x2,y2,xc,yc,ppc)
    r=r.*ppc;
    len=[abs(xc-x1);
         abs(yc-y1);
         abs(xc-x2);
         abs(yc-y2);
         sqrt((xc-x1).^2+(yc-y1).^2);
         sqrt((xc-x2).^2+(yc-y2).^2);
         sqrt((xc-x1).^2+(yc-y2).^2);
         sqrt((xc-x2).^2+(yc-y1).^2);];
    len=sort(len);
    if r<0
        error('r<0 invalid input');
    elseif r>=0 && r<len(1)
        w = 2.*pi.*r;
    elseif r>=len(1) && r<len(2)
        w = 2.*pi.*r.*((2.*pi-2.*acos(len(1)./r))./(2.*pi));
    elseif r>=len(2) && r<len(3)
        w = 2.*pi.*r.*((2.*pi-2.*acos(len(1)./r)-2.*acos(len(2)./r))./(2.*pi));
    elseif r>=len(3) && r<len(4)
        w = 2.*pi.*r.*((2.*pi-acos(len(1)./r)-acos(len(2)./r)-0.5.*pi)./(2.*pi));
    elseif r>=len(4) && r<len(5)
        w = 2.*pi.*r.*((2.*pi-acos(len(1)./r)-acos(len(2)./r)-0.5.*pi-2.*acos(len(4)./r))./(2.*pi));
    elseif r>=len(5) && r<len(6)
        w = 2.*pi.*r.*((2.*pi-acos(len(1)./r)-acos(len(2)./r)-0.5.*pi-2.*acos(len(4)./r)-2.*acos(len(5)./r))./(2.*pi));
    elseif r>=len(6) && r<len(7)
        w = 2.*pi.*r.*((2.*pi-acos(len(2)./r)-pi-acos(len(4)./r)-2.*acos(len(5)./r))./(2.*pi));
    elseif r>=len(7) && r<len(8)
        w = 2.*pi.*r.*((2.*pi-1.5.*pi-acos(len(4)./r)-acos(len(5)./r))./(2.*pi));
    else 
        w=+Inf;
    end
    w=w./ppc;
end