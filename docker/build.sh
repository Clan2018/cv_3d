#! /usr/bin/env bash

CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

docker build --network=host -t "dev_os:0.0.2" -f "${CURR_DIR}/dev_os.dockerfile" "${CURR_DIR}/"
