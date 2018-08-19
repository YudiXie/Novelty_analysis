# loglikes
# labels
# keys
# heldout_ll
# model_parameters
#     kappa
#     gamma
#     alpha
#     nu
#     num_states
#     nu_0
#     sigma_0
#     kappa_0
#     nlags
#     mu_0
#     model_class
#     ar_mat
#     sig
# run_parameters
# metadata
# model
# hold_out_list
# train_list

import numpy
import scipy.io as sio
import joblib
# import numpy
# numpy.set_printoptions(threshold=numpy.nan)
data = joblib.load('my_model.p')
save_dict={'MSid':data['keys']}

for saveiter in range(16):
    print(saveiter)
    MSlabels=data['labels'][0][saveiter][0]
    print(type(MSlabels))
    print(len(MSlabels))
    print(MSlabels)
    save_dict['MSlabels'+str(saveiter+1)]=MSlabels

sio.savemat('/Users/yuxie/Desktop/my_model.mat', save_dict)
