img_name="ptz_sw_img"

docker build -t $img_name --network=host --progress=plain .
