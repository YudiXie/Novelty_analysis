
% XTick={'H1'	'H2'	'N1'	'N2'	'N3'	'N4'	'N5'	'N6'	'N7'	'N8'	'N9'	'N10'	'N11'	'N12'};
XTick={'H1'	'H2'	'N1'	'N2'};
X=1:4;
Y_dis=[1.21E-02	1.14E-02	3.46E-02	9.94E-03;
2.19E-02	1.96E-02	5.42E-02	2.03E-02;
2.37E-02	3.28E-02	2.29E-02	1.24E-02;
1.77E-02	3.39E-02	6.88E-02	3.64E-02;
2.64E-02	5.79E-02	2.61E-02	1.19E-02;
3.76E-02	2.58E-02	2.32E-02	9.61E-03;];

Y_ang=[3.53E-02	3.76E-02	1.01E-01	4.48E-02;
5.49E-02	9.69E-02	7.88E-02	6.11E-02;
5.72E-02	4.08E-02	7.70E-02	4.78E-02;
3.44E-02	4.60E-02	6.52E-02	3.03E-02;
6.19E-02	8.20E-02	8.88E-02	6.06E-02;
4.33E-02	4.57E-02	4.64E-02	4.28E-02;];

condavg=mean(Y_dis(1:3,:));
studavg=mean(Y_dis(4:6,:));

conaavg=mean(Y_ang(1:3,:));
stuaavg=mean(Y_ang(4:6,:));

condstd=std(Y_dis(1:3,:));
studstd=std(Y_dis(4:6,:));

conastd=std(Y_ang(1:3,:));
stuastd=std(Y_ang(4:6,:));


disfig=figure(1)
errorbar(X,studavg,studstd)
hold on
errorbar(X,condavg,condstd)
hold on
scatter(X,Y_dis(4,:),'Marker','o','MarkerFaceColor','b')
hold on
scatter(X,Y_dis(5,:),'Marker','o','MarkerFaceColor','b')
hold on
scatter(X,Y_dis(6,:),'Marker','o','MarkerFaceColor','b')
hold on
scatter(X,Y_dis(1,:),'Marker','o','MarkerFaceColor','r')
hold on
scatter(X,Y_dis(2,:),'Marker','o','MarkerFaceColor','r')
hold on
scatter(X,Y_dis(3,:),'Marker','o','MarkerFaceColor','r')
title('Time spent at obj in first 10 min (percentage) Radius=50')
ylabel('Percentage')
legend('Stimulus','Contextual')
xticks(X);
xticklabels(XTick);
axis([X(1)-0.5 X(end)+0.5 0 0.15]);


angfig=figure(2)
errorbar(X,stuaavg,stuastd)
hold on
errorbar(X,conaavg,conastd)
hold on
scatter(X,Y_ang(4,:),'Marker','o','MarkerFaceColor','b')
hold on
scatter(X,Y_ang(5,:),'Marker','o','MarkerFaceColor','b')
hold on
scatter(X,Y_ang(6,:),'Marker','o','MarkerFaceColor','b')
hold on
scatter(X,Y_ang(1,:),'MarkerFaceColor','r')
hold on
scatter(X,Y_ang(2,:),'Marker','o','MarkerFaceColor','r')
hold on
scatter(X,Y_ang(3,:),'Marker','o','MarkerFaceColor','r')

title('Orientation at obj in first 10 min (percentage) Radius=+-15 degree')
ylabel('Percentage')
legend('Stimulus','Contextual')
xticks(X);
xticklabels(XTick);
axis([X(1)-0.5 X(end)+0.5 0 0.15]);

saveas(disfig,'Distance_compare.png')
saveas(angfig,'Angle_compare.png')