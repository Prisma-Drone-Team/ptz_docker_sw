# ptz_docker_sw

Docker image to run the Axis PTZ for Leonardo Drone Contest 2025

## Clone repository
```
git clone --recurse-submodules https://github.com/Prisma-Drone-Team/ptz_docker_sw
```

## Build docker image
Inside the `ptz_docker_sw` folder, run:
```
./docker_build.sh
```
It will request a docker image name, and then if you want to run the building process without using caching.
If `y` is selected, then the `docker build` command is run with the `--no-cache` flag, that enables the docker image to be rebuilt from scratch overriding the cached items.
If `n` is selected, the docker building will be performed as usual, using the cached elements.

## Run docker container
Inside the `ptz_docker_sw` folder, run:
```
./docker_run.sh
```
It will request a image name (same that you put when running `docker_build.sh`) and a container name.

## Update submodules
Either from outside or inside the Docker container, from the main repository folder, simply run:
```
git pull --recurse-submodules
```
It could ask you username and password.

## Update main repository
Either from outside or inside the Docker container, from the main repository folder, simply run:
```
git pull
```
It could ask you username and password.

## Development
VSCode can be used to develop inside the container. The run script is such that it will share also the `.git` folder for the main repository, so you can use VSCode git tools from inside.
It will find all the submodules as separate git repositories, so you can work on them independently.
If you want to work on the general repository files (`README.md`, `docker_run.sh`, `docker_build.sh`, `Dockerfile`), you should do this from outside of the container, since these files are not shared inside it.
