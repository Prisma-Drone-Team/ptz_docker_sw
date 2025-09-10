read -p "Image name >> " img_name
read -p "Container name >> " cnt_name


#-v ./src:/root/ros2_ws/src \
docker run -it --privileged -v /dev/bus/usb:/dev/bus/usb \
-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
-e DISPLAY=$DISPLAY \
--network host \
--workdir="/root/ros2_ws" \
--name=$cnt_name $img_name bash
