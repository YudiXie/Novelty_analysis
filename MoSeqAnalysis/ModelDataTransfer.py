# load in the model and the index to the extracted data
index_file = '/media/alex/DataDrive1/MoSeqData/CvsS_180831/CvsS_20180831_MoSeq/moseq2-index.yaml'
model_file = '/media/alex/DataDrive1/MoSeqData/CvsS_180831/CvsS_20180831_MoSeq/my_model.p'

# Save file directory
save_directory='/home/alex/Desktop/MoSeqDataFrame.mat'


import scipy.io as sio
import h5py
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from moseq2_viz.model.util import (get_transition_matrix,
                                   parse_model_results,
                                   relabel_by_usage)
from moseq2_viz.util import parse_index
from moseq2_viz.scalars.util import scalars_to_dataframe
from moseq2_viz.model.dist import get_behavioral_distance




model_results = parse_model_results(model_file)
index, sorted_index = parse_index(index_file)

# retrieves behavioral distance using AR matrices

dist = get_behavioral_distance(sorted_index, 
                               model_file, 
                               distances=['ar[init]'], 
                               max_syllable=None)

# packs data into a dataframe, including all scalars and model labels (note that -5 is a fill value, ignore for all downstream analysis)

df = scalars_to_dataframe(sorted_index, include_model=model_file)

sorted_labels = relabel_by_usage(model_results['labels'])[0]

save_dict=df.to_dict("list")
save_dict['syllable_dis']=dist['ar[init]']
save_dict['sorted_labels']=sorted_labels
save_dict['labels']=model_results['labels']
save_dict['session_uuid']=model_results['keys']

sio.savemat(save_directory, {'MoSeqDataFrame':save_dict})


############################################################################
# Old version
############################################################################
# import numpy
# import scipy.io as sio
# import joblib
# # import numpy
# # numpy.set_printoptions(threshold=numpy.nan)


# data = joblib.load('my_model.p')
# save_dict={'MSid':data['keys']}

# for saveiter in range(16):
#     print(saveiter)
#     MSlabels=data['labels'][0][saveiter][0]
#     print(type(MSlabels))
#     print(len(MSlabels))
#     print(MSlabels)
#     save_dict['MSlabels'+str(saveiter+1)]=MSlabels

# sio.savemat('/Users/yuxie/Desktop/my_model.mat', save_dict)
