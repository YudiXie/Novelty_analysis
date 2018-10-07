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

1. Mannually label the position of the arena and object, using 
```
MarkObjPos.m
```
2. Calculate head position, speed, angle etc. Also plotting the trajectory, heatmap, etc. 
```
Analysis.m
```
3. Make labeled videos to check whether the labels are correct. This script generate labeled videos with a side bar showing the frame number, distance, orientation, speed, etc. for mannually label some interesting behaviors.
```
VideoLabeling.m
```

# Sample commands for using DeepLabCut and MoSeq

[Running an existing network (Korleki)](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/Using_DLC_in_UchidaLab_Korleki.md)

[Running an existing network (Mitsuko)](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/Using_DLC_in_UchidaLab_Mitsuko.md)

[Running an existing network (Sara & Eva)](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/Using_DLC_in_UchidaLab_Sara%26Eva.md)




[Training a New Network for DeepLabCut](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/Training_a_new_network.md)

[MoSeq Sample Commands](https://github.com/Rxie9596/Novelty_analysis/blob/master/Docs/MoSeq_Example_Command.md)

 
# Running on the cluster
#### DeepLabCut
1. Train a network locally, and copy the network to the cluster
2. Generate a singularity image based on docker image
3. Log in the cluster, Copy video to the cluster (/n/regal/uchida_lab)
4. start an interactive session with GPUs
5. oad modules and build singularity container
6, Point GPUs to different videos and start extraction


#### MoSeq
1. Log into the cluster
2. Start an interactive session
3. Install  and activate moseq2 conda environment
4. Install moseq packages
5. Use moseq2-batch to generate a shell script
6. Execute the shell script, start jobs inside an interactive session.


