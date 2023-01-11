#!/usr/bin/env bash

TAB="    " # 4 Spaces

function _start() {
    local dev_container="dev_os_${USER}"
    local dev_image="dev_os:0.0.1"
    local shm_size="2G"
    local dev_inside="in-dev-docker"
    local local_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
    local volumes="-v ${local_dir}:/dev"
    local local_host="$(hostname)"
    local display="${DISPLAY:-:0}"
    echo "${dev_container}"
    docker run -itd \
        --privileged \
        --name "${dev_container}" \
        -e DISPLAY="${display}" \
        -e USER="root" \
        ${volumes} \
        --net host \
        -w /xviewer \
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
        if [[ "${container}" =~ xviewer_.*_${USER} ]]; then
            echo "Now stop container ${container} ..."
            if docker stop "${container}" >/dev/null; then
                docker rm -f "${container}" 2>/dev/null
                echo "Container ${container} stoped successfully."
            else
                echo echo "Container ${container} stoped failed."
            fi
        fi
    done
}

function _into() {
    local dev_container="dev_os_${USER}"
    docker exec -u "root" -it "${dev_container}" /bin/bash
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
    echo "$#"
    if [[ $# -ne 1 ]]; then
        print_usage
        exit 0
    fi
    while [[ $# -gt 0 ]]; do
        local opt="$1"
        shift
        case $opt in
            start)
                echo "Start dev docker container"
                _stop
                _start
                shift
                ;;
            stop)
                echo "Stop and remove dev docker container"
                _stop
                shift
                ;;
            into)
                echo "Step into dev docker container"
                _into
                shift
                ;;
            help)
                _print_usage
                exit 0
                ;;
            *)
                echo "Unknown option: ${opt}"
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
