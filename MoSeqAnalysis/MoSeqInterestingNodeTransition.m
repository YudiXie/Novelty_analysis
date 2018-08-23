load('GeneralUsage.mat')
nodename=regexp(sprintf('%i ',0:99),'(\d+)','match');

fsize=20;
plotnodesize=700;
plotedgewidth=2000;
compareplotedgewidth=10;

% Syllable 81 transition on Novelty and Habituation Day
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InterestingNodeThreshold=5.*1e-04;
PGBM_th=PGBM-PGBM.*(PGBM<InterestingNodeThreshold);
PNBM_th=PNBM-PNBM.*(PGBM<InterestingNodeThreshold);
PHBM_th=PHBM-PHBM.*(PGBM<InterestingNodeThreshold);

NHCompareM=(PNBM_th-PHBM_th)./(PNBM_th+PHBM_th);

GTG=digraph(PGBM_th,nodename);
GTG.Nodes.usage=PGUsage(2:end)';
GTG.Nodes.InOutDegree = indegree(GTG)+outdegree(GTG);

NTG=digraph(PNBM_th,nodename);
NTG.Nodes.usage=PNUsage(2:end)';
NTG.Nodes.InOutDegree = indegree(NTG)+outdegree(NTG);

HTG=digraph(PHBM_th,nodename);
HTG.Nodes.usage=PHUsage(2:end)';
HTG.Nodes.InOutDegree = indegree(HTG)+outdegree(HTG);

NHCompareG=digraph(NHCompareM,nodename);
NHCompareG.Nodes.usage=PGUsage(2:end)';
NHCompareG.Nodes.usagecmp=NvsHusage(2:end)';
NHCompareG.Nodes.InOutDegree = indegree(GTG)+outdegree(GTG);


for nodeiter=1:length(nodename)
    if indegree(HTG,nodename(nodeiter))+outdegree(HTG,nodename(nodeiter))<1 && ...
       indegree(NTG,nodename(nodeiter))+outdegree(NTG,nodename(nodeiter))<1
        
        GTG=rmnode(GTG,nodename(nodeiter));
        NTG=rmnode(NTG,nodename(nodeiter));
        HTG=rmnode(HTG,nodename(nodeiter));
        NHCompareG=rmnode(NHCompareG,nodename(nodeiter));
    end
end

elen=length(NHCompareG.Edges.Weight);
for edgeiter=elen:-1:1
    if isnan(NHCompareG.Edges.Weight(edgeiter))
        NHCompareG=rmedge(NHCompareG,edgeiter);
    end
end

Np81 = predecessors(NTG,'81');
Ns81 = successors(NTG,'81');

Hp81 = predecessors(HTG,'81');
Hs81 = successors(HTG,'81');

NHp81 = predecessors(NHCompareG,'81');
NHs81 = successors(NHCompareG,'81');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Syllable 81 transition on Novelty days
% Node size coded by novelty usage
% edge width coded by novelty transition probabitliy
% Node color coded by indegree+outdegree
% Edge color is red with in '81' transition
% Edge color is blue with out '81' transition
% Hightlighted in and out 81 transition
% Transition threshold by transition probability
% Nodes threshold by in and out degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Novelty81Transition=figure;
Plot_81NTG=plot(NTG);
Plot_81NTG.EdgeColor = 9.*[0.1 0.1 0.1];
Plot_81NTG.LineWidth=plotedgewidth.*NTG.Edges.Weight;
Plot_81NTG.MarkerSize=(plotnodesize.*NTG.Nodes.usage)+1e-10;
Plot_81NTG.NodeCData=NTG.Nodes.InOutDegree;

highlight(Plot_81NTG,Np81,'81','EdgeColor','b');
highlight(Plot_81NTG,'81',Ns81,'EdgeColor','r');
layout(Plot_81NTG,'circle','Center','81');

Ncb=colorbar;
Ncb.Label.String = 'indegree + outdegree';
Ncb.Label.FontSize=fsize;
colormap cool
title('Syllable 81 Transition on Novelty Day','FontSize',fsize)
set(Novelty81Transition, 'position', [0 0 1000 850]);

X=Plot_81NTG.XData;
Y=Plot_81NTG.YData;
Z=Plot_81NTG.ZData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Syllable 81 transition on Habituation days
% Use X Y Data from the former graph
% Node size coded by habituation usage
% edge width coded by habituation transition probabitliy
% Node color coded by indegree+outdegree
% Edge color is red with in '81' transition
% Edge color is blue with out '81' transition
% Hightlighted in and out 81 transition
% Transition threshold by transition probability
% Nodes threshold by in and out degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Habituation81Transition=figure;
Plot_81HTG=plot(HTG,'XData',X,'YData',Y);
Plot_81HTG.EdgeColor = 9.*[0.1 0.1 0.1];
Plot_81HTG.LineWidth=plotedgewidth.*HTG.Edges.Weight;
Plot_81HTG.MarkerSize=(plotnodesize.*HTG.Nodes.usage)+1e-10;
Plot_81HTG.NodeCData=HTG.Nodes.InOutDegree;

highlight(Plot_81HTG,Hp81,'81','EdgeColor','b');
highlight(Plot_81HTG,'81',Hs81,'EdgeColor','r');
% layout(Plot_81HTG,'circle','Center','81');

Hcb=colorbar;
Hcb.Label.String = 'indegree + outdegree';
Hcb.Label.FontSize=fsize;
colormap cool
title('Syllable 81 Transition on Habituation Day','FontSize',fsize)
set(Habituation81Transition, 'position', [0 0 1000 850]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Syllable 81 transition compare Novelty days vs Habituation days
% Use X Y Data from the former graph
% Node size coded by general usage
% Node color coded by Novelty Habituation usage comparison
% edge width coded by absolute usage change abs((N-H)/(N+H))
% Edge color is red with novelty entiched transition
% Edge color is blue with habituation enrichard transition
% Hightlighted in and out 81 transition
% Transition threshold by transition probability
% Nodes threshold by in and out degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NvsH81Transition=figure;
Plot_81NvsHTG=plot(NHCompareG,'XData',X,'YData',Y);
Plot_81NvsHTG.EdgeColor = 9.*[0.1 0.1 0.1];
Plot_81NvsHTG.LineWidth=compareplotedgewidth.*abs(NHCompareG.Edges.Weight);
Plot_81NvsHTG.MarkerSize=(plotnodesize.*NHCompareG.Nodes.usage)+1e-10;
Plot_81NvsHTG.NodeCData=NHCompareG.Nodes.usagecmp;

% Node color is red with novelty enriched syllables
% Node color is blue with habituation enriched syllables
% upnodecolor=[0.8500, 0.3250, 0.0980];
% downnodecolor=[0, 0.4470, 0.7410];
% for nodeiter=1:length(NHCompareG.Nodes.Name)
%     if NHCompareG.Nodes.usagecmp(nodeiter)>0
%         highlight(Plot_81NvsHTG,NHCompareG.Nodes.Name{nodeiter},'NodeColor',upnodecolor)
%     else
%         highlight(Plot_81NvsHTG,NHCompareG.Nodes.Name{nodeiter},'NodeColor',downnodecolor)
%     end
% end


for edgeiter=1:length(NHp81)
    if NHCompareG.Edges.Weight(findedge(NHCompareG,NHp81{edgeiter},'81'))>0
        highlight(Plot_81NvsHTG,'Edges',findedge(NHCompareG,NHp81{edgeiter},'81'),'EdgeColor','r')
    else
        highlight(Plot_81NvsHTG,'Edges',findedge(NHCompareG,NHp81{edgeiter},'81'),'EdgeColor','b')
    end
end

for edgeiter=1:length(NHs81)
    if NHCompareG.Edges.Weight(findedge(NHCompareG,'81',NHs81{edgeiter}))>0
        highlight(Plot_81NvsHTG,'Edges',findedge(NHCompareG,'81',NHs81{edgeiter}),'EdgeColor','r')
    else
        highlight(Plot_81NvsHTG,'Edges',findedge(NHCompareG,'81',NHs81{edgeiter}),'EdgeColor','b')
    end
end

NHcb=colorbar;
NHcb.Label.String = 'Habituation Enriched         Novelty Enriched';
NHcb.Label.FontSize=fsize;
colormap cool
title('Syllable 81 Transition Novelty/Habituation Comparison','FontSize',fsize)
set(NvsH81Transition, 'position', [0 0 1000 850]);