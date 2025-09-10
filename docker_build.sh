read -p "Image name >> " img_name
read -p "no cache? (y/n) >>" no_cache_yn

if [[ $no_cache_yn == "y" ]] || [[ $no_cache == "Y" ]]; then
docker build -t $img_name --no-cache --network=host --progress=plain .
elif [[ $no_cache_yn == "n" ]] || [[ $no_cache == "N" ]]; then
docker build -t $img_name --network=host --progress=plain .
else echo "NOT VALID"
fi
