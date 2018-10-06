# Novelty Analysis
Matlab and Python code for novelty exploration behavior analysis in mice.
Used after [DeepLabCut](https://github.com/AlexEMG/DeepLabCut) and MoSeq analysis.

## Workflow
0. Edit configuration file 
```
Config_NovAna.m
```

Especially, use correct `networkname_format`, which is the network name after 'DeepLabCut' without extension. For example `DeepCut_resnet50_MoSeqNoveltySep12shuffle1_1030000`

Use correct `videoname_format`, an example file name of your videos, including the '.mp4' or '.avi' extensions. For example, `C4_180907_rgb.mp4`

* The following code need to be run directly under the folder containing all the videos and `.csv` files, if the videos are placed under subfolders use:`MoveFromDir.m`

1. First mannually label the position of the arena and object, using 
```
MarkObjPos.m
```
2. Secondly, calculate head position, speed, angle etc. Also plotting the trajectory, heatmap, etc. 
```
Analysis.m
```
3. Thirdly, make labeled videos,
```
VideoLabeling.m
```

# Sample commands for using DeepLabCut and MoSeq

[Running an existing network (Korleki)](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/Using_DLC_in_UchidaLab_Korleki.md)

[Running an existing network (Mitsuko)](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/Using_DLC_in_UchidaLab_Mitsuko.md)

[Running an existing network (Sara & Eva)](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/Using_DLC_in_UchidaLab_Sara%26Eva.md)




[Training a New Network for DeepLabCut](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/Training_a_new_network.md)

[MoSeq Sample Commands](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/MoSeq_Example_Command.md)
