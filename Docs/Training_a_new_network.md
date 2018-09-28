# Training a new neural network
#### Starting the docker environment
```
docker start yuxie_GPU1
docker exec -it yuxie_GPU1 /bin/bash
```
#### Starting the docker environment
0. Configuration of your project:

Edit `myconfig.py`
1. Selecting data to label:
```
cd Generating_a_Training_Set
python3 Step1_SelectRandomFrames_fromVideos.py
```
2. Label the frames:

 Using fiji: File > Import > Image Sequence > (check "virtual stack")

3. Formatting the data I:
```
python3 Step2_ConvertingLabels2DataFrame.py
```
4. Checking the formatted data:
```
python3 Step3_CheckLabels.py
```
5. Formatting the data II:
```
python3 Step4_GenerateTrainingFileFromLabelledData.py
```
6. Training the deep neural network:

If using for the first time, download a pretrained network:
```
 $ cd pose-tensorflow/models/pretrained
 $ ./download.sh
```
Copy the two folders generated from the last step to `/pose-tensorflow/models/`
```
$ cp -r YOURexperimentNameTheDate-trainset95shuffle1 ../pose-tensorflow/models/
$ cp -r UnaugmentedDataSet_YOURexperimentNameTheDate ../pose-tensorflow/models/
```
Start training
```
$ cd pose-tensorflow/models/data_set_name/train
$ TF_CUDNN_USE_AUTOTUNE=0 CUDA_VISIBLE_DEVICES=0 python3 ../../../train.py 
```
7. Evaluate your network:
```
$ CUDA_VISIBLE_DEVICES=0 python3 Step1_EvaluateModelonDataset.py #to evaluate your model [needs TensorFlow]
$ python3 Step2_AnalysisofResults.py  #to compute test & train errors for your trained model
```

# Analyzing videos
0. Configuration of your project:

Edit: `myconfig_analysis.py`

1. AnalyzingVideos:
```
$ CUDA_VISIBLE_DEVICES=0 python3 AnalyzeVideos.py
```
2. Making labeled videos
```
$ python3 MakingLabeledVideo.py
```