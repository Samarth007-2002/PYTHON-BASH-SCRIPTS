#!/bin/bash

if [[ $# -ne 2]]; then
        echo "Usage: $0 <source> <destintion>"
        exit 1
fi

SOURCE_DIR=$1
DEST_DIR=$2

if [[ ! -d "$SOURCE_DIR"]]; then
        echo "Error: Doesnt exist"
        exit 1
fi

if [[ ! -d "$DEST_DIR"]]; then
        mkdir -p "$DEST_DIR"
fi

find "$SOURCE_DIR" -type f -size +1G -exec mv {} "$DEST_DIR" \;

echo "Files larger than 1gb have been moved"
