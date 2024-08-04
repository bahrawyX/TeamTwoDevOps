#!/bin/bash

# Define the variables
yaml_file_path=$1
build_number=$2

# Replace 'latest' with the build number in the image tag
sed -i "s|image: xbahrawy/finalproject:latest|image: xbahrawy/finalproject:$build_number|g" $yaml_file_path
