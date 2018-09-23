import numpy as np
import scipy.io as sio

save_directory='/home/alex/Desktop/MoSeqFP.mat'
filename = '/media/alex/DataDrive1/MoSeqData/MSFP_Test/180922/session_20180922154525/nidaq.dat'
nch=3
dtype='<f8'
with open(filename, "rb") as file_read:
    dat = np.fromfile(file_read, dtype)

nidaq_dict = {}

for i in range(nch-1):
    nidaq_dict['ch{:02d}'.format(i)] = dat[i::nch]

nidaq_dict['tstep'] = dat[nch-1::nch]

sio.savemat(save_directory, nidaq_dict)