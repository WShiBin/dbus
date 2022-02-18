#!/bin/bash

# Default value
clang_format=$(which clang-format)
echo "clang-format: $clang_format"

function check_requirement_for_clang_foramt() {
    # 防止clang-format 拷贝之后没有可执行权限
    if [[ ! -x "${clang_format}" ]]; then
        chmod u+x ${clang_format}
        echo "add exec permission for clang_format"
    fi
}

function format_file() {
    # NOTE:这两个文件太大(22W行), 格式化会崩溃
    if [[ $1 == *sqlite3.c || $1 == *sqlite3.h ]]; then
        echo "for some reason, $path will not format"
        return
    fi

    # format
    echo "formatting file  --->  $1"
    ${clang_format} -i $1
}

function walk() {
    for file in $1/*; do
        local path=$file
        if [ -d $path ]; then
            walk $path
        else
            # 格式化.c/.h后缀文件
            if [[ $path == *.c || $path == *.h ]]; then
                format_file $path
            fi
        fi
    done
}

check_requirement_for_clang_foramt

if [[ -n $1 ]]; then
    if [[ -d $1 ]]; then
        # 格式化指定目录
        walk $1
    elif [[ -f $1 ]]; then
        # 格式化指定文件
        format_file $1
    else
        echo "can't recognize $1"
    fi
else
    walk . # 格式化当前项目
fi