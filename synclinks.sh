#!/bin/env bash

SOURCE_DIR="/Users/u.yilmaz/dev/ghostty-shaders"
DEST_FILE="/Users/u.yilmaz/.config/ghostty/shaders"

# Define the prefix to attach.
prefix="# custom-shader = \"/Users/u.yilmaz/dev/ghostty-shaders"

# Loop over all files in the folder.
rm -f $DEST_FILE
for file in "$SOURCE_DIR"/*.glsl; do
  # Check if the current item is a file.
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    filename_no_ext="${filename%.*}"
    echo "${prefix}/${filename}\"" >> "$DEST_FILE"
  fi
done

