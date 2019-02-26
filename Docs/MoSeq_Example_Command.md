# MoSeq Example Commands

You can use a shell script to do the following analysis automatically, there is a template
```
Shell_Script_Template.sh
```

1. Activate conda environment for MoSeq
```
source activate moseq2
```
2. Using MoSeq extract

* Basic extraction
```
moseq2-extract extract ~/Programs/MoSeq_videos/MoSeq_test/session_20180728154636/depth.dat
```
* Use a flip classifier

If you are using for the first time, download a flip classifier
```
moseq2-extract download-flip-file
```
* Extraction using a flip classifier and with increased dilation range.
```
moseq2-extract extract /path/to/data/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl --bg-roi-dilate 75 75 
```
* Use this when doing fiber photometry
```
moseq2-extract extract depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl --bg-roi-dilate 75 75 --use-tracking-model True --cable-filter-iters 1
```
* Trimming frames when the mouse is not in the arena, 

The relevant option is --frame-trim which is number of frames to trim from the beginning and from the end. To skip the first 500 and last 5000 frames,
```
moseq2-extract --frame-trim 500 5000 depth.dat --output-dir trim_test
```
For older version:

this is staged for the next version of moseq2-extract (v0.1.1). If you want to try now checkout the v0.1.1 branch (if it is already this version, skip this part)
```
cd ~/location_of_moseq2-extract/
git pull
git checkout v0.1.1
```

* to customize height, use `bg-roi-depth-range`

You may also need to change other parameters

Try out the defaults first.  If they don't work, the only filter you may want to turn down is the `tail` filter, try:

`--tail-filter-size 5, 5`

* When some mice in the experiments don't move very much during the entire trial, use this option to prevent it is excluded as background.
`--use-plane-bground`

3. Training PCA

First, go to the folder containing all your data. `moseq2-pca` analyze all your data inside the folder recursively

Specify the number of workers and cores to use.
* Without cable
```
moseq2-pca train-pca -c 6 -n 1
```
* use this when doing fiber photometry
```
moseq2-pca train-pca -c 6 -n 1 --missing-data
```

4. Apply PCA
```
moseq2-pca apply-pca -c 6 -n 1
```
5. Compute change points
```
moseq2-pca compute-changepoints -c 6 -n 1
```
6. Model learning

use`--save-model`to save the model parameters
* Set kappa to the total number of frames in your traning data set
```
moseq2-model learn-model --kappa 108843 --save-model _pca/pca_scores.h5 my_model.p
```
* Try to use the following options when training fails.
```
--whiten each
--robust
```

7. Use built-in visualization

First, generate index.
```
moseq2-viz generate-index 
```
* use `moseq2-viz add-group` to specify groups in the index. (you can also do that by editing the `moseq2-index.yaml` file directly. The following command add the "group1" label to four mice whose subject names are "mouse3", "mouse4", "mouse8", and "mouse100".

```
moseq2-viz add-group -k SubjectName -v "mouse3" -v "mouse4" -v "mouse8" -v "mouse100" -g "group1" moseq2-index.yaml
```
If you have another group (eg. group name "group2"), please use this command again to assign the corrisponding mice to "group2".

You can also add the group information by editing the `group` field in the `moseq2-index.yaml` file directly.


* plot the syllable usages for each group, for example, if you want to plot the usage for group1 and group2, please use the following command,
```
moseq2-viz plot-usages moseq2-index.yaml my_model.p --group group1 --group group2
```

if there is no group,
```
moseq2-viz plot-usages moseq2-index.yaml my_model.p
```

* plot the averaged velocity or height, etc. for each group
```
moseq2-viz plot-scalar-summary moseq2-index.yaml
```
* plot the transition graph
```
moseq2-viz plot-transition-graph moseq2-index.yaml my_model.p --group group1 --group group2
```

* making crowd movies.
```
moseq2-viz make-crowd-movies moseq2-index.yaml my_model.p
```
* use `--max-syllable` to specify the maximun number of syllables to generate, 
* Sometimes the lower part of the arena is not included in the crowd movies, use, for example `--raw-size 512 512`. 
* use `--sort False`, so that the syllables numbers generated correspond to model labels in the `my_model.p`file.
```
moseq2-viz make-crowd-movies  --max-syllable 1000 --raw-size 512 512 --sort False moseq2-index.yaml my_model.p
```

# Using MoSeq on a cluster

1. Start an interactivate session, activate moseq conda environment
```
srun --pty --mem=50G -n 20 -N 1 -p test,shared -t 60 bash
source activate moseq2
```

2. Go to the folder where you store your data
```
cd /n/regal/uchida_lab/yuxie/Serenity/Serenity_MoSeq
```

3. Sample commands
```
moseq2-extract extract  /n/regal/uchida_lab/yuxie/MoSeq_Testing/depth.dat 
moseq2-pca train-pca -n 10 -c 2
moseq2-pca train-pca --cluster-type slurm --queue test --wall-time 01:00:00 --nworkers 30 --timeout 5 -c 4 —-memory 30GB
moseq2-pca train-pca --cluster-type slurm --queue test --wall-time 01:00:00 --nworkers 30 --timeout 5 -c 4 —-memory 30GB
```

# Updating MoSeq
```
cd ~/location_of_moseq2-extract/
git pull
pip install something # follow the instuction on MoSeq2/docs
```
