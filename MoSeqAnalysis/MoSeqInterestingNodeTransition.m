load('GeneralUsage.mat')
nodename=regexp(sprintf('%i ',0:99),'(\d+)','match');

Group1Name='Contextual Novelty';
Group2Name='Stimulus Novelty';

fsize=20;
plotnodesize=700;
plotedgewidth=2000;
compareplotedgewidth=10;

IntNode='70';

% edge thresholded by percentage usage
InterestingNodeThreshold=3.*1e-04;

% Interesting node transition of Group1 and Group2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PGBM_th=PGBM-PGBM.*(PGBM<InterestingNodeThreshold);
PG2BM_th=PG2BM-PG2BM.*(PGBM<InterestingNodeThreshold);
PG1BM_th=PG1BM-PG1BM.*(PGBM<InterestingNodeThreshold);

G2G1CompareM=(PG2BM_th-PG1BM_th)./(PG2BM_th+PG1BM_th);

GTG=digraph(PGBM_th,nodename);
GTG.Nodes.usage=PGUsage(2:end)';
GTG.Nodes.InOutDegree = indegree(GTG)+outdegree(GTG);

G2TG=digraph(PG2BM_th,nodename);
G2TG.Nodes.usage=PG2Usage(2:end)';
G2TG.Nodes.InOutDegree = indegree(G2TG)+outdegree(G2TG);

G1TG=digraph(PG1BM_th,nodename);
G1TG.Nodes.usage=PG1Usage(2:end)';
G1TG.Nodes.InOutDegree = indegree(G1TG)+outdegree(G1TG);

G2G1CompareG=digraph(G2G1CompareM,nodename);
G2G1CompareG.Nodes.usage=PGUsage(2:end)';
G2G1CompareG.Nodes.usagecmp=G2vsG1usage(2:end)';
G2G1CompareG.Nodes.InOutDegree = indegree(GTG)+outdegree(GTG);


for nodeiter=1:length(nodename)
    if indegree(G1TG,nodename(nodeiter))+outdegree(G1TG,nodename(nodeiter))<1 && ...
       indegree(G2TG,nodename(nodeiter))+outdegree(G2TG,nodename(nodeiter))<1
        
        GTG=rmnode(GTG,nodename(nodeiter));
        G2TG=rmnode(G2TG,nodename(nodeiter));
        G1TG=rmnode(G1TG,nodename(nodeiter));
        G2G1CompareG=rmnode(G2G1CompareG,nodename(nodeiter));
    end
end

elen=length(G2G1CompareG.Edges.Weight);
for edgeiter=elen:-1:1
    if isnan(G2G1CompareG.Edges.Weight(edgeiter))
        G2G1CompareG=rmedge(G2G1CompareG,edgeiter);
    end
end

G2pIntNode = predecessors(G2TG,IntNode);
G2sIntNode = successors(G2TG,IntNode);

G1pIntNode = predecessors(G1TG,IntNode);
G1sIntNode = successors(G1TG,IntNode);

G2G1pIntNode = predecessors(G2G1CompareG,IntNode);
G2G1sIntNode = successors(G2G1CompareG,IntNode);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interesting Node transition of Group2
% Node size coded by novelty usage
% edge width coded by novelty transition probabitliy
% Node color coded by indegree+outdegree
% Edge color is red with in IntNode transition
% Edge color is blue with out IntNode transition
% Hightlighted in and out IntNode transition
% Transition threshold by transition probability
% Nodes threshold by in and out degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

G2IntNodeTransition=figure;
Plot_IntNodeG2TG=plot(G2TG);
Plot_IntNodeG2TG.EdgeColor = 9.*[0.1 0.1 0.1];
Plot_IntNodeG2TG.LineWidth=plotedgewidth.*G2TG.Edges.Weight;
Plot_IntNodeG2TG.MarkerSize=(plotnodesize.*G2TG.Nodes.usage)+1e-10;
Plot_IntNodeG2TG.NodeCData=G2TG.Nodes.InOutDegree;

highlight(Plot_IntNodeG2TG,G2pIntNode,IntNode,'EdgeColor','b');
highlight(Plot_IntNodeG2TG,IntNode,G2sIntNode,'EdgeColor','r');
layout(Plot_IntNodeG2TG,'circle','Center',IntNode);

G2cb=colorbar;
G2cb.Label.String = 'indegree + outdegree';
G2cb.Label.FontSize=fsize;
colormap cool
title(['Syllable ' IntNode ' Transition, ' Group2Name ' Mice'],'FontSize',fsize)
set(G2IntNodeTransition, 'position', [0 0 1000 850]);

X=Plot_IntNodeG2TG.XData;
Y=Plot_IntNodeG2TG.YData;
Z=Plot_IntNodeG2TG.ZData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Syllable IntNode transition of Group1
% Use X Y Data from the former graph
% Node size coded by habituation usage
% edge width coded by habituation transition probabitliy
% Node color coded by indegree+outdegree
% Edge color is red with in IntNode transition
% Edge color is blue with out IntNode transition
% Hightlighted in and out IntNode transition
% Transition threshold by transition probability
% Nodes threshold by in and out degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

G1IntNodeTransition=figure;
Plot_IntNodeG1TG=plot(G1TG,'XData',X,'YData',Y);
Plot_IntNodeG1TG.EdgeColor = 9.*[0.1 0.1 0.1];
Plot_IntNodeG1TG.LineWidth=plotedgewidth.*G1TG.Edges.Weight;
Plot_IntNodeG1TG.MarkerSize=(plotnodesize.*G1TG.Nodes.usage)+1e-10;
Plot_IntNodeG1TG.NodeCData=G1TG.Nodes.InOutDegree;

highlight(Plot_IntNodeG1TG,G1pIntNode,IntNode,'EdgeColor','b');
highlight(Plot_IntNodeG1TG,IntNode,G1sIntNode,'EdgeColor','r');
% layout(Plot_IntNodeG1TG,'circle','Center',IntNode);

G1cb=colorbar;
G1cb.Label.String = 'indegree + outdegree';
G1cb.Label.FontSize=fsize;
colormap cool
title(['Syllable ' IntNode ' Transition, ' Group1Name ' Mice'],'FontSize',fsize)
set(G1IntNodeTransition, 'position', [0 0 1000 850]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Syllable IntNode transition compare Group2 vs Group1
% Use X Y Data from the former graph
% Node size coded by general usage
% Node color coded by Group2 vs Group1 usage comparison
% edge width coded by absolute usage change abs((G2-G1)/(G2+G1))
% Edge color is red with novelty entiched transition
% Edge color is blue with habituation enrichard transition
% Hightlighted in and out IntNode transition
% Transition threshold by transition probability
% Nodes threshold by in and out degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
G2vsG1IntNodeTransition=figure;
Plot_IntNodeG2vsG1TG=plot(G2G1CompareG,'XData',X,'YData',Y);
Plot_IntNodeG2vsG1TG.EdgeColor = 9.*[0.1 0.1 0.1];
Plot_IntNodeG2vsG1TG.LineWidth=compareplotedgewidth.*abs(G2G1CompareG.Edges.Weight);
Plot_IntNodeG2vsG1TG.MarkerSize=(plotnodesize.*G2G1CompareG.Nodes.usage)+1e-10;
Plot_IntNodeG2vsG1TG.NodeCData=G2G1CompareG.Nodes.usagecmp;

% Node color is red with novelty enriched syllables
% Node color is blue with habituation enriched syllables
% upnodecolor=[0.8500, 0.3250, 0.0980];
% downnodecolor=[0, 0.4470, 0.7410];
% for nodeiter=1:length(G2G1CompareG.Nodes.Name)
%     if G2G1CompareG.Nodes.usagecmp(nodeiter)>0
%         highlight(Plot_IntNodeG2vsG1TG,G2G1CompareG.Nodes.Name{nodeiter},'NodeColor',upnodecolor)
%     else
%         highlight(Plot_IntNodeG2vsG1TG,G2G1CompareG.Nodes.Name{nodeiter},'NodeColor',downnodecolor)
%     end
% end


for edgeiter=1:length(G2G1pIntNode)
    if G2G1CompareG.Edges.Weight(findedge(G2G1CompareG,G2G1pIntNode{edgeiter},IntNode))>0
        highlight(Plot_IntNodeG2vsG1TG,'Edges',findedge(G2G1CompareG,G2G1pIntNode{edgeiter},IntNode),'EdgeColor','r')
    else
        highlight(Plot_IntNodeG2vsG1TG,'Edges',findedge(G2G1CompareG,G2G1pIntNode{edgeiter},IntNode),'EdgeColor','b')
    end
end

for edgeiter=1:length(G2G1sIntNode)
    if G2G1CompareG.Edges.Weight(findedge(G2G1CompareG,IntNode,G2G1sIntNode{edgeiter}))>0
        highlight(Plot_IntNodeG2vsG1TG,'Edges',findedge(G2G1CompareG,IntNode,G2G1sIntNode{edgeiter}),'EdgeColor','r')
    else
        highlight(Plot_IntNodeG2vsG1TG,'Edges',findedge(G2G1CompareG,IntNode,G2G1sIntNode{edgeiter}),'EdgeColor','b')
    end
end

G2G1cb=colorbar;
G2G1cb.Label.String = [Group1Name ' Enriched         ' Group2Name ' Enriched'];
G2G1cb.Label.FontSize=fsize;
colormap cool
title(['Syllable ' IntNode ' Transition' Group2Name '/' Group1Name 'Comparison'],'FontSize',fsize)
set(G2vsG1IntNodeTransition, 'position', [0 0 1000 850]);