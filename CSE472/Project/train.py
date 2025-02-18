import keras

from keras.applications import resnet50
from keras.preprocessing.image import ImageDataGenerator
from keras.callbacks import CSVLogger, ModelCheckpoint, EarlyStopping
from keras.callbacks import ReduceLROnPlateau
from keras import backend as K
from keras.layers import Flatten,Dense,Dropout
from keras.models import Sequential
from keras import optimizers
from keras.models import model_from_json
import numpy as np
import os
import importlib, importlib.util, os.path


def TrainModel(resnet_conv,learning_rate,dropout_rate=0.5,activation_function='softmax',optimizer='Adam',denselayer_size=1024,train_conv_layer=10):


    img_width, img_height = 224, 224
    num_channels = 3
    num_classes = 7
    # train_data = 'fer2013/Training1'
    # valid_data = 'fer2013/PublicTest1'
    train_data ='drive/COLAB_NOTEBOOKS/sample/Training1'
    valid_data = 'drive/COLAB_NOTEBOOKS/sample/PublicTest1'

    verbose = 1
    batch_size = 32
    num_epochs =1 #10000
    patience = 50
    log_file_path = './logs/training.log'
    trained_models_path = 'models/model'

    for layer in resnet_conv.layers[:-train_conv_layer]:
        layer.trainable = False



    model = Sequential()
    model.add(resnet_conv)

    model.add(Flatten())


    model.add(Dense(denselayer_size, activation='relu'))
    model.add(Dropout(dropout_rate))
    model.add(Dense(denselayer_size, activation='relu'))
    model.add(Dropout(dropout_rate))

    model.add(Dense(int(denselayer_size/2), activation='relu'))
    model.add(Dropout(dropout_rate/2.0))
    model.add(Dense(int(denselayer_size/2), activation='relu'))
    model.add(Dropout(dropout_rate/4.0))
    
    model.add(Dense(7, activation=activation_function))


    opt = None
    if(optimizer=="Adam"):
        opt = optimizers.Adam(lr = learning_rate)
    elif(optimizer=="SGD"):
        opt = optimizers.SGD(lr = learning_rate)
    elif(optimizer == "RMSprop"):
        opt = optimizers.RMSprop(lr = learning_rate)




    model.compile(optimizer=opt, loss='categorical_crossentropy', metrics=['accuracy'])


    print(model.summary())



    print("Resnet Model Weights loaded")

    # prepare data augmentation configuration
    train_data_gen = ImageDataGenerator(rescale=1.0/255,
                                        featurewise_center=False,
                                        featurewise_std_normalization=False,
                                        rotation_range=10,
                                        width_shift_range=0.1,
                                        height_shift_range=0.1,
                                        zoom_range=0.1,
                                        horizontal_flip=True)
    valid_data_gen = ImageDataGenerator(rescale=1.0/255)
    valid_generator = valid_data_gen.flow_from_directory(valid_data, (img_width, img_height), batch_size=batch_size,class_mode='categorical')


    # callbacks
    tensor_board = keras.callbacks.TensorBoard(log_dir='./logs', histogram_freq=0, write_graph=True, write_images=True)
    
    csv_logger = CSVLogger(log_file_path, append=False)
    early_stop = EarlyStopping('val_acc', patience=patience)
    reduce_lr = ReduceLROnPlateau('val_acc', factor=0.1, patience=int(patience / 4), verbose=1)
    
    # model_names = str(trained_models_path) +'_'+str(activation_function)+'_'+str(learning_rate)+'_'+str(optimizer)+'_'+str(dropout_rate)+'_'+str(denselayer_size)+'_'+str(train_conv_layer)+'.{epoch:02d}-{val_acc:.2f}.hdf5'
    # model_checkpoint = ModelCheckpoint(model_names, monitor='val_acc', verbose=1, save_best_only=True)
    
    callbacks = [tensor_board ,csv_logger, early_stop, reduce_lr]
    #callbacks.append(model_checkpoint)
    
    # generators
    train_generator = train_data_gen.flow_from_directory(train_data, (img_width, img_height), batch_size=batch_size,
                                                         class_mode='categorical')


    print("Starting Tuning the Model")

    #fine tune the model
    model.fit_generator(
      train_generator,
      steps_per_epoch=train_generator.samples/train_generator.batch_size ,
      epochs=num_epochs,
      validation_data=valid_generator,
      validation_steps=valid_generator.samples/valid_generator.batch_size,
      verbose=1,
      callbacks=callbacks)
    return model
