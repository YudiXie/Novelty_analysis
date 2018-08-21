AnalysisDay=3;      % first novelty day

Mice(1).datanum=26;
Mice(2).datanum=43;
Mice(3).datanum=40;
Mice(4).datanum=41;


Mice(1).name='Mal';
Mice(2).name='Wash';
Mice(3).name='Kaylee';
Mice(4).name='River';

Mice(1).novelty='S';
Mice(2).novelty='S';
Mice(3).novelty='S';
Mice(4).novelty='S';

AllActLabels=csvread('serenity_poke_labels_N1.csv',1,2);
AllActLabels(:,4)=(AllActLabels(:,3)-AllActLabels(:,1))./fps;