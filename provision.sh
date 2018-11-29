#!/bin/sh

## Build virtual machine
vagrant up

## provision
vagrant box list | cut -f 1 -d ' ' | while read; do 

  docker-machine -d generic \
    --generic-ssh-key=$(vagrant ssh-config | awk '/IdentityFile/ { print $NF }' \
    --generic-ssh-user=$(vagrant ssh-config | awk '/User/ { print $NF }') \
    --generic-ip-address=$(vagrant ssh-config | awk '/HostName/ { print $NF }') \
    --generic-ssh-port=$(vagrant ssh-config | awk '/Port/ { print $NF }') \
    $REPLY

end

eval $(docker-machine env default)
docker swarm init
docker network create -d overlay --subnet=192.168.88.0/24 --scope swarm public
docker network create -d overlay --subnet=192.168.87.0/24 --scope swarm internal
docker stack deploy -c docker-compose.yml $(basename "$(pwd)")

eval $(docker-machine env worker1)
eval $(docker-machine ssh default docker swarm join --token-worker)
