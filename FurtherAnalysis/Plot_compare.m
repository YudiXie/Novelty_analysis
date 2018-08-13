
%XTick={'H1'	'H2'	'N1'	'N2'	'N3'	'N4'	'N5'	'N6'	'N7'	'N8'	'N9'	'N10'	'N11'	'N12'};
XTick={'H1'	'H2'	'N1'	'N2' 'N3'};
X=1:5;

% 1-3 rows are contextual novelty
% 4-6 rows are stimulus novelty

Y_dis=[1.22E-02	1.24E-02	3.44E-02	9.94E-03	4.50E-03;
2.19E-02	2.02E-02	5.42E-02	1.95E-02	2.71E-02;
2.33E-02	3.48E-02	2.24E-02	1.24E-02	1.28E-02;
1.77E-02	3.43E-02	6.89E-02	3.61E-02	9.89E-03;
2.67E-02	5.90E-02	2.62E-02	1.19E-02	1.11E-02;
3.91E-02	2.61E-02	2.33E-02	9.61E-03	6.83E-03;]

Y_ang=[3.54E-02	3.78E-02	1.01E-01	4.48E-02	2.91E-02;
5.52E-02	9.77E-02	7.86E-02	5.96E-02	5.00E-02;
5.43E-02	4.07E-02	7.73E-02	4.78E-02	4.01E-02;
3.51E-02	4.54E-02	6.53E-02	3.03E-02	2.05E-02;
6.26E-02	8.16E-02	8.94E-02	6.02E-02	2.51E-02;
4.42E-02	4.56E-02	4.62E-02	4.29E-02	2.46E-02;]



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
title('Time spent at obj in first 10 min (percentage) Radius=50 (8.6cm)')
ylabel('Percentage')
legend('Stimulus','Contextual')
xticks(X);
xticklabels(XTick);
axis([X(1)-0.5 X(end)+0.5 0 max(max(Y_dis))+0.1]);


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
axis([X(1)-0.5 X(end)+0.5 0 max(max(Y_ang))+0.1]);

saveas(disfig,'Distance_compare.png')
saveas(angfig,'Angle_compare.png')