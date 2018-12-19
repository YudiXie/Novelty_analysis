#!/bin/bash

moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num16/session_20181130202457/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl
moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num22/session_20181130214357/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl
moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num24/session_20181130230028/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl
moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num25/session_20181201002148/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl
moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num30/session_20181130202514/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl
moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num31/session_20181130210235/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl
moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num33/session_20181130210309/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl
moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num36/session_20181130222257/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl
moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num37/session_20181130234116/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl
moseq2-extract extract /media/alex/DataDrive1/MoSeqData/Kaeser_Lab/181212/Exp/Num40/session_20181130214325/depth.dat --flip-classifier /home/alex/moseq2/flip_classifier_k2_c57_10to13weeks.pkl

moseq2-pca train-pca -c 6 -n 1
moseq2-pca apply-pca -c 6 -n 1
moseq2-pca compute-changepoints -c 6 -n 1
moseq2-model learn-model --kappa 539637 --save-model _pca/pca_scores.h5 my_model.p

moseq2-viz generate-index 
moseq2-viz add-group -k SubjectName -v "DRD_37mo_seq" -g "group2" moseq2-index.yaml
moseq2-viz plot-usages moseq2-index.yaml my_model.p --group group1 --group group2
moseq2-viz plot-usages moseq2-index.yaml my_model.p
moseq2-viz plot-scalar-summary moseq2-index.yaml
moseq2-viz plot-transition-graph moseq2-index.yaml my_model.p --group group1 --group group2
moseq2-viz make-crowd-movies --max-syllable 1000 --sort False moseq2-index.yaml my_model.p
