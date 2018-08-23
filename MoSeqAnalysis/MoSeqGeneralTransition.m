load('GeneralUsage.mat')
nodename=regexp(sprintf('%i ',0:99),'(\d+)','match');

fsize=20;
plotnodesize=700;
plotedgewidth=1000;
compareplotedgewidth=20;

% General transition on Novelty and Habituation Day
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% edge thresholded by percentage usage

Generalthreshold=30.*1e-04;
PGBM_th=PGBM-PGBM.*(PGBM<Generalthreshold);
PNBM_th=PNBM-PNBM.*(PGBM<Generalthreshold);
PHBM_th=PHBM-PHBM.*(PGBM<Generalthreshold);

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

% Nodes thresholded by usage
usageth=3.*1e-4;
nlen=length(nodename);
for nodeiter=1:nlen
    if GTG.Nodes.usage(findnode(GTG,nodename(nodeiter)))<usageth
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General transtion on Novelty days
% Node size novelty usage
% Edge width coded by bigram transition probability on novelty days
% Edge color coded by bigram transition probability on novelty days
% Edge length invert related to bigram transition probability
% Transition threshoded by transition probability
% Nodes threshoded by usage
% Postion initialized by circle, updated by force directed algorithm with gravity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NoveltyTransition=figure;
Plot_NTG=plot(NTG);
Plot_NTG.LineWidth=plotedgewidth.*NTG.Edges.Weight;
Plot_NTG.MarkerSize=(plotnodesize.*NTG.Nodes.usage)+1e-10;
Plot_NTG.EdgeCData=NTG.Edges.Weight;
Plot_NTG.NodeColor=1.2.*[0, 0.4470, 0.7410];

% initial position
layout(Plot_NTG,'circle')
X=Plot_NTG.XData;
Y=Plot_NTG.YData;
Z=Plot_NTG.ZData;

layout(Plot_NTG,'force','UseGravity',true,'XStart',X,'YStart',Y,'WeightEffect','inverse')

Ncb=colorbar;
Ncb.Label.String = 'Bigram Transition Probabillity';
Ncb.Label.FontSize=fsize;
colormap cool
title('General Transition on Novelty Day','FontSize',fsize)
set(NoveltyTransition, 'position', [0 0 1000 850]);

X=Plot_NTG.XData;
Y=Plot_NTG.YData;
Z=Plot_NTG.ZData;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General transtion on Habituation days
% Node size habituation usage
% Edge width coded by bigram transition probability on habituation days
% Edge color coded by bigram transition probability on habituation days
% Transition threshoded by transition probability
% Nodes threshoded by usage
% Postion initialized by circle, updated by force directed algorithm with gravity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HabituationTransition=figure;
Plot_HTG=plot(HTG,'XData',X,'YData',Y);
Plot_HTG.LineWidth=plotedgewidth.*HTG.Edges.Weight;
Plot_HTG.MarkerSize=(plotnodesize.*HTG.Nodes.usage)+1e-10;
Plot_HTG.EdgeCData=HTG.Edges.Weight;
Plot_HTG.NodeColor=1.2.*[0, 0.4470, 0.7410];

Hcb=colorbar;
Hcb.Label.String = 'Bigram Transition Probabillity';
Hcb.Label.FontSize=fsize;
colormap cool
title('General Transition on Habituation Day','FontSize',fsize)
set(HabituationTransition, 'position', [0 0 1000 850]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General transtion comparison Novelty days vs Habituation days
% Node size general usage on both novelty and habituation days
% Edge width coded by bigram absolute value of transition probability comparison between Novelty and Habituation days
% Edge color coded by bigram transition probability comparison between Novelty and Habituation days
% Transition threshoded by transition probability
% Nodes threshoded by usage
% Postion initialized by circle, updated by force directed algorithm with gravity
% Node color is red with novelty enriched syllables
% Node color is blue with habituation enriched syllables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NvsHabituationTransition=figure;
Plot_NHTG=plot(NHCompareG,'XData',X,'YData',Y);
Plot_NHTG.LineWidth=compareplotedgewidth.*abs(NHCompareG.Edges.Weight);
Plot_NHTG.MarkerSize=(plotnodesize.*NHCompareG.Nodes.usage)+1e-10;
Plot_NHTG.EdgeCData=NHCompareG.Edges.Weight;

upnodecolor=1.2*[0.6350, 0.0780, 0.1840];
downnodecolor=1.2.*[0, 0.4470, 0.7410];
for nodeiter=1:length(NHCompareG.Nodes.Name)
    if NHCompareG.Nodes.usagecmp(nodeiter)>0
        highlight(Plot_NHTG,nodeiter,'NodeColor',upnodecolor);
    else
        highlight(Plot_NHTG,nodeiter,'NodeColor',downnodecolor);
    end
end


NHcb=colorbar;
NHcb.Label.String = 'Bigram Transition Probabillity Comparison Nov vs. Hab';
NHcb.Label.FontSize=fsize;
colormap cool
title('General Transition Comparison Novelty vs Habituation','FontSize',fsize)
set(NvsHabituationTransition, 'position', [0 0 1000 850]);