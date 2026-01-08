img_name="ptz_sw_img"
cnt_name="ptz_sw_nvidia_cnt"


#-v ./src:/root/ros2_ws/src \
docker run -it --privileged -v /dev/bus/usb:/dev/bus/usb \
--shm-size=8G \
-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
-v ./src:/root/ros2_ws/src \
-v ./.git:/root/ros2_ws/.git \
-v ./.gitmodules:/root/ros2_ws/.gitmodules \
-e DISPLAY=$DISPLAY \
--gpus all \
--network host \
--workdir="/root/ros2_ws" \
--name=$cnt_name $img_name bash
