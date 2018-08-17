
XTick={'H1'	'H2'	'N1'	'N2'	'N3'	'N4'	'N5'	'N6'	'N7'	'N8'	'N9'	'N10'	'N11'	'N12'};


% 1-3 rows are contextual novelty
% 4-6 rows are stimulus novelty

Y_dis=[0.0226666667	0.0091111111	0.0299444444	0.0453333333	0.0821666667	0.0513333333	0.0631111111	0.0626666667	0.0570555556	0.036	0.0305	0.046	0.0451666667	0.0636111111;
0.0188333333	0.0123333333	0.1467222222	0.0843333333	0.0858333333	0.0928333333	0.0566666667	0.0256111111	0.0645	0.086	0.0986111111	0.0602777778	0.03	0.0829444444;
0.0173888889	0.0293333333	0.1832222222	0.0732777778	0.0986666667	0.1905	0.1973333333	0.1200555556	0.1185	0.1745555556	0.0642777778	0.1025555556	0.056	0.0692222222;
0.0347777778	0.0192777778	0.0198888889	0.0082222222	0.0106111111	0.0062777778	0.0154444444	0.0179444444	0.0321111111	0.0382777778	0.0345555556	0.0753333333	0.0595555556	0.0344444444;
0.0230555556	0.0540555556	0.0050555556	0.0026666667	0.0035555556	0.0023333333	0.012	0.0062222222	0.0059444444	0.0038333333	0.0127777778	0.0079444444	0.0064444444	0.0338333333;
0.0262222222	0.0075555556	0.0262222222	0.0363888889	0.0221111111	0.0277222222	0.044	0.0358333333	0.0332777778	0.0229444444	0.0201111111	0.0169444444	0.0443333333	0.0287222222;];


Y_ang=[0.0434444444	0.062	0.0801111111	0.0912222222	0.0608333333	0.0642222222	0.0678888889	0.0637222222	0.0866111111	0.0537777778	0.0646111111	0.0901111111	0.0873333333	0.0829444444;
0.0255	0.0382777778	0.0921666667	0.0612222222	0.082	0.0754444444	0.0310555556	0.0337222222	0.0947222222	0.0555555556	0.1042222222	0.0876666667	0.0349444444	0.0454444444;
0.0304444444	0.0453888889	0.0993333333	0.0498888889	0.0628888889	0.0956666667	0.1246111111	0.0761666667	0.0931111111	0.0952777778	0.0612222222	0.0818888889	0.0624444444	0.1145;
0.0441111111	0.0341111111	0.0807777778	0.0593333333	0.0346111111	0.037	0.0398333333	0.0391111111	0.0552222222	0.0575	0.05	0.055	0.0487222222	0.0451111111;
0.0668888889	0.0798888889	0.1758888889	0.0786666667	0.104	0.1104444444	0.0599444444	0.0604444444	0.0621111111	0.0788888889	0.0568333333	0.096	0.1189444444	0.067;
0.0312222222	0.0401666667	0.0814444444	0.0788333333	0.0354444444	0.0331666667	0.0443888889	0.0391111111	0.0775555556	0.0762777778	0.0471666667	0.0445	0.0675	0.0480555556;];


XTick=XTick(1:length(Y_dis(1,:)));
X=1:length(Y_dis(1,:));



condavg=mean(Y_dis(1:3,:));
studavg=mean(Y_dis(4:6,:));

conaavg=mean(Y_ang(1:3,:));
stuaavg=mean(Y_ang(4:6,:));

condstd=std(Y_dis(1:3,:));
studstd=std(Y_dis(4:6,:));

conastd=std(Y_ang(1:3,:));
stuastd=std(Y_ang(4:6,:));


disfig=figure(1);
errorbar(X,condavg,condstd)
hold on
errorbar(X,studavg,studstd)
hold on
scatter(X,Y_dis(1,:),'Marker','o','MarkerFaceColor','b','LineWidth',1)
hold on
scatter(X,Y_dis(2,:),'Marker','o','MarkerFaceColor','b','LineWidth',1)
hold on
scatter(X,Y_dis(3,:),'Marker','o','MarkerFaceColor','b','LineWidth',1)
hold on
scatter(X,Y_dis(4,:),'Marker','o','MarkerFaceColor','r','LineWidth',1)
hold on
scatter(X,Y_dis(5,:),'Marker','o','MarkerFaceColor','r','LineWidth',1)
hold on
scatter(X,Y_dis(6,:),'Marker','o','MarkerFaceColor','r','LineWidth',1)

title('Time spent at obj in first 10 min (percentage) Radius=50 (8.6cm)')
ylabel('Percentage')
legend('Contextual','Stimulus','Lei','Luk','Obi','Dar','Han','R2D')
xticks(X);
xticklabels(XTick);
axis([X(1)-0.5 X(end)+0.5 0 max(max(Y_dis))+0.03]);



angfig=figure(2);
errorbar(X,conaavg,conastd)
hold on
errorbar(X,stuaavg,stuastd)
hold on
scatter(X,Y_ang(1,:),'Marker','o','MarkerFaceColor','b','LineWidth',1)
hold on
scatter(X,Y_ang(2,:),'Marker','o','MarkerFaceColor','b','LineWidth',1)
hold on
scatter(X,Y_ang(3,:),'Marker','o','MarkerFaceColor','b','LineWidth',1)
hold on
scatter(X,Y_ang(4,:),'Marker','o','MarkerFaceColor','r','LineWidth',1)
hold on
scatter(X,Y_ang(5,:),'Marker','o','MarkerFaceColor','r','LineWidth',1)
hold on
scatter(X,Y_ang(6,:),'Marker','o','MarkerFaceColor','r','LineWidth',1)

title('Orientation at obj in first 10 min (percentage) Radius=+-15 degree')
ylabel('Percentage')
legend('Contextual','Stimulus','Lei','Luk','Obi','Dar','Han','R2D')
xticks(X);
xticklabels(XTick);
axis([X(1)-0.5 X(end)+0.5 0 max(max(Y_ang))+0.03]);

saveas(disfig,'Distance_compare.png')
saveas(angfig,'Angle_compare.png')