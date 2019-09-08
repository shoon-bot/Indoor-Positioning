import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '1' 
import tensorflow as tf

print("Is built with cuda?", tf.test.is_built_with_cuda())
print("is gpu avaliable?", tf.test.is_gpu_available())
