
XTick={'Stimulus' 'Contextual'};
X=1:2;
Contextual_count=[32 23 30];
Stimulus_count=[24 17 29];


conavg=mean(Contextual_count);
stuavg=mean(Stimulus_count);

avg=[conavg stuavg];

constd=std(Contextual_count);
stustd=std(Stimulus_count);

csstd=[constd stustd]


disfig=figure(1);
bar(X,avg)
hold on
errorbar(X,avg,csstd,'.','Marker','*')
hold on
scatter([1 1 1],Contextual_count,'filled','d')
hold on
scatter([1 1 1].*2,Stimulus_count,'filled','d')

title('Interaction Count in first 10 min on novelty day 1 ROTJ')
ylabel('Interaction Count')

xticks(X);
xticklabels(XTick);

% axis([X(1)-0.5 X(end)+0.5 0 40]);