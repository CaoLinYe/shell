#!/bin/bash 

##############################################################
# tinypng压缩脚本
# KEY 7ZjRlLpmDKNSQDCXPvNXdmZVCLXj7bBk
#############################################################
INPUT= # 压缩文件 
OUTPUT= # 输出文件
# TINYPNG_APIKEY= # 读bash_profile 

usage () {
	echo "
	tinypng压缩单张图片
	-i input 
	-o output
	-h help 
	example: 
		tinypng.sh -i a.png -o b.png
	"
    exit 1
}

while getopts "i:o:h" opt; do
	case $opt in
        i) INPUT="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        h) usage ;;
        ?) usage ;;
    esac
done

if [[ ! -f "$INPUT" ]]; then
    echo "error inputfile $INPUT not exist"
    exit 1
fi

if [[ -z "$OUTPUT" ]]; then
    echo "error no output file"
    exit 1
fi

result=$(curl --silent --user api:$TINYPNG_APIKEY --data-binary "@$INPUT" -i https://api.tinify.com/shrink)
if [[ $? -eq 0 ]]; then
    count=$(echo "$result" | grep -i 'compression-count' | awk '{print $2}' | tr -d '\r')
    url=$(echo "$result" | grep -i 'location:' | awk '{print $2}' | tr -d '\r')
    if [[ -n "$url" ]]; then
        echo "success:$INPUT url:$url count:$count"
        curl --silent "$url" --output "$OUTPUT"
        if [[ $? -ne 0 ]]; then
            echo "error download:$OUTPUT url:$url"
        fi
    else
        echo "error compress:$INPUT"
    fi
else
    echo "error curl:$INPUT"
fi






