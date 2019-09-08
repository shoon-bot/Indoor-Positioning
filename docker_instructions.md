How to Docker
=============

Images
------

Docker has Images and containers.
An image is like a template used to create containers.
The image is either downloaded from the internet, or created using a `Dockerfile`
eg:-
* `docker pull tensorflow/tensorflow:latest-gpu-py3-jupyter`
* `docker pull tensorflow/tensorflow:latest-gpu-py3`

`docker pull <Image Name>`          - Download a new docker image

`docker images`/`docker image ls`   - List all the downloaded images

`docker image rm <Image ID>`        - Delete a Docker image

`docker image prune`                - Remove all Images that do not have tags, or do not have any (active?) continers


Containers
----------

A container is like a mini OS. Each new container can be considered a clone of a Docker Image.
Changes can then be made inside each container, like installing VIM, git, etc.
Changes made to one container will not affect other continers even if they are from the same image.

`docker ps`/`docker container ls`       - List active containers. (Use `-a` option to list all containers (including stopped ones))

`docker container rm <Container ID>`    - Remove a Container

`docker container prune`                - Remove all stopped containers


### Creating a New Container

To create a new container:

```
optirun docker run --runtime=nvidia -it \
--name tensor_gpu \
-v $PWD:/home/Deep_Learning \
-w /home/Deep_Learning \
--user $(id -u):$(id -g) \
tensorflow/tensorflow:latest-gpu-py3 \
bash
```

`optirun`               - To tell Bumblebee to use the GPU

`docker run`            - Create the container

`--runtime=nvidia`      - Needed for GPU use

`-it`                   - For use with bash

`-d`                    - Daemon - Run in background.

`--rm`                  - Remove/Delete the container immediately after use.

`--name <name>`         - Give the container a name for easy access in the future

`-v <local>:<remote>`   - Mount the 'local' directory on your machine to the 'remote' docker direcctory

`-w <directory>`        - Set the working directory (default landing directory when using bash)

`--user UUID:GUID`      - set the userid so you wont be logged in as root. use `$(id -u):$(id -g)` to login as yourself (preferable).

`<Docker Image>`        - Select the `Image` you want to use. Preferably with the `py3` tag

`<comand>`              - Type the comand to execute. Can be `bash` to open a shell. Or `python -c  '<Code>'` to execute code, or `nvidia-smi` to test the gpu, or anything else.


### Using Containers

To use a container, first create it, preferably with the bash command.
Then use it.

Exit bash normally with the `exit` command.


### Restarting the Container

`optirun docker start -i <Container Name/ID>`

This will restart the container, and the GPU will work again.

Execute this comand without specifiing a 'comand' (it will re-execute the command used to create the container (probably bash))


`Optirun docker exec <Container Name> <Command>`

This can be used to run a different command on an existing container. Create a new bash shell, run a python script or do anything else, but **GPU will not work** here.


##### Leaving bash without killing the container

The bash shell can be exited using `<Ctrl-P> + <Ctrl-Q>`

This will keep the container alive in the background, and can be restarted with `docker exec`


Atom
----

The docker container is maintained seperately from the regular OS and file system.
This means that while programs can still be edited outside the container, using vim or atom, these programs can only be run from within the container.
As such, Hydrogen in Atom will not work, since none of the tensorflow packages are installed.

To get around this, a connection will have to be established between Hydrogen in Atom, and the Kernel in the container inside Docker.

### Docker execution via kernel gateways

Follow the 'Example Docker kernel gateway' hedding in the official [Hydrogen package instructions](https://atom.io/packages/greyatom-hydrogen#docker-execution-via-kernel-gateways)

Create the Dockerfile according to the instructions, and build the docker image.

**Dockerfile:**
```
FROM tensorflow/tensorflow:latest-gpu-py3-jupyter
RUN apt-get install -y vim git
RUN pip install jupyter_kernel_gateway
EXPOSE 8888
```

Then create a container of the image, ensuring to add the port number and a bash shell:

`optirun docker run -it --runtime=nvidia -v /home/shaun/Programs:/Programs -w /Programs --name tensor_atom -p 8888:8888 tensor_atom:latest bash`

If closed, reopen an interactive bash shell in the container:

`optirun docker start -i tensor_atom`

Finally within the bash shell run this command to allow a connection from atom to the container:

`jupyter kernelgateway --ip=0.0.0.0 --port=8888`

Leave the command runnning as long as you want to use Hydrogen. If you `<Ctrl-C>` from the command the remote Kernel will close and hydrogen will not be able to function.

If you want to use the Docker container, start the `tensor_root` container instead, and make any needed changes from there.


### Connect Hydrogen to the remote kernel
Ensure that the Hydrogen settings already have the 'Kernel Gateway' setting configured to:

`[{"name": "Docker Tensorflow Container", "options": {"baseUrl": "http://localhost:8888"}}]`


#### To connect:
* Open Atom
* `ctrl-shift-p` and find `Hydrogen: Connect to Remote Kernel`
* Select the kernel gateway configured in Hydrogen's settings ('Docker Tensorflow Container')
Select 'Python 3'
* Hydrogen will now run all commands from the remote Kernel. Keep in mind that the paths to files will now have to be relative to the Docker container's file system, and not the host machine's.


Setting Up The Whole Docker Ting
--------------------------------

* `sudo pacman -S docker` - Installing Docker.
* `systemctl enable --now docker` - Starting the Docker daemon.
* `sudo usermod -aG docker $USER` - Adding myslef to the docker group (so I can run docker commands without `sudo` )
* `docker pull tensorflow/tensorflow:latest-gpu-py3` - Downloading the Tensorflow Docker image (gpu + python 3)
* `docker pull tensorflow/tensorflow:latest-gpu-py3-jupyter` - Downloading the same Docker image with jupyter notebook support

* `optirun docker run --runtime=nvidia -it --name tensor_gpu -v /home/Shaun/Programs/Deep_Learning:/home/Deep_Learning -w /home/Deep_Learning --user $(id -u):$(id -g) tensorflow/tensorflow:latest-gpu-py3 bash` - Create a docker container (tensor_gpu) without root access.

* `optirun docker run --runtime=nvidia -it --name tensor_root -v /home/shaun/Programs:/Programs -w /Programs tensorflow/tensorflow:latest-gpu-py3 bash` - Another Container (tensor_root) with root access.

* `vim Dockerfile` - Scroll back to 'Docker execution via kernel gateways' for details.
* `docker build -t tensor_atom .` - Turn the Dockerfile into a Docker Image.
* `jupyter kernelgateway --ip=0.0.0.0 --port=8888` - (Within the container) To start the kernal gateway and allow Hydrogen to connect.
