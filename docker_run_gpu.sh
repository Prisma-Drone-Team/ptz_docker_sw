img_name="ptz_sw_img"
cnt_name="ptz_sw_nvidia_cnt"

# Check if container exists and is not running
if docker container inspect $cnt_name > /dev/null 2>&1; then
    echo "Found existing container: $cnt_name"
    
    # If container exists but is stopped, start it
    if [ "$(docker container inspect -f '{{.State.Running}}' $cnt_name)" = "false" ]; then
        echo "Starting container..."
        docker start $cnt_name
    fi
    
    # Attach to the container
    echo "Attaching to container..."
    docker exec -it $cnt_name bash
else
    # Create new container 
    echo "Creating new container..."
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
fi
