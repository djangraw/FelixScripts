#!/usr/bin/env python

# Imports
import numpy as np
from keras.models import Input, Model     
from keras.layers import Dense
from keras.callbacks import ModelCheckpoint

# Get data
num_samples = 1000
num_weights = 10
seed = 1
np.random.seed(seed)
x_train = np.random.uniform(-1, 1, (num_samples, num_weights))
y_train = np.where(np.sum(x_train, axis=1) > 0, 1, 0)

# Define a model  
X = Input((num_weights,)) 
Z = Dense(1, input_dim=num_weights, activation='sigmoid')(X)
model = Model(inputs = X, outputs = Z)
model.compile(loss='mean_squared_error', optimizer='sgd')

# Run the model on the data
checkpointer = ModelCheckpoint(filepath="perceptron.h5")
model.fit(x_train, y_train, epochs=100, callbacks=[checkpointer])

