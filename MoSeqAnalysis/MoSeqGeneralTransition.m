load('GeneralUsage.mat')
nodename=regexp(sprintf('%i ',0:99),'(\d+)','match');

Group1Name='Contextual Novelty';
Group2Name='Stimulus Novelty';

fsize=20;
plotnodesize=1000;
plotedgewidth=1400;
compareplotedgewidth=40;

% edge thresholded by percentage usage
Generalthreshold=30.*1e-04;

% Nodes thresholded by usage
usageth=0.1.*1e-4;

% General transition of Group 1 and Group 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


PGBM_th=PGBM-PGBM.*(PGBM<Generalthreshold);
PG2BM_th=PG2BM-PG2BM.*(PGBM<Generalthreshold);
PG1BM_th=PG1BM-PG1BM.*(PGBM<Generalthreshold);

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

% filter by in and out degree
% for nodeiter=1:length(nodename)
%     if indegree(HTG,nodename(nodeiter))+outdegree(HTG,nodename(nodeiter))<1 && ...
%        indegree(NTG,nodename(nodeiter))+outdegree(NTG,nodename(nodeiter))<1
        
%         GTG=rmnode(GTG,nodename(nodeiter));
%         NTG=rmnode(NTG,nodename(nodeiter));
%         HTG=rmnode(HTG,nodename(nodeiter));
%         NHCompareG=rmnode(NHCompareG,nodename(nodeiter));
%     end
% end


nlen=length(nodename);
for nodeiter=1:nlen
    if GTG.Nodes.usage(findnode(GTG,nodename(nodeiter)))<usageth
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General transition of Group2
% Node size novelty usage
% Edge width coded by bigram transition probability of Group2
% Edge color coded by bigram transition probability on Group2
% Edge length invert related to bigram transition probability
% Transition threshold by transition probability
% Nodes threshold by usage
% Position initialized by circle, updated by force directed algorithm with gravity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

G2Transition=figure;
Plot_G2TG=plot(G2TG);
Plot_G2TG.LineWidth=plotedgewidth.*G2TG.Edges.Weight;
Plot_G2TG.MarkerSize=(plotnodesize.*G2TG.Nodes.usage)+1e-10;
Plot_G2TG.EdgeCData=G2TG.Edges.Weight;
Plot_G2TG.NodeColor=1.2.*[0, 0.4470, 0.7410];

% initial position
layout(Plot_G2TG,'circle')
X=Plot_G2TG.XData;
Y=Plot_G2TG.YData;
Z=Plot_G2TG.ZData;

layout(Plot_G2TG,'force','UseGravity',true,'XStart',X,'YStart',Y,'WeightEffect','inverse')

G2cb=colorbar;
G2cb.Label.String = 'Bigram Transition Probabillity';
G2cb.Label.FontSize=fsize;
colormap cool
title(['General Transition of' Group2Name 'Mice'],'FontSize',fsize)
set(G2Transition, 'position', [0 0 1000 850]);

X=Plot_G2TG.XData;
Y=Plot_G2TG.YData;
Z=Plot_G2TG.ZData;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General transition of Group1
% Node size habituation usage
% Edge width coded by bigram transition probability of Group1
% Edge color coded by bigram transition probability of Group1
% Transition threshold by transition probability
% Nodes threshold by usage
% Position initialized by circle, updated by force directed algorithm with gravity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

G1Transition=figure;
Plot_G1TG=plot(G1TG,'XData',X,'YData',Y);
Plot_G1TG.LineWidth=plotedgewidth.*G1TG.Edges.Weight;
Plot_G1TG.MarkerSize=(plotnodesize.*G1TG.Nodes.usage)+1e-10;
Plot_G1TG.EdgeCData=G1TG.Edges.Weight;
Plot_G1TG.NodeColor=1.2.*[0, 0.4470, 0.7410];

G1cb=colorbar;
G1cb.Label.String = 'Bigram Transition Probabillity';
G1cb.Label.FontSize=fsize;
colormap cool
title(['General Transition of' Group1Name 'Mice'],'FontSize',fsize)
set(G1Transition, 'position', [0 0 1000 850]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General transition comparison Novelty days vs Habituation days
% Node size general usage on both novelty and habituation days
% Edge width coded by bigram absolute value of transition probability comparison between Novelty and Habituation days
% Edge color coded by bigram transition probability comparison between Novelty and Habituation days
% Transition threshold by transition probability
% Nodes threshold by usage
% Position initialized by circle, updated by force directed algorithm with gravity
% Node color is red with novelty enriched syllables
% Node color is blue with habituation enriched syllables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

G2vsG1Transition=figure;
Plot_G2G1TG=plot(G2G1CompareG,'XData',X,'YData',Y);
Plot_G2G1TG.LineWidth=compareplotedgewidth.*abs(G2G1CompareG.Edges.Weight);
Plot_G2G1TG.MarkerSize=(plotnodesize.*G2G1CompareG.Nodes.usage)+1e-10;
Plot_G2G1TG.EdgeCData=G2G1CompareG.Edges.Weight;

upnodecolor=1.2*[0.6350, 0.0780, 0.1840];
downnodecolor=1.2.*[0, 0.4470, 0.7410];
for nodeiter=1:length(G2G1CompareG.Nodes.Name)
    if G2G1CompareG.Nodes.usagecmp(nodeiter)>0
        highlight(Plot_G2G1TG,nodeiter,'NodeColor',upnodecolor);
    else
        highlight(Plot_G2G1TG,nodeiter,'NodeColor',downnodecolor);
    end
end


G2G1cb=colorbar;
G2G1cb.Label.String = ['Bigram Transition Probabillity Comparison ' Group2Name ' vs.' Group1Name];
G2G1cb.Label.FontSize=fsize;
colormap cool
title(['General Transition Comparison' Group2Name ' vs ' Group1Name],'FontSize',fsize)
set(G2vsG1Transition, 'position', [0 0 1000 850]);