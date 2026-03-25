#!/bin/bash 

INPUT=
OUTPUT=
SIZE=
LEFT=20
RIGHT=20
TOP=20
BOTTOM=20

usage () {
    echo "
        把一张大图切割为游戏中可以使用的9宫格图片 
        -h help 显示帮助
        -i input  输入文件
        -o output 输出文件
        -s size 切割尺寸 
        -l left 左侧距离
        -r right  右侧距离
        -t top 上侧距离
        -b bottom 下侧距离
    "
    exit 1
}

while getopts "i:o:s:l:r:t:b:h" opt; do
    case $opt in
        i) INPUT="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        s) SIZE="$OPTARG" ;;
        l) LEFT="$OPTARG" ;;
        r) RIGHT="$OPTARG" ;;
        t) TOP="$OPTARG" ;;
        b) BOTTOM="$OPTARG" ;;
        h) usage ;;
		?) usage ;;
    esac
done

if [[ -n "$SIZE" ]]; then
    LEFT="$SIZE"
    RIGHT="$SIZE"
    TOP="$SIZE"
    BOTTOM="$SIZE"
fi

if [[ ! -f "$INPUT" ]]; then
    echo "$INPUT 不存在"
    exit 1
fi

if [[ -z "$OUTPUT" ]]; then
    OUTPUT="$INPUT"
fi

WIDTH=$(identify -format "%w" "$INPUT")
HEIGHT=$(identify -format "%h" "$INPUT")

mkdir -p .tmp
convert "$INPUT" -crop ${LEFT}x${TOP}+0+0 .tmp/tl.png                                     # 左上
convert "$INPUT" -crop ${RIGHT}x${TOP}+$((WIDTH-RIGHT))+0 .tmp/tr.png                     # 右上
convert "$INPUT" -crop ${LEFT}x${BOTTOM}+0+$((HEIGHT-BOTTOM)) .tmp/bl.png                 # 左下
convert "$INPUT" -crop ${RIGHT}x${BOTTOM}+$((WIDTH-RIGHT))+$((HEIGHT-BOTTOM)) .tmp/br.png # 右下

# 合并（2x2）
convert .tmp/tl.png .tmp/tr.png +append .tmp/top.png
convert .tmp/bl.png .tmp/br.png +append .tmp/bottom.png
convert .tmp/top.png .tmp/bottom.png -append "$OUTPUT"

# 清理临时文件
rm -rf .tmp
echo "完成: $LEFT $RIGHT $TOP $BOTTOM $OUTPUT"
