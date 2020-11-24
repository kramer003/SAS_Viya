from ayx import Alteryx
import tensorflow as tf
#https://www.tensorflow.org/tutorials/quickstart/beginner

mnist = tf.keras.datasets.mnist

(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0




model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(128, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10)
])


predictions = model(x_train[:1]).numpy()
predictions


import pandas as pd
df = pd.DataFrame({'prediction': [predictions]})
df = pd.DataFrame(predictions[0], columns=['test'])


Alteryx.write(df,1)

import numpy as np
x_test = np.load('x_test.npy')

Alteryx.installPackages('', install_type='freeze')

#No password and username
Alteryx.installPackages(package="<mypackage>",install_type="install --proxy proxy.server:port") 
#With password and username
Alteryx.installPackages(package="<mypackage>",install_type="install --proxy [user:passwd@]proxy.server:port") 