import joblib
import scipy.io as sio

model_data = joblib.load('my_model.p')
sio.savemat('my_model.mat', {'model_data':model_data})