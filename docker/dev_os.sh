#!/usr/bin/env bash

TAB="    " # 4 Spaces

export USER_ID=$(id -u)
export GID=$(id -g)

function _start() {
    local dev_container="dev_os_${USER}"
    local dev_image="dev_os:0.0.2"
    local shm_size="2G"
    local dev_inside="in-dev-docker"
    local local_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
    local volumes="-v ${local_dir}:/dev_os"
    local local_host="$(hostname)"
    local display="${DISPLAY:-:0}"
    echo "${dev_container}"
    docker run -itd \
        --privileged \
        --name "${dev_container}" \
        -e DISPLAY="${display}" \
        --user $USER_ID:$GID \
	-v="/etc/group:/etc/group:ro" \
	-v="/etc/passwd:/etc/passwd:ro" \
	-v="/etc/shadow:/etc/shadow:ro" \
        ${volumes} \
        --net host \
        -w /dev_os \
        --add-host "${dev_inside}:127.0.0.1" \
        --add-host "${local_host}:127.0.0.1" \
        --hostname "${dev_inside}" \
        --shm-size "${shm_size}" \
        --pid=host \
        "${dev_image}" \
        /bin/bash
}

function _stop() {
    local containers
    containers="$(docker ps -a --format '{{.Names}}')"
    for container in ${containers[*]}; do
        if [[ "${container}" =~ dev_os_${USER} ]]; then
            echo -e "\033[1;36mnow stop container ${container} ...\033[0m"
            if docker stop "${container}" >/dev/null; then
                docker rm -f "${container}" 2>/dev/null
                echo -e "\033[1;32mcontainer ${container} stoped successfully.\033[0m"
            else
                echo -e "\033[1;31mcontainer ${container} stoped failed.\033[0m"
            fi
        fi
    done
}

function _into() {
    local dev_container="dev_os_${USER}"
    docker exec -u $USER_ID:$GID -it "${dev_container}" /bin/bash
}

function _print_usage() {
    echo "Usage:"
    echo "Available options:"
    echo "${TAB}start      Start dev docker container"
    echo "${TAB}stop       Stop and remove dev docker container"
    echo "${TAB}into       Step into dev docker container"
    echo "${TAB}help       Show this message and exit"
}

function _parse_arguments() {
    if [[ $# -ne 1 ]]; then
        print_usage
        exit 0
    fi
    while [[ $# -gt 0 ]]; do
        local opt="$1"
        shift
        case $opt in
            start)
                echo -e "\033[1;33mstart dev docker container\033[0m"
                _stop
                _start
                shift
                ;;
            stop)
                echo -e "\033[1;33mstop and remove dev docker container\033[0m"
                _stop
                shift
                ;;
            into)
                echo -e "\033[1;33mstep into dev docker container\033[0m"
                _into
                shift
                ;;
            help)
                _print_usage
                exit 0
                ;;
            *)
                echo -e "\033[1;31munknown option: ${opt}\033[0m"
                _print_usage
                exit 1
                ;;
        esac
    done
}

function main() {
    _parse_arguments "$@"
}

main "$@"
