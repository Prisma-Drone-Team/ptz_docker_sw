img_name="ptz_sw_img_final"
cnt_name="ptz_sw_cnt_final"

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
    -v ./src:/root/ptz_ws/src \
    -v ./.git:/root/ptz_ws/.git \
    -v ./.gitmodules:/root/ptz_ws/.gitmodules \
    -e DISPLAY=$DISPLAY \
    --network host \
    --workdir="/root/ptz_ws" \
    --name=$cnt_name $img_name bash
fi
