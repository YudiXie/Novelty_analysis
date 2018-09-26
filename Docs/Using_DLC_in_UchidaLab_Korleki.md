# Applying already trained network to new videos (for Korleki, Working Locally)
#### 1. Srating docker: 
Login the local computer, open a new terminal window check out if the docker container is running or not
```
docker ps
```
if you don't see the name `yuxie_GPU1`, that means the docker container is not running, you should start the docker container using this command.
```
docker start yuxie_GPU1
``` 

After starting the docker, run this to get inside the docker,
```
docker exec -it yuxie_GPU1 /bin/bash
```

you should see your prompt shows `root` rather than your user name now.

#### 2. Changing configuration files: 
For the new network trained for MoSeq Arena, Go to the following directory (you don't need to do this in the terminal): 
`/home/alex/Programs/DeepLabCut_new/DeepLabCut/` 
and you can find many configuration files. Open `myconfig_analysis (MoSeqNovelty_Retrain).py`, edit the `videopath` for you new videos, and save the changes. 


Rename this configeration file to `myconfig_analysis.py` and replace the existing file. Also save a copy of this file with name `myconfig_analysis (MoSeqNovelty_Retrain).py` for your future use.

#### 3. Start extraction
Go to `Analysis-tools` subfolder inside the DeepLabCut folder in the docker terminal
```
cd /home/alex/Programs/DeepLabCut_new/DeepLabCut/Analysis-tools
``` 
start extraction by running 
```
CUDA_VISIBLE_DEVICES=0 python3 AnalyzeVideos.py
```

To do this, all your video need to be directly placed under the directory you spcified in the configeration file.
If your videos are orgnized by mice names and experiment days:
* Mouse1
    * 180925
        * video1.mp4
    * 180926
        * video2.mp4
    * ...
* Mouse2
    * 180925
        * video3.mp4
    * 180926
        * video4.mp4
    * ...

you can run
```
CUDA_VISIBLE_DEVICES=0 python3 AnalyzeVideos_yuxie_180913_recursive.py
```
to traverse the subfolders.
If you orgnize your videos in different ways, you can refer to `AnalyzeVideos_yuxie_180913_recursive.py` and see sample code to do extraction recursively.
