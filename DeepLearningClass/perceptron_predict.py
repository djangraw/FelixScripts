#!/usr/bin/env python

# Imports
import numpy as np
from keras.models import Input, Model
from keras.layers import Dense
from keras.callbacks import ModelCheckpoint

# Get data
num_samples = 10
num_weights = 10
seed = 7
np.random.seed(seed)
x_test  = np.random.uniform(-1, 1, (num_samples, num_weights))
y_test  = np.where(np.sum(x_test, axis=1) > 0, 1, 0)

# Define a model  
X = Input((num_weights,))
Z = Dense(1, input_dim=num_weights, activation='sigmoid')(X)
model = Model(inputs = X, outputs = Z)
model.compile(loss='mean_squared_error', optimizer='adam')

# Run the model on the data                      
model.load_weights("perceptron.h5")    
y = model.predict(x_test)
for i in range(0,num_samples):
    print("y, y_test=", int(round(y[i][0])), y_test[i])
