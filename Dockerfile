FROM ros:humble
SHELL ["/bin/bash", "-c"]
ENV GZ_VERSION=garden

WORKDIR /root

# update GPG keys for ROS
ARG ROS2_LATEST_ARCHIVE_KEYRING="/usr/share/keyrings/ros2-latest-archive-keyring.gpg"
RUN sudo rm -f ${ROS2_LATEST_ARCHIVE_KEYRING}
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o ${ROS2_LATEST_ARCHIVE_KEYRING}

# Remove Gazebo Fortress
# RUN apt remove --purge -y gazebo* libgazebo* || true
# RUN apt autoremove -y

# install ping, pip and other utils
RUN apt update && apt install -y --no-install-recommends \
	iputils-ping \
	pip \
	wget \
	lsb-release \
	gnupg 

# Install Gazebo Garden
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
RUN apt update && apt install -y gz-garden

# install Cyclone DDS and ROS stuff
RUN apt update && apt install -y --no-install-recommends \
	ros-humble-rmw-cyclonedds-cpp \
	ros-humble-joint-state-publisher \
	ros-humble-ros2-control \
	ros-humble-ros2-controllers \
	ros-humble-gz-ros2-control \
	ros-humble-ros-gz \
	ros-humble-ros-gz-sim \
	ros-humble-ros-gz-bridge \
	ros-humble-rviz2 \
	ros-humble-rqt* \
	ros-humble-xacro \
	ros-humble-vision-opencv \
	ros-humble-rviz-visual-tools

# install python dependencies
RUN pip install --upgrade pip
RUN pip install requests
# install YOLO and aux pkgs
#RUN pip install ultralytics --ignore-installed
RUN pip install ros2_numpy

# create workspace
RUN mkdir -p ptz_ws/src
WORKDIR /root/ptz_ws/
RUN source /opt/ros/humble/setup.bash && colcon build

# setup .bashrc
RUN echo "" >> /root/.bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc
RUN echo "source /root/ptz_ws/install/setup.bash" >> /root/.bashrc
RUN echo "" >> /root/.bashrc
RUN echo "export ROS_DOMAIN_ID=90" >> /root/.bashrc
RUN echo "export ROS_LOCALHOST_ONLY=0" >> /root/.bashrc
RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> /root/.bashrc
# force gazebo garden
RUN echo "export GZ_VERSION=garden" >> /root/.bashrc
# remove safety check to solve dubious ownership of git repositories
RUN echo "git config --global --add safe.directory '*'" >> /root/.bashrc


# git clone
WORKDIR /root/ptz_ws/src
COPY ./src .
# RUN git clone https://github.com/clearpathrobotics/ptz_action_server.git -b ros2
# RUN git clone https://github.com/ros-perception/image_common camera_info_manager_py -b humble
# RUN git clone https://github.com/pakocero/axis_camera -b humble-devel

# install zbar qr code scanner
#RUN apt update && apt install -y --no-install-recommends ros-humble-zbar-ros
#RUN ls

WORKDIR /root/ptz_ws
# solve ROS dependencies
RUN ls ./src
RUN source /opt/ros/humble/setup.bash && source /root/ptz_ws/install/setup.bash \
	&& rosdep install --from-paths ./src/zbar_ros --ignore-src -r -y
# compile workspace
RUN source /opt/ros/humble/setup.bash && \
    colcon build --packages-select ptz_action_server_msgs
    
RUN source /opt/ros/humble/setup.bash && \
	source /root/ptz_ws/install/setup.bash && \
	colcon build
# recompile axis msgs because it fails first time
WORKDIR /root/ptz_ws	
RUN source /opt/ros/humble/setup.bash && \
	source /root/ptz_ws/install/setup.bash && \
	colcon build --packages-select axis_msgs


