FROM osrf/ros:humble-desktop-full
SHELL ["/bin/bash", "-c"]

WORKDIR /root

# update GPG keys for ROS
ARG ROS2_LATEST_ARCHIVE_KEYRING="/usr/share/keyrings/ros2-latest-archive-keyring.gpg"
RUN sudo rm -f ${ROS2_LATEST_ARCHIVE_KEYRING}
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o ${ROS2_LATEST_ARCHIVE_KEYRING}

# install ping
RUN apt update && apt install -y --no-install-recommends \
	iputils-ping \
	pip

# install Cyclone DDS
RUN apt install -y ros-humble-rmw-cyclonedds-cpp

# install python dependencies
RUN pip install --upgrade pip
RUN pip install requests

# create workspace
RUN mkdir -p ros2_ws/src
WORKDIR /root/ros2_ws/
RUN source /opt/ros/humble/setup.bash && colcon build

# setup .bashrc
RUN echo "" >> /root/.bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc
RUN echo "source /root/ros2_ws/install/setup.bash" >> /root/.bashrc
RUN echo "" >> /root/.bashrc
RUN echo "export ROS_DOMAIN_ID=71" >> /root/.bashrc
RUN echo "export ROS_LOCALHOST_ONLY=0" >> /root/.bashrc
RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> /root/.bashrc
# remove safety check to solve dubious ownership of git repositories
RUN echo "git config --global --add safe.directory '*'" >> /root/.bashrc


# git clone
WORKDIR /root/ros2_ws/src
COPY ./src .
# RUN git clone https://github.com/clearpathrobotics/ptz_action_server.git -b ros2
# RUN git clone https://github.com/ros-perception/image_common camera_info_manager_py -b humble
# RUN git clone https://github.com/pakocero/axis_camera -b humble-devel

# install zbar qr code scanner
#RUN apt update && apt install -y --no-install-recommends ros-humble-zbar-ros
#RUN ls

WORKDIR /root/ros2_ws
# solve ROS dependencies
RUN ls ./src
RUN source /opt/ros/humble/setup.bash && source /root/ros2_ws/install/setup.bash && rosdep install --from-paths ./src/zbar_ros --ignore-src -r -y
# compile workspace
RUN source /opt/ros/humble/setup.bash && \
	source /root/ros2_ws/install/setup.bash && \
	colcon build
# recompile axis msgs because it fails first time
WORKDIR /root/ros2_ws	
RUN source /opt/ros/humble/setup.bash && \
	source /root/ros2_ws/install/setup.bash && \
	colcon build --packages-select axis_msgs


