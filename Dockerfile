FROM "tensorflow/tensorflow:latest-gpu-py3-jupyter"

RUN apt-get install -y vim git 
RUN pip install jupyter_kernel_gateway
RUN echo 'eval "$(dircolors -p | sed "s/ 4[0-9];/ 01;/; s/;4[0-9];/;01;/g; s/;4[0-9] /;01 /" | dircolors --sh /dev/stdin)"' >> /root/.bashrc

EXPOSE 8888

