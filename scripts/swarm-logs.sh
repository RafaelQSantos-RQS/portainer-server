#!/bin/bash

main() {
    docker service logs portainer_server_server -f --tail 100
}

main "$@"