# ptz_docker_sw

Docker image to run the Axis PTZ for Leonardo Drone Contest 2025. It can be run with or without NVIDIA GPU capabilities.

+ **Using Cyclone DDS implementation**

+ **Tested on Intel Core I7 with Nvidia RTX4060 system** 

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
git clone --recurse-submodules -b paper https://github.com/Prisma-Drone-Team/ptz_docker_sw
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
If the container doesn't exist, it will create one named `ptz_sw_cnt` starting from the image named `ptz_sw_img`, then start it and attach. If a container named `ptz_sw_cnt` exists, it just starts and attach to it. You can change the name of the container by changing the `img_name` and `cnt_name` variables in the `docker_run.sh` script.

If you have modified the image name, remember to change it inside this file also.
#### With GPU
```
./docker_run_gpu.sh
```
If the container doesn't exist, it will create one named `ptz_sw_nvidia_cnt` starting from the image named `ptz_sw_img`, then start it and attach. If a container named `ptz_sw_nvidia_cnt` exists, it just starts and attach to it. You can change the name of the container by changing the `img_name` and `cnt_name` variables in the `docker_run_gpu.sh` script.

If you have modified the image name, remember to change it inside this file also.

## Software configuration

### Network configuration

#### Camera IP address
The camera IP address can be setup in the file found in `src/axis_camera/launch/axis_camera.launch`. Here you can also configure other camera connection parameters such as username and password, if an encrypted connection is used, and connection port.

#### PC connection
PC is connected to the camera through an Ethernet switch capable of PoE (Power over Ethernet). Create a new Ethernet Network connection, and give it a name of your choice. In the *IPv4 Settings* panel, choose an IP address for your PC and a proper netmask (e.g. `192.164.3.54`, netmask `24`). In order to use both a wired Ethernet connection to the camera and a wireless connection to the Internet, leave the *Gateway* field empty.

### Camera calibration

#### Extrinsic
It is done by editing the `axis_camera.xacro` file inside the `src/ptz_manager/urdf` folder, that describes the transform frames used by the camera software for position calculations.

There are 2 joints to edit:
* **`map_to_footprint`**: the transformation between map frame and footprint frame, so the ground projection of the camera. Here you basically put only the `x` and `y` values to move from `map` frame to `camera` frame without considering elevation and maintaining the same orientation of the map frame.
* **`footprint_to_camera`**: positions the camera with respect to the footprint frame. Here you put elevation in the `z` value and rotation values as roll, pitch, and yaw angles. You can use the `DEG_TO_RAD` helper variable to convert from degrees to radians, needed by the ROS system.
#### Intrinsic
Intrinsic camera calibration is **NOT** necessary to run the software and it is **NOT** used by the software as is. It is only needed if you want to add object pose detection capabilities, like ArUco pose detection.

It is done by running the `cameracalibrator` node inside `camera_calibration` ROS2 package. Once intrinsic calibration files are obtained, you can put them inside `src/ptz_manager/Calib_data` for convenience.
### Software parameters

**Remember to compile the ROS workspace if parameters are changed!**

All parameters are configured in `src/ptz_manager/param/param.yaml`. Below is a description of each parameter:

#### ROS Topic Configuration
- **`camera_tf_name`**: Name of the camera transform frame (e.g., "axis_camera_frame")
- **`cmd_topic_name`**: ROS topic for sending PTZ (Pan-Tilt-Zoom) commands to the camera
- **`state_topic_name`**: ROS topic for receiving PTZ state feedback from the camera
- **`cmd_topic_rate`**: Publishing rate for PTZ commands (Hz)
- **`seed_cmd_topic_name`**: Topic for receiving mission commands/tasks
- **`camera_tf_pub_rate`**: Publishing rate for camera transform frames (Hz)
- **`roi_list_topic_name`**: Topic for receiving ROI (Region of Interest) detections from the ROI calculation module (e.g. YOLO based calculation)

#### Camera Parameters
- **`brightness`**: Camera brightness level (0-10000)
- **`aperture`**: Camera aperture/iris setting (0-9999)
- **`max_zoom`**: Maximum allowed zoom level (0-130 for Axis M5525-E cameras)
- **`zoom_mapping_k`**: Scaling factor for converting distance to zoom commands
- **`qr_code_side_mm`**: Expected QR code side length in millimeters (used for distance calculation)

#### Coverage Control Parameters
These parameters control the coverage behavior:

- **`cover_z_distr_mean`**: Mean height (in meters) for random coverage points (normal distribution)
- **`cover_z_distr_stddev`**: Standard deviation of height distribution
- **`cover_z_max_height`**: Maximum height constraint for coverage area (meters)
- **`cover_target_tf_name`**: Transform frame name for current coverage target frame
- **`arena_corner_points_from_map`**: Corner coordinates of the coverage area as array of strings (format: "(x,y)" in meters)

#### Velocity Controller Gains
- **`cover_vel_ctrl_Kp_pan`**: Proportional gain for pan velocity control
- **`cover_vel_ctrl_Kp_tilt`**: Proportional gain for tilt velocity control
- **`cover_vel_ctrl_Kp_zoom`**: Proportional gain for zoom velocity control
- **`cover_vel_ctrl_Kd_zoom`**: Derivative gain for zoom velocity control (damping)

#### Velocity Limits
- **`cover_vel_ctrl_max_pan_vel`**: Maximum pan velocity (rad/s)
- **`cover_vel_ctrl_max_tilt_vel`**: Maximum tilt velocity (rad/s)
- **`cover_vel_ctrl_max_zoom_vel`**: Maximum zoom velocity

#### Goal Reaching Thresholds
- **`cover_vel_ctrl_goal_reach_pan_thr`**: Pan error threshold to consider goal reached (radians)
- **`cover_vel_ctrl_goal_reach_tilt_thr`**: Tilt error threshold to consider goal reached (radians)
- **`cover_vel_ctrl_goal_reach_zoom_thr`**: Zoom error threshold to consider goal reached 

## Launch the simulation

Once the workspace is built and sourced, inside the container, start the Gazebo simulation using the provided launch file:

```bash
ros2 launch ptz_gz_sim launch_sim.launch.py
```

The command will:

1. Start Gazebo with the `leonardo_race.sdf` world found in `worlds/`
2. Spawn the PTZ camera robot description (`axis_camera_gazebo.xacro`) and publish its TF via `robot_state_publisher`.
3. Launch the `ros_gz_bridge` to connect ROS 2 topics with Gazebo messages (clock, images, camera info, zoom commands, etc.).
4. Start the controller manager along with several ros2_control plugins:
   - `joint_state_broadcaster` for reporting joint states.
   - `position_controller` and `velocity_controller` for the pan/tilt joints.
   These are spawned via the `controller_manager` nodes and configured by the URDF's `libgz_ros2_control` tags along with parameters from `config/controller_params.yaml`.
5. A `fake_axis_camera_node` is launched to mimic the axis camera interface.
6. RViz2 is started with a default configuration from the `ptz_manager` package so you can visualize the camera and TF frames.

## Complete Motion Stack Integration 

**🚁 For Leonardo Drone Contest 2025 development:**

The PTZ motion stack can run in **simulation** using a **dual-container architecture**:

- **Main Container**: Runs simulation (UAV + PTZ + rover world) - follow **uav_motion_stack** instructions
- **PTZ Container**: Runs motion stack (ptz_manager + SEED commands + YOLO + QR scanning)

### Quick Start:
```bash  
# Terminal 1 - Main Container (simulation)
ros2 launch <uav_motion_stack_simulation_launch>  # Follow uav_motion_stack guide

# Terminal 2 - PTZ Container (motion stack)  
ros2 launch ptz_manager ptz_navigation_stack.launch.py

# Terminal 3 - Send SEED commands
ros2 topic pub --once /seed_pdt_camera/command std_msgs/msg/String "data: 'cover(null,34,1,0:10:00)'"
```

**📖 See `README_SIMULATION_INTEGRATION.md` for complete integration guide.**

This provides **hardware-identical** motion stack behavior in simulation with **ZOOM NOW WORKING**! ✅

## Run the software with hardware
Inside the container, run the following command:

```bash
ros2 launch ptz_manager ptz_manager.launch
```

It will launch all the required ROS2 nodes, included visualization with RViz.

### Launch a cover task manually
You have to publish once on the topic `/seed_pdt_camera/command` a proper cover command. It follows the format:

```
cover(zone,target_id,task_id,deadline)
```
where:
* `zone`: it is specified as a set of 4 corners, e.g. `(1,0),(5,0),(5,3),(1,3)`; can also be `null`, in which case it starts a cover with the default area specified in the `arena_corner_points_from_map` parameter in the `ptz_manager` configuration file
* `target_id`: QR code task ID to find
* `task_id`: task id of the given command
* `deadline`: period of time in which the task should be accomplished, given in the format `h:mm:ss` (e.g. `0:13:00` meaning a period of 13 minutes from the command receipt)

An example command:

```bash
ros2 topic pub /seed_pdt_camera/command std_msgs/msg/String "{'data' : 'cover(null,34,2,0:13:00)'}" -1
```
Or, if you want to specify a zone:
```bash
ros2 topic pub /seed_pdt_camera/command std_msgs/msg/String "{'data' : 'cover((1,0),(5,0),(5,3),(1,3),34,2,0:13:00)'}" -1
```

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
