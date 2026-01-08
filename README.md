# ptz_docker_sw

Docker image to run the Axis PTZ for Leonardo Drone Contest 2025. It can be run with or without NVIDIA GPU capabilities.

## Prerequisites
* Docker
* NVIDIA drivers and Container Toolkit (OPTIONAL) 

If you want to run the software using GPU processing (which is suggested especially because of the YOLO ROI calculation module), you first have to install the `nvidia-container-toolkit`.
To do so, execute the following in a command line of the host system:

```bash
# Add the package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

```

## Clone repository
```bash
git clone --recurse-submodules https://github.com/Prisma-Drone-Team/ptz_docker_sw
```

## Build docker image
Inside the `ptz_docker_sw` folder, run:
```
./docker_build.sh
```
It will build the image using the `Dockerfile`. As default, it will be called `ptz_sw_img`, but you can change the name by changing the `img_name` variable value in the `docker_build.sh` file.

## Run docker container
Inside the `ptz_docker_sw` folder, run:
#### Without GPU
```
./docker_run.sh
```
#### With GPU
```
./docker_run_gpu.sh
```
If you have modified the image name, remember to change it inside this file also. Inside here you can alse change the container name.

## Update submodules
Either from outside or inside the Docker container, from the main repository folder, simply run:
```bash
git pull --recurse-submodules
```
It could ask you username and password.

## Update main repository
Either from outside or inside the Docker container, from the main repository folder, simply run:
```bash
git pull
```
It could ask you username and password.

## Development
VSCode can be used to develop inside the container. The run script is such that it will share also the `.git` folder for the main repository, so you can use VSCode git tools from inside.
It will find all the submodules as separate git repositories, so you can work on them independently.
If you want to work on the general repository files (`README.md`, `docker_run.sh`, `docker_build.sh`, `Dockerfile`), you should do this from outside of the container, since these files are not shared inside it.
