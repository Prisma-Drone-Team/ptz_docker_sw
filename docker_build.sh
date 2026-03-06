img_name="ptz_sw_img_final"

docker build -t $img_name --network=host --progress=plain .
