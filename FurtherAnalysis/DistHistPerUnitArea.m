fine_scale=1;        % fine scale for estimation
ppc=355./(2.*30.48); % pixels per cm
fps=30;              % video frame per second
frame_start=1000;
frame_end=19000;

AnalysisDay=3;
tic;

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

CDistances=[];
SDistances=[];
for miceiter=1:length(Mice)
    cd(Mice(miceiter).name);
    cd('Analyzed_Data');

    pathname = cd;
    PathRoot=[pathname '/'];
    filelist=dir([PathRoot,'*.mat']);
    flen = length(filelist);

    load('Arena_Obj_Pos.mat');
    load(filelist(AnalysisDay+1).name);


    x_c(miceiter)=obj_center(AnalysisDay,1);
    y_c(miceiter)=obj_center(AnalysisDay,2);
    x_1(miceiter)=arena(AnalysisDay,1);
    y_1(miceiter)=arena(AnalysisDay,2);
    x_2(miceiter)=arena(AnalysisDay,3);
    y_2(miceiter)=arena(AnalysisDay,4);
    
    if Mice(miceiter).novelty=='C'
        CDistances=[CDistances Labels(frame_start:frame_end,17)'];
    elseif Mice(miceiter).novelty=='S'
        SDistances=[SDistances Labels(frame_start:frame_end,17)'];
    end
    cd ..
    cd ..
end


dilusize=30;
x_c_avg=mean(x_c);
y_c_avg=mean(y_c);
x_1_avg=round(mean(x_1),0)-dilusize;
y_1_avg=round(mean(y_1),0)-dilusize;
x_2_avg=round(mean(x_2),0)+dilusize;
y_2_avg=round(mean(y_2),0)+dilusize;

cutoff=5;
Locate=find(CDistances>Labels(1,20)+cutoff);
CDistances(Locate)=[];
Locate=find(SDistances>Labels(1,20)+cutoff);
SDistances(Locate)=[];


disedges=0:2.5:70;
CN=histcounts(CDistances,disedges);
SN=histcounts(SDistances,disedges);
bin_size=disedges(2)-disedges(1);
dis=0.5.*(disedges(2:end)+disedges(1:end-1));


for iter=1:length(CN)
    % N_correct(iter)=N(iter)./area_weight_est(dis(iter),x_1,y_1,x_2,y_2,x_c,y_c,bin_size,fine_scale,ppc);
    CN_correct(iter)=CN(iter)./area_weight(dis(iter),x_1_avg,y_1_avg,x_2_avg,y_2_avg,x_c_avg,y_c_avg,bin_size,ppc);
    %calculate number of frames spent per unit cm^2
end


for iter=1:length(SN)
    % N_correct(iter)=N(iter)./area_weight_est(dis(iter),x_1,y_1,x_2,y_2,x_c,y_c,bin_size,fine_scale,ppc);
    SN_correct(iter)=SN(iter)./area_weight(dis(iter),x_1_avg,y_1_avg,x_2_avg,y_2_avg,x_c_avg,y_c_avg,bin_size,ppc);
    %calculate number of frames spent per unit cm^2
end

CN=CN./(fps.*length(Mice));
CN_correct=CN_correct./(fps.*length(Mice));

SN=SN./(fps.*length(Mice));
SN_correct=SN_correct./(fps.*length(Mice));



height=0.5;
fsize=16;

NHist=figure(1);
plot(dis,CN,'LineWidth',1.5);
hold on
plot(dis,SN,'LineWidth',1.5);
legend('Contextual','Stimulus');
title('Time spent at different distance','FontSize',fsize);
xlabel('Distance (cm)','FontSize',fsize);
ylabel('time (s)','FontSize',fsize);
hold on
xc_1=[1 1].*Labels(1,18);
xc_2=[1 1].*Labels(1,19);
xc_3=[1 1].*Labels(1,20);
y=[0 height];
plot(xc_1,y,xc_2,y,xc_3,y);


NCHist=figure(2);
p1=plot(dis,CN_correct,'LineWidth',1.5);
hold on
p2=plot(dis,SN_correct,'LineWidth',1.5);

title('Time spent at different distance per cm^2 (ROTJ) first 10 min','FontSize',fsize);
xlabel('Distance (cm)','FontSize',fsize);
ylabel('time (s)','FontSize',fsize);
hold on
xc_1=[1 1].*Labels(1,18);
xc_2=[1 1].*Labels(1,19);
xc_3=[1 1].*Labels(1,20);
y=[0 height];
plot(xc_1,y,xc_2,y,xc_3,y);
legend([p1 p2],'Contextual','Stimulus');


WeightPlot=figure(3);
for witer=1:length(dis)
    weights1(witer)=area_weight_est(dis(witer),x_1_avg,y_1_avg,x_2_avg,y_2_avg,x_c_avg,y_c_avg,bin_size,fine_scale,ppc);
    weights2(witer)=area_weight(dis(witer),x_1_avg,y_1_avg,x_2_avg,y_2_avg,x_c_avg,y_c_avg,bin_size,ppc);
end
plot(dis,weights1,dis,weights2)
legend('w1','w2');
hold on
xc_1=[1 1].*Labels(1,18);
xc_2=[1 1].*Labels(1,19);
xc_3=[1 1].*Labels(1,20);
y=[0 height];
plot(xc_1,y,xc_2,y,xc_3,y);



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
function w=area_weight(r,x1,y1,x2,y2,xc,yc,bin,ppc)
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
    w=(w.*bin)./ppc;
end