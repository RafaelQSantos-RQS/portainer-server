#!/bin/bash

main() {
    docker stack ps portainer_server
}

main "$@"